import sys
import os
sys.path.append('/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows')
import json
import requests
from datetime import datetime

# Load production voice configuration
with open('/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/config/production-voice.json', 'r') as f:
    config = json.load(f)

voice_config = config['production_voice']
voice_id = voice_config['voice_id']
settings = voice_config['settings']

# Load script content
script_path = '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/test_runs/battle_testing_20250829/episodes/episode_002/audio/script_clean.txt'
with open(script_path, 'r') as f:
    script_text = f.read()

# Get API key from environment
api_key = os.getenv('ELEVENLABS_API_KEY')
if not api_key:
    print('Error: ELEVENLABS_API_KEY not found in environment')
    sys.exit(1)

# Prepare request
url = f'https://api.elevenlabs.io/v1/text-to-speech/{voice_id}'
headers = {
    'Accept': 'audio/mpeg',
    'Content-Type': 'application/json',
    'xi-api-key': api_key
}

data = {
    'text': script_text,
    'model_id': settings['model_id'],
    'voice_settings': {
        'stability': settings['stability'],
        'similarity_boost': settings['similarity_boost'],
        'style': settings['style'],
        'use_speaker_boost': settings['use_speaker_boost']
    }
}

print(f'Synthesizing audio with voice {voice_config["voice_name"]} ({voice_id})')
print(f'Script length: {len(script_text)} characters')
print(f'Estimated cost: ${len(script_text) * 0.00003:.4f}')

# Make request
try:
    response = requests.post(url, json=data, headers=headers, timeout=300)

    if response.status_code == 200:
        # Save audio file
        audio_path = '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/test_runs/battle_testing_20250829/episodes/episode_002/audio/episode_002_audio.mp3'
        with open(audio_path, 'wb') as f:
            f.write(response.content)

        print(f'Audio synthesis successful!')
        print(f'Audio saved to: {audio_path}')
        print(f'Audio file size: {len(response.content)} bytes')

        # Calculate actual cost
        actual_cost = len(script_text) * 0.00003
        print(f'Actual synthesis cost: ${actual_cost:.4f}')

        # Create synthesis report
        synthesis_report = {
            'synthesis_timestamp': datetime.now().isoformat(),
            'voice_id': voice_id,
            'voice_name': voice_config['voice_name'],
            'script_characters': len(script_text),
            'audio_file_size': len(response.content),
            'synthesis_cost': actual_cost,
            'model_used': settings['model_id'],
            'voice_settings': settings,
            'status': 'success'
        }

        with open('/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/test_runs/battle_testing_20250829/episodes/episode_002/audio/synthesis_report.json', 'w') as f:
            json.dump(synthesis_report, f, indent=2)

    else:
        print(f'Error: {response.status_code}')
        print(f'Response: {response.text}')
        sys.exit(1)

except Exception as e:
    print(f'Request failed: {str(e)}')
    sys.exit(1)
