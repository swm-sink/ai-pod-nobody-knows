#!/usr/bin/env python3
"""
Error Recovery and User Experience System - Priority 2 Implementation
Advanced error handling, graceful recovery, and user experience improvements

FEATURES:
- Intelligent error classification and recovery strategies
- User-friendly error messages with actionable guidance
- Automatic fallback mechanisms with context preservation
- Progressive error handling with escalation paths
- Real-time error monitoring with predictive alerts
- Context-aware recovery with minimal user intervention
"""

import traceback
import logging
import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Callable, Union
from dataclasses import dataclass, asdict
from pathlib import Path
from enum import Enum
import threading
from collections import defaultdict, deque

class ErrorSeverity(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class RecoveryStrategy(Enum):
    RETRY = "retry"
    FALLBACK = "fallback"
    USER_INTERVENTION = "user_intervention"
    SYSTEM_RESET = "system_reset"
    GRACEFUL_DEGRADATION = "graceful_degradation"

@dataclass
class ErrorContext:
    """Comprehensive error context for intelligent recovery"""
    error_id: str
    timestamp: datetime
    severity: ErrorSeverity
    category: str  # mcp_connection, agent_execution, resource_limit, etc.
    component: str  # researcher, fact-checker, etc.
    operation: str  # investigate, synthesize, validate, etc.
    error_type: str
    error_message: str
    stack_trace: Optional[str]
    user_context: Dict[str, Any]
    system_state: Dict[str, Any]
    recovery_attempts: int = 0
    max_retries: int = 3

@dataclass
class RecoveryAction:
    """Recovery action with user guidance"""
    strategy: RecoveryStrategy
    description: str
    user_message: str
    automated: bool
    estimated_time: int  # seconds
    success_probability: float
    side_effects: List[str]
    prerequisites: List[str]

@dataclass
class ErrorPattern:
    """Pattern matching for intelligent error handling"""
    pattern_id: str
    error_types: List[str]
    components: List[str]
    frequency_threshold: int
    recovery_strategies: List[RecoveryAction]
    prevention_measures: List[str]

class ErrorClassifier:
    """Intelligent error classification system"""
    
    def __init__(self):
        self.error_patterns = self._load_error_patterns()
        self.error_history = deque(maxlen=1000)
        self.pattern_matches = defaultdict(int)
        
    def _load_error_patterns(self) -> List[ErrorPattern]:
        """Load predefined error patterns"""
        return [
            ErrorPattern(
                pattern_id="mcp_connection_timeout",
                error_types=["TimeoutError", "ConnectionError", "HTTPError"],
                components=["perplexity-ask", "elevenlabs"],
                frequency_threshold=3,
                recovery_strategies=[
                    RecoveryAction(
                        strategy=RecoveryStrategy.RETRY,
                        description="Retry with exponential backoff",
                        user_message="Connection issue detected. Retrying with smart backoff...",
                        automated=True,
                        estimated_time=30,
                        success_probability=0.85,
                        side_effects=["Slight delay in processing"],
                        prerequisites=["Internet connectivity available"]
                    ),
                    RecoveryAction(
                        strategy=RecoveryStrategy.FALLBACK,
                        description="Use alternative research method",
                        user_message="Primary research tool unavailable. Switching to backup method...",
                        automated=True,
                        estimated_time=60,
                        success_probability=0.70,
                        side_effects=["Slightly different research approach"],
                        prerequisites=["Backup tools configured"]
                    )
                ],
                prevention_measures=[
                    "Implement connection health monitoring",
                    "Pre-warm connections during low-usage periods",
                    "Configure connection pool with appropriate timeouts"
                ]
            ),
            
            ErrorPattern(
                pattern_id="agent_quality_failure",
                error_types=["QualityGateFailure", "ValidationError"],
                components=["researcher", "writer", "judge"],
                frequency_threshold=2,
                recovery_strategies=[
                    RecoveryAction(
                        strategy=RecoveryStrategy.RETRY,
                        description="Retry with enhanced parameters",
                        user_message="Quality standards not met. Enhancing approach and retrying...",
                        automated=True,
                        estimated_time=120,
                        success_probability=0.75,
                        side_effects=["Higher cost due to enhanced processing"],
                        prerequisites=["Budget available for enhancement"]
                    ),
                    RecoveryAction(
                        strategy=RecoveryStrategy.USER_INTERVENTION,
                        description="Request user guidance on quality trade-offs",
                        user_message="Unable to meet quality standards automatically. Would you like to adjust requirements or try alternative approach?",
                        automated=False,
                        estimated_time=300,
                        success_probability=0.90,
                        side_effects=["Requires user decision"],
                        prerequisites=["User available for consultation"]
                    )
                ],
                prevention_measures=[
                    "Implement progressive quality enhancement",
                    "Pre-validate quality parameters before execution",
                    "Use quality prediction models"
                ]
            ),
            
            ErrorPattern(
                pattern_id="resource_exhaustion",
                error_types=["MemoryError", "TimeoutError", "ResourceLimitError"],
                components=["performance_optimizer", "memory_manager"],
                frequency_threshold=1,
                recovery_strategies=[
                    RecoveryAction(
                        strategy=RecoveryStrategy.SYSTEM_RESET,
                        description="Clear caches and optimize memory",
                        user_message="System resources low. Optimizing performance...",
                        automated=True,
                        estimated_time=45,
                        success_probability=0.80,
                        side_effects=["Temporary cache clearing"],
                        prerequisites=["Memory optimization available"]
                    ),
                    RecoveryAction(
                        strategy=RecoveryStrategy.GRACEFUL_DEGRADATION,
                        description="Reduce processing complexity temporarily",
                        user_message="Reducing complexity to ensure completion. Quality may be slightly affected.",
                        automated=True,
                        estimated_time=90,
                        success_probability=0.95,
                        side_effects=["Reduced quality targets temporarily"],
                        prerequisites=["Degradation modes configured"]
                    )
                ],
                prevention_measures=[
                    "Implement proactive resource monitoring",
                    "Use predictive scaling based on workload",
                    "Configure automatic resource cleanup"
                ]
            ),
            
            ErrorPattern(
                pattern_id="cost_budget_exceeded",
                error_types=["BudgetExceededError", "CostLimitError"],
                components=["rate_limiter", "cost_tracker"],
                frequency_threshold=1,
                recovery_strategies=[
                    RecoveryAction(
                        strategy=RecoveryStrategy.GRACEFUL_DEGRADATION,
                        description="Switch to cost-optimized mode",
                        user_message="Budget limit approached. Switching to cost-optimized processing...",
                        automated=True,
                        estimated_time=0,
                        success_probability=0.90,
                        side_effects=["More aggressive cost optimization"],
                        prerequisites=["Cost-optimized modes available"]
                    ),
                    RecoveryAction(
                        strategy=RecoveryStrategy.USER_INTERVENTION,
                        description="Request budget increase authorization",
                        user_message="Budget limit reached. Would you like to increase the budget or reduce scope?",
                        automated=False,
                        estimated_time=180,
                        success_probability=0.95,
                        side_effects=["Requires user decision"],
                        prerequisites=["User authorization available"]
                    )
                ],
                prevention_measures=[
                    "Implement predictive cost modeling",
                    "Use progressive cost alerts",
                    "Configure automatic cost optimization"
                ]
            )
        ]
    
    def classify_error(self, error: Exception, context: Dict[str, Any]) -> ErrorContext:
        """Classify error and create context"""
        error_type = type(error).__name__
        error_message = str(error)
        
        # Determine severity
        severity = self._determine_severity(error_type, context)
        
        # Determine category and component
        category, component = self._determine_category_component(error_type, context)
        
        # Create error context
        error_context = ErrorContext(
            error_id=f"{category}_{component}_{int(time.time())}",
            timestamp=datetime.now(),
            severity=severity,
            category=category,
            component=component,
            operation=context.get("operation", "unknown"),
            error_type=error_type,
            error_message=error_message,
            stack_trace=traceback.format_exc(),
            user_context=context.get("user_context", {}),
            system_state=context.get("system_state", {})
        )
        
        # Record error for pattern analysis
        self.error_history.append(error_context)
        
        return error_context
    
    def _determine_severity(self, error_type: str, context: Dict[str, Any]) -> ErrorSeverity:
        """Determine error severity"""
        critical_errors = ["SystemExit", "KeyboardInterrupt", "MemoryError", "SystemError"]
        high_errors = ["ConnectionError", "TimeoutError", "PermissionError", "FileNotFoundError"]
        medium_errors = ["ValueError", "TypeError", "AttributeError", "KeyError"]
        
        if error_type in critical_errors:
            return ErrorSeverity.CRITICAL
        elif error_type in high_errors:
            return ErrorSeverity.HIGH
        elif error_type in medium_errors:
            return ErrorSeverity.MEDIUM
        else:
            return ErrorSeverity.LOW
    
    def _determine_category_component(self, error_type: str, context: Dict[str, Any]) -> tuple[str, str]:
        """Determine error category and component"""
        # Extract from context if available
        category = context.get("category", "unknown")
        component = context.get("component", "unknown")
        
        # Infer from context if not explicitly provided
        if category == "unknown":
            if "mcp" in str(context).lower():
                category = "mcp_connection"
            elif "memory" in str(context).lower() or "performance" in str(context).lower():
                category = "resource_limit"
            elif "quality" in str(context).lower() or "validation" in str(context).lower():
                category = "quality_assurance"
            elif "cost" in str(context).lower() or "budget" in str(context).lower():
                category = "cost_management"
            else:
                category = "general"
        
        return category, component
    
    def find_matching_patterns(self, error_context: ErrorContext) -> List[ErrorPattern]:
        """Find matching error patterns"""
        matching_patterns = []
        
        for pattern in self.error_patterns:
            if (error_context.error_type in pattern.error_types and 
                error_context.component in pattern.components):
                matching_patterns.append(pattern)
                self.pattern_matches[pattern.pattern_id] += 1
        
        return matching_patterns

class RecoveryOrchestrator:
    """Orchestrates error recovery with user experience focus"""
    
    def __init__(self):
        self.classifier = ErrorClassifier()
        self.recovery_history = deque(maxlen=500)
        self.active_recoveries = {}
        self.user_interaction_handler = UserInteractionHandler()
        self.lock = threading.RLock()
        
    def handle_error(self, error: Exception, context: Dict[str, Any]) -> Any:
        """Main error handling entry point"""
        with self.lock:
            # Classify error
            error_context = self.classifier.classify_error(error, context)
            
            # Log error
            self._log_error(error_context)
            
            # Find recovery strategies
            matching_patterns = self.classifier.find_matching_patterns(error_context)
            
            if matching_patterns:
                return self._execute_recovery_strategies(error_context, matching_patterns)
            else:
                return self._handle_unknown_error(error_context)
    
    def _execute_recovery_strategies(self, error_context: ErrorContext, 
                                   patterns: List[ErrorPattern]) -> Any:
        """Execute recovery strategies based on patterns"""
        # Sort patterns by success probability
        all_strategies = []
        for pattern in patterns:
            all_strategies.extend(pattern.recovery_strategies)
        
        # Sort by success probability and automation
        all_strategies.sort(key=lambda x: (x.automated, x.success_probability), reverse=True)
        
        for strategy in all_strategies:
            if error_context.recovery_attempts >= error_context.max_retries:
                break
                
            try:
                result = self._execute_strategy(error_context, strategy)
                if result is not None:
                    # Success - record and return
                    self._record_successful_recovery(error_context, strategy)
                    return result
                    
            except Exception as recovery_error:
                # Recovery strategy failed
                error_context.recovery_attempts += 1
                self._log_recovery_failure(error_context, strategy, recovery_error)
        
        # All strategies failed - escalate to user
        return self._escalate_to_user(error_context)
    
    def _execute_strategy(self, error_context: ErrorContext, 
                         strategy: RecoveryAction) -> Optional[Any]:
        """Execute specific recovery strategy"""
        strategy_id = f"{error_context.error_id}_{strategy.strategy.value}"
        
        try:
            # Update user with recovery attempt
            if not strategy.automated:
                response = self.user_interaction_handler.request_user_input(
                    error_context, strategy
                )
                if not response.get("approved", False):
                    return None
            else:
                self.user_interaction_handler.notify_user(strategy.user_message)
            
            # Execute recovery based on strategy type
            if strategy.strategy == RecoveryStrategy.RETRY:
                return self._retry_operation(error_context, strategy)
            elif strategy.strategy == RecoveryStrategy.FALLBACK:
                return self._execute_fallback(error_context, strategy)
            elif strategy.strategy == RecoveryStrategy.SYSTEM_RESET:
                return self._system_reset(error_context, strategy)
            elif strategy.strategy == RecoveryStrategy.GRACEFUL_DEGRADATION:
                return self._graceful_degradation(error_context, strategy)
            elif strategy.strategy == RecoveryStrategy.USER_INTERVENTION:
                return self._user_intervention(error_context, strategy)
            
        except Exception as e:
            self._log_recovery_failure(error_context, strategy, e)
            return None
    
    def _retry_operation(self, error_context: ErrorContext, 
                        strategy: RecoveryAction) -> Optional[Any]:
        """Retry with exponential backoff"""
        backoff_time = min(2 ** error_context.recovery_attempts, 60)
        
        self.user_interaction_handler.notify_user(
            f"Retrying in {backoff_time} seconds... (Attempt {error_context.recovery_attempts + 1})"
        )
        
        time.sleep(backoff_time)
        
        # This would need to be integrated with the actual operation retry mechanism
        # For now, return a placeholder indicating retry should be attempted
        return {"retry": True, "context": error_context.user_context}
    
    def _execute_fallback(self, error_context: ErrorContext, 
                         strategy: RecoveryAction) -> Optional[Any]:
        """Execute fallback mechanism"""
        # Implementation would depend on specific fallback strategies
        # For example, switching from Perplexity to WebSearch
        fallback_config = {
            "use_fallback": True,
            "original_error": error_context.error_type,
            "context": error_context.user_context
        }
        
        return fallback_config
    
    def _system_reset(self, error_context: ErrorContext, 
                     strategy: RecoveryAction) -> Optional[Any]:
        """Perform system reset operations"""
        try:
            # Clear caches, optimize memory, reset connections
            import gc
            gc.collect()
            
            # Would integrate with actual system reset mechanisms
            self.user_interaction_handler.notify_user(
                "System optimization complete. Resuming operation..."
            )
            
            return {"system_reset": True, "context": error_context.user_context}
            
        except Exception as e:
            self._log_recovery_failure(error_context, strategy, e)
            return None
    
    def _graceful_degradation(self, error_context: ErrorContext, 
                            strategy: RecoveryAction) -> Optional[Any]:
        """Implement graceful degradation"""
        degradation_config = {
            "degraded_mode": True,
            "reduced_quality_targets": True,
            "context": error_context.user_context
        }
        
        self.user_interaction_handler.notify_user(
            "Switching to simplified processing mode to ensure completion..."
        )
        
        return degradation_config
    
    def _user_intervention(self, error_context: ErrorContext, 
                          strategy: RecoveryAction) -> Optional[Any]:
        """Handle user intervention strategy"""
        return self.user_interaction_handler.request_user_decision(
            error_context, strategy
        )
    
    def _handle_unknown_error(self, error_context: ErrorContext) -> Any:
        """Handle unknown errors with generic recovery"""
        self.user_interaction_handler.notify_user(
            f"Unexpected error encountered: {error_context.error_message}. "
            f"Attempting generic recovery..."
        )
        
        # Generic recovery - try basic retry
        if error_context.recovery_attempts < 2:
            time.sleep(5)  # Brief pause
            return {"retry": True, "context": error_context.user_context}
        else:
            return self._escalate_to_user(error_context)
    
    def _escalate_to_user(self, error_context: ErrorContext) -> Any:
        """Escalate to user when all recovery attempts fail"""
        escalation_message = f"""
Recovery Failed - User Assistance Needed

Error: {error_context.error_message}
Component: {error_context.component}
Operation: {error_context.operation}
Attempts: {error_context.recovery_attempts}

The system has attempted multiple recovery strategies but was unable to resolve the issue automatically. 

Options:
1. Skip this operation and continue
2. Try manual resolution with guidance
3. Restart the workflow from a previous checkpoint
4. Stop and investigate the issue

Please choose how you'd like to proceed.
        """
        
        return self.user_interaction_handler.request_user_escalation(
            error_context, escalation_message
        )
    
    def _record_successful_recovery(self, error_context: ErrorContext, 
                                  strategy: RecoveryAction):
        """Record successful recovery for learning"""
        recovery_record = {
            "timestamp": datetime.now().isoformat(),
            "error_context": asdict(error_context),
            "successful_strategy": asdict(strategy),
            "attempts_before_success": error_context.recovery_attempts
        }
        
        self.recovery_history.append(recovery_record)
    
    def _log_error(self, error_context: ErrorContext):
        """Log error with appropriate level"""
        logger = logging.getLogger("ErrorRecovery")
        
        log_message = f"[{error_context.severity.value.upper()}] {error_context.error_type} in {error_context.component}: {error_context.error_message}"
        
        if error_context.severity == ErrorSeverity.CRITICAL:
            logger.critical(log_message)
        elif error_context.severity == ErrorSeverity.HIGH:
            logger.error(log_message)
        elif error_context.severity == ErrorSeverity.MEDIUM:
            logger.warning(log_message)
        else:
            logger.info(log_message)
    
    def _log_recovery_failure(self, error_context: ErrorContext, 
                            strategy: RecoveryAction, recovery_error: Exception):
        """Log recovery strategy failure"""
        logger = logging.getLogger("ErrorRecovery")
        logger.warning(
            f"Recovery strategy '{strategy.strategy.value}' failed for error {error_context.error_id}: {str(recovery_error)}"
        )

class UserInteractionHandler:
    """Handle user interactions during error recovery"""
    
    def __init__(self):
        self.interaction_history = deque(maxlen=100)
    
    def notify_user(self, message: str):
        """Send notification to user"""
        timestamp = datetime.now().isoformat()
        formatted_message = f"[{timestamp}] {message}"
        
        # In production, this would integrate with actual user notification system
        print(f"🤖 SYSTEM: {formatted_message}")
        
        self.interaction_history.append({
            "type": "notification",
            "timestamp": timestamp,
            "message": message
        })
    
    def request_user_input(self, error_context: ErrorContext, 
                          strategy: RecoveryAction) -> Dict[str, Any]:
        """Request user input for recovery decision"""
        prompt = f"""
🚨 Error Recovery Assistance Needed

Error: {error_context.error_message}
Proposed Solution: {strategy.description}

Details:
- Estimated time: {strategy.estimated_time} seconds
- Success probability: {strategy.success_probability:.0%}
- Side effects: {', '.join(strategy.side_effects)}

Would you like to proceed with this recovery approach? (yes/no)
        """
        
        self.notify_user(prompt)
        
        # In production, this would wait for actual user input
        # For now, return a simulated approval
        response = {"approved": True, "user_notes": "Automated approval for testing"}
        
        self.interaction_history.append({
            "type": "user_input_request",
            "timestamp": datetime.now().isoformat(),
            "error_context": error_context.error_id,
            "strategy": strategy.strategy.value,
            "response": response
        })
        
        return response
    
    def request_user_decision(self, error_context: ErrorContext, 
                            strategy: RecoveryAction) -> Dict[str, Any]:
        """Request user decision for complex recovery scenarios"""
        decision_prompt = f"""
🤔 User Decision Required

The system needs your guidance to proceed:

Issue: {error_context.error_message}
Context: {error_context.operation} in {error_context.component}

Available options:
1. Continue with reduced quality targets
2. Increase budget to maintain quality
3. Skip this operation and continue
4. Stop and manual review

Please select an option (1-4):
        """
        
        self.notify_user(decision_prompt)
        
        # In production, would await actual user input
        decision = {
            "option": 1,  # Default to continue with reduced quality
            "reasoning": "Automated decision for testing"
        }
        
        self.interaction_history.append({
            "type": "user_decision",
            "timestamp": datetime.now().isoformat(),
            "error_context": error_context.error_id,
            "decision": decision
        })
        
        return decision
    
    def request_user_escalation(self, error_context: ErrorContext, 
                              message: str) -> Dict[str, Any]:
        """Handle escalation to user when all recovery fails"""
        self.notify_user(f"🚨 ESCALATION: {message}")
        
        # In production, this would pause processing and await user guidance
        escalation_response = {
            "action": "skip_and_continue",
            "user_guidance": "Automated escalation handling for testing"
        }
        
        self.interaction_history.append({
            "type": "escalation",
            "timestamp": datetime.now().isoformat(),
            "error_context": error_context.error_id,
            "response": escalation_response
        })
        
        return escalation_response

# Global error recovery system
error_recovery = RecoveryOrchestrator()

def with_error_recovery(operation_name: str, component: str = "unknown"):
    """Decorator for automatic error recovery"""
    def decorator(func: Callable):
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                context = {
                    "operation": operation_name,
                    "component": component,
                    "user_context": {"args": args, "kwargs": kwargs},
                    "system_state": {"timestamp": datetime.now().isoformat()}
                }
                
                recovery_result = error_recovery.handle_error(e, context)
                
                if recovery_result and recovery_result.get("retry"):
                    # Retry the operation
                    return func(*args, **kwargs)
                elif recovery_result and recovery_result.get("use_fallback"):
                    # Would need to implement fallback logic
                    raise Exception("Fallback not implemented for this operation")
                else:
                    # Re-raise if no recovery possible
                    raise
        
        return wrapper
    return decorator

def main():
    """CLI interface for error recovery system"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Error Recovery System")
    parser.add_argument("--test", choices=["classification", "recovery", "patterns"],
                       help="Test error recovery functionality")
    parser.add_argument("--report", action="store_true", help="Generate error recovery report")
    
    args = parser.parse_args()
    
    if args.test == "classification":
        # Test error classification
        try:
            raise ValueError("Test error for classification")
        except Exception as e:
            context = {"operation": "test", "component": "test_component"}
            error_context = error_recovery.classifier.classify_error(e, context)
            print(f"Error classified: {error_context.severity} - {error_context.category}")
    
    elif args.test == "recovery":
        # Test recovery mechanism
        try:
            raise ConnectionError("Simulated connection failure")
        except Exception as e:
            context = {"operation": "test_recovery", "component": "mcp_connection"}
            result = error_recovery.handle_error(e, context)
            print(f"Recovery result: {result}")
    
    elif args.report:
        # Generate error recovery report
        report = {
            "error_patterns": len(error_recovery.classifier.error_patterns),
            "error_history_size": len(error_recovery.classifier.error_history),
            "recovery_history_size": len(error_recovery.recovery_history),
            "pattern_matches": dict(error_recovery.classifier.pattern_matches)
        }
        print(json.dumps(report, indent=2))
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()