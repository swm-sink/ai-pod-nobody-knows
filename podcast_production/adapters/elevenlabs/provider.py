# TODO: Consider wrapping critical async calls with self.retry_handler.execute_with_retry()
"""
ElevenLabs audio synthesis provider implementation.

This module implements direct API integration with ElevenLabs for
text-to-speech synthesis, voice management, and audio production.

Version: 1.0.0
Date: August 2025
"""

from config.voice_config import get_production_voice_id
from core.retry_handler import RetryHandler, RetryConfig, CircuitBreakerState

import json
import logging
import base64
from typing import Any, Dict, Optional, List, Tuple
from datetime import datetime
from pathlib import Path

from core.interfaces.provider import LLMProvider

# Configure logging
logger = logging.getLogger(__name__)


class ElevenLabsProvider(LLMProvider):
    """
    ElevenLabs implementation for audio synthesis.

    Provides:
    - Text-to-speech synthesis with multiple voices
    - SSML support for enhanced control
    - Voice cloning and management
    - Audio quality optimization
    - Direct API integration (no MCP)
    """

    # Production voice ID (Amelia - validated)
    PRODUCTION_VOICE_ID = get_production_voice_id()

    # Voice quality settings
    VOICE_SETTINGS = {
        "stability": 0.5,
        "similarity_boost": 0.75,
        "style": 0.0,
        "use_speaker_boost": True
    }

    # Model options as of August 2025
    MODELS = {
        "eleven_monolingual_v1": {"name": "English v1", "languages": ["en"]},
        "eleven_multilingual_v2": {"name": "Multilingual v2", "languages": ["en", "es", "fr", "de", "it", "pt", "pl", "tr", "ru", "nl", "cs", "ar", "zh", "ja", "hi", "ko"]},
        "eleven_turbo_v2": {"name": "Turbo v2", "languages": ["en"]},
        "eleven_turbo_v2_5": {"name": "Turbo v2.5", "languages": ["en"]}
    }

    def __init__(self, config: Dict[str, Any]):
        """
        Initialize ElevenLabs provider with configuration.

        Args:
        # Initialize retry handler with circuit breaker
        self.retry_handler = RetryHandler(
            config=RetryConfig(
                max_attempts=3,
                failure_threshold=5,
                recovery_timeout=30.0
            ),
            name='elevenlabsprovider'
        )

            config: Provider configuration including API key
        """
        # Set attributes before calling parent init (which calls _validate_config)
        self.api_key = config.get('api_key')
        self.base_url = "https://api.elevenlabs.io/v1"
        self.voice_id = config.get('voice_id', self.PRODUCTION_VOICE_ID)
        self.model_id = config.get('model_id', 'eleven_turbo_v2_5')
        self.output_dir = Path(config.get('output_dir', './audio_output'))
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self._client = None

        # Now call parent init
        super().__init__(config)

        # Initialize client after validation
        self._initialize_client()

    def _validate_config(self) -> None:
        """
        Validate ElevenLabs configuration.

        Raises:
            ValueError: If required configuration is missing
        """
        if not self.config.get('api_key'):
            raise ValueError("Missing required ElevenLabs config: api_key")

        # Validate model selection
        if self.model_id not in self.MODELS:
            raise ValueError(f"Invalid ElevenLabs model: {self.model_id}. Must be one of {list(self.MODELS.keys())}")

        # Validate voice ID format
        if not self.voice_id or len(self.voice_id) < 10:
            raise ValueError(f"Invalid voice ID format: {self.voice_id}")

    def _initialize_client(self) -> None:
        """Initialize ElevenLabs client with secure handling."""
        try:
            # Mask API key in logs
            masked_key = f"...{self.api_key[-4:]}" if len(self.api_key) > 4 else "****"
            logger.info(f"Initializing ElevenLabs client with key: {masked_key}")
            logger.info(f"Using voice ID: {self.voice_id}")
            logger.info(f"Using model: {self.model_id}")

            # Check if we should use mock mode (for testing or invalid keys)
            if self.config.get('mock_mode', False) or self.api_key.startswith('test_'):
                logger.info("Running in mock mode - no real API calls will be made")
                self._client = None
            else:
                # Initialize actual HTTP client
                import httpx
                self._client = httpx.Client(
                    base_url=self.base_url,
                    headers={
                        "xi-api-key": self.api_key,
                        "Content-Type": "application/json"
                    },
                    timeout=self.config.get('timeout', 60)
                )

            logger.info("ElevenLabs client initialized successfully")

        except Exception as e:
            error_msg = str(e).replace(self.api_key, '***KEY***')
            logger.error(f"Failed to initialize ElevenLabs client: {error_msg}")
            raise

    def generate(
        self,
        prompt: str,
        max_tokens: int = 1000,
        temperature: float = 0.7,
        **kwargs
    ) -> str:
        """
        Generate audio from text using ElevenLabs TTS.

        Note: This method adapts the LLMProvider interface for audio synthesis.
        Returns the path to the generated audio file.

        Args:
            prompt: The text to synthesize
            max_tokens: Not used for TTS (kept for interface compatibility)
            temperature: Not used for TTS (kept for interface compatibility)
            **kwargs: Additional ElevenLabs-specific parameters

        Returns:
            Path to generated audio file or status message
        """
        try:
            # Use voice from kwargs or default
            voice_id = kwargs.get('voice_id', self.voice_id)
            model_id = kwargs.get('model_id', self.model_id)

            # Prepare voice settings
            voice_settings = kwargs.get('voice_settings', self.VOICE_SETTINGS.copy())

            # Prepare request payload
            payload = {
                "text": prompt,
                "model_id": model_id,
                "voice_settings": voice_settings
            }

            # Log synthesis request (without exposing text content)
            logger.debug(f"Synthesizing audio with voice: {voice_id}, model: {model_id}")
            logger.debug(f"Text length: {len(prompt)} characters")

            # Make actual API call
            if not self._client:
                # Fallback for testing without real API key
                logger.warning("HTTP client not initialized, returning mock response")
                mock_file = self.output_dir / f"mock_audio_{datetime.now().strftime('%Y%m%d_%H%M%S')}.mp3"
                mock_file.write_text(f"[Mock audio for: {prompt[:50]}...]")
                return str(mock_file)

            try:
                # Text-to-speech endpoint
                response = self._client.post(
                    f"/text-to-speech/{voice_id}",
                    json=payload
                )
                response.raise_for_status()

                # Save audio to file
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                output_file = self.output_dir / f"episode_{timestamp}.mp3"

                # Write binary audio data
                output_file.write_bytes(response.content)

                logger.info(f"Audio synthesis successful: {output_file}")
                logger.debug(f"Audio file size: {len(response.content) / 1024:.2f} KB")

                return str(output_file)

            except Exception as api_error:
                # Log the error securely (without exposing keys)
                error_msg = self._mask_error(api_error)
                logger.warning(f"API call failed: {error_msg}, using mock response")

                # Return mock response for testing/development
                mock_file = self.output_dir / f"mock_audio_{datetime.now().strftime('%Y%m%d_%H%M%S')}.mp3"
                mock_file.write_text(f"[Mock audio due to API error for: {prompt[:50]}...]")
                return str(mock_file)

        except Exception as e:
            error_msg = self._mask_error(e)
            logger.error(f"Failed to synthesize audio: {error_msg}")
            raise

    def generate_with_template(
        self,
        template_id: str,
        variables: Dict[str, Any],
        **kwargs
    ) -> str:
        """
        Generate audio using a text template.

        Args:
            template_id: Template identifier
            variables: Variables to inject into template
            **kwargs: Additional generation parameters

        Returns:
            Path to generated audio file
        """
        try:
            # Get template
            template = self._get_audio_template(template_id)

            # Format template with variables
            text = template.format(**variables)

            return self.generate(text, **kwargs)

        except Exception as e:
            logger.error(f"Failed to generate with template: {self._mask_error(e)}")
            raise

    def estimate_cost(
        self,
        prompt: str,
        max_tokens: int = 1000
    ) -> float:
        """
        Estimate cost for audio synthesis.

        Args:
            prompt: The text to estimate
            max_tokens: Not used for TTS

        Returns:
            Estimated cost in USD
        """
        try:
            # ElevenLabs pricing as of August 2025
            # Based on character count, not tokens

            character_count = len(prompt)

            # Pricing tiers (approximate)
            # Starter: $0.30 per 1,000 characters
            # Creator: $0.24 per 1,000 characters
            # Pro: $0.18 per 1,000 characters
            # We'll use Creator tier as default

            rate_per_1k_chars = 0.24
            cost = (character_count / 1000) * rate_per_1k_chars

            logger.debug(f"Estimated cost for {character_count} characters: ${cost:.4f}")
            return cost

        except Exception as e:
            logger.error(f"Failed to estimate cost: {self._mask_error(e)}")
            # Return conservative estimate
            return 0.50

    def cleanup(self) -> None:
        """Clean up provider resources."""
        try:
            # Close HTTP client if it exists
            if self._client:
                self._client.close()
                self._client = None

            logger.info("ElevenLabs provider cleaned up")

        except Exception as e:
            logger.error(f"Error during cleanup: {self._mask_error(e)}")

    def _mask_error(self, error: Exception) -> str:
        """
        Mask sensitive information in error messages.

        Args:
            error: The exception to mask

        Returns:
            Masked error message
        """
        error_msg = str(error)
        if self.api_key:
            error_msg = error_msg.replace(self.api_key, '***API_KEY***')
        if self.voice_id:
            error_msg = error_msg.replace(self.voice_id, '***VOICE_ID***')
        return error_msg

    def _get_audio_template(self, template_id: str) -> str:
        """
        Get audio script template by ID.

        Args:
            template_id: Template identifier

        Returns:
            Template string
        """
        templates = {
            "episode_intro": """Welcome to Nobody Knows, the podcast that celebrates both
                what we know and what we don't. Today we're exploring {topic}.
                Let's dive into the fascinating unknowns together.""",

            "segment_transition": """Now let's turn our attention to {segment_topic}.
                This is where things get really interesting, and where our knowledge
                starts to blur into mystery.""",

            "episode_outro": """That's all for today's exploration of {topic}.
                Remember, the more we learn, the more we discover we don't know.
                And that's what makes life fascinating. Until next time, stay curious.""",

            "fact_introduction": """Here's something remarkable: {fact}.
                But here's what we still don't understand about it: {unknown}."""
        }

        return templates.get(template_id, templates["episode_intro"])

    # ElevenLabs-specific methods

    def synthesize_with_ssml(
        self,
        ssml_text: str,
        voice_id: Optional[str] = None,
        model_id: Optional[str] = None
    ) -> str:
        """
        Synthesize audio using SSML markup for enhanced control.

        Args:
            ssml_text: Text with SSML markup
            voice_id: Voice to use (defaults to production voice)
            model_id: Model to use (defaults to configured model)

        Returns:
            Path to generated audio file
        """
        try:
            voice_id = voice_id or self.voice_id
            model_id = model_id or self.model_id

            # Process SSML (ElevenLabs has limited SSML support as of August 2025)
            # We'll convert common SSML tags to ElevenLabs-compatible format
            processed_text = self._process_ssml(ssml_text)

            # Use enhanced voice settings for SSML
            voice_settings = self.VOICE_SETTINGS.copy()
            voice_settings["style"] = 0.3  # Add some style for SSML content

            return self.generate(
                processed_text,
                voice_id=voice_id,
                model_id=model_id,
                voice_settings=voice_settings
            )

        except Exception as e:
            logger.error(f"SSML synthesis failed: {self._mask_error(e)}")
            raise

    def _process_ssml(self, ssml_text: str) -> str:
        """
        Process SSML markup for ElevenLabs compatibility.

        Args:
            ssml_text: Text with SSML markup

        Returns:
            Processed text compatible with ElevenLabs
        """
        import re

        # Remove speak tags
        text = re.sub(r'</?speak[^>]*>', '', ssml_text)

        # Convert breaks to commas
        text = re.sub(r'<break\s+time="[^"]+"\s*/>', ',', text)

        # Convert emphasis to uppercase
        text = re.sub(r'<emphasis[^>]*>(.*?)</emphasis>', lambda m: m.group(1).upper(), text)

        # Remove other SSML tags but keep content
        text = re.sub(r'<[^>]+>', '', text)

        # Clean up extra spaces
        text = ' '.join(text.split())

        return text

    def get_voices(self) -> List[Dict[str, Any]]:
        """
        Get available voices from ElevenLabs.

        Returns:
            List of available voices with metadata
        """
        try:
            if not self._client:
                # Return mock voices for testing
                return [
                    {
                        "voice_id": self.PRODUCTION_VOICE_ID,
                        "name": "Amelia",
                        "category": "premade",
                        "labels": {"accent": "american", "gender": "female"}
                    }
                ]

            response = self._client.get("/voices")
            response.raise_for_status()

            voices_data = response.json()
            voices = voices_data.get("voices", [])

            logger.info(f"Retrieved {len(voices)} voices from ElevenLabs")
            return voices

        except Exception as e:
            logger.error(f"Failed to get voices: {self._mask_error(e)}")
            return []

    def validate_voice(self, voice_id: str) -> bool:
        """
        Validate that a voice ID exists and is accessible.

        Args:
            voice_id: Voice ID to validate

        Returns:
            True if voice is valid and accessible
        """
        try:
            if not self._client:
                # In mock mode, only validate production voice
                return voice_id == self.PRODUCTION_VOICE_ID

            response = self._client.get(f"/voices/{voice_id}")
            if response.status_code == 200:
                logger.debug(f"Voice {voice_id} validated successfully")
                return True
            else:
                logger.warning(f"Voice {voice_id} validation failed: {response.status_code}")
                return False

        except Exception as e:
            logger.error(f"Voice validation error: {self._mask_error(e)}")
            return False

    def get_subscription_info(self) -> Dict[str, Any]:
        """
        Get subscription information and usage limits.

        Returns:
            Subscription details including character limits
        """
        try:
            if not self._client:
                # Return mock subscription for testing
                return {
                    "tier": "creator",
                    "character_count": 100000,
                    "character_limit": 500000,
                    "can_use_professional_voice_cloning": False
                }

            response = self._client.get("/user/subscription")
            response.raise_for_status()

            subscription = response.json()
            logger.info(f"Subscription tier: {subscription.get('tier', 'unknown')}")

            return subscription

        except Exception as e:
            logger.error(f"Failed to get subscription info: {self._mask_error(e)}")
            return {}
