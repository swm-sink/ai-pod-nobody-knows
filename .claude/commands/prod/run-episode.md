# /prod-episode - Full Episode Production

<!-- Production Command: Execute complete episode production via LangGraph orchestration -->

## 🎯 COMMAND MISSION

**Purpose**: Execute complete podcast episode production through LangGraph subprocess orchestration with real-time monitoring and quality validation.

**Usage Patterns**:
- `/prod-episode "Quantum Computing Myths"` - Full episode with defaults
- `/prod-episode "AI Safety" --budget 5.00 --quality 8.5` - Custom parameters
- `/prod-episode "Climate Science" --dry-run` - Test run without API calls
- `/prod-episode "Space Exploration" --resume ep_001` - Resume from checkpoint

## 🚀 COMMAND IMPLEMENTATION

### **Main Command Handler**

```python
async def handle_prod_episode(command_args: List[str], **kwargs) -> Dict[str, Any]:
    """
    Main handler for /prod-episode command
    Orchestrates full LangGraph production workflow
    """

from config.voice_config import get_production_voice_id

    # Parse arguments
    if not command_args:
        return {
            "error": "Usage: /prod-episode \"<topic>\" [options]",
            "examples": [
                "/prod-episode \"Quantum Computing Myths\"",
                "/prod-episode \"AI Safety\" --budget 5.00",
                "/prod-episode \"Climate Science\" --dry-run"
            ]
        }

    topic = command_args[0]
    options = parse_production_options(command_args[1:], kwargs)

    # TODOWRITE: prod-episode - Starting episode production for '{topic}'

    # Initialize production orchestrator
    orchestrator = ProductionOrchestrator()

    # Execute with comprehensive monitoring
    production_result = await orchestrator.execute_production_command(
        command="prod-episode",
        args={
            "topic": topic,
            "episode_id": options.get("episode_id"),
            "budget": options.get("budget", 5.51),
            "quality_threshold": options.get("quality", 8.0),
            "dry_run": options.get("dry_run", False),
            "resume_from": options.get("resume"),
            "output_dir": options.get("output_dir", "episodes/production")
        }
    )

    # TODOWRITE: prod-episode - Completed episode production for '{topic}'

    return format_production_results(production_result)
```

### **Production Orchestration Flow**

```python
class EpisodeProductionOrchestrator:
    """Specialized orchestrator for complete episode production"""

    async def execute_full_episode_production(self,
                                            topic: str,
                                            production_config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute complete episode production workflow
        Research → Planning → Writing → Quality → Audio → Validation
        """

        episode_id = production_config.get("episode_id") or self.generate_episode_id(topic)
        start_time = datetime.now()

        try:
            # 1. Pre-production validation
            await self.validate_pre_production(production_config)

            # 2. Build LangGraph subprocess command
            cmd = self.build_langgraph_command(topic, episode_id, production_config)

            # 3. Execute LangGraph workflow with monitoring
            execution_result = await self.execute_with_comprehensive_monitoring(
                cmd=cmd,
                episode_id=episode_id,
                production_config=production_config
            )

            # 4. Post-production validation and cleanup
            validation_result = await self.validate_post_production(
                execution_result,
                production_config
            )

            # 5. Generate production report
            production_report = self.generate_production_report(
                topic=topic,
                episode_id=episode_id,
                execution_result=execution_result,
                validation_result=validation_result,
                duration=(datetime.now() - start_time).total_seconds()
            )

            return production_report

        except Exception as e:
            # Handle production failures with recovery options
            return await self.handle_production_failure(
                topic=topic,
                episode_id=episode_id,
                error=e,
                production_config=production_config
            )

    def build_langgraph_command(self,
                              topic: str,
                              episode_id: str,
                              config: Dict[str, Any]) -> List[str]:
        """Build optimized subprocess command for LangGraph execution"""

        cmd = [
            "python", "main.py",
            "--topic", topic,
            "--episode-id", episode_id,
            "--budget", str(config.get("budget", 5.51)),
            "--quality-threshold", str(config.get("quality_threshold", 8.0)),
            "--mode", "production",
            "--output-format", "json",
            "--checkpoint-enabled", "true",
            "--cost-tracking", "enabled"
        ]

        # Add optional parameters
        if config.get("dry_run"):
            cmd.extend(["--dry-run", "true"])

        if config.get("resume_from"):
            cmd.extend(["--resume-from", config["resume_from"]])

        if config.get("output_dir"):
            cmd.extend(["--output-dir", config["output_dir"]])

        # Add voice configuration
        cmd.extend([
            "--voice-id", get_production_voice_id(),  # Production voice
            "--voice-stability", "0.75",
            "--voice-clarity", "0.85"
        ])

        return cmd
```

## 📊 REAL-TIME MONITORING SYSTEM

### **Comprehensive Production Monitoring**

```python
class ProductionMonitor:
    """Advanced monitoring system for episode production"""

    def __init__(self, episode_id: str):
        self.episode_id = episode_id
        self.monitoring_active = False
        self.progress_stages = [
            "research_discovery", "research_deep_dive", "research_validation",
            "research_synthesis", "episode_planning", "script_writing",
            "brand_validation", "script_polishing", "tts_optimization",
            "audio_synthesis", "audio_validation", "final_validation"
        ]
        self.current_stage = 0
        self.stage_start_times = {}

    async def monitor_production_progress(self,
                                        process: asyncio.subprocess.Process,
                                        config: Dict[str, Any]) -> Dict[str, Any]:
        """Monitor LangGraph production with stage-aware progress tracking"""

        self.monitoring_active = True
        monitoring_data = {
            "stages_completed": [],
            "current_stage": None,
            "cost_accumulation": [],
            "quality_scores": {},
            "performance_metrics": {},
            "alerts": []
        }

        while process.returncode is None and self.monitoring_active:
            try:
                # 1. Check for stage progress indicators
                stage_progress = await self.detect_current_stage()
                if stage_progress["stage_changed"]:
                    await self.handle_stage_transition(
                        stage_progress,
                        monitoring_data
                    )

                # 2. Monitor cost accumulation
                cost_update = await self.check_cost_accumulation()
                if cost_update:
                    monitoring_data["cost_accumulation"].append(cost_update)
                    await self.check_budget_alerts(cost_update, config["budget"])

                # 3. Monitor system resources
                resource_metrics = await self.check_system_resources(process.pid)
                monitoring_data["performance_metrics"].update(resource_metrics)

                # 4. Check for output files (indicates progress)
                output_files = await self.scan_output_directory()
                monitoring_data["output_files"] = output_files

                # 5. Monitor quality scores as they become available
                quality_updates = await self.check_quality_scores()
                if quality_updates:
                    monitoring_data["quality_scores"].update(quality_updates)

                # 6. Send progress update to user interface
                await self.send_progress_update(monitoring_data)

                await asyncio.sleep(3)  # Monitor every 3 seconds

            except Exception as e:
                logger.warning(f"Monitoring error: {e}")
                await asyncio.sleep(5)  # Slower monitoring on error

        return monitoring_data

    async def detect_current_stage(self) -> Dict[str, Any]:
        """Detect current production stage from various indicators"""

        indicators = {
            # Check log files for stage indicators
            "log_indicators": await self.scan_log_files_for_stages(),

            # Check output directory for stage-specific files
            "file_indicators": await self.scan_files_for_stage_markers(),

            # Check checkpoint files
            "checkpoint_indicators": await self.scan_checkpoint_files(),

            # Check process stdout if available
            "stdout_indicators": await self.scan_stdout_buffer()
        }

        # Determine most likely current stage
        current_stage = self.analyze_stage_indicators(indicators)
        stage_changed = current_stage != self.current_stage

        if stage_changed:
            self.current_stage = current_stage
            self.stage_start_times[current_stage] = datetime.now()

        return {
            "current_stage": current_stage,
            "stage_changed": stage_changed,
            "indicators": indicators,
            "progress_percent": (current_stage / len(self.progress_stages)) * 100
        }
```

## 🎯 QUALITY GATES & VALIDATION

### **Production Quality Validation**

```python
class ProductionQualityValidator:
    """Comprehensive quality validation for produced episodes"""

    async def validate_episode_quality(self,
                                     episode_result: Dict[str, Any],
                                     quality_config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Comprehensive quality validation for completed episode
        """

        validation_results = {
            "overall_status": "pending",
            "quality_scores": {},
            "budget_compliance": {},
            "content_validation": {},
            "technical_validation": {},
            "brand_validation": {}
        }

        try:
            # 1. Budget Compliance Check
            budget_validation = await self.validate_budget_compliance(
                episode_result,
                quality_config.get("budget_limit", 5.51)
            )
            validation_results["budget_compliance"] = budget_validation

            # 2. Content Quality Assessment
            if "script_raw" in episode_result:
                content_validation = await self.validate_content_quality(
                    episode_result["script_raw"],
                    quality_config
                )
                validation_results["content_validation"] = content_validation

            # 3. Brand Alignment Check
            brand_validation = await self.validate_brand_alignment(
                episode_result,
                quality_config.get("brand_threshold", 8.0)
            )
            validation_results["brand_validation"] = brand_validation

            # 4. Technical Quality Check
            if "audio_file_path" in episode_result:
                technical_validation = await self.validate_technical_quality(
                    episode_result["audio_file_path"],
                    quality_config
                )
                validation_results["technical_validation"] = technical_validation

            # 5. Overall Quality Score Calculation
            overall_quality = self.calculate_overall_quality_score(validation_results)
            validation_results["quality_scores"]["overall"] = overall_quality

            # 6. Determine pass/fail status
            validation_results["overall_status"] = (
                "PASS" if overall_quality >= quality_config.get("quality_threshold", 8.0)
                else "FAIL"
            )

            return validation_results

        except Exception as e:
            validation_results["overall_status"] = "ERROR"
            validation_results["error"] = str(e)
            return validation_results

    async def validate_budget_compliance(self,
                                       episode_result: Dict[str, Any],
                                       budget_limit: float) -> Dict[str, Any]:
        """Validate episode stayed within budget constraints"""

        total_cost = episode_result.get("total_cost", 0)
        budget_utilization = (total_cost / budget_limit) * 100

        return {
            "total_cost": total_cost,
            "budget_limit": budget_limit,
            "budget_utilization_percent": budget_utilization,
            "budget_exceeded": total_cost > budget_limit,
            "budget_efficiency": budget_utilization,
            "cost_breakdown": episode_result.get("cost_breakdown", {}),
            "status": "PASS" if total_cost <= budget_limit else "FAIL"
        }
```

## 📊 PRODUCTION REPORTING

### **Comprehensive Production Report**

```python
class ProductionReportGenerator:
    """Generate detailed production reports for episode completion"""

    def generate_comprehensive_report(self,
                                    topic: str,
                                    episode_id: str,
                                    execution_result: Dict[str, Any],
                                    validation_result: Dict[str, Any],
                                    duration: float) -> Dict[str, Any]:
        """Generate complete production report"""

        report = {
            # Episode Information
            "episode_metadata": {
                "topic": topic,
                "episode_id": episode_id,
                "production_date": datetime.now().isoformat(),
                "total_duration": f"{duration:.1f}s",
                "production_mode": "langgraph_orchestrated"
            },

            # Execution Summary
            "execution_summary": {
                "status": execution_result.get("status", "unknown"),
                "stages_completed": execution_result.get("stages_completed", []),
                "total_cost": execution_result.get("total_cost", 0),
                "quality_score": validation_result.get("quality_scores", {}).get("overall", 0),
                "budget_utilization": validation_result.get("budget_compliance", {}).get("budget_utilization_percent", 0)
            },

            # Quality Assessment
            "quality_assessment": validation_result,

            # Performance Metrics
            "performance_metrics": {
                "execution_time": duration,
                "cost_per_minute": execution_result.get("total_cost", 0) / max(duration / 60, 1),
                "stages_per_minute": len(execution_result.get("stages_completed", [])) / max(duration / 60, 1),
                "memory_peak": execution_result.get("peak_memory_usage", 0),
                "api_calls_total": execution_result.get("total_api_calls", 0)
            },

            # Output Files
            "output_files": {
                "script_file": execution_result.get("script_file_path"),
                "audio_file": execution_result.get("audio_file_path"),
                "research_data": execution_result.get("research_data_path"),
                "quality_report": execution_result.get("quality_report_path"),
                "cost_report": execution_result.get("cost_report_path")
            },

            # Recommendations
            "recommendations": self.generate_recommendations(
                execution_result,
                validation_result
            )
        }

        return report

    def format_report_for_display(self, report: Dict[str, Any]) -> str:
        """Format report for Claude Code interface display"""

        # Extract key metrics
        metadata = report["episode_metadata"]
        execution = report["execution_summary"]
        quality = report["quality_assessment"]

        display_report = f"""
# 🎧 Episode Production Report

## 📝 Episode Information
**Topic**: {metadata["topic"]}
**Episode ID**: {metadata["episode_id"]}
**Production Time**: {metadata["total_duration"]}
**Status**: {"✅ SUCCESS" if execution["status"] == "success" else "❌ FAILED"}

## 💰 Cost & Budget
**Total Cost**: ${execution["total_cost"]:.2f}
**Budget Used**: {execution["budget_utilization"]:.1f}%
**Status**: {"✅ ON BUDGET" if execution["budget_utilization"] <= 100 else "⚠️ OVER BUDGET"}

## 📊 Quality Scores
**Overall Quality**: {execution["quality_score"]:.1f}/10
**Brand Alignment**: {quality.get("brand_validation", {}).get("score", 0):.1f}/10
**Technical Quality**: {quality.get("technical_validation", {}).get("score", 0):.1f}/10
**Status**: {"✅ QUALITY PASSED" if execution["quality_score"] >= 8.0 else "⚠️ QUALITY REVIEW NEEDED"}

## 📁 Output Files
"""

        # Add output file information
        output_files = report["output_files"]
        for file_type, file_path in output_files.items():
            if file_path:
                display_report += f"**{file_type.title()}**: `{file_path}`\n"

        # Add recommendations if any
        recommendations = report.get("recommendations", [])
        if recommendations:
            display_report += "\n## 💡 Recommendations\n"
            for rec in recommendations:
                display_report += f"- {rec}\n"

        return display_report
```

## 💡 PRODUCTION PRINCIPLES

**Technical**:
- Subprocess isolation ensures LangGraph independence
- Real-time monitoring provides immediate feedback
- Comprehensive validation ensures quality standards
- Detailed reporting enables continuous improvement

**Simple**:
- Think of this as pressing a button to manufacture a complete product
- The button (command) starts an automated factory (LangGraph)
- Quality inspectors (validators) check the product at the end
- A detailed report tells you everything that happened

**Connection**:
- This teaches production automation and workflow orchestration
- Quality assurance and validation methodologies
- Real-time monitoring and alerting systems
- Performance analysis and optimization techniques

## 🔧 TODOWRITE INTEGRATION

**Production Tasks**:
```python
# TODOWRITE: prod-episode - Starting episode production for '{topic}'
# TODOWRITE: prod-episode - Execute research pipeline for '{topic}'
# TODOWRITE: prod-episode - Generate script for '{topic}'
# TODOWRITE: prod-episode - Validate quality for '{topic}'
# TODOWRITE: prod-episode - Synthesize audio for '{topic}'
# TODOWRITE: prod-episode - Complete production for '{topic}'
```

**Post-Production Tasks**:
```python
# TODOWRITE: prod-analyze - Analyze production metrics for '{episode_id}'
# TODOWRITE: prod-optimize - Identify optimization opportunities
# TODOWRITE: prod-report - Generate comprehensive production report
```

---

**Command Type**: Production
**Specialization**: Complete Episode Production via LangGraph
**Version**: 1.0.0
**Updated**: 2025-09-01
