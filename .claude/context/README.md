# Simple Podcast System

## What This Does
Creates podcast episodes using AI agents.

## How to Use
1. Set up API keys in .env file
2. Run `/podcast "Your Topic"`  
3. Get finished episode

## Agent System
- **researcher**: Finds information using Perplexity
- **writer**: Creates scripts  
- **judge**: Validates quality
- **audio-producer**: Makes audio with ElevenLabs

## Commands
- `/podcast-workflow "topic"`: Create complete episode
- `/research-workflow "topic"`: Research only  
- `/production-workflow episode_num`: Script from research
- `/audio-workflow episode_num`: Audio from script

That's it. Simple and functional.
