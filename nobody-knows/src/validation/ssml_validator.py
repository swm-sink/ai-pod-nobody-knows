#!/usr/bin/env python3
"""
SSML Processing and Validation System
Comprehensive validation for complex prosody markup in Episode 1 script
"""

import re
import xml.etree.ElementTree as ET
from typing import Dict, List, Tuple, Any
from datetime import datetime

class SSMLValidator:
    """Production-grade SSML validation and processing system"""

    def __init__(self):
        self.valid_prosody_attrs = {
            'rate': ['x-slow', 'slow', 'medium', 'fast', 'x-fast'],
            'pitch': ['x-low', 'low', 'medium', 'high', 'x-high'],
            'volume': ['silent', 'x-soft', 'soft', 'medium', 'loud', 'x-loud', 'medium-loud', 'medium-soft']
        }
        self.valid_emphasis_levels = ['strong', 'moderate', 'reduced']
        self.validation_errors = []
        self.validation_warnings = []

    def validate_ssml_structure(self, ssml_text: str) -> Dict[str, Any]:
        """
        Comprehensive SSML structure validation

        Args:
            ssml_text: SSML formatted text to validate

        Returns:
            Validation results with errors, warnings, and statistics
        """
        print("🔍 Starting comprehensive SSML validation...")

        validation_result = {
            'valid': True,
            'errors': [],
            'warnings': [],
            'statistics': {},
            'recommendations': []
        }

        # Reset validation state
        self.validation_errors = []
        self.validation_warnings = []

        try:
            # 1. Basic XML structure validation
            self._validate_xml_structure(ssml_text)

            # 2. SSML tag validation
            self._validate_ssml_tags(ssml_text)

            # 3. Prosody attribute validation
            self._validate_prosody_attributes(ssml_text)

            # 4. Break tag validation
            self._validate_break_tags(ssml_text)

            # 5. Emphasis validation
            self._validate_emphasis_tags(ssml_text)

            # 6. Phoneme validation
            self._validate_phoneme_tags(ssml_text)

            # 7. Nesting validation
            self._validate_tag_nesting(ssml_text)

            # 8. Content balance validation
            self._validate_content_balance(ssml_text)

            # 9. Generate statistics
            validation_result['statistics'] = self._generate_statistics(ssml_text)

            # Compile results
            validation_result['errors'] = self.validation_errors
            validation_result['warnings'] = self.validation_warnings
            validation_result['valid'] = len(self.validation_errors) == 0

            # Generate recommendations
            validation_result['recommendations'] = self._generate_recommendations()

        except Exception as e:
            validation_result['valid'] = False
            validation_result['errors'].append(f"Critical validation error: {str(e)}")

        return validation_result

    def _validate_xml_structure(self, ssml_text: str) -> None:
        """Validate basic XML structure"""
        try:
            # Check for XML declaration
            if not ssml_text.strip().startswith('<?xml'):
                self.validation_warnings.append("Missing XML declaration")

            # Check for root <speak> tags
            if '<speak>' not in ssml_text or '</speak>' not in ssml_text:
                self.validation_errors.append("Missing required <speak> root tags")

            # Basic XML parsing attempt
            # Clean version without XML declaration for ET parsing
            clean_ssml = re.sub(r'<\?xml.*?\?>', '', ssml_text, flags=re.DOTALL).strip()

            # Try parsing to check well-formedness
            try:
                ET.fromstring(clean_ssml)
            except ET.ParseError as e:
                self.validation_errors.append(f"XML parsing error: {str(e)}")

        except Exception as e:
            self.validation_errors.append(f"XML structure validation failed: {str(e)}")

    def _validate_ssml_tags(self, ssml_text: str) -> None:
        """Validate SSML-specific tags"""
        # Find all SSML tags
        ssml_tags = re.findall(r'<(/?)([a-zA-Z][a-zA-Z0-9]*)', ssml_text)

        valid_ssml_tags = {'speak', 'prosody', 'break', 'emphasis', 'phoneme', 'say-as', 'audio', 'mark', 'p', 's', 'voice'}

        for is_closing, tag_name in ssml_tags:
            if tag_name not in valid_ssml_tags:
                self.validation_warnings.append(f"Unknown SSML tag: <{tag_name}>")

    def _validate_prosody_attributes(self, ssml_text: str) -> None:
        """Validate prosody tag attributes"""
        prosody_tags = re.findall(r'<prosody([^>]*)>', ssml_text)

        for attributes in prosody_tags:
            attr_matches = re.findall(r'(\w+)=["\']([^"\']*)["\']', attributes)

            for attr_name, attr_value in attr_matches:
                if attr_name in self.valid_prosody_attrs:
                    valid_values = self.valid_prosody_attrs[attr_name]
                    if attr_value not in valid_values:
                        # Check if it's a relative value (like +20% or -10%)
                        if not re.match(r'[+-]\d+(\.\d+)?%?|[+-]?\d+(\.\d+)?(Hz|st)', attr_value):
                            self.validation_warnings.append(
                                f"Prosody {attr_name}='{attr_value}' not in standard values: {valid_values}"
                            )
                else:
                    self.validation_warnings.append(f"Unknown prosody attribute: {attr_name}")

    def _validate_break_tags(self, ssml_text: str) -> None:
        """Validate break tag syntax and values"""
        break_tags = re.findall(r'<break([^>]*)/?>', ssml_text)

        for attributes in break_tags:
            if 'time=' in attributes:
                time_match = re.search(r'time=["\']([^"\']*)["\']', attributes)
                if time_match:
                    time_value = time_match.group(1)
                    # Validate time format (e.g., "500ms", "2s", "1.5s")
                    if not re.match(r'\d+(\.\d+)?(ms|s)', time_value):
                        self.validation_errors.append(f"Invalid break time format: '{time_value}'")

    def _validate_emphasis_tags(self, ssml_text: str) -> None:
        """Validate emphasis tag levels"""
        emphasis_tags = re.findall(r'<emphasis([^>]*)>', ssml_text)

        for attributes in emphasis_tags:
            if 'level=' in attributes:
                level_match = re.search(r'level=["\']([^"\']*)["\']', attributes)
                if level_match:
                    level_value = level_match.group(1)
                    if level_value not in self.valid_emphasis_levels:
                        self.validation_errors.append(
                            f"Invalid emphasis level '{level_value}'. Valid: {self.valid_emphasis_levels}"
                        )

    def _validate_phoneme_tags(self, ssml_text: str) -> None:
        """Validate phoneme pronunciation tags"""
        phoneme_tags = re.findall(r'<phoneme([^>]*)>', ssml_text)

        for attributes in phoneme_tags:
            # Check for required alphabet attribute
            if 'alphabet=' not in attributes:
                self.validation_errors.append("Phoneme tag missing required 'alphabet' attribute")

            # Check for required ph attribute
            if 'ph=' not in attributes:
                self.validation_errors.append("Phoneme tag missing required 'ph' attribute")

            # Validate alphabet type
            alphabet_match = re.search(r'alphabet=["\']([^"\']*)["\']', attributes)
            if alphabet_match:
                alphabet = alphabet_match.group(1)
                if alphabet not in ['ipa', 'x-sampa', 'x-amazon-pron']:
                    self.validation_warnings.append(f"Unknown phoneme alphabet: '{alphabet}'")

    def _validate_tag_nesting(self, ssml_text: str) -> None:
        """Validate proper SSML tag nesting"""
        # This is a simplified nesting check
        # Remove self-closing tags first
        text_no_self_closing = re.sub(r'<[^>]+/>', '', ssml_text)

        # Find all opening and closing tags
        tags = re.findall(r'<(/?)([a-zA-Z][a-zA-Z0-9]*)', text_no_self_closing)

        stack = []
        for is_closing, tag_name in tags:
            if not is_closing:  # Opening tag
                stack.append(tag_name)
            else:  # Closing tag
                if not stack:
                    self.validation_errors.append(f"Closing tag </{tag_name}> without matching opening tag")
                elif stack[-1] != tag_name:
                    self.validation_warnings.append(f"Tag nesting issue: expected </{stack[-1]}>, found </{tag_name}>")
                else:
                    stack.pop()

        # Check for unclosed tags
        if stack:
            for tag in stack:
                self.validation_errors.append(f"Unclosed tag: <{tag}>")

    def _validate_content_balance(self, ssml_text: str) -> None:
        """Validate content balance and optimization"""
        # Remove all markup to get plain text
        plain_text = re.sub(r'<[^>]*>', '', ssml_text)
        plain_text = re.sub(r'<!--.*?-->', '', plain_text, flags=re.DOTALL)
        plain_text = plain_text.strip()

        # Calculate ratios
        total_length = len(ssml_text)
        markup_length = total_length - len(plain_text)
        content_length = len(plain_text)

        if content_length == 0:
            self.validation_errors.append("No actual content found in SSML")
            return

        markup_ratio = (markup_length / total_length) * 100

        # Warn if markup is too heavy
        if markup_ratio > 50:
            self.validation_warnings.append(f"High markup ratio: {markup_ratio:.1f}% (consider simplifying)")
        elif markup_ratio > 40:
            self.validation_warnings.append(f"Moderate markup ratio: {markup_ratio:.1f}%")

    def _generate_statistics(self, ssml_text: str) -> Dict[str, Any]:
        """Generate comprehensive SSML statistics"""
        stats = {
            'total_characters': len(ssml_text),
            'prosody_tags': len(re.findall(r'<prosody', ssml_text)),
            'break_tags': len(re.findall(r'<break', ssml_text)),
            'emphasis_tags': len(re.findall(r'<emphasis', ssml_text)),
            'phoneme_tags': len(re.findall(r'<phoneme', ssml_text)),
            'comment_blocks': len(re.findall(r'<!--.*?-->', ssml_text, flags=re.DOTALL)),
        }

        # Calculate plain text
        plain_text = re.sub(r'<[^>]*>', '', ssml_text)
        plain_text = re.sub(r'<!--.*?-->', '', plain_text, flags=re.DOTALL).strip()

        stats['plain_text_characters'] = len(plain_text)
        stats['markup_characters'] = stats['total_characters'] - stats['plain_text_characters']
        stats['markup_percentage'] = (stats['markup_characters'] / stats['total_characters']) * 100

        # Estimate speech duration (using empirically validated 206 WPM from Episode 1)
        word_count = len(plain_text.split())
        stats['word_count'] = word_count
        stats['estimated_duration_minutes'] = word_count / 206  # Episode 1 empirical rate

        # Break analysis
        break_times = re.findall(r'<break time=["\']([^"\']*)["\']', ssml_text)
        total_break_time = 0
        for break_time in break_times:
            if break_time.endswith('s'):
                total_break_time += float(break_time[:-1])
            elif break_time.endswith('ms'):
                total_break_time += float(break_time[:-2]) / 1000

        stats['total_break_time_seconds'] = total_break_time
        stats['total_break_time_minutes'] = total_break_time / 60

        return stats

    def _generate_recommendations(self) -> List[str]:
        """Generate optimization recommendations"""
        recommendations = []

        if len(self.validation_errors) > 0:
            recommendations.append("Fix all validation errors before synthesis")

        if len(self.validation_warnings) > 5:
            recommendations.append("Consider simplifying SSML markup for better reliability")

        recommendations.append("Test synthesis with small chunks first")
        recommendations.append("Validate pronunciation of technical terms")
        recommendations.append("Review emphasis placement for natural flow")

        return recommendations


def main():
    """Test SSML validation with Episode 1 script"""
    print("🔍 SSML Processing & Validation System")
    print("=" * 60)

    script_path = "nobody-knows/production/ep_001_test/script/tts_optimized_script.ssml"

    # Validate and read the script
    try:
        import os
        if not os.path.exists(script_path):
            print(f"❌ Script file not found: {script_path}")
            return

        if not os.access(script_path, os.R_OK):
            print(f"❌ Permission denied reading script: {script_path}")
            return

        with open(script_path, 'r', encoding='utf-8') as f:
            script_content = f.read()

        if not script_content.strip():
            print(f"❌ Script file is empty: {script_path}")
            return

    except UnicodeDecodeError as e:
        print(f"❌ Script encoding error: {str(e)}")
        return
    except Exception as e:
        print(f"❌ Error reading script: {e}")
        return

    # Initialize validator
    validator = SSMLValidator()

    # Run validation
    print("🔍 Running comprehensive SSML validation...")
    result = validator.validate_ssml_structure(script_content)

    # Report results
    print("\n" + "=" * 60)
    print("📊 VALIDATION RESULTS")
    print("=" * 60)

    # Overall status
    if result['valid']:
        print("✅ SSML Structure: VALID")
    else:
        print("❌ SSML Structure: INVALID")

    print(f"🔢 Total Characters: {result['statistics']['total_characters']:,}")
    print(f"📝 Plain Text: {result['statistics']['plain_text_characters']:,} chars")
    print(f"🏷️ Markup: {result['statistics']['markup_characters']:,} chars ({result['statistics']['markup_percentage']:.1f}%)")

    # Tag statistics
    print(f"\n🏷️ SSML Tags:")
    print(f"   Prosody tags: {result['statistics']['prosody_tags']}")
    print(f"   Break tags: {result['statistics']['break_tags']}")
    print(f"   Emphasis tags: {result['statistics']['emphasis_tags']}")
    print(f"   Phoneme tags: {result['statistics']['phoneme_tags']}")

    # Duration estimates
    print(f"\n⏱️ Duration Estimates:")
    print(f"   Word count: {result['statistics']['word_count']:,}")
    print(f"   Speech time: {result['statistics']['estimated_duration_minutes']:.1f} minutes")
    print(f"   Break time: {result['statistics']['total_break_time_minutes']:.1f} minutes")
    print(f"   Total estimated: {result['statistics']['estimated_duration_minutes'] + result['statistics']['total_break_time_minutes']:.1f} minutes")

    # Errors
    if result['errors']:
        print(f"\n❌ Errors ({len(result['errors'])}):")
        for i, error in enumerate(result['errors'], 1):
            print(f"   {i}. {error}")

    # Warnings
    if result['warnings']:
        print(f"\n⚠️ Warnings ({len(result['warnings'])}):")
        for i, warning in enumerate(result['warnings'], 1):
            print(f"   {i}. {warning}")

    # Recommendations
    if result['recommendations']:
        print(f"\n💡 Recommendations:")
        for i, rec in enumerate(result['recommendations'], 1):
            print(f"   {i}. {rec}")

    print("=" * 60)
    print("✅ SSML validation complete")


if __name__ == "__main__":
    main()
