# ElevenLabs MCP Integration Guide (2025)

## 🎯 Purpose of This Document
**For You**: Connect ElevenLabs directly to Claude Code for seamless voice generation
**For AI**: Complete MCP server specifications and integration patterns

---

## 🎓 MCP Explained Simply

**Model Context Protocol (MCP)** is like USB for AI:
- Plug in any service (ElevenLabs, GitHub, etc.)
- AI assistants can use it immediately
- No complex integration code needed
- Works with Claude Desktop, Cursor, Windsurf

**Why this matters**: Generate voices directly from Claude without writing code!

---

## 🚀 Installation & Setup

### Step 1: Install MCP Server
```bash
# Official ElevenLabs MCP server
npm install -g @elevenlabs/mcp-server

# Or clone from GitHub
git clone https://github.com/elevenlabs/elevenlabs-mcp
cd elevenlabs-mcp
npm install
```

### Step 2: Configure Claude Desktop
```json
// ~/Library/Application Support/Claude/claude_desktop_config.json
{
  "mcpServers": {
    "elevenlabs": {
      "command": "npx",
      "args": ["@elevenlabs/mcp-server"],
      "env": {
        "ELEVENLABS_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

### Step 3: Restart Claude
```bash
# Restart Claude Desktop to load MCP server
# The ElevenLabs icon should appear in Claude's interface
```

---

## 🔧 MCP Capabilities

### Available Functions (2025)
```javascript
MCP_FUNCTIONS = {
  'text_to_speech': 'Generate audio from text',
  'voice_clone': 'Create custom voice from samples',
  'transcribe': 'Convert audio/video to text',
  'voice_design': 'Create AI voice from description',
  'outbound_call': 'Make phone calls with AI voice',
  'list_voices': 'Get available voices',
  'get_usage': 'Check API usage and credits'
}
```

### Direct Claude Commands
```markdown
// In Claude, you can now say:
"Generate audio saying 'Welcome to the podcast' using Rachel's voice"
"Transcribe this audio file: /path/to/recording.mp3"
"Create a voice that sounds warm and intellectual"
"Call this number and order pizza"
```

---

## 🎙️ Podcast Production via MCP

### Workflow Example
```python
# Claude can now execute this workflow directly:

1. User: "Generate Episode 1 audio"
2. Claude via MCP:
   - Reads script from file
   - Selects appropriate voice
   - Generates audio chunks
   - Combines into episode
   - Saves to project folder

# No code writing needed!
```

### MCP Configuration for Podcasts
```json
{
  "mcpServers": {
    "elevenlabs": {
      "command": "npx",
      "args": ["@elevenlabs/mcp-server"],
      "env": {
        "ELEVENLABS_API_KEY": "your_key",
        "DEFAULT_VOICE": "Rachel",
        "DEFAULT_MODEL": "eleven_turbo_v2_5",
        "OUTPUT_FORMAT": "mp3_44100_128",
        "PODCAST_MODE": "true"
      }
    }
  }
}
```

---

## 📡 Advanced MCP Features

### Custom MCP Commands
```javascript
// Create custom podcast commands
// File: .claude/mcp/podcast_commands.js

export const commands = {
  'generate_episode': async (params) => {
    const { script, episode_num, voice } = params;
    
    // Use ElevenLabs MCP to generate
    const audio = await mcp.elevenlabs.textToSpeech({
      text: script,
      voice: voice || 'Rachel',
      model: 'eleven_turbo_v2_5'
    });
    
    // Save with episode number
    const filename = `episode_${episode_num}.mp3`;
    await fs.writeFile(filename, audio);
    
    return `Episode ${episode_num} generated: ${filename}`;
  },
  
  'batch_generate': async (params) => {
    const { episodes } = params;
    const results = [];
    
    for (const ep of episodes) {
      const result = await commands.generate_episode(ep);
      results.push(result);
    }
    
    return results;
  }
};
```

### MCP + Claude Code Integration
```python
# Your Python code can trigger MCP commands

import subprocess
import json

def call_mcp_elevenlabs(command, params):
    """
    Call ElevenLabs via MCP from Python
    """
    mcp_request = {
        'command': command,
        'params': params
    }
    
    result = subprocess.run(
        ['claude', 'mcp', 'elevenlabs', json.dumps(mcp_request)],
        capture_output=True,
        text=True
    )
    
    return json.loads(result.stdout)

# Generate audio via MCP
audio_result = call_mcp_elevenlabs('text_to_speech', {
    'text': 'Hello from Python via MCP!',
    'voice': 'Rachel'
})
```

---

## 🔄 Bidirectional Communication

### Claude → ElevenLabs → Claude
```mermaid
1. Claude receives user request
2. Claude calls ElevenLabs MCP
3. ElevenLabs generates audio
4. MCP returns audio data
5. Claude saves/processes audio
6. Claude reports to user
```

### Real-Time Feedback Loop
```javascript
// MCP server with progress updates
const mcpServer = {
  textToSpeech: async (params, callback) => {
    const chunks = splitIntoChunks(params.text);
    const results = [];
    
    for (let i = 0; i < chunks.length; i++) {
      // Send progress update to Claude
      callback({
        type: 'progress',
        current: i + 1,
        total: chunks.length
      });
      
      const audio = await generateChunk(chunks[i]);
      results.push(audio);
    }
    
    return combineAudio(results);
  }
};
```

---

## 🎯 MCP for Your Project

### Specific Setup for "Nobody Knows"
```json
// Enhanced MCP configuration for your podcast
{
  "mcpServers": {
    "elevenlabs": {
      "command": "npx",
      "args": ["@elevenlabs/mcp-server"],
      "env": {
        "ELEVENLABS_API_KEY": "${ELEVENLABS_API_KEY}",
        "PROJECT_NAME": "nobody_knows_podcast",
        "DEFAULT_VOICE": "Rachel",
        "BACKUP_VOICE": "Antoni",
        "MODEL_PRODUCTION": "eleven_v3_alpha",
        "MODEL_DRAFT": "eleven_flash_v2_5",
        "CACHE_ENABLED": "true",
        "CACHE_DIR": "./projects/nobody_knows/cache"
      }
    }
  }
}
```

### Claude Slash Commands
```markdown
// Custom commands for your podcast
/generate-episode <number> - Generate specific episode
/test-voices <text> - Test different voices
/check-costs - Show current spending
/batch-generate <start> <end> - Generate multiple episodes
```

---

## 🛠️ Troubleshooting MCP

### Common Issues & Solutions
```python
MCP_TROUBLESHOOTING = {
    'server_not_starting': {
        'check': 'Is API key set correctly?',
        'fix': 'Export ELEVENLABS_API_KEY or add to config'
    },
    'commands_not_working': {
        'check': 'Is MCP server running?',
        'fix': 'Restart Claude Desktop'
    },
    'slow_response': {
        'check': 'Network connection?',
        'fix': 'Check rate limits and connection'
    },
    'no_audio_output': {
        'check': 'Permissions and paths?',
        'fix': 'Ensure write permissions for output directory'
    }
}
```

### Debug Mode
```bash
# Enable verbose logging
export MCP_DEBUG=true
export ELEVENLABS_DEBUG=true

# Check MCP server status
claude mcp status

# Test MCP connection
claude mcp test elevenlabs
```

---

## 🔮 Future MCP Features

### Coming Soon (2025)
- Streaming audio support via MCP
- Voice training through MCP
- Real-time voice conversion
- Multi-voice conversations
- Automatic transcription sync

### Prepare Your Setup
```javascript
// Future-proof configuration
{
  "mcpServers": {
    "elevenlabs": {
      "version": "2.0",  // Ready for v2
      "features": {
        "streaming": true,
        "voice_training": true,
        "real_time": true
      }
    }
  }
}
```

---

## 💡 Pro Tips

1. **Use Environment Variables**: Don't hardcode API keys
2. **Enable Caching**: MCP can cache common responses
3. **Monitor Usage**: MCP tracks API calls automatically
4. **Batch Operations**: MCP handles concurrency well
5. **Custom Shortcuts**: Create project-specific commands

---

## 🎓 Learning Path

### Step 1: Basic MCP
- Install and configure
- Test simple commands
- Generate first audio

### Step 2: Integration
- Connect to your project
- Create custom commands
- Automate workflows

### Step 3: Advanced
- Build complex pipelines
- Add error handling
- Optimize performance

---

*Last Updated: January 2025*
*Based on official ElevenLabs MCP server documentation*