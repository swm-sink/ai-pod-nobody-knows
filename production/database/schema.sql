-- AI Podcast Production System - PostgreSQL Schema
-- Production database setup for LangGraph checkpointer and system state

-- Create database (run as superuser)
-- CREATE DATABASE podcast_production;
-- CREATE USER podcast_app WITH ENCRYPTED PASSWORD 'your_secure_password';
-- GRANT ALL PRIVILEGES ON DATABASE podcast_production TO podcast_app;

-- Connect to podcast_production database and run the following:

-- Create schema for application
CREATE SCHEMA IF NOT EXISTS podcast_production;
SET search_path TO podcast_production;

-- LangGraph checkpoints table (compatible with PostgresSaver)
CREATE TABLE IF NOT EXISTS checkpoints (
    thread_id TEXT NOT NULL,
    checkpoint_ns TEXT NOT NULL DEFAULT '',
    checkpoint_id TEXT NOT NULL,
    parent_checkpoint_id TEXT,
    type TEXT,
    checkpoint BYTEA,
    metadata BYTEA,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (thread_id, checkpoint_ns, checkpoint_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_checkpoints_thread_id
ON checkpoints(thread_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_checkpoints_parent
ON checkpoints(parent_checkpoint_id);

-- Episode tracking and management
CREATE TABLE IF NOT EXISTS episodes (
    episode_id TEXT PRIMARY KEY,
    topic TEXT NOT NULL,
    status TEXT DEFAULT 'initialized',
    budget_limit DECIMAL(10,2) DEFAULT 5.51,
    current_cost DECIMAL(10,2) DEFAULT 0.0,
    quality_score DECIMAL(3,1),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,

    CONSTRAINT valid_status CHECK (status IN ('initialized', 'research', 'planning', 'script', 'audio', 'completed', 'failed')),
    CONSTRAINT valid_budget CHECK (budget_limit > 0),
    CONSTRAINT valid_cost CHECK (current_cost >= 0),
    CONSTRAINT valid_quality CHECK (quality_score IS NULL OR (quality_score >= 0 AND quality_score <= 10))
);

-- Cost tracking with detailed attribution
CREATE TABLE IF NOT EXISTS cost_tracking (
    id SERIAL PRIMARY KEY,
    episode_id TEXT NOT NULL REFERENCES episodes(episode_id),
    operation TEXT NOT NULL,
    cost DECIMAL(10,4) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    provider TEXT,
    tokens_used INTEGER,
    api_call_duration INTERVAL,
    metadata JSONB,

    CONSTRAINT valid_cost CHECK (cost >= 0)
);

-- Indexes for cost tracking
CREATE INDEX IF NOT EXISTS idx_cost_tracking_episode
ON cost_tracking(episode_id, timestamp);

CREATE INDEX IF NOT EXISTS idx_cost_tracking_operation
ON cost_tracking(operation, timestamp);

-- Performance metrics tracking
CREATE TABLE IF NOT EXISTS performance_metrics (
    id SERIAL PRIMARY KEY,
    episode_id TEXT REFERENCES episodes(episode_id),
    metric_name TEXT NOT NULL,
    metric_value DECIMAL(10,4),
    measurement_unit TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB
);

-- System health and monitoring
CREATE TABLE IF NOT EXISTS system_health (
    id SERIAL PRIMARY KEY,
    component TEXT NOT NULL,
    status TEXT NOT NULL,
    response_time_ms INTEGER,
    error_count INTEGER DEFAULT 0,
    last_error TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT valid_status CHECK (status IN ('healthy', 'degraded', 'unhealthy', 'unknown'))
);

-- Grant permissions to application user
GRANT USAGE ON SCHEMA podcast_production TO podcast_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA podcast_production TO podcast_app;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA podcast_production TO podcast_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA podcast_production GRANT ALL ON TABLES TO podcast_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA podcast_production GRANT ALL ON SEQUENCES TO podcast_app;

-- Create view for episode summary
CREATE OR REPLACE VIEW episode_summary AS
SELECT
    e.episode_id,
    e.topic,
    e.status,
    e.budget_limit,
    e.current_cost,
    e.quality_score,
    e.created_at,
    e.completed_at,
    EXTRACT(EPOCH FROM (COALESCE(e.completed_at, NOW()) - e.created_at))/3600 as duration_hours,
    COALESCE(ct.operation_count, 0) as operation_count,
    COALESCE(ct.total_operations_cost, 0) as total_operations_cost
FROM episodes e
LEFT JOIN (
    SELECT
        episode_id,
        COUNT(*) as operation_count,
        SUM(cost) as total_operations_cost
    FROM cost_tracking
    GROUP BY episode_id
) ct ON e.episode_id = ct.episode_id;

-- Performance monitoring views
CREATE OR REPLACE VIEW cost_efficiency_report AS
SELECT
    DATE_TRUNC('day', created_at) as day,
    COUNT(*) as episodes_completed,
    AVG(current_cost) as avg_cost_per_episode,
    MIN(current_cost) as min_cost,
    MAX(current_cost) as max_cost,
    AVG(quality_score) as avg_quality_score
FROM episodes
WHERE status = 'completed' AND completed_at IS NOT NULL
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day DESC;

-- Insert initial system health check
INSERT INTO system_health (component, status, timestamp) VALUES
('database', 'healthy', NOW()),
('langgraph_checkpointer', 'healthy', NOW())
ON CONFLICT DO NOTHING;
