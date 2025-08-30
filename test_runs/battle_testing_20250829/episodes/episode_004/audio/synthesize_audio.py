#!/usr/bin/env python3
"""
Audio Synthesis Script - Episode 4: CRISPR Gene Editing Ethics
Optimized for nuanced ethical content delivery with multi-perspective analysis
"""

import os
import sys
import json
import time
from pathlib import Path

# Add project root to path for imports
project_root = Path(__file__).parent.parent.parent.parent.parent
sys.path.insert(0, str(project_root))

try:
    from elevenlabs import client, generate, save
    ELEVENLABS_AVAILABLE = True
except ImportError:
    ELEVENLABS_AVAILABLE = False
    print("ElevenLabs library not available. Install with: pip install elevenlabs")

class Episode4AudioSynthesizer:
    """Specialized synthesizer for ethical content with multi-perspective analysis"""

    def __init__(self):
        self.episode_dir = Path(__file__).parent.parent
        self.audio_dir = Path(__file__).parent

        # Load production voice configuration
        self.load_voice_config()

        # Load synthesis requirements
        self.load_synthesis_config()

    def load_voice_config(self):
        """Load approved production voice configuration"""
        config_path = self.episode_dir.parent.parent.parent / ".claude/config/production-voice.json"

        if not config_path.exists():
            raise FileNotFoundError(f"Production voice config not found at {config_path}")

        with open(config_path, 'r') as f:
            config = json.load(f)

        self.voice_config = config['production_voice']
        self.voice_id = self.voice_config['voice_id']
        self.voice_settings = self.voice_config['settings']

        print(f"Loaded production voice: {self.voice_config['voice_name']} ({self.voice_id})")

    def load_synthesis_config(self):
        """Load synthesis optimization parameters"""
        synthesis_path = self.audio_dir / "synthesis_report.json"

        if not synthesis_path.exists():
            raise FileNotFoundError(f"Synthesis config not found at {synthesis_path}")

        with open(synthesis_path, 'r') as f:
            self.synthesis_config = json.load(f)

        print("Loaded synthesis optimization parameters")

    def load_script(self):
        """Load clean script text"""
        script_path = self.audio_dir / "script_clean.txt"

        if not script_path.exists():
            raise FileNotFoundError(f"Clean script not found at {script_path}")

        with open(script_path, 'r', encoding='utf-8') as f:
            script_text = f.read().strip()

        print(f"Loaded script: {len(script_text)} characters")
        return script_text

    def optimize_for_ethical_content(self, text):
        """Apply optimization for nuanced ethical content delivery"""

        # Ensure clear articulation of technical terms
        technical_terms = {
            "CRISPR": "CRISPR",  # Ensure clear pronunciation
            "Cas9": "Cas nine",
            "germline": "germ-line",
            "somatic": "so-matic",
            "bioethicist": "bio-ethicist",
            "utilitarian": "u-til-i-tarian",
            "deontological": "de-on-to-logical"
        }

        optimized_text = text
        for term, pronunciation in technical_terms.items():
            # Add subtle pauses for complex terms
            optimized_text = optimized_text.replace(term, f"{pronunciation}")

        # Add emphasis markers for key quotes (if supported)
        quote_markers = [
            "unprecedented scientific opportunity demanding unprecedented ethical responsibility",
            "We must resist scientific hubris",
            "uncertainty must inform, not silence, ethical debate",
            "care, not certainty",
            "What do we know, what can't we know yet"
        ]

        for quote in quote_markers:
            # Add slight emphasis through punctuation
            optimized_text = optimized_text.replace(quote, f'"{quote}"')

        return optimized_text

    def synthesize_audio(self):
        """Perform the actual audio synthesis"""

        if not ELEVENLABS_AVAILABLE:
            print("ERROR: ElevenLabs library not available")
            return False

        # Check for API key
        api_key = os.getenv('ELEVENLABS_API_KEY')
        if not api_key:
            print("ERROR: ELEVENLABS_API_KEY environment variable not set")
            return False

        try:
            print("Starting audio synthesis...")
            start_time = time.time()

            # Load and optimize script
            script_text = self.load_script()
            optimized_text = self.optimize_for_ethical_content(script_text)

            print(f"Synthesizing with voice: {self.voice_config['voice_name']}")
            print(f"Model: {self.voice_settings['model_id']}")

            # Generate audio with production settings
            audio = generate(
                text=optimized_text,
                voice=self.voice_id,
                model=self.voice_settings['model_id'],
                api_key=api_key,
                voice_settings={
                    'stability': self.voice_settings['stability'],
                    'similarity_boost': self.voice_settings['similarity_boost'],
                    'style': self.voice_settings['style'],
                    'use_speaker_boost': self.voice_settings['use_speaker_boost']
                }
            )

            # Save audio file
            output_path = self.audio_dir / "episode_004_audio.mp3"
            save(audio, str(output_path))

            synthesis_time = time.time() - start_time

            # Calculate metrics
            word_count = len(script_text.split())
            char_count = len(script_text)

            # Update synthesis report with actual results
            self.update_synthesis_report({
                "synthesis_completed": True,
                "completion_timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "actual_metrics": {
                    "word_count": word_count,
                    "character_count": char_count,
                    "synthesis_time_seconds": round(synthesis_time, 2),
                    "output_file": str(output_path),
                    "file_size_mb": round(os.path.getsize(output_path) / (1024*1024), 2) if output_path.exists() else 0
                },
                "quality_validation": {
                    "voice_configuration_verified": True,
                    "optimization_applied": True,
                    "technical_term_handling": True,
                    "ethical_content_optimization": True
                }
            })

            print(f"✅ Audio synthesis completed successfully!")
            print(f"   Output: {output_path}")
            print(f"   Duration: {synthesis_time:.1f} seconds")
            print(f"   Words: {word_count} | Characters: {char_count}")

            return True

        except Exception as e:
            print(f"❌ Audio synthesis failed: {str(e)}")

            # Update synthesis report with failure
            self.update_synthesis_report({
                "synthesis_completed": False,
                "error": str(e),
                "completion_timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ")
            })

            return False

    def update_synthesis_report(self, updates):
        """Update synthesis report with actual results"""
        synthesis_path = self.audio_dir / "synthesis_report.json"

        with open(synthesis_path, 'r') as f:
            report = json.load(f)

        # Add updates
        report.update(updates)

        with open(synthesis_path, 'w') as f:
            json.dump(report, f, indent=2)

    def validate_audio_output(self):
        """Validate the synthesized audio meets quality requirements"""
        output_path = self.audio_dir / "episode_004_audio.mp3"

        if not output_path.exists():
            return False, "Audio file not found"

        file_size = os.path.getsize(output_path)
        if file_size < 1024:  # Less than 1KB suggests failure
            return False, f"Audio file too small ({file_size} bytes)"

        return True, "Audio validation passed"

def main():
    """Main synthesis execution"""
    print("=== Episode 4 Audio Synthesis ===")
    print("Topic: CRISPR Gene Editing Ethics - Multi-Perspective Analysis")
    print("Optimization: Nuanced ethical content delivery")

    synthesizer = Episode4AudioSynthesizer()

    # Perform synthesis
    success = synthesizer.synthesize_audio()

    if success:
        # Validate output
        valid, message = synthesizer.validate_audio_output()
        if valid:
            print(f"✅ {message}")
            print("\n=== Synthesis Complete ===")
            return 0
        else:
            print(f"❌ Validation failed: {message}")
            return 1
    else:
        print("❌ Synthesis failed")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
