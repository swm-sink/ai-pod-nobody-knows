#!/usr/bin/env python3
"""
Speech-to-Text Quality Validation System
Direct ElevenLabs STT API integration for audio quality validation
"""

import requests
import json
import os
import sys
import re
import difflib
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Any

class ElevenLabsSTTValidator:
    """Direct STT API validation for synthesized audio quality"""

    def __init__(self, api_key: str):
        """
        Initialize STT validator with ElevenLabs API

        Args:
            api_key: ElevenLabs API key (from environment variable for security)
        """
        if not api_key:
            raise ValueError("API key is required for STT validation")

        self.api_key = api_key
        self.base_url = "https://api.elevenlabs.io/v1"
        self.headers = {"xi-api-key": self.api_key}

        print("✅ ElevenLabs STT Validator initialized")
        print("   Model: scribe_v1_experimental (Episode 1 validated)")

    def transcribe_audio(self, audio_path: str) -> Dict[str, Any]:
        """
        Transcribe audio file using ElevenLabs STT API

        Args:
            audio_path: Path to audio file

        Returns:
            Transcription result with metadata
        """
        print(f"🎙️ Transcribing audio: {audio_path}")

        # Enhanced file validation
        try:
            if not os.path.exists(audio_path):
                return {"success": False, "error": f"Audio file not found: {audio_path}"}

            if not os.access(audio_path, os.R_OK):
                return {"success": False, "error": f"Permission denied reading audio file: {audio_path}"}

            file_size = os.path.getsize(audio_path)

            if file_size == 0:
                return {"success": False, "error": "Audio file is empty"}

            if file_size > 100 * 1024 * 1024:  # 100MB limit
                return {"success": False, "error": f"Audio file too large: {file_size / (1024*1024):.1f} MB (max 100MB)"}

            print(f"   File size: {file_size:,} bytes ({file_size / (1024*1024):.1f} MB)")

        except OSError as e:
            return {"success": False, "error": f"Cannot access audio file: {str(e)}"}

        try:
            with open(audio_path, 'rb') as audio_file:
                files = {"file": audio_file}
                data = {"model_id": "scribe_v1_experimental"}

                headers_stt = {
                    "xi-api-key": self.api_key,
                    "Accept": "application/json"
                }

                print("🔄 Making STT API request...")
                response = requests.post(
                    f"{self.base_url}/speech-to-text",
                    headers=headers_stt,
                    files=files,
                    data=data,
                    timeout=600  # 10 minutes for long audio
                )

            if response.status_code == 200:
                result = response.json()
                transcript = result.get("text", "")

                print(f"✅ Transcription successful: {len(transcript)} characters")

                return {
                    "success": True,
                    "transcript": transcript,
                    "character_count": len(transcript),
                    "word_count": len(transcript.split()),
                    "api_response": result
                }

            elif response.status_code == 401:
                return {"success": False, "error": "Authentication failed - check ELEVENLABS_API_KEY environment variable"}
            elif response.status_code == 403:
                return {"success": False, "error": "API key lacks STT permissions"}
            elif response.status_code == 413:
                return {"success": False, "error": "Audio file too large for STT API (max 100MB)"}
            elif response.status_code == 415:
                return {"success": False, "error": "Unsupported audio format - use MP3, WAV, or FLAC"}
            elif response.status_code == 422:
                return {"success": False, "error": f"Invalid audio format or corrupted file: {response.text}"}
            elif response.status_code == 429:
                return {"success": False, "error": "Rate limit exceeded - wait and retry"}
            else:
                return {"success": False, "error": f"STT API error: {response.status_code} - {response.text}"}

        except requests.exceptions.Timeout:
            return {"success": False, "error": "STT request timeout (10+ minutes) - audio file may be too large"}
        except requests.exceptions.ConnectionError:
            return {"success": False, "error": "Connection failed - check internet connectivity"}
        except requests.exceptions.RequestException as e:
            return {"success": False, "error": f"Network error during STT request: {str(e)}"}
        except MemoryError:
            return {"success": False, "error": "Insufficient memory to process audio file"}
        except Exception as e:
            return {"success": False, "error": f"Unexpected STT error: {str(e)}"}

    def clean_text_for_comparison(self, text: str) -> str:
        """
        Clean text for accurate comparison between original and transcript

        Args:
            text: Raw text to clean

        Returns:
            Cleaned text for comparison
        """
        # Remove SSML markup
        cleaned = re.sub(r'<[^>]*>', '', text)

        # Remove comments
        cleaned = re.sub(r'<!--.*?-->', '', cleaned, flags=re.DOTALL)

        # Normalize whitespace
        cleaned = re.sub(r'\s+', ' ', cleaned)

        # Remove punctuation that might not be spoken
        cleaned = re.sub(r'[""''„"«»‹›]', '"', cleaned)  # Normalize quotes
        cleaned = re.sub(r'[–—]', '-', cleaned)  # Normalize dashes

        # Convert to lowercase for comparison
        cleaned = cleaned.lower().strip()

        return cleaned

    def calculate_accuracy_metrics(self, original_text: str, transcript: str) -> Dict[str, Any]:
        """
        Calculate comprehensive accuracy metrics between original and transcript

        Args:
            original_text: Original script text (cleaned)
            transcript: STT transcript text

        Returns:
            Detailed accuracy metrics
        """
        print("📊 Calculating accuracy metrics...")

        # Clean both texts for comparison
        original_clean = self.clean_text_for_comparison(original_text)
        transcript_clean = self.clean_text_for_comparison(transcript)

        # Word-level comparison
        original_words = original_clean.split()
        transcript_words = transcript_clean.split()

        # Calculate word accuracy using sequence matching
        matcher = difflib.SequenceMatcher(None, original_words, transcript_words)

        # Get matching blocks
        matching_blocks = matcher.get_matching_blocks()
        total_matches = sum(block.size for block in matching_blocks)

        word_accuracy = (total_matches / len(original_words)) * 100 if original_words else 0

        # Character-level accuracy
        char_matcher = difflib.SequenceMatcher(None, original_clean, transcript_clean)
        char_accuracy = char_matcher.ratio() * 100

        # Find differences
        word_differences = []
        opcodes = matcher.get_opcodes()

        for tag, i1, i2, j1, j2 in opcodes:
            if tag != 'equal':
                original_segment = ' '.join(original_words[i1:i2])
                transcript_segment = ' '.join(transcript_words[j1:j2])
                word_differences.append({
                    'type': tag,
                    'original': original_segment,
                    'transcript': transcript_segment,
                    'position': i1
                })

        # Technical term accuracy check
        technical_terms = self.extract_technical_terms(original_text)
        term_accuracy = self.check_technical_term_accuracy(original_clean, transcript_clean, technical_terms)

        # Statistical validation
        statistics_accuracy = self.validate_statistics_pronunciation(original_clean, transcript_clean)

        # Expert name validation
        expert_names = ["yoshua bengio", "geoffrey hinton"]
        expert_accuracy = self.check_expert_names(original_clean, transcript_clean, expert_names)

        metrics = {
            "word_accuracy_percent": round(word_accuracy, 2),
            "character_accuracy_percent": round(char_accuracy, 2),
            "original_word_count": len(original_words),
            "transcript_word_count": len(transcript_words),
            "word_count_ratio": len(transcript_words) / len(original_words) if original_words else 0,
            "technical_term_accuracy": term_accuracy,
            "statistics_accuracy": statistics_accuracy,
            "expert_name_accuracy": expert_accuracy,
            "total_differences": len(word_differences),
            "differences_sample": word_differences[:10],  # First 10 differences
        }

        # Calculate composite quality score
        weights = {
            "word_accuracy": 0.30,
            "character_accuracy": 0.20,
            "technical_terms": 0.25,
            "statistics": 0.15,
            "expert_names": 0.10
        }

        composite_score = (
            (word_accuracy * weights["word_accuracy"]) +
            (char_accuracy * weights["character_accuracy"]) +
            (term_accuracy["accuracy_percent"] * weights["technical_terms"]) +
            (statistics_accuracy["accuracy_percent"] * weights["statistics"]) +
            (expert_accuracy["accuracy_percent"] * weights["expert_names"])
        )

        metrics["composite_quality_score"] = round(composite_score, 2)
        metrics["quality_rating"] = self.get_quality_rating(composite_score)

        return metrics

    def extract_technical_terms(self, text: str) -> List[str]:
        """Extract technical terms from the original script"""
        # Common AI/tech terms from Episode 1
        technical_terms = [
            "artificial intelligence", "ai", "neural networks", "deep learning",
            "machine learning", "turing award", "nobei", "oecd", "pew research",
            "percentage", "thirty-nine percentage", "thirty nine percentage",
            "thirty-nine-percentage", "intellectual humility", "remarkably uncertain"
        ]

        found_terms = []
        text_lower = text.lower()

        for term in technical_terms:
            if term in text_lower:
                found_terms.append(term)

        return found_terms

    def check_technical_term_accuracy(self, original: str, transcript: str, terms: List[str]) -> Dict[str, Any]:
        """Check accuracy of technical term pronunciation"""
        if not terms:
            return {"accuracy_percent": 100, "correct_terms": 0, "total_terms": 0}

        correct_count = 0
        term_details = []

        for term in terms:
            original_has = term.lower() in original
            transcript_has = term.lower() in transcript

            if original_has and transcript_has:
                correct_count += 1
                term_details.append({"term": term, "status": "correct"})
            elif original_has and not transcript_has:
                term_details.append({"term": term, "status": "missing"})
            elif not original_has and transcript_has:
                term_details.append({"term": term, "status": "added"})

        accuracy = (correct_count / len(terms)) * 100 if terms else 100

        return {
            "accuracy_percent": round(accuracy, 2),
            "correct_terms": correct_count,
            "total_terms": len(terms),
            "term_details": term_details
        }

    def validate_statistics_pronunciation(self, original: str, transcript: str) -> Dict[str, Any]:
        """Validate pronunciation of key statistics"""
        key_statistics = [
            "thirty-nine percentage", "thirty nine percentage", "39 percentage",
            "fifty-six percent", "56 percent", "seventeen percent", "17 percent",
            "298 pages", "two hundred ninety-eight pages", "january 29th",
            "april 2025", "july 2025"
        ]

        found_stats = 0
        correct_stats = 0
        stat_details = []

        for stat in key_statistics:
            if stat in original:
                found_stats += 1
                if stat in transcript or stat.replace("-", " ") in transcript:
                    correct_stats += 1
                    stat_details.append({"statistic": stat, "status": "correct"})
                else:
                    stat_details.append({"statistic": stat, "status": "incorrect"})

        accuracy = (correct_stats / found_stats) * 100 if found_stats else 100

        return {
            "accuracy_percent": round(accuracy, 2),
            "correct_statistics": correct_stats,
            "total_statistics": found_stats,
            "statistic_details": stat_details
        }

    def check_expert_names(self, original: str, transcript: str, names: List[str]) -> Dict[str, Any]:
        """Check pronunciation accuracy of expert names"""
        correct_count = 0
        name_details = []

        for name in names:
            if name.lower() in original:
                # Check various pronunciation possibilities
                name_variants = [
                    name,
                    name.replace(" ", "-"),
                    name.replace(" ", ""),
                ]

                found = any(variant.lower() in transcript for variant in name_variants)

                if found:
                    correct_count += 1
                    name_details.append({"name": name, "status": "correct"})
                else:
                    name_details.append({"name": name, "status": "incorrect"})

        accuracy = (correct_count / len(names)) * 100 if names else 100

        return {
            "accuracy_percent": round(accuracy, 2),
            "correct_names": correct_count,
            "total_names": len(names),
            "name_details": name_details
        }

    def get_quality_rating(self, score: float) -> str:
        """Get quality rating from composite score"""
        if score >= 95:
            return "EXCELLENT"
        elif score >= 90:
            return "VERY_GOOD"
        elif score >= 85:
            return "GOOD"
        elif score >= 75:
            return "ACCEPTABLE"
        else:
            return "NEEDS_IMPROVEMENT"

    def validate_episode_audio(self, audio_path: str, script_path: str, output_dir: str) -> Dict[str, Any]:
        """
        Complete validation workflow for episode audio

        Args:
            audio_path: Path to synthesized audio
            script_path: Path to original script
            output_dir: Directory for validation reports

        Returns:
            Complete validation results
        """
        print(f"\n🔍 Starting Episode Audio Validation")
        print(f"   Audio: {audio_path}")
        print(f"   Script: {script_path}")

        # Create output directory with error handling
        try:
            os.makedirs(output_dir, exist_ok=True)
            # Test write permissions
            test_file = os.path.join(output_dir, ".write_test")
            with open(test_file, 'w') as f:
                f.write("test")
            os.remove(test_file)
        except PermissionError:
            validation_result["error"] = f"Permission denied creating output directory: {output_dir}"
            return validation_result
        except OSError as e:
            validation_result["error"] = f"Cannot create output directory: {str(e)}"
            return validation_result

        validation_result = {
            "validation_start": datetime.now().isoformat(),
            "audio_path": audio_path,
            "script_path": script_path,
            "success": False
        }

        # 1. Transcribe audio
        transcription = self.transcribe_audio(audio_path)
        validation_result["transcription"] = transcription

        if not transcription["success"]:
            validation_result["error"] = f"Transcription failed: {transcription['error']}"
            return validation_result

        # 2. Load original script with enhanced validation
        try:
            if not os.path.exists(script_path):
                validation_result["error"] = f"Script file not found: {script_path}"
                return validation_result

            if not os.access(script_path, os.R_OK):
                validation_result["error"] = f"Permission denied reading script: {script_path}"
                return validation_result

            with open(script_path, 'r', encoding='utf-8') as f:
                original_script = f.read()

            if not original_script or len(original_script.strip()) == 0:
                validation_result["error"] = "Script file is empty"
                return validation_result

        except UnicodeDecodeError:
            validation_result["error"] = f"Invalid UTF-8 encoding in script: {script_path}"
            return validation_result
        except Exception as e:
            validation_result["error"] = f"Script read error: {str(e)}"
            return validation_result

        # 3. Calculate accuracy metrics
        metrics = self.calculate_accuracy_metrics(original_script, transcription["transcript"])
        validation_result["accuracy_metrics"] = metrics

        # 4. Generate quality assessment
        validation_result["quality_assessment"] = {
            "overall_rating": metrics["quality_rating"],
            "composite_score": metrics["composite_quality_score"],
            "passes_threshold": metrics["composite_quality_score"] >= 85,
            "target_threshold": 85
        }

        # 5. Generate recommendations
        validation_result["recommendations"] = self.generate_recommendations(metrics)

        validation_result["validation_end"] = datetime.now().isoformat()
        validation_result["success"] = True

        # Save detailed report with error handling
        report_path = os.path.join(output_dir, "audio_quality_validation_report.json")
        try:
            with open(report_path, 'w', encoding='utf-8') as f:
                json.dump(validation_result, f, indent=2, ensure_ascii=False)
            print(f"📊 Validation report saved: {report_path}")
        except Exception as e:
            print(f"⚠️ Failed to save validation report: {e}")

        # Save transcript for manual review with error handling
        transcript_path = os.path.join(output_dir, "transcribed_audio.txt")
        try:
            with open(transcript_path, 'w', encoding='utf-8') as f:
                f.write(transcription["transcript"])
            print(f"📝 Transcript saved: {transcript_path}")
        except Exception as e:
            print(f"⚠️ Failed to save transcript: {e}")

        return validation_result

    def generate_recommendations(self, metrics: Dict[str, Any]) -> List[str]:
        """Generate improvement recommendations based on metrics"""
        recommendations = []

        if metrics["composite_quality_score"] >= 95:
            recommendations.append("✅ Excellent quality - ready for production")
        elif metrics["composite_quality_score"] >= 85:
            recommendations.append("✅ Good quality - meets production standards")
        else:
            recommendations.append("⚠️ Quality below threshold - review and improve")

        if metrics["word_accuracy_percent"] < 90:
            recommendations.append("• Improve word accuracy - consider adjusting synthesis parameters")

        if metrics["technical_term_accuracy"]["accuracy_percent"] < 95:
            recommendations.append("• Review technical term pronunciation - add phonetic guidance")

        if metrics["expert_name_accuracy"]["accuracy_percent"] < 100:
            recommendations.append("• Verify expert name pronunciation - use IPA phonetic notation")

        if metrics["statistics_accuracy"]["accuracy_percent"] < 95:
            recommendations.append("• Check statistics pronunciation - ensure clear number articulation")

        return recommendations


def main():
    """Test STT validation with Episode 1 synthesized audio using empirical thresholds"""
    print("🔍 Episode 1 Audio Quality Validation (Empirical Thresholds)")
    print("=" * 60)
    print("📚 Episode 1 Empirical Quality Standards:")
    print("   ✅ Word accuracy target: ≥94% (Episode 1: 94.89%)")
    print("   ✅ Character accuracy target: ≥91% (Episode 1: 91.23%)")
    print("   ✅ Composite quality target: ≥85% (Episode 1: 92.1%)")
    print("   ✅ STT model: scribe_v1_experimental (production validated)")
    print("=" * 60)

    # Configuration - Use environment variables for security
    API_KEY = os.getenv("ELEVENLABS_API_KEY")
    if not API_KEY:
        print("❌ Error: ELEVENLABS_API_KEY environment variable not set")
        print("   Please run: export ELEVENLABS_API_KEY=your_api_key")
        return

    AUDIO_PATH = "nobody-knows/production/ep_001_test/audio/episode_1_test.mp3"
    SCRIPT_PATH = "nobody-knows/production/ep_001_test/script/tts_optimized_script.ssml"
    OUTPUT_DIR = "nobody-knows/production/ep_001_test/audio"

    # Initialize validator with error handling
    try:
        validator = ElevenLabsSTTValidator(API_KEY)
    except ValueError as e:
        print(f"❌ Validator initialization failed: {e}")
        return
    except Exception as e:
        print(f"❌ Unexpected initialization error: {e}")
        return

    # Validate input files exist before processing
    if not os.path.exists(AUDIO_PATH):
        print(f"❌ Audio file not found: {AUDIO_PATH}")
        return

    if not os.path.exists(SCRIPT_PATH):
        print(f"❌ Script file not found: {SCRIPT_PATH}")
        return

    print(f"✅ Input validation passed")
    print(f"   Audio: {os.path.basename(AUDIO_PATH)}")
    print(f"   Script: {os.path.basename(SCRIPT_PATH)}")

    # Run validation with progress tracking
    try:
        result = validator.validate_episode_audio(AUDIO_PATH, SCRIPT_PATH, OUTPUT_DIR)
    except KeyboardInterrupt:
        print("⚠️ Validation cancelled by user")
        return
    except Exception as e:
        print(f"❌ Validation error: {str(e)}")
        return

    # Report results
    print("\n" + "=" * 60)
    print("📊 VALIDATION RESULTS")
    print("=" * 60)

    if result["success"]:
        metrics = result["accuracy_metrics"]
        assessment = result["quality_assessment"]

        print(f"🎯 Overall Rating: {assessment['overall_rating']}")
        print(f"📊 Composite Score: {assessment['composite_score']:.2f}%")

        if assessment['passes_threshold']:
            print(f"✅ Quality Status: PASSES (≥{assessment['target_threshold']}% - Episode 1 empirical threshold)")
        else:
            print(f"❌ Quality Status: FAILS (<{assessment['target_threshold']}% - Episode 1 empirical threshold)")

        print(f"\n📈 Detailed Metrics (Episode 1 Comparison):")

        word_acc = metrics['word_accuracy_percent']
        word_status = "✅" if word_acc >= 94 else "⚠️" if word_acc >= 90 else "❌"
        print(f"   Word Accuracy: {word_acc:.2f}% {word_status} (Episode 1: 94.89%)")

        char_acc = metrics['character_accuracy_percent']
        char_status = "✅" if char_acc >= 91 else "⚠️" if char_acc >= 85 else "❌"
        print(f"   Character Accuracy: {char_acc:.2f}% {char_status} (Episode 1: 91.23%)")

        tech_acc = metrics['technical_term_accuracy']['accuracy_percent']
        tech_status = "✅" if tech_acc >= 95 else "⚠️" if tech_acc >= 90 else "❌"
        print(f"   Technical Terms: {tech_acc:.2f}% {tech_status} (Target: ≥95%)")

        stats_acc = metrics['statistics_accuracy']['accuracy_percent']
        stats_status = "✅" if stats_acc >= 100 else "⚠️" if stats_acc >= 95 else "❌"
        print(f"   Statistics: {stats_acc:.2f}% {stats_status} (Episode 1: 100%)")

        expert_acc = metrics['expert_name_accuracy']['accuracy_percent']
        expert_status = "✅" if expert_acc >= 90 else "⚠️" if expert_acc >= 80 else "❌"
        print(f"   Expert Names: {expert_acc:.2f}% {expert_status} (Target: ≥90%)")

        print(f"\n📝 Content Analysis:")
        print(f"   Original Words: {metrics['original_word_count']:,}")
        print(f"   Transcript Words: {metrics['transcript_word_count']:,}")
        print(f"   Word Count Ratio: {metrics['word_count_ratio']:.3f}")
        print(f"   Total Differences: {metrics['total_differences']}")

        print(f"\n💡 Recommendations:")
        for rec in result["recommendations"]:
            if rec.startswith("✅"):
                print(f"   {rec}")
            else:
                print(f"   {rec}")

    else:
        print(f"❌ Validation Failed: {result.get('error', 'Unknown error')}")

        if 'transcription' in result and result['transcription'] and not result['transcription'].get('success'):
            print(f"   Transcription Error: {result['transcription'].get('error', 'Unknown transcription error')}")

        print("\n💡 Troubleshooting Suggestions:")
        print("   • Check audio file format (MP3, WAV, FLAC supported)")
        print("   • Verify file is not corrupted")
        print("   • Ensure ELEVENLABS_API_KEY is valid")
        print("   • Check internet connectivity")

    print("=" * 60)


if __name__ == "__main__":
    main()
