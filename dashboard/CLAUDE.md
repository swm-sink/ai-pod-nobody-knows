# Dashboard Memory - Real-Time Monitoring 📊

<document type="dashboard-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>dashboard</domain>
    <scope>Real-time monitoring, analytics, and production tracking interface</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>dashboard development, monitoring setup, analytics work</loads-when>
    <triggers>dashboard|monitoring|analytics|metrics|realtime</triggers>
  </metadata>
</document>

## 🎯 DASHBOARD MONITORING CONTEXT

**Technical:** Dashboard system memory implementing real-time production monitoring, cost analytics, quality metrics visualization, and system health tracking for comprehensive AI podcast production oversight.

**Simple:** Like having a mission control center that shows you everything happening in your podcast production system in real-time.

**Connection:** This teaches system monitoring, analytics design, and operational intelligence essential for managing complex AI automation systems.

---

## 📊 DASHBOARD ARCHITECTURE

### **Real-Time Monitoring**
<LOAD_IF task="realtime|monitoring|live|status">
```yaml
monitoring_systems:
  production_pipeline: "Live workflow progress tracking"
  cost_analytics: "Real-time cost monitoring and attribution"
  quality_metrics: "Episode quality scores and trends"
  system_health: "MCP connections and component status"
  
real_time_features:
  websocket_updates: "Live data streaming to dashboard"
  mobile_responsive: "Works on all devices"
  alert_system: "Cost and quality threshold notifications"
```
</LOAD_IF>

### **Analytics Engine**
<LOAD_IF task="analytics|metrics|reporting|intelligence">
```yaml
analytics_capabilities:
  cost_analysis: "Per-episode and series-level cost trending"
  quality_tracking: "Quality score evolution and patterns"
  efficiency_metrics: "Production time and resource utilization"
  
business_intelligence:
  cost_optimization: "Identify efficiency improvement opportunities"
  quality_patterns: "Understand what drives high-quality episodes"
  scaling_analysis: "Project scalability and resource planning"
```
</LOAD_IF>

### **Production Interface**
<LOAD_IF task="interface|ui|production|control">
```yaml
dashboard_interface:
  production_control: "Start, monitor, and manage episode production"
  session_tracking: "Visual workflow progress and status"
  quality_review: "Episode quality assessment interface"
  
user_experience:
  intuitive_navigation: "Easy access to all system functions"
  actionable_insights: "Clear data visualization and recommendations"
  mobile_optimization: "Full functionality on mobile devices"
```
</LOAD_IF>

---

## 🎛️ DASHBOARD COORDINATION

### **Data Integration**
```yaml
data_sources:
  session_state: "Live session tracking from .claude/state/"
  cost_logs: "Real-time cost data from .claude/logs/"
  quality_reports: "Episode quality metrics from sessions/"
  system_health: "Component status from infrastructure monitoring"
  
integration_patterns:
  real_time_updates: "WebSocket streaming for live data"
  historical_analysis: "Trend analysis across episode history"
  predictive_insights: "Cost and quality forecasting"
```

### **System Intelligence**
- **Performance Monitoring**: Track system efficiency and optimization opportunities
- **Cost Intelligence**: Advanced cost analysis and optimization recommendations
- **Quality Intelligence**: Quality pattern analysis and improvement suggestions
- **Operational Intelligence**: System health monitoring and proactive issue detection

---

*Dashboard memory: Load when working with monitoring, analytics, or production tracking interfaces*
