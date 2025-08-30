#!/usr/bin/env python3
"""
Audio synthesis for Episode 003: Stoicism Modern Applications
Using production-validated voice configuration
"""

import os
import json
from pathlib import Path
import requests
import time

def load_production_config():
    """Load the production voice configuration"""
    config_path = "/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/config/production-voice.json"
    with open(config_path, 'r') as f:
        return json.load(f)

def synthesize_episode():
    """Synthesize the complete episode audio"""

    # Load production configuration
    config = load_production_config()
    voice_config = config['production_voice']

    # Episode details
    episode_dir = "/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/test_runs/battle_testing_20250829/episodes/episode_003"
    script_path = f"{episode_dir}/audio/script_clean.txt"
    output_path = f"{episode_dir}/audio/episode_003_audio.mp3"

    # Read the script
    with open(script_path, 'r') as f:
        script_text = f.read()

    # API configuration
    API_KEY = os.getenv('ELEVENLABS_API_KEY')
    if not API_KEY:
        raise ValueError("ELEVENLABS_API_KEY environment variable not set")

    voice_id = voice_config['voice_id']
    model_id = voice_config['settings']['model_id']

    # Synthesis parameters using validated settings
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"

    headers = {
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
        "xi-api-key": API_KEY
    }

    data = {
        "text": script_text,
        "model_id": model_id,
        "voice_settings": {
            "stability": voice_config['settings']['stability'],
            "similarity_boost": voice_config['settings']['similarity_boost'],
            "style": voice_config['settings']['style'],
            "use_speaker_boost": voice_config['settings']['use_speaker_boost']
        }
    }

    print(f"Synthesizing episode audio...")
    print(f"Voice ID: {voice_id} (Amelia)")
    print(f"Model: {model_id}")
    print(f"Script length: {len(script_text)} characters")

    start_time = time.time()

    try:
        response = requests.post(url, json=data, headers=headers, timeout=300)
        response.raise_for_status()

        # Save the audio file
        with open(output_path, 'wb') as f:
            f.write(response.content)

        synthesis_time = time.time() - start_time

        # Calculate metrics
        word_count = len(script_text.split())
        estimated_cost = len(script_text) * 0.00003  # Approximate ElevenLabs pricing

        synthesis_report = {
            "episode": "003",
            "topic": "Stoicism Modern Applications",
            "synthesis_timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "voice_configuration": {
                "voice_id": voice_id,
                "voice_name": "Amelia",
                "model_id": model_id,
                "settings": voice_config['settings']
            },
            "metrics": {
                "script_characters": len(script_text),
                "script_words": word_count,
                "synthesis_time_seconds": round(synthesis_time, 2),
                "estimated_cost_usd": round(estimated_cost, 4),
                "output_file": output_path,
                "file_size_mb": round(os.path.getsize(output_path) / (1024 * 1024), 2)
            },
            "status": "completed"
        }

        # Save synthesis report
        report_path = f"{episode_dir}/audio/synthesis_report.json"
        with open(report_path, 'w') as f:
            json.dump(synthesis_report, f, indent=2)

        print(f"✅ Audio synthesis completed successfully!")
        print(f"📁 Output: {output_path}")
        print(f"📊 Duration: {synthesis_time:.1f}s")
        print(f"💰 Estimated cost: ${estimated_cost:.4f}")
        print(f"📄 Report saved: {report_path}")

        return synthesis_report

    except requests.exceptions.RequestException as e:
        print(f"❌ Audio synthesis failed: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response content: {e.response.content}")
        raise

if __name__ == "__main__":
    synthesize_episode()
