Batch produce multiple podcast episodes: $ARGUMENTS

USAGE: /batch:produce [project_name] [topics_file.csv]

CSV FORMAT:
```
episode_number,topic,complexity_level,notes
1,"Introduction to AI",beginner,"Season opener"
2,"Machine Learning Basics",beginner,"Build on episode 1"
3,"Neural Networks",intermediate,"Technical deep dive"
```

BATCH PROCESSING:
1. Parse CSV file for episode topics
2. Optimize production order for efficiency
3. Execute parallel research where possible
4. Sequential script generation with context
5. Batch audio synthesis for cost optimization
6. Aggregate quality reports

OPTIMIZATION FEATURES:
- Parallel research for independent topics
- Shared context for related episodes
- Batch API calls for cost efficiency
- Progressive complexity tracking
- Automatic retry on failures

EXAMPLE:
/batch:produce nobody-knows season1_topics.csv

OUTPUT:
- All episodes in projects/[project]/episodes/
- Batch report at projects/[project]/batch_[timestamp].json
- Updated cost tracking
- Quality summary dashboard