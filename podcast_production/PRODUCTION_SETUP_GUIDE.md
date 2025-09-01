# 🎧 AI Podcast Production - Production Setup Guide

**Version:** 1.0.0 | **Date:** September 2025  
**Target:** Production deployment ready for 2 episodes/week  

This guide walks you through setting up a complete production environment for automated podcast episode generation with comprehensive monitoring and cost controls.

## 🚀 Quick Start (5 Minutes)

### 1. Configure API Keys
```bash
# Copy the template and edit with your keys
cp .env.production.template .env

# Edit .env with your actual API keys
nano .env  # or use your preferred editor
```

**Required API Keys:**
- `OPENROUTER_API_KEY` - For language models
- `ELEVENLABS_API_KEY` - For audio synthesis  
- `PERPLEXITY_API_KEY` - For research and fact-checking

### 2. Run Production Setup
```bash
# Setup and validate the production environment
python3 scripts/setup_production.py --mode=production
```

### 3. Validate Environment  
```bash
# Comprehensive validation (includes API tests)
python3 scripts/validate_production.py --comprehensive
```

### 4. Start Monitoring
```bash
# Test monitoring system
python3 monitoring/production_monitor.py --mode=once
```

### 5. Production Test
```bash
# Run your first episode
python3 main.py --topic "Production System Test"
```

## 📊 Production Features

### 💰 Cost Control & Budget Management
- **Episode Budget:** $5.51 maximum per episode
- **Real-time Cost Tracking:** Penny-precise cost attribution
- **Budget Alerts:** Automatic warnings at 75%, 90%, 100% budget usage
- **Emergency Stops:** Automatic production halt on budget overrun
- **Cost Breakdown:** Detailed cost analysis by component (research, script, audio, validation)

### 🎯 Quality Assurance & Gates
- **Multi-Evaluator Consensus:** Claude + Gemini evaluations with consensus scoring
- **Brand Alignment:** Automated brand consistency validation (≥85%)
- **Technical Accuracy:** Fact-checking and technical content validation (≥90%)
- **Engagement Scoring:** Content engagement and audience appeal metrics (≥80%)
- **Quality Gates:** Automatic rejection of episodes below quality thresholds

### 📈 Real-Time Monitoring & Alerting
- **System Health:** Continuous monitoring of CPU, memory, disk usage
- **Performance Metrics:** Episode production times, success rates, error tracking
- **Cost Monitoring:** Real-time budget utilization and cost trend analysis
- **Quality Trending:** Quality score evolution and degradation detection
- **Multi-Channel Alerts:** Email, Slack, Discord notifications for critical issues

### 🔒 Security & Compliance
- **API Key Security:** Encrypted storage, rotation procedures, access auditing
- **Data Protection:** GDPR compliance, data anonymization, secure deletion
- **Audit Logging:** Comprehensive logging of all production activities
- **Access Control:** Role-based permissions and authentication

### ⚡ High-Performance Architecture
- **LangGraph Workflows:** State-machine based episode production pipeline
- **Parallel Processing:** Concurrent agent execution for faster processing
- **Smart Caching:** Intelligent caching to reduce costs and improve speed
- **Error Recovery:** Automatic retry mechanisms and graceful error handling

## 🛠️ Detailed Setup Instructions

### Prerequisites

**System Requirements:**
- Python 3.11 or higher
- 4GB+ RAM available
- 10GB+ disk space
- Stable internet connection

**Required Services:**
- OpenRouter account with API access
- ElevenLabs account with API access
- Perplexity account with API access

### Step-by-Step Setup

#### 1. Environment Configuration

1. **Copy Environment Template:**
   ```bash
   cp .env.production.template .env
   ```

2. **Configure API Keys:**
   ```bash
   # Edit the .env file with your actual API keys
   nano .env
   ```

   **Required Variables:**
   ```env
   OPENROUTER_API_KEY=sk-or-v1-your-actual-api-key-here
   ELEVENLABS_API_KEY=sk_your-actual-elevenlabs-key-here  
   PERPLEXITY_API_KEY=pplx-your-actual-perplexity-key-here
   PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
   MAX_EPISODE_COST=5.51
   ```

3. **Verify Configuration:**
   ```bash
   # Check that .env is properly ignored by git
   git status  # .env should not appear in untracked files
   ```

#### 2. Production Setup Execution

1. **Run Setup Script:**
   ```bash
   python3 scripts/setup_production.py --mode=production --verbose
   ```

   **What this does:**
   - Validates all environment variables
   - Tests API connectivity with minimal cost
   - Verifies system resources and permissions
   - Initializes cost tracking and monitoring systems
   - Creates necessary directories and log files

2. **Review Setup Report:**
   ```bash
   # Check the setup report
   ls reports/production_setup_report_*.md
   cat reports/production_setup_report_*.md
   ```

#### 3. Comprehensive Validation

1. **Run Full Validation:**
   ```bash
   python3 scripts/validate_production.py --comprehensive
   ```

   **Validation Categories:**
   - **Environment:** API keys, config files, directories
   - **System:** Python version, dependencies, resources
   - **APIs:** Connectivity tests for all required services
   - **Components:** Cost tracker, state manager, workflows
   - **Quality:** Quality gates, brand validation, evaluator consensus
   - **Monitoring:** Health checks, alerting, metrics collection
   - **Security:** API key security, data protection
   - **Performance:** Memory efficiency, response times

2. **Verify Production Ready Status:**
   ```bash
   # Check validation results
   grep -i "production ready" reports/production_validation_report_*.md
   ```

#### 4. Monitoring System Setup

1. **Test Monitoring:**
   ```bash
   python3 monitoring/production_monitor.py --mode=once
   ```

2. **Start Continuous Monitoring (Optional):**
   ```bash
   # For continuous monitoring in production
   nohup python3 monitoring/production_monitor.py --mode=continuous > logs/monitor.log 2>&1 &
   ```

3. **Configure Alerts (Optional):**
   ```bash
   # Add alert webhooks to .env
   echo "SLACK_WEBHOOK=https://hooks.slack.com/your/webhook/url" >> .env
   echo "DISCORD_WEBHOOK=https://discord.com/api/webhooks/your/webhook" >> .env
   ```

#### 5. Production Testing

1. **First Production Episode:**
   ```bash
   python3 main.py --topic "AI Podcast Production System Validation"
   ```

2. **Monitor Execution:**
   ```bash
   # Watch real-time logs
   tail -f logs/podcast_production.log
   
   # Check cost tracking
   tail -f logs/costs.csv
   ```

3. **Verify Results:**
   - Episode completed successfully
   - Cost within budget (≤ $5.51)
   - Quality scores above thresholds
   - Audio output generated (if enabled)

## 📊 Production Dashboard

### Key Metrics to Monitor

**Cost Metrics:**
- Episode cost trend
- Budget utilization percentage
- Cost per component breakdown
- Daily/weekly spend tracking

**Quality Metrics:**
- Overall quality score trend
- Brand alignment scores
- Technical accuracy scores  
- Engagement scores

**Performance Metrics:**
- Episode production success rate
- Average production time
- System resource utilization
- API response times

**System Health:**
- Error rates and types
- Alert frequency and resolution
- System uptime
- Capacity utilization

### Monitoring Commands

```bash
# Real-time system status
python3 monitoring/production_monitor.py --mode=once

# Check recent costs
tail -20 logs/costs.csv

# Review recent quality scores  
ls -la output/*evaluation*.json

# System health check
python3 health_check.py

# Review recent episodes
ls -la outputs/*/reports/
```

## 🚨 Production Operations

### Daily Checklist
- [ ] Check system health status
- [ ] Review overnight episodes and costs
- [ ] Monitor quality score trends
- [ ] Verify monitoring alerts functioning
- [ ] Check disk space and system resources

### Weekly Tasks
- [ ] Review cost and quality trends
- [ ] Analyze performance metrics
- [ ] Update quality thresholds if needed
- [ ] Review and clear old log files
- [ ] Test backup and recovery procedures

### Monthly Maintenance
- [ ] Review and rotate API keys
- [ ] Update system dependencies
- [ ] Perform comprehensive validation
- [ ] Review and update budget limits
- [ ] Conduct security audit

### Emergency Procedures

**Budget Overrun:**
1. Check current running episodes: `ps aux | grep python3`
2. Stop production: `pkill -f main.py`
3. Review cost breakdown: `python3 analyze_costs.py`
4. Investigate cost spike and adjust limits

**Quality Failure:**
1. Review recent quality reports: `ls -la output/*validation*.json`
2. Check evaluator consensus scores
3. Adjust quality thresholds if appropriate
4. Retrain or reconfigure quality gates

**System Failure:**
1. Check system status: `python3 monitoring/production_monitor.py --mode=once`
2. Review error logs: `tail -100 logs/podcast_production.log`
3. Verify API connectivity: `python3 scripts/validate_production.py --category=api`
4. Restart failed components

## 📈 Scaling for Production

### Current Capacity
- **Episodes per day:** 5-10 episodes
- **Episodes per week:** 20-30 episodes  
- **Episodes per month:** 100-120 episodes
- **Cost per episode:** $5.51 target

### Scaling Considerations

**Horizontal Scaling:**
- Multiple production instances
- Load balancing across servers
- Distributed monitoring and alerting

**Vertical Scaling:**  
- Increased system resources
- Larger batch processing
- Enhanced caching strategies

**Cost Optimization:**
- Model selection optimization
- Batch processing efficiency
- Caching and reuse strategies

## 🎯 Success Metrics

### Production Readiness KPIs
- **System Availability:** >99.5%
- **Episode Success Rate:** >95%
- **Cost Compliance:** Episodes within budget >98%
- **Quality Compliance:** Episodes meeting thresholds >90%
- **Mean Time to Recovery:** <15 minutes

### Business Impact Metrics
- **Cost per Episode:** $5.51 (vs $800-3500 traditional)
- **Production Time:** 15-20 minutes per episode
- **Quality Consistency:** ±0.2 score variation
- **Audience Satisfaction:** Quality scores >8.5

## 💡 Tips for Success

### Best Practices
1. **Start Small:** Begin with 1-2 episodes per day
2. **Monitor Closely:** Watch metrics during first week
3. **Iterate Quickly:** Adjust thresholds based on results
4. **Document Everything:** Keep production logs and learnings
5. **Plan for Scale:** Design processes for growth

### Common Issues and Solutions

**High Costs:**
- Review model selection and parameters
- Optimize prompt lengths and complexity
- Implement better caching strategies
- Use more cost-effective models for non-critical components

**Low Quality Scores:**
- Adjust quality thresholds gradually
- Review and improve prompts
- Enhance brand validation rules
- Implement additional quality checks

**System Performance:**
- Monitor resource usage trends
- Optimize slow components
- Implement parallel processing
- Use caching more aggressively

## 🔗 Additional Resources

### Documentation
- [Production Configuration Guide](config/production_config.yaml)
- [Monitoring Setup Guide](monitoring/README.md)
- [Deployment Checklist](deployment/production_checklist.md)
- [API Integration Guide](docs/api-integration.md)

### Tools and Scripts
- **Setup:** `scripts/setup_production.py`
- **Validation:** `scripts/validate_production.py`  
- **Monitoring:** `monitoring/production_monitor.py`
- **Cost Analysis:** `analyze_costs.py`
- **Health Check:** `health_check.py`

### Support
- **Logs Directory:** `logs/` - All system logs
- **Reports Directory:** `reports/` - Validation and setup reports
- **Output Directory:** `output/` - Episode production outputs
- **Config Directory:** `config/` - System configuration files

---

## 🎉 Ready for Production!

Once you complete this setup guide, you'll have a fully-featured, production-ready AI podcast generation system capable of:

✅ **Automated Episode Production** - From topic to finished script  
✅ **Real-time Cost Control** - Stay within $5.51 per episode  
✅ **Quality Assurance** - Multi-evaluator quality gates  
✅ **Comprehensive Monitoring** - Health, performance, and cost tracking  
✅ **Enterprise Security** - API key management and data protection  
✅ **Scalable Architecture** - Ready for 2+ episodes per week  

**Next Steps:**
1. Complete the setup following this guide
2. Run your first production episode
3. Monitor and iterate based on results
4. Scale up to your target production schedule

**Questions or Issues?**
Check the logs, run the validation scripts, and review the deployment checklist for troubleshooting guidance.

---

**Setup Guide Version:** 1.0.0  
**Last Updated:** September 2025  
**Compatible With:** Python 3.11+, LangGraph 0.2+