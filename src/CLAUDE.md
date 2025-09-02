# Source Code Memory - Implementation Layer 💻

<document type="source-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>src</domain>
    <scope>Python source code, implementation patterns, and development utilities</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>source code development, Python implementation, utility work</loads-when>
    <triggers>source|python|implementation|utils|development</triggers>
  </metadata>
</document>

## 🎯 SOURCE CODE DEVELOPMENT CONTEXT

**Technical:** Python implementation memory for audio processing utilities, validation scripts, testing frameworks, and utility functions supporting the AI podcast production system infrastructure.

**Simple:** Like having a toolbox manual for all the Python code that powers the system behind the scenes.

**Connection:** This teaches practical Python development, utility design, and supporting infrastructure essential for AI system implementation.

---

## 💻 SOURCE CODE ARCHITECTURE

### **Audio Processing** - `@audio/`
<LOAD_IF task="audio|tts|processing|synthesis|python">
```yaml
audio_utilities:
  tts_direct_api: "Direct ElevenLabs API implementation"
  audio_validation: "STT verification and quality checking"
  batch_synthesis: "Efficient batch audio processing"
  format_conversion: "Audio format optimization"
```
</LOAD_IF>

### **Validation Scripts** - `@validation/`
<LOAD_IF task="validation|stt|ssml|quality|verification">
```yaml
validation_tools:
  stt_verification: "Speech-to-text accuracy checking"
  ssml_processing: "SSML markup validation and optimization"
  quality_metrics: "Automated quality assessment"
  pronunciation_check: "IPA and phoneme validation"
```
</LOAD_IF>

### **Utility Functions** - `@utils/`
<LOAD_IF task="utilities|testing|helpers|tools">
```yaml
utility_functions:
  test_utilities: "Testing framework helpers"
  file_operations: "Safe file handling utilities"
  api_clients: "MCP client implementations"
  cost_calculators: "Cost estimation and tracking"
```
</LOAD_IF>

---

## 🔧 DEVELOPMENT PATTERNS

### **Python Standards**
```yaml
coding_standards:
  style: "PEP 8 compliance with black formatting"
  structure: "Module-based organization with clear interfaces"
  documentation: "Docstrings for all functions and classes"
  testing: "Unit tests for all utility functions"
  
error_handling:
  exceptions: "Custom exception classes for clear error types"
  logging: "Structured logging for debugging and monitoring"
  validation: "Input validation for all public functions"
  recovery: "Graceful degradation for non-critical failures"
```

### **Integration Patterns**
- **MCP Clients**: Python implementations for direct API access
- **Hook Integration**: Python utilities callable from bash hooks
- **Session Management**: Python scripts for state persistence
- **Quality Metrics**: Automated calculation and validation

---

*Source memory: Load when developing Python code, implementing utilities, or working with audio processing*
