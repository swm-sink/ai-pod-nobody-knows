# Structured Output Schemas - Production JSON Templates

## Research Metadata
- **Created**: 2025-08-21
- **Purpose**: Standardized JSON schemas for Perplexity research and analysis outputs
- **Focus**: Consistent, machine-readable data structures for agent enhancement workflows
- **Context**: Supporting both Sonar Deep Research and Sonar Reasoning structured outputs

---

## Core Schema Architecture

### Master Research Package Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "Master Research Package",
  "description": "Complete research and analysis package for agent enhancement",
  "required": ["research_metadata", "deep_research_results", "reasoning_analysis"],
  "properties": {
    "research_metadata": {
      "$ref": "#/definitions/ResearchMetadata"
    },
    "deep_research_results": {
      "$ref": "#/definitions/DeepResearchResults"
    },
    "reasoning_analysis": {
      "$ref": "#/definitions/ReasoningAnalysis"
    },
    "implementation_roadmap": {
      "$ref": "#/definitions/ImplementationRoadmap"
    },
    "quality_assessment": {
      "$ref": "#/definitions/QualityAssessment"
    }
  },
  "definitions": {
    "ResearchMetadata": {
      "type": "object",
      "required": ["research_id", "topic", "timestamp", "models_used"],
      "properties": {
        "research_id": {
          "type": "string",
          "pattern": "^[a-zA-Z0-9_-]+$",
          "description": "Unique identifier for research package"
        },
        "topic": {
          "type": "string",
          "description": "Primary research subject"
        },
        "research_objective": {
          "type": "string",
          "description": "Specific goal and intended application"
        },
        "timestamp": {
          "type": "string",
          "format": "date-time",
          "description": "Research completion timestamp"
        },
        "models_used": {
          "type": "object",
          "properties": {
            "deep_research": {
              "type": "string",
              "enum": ["sonar-deep-research"]
            },
            "reasoning_analysis": {
              "type": "string",
              "enum": ["sonar-reasoning"]
            }
          }
        },
        "cost_tracking": {
          "$ref": "#/definitions/CostTracking"
        }
      }
    }
  }
}
```

---

## Sonar Deep Research Schema

### Comprehensive Research Results Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "Sonar Deep Research Results",
  "required": ["query_metadata", "research_findings", "source_analysis"],
  "properties": {
    "query_metadata": {
      "type": "object",
      "required": ["original_query", "optimized_query", "reasoning_effort"],
      "properties": {
        "original_query": {
          "type": "string",
          "description": "Initial research question"
        },
        "optimized_query": {
          "type": "string",
          "description": "Expert-enhanced query for maximum results"
        },
        "reasoning_effort": {
          "type": "string",
          "enum": ["high", "medium", "low"],
          "description": "Reasoning depth setting"
        },
        "search_parameters": {
          "type": "object",
          "properties": {
            "domain_focus": "string",
            "time_range": "string",
            "authority_preference": "string",
            "source_types": {
              "type": "array",
              "items": {
                "type": "string",
                "enum": ["academic", "industry", "government", "expert_analysis", "technical_documentation"]
              }
            }
          }
        }
      }
    },
    "research_findings": {
      "type": "object",
      "required": ["executive_summary", "comprehensive_analysis"],
      "properties": {
        "executive_summary": {
          "type": "object",
          "required": ["key_insights", "critical_findings"],
          "properties": {
            "key_insights": {
              "type": "array",
              "items": "string",
              "minItems": 3,
              "maxItems": 8,
              "description": "Primary research discoveries"
            },
            "critical_findings": {
              "type": "array",
              "items": "string",
              "minItems": 2,
              "maxItems": 5,
              "description": "Most important actionable insights"
            },
            "implementation_priorities": {
              "type": "array",
              "items": "string",
              "description": "Priority order for applying findings"
            }
          }
        },
        "comprehensive_analysis": {
          "type": "object",
          "properties": {
            "domain_overview": {
              "type": "string",
              "description": "Current state of the research domain"
            },
            "best_practices": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "practice": "string",
                  "description": "string",
                  "authority_sources": {
                    "type": "array",
                    "items": "string"
                  },
                  "implementation_complexity": {
                    "type": "string",
                    "enum": ["low", "medium", "high", "expert"]
                  }
                }
              }
            },
            "emerging_trends": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "trend": "string",
                  "adoption_stage": {
                    "type": "string",
                    "enum": ["experimental", "early_adopter", "mainstream", "mature"]
                  },
                  "relevance_score": {
                    "type": "number",
                    "minimum": 0,
                    "maximum": 10
                  }
                }
              }
            },
            "optimization_opportunities": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "opportunity": "string",
                  "impact_potential": {
                    "type": "string",
                    "enum": ["low", "medium", "high", "transformative"]
                  },
                  "implementation_effort": {
                    "type": "string",
                    "enum": ["trivial", "moderate", "significant", "major"]
                  },
                  "supporting_evidence": {
                    "type": "array",
                    "items": "string"
                  }
                }
              }
            }
          }
        }
      }
    },
    "source_analysis": {
      "$ref": "#/definitions/SourceAnalysis"
    }
  },
  "definitions": {
    "SourceAnalysis": {
      "type": "object",
      "required": ["primary_sources", "source_quality_metrics"],
      "properties": {
        "primary_sources": {
          "type": "array",
          "minItems": 5,
          "items": {
            "type": "object",
            "required": ["url", "title", "authority_score", "relevance_score"],
            "properties": {
              "url": {
                "type": "string",
                "format": "uri"
              },
              "title": "string",
              "authority_score": {
                "type": "number",
                "minimum": 0,
                "maximum": 1
              },
              "relevance_score": {
                "type": "number",
                "minimum": 0,
                "maximum": 1
              },
              "publication_date": {
                "type": "string",
                "format": "date"
              },
              "source_type": {
                "type": "string",
                "enum": ["academic", "industry", "government", "expert_blog", "technical_docs", "case_study"]
              },
              "key_contributions": {
                "type": "array",
                "items": "string",
                "description": "Specific insights from this source"
              },
              "credibility_indicators": {
                "type": "object",
                "properties": {
                  "peer_reviewed": "boolean",
                  "expert_author": "boolean",
                  "institutional_backing": "boolean",
                  "citation_count": "number"
                }
              }
            }
          }
        },
        "source_quality_metrics": {
          "type": "object",
          "properties": {
            "total_sources": "number",
            "average_authority_score": "number",
            "source_diversity": {
              "type": "object",
              "properties": {
                "academic_percentage": "number",
                "industry_percentage": "number",
                "government_percentage": "number",
                "expert_analysis_percentage": "number"
              }
            },
            "temporal_distribution": {
              "type": "object",
              "properties": {
                "last_6_months": "number",
                "last_12_months": "number",
                "last_24_months": "number",
                "older_sources": "number"
              }
            },
            "geographic_diversity": {
              "type": "array",
              "items": "string",
              "description": "Regions/countries represented in sources"
            }
          }
        }
      }
    }
  }
}
```

---

## Sonar Reasoning Schema

### Strategic Analysis Results Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "Sonar Reasoning Analysis Results",
  "required": ["analysis_metadata", "strategic_assessment", "implementation_framework"],
  "properties": {
    "analysis_metadata": {
      "type": "object",
      "required": ["research_input_reference", "analysis_type", "reasoning_approach"],
      "properties": {
        "research_input_reference": {
          "type": "string",
          "description": "Reference to source Sonar Deep Research results"
        },
        "analysis_objective": "string",
        "analysis_type": {
          "type": "string",
          "enum": ["strategic_implementation", "comparative_analysis", "risk_assessment", "optimization_strategy", "decision_support", "synthesis_integration"]
        },
        "reasoning_approach": {
          "type": "string",
          "enum": ["chain-of-thought", "structured-comparison", "risk-assessment", "optimization-focused", "decision-analysis", "synthesis-integration"]
        },
        "analysis_depth": {
          "type": "string",
          "enum": ["overview", "strategic", "comprehensive", "thorough"]
        }
      }
    },
    "strategic_assessment": {
      "type": "object",
      "required": ["key_insights", "strategic_implications"],
      "properties": {
        "key_insights": {
          "type": "array",
          "items": "string",
          "minItems": 3,
          "description": "Primary strategic discoveries from analysis"
        },
        "strategic_implications": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "implication": "string",
              "impact_level": {
                "type": "string",
                "enum": ["low", "medium", "high", "critical"]
              },
              "stakeholders_affected": {
                "type": "array",
                "items": "string"
              },
              "timeline": {
                "type": "string",
                "enum": ["immediate", "short_term", "medium_term", "long_term"]
              }
            }
          }
        },
        "critical_success_factors": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "factor": "string",
              "importance": {
                "type": "string",
                "enum": ["essential", "important", "beneficial", "nice_to_have"]
              },
              "controllability": {
                "type": "string",
                "enum": ["fully_controllable", "partially_controllable", "external_dependency"]
              }
            }
          }
        }
      }
    },
    "implementation_framework": {
      "type": "object",
      "required": ["recommended_approach", "implementation_priorities"],
      "properties": {
        "recommended_approach": {
          "type": "object",
          "properties": {
            "strategy_overview": "string",
            "key_principles": {
              "type": "array",
              "items": "string"
            },
            "success_philosophy": "string"
          }
        },
        "implementation_priorities": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["priority_rank", "initiative", "rationale"],
            "properties": {
              "priority_rank": {
                "type": "integer",
                "minimum": 1
              },
              "initiative": "string",
              "rationale": "string",
              "resource_requirements": {
                "type": "object",
                "properties": {
                  "budget_estimate": "string",
                  "time_estimate": "string",
                  "capability_requirements": {
                    "type": "array",
                    "items": "string"
                  },
                  "external_dependencies": {
                    "type": "array",
                    "items": "string"
                  }
                }
              },
              "success_metrics": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "metric": "string",
                    "target_value": "string",
                    "measurement_method": "string",
                    "measurement_frequency": "string"
                  }
                }
              },
              "validation_checkpoints": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "checkpoint": "string",
                    "criteria": "string",
                    "timeline": "string"
                  }
                }
              }
            }
          }
        }
      }
    },
    "comparative_analysis": {
      "type": "object",
      "properties": {
        "options_evaluated": {
          "type": "array",
          "items": "string"
        },
        "evaluation_criteria": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "criterion": "string",
              "weight": {
                "type": "number",
                "minimum": 0,
                "maximum": 1
              },
              "description": "string"
            }
          }
        },
        "scoring_matrix": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "option": "string",
              "criteria_scores": {
                "type": "object",
                "patternProperties": {
                  "^[a-zA-Z_]+$": {
                    "type": "number",
                    "minimum": 0,
                    "maximum": 10
                  }
                }
              },
              "weighted_total": "number",
              "ranking": "integer"
            }
          }
        },
        "recommendation": {
          "type": "object",
          "required": ["preferred_option", "rationale"],
          "properties": {
            "preferred_option": "string",
            "confidence_level": {
              "type": "string",
              "enum": ["high", "medium", "low"]
            },
            "rationale": "string",
            "key_advantages": {
              "type": "array",
              "items": "string"
            },
            "acknowledged_limitations": {
              "type": "array",
              "items": "string"
            }
          }
        }
      }
    },
    "risk_assessment": {
      "$ref": "#/definitions/RiskAssessment"
    }
  },
  "definitions": {
    "RiskAssessment": {
      "type": "object",
      "properties": {
        "identified_risks": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["risk_description", "probability", "impact"],
            "properties": {
              "risk_id": "string",
              "risk_description": "string",
              "probability": {
                "type": "string",
                "enum": ["very_low", "low", "medium", "high", "very_high"]
              },
              "impact": {
                "type": "string",
                "enum": ["negligible", "minor", "moderate", "major", "critical"]
              },
              "risk_category": {
                "type": "string",
                "enum": ["technical", "operational", "financial", "strategic", "regulatory", "reputation"]
              },
              "mitigation_strategy": {
                "type": "object",
                "properties": {
                  "preventive_measures": {
                    "type": "array",
                    "items": "string"
                  },
                  "contingency_plan": "string",
                  "monitoring_approach": "string",
                  "escalation_criteria": "string"
                }
              }
            }
          }
        },
        "overall_risk_profile": {
          "type": "object",
          "properties": {
            "risk_level": {
              "type": "string",
              "enum": ["low", "medium", "high", "critical"]
            },
            "risk_summary": "string",
            "key_risk_drivers": {
              "type": "array",
              "items": "string"
            },
            "recommended_risk_response": "string"
          }
        }
      }
    }
  }
}
```

---

## Implementation Roadmap Schema

### Enhancement Implementation Plan Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "Implementation Roadmap",
  "required": ["roadmap_metadata", "implementation_phases", "resource_planning"],
  "properties": {
    "roadmap_metadata": {
      "type": "object",
      "properties": {
        "roadmap_id": "string",
        "target_system": "string",
        "enhancement_scope": "string",
        "estimated_timeline": "string",
        "created_date": {
          "type": "string",
          "format": "date-time"
        }
      }
    },
    "implementation_phases": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["phase_number", "phase_name", "objectives", "deliverables"],
        "properties": {
          "phase_number": "integer",
          "phase_name": "string",
          "phase_description": "string",
          "objectives": {
            "type": "array",
            "items": "string"
          },
          "deliverables": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "deliverable": "string",
                "description": "string",
                "acceptance_criteria": {
                  "type": "array",
                  "items": "string"
                },
                "validation_method": "string"
              }
            }
          },
          "timeline": {
            "type": "object",
            "properties": {
              "estimated_duration": "string",
              "dependencies": {
                "type": "array",
                "items": "string"
              },
              "critical_path_items": {
                "type": "array",
                "items": "string"
              }
            }
          }
        }
      }
    },
    "resource_planning": {
      "$ref": "#/definitions/ResourcePlanning"
    }
  },
  "definitions": {
    "ResourcePlanning": {
      "type": "object",
      "properties": {
        "budget_allocation": {
          "type": "object",
          "properties": {
            "total_budget_estimate": "string",
            "phase_breakdown": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "phase": "string",
                  "budget_allocation": "string",
                  "cost_categories": {
                    "type": "object",
                    "properties": {
                      "api_costs": "string",
                      "development_time": "string",
                      "testing_resources": "string",
                      "infrastructure": "string"
                    }
                  }
                }
              }
            }
          }
        },
        "capability_requirements": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "capability": "string",
              "required_level": {
                "type": "string",
                "enum": ["basic", "intermediate", "advanced", "expert"]
              },
              "availability": {
                "type": "string",
                "enum": ["available", "needs_development", "requires_hiring", "external_resource"]
              }
            }
          }
        }
      }
    }
  }
}
```

---

## Quality Assessment Schema

### Research & Analysis Quality Validation Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "Quality Assessment",
  "required": ["assessment_metadata", "research_quality", "analysis_quality"],
  "properties": {
    "assessment_metadata": {
      "type": "object",
      "properties": {
        "assessment_date": {
          "type": "string",
          "format": "date-time"
        },
        "assessor": "string",
        "assessment_criteria_version": "string"
      }
    },
    "research_quality": {
      "type": "object",
      "properties": {
        "completeness_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "source_quality_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "insight_depth_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "actionability_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "overall_research_rating": {
          "type": "string",
          "enum": ["excellent", "good", "satisfactory", "needs_improvement", "inadequate"]
        },
        "quality_notes": "string"
      }
    },
    "analysis_quality": {
      "type": "object",
      "properties": {
        "logical_coherence_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "strategic_value_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "implementation_specificity_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "risk_assessment_completeness": {
          "type": "number",
          "minimum": 0,
          "maximum": 10
        },
        "overall_analysis_rating": {
          "type": "string",
          "enum": ["excellent", "good", "satisfactory", "needs_improvement", "inadequate"]
        },
        "analysis_notes": "string"
      }
    }
  }
}
```

---

## Cost Tracking Schema

### Comprehensive Cost Analysis Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "Cost Tracking",
  "required": ["cost_metadata", "deep_research_costs", "reasoning_costs"],
  "properties": {
    "cost_metadata": {
      "type": "object",
      "properties": {
        "tracking_id": "string",
        "cost_calculation_date": {
          "type": "string",
          "format": "date-time"
        },
        "currency": {
          "type": "string",
          "default": "USD"
        }
      }
    },
    "deep_research_costs": {
      "type": "object",
      "properties": {
        "input_token_cost": {
          "type": "number",
          "description": "Cost for input tokens at $2/1M"
        },
        "output_token_cost": {
          "type": "number",
          "description": "Cost for output tokens at $8/1M"
        },
        "citation_token_cost": {
          "type": "number",
          "description": "Cost for citation tokens at $2/1M"
        },
        "search_query_cost": {
          "type": "number",
          "description": "Cost for search queries at $5/1K"
        },
        "reasoning_token_cost": {
          "type": "number",
          "description": "Cost for reasoning tokens at $3/1M"
        },
        "subtotal_deep_research": "number"
      }
    },
    "reasoning_costs": {
      "type": "object",
      "properties": {
        "input_token_cost": {
          "type": "number",
          "description": "Cost for input tokens at $1/1M"
        },
        "output_token_cost": {
          "type": "number",
          "description": "Cost for output tokens at $5/1M"
        },
        "subtotal_reasoning": "number"
      }
    },
    "total_research_cost": "number",
    "cost_per_insight": {
      "type": "number",
      "description": "Total cost divided by number of key insights"
    },
    "budget_tracking": {
      "type": "object",
      "properties": {
        "allocated_budget": "number",
        "remaining_budget": "number",
        "budget_utilization_percentage": "number"
      }
    }
  }
}
```

---

## Schema Usage Guidelines

### Implementation Best Practices
```yaml
schema_implementation:
  validation_approach:
    - validate_before_processing: "Always validate JSON against schema"
    - error_handling: "Graceful handling of schema validation failures"
    - schema_versioning: "Track schema versions for compatibility"
    - migration_planning: "Plan for schema evolution and data migration"

  quality_assurance:
    - required_field_completeness: "Ensure all required fields are populated"
    - data_type_validation: "Verify correct data types and formats"
    - constraint_checking: "Validate min/max values and enums"
    - business_logic_validation: "Check business rules and relationships"

  performance_optimization:
    - schema_size_management: "Keep schemas as simple as possible"
    - nested_structure_optimization: "Balance detail with processing efficiency"
    - caching_strategies: "Cache validated schemas for repeated use"
    - batch_processing: "Process multiple research packages efficiently"
```

### Integration with Perplexity APIs
```yaml
api_integration:
  request_formatting:
    - response_format_specification: "Include schema in API requests"
    - schema_hinting: "Reference desired structure in prompts"
    - error_recovery: "Handle schema compliance failures"
    - retry_strategies: "Automatic retry with schema corrections"

  output_processing:
    - automatic_validation: "Validate all API responses against schemas"
    - error_detection: "Identify and flag schema violations"
    - data_extraction: "Extract structured data for downstream processing"
    - quality_metrics: "Track schema compliance rates and quality"
```

These comprehensive schemas ensure consistent, machine-readable outputs from our Perplexity research workflows, enabling reliable automation and quality assurance across all agent enhancement activities.
