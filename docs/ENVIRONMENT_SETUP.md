# Environment Setup Guide

## Quick Start

1. **Copy the template:**
   ```bash
   cp .env.production.template .env.production
   ```

2. **Configure your API keys:**
   Edit `.env.production` and replace all `YOUR_*_KEY_HERE` placeholders with your actual API keys.

3. **Validate configuration:**
   ```bash
   python3 validate_environment.py
   ```

4. **Test the system:**
   ```bash
   python3 setup_production_database.py
   python3 -c "from tests.integration import validate_production_system; validate_production_system.main()"
   ```

## Required API Keys

### OpenAI API Key
- Sign up at: https://platform.openai.com/
- Create API key in dashboard
- Set `OPENAI_API_KEY=sk-proj-your-key-here`

### Anthropic API Key
- Sign up at: https://console.anthropic.com/
- Generate API key
- Set `ANTHROPIC_API_KEY=sk-ant-your-key-here`

### Perplexity API Key
- Sign up at: https://www.perplexity.ai/
- Get API access
- Set `PERPLEXITY_API_KEY=pplx-your-key-here`

### ElevenLabs API Key
- Sign up at: https://elevenlabs.io/
- Get API key from profile
- Set `ELEVENLABS_API_KEY=your-key-here`

### Langfuse (Optional - for observability)
- Sign up at: https://langfuse.com/
- Create project and get keys
- Set `LANGFUSE_PUBLIC_KEY` and `LANGFUSE_SECRET_KEY`

## Database Setup

### Development (SQLite - No setup required)
The system will automatically create a SQLite database for development.

### Production (PostgreSQL - Required)
1. **Using Docker (Recommended):**
   ```bash
   cd production/database
   ./setup.sh
   ```

2. **Using existing PostgreSQL:**
   Configure `POSTGRES_URL` in `.env.production`

## Security Best Practices

1. **Never commit .env files to version control**
2. **Use strong passwords for database connections**
3. **Enable SSL for production database connections**
4. **Rotate API keys regularly**
5. **Use environment-specific configurations**

## Environment Files

- `.env.production` - Production configuration (never commit!)
- `.env.development` - Development configuration (git-ignored)
- `.env.production.template` - Template with all variables (can commit)

## Validation

Run the validation script to ensure your environment is properly configured:

```bash
python3 validate_environment.py
```

This will check:
- Database connectivity
- API key presence
- Cost control settings
- Quality thresholds
- Observability configuration

## Troubleshooting

### Database Connection Issues
1. Check `POSTGRES_URL` format
2. Verify database server is running
3. Ensure SSL settings match your server
4. Test with: `python3 setup_production_database.py`

### API Key Issues
1. Verify keys are not expired
2. Check API quotas and billing
3. Ensure keys have required permissions
4. Test individual APIs if needed

### Cost Control Issues
1. Set `MAX_EPISODE_COST=5.51` for production
2. Enable `COST_TRACKING_ENABLED=true`
3. Set `BUDGET_ENFORCEMENT_MODE=strict`

### Quality Issues
1. Set `QUALITY_THRESHOLD=8.0` for production
2. Enable `QUALITY_VALIDATION_REQUIRED=true`
3. Ensure evaluators are configured

## Production Checklist

Before deploying to production:

- [ ] All API keys configured and tested
- [ ] PostgreSQL database setup and accessible
- [ ] Cost controls enabled and tested
- [ ] Quality thresholds set appropriately
- [ ] Observability configured (Langfuse)
- [ ] Environment validation passes (90%+)
- [ ] Voice ID configured and validated
- [ ] Backup and monitoring configured
- [ ] Security settings reviewed

## Support

If you encounter issues:
1. Run `python3 validate_environment.py` for diagnostics
2. Check the troubleshooting section above
3. Review logs for specific error messages
4. Consult the main CLAUDE.md documentation

Generated on 2025-09-01 15:45:56 UTC
