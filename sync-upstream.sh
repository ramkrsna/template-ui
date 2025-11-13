#!/bin/bash

# Sync Upstream Script for template-ui fork
# This script syncs your fork with the upstream repository

set -e

echo "🔄 Syncing fork with upstream repository..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if upstream remote exists
if ! git remote get-url upstream >/dev/null 2>&1; then
    echo "❌ Error: upstream remote not found"
    echo "Run: git remote add upstream https://github.com/redhat-data-and-ai/template-ui.git"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Stash any uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "💾 Stashing uncommitted changes..."
    git stash push -m "Auto-stash before upstream sync $(date)"
    STASHED=true
else
    STASHED=false
fi

# Fetch upstream changes
echo "📥 Fetching upstream changes..."
git fetch upstream

# Switch to main branch
echo "🔀 Switching to main branch..."
git checkout main

# Merge upstream changes
echo "🔄 Merging upstream/main into main..."
git merge upstream/main

# Push changes to origin
echo "📤 Pushing changes to origin..."
git push origin main

# Switch back to original branch if it wasn't main
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "🔀 Switching back to $CURRENT_BRANCH..."
    git checkout "$CURRENT_BRANCH"
    
    # Optionally merge main into current branch
    read -p "🤔 Merge main into $CURRENT_BRANCH? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Merging main into $CURRENT_BRANCH..."
        git merge main
    fi
fi

# Restore stashed changes if any
if [ "$STASHED" = true ]; then
    echo "📤 Restoring stashed changes..."
    git stash pop
fi

echo "✅ Upstream sync completed successfully!"
echo "📋 Summary:"
echo "   - Fetched latest changes from upstream"
echo "   - Merged upstream/main into local main"
echo "   - Pushed updated main to origin"
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "   - Returned to branch: $CURRENT_BRANCH"
fi
