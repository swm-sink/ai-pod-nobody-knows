# /dev-build - LangGraph Component Builder

<!-- Development Command: Build LangGraph components with comprehensive validation -->

## 🎯 COMMAND MISSION

**Purpose**: Build, configure, and validate LangGraph components (nodes, graphs, workflows) with automated testing and integration.

**Usage Patterns**:
- `/dev-build agent "script-writer"` - Build specific agent node
- `/dev-build workflow "research-pipeline"` - Build complete workflow
- `/dev-build state "PodcastState"` - Build/update state schema
- `/dev-build integration "cost-tracking"` - Build integration component

## 🏗️ COMMAND IMPLEMENTATION

### **Main Command Handler**

```python
async def handle_dev_build(command_args: List[str]) -> Dict[str, Any]:
    """
    Main handler for /dev-build command
    Routes to specialized builders based on component type
    """

    if len(command_args) < 2:
        return {
            "error": "Usage: /dev-build <type> <name> [options]",
            "examples": [
                "/dev-build agent 'script-writer'",
                "/dev-build workflow 'research-pipeline'",
                "/dev-build state 'PodcastState'",
                "/dev-build integration 'cost-tracking'"
            ]
        }

    component_type = command_args[0].lower()
    component_name = command_args[1]
    options = parse_build_options(command_args[2:])

    # Route to specialized builder
    builders = {
        "agent": build_agent_component,
        "workflow": build_workflow_component,
        "state": build_state_component,
        "integration": build_integration_component
    }

    if component_type not in builders:
        return {"error": f"Unknown component type: {component_type}"}

    # Execute build with progress tracking
    build_result = await execute_with_progress_tracking(
        builder=builders[component_type],
        component_name=component_name,
        options=options
    )

    return format_build_result(build_result)
```

### **Agent Builder Specialization**

```python
async def build_agent_component(agent_name: str, options: Dict[str, Any]) -> Dict[str, Any]:
    """
    Build LangGraph node for specific agent
    Coordinates with langgraph-builder and migration-specialist agents
    """

    # TODOWRITE: dev-build - Starting agent build for {agent_name}

    # 1. Analyze existing agent (if migrating)
    if options.get("migrate", True):
        analysis = await analyze_existing_agent(agent_name)
        if not analysis["exists"]:
            return {"error": f"Agent {agent_name} not found for migration"}
    else:
        analysis = await create_new_agent_spec(agent_name, options)

    # 2. Use langgraph-builder agent to create node
    builder_result = await invoke_agent(
        agent="langgraph-builder",
        task="create_node",
        params={
            "agent_name": agent_name,
            "analysis": analysis,
            "options": options
        }
    )

    if builder_result["status"] != "success":
        return {"error": f"Builder failed: {builder_result['error']}"}

    # 3. Create test suite with test-harness agent
    test_result = await invoke_agent(
        agent="test-harness",
        task="create_agent_tests",
        params={
            "agent_name": agent_name,
            "node_function": builder_result["node_function"]
        }
    )

    # 4. Validate state compatibility with state-architect
    state_validation = await invoke_agent(
        agent="state-architect",
        task="validate_state_changes",
        params={
            "agent_name": agent_name,
            "state_updates": builder_result["state_updates"]
        }
    )

    # 5. Run initial tests
    initial_test_results = await run_agent_tests(agent_name)

    # TODOWRITE: dev-build - Completed agent build for {agent_name}

    return {
        "status": "success",
        "component_type": "agent",
        "component_name": agent_name,
        "files_created": builder_result["files_created"],
        "tests_created": test_result["tests_created"],
        "test_results": initial_test_results,
        "state_validation": state_validation,
        "next_steps": [
            f"Run: /dev-test agent '{agent_name}'",
            f"Run: /dev-integrate '{agent_name}' into workflow"
        ]
    }
```

### **Workflow Builder Specialization**

```python
async def build_workflow_component(workflow_name: str, options: Dict[str, Any]) -> Dict[str, Any]:
    """
    Build complete LangGraph workflow with nodes and routing
    """

    # TODOWRITE: dev-build - Building workflow {workflow_name}

    # 1. Load workflow specification
    workflow_spec = await load_workflow_specification(workflow_name)

    # 2. Validate all required nodes exist
    node_validation = await validate_workflow_nodes(workflow_spec)
    if not node_validation["all_nodes_exist"]:
        missing_nodes = node_validation["missing_nodes"]
        return {
            "error": f"Missing nodes for workflow: {missing_nodes}",
            "suggestion": f"Build missing nodes first: {', '.join(missing_nodes)}"
        }

    # 3. Build StateGraph with langgraph-builder
    graph_result = await invoke_agent(
        agent="langgraph-builder",
        task="create_workflow_graph",
        params={
            "workflow_name": workflow_name,
            "specification": workflow_spec,
            "options": options
        }
    )

    # 4. Create workflow integration tests
    workflow_tests = await invoke_agent(
        agent="test-harness",
        task="create_workflow_tests",
        params={
            "workflow_name": workflow_name,
            "graph_definition": graph_result["graph"]
        }
    )

    # 5. Validate workflow with state-architect
    state_flow_validation = await invoke_agent(
        agent="state-architect",
        task="validate_workflow_state_flow",
        params={
            "workflow_name": workflow_name,
            "node_sequence": workflow_spec["nodes"],
            "state_transitions": graph_result["state_transitions"]
        }
    )

    # 6. Run workflow integration tests
    integration_test_results = await run_workflow_tests(workflow_name)

    # TODOWRITE: dev-build - Completed workflow build for {workflow_name}

    return {
        "status": "success",
        "component_type": "workflow",
        "component_name": workflow_name,
        "graph_file": graph_result["graph_file"],
        "nodes_included": workflow_spec["nodes"],
        "test_results": integration_test_results,
        "state_validation": state_flow_validation,
        "performance_metrics": integration_test_results.get("performance", {}),
        "next_steps": [
            f"Run: /dev-test workflow '{workflow_name}'",
            f"Run: /dev-validate workflow '{workflow_name}'"
        ]
    }
```

## 🧪 BUILD VALIDATION FRAMEWORK

### **Automated Build Testing**

```python
class BuildValidator:
    """Comprehensive validation for built components"""

    async def validate_agent_build(self, agent_name: str, build_artifacts: Dict) -> Dict[str, Any]:
        """Validate agent build meets all requirements"""

        validations = {
            "syntax_check": await self.check_python_syntax(build_artifacts["node_file"]),
            "import_check": await self.check_imports_resolve(build_artifacts["node_file"]),
            "state_compatibility": await self.check_state_compatibility(agent_name),
            "cost_tracking": await self.check_cost_tracking_integration(agent_name),
            "serialization": await self.check_msgpack_serialization(agent_name),
            "test_coverage": await self.check_test_coverage(agent_name),
            "documentation": await self.check_documentation_exists(agent_name)
        }

        all_passed = all(validation["passed"] for validation in validations.values())

        return {
            "overall_status": "PASS" if all_passed else "FAIL",
            "validations": validations,
            "critical_issues": [
                name for name, result in validations.items()
                if not result["passed"] and result.get("critical", False)
            ]
        }

    async def validate_workflow_build(self, workflow_name: str, build_artifacts: Dict) -> Dict[str, Any]:
        """Validate workflow build meets all requirements"""

        validations = {
            "graph_compilation": await self.check_graph_compiles(build_artifacts["graph_file"]),
            "node_connectivity": await self.check_all_nodes_connected(workflow_name),
            "state_flow": await self.check_state_flows_correctly(workflow_name),
            "error_handling": await self.check_error_paths_exist(workflow_name),
            "performance": await self.check_performance_acceptable(workflow_name),
            "cost_budgets": await self.check_cost_budgets_respected(workflow_name)
        }

        all_passed = all(validation["passed"] for validation in validations.values())

        return {
            "overall_status": "PASS" if all_passed else "FAIL",
            "validations": validations,
            "performance_metrics": validations["performance"].get("metrics", {}),
            "cost_analysis": validations["cost_budgets"].get("analysis", {})
        }
```

## 📊 BUILD PROGRESS TRACKING

### **Progress Monitoring System**

```python
class BuildProgressTracker:
    """Track and display build progress with TODOWRITE integration"""

    def __init__(self):
        self.current_build = None
        self.progress_steps = []
        self.start_time = None

    async def start_build_tracking(self, component_type: str, component_name: str):
        """Initialize build tracking"""

        self.current_build = f"{component_type}:{component_name}"
        self.start_time = datetime.now()

        # Create TODOWRITE entries for build process
        build_todos = [
            f"dev-build - Analyze {component_name} requirements",
            f"dev-build - Create {component_type} implementation",
            f"dev-build - Generate tests for {component_name}",
            f"dev-build - Validate {component_name} integration",
            f"dev-build - Complete {component_name} build"
        ]

        await self.create_build_todos(build_todos)

    async def update_progress(self, step: str, status: str, details: Dict[str, Any]):
        """Update build progress with detailed information"""

        progress_entry = {
            "step": step,
            "status": status,  # "in_progress", "completed", "failed"
            "timestamp": datetime.now(),
            "details": details,
            "duration": self.calculate_step_duration()
        }

        self.progress_steps.append(progress_entry)

        # Update corresponding TODOWRITE entry
        await self.update_todo_status(step, status)

        # Display progress to user
        await self.display_progress_update(progress_entry)

    def format_build_summary(self) -> Dict[str, Any]:
        """Create comprehensive build summary"""

        total_duration = (datetime.now() - self.start_time).total_seconds()
        successful_steps = len([s for s in self.progress_steps if s["status"] == "completed"])
        failed_steps = len([s for s in self.progress_steps if s["status"] == "failed"])

        return {
            "build_target": self.current_build,
            "total_duration": total_duration,
            "steps_completed": successful_steps,
            "steps_failed": failed_steps,
            "overall_success": failed_steps == 0,
            "performance_metrics": self.extract_performance_metrics(),
            "detailed_steps": self.progress_steps
        }
```

## 🎯 BUILD CONFIGURATION

### **Component Build Specifications**

```python
# Build specifications for different component types
BUILD_SPECS = {
    "agents": {
        "script-writer": {
            "priority": "critical",
            "budget": 1.75,
            "complexity": "high",
            "dependencies": ["research-synthesis", "episode-planner"],
            "quality_gates": ["brand_alignment", "tts_optimization"],
            "test_requirements": ["unit", "integration", "budget_compliance"]
        },
        "brand-validator": {
            "priority": "high",
            "budget": 0.25,
            "complexity": "medium",
            "dependencies": ["script-writer"],
            "quality_gates": ["intellectual_humility", "brand_consistency"],
            "test_requirements": ["unit", "brand_scoring"]
        }
    },
    "workflows": {
        "research-pipeline": {
            "nodes": ["research-discovery", "research-deep-dive", "research-validate", "research-synthesis"],
            "routing": "linear",
            "budget": 2.0,
            "timeout": 600,
            "checkpoint_frequency": 60
        },
        "production-pipeline": {
            "nodes": ["episode-planner", "script-writer", "brand-validator", "script-polisher"],
            "routing": "conditional_quality",
            "budget": 2.5,
            "timeout": 900,
            "checkpoint_frequency": 120
        }
    }
}
```

## 💡 BUILD PRINCIPLES

**Technical**:
- All builds must pass comprehensive validation before completion
- State serialization compatibility is mandatory
- Cost tracking integration is required for all components
- Automated testing must be generated and passing

**Simple**:
- Think of building like assembling a complex LEGO set
- Each component is a specialized piece that must fit perfectly
- Instructions (specs) must be followed exactly
- Quality control checks each piece before final assembly

**Connection**:
- This teaches component-based architecture and modular design
- Build automation and continuous integration practices
- Quality assurance and validation methodologies
- Project management and progress tracking techniques

## 🔧 TODOWRITE INTEGRATION

**Build Process Tracking**:
```python
# TODOWRITE: dev-build - Analyze requirements for {component_name}
# TODOWRITE: dev-build - Create implementation for {component_name}
# TODOWRITE: dev-build - Generate tests for {component_name}
# TODOWRITE: dev-build - Validate integration for {component_name}
# TODOWRITE: dev-build - Complete build for {component_name}
```

**Post-Build Tasks**:
```python
# TODOWRITE: dev-test - Run comprehensive tests for {component_name}
# TODOWRITE: dev-integrate - Integrate {component_name} into workflow
# TODOWRITE: dev-validate - Validate {component_name} meets quality gates
```

---

**Command Type**: Development
**Specialization**: LangGraph Component Building
**Version**: 1.0.0
**Updated**: 2025-09-01
