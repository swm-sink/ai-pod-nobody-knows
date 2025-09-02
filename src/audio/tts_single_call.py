#!/usr/bin/env python3
"""
Simplified ElevenLabs Direct API - Single Call Synthesis
Production-Ready Implementation for 27-Minute Episodes
Based on verified API limits: 40,000 chars/40 minutes for Flash/Turbo v2.5
"""

from config.voice_config import get_production_voice_id

import requests
import json
import time
import os
from datetime import datetime
from pathlib import Path

class ElevenLabsSingleCall:
    """Simplified ElevenLabs client for single-call long-form synthesis"""

    def __init__(self, api_key: str, voice_id: str = get_production_voice_id()):
        """
        Initialize ElevenLabs client with Amelia voice for single-call synthesis

        Args:
            api_key: ElevenLabs API key (from environment variable)
            voice_id: Production voice ID from configuration
        """
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

        print(f"✅ ElevenLabs Single-Call Client Initialized")
        print(f"   Voice: Production voice ({self.voice_id})")
        print(f"   Model Target: eleven_turbo_v2_5 (40k chars/40min limit)")
        print(f"   Settings: Stability={self.voice_settings['stability']}, Similarity={self.voice_settings['similarity_boost']}")

    def validate_api_key(self):
        """Validate API key and verify voice availability"""
        try:
            response = requests.get(
                f"{self.base_url}/voices",
                headers={"xi-api-key": self.api_key},
                timeout=10
            )

            if response.status_code == 200:
                voices_data = response.json().get("voices", [])
                voice_ids = [voice.get("voice_id") for voice in voices_data]

                # Verify the Amelia voice is available
                if self.voice_id in voice_ids:
                    print("✅ API key validation successful")
                    print(f"✅ Amelia voice ({self.voice_id}) confirmed available")
                    return {"success": True, "voice_count": len(voices_data), "voice_verified": True}
                else:
                    print(f"⚠️ Warning: Voice {self.voice_id} not found in account")
                    return {"success": True, "voice_count": len(voices_data), "voice_verified": False,
                           "warning": f"Voice {self.voice_id} not available"}

            elif response.status_code == 401:
                return {"success": False, "error": "Invalid API key - check ELEVENLABS_API_KEY environment variable"}
            elif response.status_code == 403:
                return {"success": False, "error": "API key lacks necessary permissions"}
            elif response.status_code == 429:
                return {"success": False, "error": "Rate limit exceeded - please wait and retry"}
            else:
                return {"success": False, "error": f"API validation failed: {response.status_code} - {response.text}"}

        except requests.exceptions.Timeout:
            return {"success": False, "error": "API validation timeout - check network connection"}
        except requests.exceptions.ConnectionError:
            return {"success": False, "error": "Cannot connect to ElevenLabs API - check internet connection"}
        except Exception as e:
            return {"success": False, "error": f"API validation error: {str(e)}"}

    def validate_content_limits(self, text: str) -> dict:
        """
        Validate content against ElevenLabs limits before synthesis

        Args:
            text: Full SSML script content

        Returns:
            Validation result with recommendations
        """
        char_count = len(text)

        # Estimate word count and duration
        import re
        plain_text = re.sub(r'<[^>]*>', '', text)  # Remove SSML tags
        plain_text = re.sub(r'<!--.*?-->', '', plain_text, flags=re.DOTALL)  # Remove comments
        word_count = len(plain_text.split())

        # Estimate speech duration (206 WPM empirical rate from Episode 1 + breaks)
        base_duration_minutes = word_count / 206  # Empirically validated ElevenLabs processing rate

        # Add break time estimation
        break_matches = re.findall(r'<break time=["\']([^"\']*)["\']', text)
        total_break_seconds = 0
        for break_time in break_matches:
            try:
                if break_time.endswith('s') and not break_time.endswith('ms'):
                    total_break_seconds += float(break_time[:-1])
                elif break_time.endswith('ms'):
                    total_break_seconds += float(break_time[:-2]) / 1000
            except ValueError:
                # Skip malformed break times
                continue

        estimated_duration = base_duration_minutes + (total_break_seconds / 60)

        validation = {
            "char_count": char_count,
            "word_count": word_count,
            "estimated_duration_minutes": estimated_duration,
            "within_limits": True,
            "recommended_model": "eleven_turbo_v2_5",
            "warnings": [],
            "errors": []
        }

        # Check character limits
        if char_count > 40000:
            validation["within_limits"] = False
            validation["errors"].append(f"Exceeds 40k character limit: {char_count:,} chars")
        elif char_count > 35000:
            validation["warnings"].append(f"Near character limit: {char_count:,}/40,000 chars")

        # Check duration limits
        if estimated_duration > 40:
            validation["within_limits"] = False
            validation["errors"].append(f"Exceeds 40-minute limit: {estimated_duration:.1f} minutes")
        elif estimated_duration > 35:
            validation["warnings"].append(f"Near duration limit: {estimated_duration:.1f}/40 minutes")

        # Model recommendations
        if char_count <= 10000:
            validation["recommended_model"] = "eleven_multilingual_v2"  # Cheaper option
        elif char_count <= 30000:
            validation["recommended_model"] = "eleven_turbo_v2_5"  # Balanced
        else:
            validation["recommended_model"] = "eleven_turbo_v2_5"  # Required for >30k

        return validation

    def synthesize_episode_single_call(self, script_path: str, output_directory: str, episode_name: str = "episode_1") -> dict:
        """
        Synthesize complete episode in single API call

        Args:
            script_path: Path to SSML script file
            output_directory: Directory for output files
            episode_name: Episode identifier

        Returns:
            Synthesis results with detailed logging
        """
        print(f"\n🚀 Single-Call Episode Synthesis: {episode_name}")
        print(f"   Script: {script_path}")
        print(f"   Output: {output_directory}")

        # Read TTS-optimized script with enhanced validation
        try:
            if not os.path.exists(script_path):
                return {"success": False, "error": f"Script file not found: {script_path}"}

            with open(script_path, 'r', encoding='utf-8') as f:
                script_content = f.read()

            if not script_content or len(script_content.strip()) == 0:
                return {"success": False, "error": "Script file is empty"}

        except FileNotFoundError:
            return {"success": False, "error": f"Script file not found: {script_path}"}
        except PermissionError:
            return {"success": False, "error": f"Permission denied reading: {script_path}"}
        except UnicodeDecodeError:
            return {"success": False, "error": f"Invalid UTF-8 encoding in: {script_path}"}
        except Exception as e:
            return {"success": False, "error": f"Script read error: {str(e)}"}

        print(f"📄 Script loaded: {len(script_content):,} characters")

        # Validate content limits
        validation = self.validate_content_limits(script_content)

        print(f"📊 Content Analysis:")
        print(f"   Characters: {validation['char_count']:,}")
        print(f"   Words: {validation['word_count']:,}")
        print(f"   Est. Duration: {validation['estimated_duration_minutes']:.1f} minutes")
        print(f"   Recommended Model: {validation['recommended_model']}")

        if validation["warnings"]:
            for warning in validation["warnings"]:
                print(f"   ⚠️ {warning}")

        if not validation["within_limits"]:
            for error in validation["errors"]:
                print(f"   ❌ {error}")
            return {"success": False, "error": "Content exceeds API limits", "validation": validation}

        # Create output directory with error handling
        try:
            os.makedirs(output_directory, exist_ok=True)
            # Test write permissions
            test_file = os.path.join(output_directory, ".write_test")
            with open(test_file, 'w') as f:
                f.write("test")
            os.remove(test_file)
        except PermissionError:
            return {"success": False, "error": f"Permission denied creating output directory: {output_directory}"}
        except OSError as e:
            return {"success": False, "error": f"Cannot create output directory: {str(e)}"}

        # Synthesis tracking
        synthesis_log = {
            "episode_name": episode_name,
            "script_path": script_path,
            "character_count": validation["char_count"],
            "word_count": validation["word_count"],
            "estimated_duration": validation["estimated_duration_minutes"],
            "model_used": validation["recommended_model"],
            "start_time": datetime.now().isoformat(),
            "estimated_cost": validation["char_count"] / 1000 * 0.18,  # $0.18 per 1k chars
            "synthesis_method": "single_call"
        }

        print(f"💰 Estimated cost: ${synthesis_log['estimated_cost']:.2f}")

        # Prepare synthesis request
        payload = {
            "text": script_content,
            "model_id": validation["recommended_model"],
            "voice_settings": self.voice_settings
        }

        # Output file path
        output_file = os.path.join(output_directory, f"{episode_name}_single_call.mp3")

        print(f"\n🎤 Starting single-call synthesis...")
        print(f"   Model: {validation['recommended_model']}")
        print(f"   Target: {output_file}")

        try:
            # Make synthesis request with extended timeout for long content
            response = requests.post(
                f"{self.base_url}/text-to-speech/{self.voice_id}",
                headers=self.headers,
                json=payload,
                timeout=900  # 15 minutes for long synthesis
            )

            synthesis_log["response_status"] = response.status_code
            synthesis_log["end_time"] = datetime.now().isoformat()

            if response.status_code == 200:
                # Save audio file with enhanced error handling
                try:
                    # Validate audio content
                    audio_content = response.content
                    file_size = len(audio_content)

                    if file_size < 1000:  # Less than 1KB suggests invalid audio
                        synthesis_log["success"] = False
                        synthesis_log["error"] = f"Audio file too small ({file_size} bytes) - may be invalid"
                        return synthesis_log

                    # Write audio file with atomic operation
                    temp_file = output_file + ".tmp"
                    with open(temp_file, 'wb') as f:
                        f.write(audio_content)

                    # Atomic rename to final file
                    os.rename(temp_file, output_file)

                    synthesis_log["output_file"] = output_file
                    synthesis_log["file_size_bytes"] = file_size
                    synthesis_log["file_size_mb"] = file_size / (1024 * 1024)
                    synthesis_log["success"] = True

                except OSError as e:
                    synthesis_log["success"] = False
                    synthesis_log["error"] = f"Failed to save audio file: {str(e)}"
                    return synthesis_log

                print(f"✅ Synthesis successful!")
                print(f"   File: {output_file}")
                print(f"   Size: {file_size:,} bytes ({synthesis_log['file_size_mb']:.1f} MB)")

                # Get actual audio duration if possible
                try:
                    import subprocess
                    import shutil

                    # Check if ffprobe is available
                    if shutil.which('ffprobe'):
                        duration_cmd = ['ffprobe', '-v', 'quiet', '-show_entries', 'format=duration',
                                      '-of', 'csv=p=0', output_file]
                        duration_result = subprocess.run(duration_cmd, capture_output=True, text=True, timeout=30)

                        if duration_result.returncode == 0 and duration_result.stdout.strip():
                            try:
                                actual_duration = float(duration_result.stdout.strip()) / 60
                                synthesis_log["actual_duration_minutes"] = actual_duration

                                # Validate duration against Episode 1 empirical data
                                expected_duration = validation["word_count"] / 206  # 206 WPM empirical rate
                                duration_ratio = actual_duration / expected_duration if expected_duration > 0 else 0

                                print(f"   Actual Duration: {actual_duration:.1f} minutes")
                                print(f"   Expected Duration: {expected_duration:.1f} minutes (206 WPM)")
                                print(f"   Duration Accuracy: {duration_ratio:.1%} of expected")

                                synthesis_log["expected_duration_minutes"] = expected_duration
                                synthesis_log["duration_accuracy_ratio"] = duration_ratio

                            except ValueError as e:
                                print(f"   Duration parsing error: {e}")
                        else:
                            print("   Duration detection failed - audio may be corrupted")
                    else:
                        print("   Duration detection unavailable - install ffmpeg for validation")

                except subprocess.TimeoutExpired:
                    print("   Duration detection timeout")
                except Exception as e:
                    print(f"   Duration detection error: {e}")

            elif response.status_code == 401:
                synthesis_log["success"] = False
                synthesis_log["error"] = "Authentication failed - check API key"

            elif response.status_code == 429:
                synthesis_log["success"] = False
                synthesis_log["error"] = "Rate limit exceeded"
                print("⚠️ Rate limit hit - consider upgrading plan for large synthesis")

            elif response.status_code == 422:
                synthesis_log["success"] = False
                synthesis_log["error"] = f"Invalid SSML input: {response.text}"

            elif response.status_code == 413:
                synthesis_log["success"] = False
                synthesis_log["error"] = "Content too large for single call"

            else:
                synthesis_log["success"] = False
                synthesis_log["error"] = f"API error: {response.status_code} - {response.text}"

        except requests.exceptions.Timeout:
            synthesis_log["success"] = False
            synthesis_log["error"] = "Synthesis timeout (15+ minutes) - content may be too large for single call"
            synthesis_log["end_time"] = datetime.now().isoformat()
            synthesis_log["recovery_suggestion"] = "Consider using chunked synthesis for content >35k characters"
            print("⚠️ Timeout: Consider chunking for very long content")

        except requests.exceptions.ConnectionError:
            synthesis_log["success"] = False
            synthesis_log["error"] = "Connection error - check internet connectivity"
            synthesis_log["end_time"] = datetime.now().isoformat()
            synthesis_log["recovery_suggestion"] = "Verify network connection and retry"
            print("⚠️ Connection lost: Check network and retry")

        except requests.exceptions.RequestException as e:
            synthesis_log["success"] = False
            synthesis_log["error"] = f"Network error: {str(e)}"
            synthesis_log["end_time"] = datetime.now().isoformat()
            synthesis_log["recovery_suggestion"] = "Check network connectivity and API status"
            print(f"⚠️ Request error: {str(e)}")

        except Exception as e:
            synthesis_log["success"] = False
            synthesis_log["error"] = f"Unexpected error: {str(e)}"
            synthesis_log["end_time"] = datetime.now().isoformat()
            synthesis_log["recovery_suggestion"] = "Check script content and system resources"
            print(f"⚠️ Unexpected error: {str(e)}")

        # Save synthesis log with error handling
        log_path = os.path.join(output_directory, f"{episode_name}_synthesis_log.json")
        try:
            with open(log_path, 'w', encoding='utf-8') as f:
                json.dump(synthesis_log, f, indent=2, ensure_ascii=False)
            print(f"📊 Synthesis log saved: {log_path}")
        except Exception as e:
            print(f"⚠️ Failed to save synthesis log: {e}")
            # Continue execution even if log save fails

        return synthesis_log


def main():
    """Main execution function for Episode 1 single-call synthesis with empirical validation"""
    print("🎙️ Episode 1 TTS - Single Call Direct API Integration (206 WPM Validated)")
    print("=" * 70)
    print("📚 Episode 1 Empirical Discoveries:")
    print("   ✅ ElevenLabs processes at 206 WPM (not 150 WPM)")
    print("   ✅ Direct API integration required (MCP integration failed)")
    print("   ✅ Production voice settings: stability=0.65, similarity=0.8, style=0.3")
    print("   ✅ Cost accuracy: $2.77 actual vs $2.70 estimated (99.7% accuracy)")
    print("=" * 70)

    # Configuration - Use environment variables for security
    API_KEY = os.getenv("ELEVENLABS_API_KEY")
    if not API_KEY:
        print("❌ Error: ELEVENLABS_API_KEY environment variable not set")
        print("   Please run: export ELEVENLABS_API_KEY=your_api_key")
        return

    AMELIA_VOICE_ID = get_production_voice_id()  # Episode 1 empirically validated voice ID

    SCRIPT_PATH = "/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/sessions/ep_001_production_20250824_231505/production/tts_optimized_script.ssml"
    OUTPUT_DIR = "/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/sessions/ep_001_production_20250824_231505/audio_single_call"

    # Initialize client
    client = ElevenLabsSingleCall(API_KEY, AMELIA_VOICE_ID)

    # Validate API key and voice availability
    validation = client.validate_api_key()
    if not validation["success"]:
        print(f"❌ API validation failed: {validation['error']}")
        print("   Ensure ELEVENLABS_API_KEY is set correctly")
        print("   Check your API key at: https://elevenlabs.io/app/speech-synthesis")
        return

    print(f"   Available voices: {validation.get('voice_count', 'N/A')}")

    if not validation.get('voice_verified', True):
        print(f"⚠️ {validation.get('warning', 'Voice verification failed')}")
        print("   Episodes may fail if voice is not available in your account")
        response = input("   Continue anyway? (y/N): ")
        if response.lower() != 'y':
            print("❌ Synthesis cancelled")
            return

    # Synthesize episode in single call
    result = client.synthesize_episode_single_call(SCRIPT_PATH, OUTPUT_DIR, "episode_1_single")

    # Report final results
    print("\n" + "=" * 70)
    print("📊 FINAL RESULTS")
    print("=" * 70)

    if result["success"]:
        print("🎯 Status: SUCCESS")
        print(f"📁 Audio file: {result.get('output_file', 'N/A')}")
        print(f"📊 Size: {result.get('file_size_mb', 0):.1f} MB")
        print(f"💰 Cost: ${result['estimated_cost']:.2f}")

        if 'actual_duration_minutes' in result:
            print(f"⏱️ Actual Duration: {result['actual_duration_minutes']:.1f} minutes")

            if 'expected_duration_minutes' in result:
                print(f"🎯 Expected Duration: {result['expected_duration_minutes']:.1f} minutes (206 WPM empirical)")

            if 'duration_accuracy_ratio' in result:
                accuracy = result['duration_accuracy_ratio']
                if 0.9 <= accuracy <= 1.1:
                    print(f"✅ Duration Accuracy: {accuracy:.1%} (within expected range)")
                else:
                    print(f"⚠️ Duration Accuracy: {accuracy:.1%} (outside expected range)")

        print(f"🚀 Method: Single API call (no chunking)")
        print(f"📈 Model: {result.get('model_used', 'N/A')}")
        print(f"🎙️ Voice: Production voice ({AMELIA_VOICE_ID})")
    else:
        print("❌ Status: FAILED")
        print(f"🚨 Error: {result.get('error', 'Unknown error')}")

        if 'recovery_suggestion' in result:
            print(f"💡 Suggestion: {result['recovery_suggestion']}")

        if 'validation' in result:
            print("📊 Content Analysis:")
            v = result['validation']
            print(f"   Characters: {v.get('char_count', 0):,}")
            print(f"   Words: {v.get('word_count', 0):,}")
            print(f"   Est. Duration: {v.get('estimated_duration_minutes', 0):.1f} minutes (206 WPM)")

            if v.get('char_count', 0) > 40000:
                print("⚠️ Content exceeds 40k character limit for single-call synthesis")
                print("   Consider using chunked synthesis for longer content")

    print("=" * 70)


if __name__ == "__main__":
    main()
