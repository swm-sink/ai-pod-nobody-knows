# ElevenLabs WebSocket Streaming Guide (2025)

## 🎯 Purpose of This Document
**For You**: Learn real-time audio streaming - generate audio AS text arrives, not after
**For AI**: Complete WebSocket implementation specifications for low-latency audio generation

---

## 🎓 WebSockets Explained Simply

**Traditional API (like ordering takeout):**
1. You place complete order
2. Wait for everything to cook
3. Get all food at once
4. Total time: 30 minutes

**WebSocket (like a sushi conveyor belt):**
1. Chef starts making pieces immediately
2. You get each piece as it's ready
3. Start eating while more arrives
4. First bite: 2 minutes!

This is CRUCIAL for responsive AI applications!

---

## 🌊 Why Streaming Matters

### Time to First Byte (TTFB)
```
Regular API:
Text (5000 chars) → Wait (3-5 seconds) → Complete Audio

WebSocket Stream:
Text (chunk 1) → Audio (100ms) → Playing while generating rest!
```

### Real-World Impact
- **Conversational AI**: Responses feel instant
- **Live narration**: Start playing before script is complete
- **Interactive podcasts**: Dynamic content adaptation
- **User experience**: 10x perceived speed improvement

---

## 🔌 WebSocket Connection Setup

### Basic Connection
```python
import websocket
import json
import base64

def connect_to_elevenlabs():
    """
    Establish WebSocket connection
    """
    # WebSocket URL with parameters
    voice_id = "21m00Tcm4TlvDq8ikWAM"  # Rachel
    model = "eleven_turbo_v2_5"

    ws_url = (
        f"wss://api.elevenlabs.io/v1/text-to-speech/{voice_id}/stream-input"
        f"?model_id={model}"
    )

    # Headers with authentication
    headers = {
        "xi-api-key": "your_api_key_here"
    }

    # Create connection
    ws = websocket.WebSocketApp(
        ws_url,
        header=headers,
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )

    return ws
```

### Event Handlers
```python
def on_open(ws):
    """Called when connection opens"""
    print("WebSocket connected!")

    # Send initial configuration
    config = {
        "text": " ",  # Start with space to initialize
        "voice_settings": {
            "stability": 0.65,
            "similarity_boost": 0.75
        },
        "generation_config": {
            "chunk_length_schedule": [120, 160, 250]  # Optimized for quality
        }
    }
    ws.send(json.dumps(config))

def on_message(ws, message):
    """Handle incoming audio chunks"""
    data = json.loads(message)

    if data.get("audio"):
        # Decode base64 audio
        audio_chunk = base64.b64decode(data["audio"])
        # Process or play audio chunk
        play_audio_chunk(audio_chunk)

    if data.get("isFinal"):
        print("Audio generation complete!")

def on_error(ws, error):
    """Handle errors"""
    print(f"WebSocket error: {error}")

def on_close(ws, close_status_code, close_msg):
    """Handle connection close"""
    print(f"WebSocket closed: {close_msg}")
```

---

## 🚀 Advanced Streaming Implementation

### Production WebSocket Client
```python
import asyncio
import websockets
import json
import base64
from queue import Queue
import threading

class ElevenLabsStreamer:
    """
    Production-ready WebSocket streaming client
    """

    def __init__(self, api_key, voice_id="21m00Tcm4TlvDq8ikWAM"):
        self.api_key = api_key
        self.voice_id = voice_id
        self.audio_queue = Queue()
        self.is_streaming = False
        self.buffer = ""
        self.chunk_schedule = [120, 160, 250]  # Characters before generation

    async def stream_text(self, text_generator):
        """
        Stream text to ElevenLabs and receive audio
        """
        url = (
            f"wss://api.elevenlabs.io/v1/text-to-speech/{self.voice_id}/stream-input"
            f"?model_id=eleven_turbo_v2_5"
        )

        headers = {"xi-api-key": self.api_key}

        async with websockets.connect(url, extra_headers=headers) as websocket:
            self.is_streaming = True

            # Send initial config
            await self._send_config(websocket)

            # Start audio receiver task
            receiver_task = asyncio.create_task(
                self._receive_audio(websocket)
            )

            # Stream text chunks
            async for text_chunk in text_generator:
                await self._send_text_chunk(websocket, text_chunk)

            # Send final flush
            await self._flush_buffer(websocket)

            # Wait for all audio
            await receiver_task

    async def _send_config(self, websocket):
        """
        Send initial configuration
        """
        config = {
            "text": " ",
            "voice_settings": {
                "stability": 0.65,
                "similarity_boost": 0.75,
                "style": 0.30
            },
            "generation_config": {
                "chunk_length_schedule": self.chunk_schedule
            }
        }
        await websocket.send(json.dumps(config))

    async def _send_text_chunk(self, websocket, text):
        """
        Send text chunk with smart buffering
        """
        self.buffer += text

        # Check if buffer reached threshold
        if len(self.buffer) >= self.chunk_schedule[0]:
            message = {
                "text": self.buffer,
                "flush": False
            }
            await websocket.send(json.dumps(message))
            self.buffer = ""

    async def _flush_buffer(self, websocket):
        """
        Force generate remaining buffered text
        """
        if self.buffer:
            message = {
                "text": self.buffer,
                "flush": True  # Force immediate generation
            }
            await websocket.send(json.dumps(message))
            self.buffer = ""

        # Send end of stream signal
        await websocket.send(json.dumps({"text": ""}))

    async def _receive_audio(self, websocket):
        """
        Receive and queue audio chunks
        """
        try:
            async for message in websocket:
                data = json.loads(message)

                if "audio" in data:
                    audio_chunk = base64.b64decode(data["audio"])
                    self.audio_queue.put(audio_chunk)

                if data.get("isFinal"):
                    self.is_streaming = False
                    break

        except Exception as e:
            print(f"Receive error: {e}")
            self.is_streaming = False

    def get_audio_chunk(self, timeout=0.1):
        """
        Get next audio chunk from queue
        """
        try:
            return self.audio_queue.get(timeout=timeout)
        except:
            return None
```

---

## 🎚️ Buffer Management & Optimization

### Understanding Chunk Length Schedule
```python
# The chunk_length_schedule controls quality vs latency trade-off

# Aggressive (Low latency, lower quality)
AGGRESSIVE = [50, 50, 100, 100]

# Balanced (Good compromise)
BALANCED = [120, 160, 250, 290]

# Quality (Higher latency, better quality)
QUALITY = [250, 350, 450, 500]

def select_chunk_schedule(priority="balanced"):
    """
    Select optimal chunk schedule
    """
    schedules = {
        "speed": [50, 75, 100, 150],      # ~100ms latency
        "balanced": [120, 160, 250, 290],  # ~250ms latency
        "quality": [250, 350, 450, 500]    # ~400ms latency
    }
    return schedules.get(priority, schedules["balanced"])
```

### Dynamic Buffer Adjustment
```python
class AdaptiveBuffering:
    """
    Dynamically adjust buffering based on content
    """

    def __init__(self):
        self.base_schedule = [120, 160, 250, 290]
        self.current_schedule = self.base_schedule.copy()

    def adjust_for_content(self, text):
        """
        Adjust buffer based on content type
        """
        # Shorter buffers for dialogue
        if self._is_dialogue(text):
            self.current_schedule = [80, 120, 160, 200]

        # Longer buffers for narration
        elif self._is_narration(text):
            self.current_schedule = [200, 280, 350, 400]

        # Default for mixed content
        else:
            self.current_schedule = self.base_schedule.copy()

        return self.current_schedule

    def _is_dialogue(self, text):
        """Check if text is dialogue"""
        dialogue_markers = ['"', "'", "said", "asked", "replied"]
        return any(marker in text for marker in dialogue_markers)

    def _is_narration(self, text):
        """Check if text is narration"""
        narration_markers = ["once upon", "the story", "narrator:"]
        return any(marker in text.lower() for marker in narration_markers)
```

---

## 🔄 Keep-Alive & Connection Management

### Connection Maintenance
```python
class ConnectionManager:
    """
    Manage WebSocket connection lifecycle
    """

    def __init__(self, timeout_seconds=20):
        self.timeout = timeout_seconds
        self.last_activity = time.time()
        self.keep_alive_task = None

    async def start_keep_alive(self, websocket):
        """
        Keep connection alive during idle periods
        """
        self.keep_alive_task = asyncio.create_task(
            self._keep_alive_loop(websocket)
        )

    async def _keep_alive_loop(self, websocket):
        """
        Send periodic keep-alive messages
        """
        while True:
            await asyncio.sleep(15)  # Check every 15 seconds

            time_since_activity = time.time() - self.last_activity

            if time_since_activity > 15:
                # Send single space to keep alive
                keep_alive = {"text": " "}
                await websocket.send(json.dumps(keep_alive))
                print("Sent keep-alive")

    def update_activity(self):
        """
        Update last activity timestamp
        """
        self.last_activity = time.time()

    def stop_keep_alive(self):
        """
        Stop keep-alive task
        """
        if self.keep_alive_task:
            self.keep_alive_task.cancel()
```

---

## 🎯 Podcast Streaming Implementation

### Real-Time Podcast Generator
```python
class PodcastStreamer:
    """
    Stream podcast audio in real-time
    """

    def __init__(self, api_key):
        self.streamer = ElevenLabsStreamer(api_key)
        self.audio_player = AudioPlayer()  # Your audio player

    async def stream_episode(self, script_generator):
        """
        Stream episode as it's being generated
        """
        print("Starting real-time podcast stream...")

        # Start streaming task
        stream_task = asyncio.create_task(
            self.streamer.stream_text(script_generator)
        )

        # Start playing audio as it arrives
        play_task = asyncio.create_task(
            self._play_audio_stream()
        )

        # Wait for both to complete
        await asyncio.gather(stream_task, play_task)

        print("Episode streaming complete!")

    async def _play_audio_stream(self):
        """
        Play audio chunks as they arrive
        """
        audio_buffer = []
        min_buffer_size = 3  # Buffer 3 chunks before starting

        while self.streamer.is_streaming or not self.streamer.audio_queue.empty():
            # Get audio chunk
            chunk = self.streamer.get_audio_chunk()

            if chunk:
                audio_buffer.append(chunk)

                # Start playing once we have enough buffered
                if len(audio_buffer) >= min_buffer_size:
                    combined = b''.join(audio_buffer[:min_buffer_size])
                    self.audio_player.play(combined)
                    audio_buffer = audio_buffer[min_buffer_size:]

            await asyncio.sleep(0.01)

        # Play remaining audio
        if audio_buffer:
            self.audio_player.play(b''.join(audio_buffer))
```

---

## 📊 Performance Metrics

### Latency Measurement
```python
class LatencyTracker:
    """
    Track streaming performance metrics
    """

    def __init__(self):
        self.first_text_time = None
        self.first_audio_time = None
        self.chunks_sent = 0
        self.chunks_received = 0

    def mark_text_sent(self):
        """Mark when first text is sent"""
        if not self.first_text_time:
            self.first_text_time = time.time()
        self.chunks_sent += 1

    def mark_audio_received(self):
        """Mark when first audio arrives"""
        if not self.first_audio_time and self.first_text_time:
            self.first_audio_time = time.time()
        self.chunks_received += 1

    def get_ttfb(self):
        """Get Time To First Byte"""
        if self.first_text_time and self.first_audio_time:
            return self.first_audio_time - self.first_text_time
        return None

    def get_metrics(self):
        """Get all metrics"""
        return {
            "ttfb": self.get_ttfb(),
            "chunks_sent": self.chunks_sent,
            "chunks_received": self.chunks_received,
            "efficiency": self.chunks_received / max(self.chunks_sent, 1)
        }
```

---

## 🚨 Error Recovery

### Robust Streaming with Reconnection
```python
class ResilientStreamer:
    """
    Streaming with automatic reconnection
    """

    def __init__(self, api_key, max_retries=3):
        self.api_key = api_key
        self.max_retries = max_retries

    async def stream_with_retry(self, text_generator):
        """
        Stream with automatic retry on failure
        """
        for attempt in range(self.max_retries):
            try:
                streamer = ElevenLabsStreamer(self.api_key)
                await streamer.stream_text(text_generator)
                return  # Success

            except websockets.ConnectionClosed as e:
                print(f"Connection closed: {e}")
                if attempt < self.max_retries - 1:
                    wait_time = 2 ** attempt
                    print(f"Retrying in {wait_time}s...")
                    await asyncio.sleep(wait_time)
                else:
                    raise

            except Exception as e:
                print(f"Streaming error: {e}")
                raise
```

---

## 🎓 Learning Path

### Milestone 1: Basic Streaming
- [ ] Establish WebSocket connection
- [ ] Send text and receive audio
- [ ] Handle connection lifecycle

### Milestone 2: Buffer Management
- [ ] Implement chunk scheduling
- [ ] Add dynamic buffering
- [ ] Optimize for latency

### Milestone 3: Production Features
- [ ] Add keep-alive mechanism
- [ ] Implement reconnection
- [ ] Track performance metrics

---

## 💡 Optimization Tips

### For Your Podcast Project

1. **Pre-buffer Introduction**: Generate intro while loading script
2. **Parallel Streams**: Use multiple connections for segments
3. **Cache Common Audio**: Don't regenerate repeated content
4. **Adaptive Quality**: Adjust buffer based on network speed
5. **Fallback to HTTP**: If WebSocket fails, use regular API

### Network Optimization
```python
# Reuse SSL/TLS sessions for lower latency
session = aiohttp.ClientSession(
    connector=aiohttp.TCPConnector(
        ssl=True,
        use_dns_cache=True,
        ttl_dns_cache=300,
        enable_cleanup_closed=True
    )
)
```

---

## 🔧 Testing WebSockets

### Mock WebSocket Server
```python
import asyncio
import websockets
import json
import base64

async def mock_elevenlabs_server(websocket, path):
    """
    Mock server for testing
    """
    async for message in websocket:
        data = json.loads(message)

        if "text" in data and data["text"]:
            # Send mock audio response
            mock_audio = base64.b64encode(b"mock_audio_data").decode()
            response = {
                "audio": mock_audio,
                "isFinal": False
            }
            await websocket.send(json.dumps(response))

    # Send final message
    await websocket.send(json.dumps({"isFinal": True}))

# Run mock server
start_server = websockets.serve(mock_elevenlabs_server, "localhost", 8765)
asyncio.get_event_loop().run_until_complete(start_server)
```

---

## 🎯 Complete Example

### Streaming Podcast Episode
```python
async def generate_streaming_podcast():
    """
    Complete example: Stream a podcast episode
    """
    api_key = "your_api_key"

    # Script generator (simulating AI generating text)
    async def script_generator():
        segments = [
            "Welcome to Nobody Knows, the podcast about the limits of knowledge.",
            "Today, we explore the paradox of learning:",
            "The more we discover, the more we realize we don't know.",
            "Let's dive into this fascinating topic..."
        ]

        for segment in segments:
            yield segment
            await asyncio.sleep(0.5)  # Simulate generation time

    # Create streamer
    streamer = ElevenLabsStreamer(api_key)

    # Stream the episode
    await streamer.stream_text(script_generator())

    print("Streaming complete!")

# Run
asyncio.run(generate_streaming_podcast())
```

---

## 🔮 Future Considerations

### Coming in 2025
- Multi-voice streaming support
- Enhanced buffer algorithms
- Lower latency models
- Improved error recovery

### Prepare for
- WebSocket protocol updates
- New streaming parameters
- Enhanced audio codecs
- Real-time voice switching

---

*Last Updated: January 2025*
*Based on ElevenLabs WebSocket API v1 documentation*
