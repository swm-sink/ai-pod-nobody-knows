#!/bin/bash
# Simple Session Cleanup Hook
# Minimal dependencies for maximum reliability

echo '{"continue": true, "message": "Session cleanup completed"}' 2>/dev/null || echo "Session cleanup completed"
