# Infrastructure Services Memory - System Foundation 🏗️

<document type="infrastructure-services-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>.claude/infrastructure</domain>
    <scope>Infrastructure services, state management, and system optimization</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>infrastructure work, system optimization, state management</loads-when>
    <triggers>infrastructure|state|persistence|optimization|services</triggers>
  </metadata>
</document>

## 🎯 INFRASTRUCTURE SERVICES CONTEXT

**Technical:** Infrastructure services memory implementing state persistence management, memory optimization, system reliability, dashboard integration, and advanced operational capabilities for enterprise-grade AI podcast production infrastructure.

**Simple:** Like having the foundational systems that make everything else possible - the plumbing, electrical, and structural support.

**Connection:** This teaches infrastructure design, system reliability, and operational excellence patterns essential for scalable production AI systems.

---

## 🏗️ INFRASTRUCTURE SERVICES

### **State Persistence** - `@state-persistence-manager.sh`
<LOAD_IF task="state|persistence|session|recovery">
```yaml
state_management:
  session_initialization: "Episode session creation and tracking"
  cross_phase_state: "Maintain state across workflow phases"
  checkpoint_system: "Automated progress checkpointing"
  recovery_protocols: "State recovery from failure points"
  
persistence_patterns:
  json_validation: "Schema validation for all state data"
  backup_creation: "Automatic state backup before changes"
  error_recovery: "Robust recovery from corrupted state"
```
</LOAD_IF>

### **Memory Optimization** - `@memory-optimization.json`
<LOAD_IF task="memory|optimization|performance|efficiency">
```yaml
memory_strategies:
  sliding_window: "Keep only recent data in active memory"
  shared_pools: "Reuse common data structures"
  garbage_collection: "Automatic cleanup of unused data"
  checkpoint_persistence: "Save important state to disk"
  
optimization_targets:
  memory_limit: "10GB for 5 concurrent episodes"
  cleanup_triggers: "Episode completion, memory threshold, daily cleanup"
  retention_policy: "30 days for completed episodes"
```
</LOAD_IF>

### **Dashboard Integration** - `@dashboard-*`
<LOAD_IF task="dashboard|monitoring|analytics|visualization">
```yaml
dashboard_services:
  api_server: "Dashboard API server with WebSocket support"
  web_interface: "Real-time monitoring and control interface"
  data_streaming: "Live production and cost data streaming"
  
monitoring_capabilities:
  real_time_metrics: "Live production pipeline monitoring"
  cost_analytics: "Real-time cost tracking and forecasting"
  quality_trends: "Episode quality analysis and optimization"
```
</LOAD_IF>

### **System Schemas** - `@schemas/`
<LOAD_IF task="schema|validation|structure|data">
```yaml
schema_management:
  episode_schema: "Episode structure and metadata validation"
  quality_schema: "Quality metrics and evaluation structure"
  session_schema: "Session state and progress tracking"
  cost_schema: "Cost tracking and attribution structure"
  
validation_automation:
  json_validation: "Automatic schema validation for all data"
  structure_checking: "Ensure consistent data structures"
  migration_support: "Schema evolution and backward compatibility"
```
</LOAD_IF>

---

## 🎛️ INFRASTRUCTURE COORDINATION

### **Service Integration**
```yaml
infrastructure_patterns:
  service_discovery: "Automatic service location and health checking"
  load_balancing: "Intelligent resource allocation for batch processing"
  fault_tolerance: "Graceful degradation and recovery protocols"
  
operational_intelligence:
  predictive_scaling: "Resource allocation based on workload patterns"
  cost_optimization: "Automatic efficiency optimization"
  performance_tuning: "Continuous system performance improvement"
```

### **System Reliability**
- **High Availability**: Redundant systems and automatic failover
- **Data Persistence**: Reliable state management and backup systems
- **Performance Monitoring**: Continuous system performance tracking
- **Operational Excellence**: Automated operations and maintenance

---

*Infrastructure memory: Load when working with system foundation, state management, or infrastructure services*
