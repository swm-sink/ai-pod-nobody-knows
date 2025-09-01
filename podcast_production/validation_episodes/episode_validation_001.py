#!/usr/bin/env python3
"""
Production Validation Episode - Complete System Test
Episode Topic: "The Future of AI Assistants: Promise vs Reality"

Comprehensive validation of the AgentOrchestrator system with:
- Full pipeline execution (Research → Planning → Scripting → Quality → Audio)
- Real-time cost tracking and budget enforcement (≤ $5.51)
- Quality monitoring and validation (≥ 8.0 targets)
- Performance metrics collection
- Error recovery testing
- State integrity validation

Version: 1.0.0
Date: September 1, 2025
"""

import asyncio
import json
import logging
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, List
import traceback

# Add current directory to path for imports
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

from core.logging_config import setup_logging
from core.state import create_initial_state, validate_state
from core.config.manager import get_config_manager
from workflows.orchestrated_workflow import execute_orchestrated_workflow

# Configure logging
setup_logging(verbose=True, component="validation")
logger = logging.getLogger(__name__)


class ProductionValidationRunner:
    """
    Complete production validation system for testing the full AgentOrchestrator
    workflow under real production conditions.
    """
    
    def __init__(self, topic: str, budget: float = 5.51, output_base_dir: str = "./outputs"):
        """
        Initialize production validation runner.
        
        Args:
            topic: Episode topic for validation
            budget: Budget limit for validation
            output_base_dir: Base directory for outputs
        """
        self.topic = topic
        self.budget = budget
        self.output_base_dir = Path(output_base_dir)
        self.validation_id = f"validation_001_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.output_dir = self.output_base_dir / f"validation_episode_001"
        
        # Validation tracking
        self.start_time = None
        self.end_time = None
        self.validation_results = {
            "validation_id": self.validation_id,
            "topic": self.topic,
            "budget_limit": self.budget,
            "start_time": None,
            "end_time": None,
            "duration_seconds": None,
            "success": False,
            "final_cost": None,
            "budget_compliance": None,
            "quality_scores": {},
            "pipeline_stages": {},
            "performance_metrics": {},
            "errors": [],
            "warnings": [],
            "system_health": {},
            "recommendations": []
        }
        
        # Success criteria
        self.success_criteria = {
            "cost_limit": budget,
            "quality_target": 8.0,
            "max_duration_minutes": 15,
            "required_outputs": [
                "research_data",
                "episode_plan", 
                "script_raw",
                "quality_scores"
            ]
        }
    
    async def run_validation(self) -> Dict[str, Any]:
        """
        Execute complete production validation with comprehensive monitoring.
        
        Returns:
            Detailed validation results and metrics
        """
        logger.info("=" * 80)
        logger.info("PRODUCTION VALIDATION EPISODE - STARTING")
        logger.info("=" * 80)
        logger.info(f"Topic: {self.topic}")
        logger.info(f"Budget Limit: ${self.budget}")
        logger.info(f"Validation ID: {self.validation_id}")
        logger.info(f"Output Directory: {self.output_dir}")
        logger.info("=" * 80)
        
        self.start_time = datetime.now()
        self.validation_results["start_time"] = self.start_time.isoformat()
        
        try:
            # Environment validation
            await self._validate_environment()
            
            # System health check
            await self._check_system_health()
            
            # Execute production workflow
            final_state = await self._execute_production_workflow()
            
            # Validate results
            await self._validate_results(final_state)
            
            # Generate performance analysis
            await self._analyze_performance(final_state)
            
            # Generate recommendations
            await self._generate_recommendations(final_state)
            
            self.validation_results["success"] = True
            logger.info("VALIDATION COMPLETED SUCCESSFULLY")
            
        except Exception as e:
            logger.error(f"VALIDATION FAILED: {e}")
            logger.error(traceback.format_exc())
            self.validation_results["errors"].append({
                "error": str(e),
                "stage": "validation_runner",
                "timestamp": datetime.now().isoformat(),
                "traceback": traceback.format_exc()
            })
        
        finally:
            self.end_time = datetime.now()
            self.validation_results["end_time"] = self.end_time.isoformat()
            self.validation_results["duration_seconds"] = (
                self.end_time - self.start_time
            ).total_seconds()
            
            # Save results
            await self._save_validation_results()
            
            # Print summary
            await self._print_validation_summary()
        
        return self.validation_results
    
    async def _validate_environment(self):
        """Validate environment and dependencies."""
        logger.info("Validating environment and dependencies...")
        
        # Check required environment variables
        required_envs = [
            "PERPLEXITY_API_KEY",  # pragma: allowlist secret
            "LANGFUSE_PUBLIC_KEY",  # pragma: allowlist secret
            "LANGFUSE_SECRET_KEY"  # pragma: allowlist secret
        ]
        
        missing_envs = []
        for env_var in required_envs:
            if not os.getenv(env_var):
                missing_envs.append(env_var)
        
        if missing_envs:
            self.validation_results["warnings"].append({
                "warning": f"Missing environment variables: {missing_envs}",
                "stage": "environment_check",
                "impact": "May cause API authentication failures"
            })
        
        # Create output directories
        self.output_dir.mkdir(parents=True, exist_ok=True)
        (self.output_dir / "reports").mkdir(exist_ok=True)
        (self.output_dir / "logs").mkdir(exist_ok=True)
        
        logger.info("Environment validation completed")
    
    async def _check_system_health(self):
        """Check system health before starting validation."""
        logger.info("Checking system health...")
        
        health_check = {
            "config_manager": False,
            "import_availability": {},
            "directory_structure": True,
            "memory_available": True
        }
        
        try:
            # Test configuration manager
            config_manager = get_config_manager()
            health_check["config_manager"] = True
            logger.info("✓ Configuration manager accessible")
        except Exception as e:
            health_check["config_manager"] = False
            logger.warning(f"⚠ Configuration manager issue: {e}")
        
        # Test critical imports
        critical_imports = [
            ("workflows.orchestrated_workflow", "execute_orchestrated_workflow"),
            ("core.agent_orchestrator", "create_orchestrator"),
            ("core.state", "PodcastState")
        ]
        
        for module_name, class_name in critical_imports:
            try:
                module = __import__(module_name, fromlist=[class_name])
                getattr(module, class_name)
                health_check["import_availability"][module_name] = True
                logger.info(f"✓ {module_name}.{class_name} available")
            except Exception as e:
                health_check["import_availability"][module_name] = False
                logger.warning(f"⚠ {module_name}.{class_name} unavailable: {e}")
        
        self.validation_results["system_health"] = health_check
        logger.info("System health check completed")
    
    async def _execute_production_workflow(self) -> Dict[str, Any]:
        """Execute the complete production workflow with monitoring."""
        logger.info("STARTING PRODUCTION WORKFLOW EXECUTION")
        logger.info("-" * 60)
        
        workflow_start = time.time()
        
        try:
            # Execute orchestrated workflow
            final_state = await execute_orchestrated_workflow(
                topic=self.topic,
                budget=self.budget,
                output_dir=str(self.output_dir),
                dry_run=False,  # REAL PRODUCTION RUN
                verbose=True,
                config={
                    "validation_mode": True,
                    "enhanced_monitoring": True,
                    "save_intermediate_states": True
                }
            )
            
            workflow_duration = time.time() - workflow_start
            
            # Log workflow completion
            logger.info("-" * 60)
            logger.info("PRODUCTION WORKFLOW COMPLETED")
            logger.info(f"Duration: {workflow_duration:.2f} seconds")
            logger.info(f"Final Stage: {final_state.get('current_stage', 'unknown')}")
            logger.info(f"Total Cost: ${final_state.get('total_cost', 0.0):.4f}")
            logger.info("-" * 60)
            
            # Store performance metrics
            self.validation_results["performance_metrics"]["workflow_duration"] = workflow_duration
            self.validation_results["final_cost"] = final_state.get("total_cost", 0.0)
            
            return final_state
            
        except Exception as e:
            logger.error(f"Workflow execution failed: {e}")
            raise
    
    async def _validate_results(self, final_state: Dict[str, Any]):
        """Validate the results against success criteria."""
        logger.info("VALIDATING RESULTS AGAINST SUCCESS CRITERIA")
        logger.info("-" * 60)
        
        validation_status = {
            "cost_compliance": False,
            "quality_compliance": False,
            "output_completeness": False,
            "duration_compliance": False,
            "error_tolerance": True
        }
        
        # Check cost compliance
        final_cost = final_state.get("total_cost", 0.0)
        if final_cost <= self.success_criteria["cost_limit"]:
            validation_status["cost_compliance"] = True
            logger.info(f"✓ Cost compliance: ${final_cost:.4f} ≤ ${self.success_criteria['cost_limit']}")
        else:
            logger.error(f"✗ Cost exceeded: ${final_cost:.4f} > ${self.success_criteria['cost_limit']}")
        
        self.validation_results["budget_compliance"] = validation_status["cost_compliance"]
        
        # Check quality scores
        quality_scores = final_state.get("quality_scores", {})
        if quality_scores:
            avg_quality = sum(
                score for key, score in quality_scores.items() 
                if isinstance(score, (int, float)) and key != "mock"
            ) / max(len([k for k in quality_scores.keys() if k != "mock"]), 1)
            
            if avg_quality >= self.success_criteria["quality_target"]:
                validation_status["quality_compliance"] = True
                logger.info(f"✓ Quality target met: {avg_quality:.2f} ≥ {self.success_criteria['quality_target']}")
            else:
                logger.error(f"✗ Quality below target: {avg_quality:.2f} < {self.success_criteria['quality_target']}")
        else:
            logger.warning("⚠ No quality scores available")
        
        self.validation_results["quality_scores"] = quality_scores
        
        # Check output completeness
        missing_outputs = []
        for required_output in self.success_criteria["required_outputs"]:
            if not final_state.get(required_output):
                missing_outputs.append(required_output)
        
        if not missing_outputs:
            validation_status["output_completeness"] = True
            logger.info("✓ All required outputs generated")
        else:
            logger.error(f"✗ Missing required outputs: {missing_outputs}")
        
        # Check duration
        duration_minutes = self.validation_results["duration_seconds"] / 60
        if duration_minutes <= self.success_criteria["max_duration_minutes"]:
            validation_status["duration_compliance"] = True
            logger.info(f"✓ Duration acceptable: {duration_minutes:.2f} ≤ {self.success_criteria['max_duration_minutes']} minutes")
        else:
            logger.warning(f"⚠ Duration exceeded: {duration_minutes:.2f} > {self.success_criteria['max_duration_minutes']} minutes")
        
        # Check error tolerance
        errors = final_state.get("errors", [])
        if len(errors) > 3:  # Allow up to 3 minor errors
            validation_status["error_tolerance"] = False
            logger.error(f"✗ Too many errors: {len(errors)} > 3")
        else:
            logger.info(f"✓ Error tolerance: {len(errors)} ≤ 3 errors")
        
        # Store validation results
        self.validation_results["pipeline_stages"] = {
            "final_stage": final_state.get("current_stage"),
            "stages_completed": self._get_completed_stages(final_state),
            "validation_status": validation_status
        }
        
        logger.info("-" * 60)
    
    async def _analyze_performance(self, final_state: Dict[str, Any]):
        """Analyze performance metrics and resource usage."""
        logger.info("ANALYZING PERFORMANCE METRICS")
        logger.info("-" * 40)
        
        performance_analysis = {
            "cost_efficiency": None,
            "quality_efficiency": None,
            "time_efficiency": None,
            "resource_usage": {},
            "bottlenecks": [],
            "optimizations": []
        }
        
        # Cost efficiency analysis
        final_cost = final_state.get("total_cost", 0.0)
        cost_breakdown = final_state.get("cost_breakdown", {})
        
        if final_cost > 0:
            performance_analysis["cost_efficiency"] = {
                "cost_per_dollar_budget": final_cost / self.budget,
                "cost_breakdown": cost_breakdown,
                "most_expensive_stage": max(cost_breakdown.items(), key=lambda x: x[1]) if cost_breakdown else None
            }
        
        # Quality efficiency
        quality_scores = final_state.get("quality_scores", {})
        if quality_scores and final_cost > 0:
            avg_quality = sum(
                score for key, score in quality_scores.items() 
                if isinstance(score, (int, float)) and key != "mock"
            ) / max(len([k for k in quality_scores.keys() if k != "mock"]), 1)
            
            performance_analysis["quality_efficiency"] = {
                "quality_per_dollar": avg_quality / final_cost if final_cost > 0 else 0,
                "individual_scores": quality_scores
            }
        
        # Time efficiency
        duration = self.validation_results["duration_seconds"]
        if duration > 0:
            performance_analysis["time_efficiency"] = {
                "seconds_per_dollar_budget": duration / self.budget,
                "cost_per_minute": final_cost / (duration / 60) if duration > 0 else 0
            }
        
        # Identify bottlenecks and optimizations
        if cost_breakdown:
            # Find most expensive stage
            most_expensive = max(cost_breakdown.items(), key=lambda x: x[1])
            if most_expensive[1] > final_cost * 0.4:  # More than 40% of budget
                performance_analysis["bottlenecks"].append({
                    "type": "cost_concentration",
                    "stage": most_expensive[0],
                    "cost": most_expensive[1],
                    "percentage": (most_expensive[1] / final_cost) * 100
                })
                
                performance_analysis["optimizations"].append({
                    "type": "cost_optimization",
                    "target": most_expensive[0],
                    "recommendation": f"Consider optimizing {most_expensive[0]} stage - uses {(most_expensive[1] / final_cost) * 100:.1f}% of budget"
                })
        
        # Duration analysis
        if duration > 300:  # More than 5 minutes
            performance_analysis["optimizations"].append({
                "type": "performance_optimization", 
                "recommendation": f"Consider parallel execution - total time {duration:.1f}s exceeds target"
            })
        
        self.validation_results["performance_metrics"]["analysis"] = performance_analysis
        
        logger.info(f"Cost Efficiency: ${final_cost:.4f} / ${self.budget:.2f} = {(final_cost/self.budget)*100:.1f}%")
        if quality_scores:
            avg_quality = sum(
                score for key, score in quality_scores.items() 
                if isinstance(score, (int, float)) and key != "mock"
            ) / max(len([k for k in quality_scores.keys() if k != "mock"]), 1)
            logger.info(f"Quality Efficiency: {avg_quality:.2f} quality / ${final_cost:.4f} cost = {avg_quality/final_cost:.2f} quality per dollar")
        logger.info(f"Time Efficiency: {duration:.1f} seconds total")
        logger.info("-" * 40)
    
    async def _generate_recommendations(self, final_state: Dict[str, Any]):
        """Generate actionable recommendations based on validation results."""
        logger.info("GENERATING RECOMMENDATIONS")
        logger.info("-" * 40)
        
        recommendations = []
        
        # Cost-based recommendations
        final_cost = final_state.get("total_cost", 0.0)
        cost_breakdown = final_state.get("cost_breakdown", {})
        
        if final_cost > self.budget * 0.9:  # Used more than 90% of budget
            recommendations.append({
                "priority": "HIGH",
                "category": "cost_management",
                "title": "Budget Utilization High",
                "description": f"Used {(final_cost/self.budget)*100:.1f}% of budget (${final_cost:.4f}/${self.budget:.2f})",
                "action": "Consider implementing cost-saving measures or increasing budget buffer"
            })
        
        if cost_breakdown:
            # Find stages using more than 30% of budget
            for stage, cost in cost_breakdown.items():
                if cost > self.budget * 0.3:
                    recommendations.append({
                        "priority": "MEDIUM",
                        "category": "stage_optimization",
                        "title": f"Expensive Stage: {stage}",
                        "description": f"Stage '{stage}' costs ${cost:.4f} ({(cost/final_cost)*100:.1f}% of total)",
                        "action": f"Review {stage} configuration for optimization opportunities"
                    })
        
        # Quality-based recommendations
        quality_scores = final_state.get("quality_scores", {})
        if quality_scores:
            for metric, score in quality_scores.items():
                if isinstance(score, (int, float)) and metric != "mock":
                    if score < 7.0:
                        recommendations.append({
                            "priority": "HIGH",
                            "category": "quality_improvement",
                            "title": f"Low Quality Score: {metric}",
                            "description": f"Quality metric '{metric}' scored {score:.2f} (below 7.0 threshold)",
                            "action": f"Investigate and improve {metric} quality mechanisms"
                        })
                    elif score < 8.0:
                        recommendations.append({
                            "priority": "MEDIUM", 
                            "category": "quality_enhancement",
                            "title": f"Marginal Quality Score: {metric}",
                            "description": f"Quality metric '{metric}' scored {score:.2f} (could be improved)",
                            "action": f"Consider enhancements to {metric} evaluation process"
                        })
        
        # Performance-based recommendations  
        duration = self.validation_results["duration_seconds"]
        if duration > 600:  # More than 10 minutes
            recommendations.append({
                "priority": "MEDIUM",
                "category": "performance", 
                "title": "Long Execution Time",
                "description": f"Total execution time: {duration:.1f} seconds ({duration/60:.1f} minutes)",
                "action": "Consider implementing parallel processing or caching mechanisms"
            })
        
        # Error-based recommendations
        errors = final_state.get("errors", [])
        if errors:
            recommendations.append({
                "priority": "HIGH" if len(errors) > 1 else "MEDIUM",
                "category": "reliability",
                "title": f"Errors Encountered ({len(errors)})",
                "description": f"Workflow encountered {len(errors)} error(s)",
                "action": "Review error handling and implement additional recovery mechanisms"
            })
        
        # Success recommendations
        if (self.validation_results["budget_compliance"] and 
            len(errors) == 0 and 
            duration < 300):
            recommendations.append({
                "priority": "LOW",
                "category": "optimization",
                "title": "Excellent Performance",
                "description": "All criteria met with excellent performance",
                "action": "Consider increasing quality targets or reducing budget for better efficiency"
            })
        
        self.validation_results["recommendations"] = recommendations
        
        # Log recommendations
        for rec in recommendations:
            logger.info(f"[{rec['priority']}] {rec['title']}: {rec['action']}")
        
        logger.info("-" * 40)
    
    async def _save_validation_results(self):
        """Save comprehensive validation results."""
        logger.info("Saving validation results...")
        
        # Save main validation report
        report_path = self.output_dir / "reports" / f"validation_report_{self.validation_id}.json"
        with open(report_path, 'w') as f:
            json.dump(self.validation_results, f, indent=2, default=str)
        
        # Generate markdown summary
        summary_path = self.output_dir / "reports" / f"validation_summary_{self.validation_id}.md"
        await self._generate_markdown_summary(summary_path)
        
        logger.info(f"Validation results saved:")
        logger.info(f"  Report: {report_path}")
        logger.info(f"  Summary: {summary_path}")
    
    async def _generate_markdown_summary(self, summary_path: Path):
        """Generate human-readable markdown summary."""
        with open(summary_path, 'w') as f:
            f.write(f"# Production Validation Report\n\n")
            f.write(f"**Validation ID:** {self.validation_results['validation_id']}  \n")
            f.write(f"**Topic:** {self.validation_results['topic']}  \n")
            f.write(f"**Date:** {self.validation_results['start_time']}  \n")
            f.write(f"**Duration:** {self.validation_results['duration_seconds']:.1f} seconds  \n")
            f.write(f"**Status:** {'✅ SUCCESS' if self.validation_results['success'] else '❌ FAILED'}  \n\n")
            
            # Cost Analysis
            f.write("## 💰 Cost Analysis\n\n")
            final_cost = self.validation_results['final_cost'] or 0.0
            f.write(f"- **Final Cost:** ${final_cost:.4f}\n")
            f.write(f"- **Budget Limit:** ${self.validation_results['budget_limit']:.2f}\n")
            f.write(f"- **Budget Usage:** {(final_cost/self.validation_results['budget_limit'])*100:.1f}%\n")
            f.write(f"- **Budget Compliance:** {'✅ PASSED' if self.validation_results['budget_compliance'] else '❌ FAILED'}\n\n")
            
            # Quality Scores
            f.write("## 🎯 Quality Scores\n\n")
            quality_scores = self.validation_results['quality_scores']
            if quality_scores:
                for metric, score in quality_scores.items():
                    if metric != "mock" and isinstance(score, (int, float)):
                        f.write(f"- **{metric}:** {score:.2f}/10\n")
            else:
                f.write("- No quality scores available\n")
            f.write("\n")
            
            # Performance Metrics
            f.write("## ⚡ Performance Metrics\n\n")
            perf = self.validation_results['performance_metrics']
            if 'workflow_duration' in perf:
                f.write(f"- **Workflow Duration:** {perf['workflow_duration']:.2f} seconds\n")
            if 'analysis' in perf:
                analysis = perf['analysis']
                if analysis.get('cost_efficiency'):
                    f.write(f"- **Cost Efficiency:** {analysis['cost_efficiency']['cost_per_dollar_budget']*100:.1f}% of budget used\n")
            f.write("\n")
            
            # Recommendations
            f.write("## 📋 Recommendations\n\n")
            recommendations = self.validation_results.get('recommendations', [])
            if recommendations:
                for rec in recommendations:
                    priority_emoji = {"HIGH": "🔴", "MEDIUM": "🟡", "LOW": "🟢"}.get(rec['priority'], "⚪")
                    f.write(f"### {priority_emoji} {rec['title']} ({rec['priority']})\n")
                    f.write(f"**Description:** {rec['description']}  \n")
                    f.write(f"**Action:** {rec['action']}  \n\n")
            else:
                f.write("No recommendations generated.\n\n")
            
            # System Health
            f.write("## 🔧 System Health\n\n")
            health = self.validation_results.get('system_health', {})
            for component, status in health.items():
                if isinstance(status, bool):
                    f.write(f"- **{component}:** {'✅ OK' if status else '❌ ISSUE'}\n")
                elif isinstance(status, dict):
                    f.write(f"- **{component}:**\n")
                    for sub_comp, sub_status in status.items():
                        f.write(f"  - {sub_comp}: {'✅ OK' if sub_status else '❌ ISSUE'}\n")
            f.write("\n")
            
            # Errors
            errors = self.validation_results.get('errors', [])
            if errors:
                f.write("## ❌ Errors\n\n")
                for i, error in enumerate(errors, 1):
                    f.write(f"### Error {i}\n")
                    f.write(f"**Stage:** {error.get('stage', 'unknown')}  \n")
                    f.write(f"**Error:** {error.get('error', 'unknown')}  \n")
                    f.write(f"**Timestamp:** {error.get('timestamp', 'unknown')}  \n\n")
    
    async def _print_validation_summary(self):
        """Print validation summary to console."""
        print("\n" + "=" * 80)
        print("PRODUCTION VALIDATION EPISODE SUMMARY")
        print("=" * 80)
        print(f"Topic: {self.topic}")
        print(f"Validation ID: {self.validation_id}")
        print(f"Status: {'✅ SUCCESS' if self.validation_results['success'] else '❌ FAILED'}")
        print(f"Duration: {self.validation_results['duration_seconds']:.1f} seconds")
        print("-" * 80)
        
        # Cost Summary
        final_cost = self.validation_results['final_cost'] or 0.0
        print(f"💰 COST ANALYSIS")
        print(f"   Final Cost: ${final_cost:.4f}")
        print(f"   Budget Limit: ${self.validation_results['budget_limit']:.2f}")
        print(f"   Budget Usage: {(final_cost/self.validation_results['budget_limit'])*100:.1f}%")
        print(f"   Compliance: {'✅ PASSED' if self.validation_results['budget_compliance'] else '❌ FAILED'}")
        print()
        
        # Quality Summary
        print(f"🎯 QUALITY ANALYSIS")
        quality_scores = self.validation_results['quality_scores']
        if quality_scores:
            valid_scores = [(k, v) for k, v in quality_scores.items() 
                          if k != "mock" and isinstance(v, (int, float))]
            if valid_scores:
                avg_quality = sum(score for _, score in valid_scores) / len(valid_scores)
                print(f"   Average Quality: {avg_quality:.2f}/10")
                for metric, score in valid_scores:
                    status = "✅" if score >= 8.0 else "⚠️" if score >= 7.0 else "❌"
                    print(f"   {metric}: {score:.2f}/10 {status}")
        else:
            print("   No quality scores available")
        print()
        
        # Recommendations Summary
        recommendations = self.validation_results.get('recommendations', [])
        if recommendations:
            print(f"📋 TOP RECOMMENDATIONS")
            high_priority = [r for r in recommendations if r['priority'] == 'HIGH'][:3]
            for rec in high_priority:
                print(f"   🔴 {rec['title']}: {rec['action']}")
            if not high_priority:
                medium_priority = [r for r in recommendations if r['priority'] == 'MEDIUM'][:2]
                for rec in medium_priority:
                    print(f"   🟡 {rec['title']}: {rec['action']}")
        print()
        
        # Files Generated
        print(f"📁 OUTPUT FILES")
        print(f"   Reports: {self.output_dir}/reports/")
        print(f"   Logs: {self.output_dir}/logs/")
        print(f"   Episode Data: {self.output_dir}/")
        
        print("=" * 80)
    
    def _get_completed_stages(self, final_state: Dict[str, Any]) -> List[str]:
        """Extract completed stages from final state."""
        completed = []
        current_stage = final_state.get("current_stage", "")
        
        stage_order = [
            "initialized", "research_phase", "planning_phase", 
            "production_phase", "quality_phase", "audio_phase", "completed"
        ]
        
        for stage in stage_order:
            if stage in str(current_stage) or (stage == "completed" and "completed" in str(current_stage)):
                completed.append(stage)
            if stage == current_stage:
                break
        
        return completed


async def run_production_validation():
    """Main function to run production validation episode."""
    
    # Validation episode configuration
    VALIDATION_TOPIC = "The Future of AI Assistants: Promise vs Reality"
    VALIDATION_BUDGET = 5.51
    OUTPUT_BASE_DIR = "./outputs"
    
    # Create validation runner
    validator = ProductionValidationRunner(
        topic=VALIDATION_TOPIC,
        budget=VALIDATION_BUDGET, 
        output_base_dir=OUTPUT_BASE_DIR
    )
    
    # Execute validation
    results = await validator.run_validation()
    
    # Return results for external usage
    return results


if __name__ == "__main__":
    """Direct execution entry point."""
    print("🚀 Starting Production Validation Episode")
    print("-" * 60)
    
    try:
        results = asyncio.run(run_production_validation())
        
        # Exit with appropriate code
        exit_code = 0 if results.get("success", False) else 1
        print(f"\nValidation completed with exit code: {exit_code}")
        sys.exit(exit_code)
        
    except KeyboardInterrupt:
        print("\n⏹️  Validation interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n💥 Validation failed with exception: {e}")
        sys.exit(1)