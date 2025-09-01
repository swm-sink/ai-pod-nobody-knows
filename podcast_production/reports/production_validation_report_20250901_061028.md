================================================================================
AI PODCAST PRODUCTION - PRODUCTION VALIDATION REPORT
================================================================================
Validation Date: 2025-09-01 06:10:28
Total Duration: 0.0 seconds
Environment: production

VALIDATION SUMMARY
========================================
Total Tests: 3
Passed: 2 ✓
Failed: 1 ✗
Skipped: 0 ⊝
Total Cost: $0.000000

PRODUCTION READINESS: ✗ NOT READY

ENVIRONMENT TESTS
========================================
✗ env_variables *: Missing required variables: OPENROUTER_API_KEY, ELEVENLABS_API_KEY, PERPLEXITY_API_KEY, PRODUCTION_VOICE_ID, MAX_EPISODE_COST [0.0s]
✓ config_files *: All 3 config files valid [0.0s]
✓ directories *: All 9 directories present [0.0s]

FAILED TESTS SUMMARY
========================================
✗ env_variables (REQUIRED): Missing required variables: OPENROUTER_API_KEY, ELEVENLABS_API_KEY, PERPLEXITY_API_KEY, PRODUCTION_VOICE_ID, MAX_EPISODE_COST

NEXT STEPS
========================================
✗ Production environment is NOT ready for deployment
✗ 1 required tests failed
✗ Address all failed required tests before production use

Required fixes:
  - env_variables: Missing required variables: OPENROUTER_API_KEY, ELEVENLABS_API_KEY, PERPLEXITY_API_KEY, PRODUCTION_VOICE_ID, MAX_EPISODE_COST

After fixing issues, re-run validation:
  python scripts/validate_production.py --comprehensive

================================================================================
Report Generated: 2025-09-01 06:10:29
* = Required test
================================================================================