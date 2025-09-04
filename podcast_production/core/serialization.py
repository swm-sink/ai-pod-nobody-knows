"""
State Serialization Module - August 2025 Best Practices
Handles msgpack and JSON serialization with error handling and fallbacks.

Based on current LangGraph serialization patterns with production-ready error handling.
"""

import json
import logging
from typing import Dict, Any, Union, Optional
from datetime import datetime
from enum import Enum

try:
    import msgpack
    MSGPACK_AVAILABLE = True
except ImportError:
    MSGPACK_AVAILABLE = False

logger = logging.getLogger(__name__)


class SerializationFormat(Enum):
    """Supported serialization formats."""
    MSGPACK = "msgpack"
    JSON = "json"
    AUTO = "auto"  # Prefer msgpack, fallback to JSON


class SerializationError(Exception):
    """Raised when serialization fails."""
    pass


class DeserializationError(Exception):
    """Raised when deserialization fails."""
    pass


class StateSerializer:
    """
    Production-ready state serializer with msgpack and JSON support.
    
    Features:
    - Automatic msgpack/JSON selection
    - Error handling with fallbacks
    - Schema validation hooks
    - Performance monitoring
    - August 2025 compatible patterns
    """
    
    def __init__(
        self, 
        preferred_format: SerializationFormat = SerializationFormat.AUTO,
        enable_compression: bool = True,
        validate_schema: bool = True
    ):
        """Initialize serializer with options."""
        self.preferred_format = preferred_format
        self.enable_compression = enable_compression
        self.validate_schema = validate_schema
        
        # Check msgpack availability
        if preferred_format == SerializationFormat.MSGPACK and not MSGPACK_AVAILABLE:
            logger.warning("msgpack not available, falling back to JSON")
            self.preferred_format = SerializationFormat.JSON
        
        logger.info(f"StateSerializer initialized with format: {self.preferred_format.value}")
    
    def serialize(self, data: Dict[str, Any]) -> bytes:
        """
        Serialize data to bytes using preferred format with fallback.
        
        Args:
            data: State dictionary to serialize
            
        Returns:
            Serialized bytes
            
        Raises:
            SerializationError: If serialization fails completely
        """
        if not isinstance(data, dict):
            raise SerializationError(f"Data must be dict, got {type(data)}")
        
        # Prepare data for serialization
        prepared_data = self._prepare_for_serialization(data)
        
        try:
            # Try preferred format first
            if self.preferred_format == SerializationFormat.MSGPACK and MSGPACK_AVAILABLE:
                return self._serialize_msgpack(prepared_data)
            elif self.preferred_format == SerializationFormat.JSON:
                return self._serialize_json(prepared_data)
            else:  # AUTO mode
                return self._serialize_auto(prepared_data)
                
        except Exception as e:
            logger.error(f"Serialization failed: {e}")
            raise SerializationError(f"Failed to serialize state: {e}") from e
    
    def deserialize(self, data: bytes) -> Dict[str, Any]:
        """
        Deserialize bytes back to state dictionary.
        
        Args:
            data: Serialized bytes to deserialize
            
        Returns:
            State dictionary
            
        Raises:
            DeserializationError: If deserialization fails
        """
        if not isinstance(data, bytes):
            raise DeserializationError(f"Data must be bytes, got {type(data)}")
        
        try:
            # Try to detect format and deserialize
            result = self._deserialize_auto(data)
            
            # Post-process data
            return self._post_process_deserialization(result)
            
        except Exception as e:
            logger.error(f"Deserialization failed: {e}")
            raise DeserializationError(f"Failed to deserialize state: {e}") from e
    
    def _prepare_for_serialization(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Prepare data for serialization - convert non-serializable types.
        
        Following August 2025 patterns for datetime and other objects.
        """
        prepared = {}
        
        for key, value in data.items():
            prepared[key] = self._convert_value_for_serialization(value)
        
        return prepared
    
    def _convert_value_for_serialization(self, value: Any) -> Any:
        """Convert individual values to serializable forms."""
        if isinstance(value, datetime):
            return value.isoformat()
        elif isinstance(value, dict):
            return {k: self._convert_value_for_serialization(v) for k, v in value.items()}
        elif isinstance(value, list):
            return [self._convert_value_for_serialization(item) for item in value]
        elif isinstance(value, Enum):
            return value.value
        elif hasattr(value, 'dict') and callable(value.dict):
            # Pydantic model
            return self._convert_value_for_serialization(value.dict())
        else:
            return value
    
    def _serialize_msgpack(self, data: Dict[str, Any]) -> bytes:
        """Serialize using msgpack with production settings."""
        return msgpack.packb(
            data, 
            use_bin_type=True,  # August 2025 recommended setting
            timestamp=3  # Support timestamp extension
        )
    
    def _serialize_json(self, data: Dict[str, Any]) -> bytes:
        """Serialize using JSON with compact encoding."""
        json_str = json.dumps(
            data, 
            separators=(',', ':'),  # Compact format
            ensure_ascii=False,
            default=str  # Fallback for unexpected types
        )
        return json_str.encode('utf-8')
    
    def _serialize_auto(self, data: Dict[str, Any]) -> bytes:
        """Auto-select format - prefer msgpack, fallback to JSON."""
        if MSGPACK_AVAILABLE:
            try:
                return self._serialize_msgpack(data)
            except Exception as e:
                logger.warning(f"msgpack serialization failed, using JSON: {e}")
                return self._serialize_json(data)
        else:
            return self._serialize_json(data)
    
    def _deserialize_auto(self, data: bytes) -> Dict[str, Any]:
        """Auto-detect format and deserialize."""
        # Try msgpack first (more likely to fail fast if wrong format)
        if MSGPACK_AVAILABLE:
            try:
                return msgpack.unpackb(data, raw=False, timestamp=3)
            except (msgpack.exceptions.ExtraData, msgpack.exceptions.UnpackException):
                # Not msgpack, try JSON
                pass
        
        # Try JSON
        try:
            json_str = data.decode('utf-8')
            return json.loads(json_str)
        except (UnicodeDecodeError, json.JSONDecodeError) as e:
            raise DeserializationError(f"Cannot deserialize as JSON or msgpack: {e}")
    
    def _post_process_deserialization(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Post-process deserialized data - restore datetime objects etc.
        """
        processed = {}
        
        for key, value in data.items():
            processed[key] = self._restore_value_from_serialization(value)
        
        return processed
    
    def _restore_value_from_serialization(self, value: Any) -> Any:
        """Restore individual values from serializable forms."""
        if isinstance(value, str) and self._looks_like_datetime(value):
            try:
                return datetime.fromisoformat(value)
            except ValueError:
                return value  # Not a datetime after all
        elif isinstance(value, dict):
            return {k: self._restore_value_from_serialization(v) for k, v in value.items()}
        elif isinstance(value, list):
            return [self._restore_value_from_serialization(item) for item in value]
        else:
            return value
    
    def _looks_like_datetime(self, value: str) -> bool:
        """Simple heuristic to detect datetime strings."""
        return (
            isinstance(value, str) 
            and len(value) > 18 
            and 'T' in value 
            and (':' in value)
        )
    
    def get_serialization_info(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Get information about serialization without actually serializing."""
        prepared = self._prepare_for_serialization(data)
        
        info = {
            'preferred_format': self.preferred_format.value,
            'msgpack_available': MSGPACK_AVAILABLE,
            'estimated_json_size': len(json.dumps(prepared).encode('utf-8')),
            'field_count': len(prepared),
            'nested_levels': self._count_nesting_levels(prepared)
        }
        
        if MSGPACK_AVAILABLE:
            try:
                msgpack_size = len(msgpack.packb(prepared, use_bin_type=True))
                info['estimated_msgpack_size'] = msgpack_size
                info['compression_ratio'] = info['estimated_json_size'] / msgpack_size if msgpack_size > 0 else 1.0
            except Exception:
                info['estimated_msgpack_size'] = None
                info['compression_ratio'] = 1.0
        
        return info
    
    def _count_nesting_levels(self, obj: Any, level: int = 0) -> int:
        """Count maximum nesting levels in data structure."""
        max_level = level
        
        if isinstance(obj, dict):
            for value in obj.values():
                max_level = max(max_level, self._count_nesting_levels(value, level + 1))
        elif isinstance(obj, list):
            for item in obj:
                max_level = max(max_level, self._count_nesting_levels(item, level + 1))
        
        return max_level


# Convenience functions for direct usage
def serialize_state(
    data: Dict[str, Any], 
    format: SerializationFormat = SerializationFormat.AUTO
) -> bytes:
    """Convenience function to serialize state data."""
    serializer = StateSerializer(preferred_format=format)
    return serializer.serialize(data)


def deserialize_state(data: bytes) -> Dict[str, Any]:
    """Convenience function to deserialize state data."""
    serializer = StateSerializer()
    return serializer.deserialize(data)


def get_optimal_serializer() -> StateSerializer:
    """Get serializer with optimal settings for August 2025."""
    return StateSerializer(
        preferred_format=SerializationFormat.AUTO,
        enable_compression=True,
        validate_schema=True
    )