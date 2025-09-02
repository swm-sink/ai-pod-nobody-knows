#!/usr/bin/env python3
"""
Direct ElevenLabs API Integration for Episode 1 Audio Synthesis
Production-Ready Implementation with Comprehensive Error Handling
"""

from config.voice_config import get_production_voice_id

import requests
import json
import time
import os
import re
import subprocess
from pathlib import Path
from datetime import datetime

class ElevenLabsDirectAPI:
    """Production-grade ElevenLabs API client with intelligent chunking and error handling"""

    def __init__(self, api_key: str, voice_id: str = get_production_voice_id()):
        """
        Initialize ElevenLabs client with Amelia voice

        Args:
            api_key: ElevenLabs API key (from environment variable for security)
            voice_id: Production voice ID from configuration
        """
        if not api_key:
            raise ValueError("API key is required for TTS synthesis")

        self.api_key = api_key
        self.voice_id = voice_id  # Amelia - young and enthusiastic
        self.base_url = "https://api.elevenlabs.io/v1"
        self.headers = {
            "xi-api-key": self.api_key,
            "Content-Type": "application/json"
        }

        # Production-optimized settings for Amelia voice
        self.voice_settings = {
            "stability": 0.65,
            "similarity_boost": 0.8,
            "style": 0.3,
            "use_speaker_boost": True
        }

        print(f"✅ ElevenLabs client initialized")
        print(f"   Voice: Production voice ({self.voice_id})")
        print(f"   Settings: Stability={self.voice_settings['stability']}, Similarity={self.voice_settings['similarity_boost']}")

    def validate_api_key(self):
        """Validate API key before processing"""
        try:
            response = requests.get(
                f"{self.base_url}/voices",
                headers={"xi-api-key": self.api_key},
                timeout=10
            )
            if response.status_code == 200:
                print("✅ API key validation successful")
                return {"success": True}
            else:
                return {"success": False, "error": f"API validation failed: {response.status_code}"}
        except Exception as e:
            return {"success": False, "error": f"API validation error: {str(e)}"}

    def chunk_large_text(self, text: str, max_chunk_size: int = 800) -> list:
        """
        Intelligently chunk large SSML text preserving markup structure

        Args:
            text: SSML formatted text
            max_chunk_size: Maximum characters per chunk

        Returns:
            List of SSML chunks
        """
        print(f"📝 Chunking script: {len(text)} characters")

        # Remove XML declaration and root speak tags for processing
        text_content = text.strip()
        if text_content.startswith('<?xml'):
            text_content = re.sub(r'<\?xml.*?\?>', '', text_content, flags=re.DOTALL)

        # Extract content between <speak> tags
        speak_match = re.search(r'<speak>(.*)</speak>', text_content, re.DOTALL)
        if speak_match:
            inner_content = speak_match.group(1).strip()
        else:
            inner_content = text_content

        chunks = []
        current_chunk = ""

        # Split on natural SSML break points
        segments = re.split(r'(</prosody>|<break time="[^"]*"/>)', inner_content)

        for i, segment in enumerate(segments):
            segment = segment.strip()
            if not segment:
                continue

            # Check if adding this segment exceeds chunk size
            if len(current_chunk) + len(segment) <= max_chunk_size:
                current_chunk += segment + " "
            else:
                if current_chunk.strip():
                    # Wrap in speak tags for synthesis
                    chunks.append(f'<speak>{current_chunk.strip()}</speak>')
                current_chunk = segment + " "

        # Add final chunk
        if current_chunk.strip():
            chunks.append(f'<speak>{current_chunk.strip()}</speak>')

        print(f"📊 Created {len(chunks)} chunks")
        for i, chunk in enumerate(chunks):
            print(f"   Chunk {i+1}: {len(chunk)} characters")

        return chunks

    def synthesize_chunk(self, text: str, output_path: str, model_id: str = "eleven_turbo_v2_5") -> dict:
        """
        Synthesize single text chunk to audio

        Args:
            text: SSML formatted text chunk
            output_path: Output file path
            model_id: ElevenLabs model to use

        Returns:
            Dictionary with success status and metadata
        """
        payload = {
            "text": text,
            "model_id": model_id,
            "voice_settings": self.voice_settings
        }

        try:
            print(f"🎤 Synthesizing chunk ({len(text)} chars)...")

            response = requests.post(
                f"{self.base_url}/text-to-speech/{self.voice_id}",
                headers=self.headers,
                json=payload,
                timeout=300
            )

            if response.status_code == 200:
                with open(output_path, 'wb') as f:
                    f.write(response.content)

                file_size = len(response.content)
                print(f"✅ Synthesis successful: {file_size} bytes saved to {output_path}")
                return {
                    "success": True,
                    "file_path": output_path,
                    "size": file_size,
                    "characters": len(text)
                }

            elif response.status_code == 401:
                return {"success": False, "error": "Authentication failed - check API key"}

            elif response.status_code == 429:
                print("⚠️ Rate limit hit, implementing backoff...")
                time.sleep(5)  # Simple backoff
                return {"success": False, "error": "Rate limit exceeded - retry needed"}

            elif response.status_code == 422:
                return {"success": False, "error": f"Invalid SSML input: {response.text}"}

            else:
                return {"success": False, "error": f"API error: {response.status_code} - {response.text}"}

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": f"Network error: {str(e)}"}

    def synthesize_episode(self, script_path: str, output_directory: str, episode_name: str = "episode_1") -> dict:
        """
        Synthesize complete episode with chunking and concatenation

        Args:
            script_path: Path to SSML script file
            output_directory: Directory for output files
            episode_name: Episode identifier

        Returns:
            Synthesis results with detailed logging
        """
        print(f"\n🚀 Starting Episode Synthesis: {episode_name}")
        print(f"   Script: {script_path}")
        print(f"   Output: {output_directory}")

        # Read TTS-optimized script
        try:
            if not os.path.exists(script_path):
                return {"success": False, "error": f"Script file not found: {script_path}"}

            with open(script_path, 'r', encoding='utf-8') as f:
                script_content = f.read()

            if not script_content.strip():
                return {"success": False, "error": "Script file is empty"}

        except PermissionError:
            return {"success": False, "error": f"Permission denied reading script: {script_path}"}
        except UnicodeDecodeError as e:
            return {"success": False, "error": f"Script encoding error: {str(e)}"}
        except Exception as e:
            return {"success": False, "error": f"Script read error: {str(e)}"}

        print(f"📄 Script loaded: {len(script_content)} characters")

        # Create output directory
        os.makedirs(output_directory, exist_ok=True)

        # Chunk the script intelligently
        chunks = self.chunk_large_text(script_content)

        # Synthesis tracking
        synthesis_log = {
            "episode_name": episode_name,
            "script_path": script_path,
            "total_chunks": len(chunks),
            "total_characters": len(script_content),
            "chunks_synthesized": 0,
            "failed_chunks": [],
            "audio_files": [],
            "errors": [],
            "start_time": datetime.now().isoformat(),
            "estimated_cost": len(script_content) / 1000 * 0.18  # $0.18 per 1k chars
        }

        print(f"💰 Estimated cost: ${synthesis_log['estimated_cost']:.2f}")

        # Synthesize each chunk
        audio_files = []

        for i, chunk in enumerate(chunks):
            chunk_filename = f"{episode_name}_chunk_{i+1:03d}.mp3"
            chunk_path = os.path.join(output_directory, chunk_filename)

            print(f"\n📍 Processing chunk {i+1}/{len(chunks)}")

            # Synthesize with retry logic
            max_retries = 3
            for attempt in range(max_retries):
                result = self.synthesize_chunk(chunk, chunk_path)

                if result["success"]:
                    audio_files.append(chunk_path)
                    synthesis_log["chunks_synthesized"] += 1
                    synthesis_log["audio_files"].append({
                        "chunk_number": i+1,
                        "file_path": chunk_path,
                        "file_size": result["size"],
                        "characters": result["characters"]
                    })
                    break
                else:
                    print(f"❌ Attempt {attempt+1} failed: {result['error']}")
                    if attempt < max_retries - 1:
                        print(f"🔄 Retrying in {2**attempt} seconds...")
                        time.sleep(2**attempt)  # Exponential backoff
                    else:
                        synthesis_log["failed_chunks"].append(i+1)
                        synthesis_log["errors"].append({
                            "chunk_number": i+1,
                            "error": result["error"]
                        })

            # Rate limiting - pause between chunks
            if i < len(chunks) - 1:  # Don't wait after last chunk
                time.sleep(1.5)

        synthesis_log["end_time"] = datetime.now().isoformat()

        # Concatenate audio files if all successful
        if synthesis_log["chunks_synthesized"] == len(chunks):
            print(f"\n🔗 Concatenating {len(audio_files)} audio files...")
            final_audio_path = os.path.join(output_directory, f"{episode_name}_final.mp3")

            concat_result = self.concatenate_audio_files(audio_files, final_audio_path)
            if concat_result:
                synthesis_log["final_audio_path"] = final_audio_path
                synthesis_log["success"] = True
                print(f"🎯 Episode synthesis complete: {final_audio_path}")
            else:
                synthesis_log["success"] = False
                synthesis_log["errors"].append("Audio concatenation failed")
        else:
            synthesis_log["success"] = False
            print(f"❌ Synthesis incomplete: {synthesis_log['chunks_synthesized']}/{len(chunks)} chunks successful")

        # Save synthesis log
        log_path = os.path.join(output_directory, f"{episode_name}_synthesis_log.json")
        with open(log_path, 'w') as f:
            json.dump(synthesis_log, f, indent=2)

        print(f"📊 Synthesis log saved: {log_path}")

        return synthesis_log

    def concatenate_audio_files(self, audio_files: list, output_path: str) -> bool:
        """
        Concatenate multiple audio files using ffmpeg

        Args:
            audio_files: List of audio file paths
            output_path: Final concatenated file path

        Returns:
            True if successful, False otherwise
        """
        if not audio_files:
            print("❌ No audio files to concatenate")
            return False

        # Create ffmpeg concat file
        concat_file = output_path.replace('.mp3', '_concat_list.txt')

        try:
            with open(concat_file, 'w') as f:
                for audio_file in audio_files:
                    f.write(f"file '{audio_file}'\n")

            # Use ffmpeg to concatenate
            concat_command = [
                "ffmpeg", "-f", "concat", "-safe", "0",
                "-i", concat_file, "-c", "copy", output_path, "-y"
            ]

            print("🔗 Running ffmpeg concatenation...")
            result = subprocess.run(concat_command, capture_output=True, text=True)

            if result.returncode == 0:
                print(f"✅ Audio concatenation successful")

                # Get final file info
                file_size = os.path.getsize(output_path)
                print(f"📁 Final audio: {output_path} ({file_size} bytes)")

                # Clean up individual chunk files and concat list
                for audio_file in audio_files:
                    os.remove(audio_file)
                os.remove(concat_file)

                print("🧹 Cleanup completed - individual chunks removed")
                return True
            else:
                print(f"❌ FFmpeg error: {result.stderr}")
                return False

        except Exception as e:
            print(f"❌ Concatenation error: {str(e)}")
            return False


def load_production_config():
    """Load production configuration from central config file"""
    try:
        config_path = os.path.join(os.path.dirname(__file__), ".claude", "config", "production-voice.json")
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = json.load(f)
            return config.get("production_voice", {})
    except Exception as e:
        print(f"⚠️ Could not load central config: {e}")

    # Fallback to hardcoded values
    return {
        "voice_id": get_production_voice_id(),
        "voice_name": "Amelia",
        "settings": {
            "stability": 0.65,
            "similarity_boost": 0.8,
            "style": 0.3,
            "use_speaker_boost": True,
            "model_id": "eleven_turbo_v2_5"
        }
    }

def main():
    """Main execution function for Episode 1 synthesis"""
    print("🎙️ Episode 1 TTS Synthesis - Direct API Integration")
    print("=" * 60)

    # Get API key from environment variable (security best practice)
    api_key = os.getenv('ELEVENLABS_API_KEY')
    if not api_key:
        print("❌ ELEVENLABS_API_KEY environment variable not set")
        print("   Please run: export ELEVENLABS_API_KEY=your_api_key")
        return

    # Load central configuration
    config = load_production_config()
    voice_id = config.get("voice_id", get_production_voice_id())

    print(f"🔧 Using voice: {config.get('voice_name', 'Amelia')} ({voice_id})")

    # Configuration paths
    SCRIPT_PATH = "/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/sessions/ep_001_production_20250824_231505/production/tts_optimized_script.ssml"
    OUTPUT_DIR = "/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/sessions/ep_001_production_20250824_231505/audio_direct_api"

    # Initialize client
    client = ElevenLabsDirectAPI(api_key, voice_id)

    # Validate API key
    validation = client.validate_api_key()
    if not validation["success"]:
        print(f"❌ API validation failed: {validation['error']}")
        return

    # Synthesize episode
    result = client.synthesize_episode(SCRIPT_PATH, OUTPUT_DIR, "episode_1_direct_api")

    # Report results
    print("\n" + "=" * 60)
    print("📊 SYNTHESIS RESULTS")
    print("=" * 60)

    if result["success"]:
        print("🎯 Status: SUCCESS")
        print(f"📁 Final audio: {result.get('final_audio_path', 'N/A')}")
        print(f"📊 Chunks processed: {result['chunks_synthesized']}/{result['total_chunks']}")
        print(f"💰 Estimated cost: ${result['estimated_cost']:.2f}")
        print(f"⏱️ Duration: {result['start_time']} to {result['end_time']}")
    else:
        print("❌ Status: FAILED")
        print(f"📊 Chunks processed: {result['chunks_synthesized']}/{result['total_chunks']}")
        if result.get('errors'):
            print("🚨 Errors:")
            for error in result['errors']:
                print(f"   - {error}")

    print("=" * 60)


if __name__ == "__main__":
    main()
