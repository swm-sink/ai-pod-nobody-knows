#!/usr/bin/env python3
"""
Episode Archival Management System
Archives episodes older than specified days to compressed storage.
September 2025 implementation.
"""

import os
import json
import shutil
import tarfile
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
import argparse
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class EpisodeArchiver:
    """Manages tiered storage of podcast episodes"""
    
    def __init__(self, base_dir: str = "."):
        self.base_dir = Path(base_dir)
        self.production_dir = self.base_dir / "production"
        self.active_dir = self.base_dir / "active"
        self.recent_dir = self.base_dir / "recent"
        self.archive_dir = self.base_dir / "archive"
        self.metadata_file = self.base_dir / "metadata.json"
        
        # Create directories if they don't exist
        for dir_path in [self.active_dir, self.recent_dir, self.archive_dir]:
            dir_path.mkdir(parents=True, exist_ok=True)
    
    def load_metadata(self) -> Dict:
        """Load episode metadata index"""
        if self.metadata_file.exists():
            with open(self.metadata_file, 'r') as f:
                return json.load(f)
        return {"episodes": {}, "last_archive": None}
    
    def save_metadata(self, metadata: Dict):
        """Save episode metadata index"""
        metadata["last_archive"] = datetime.now().isoformat()
        with open(self.metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)
    
    def get_episode_age(self, episode_path: Path) -> int:
        """Get age of episode in days"""
        stat = episode_path.stat()
        age = datetime.now() - datetime.fromtimestamp(stat.st_mtime)
        return age.days
    
    def scan_episodes(self) -> Dict[str, List[Path]]:
        """Scan and categorize episodes by age"""
        episodes = {
            "active": [],    # Last 10 episodes or < 7 days
            "recent": [],    # 7-30 days old
            "archive": []    # > 30 days old
        }
        
        if not self.production_dir.exists():
            logger.warning(f"Production directory not found: {self.production_dir}")
            return episodes
        
        # Get all episode directories
        all_episodes = sorted(
            [d for d in self.production_dir.iterdir() if d.is_dir()],
            key=lambda x: x.stat().st_mtime,
            reverse=True  # Newest first
        )
        
        for idx, episode_dir in enumerate(all_episodes):
            age_days = self.get_episode_age(episode_dir)
            
            if idx < 10 or age_days < 7:
                episodes["active"].append(episode_dir)
            elif age_days < 30:
                episodes["recent"].append(episode_dir)
            else:
                episodes["archive"].append(episode_dir)
        
        return episodes
    
    def move_to_tier(self, episode_path: Path, tier: str):
        """Move episode to appropriate tier"""
        if tier == "active":
            dest = self.active_dir / episode_path.name
        elif tier == "recent":
            dest = self.recent_dir / episode_path.name
        elif tier == "archive":
            # For archive, we compress first
            return self.compress_and_archive(episode_path)
        else:
            raise ValueError(f"Invalid tier: {tier}")
        
        # Move directory
        if dest.exists():
            logger.info(f"Episode already in {tier}: {episode_path.name}")
            return dest
        
        shutil.move(str(episode_path), str(dest))
        logger.info(f"Moved {episode_path.name} to {tier}")
        return dest
    
    def compress_and_archive(self, episode_path: Path) -> Path:
        """Compress episode and move to archive"""
        archive_name = f"{episode_path.name}.tar.gz"
        archive_path = self.archive_dir / archive_name
        
        if archive_path.exists():
            logger.info(f"Already archived: {archive_name}")
            return archive_path
        
        # Create compressed archive
        logger.info(f"Compressing {episode_path.name}...")
        with tarfile.open(archive_path, "w:gz") as tar:
            tar.add(episode_path, arcname=episode_path.name)
        
        # Calculate compression ratio
        original_size = sum(
            f.stat().st_size for f in episode_path.rglob("*") if f.is_file()
        )
        compressed_size = archive_path.stat().st_size
        ratio = (1 - compressed_size / original_size) * 100
        
        logger.info(f"Compressed {episode_path.name} - {ratio:.1f}% reduction")
        
        # Remove original after successful compression
        shutil.rmtree(episode_path)
        
        return archive_path
    
    def organize_episodes(self, dry_run: bool = False):
        """Organize all episodes into appropriate tiers"""
        episodes = self.scan_episodes()
        metadata = self.load_metadata()
        
        # Statistics
        stats = {
            "moved_to_active": 0,
            "moved_to_recent": 0,
            "archived": 0,
            "space_saved_mb": 0
        }
        
        # Process each tier
        for tier, episode_list in episodes.items():
            for episode_path in episode_list:
                if dry_run:
                    logger.info(f"[DRY RUN] Would move {episode_path.name} to {tier}")
                else:
                    # Track original size for archive operations
                    if tier == "archive":
                        original_size = sum(
                            f.stat().st_size for f in episode_path.rglob("*") if f.is_file()
                        )
                    
                    # Move to appropriate tier
                    new_path = self.move_to_tier(episode_path, tier)
                    
                    # Update metadata
                    metadata["episodes"][episode_path.name] = {
                        "tier": tier,
                        "path": str(new_path),
                        "archived_date": datetime.now().isoformat(),
                        "age_days": self.get_episode_age(episode_path)
                    }
                    
                    # Update statistics
                    if tier == "active":
                        stats["moved_to_active"] += 1
                    elif tier == "recent":
                        stats["moved_to_recent"] += 1
                    elif tier == "archive":
                        stats["archived"] += 1
                        compressed_size = new_path.stat().st_size
                        stats["space_saved_mb"] += (original_size - compressed_size) / (1024 * 1024)
        
        if not dry_run:
            self.save_metadata(metadata)
        
        # Print summary
        logger.info("\n" + "="*50)
        logger.info("Archive Summary:")
        logger.info(f"  Active episodes: {stats['moved_to_active']}")
        logger.info(f"  Recent episodes: {stats['moved_to_recent']}")
        logger.info(f"  Archived episodes: {stats['archived']}")
        logger.info(f"  Space saved: {stats['space_saved_mb']:.1f} MB")
        logger.info("="*50)
        
        return stats
    
    def restore_episode(self, episode_name: str, destination: str = "production"):
        """Restore an archived episode"""
        metadata = self.load_metadata()
        
        if episode_name not in metadata["episodes"]:
            raise ValueError(f"Episode not found: {episode_name}")
        
        episode_info = metadata["episodes"][episode_name]
        source_path = Path(episode_info["path"])
        
        if not source_path.exists():
            raise FileNotFoundError(f"Episode file not found: {source_path}")
        
        # Determine destination
        if destination == "production":
            dest_dir = self.production_dir
        elif destination == "active":
            dest_dir = self.active_dir
        else:
            dest_dir = Path(destination)
        
        dest_path = dest_dir / episode_name
        
        # If archived (compressed), extract
        if episode_info["tier"] == "archive" and source_path.suffix == ".gz":
            logger.info(f"Extracting {episode_name} from archive...")
            with tarfile.open(source_path, "r:gz") as tar:
                tar.extractall(dest_dir)
            logger.info(f"Restored {episode_name} to {dest_dir}")
        else:
            # Just move the directory
            shutil.move(str(source_path), str(dest_path))
            logger.info(f"Moved {episode_name} to {dest_dir}")
        
        # Update metadata
        metadata["episodes"][episode_name]["tier"] = destination
        metadata["episodes"][episode_name]["path"] = str(dest_path)
        metadata["episodes"][episode_name]["restored_date"] = datetime.now().isoformat()
        self.save_metadata(metadata)
        
        return dest_path
    
    def cleanup_old_archives(self, keep_days: int = 365):
        """Remove archives older than specified days"""
        removed = []
        
        for archive_file in self.archive_dir.glob("*.tar.gz"):
            age_days = self.get_episode_age(archive_file)
            if age_days > keep_days:
                logger.info(f"Removing old archive: {archive_file.name} ({age_days} days old)")
                archive_file.unlink()
                removed.append(archive_file.name)
        
        if removed:
            # Update metadata
            metadata = self.load_metadata()
            for episode_name in removed:
                episode_key = episode_name.replace(".tar.gz", "")
                if episode_key in metadata["episodes"]:
                    del metadata["episodes"][episode_key]
            self.save_metadata(metadata)
        
        logger.info(f"Removed {len(removed)} old archives")
        return removed


def main():
    parser = argparse.ArgumentParser(description="Episode Archival Management")
    parser.add_argument(
        "--dir", 
        default=".",
        help="Base directory for episodes (default: current directory)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview actions without making changes"
    )
    parser.add_argument(
        "--restore",
        help="Restore an archived episode by name"
    )
    parser.add_argument(
        "--cleanup",
        type=int,
        help="Remove archives older than N days"
    )
    parser.add_argument(
        "--destination",
        default="production",
        help="Destination for restored episodes (default: production)"
    )
    
    args = parser.parse_args()
    
    archiver = EpisodeArchiver(args.dir)
    
    if args.restore:
        # Restore mode
        restored = archiver.restore_episode(args.restore, args.destination)
        print(f"Successfully restored: {restored}")
    elif args.cleanup:
        # Cleanup mode
        removed = archiver.cleanup_old_archives(args.cleanup)
        print(f"Cleaned up {len(removed)} old archives")
    else:
        # Archive mode
        stats = archiver.organize_episodes(dry_run=args.dry_run)
        if args.dry_run:
            print("\nThis was a dry run. No changes were made.")


if __name__ == "__main__":
    main()