#!/usr/bin/env python3
"""
Test chunking algorithm for Episode 1 SSML script
Validates intelligent text chunking without API calls
"""

import re
import os

def chunk_large_text(text: str, max_chunk_size: int = 800) -> list:
    """
    Test the intelligent SSML chunking algorithm

    Args:
        text: SSML formatted text
        max_chunk_size: Maximum characters per chunk

    Returns:
        List of SSML chunks with analysis
    """
    print(f"📝 Analyzing script: {len(text)} characters")

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

    print(f"🔍 Found {len(segments)} segments after SSML splitting")

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
                chunk_text = f'<speak>{current_chunk.strip()}</speak>'
                chunks.append({
                    'content': chunk_text,
                    'size': len(chunk_text),
                    'original_size': len(current_chunk.strip())
                })
            current_chunk = segment + " "

    # Add final chunk
    if current_chunk.strip():
        chunk_text = f'<speak>{current_chunk.strip()}</speak>'
        chunks.append({
            'content': chunk_text,
            'size': len(chunk_text),
            'original_size': len(current_chunk.strip())
        })

    return chunks

def analyze_ssml_complexity(text: str) -> dict:
    """Analyze SSML markup complexity"""
    analysis = {
        'prosody_tags': len(re.findall(r'<prosody[^>]*>', text)),
        'break_tags': len(re.findall(r'<break[^>]*>', text)),
        'emphasis_tags': len(re.findall(r'<emphasis[^>]*>', text)),
        'phoneme_tags': len(re.findall(r'<phoneme[^>]*>', text)),
        'total_markup_chars': len(text) - len(re.sub(r'<[^>]*>', '', text))
    }

    analysis['markup_density'] = analysis['total_markup_chars'] / len(text) * 100

    return analysis

def main():
    """Test chunking with Episode 1 script"""
    print("🧪 Testing SSML Chunking Algorithm")
    print("=" * 50)

    script_path = "/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/sessions/ep_001_production_20250824_231505/production/tts_optimized_script.ssml"

    # Validate and read the script
    try:
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

    print(f"📄 Script loaded: {len(script_content)} characters")

    # Analyze SSML complexity
    complexity = analyze_ssml_complexity(script_content)
    print(f"\n🔍 SSML Complexity Analysis:")
    print(f"   Prosody tags: {complexity['prosody_tags']}")
    print(f"   Break tags: {complexity['break_tags']}")
    print(f"   Emphasis tags: {complexity['emphasis_tags']}")
    print(f"   Phoneme tags: {complexity['phoneme_tags']}")
    print(f"   Markup density: {complexity['markup_density']:.1f}%")

    # Test different chunk sizes
    chunk_sizes = [500, 800, 1200, 1600]

    print(f"\n📊 Chunking Analysis:")
    print("-" * 50)

    for size in chunk_sizes:
        chunks = chunk_large_text(script_content, size)

        total_chars = sum(chunk['size'] for chunk in chunks)
        avg_size = total_chars / len(chunks) if chunks else 0
        min_size = min(chunk['size'] for chunk in chunks) if chunks else 0
        max_size = max(chunk['size'] for chunk in chunks) if chunks else 0

        print(f"Chunk size {size:4d}: {len(chunks):2d} chunks | "
              f"Avg: {avg_size:4.0f} | Min: {min_size:3d} | Max: {max_size:4d}")

    # Detailed analysis for optimal size (800)
    print(f"\n📝 Detailed Analysis (800 char chunks):")
    print("-" * 50)

    optimal_chunks = chunk_large_text(script_content, 800)

    for i, chunk in enumerate(optimal_chunks[:5]):  # Show first 5 chunks
        preview = chunk['content'][:100].replace('\n', ' ')
        print(f"Chunk {i+1:2d}: {chunk['size']:3d} chars | {preview}...")

    if len(optimal_chunks) > 5:
        print(f"... and {len(optimal_chunks)-5} more chunks")

    # Cost estimation
    total_chars = sum(chunk['size'] for chunk in optimal_chunks)
    estimated_cost = total_chars / 1000 * 0.18  # $0.18 per 1k chars

    print(f"\n💰 Cost Estimation:")
    print(f"   Total characters: {total_chars:,}")
    print(f"   Estimated cost: ${estimated_cost:.2f}")
    print(f"   Cost per chunk: ${estimated_cost/len(optimal_chunks):.3f}")

    print("=" * 50)
    print("✅ Chunking algorithm validation complete")

if __name__ == "__main__":
    main()
