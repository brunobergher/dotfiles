#!/bin/bash

# Git Worktree Cleanup Script
# Finds and removes stale git worktrees (last commit > 14 days old)
# Excludes worktrees with uncommitted changes (dirty state)

set -e

# Configuration
DAYS_THRESHOLD=14
SECONDS_THRESHOLD=$((DAYS_THRESHOLD * 24 * 60 * 60))

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Arrays to store worktrees
declare -a WORKTREES_TO_DELETE=()
declare -a WORKTREE_SIZES=()
declare -a WORKTREE_AGES=()
declare -a SKIPPED_DIRTY=()

# Convert bytes to human readable format
human_size() {
    local bytes=$1
    if [[ $bytes -ge 1073741824 ]]; then
        echo "$(echo "scale=2; $bytes / 1073741824" | bc)GB"
    elif [[ $bytes -ge 1048576 ]]; then
        echo "$(echo "scale=2; $bytes / 1048576" | bc)MB"
    elif [[ $bytes -ge 1024 ]]; then
        echo "$(echo "scale=2; $bytes / 1024" | bc)KB"
    else
        echo "${bytes}B"
    fi
}

# Convert seconds to human readable duration
human_duration() {
    local seconds=$1
    local days=$((seconds / 86400))
    if [[ $days -eq 1 ]]; then
        echo "1 day"
    else
        echo "$days days"
    fi
}

# Draw progress bar
draw_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=0
    local filled=0
    local empty=0
    
    if [[ $total -gt 0 ]]; then
        percentage=$((current * 100 / total))
        filled=$((current * width / total))
    fi
    empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${percentage}%%${NC} "
}

# Check if a directory is a git worktree
is_worktree() {
    local dir=$1
    local git_file="$dir/.git"
    
    # Worktrees have a .git file (not directory) pointing to the main repo
    if [[ -f "$git_file" ]]; then
        local content=$(cat "$git_file")
        if [[ "$content" == gitdir:* ]]; then
            return 0
        fi
    fi
    return 1
}

# Check if worktree has uncommitted changes
is_dirty() {
    local dir=$1
    local status=$(git -C "$dir" status --porcelain 2>/dev/null)
    [[ -n "$status" ]]
}

# Get last commit timestamp
get_last_commit_time() {
    local dir=$1
    git -C "$dir" log -1 --format=%ct 2>/dev/null || echo "0"
}

# Get directory size in bytes
get_dir_size() {
    local dir=$1
    # du -sk gives size in KB, multiply by 1024 for bytes
    local size_kb=$(du -sk "$dir" 2>/dev/null | cut -f1)
    echo $((size_kb * 1024))
}

echo -e "${BOLD}${BLUE}🔍 Scanning for git worktrees...${NC}"
echo ""

# Find all potential worktrees (directories with .git file)
current_time=$(date +%s)
total_found=0
scanned=0

# First pass: find all .git files that are regular files (worktree indicators)
while IFS= read -r git_file; do
    dir=$(dirname "$git_file")
    
    # Skip if not a valid worktree
    if ! is_worktree "$dir"; then
        continue
    fi
    
    ((total_found++))
    
    # Get last commit time
    last_commit=$(get_last_commit_time "$dir")
    if [[ "$last_commit" == "0" ]]; then
        continue
    fi
    
    age=$((current_time - last_commit))
    
    # Check if older than threshold
    if [[ $age -lt $SECONDS_THRESHOLD ]]; then
        continue
    fi
    
    # Check if dirty
    if is_dirty "$dir"; then
        SKIPPED_DIRTY+=("$dir")
        continue
    fi
    
    # Get size and add to deletion list
    size=$(get_dir_size "$dir")
    WORKTREES_TO_DELETE+=("$dir")
    WORKTREE_SIZES+=("$size")
    WORKTREE_AGES+=("$age")
    
done < <(find . -name ".git" -type f 2>/dev/null)

# Summary
echo -e "${GRAY}Found $total_found worktree(s) total${NC}"
echo ""

# Report skipped dirty worktrees
if [[ ${#SKIPPED_DIRTY[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Skipped ${#SKIPPED_DIRTY[@]} worktree(s) with uncommitted changes:${NC}"
    for dir in "${SKIPPED_DIRTY[@]}"; do
        echo -e "   ${GRAY}• $dir${NC}"
    done
    echo ""
fi

# Check if anything to delete
if [[ ${#WORKTREES_TO_DELETE[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ No stale worktrees to clean up!${NC}"
    exit 0
fi

# Calculate total size
total_size=0
for size in "${WORKTREE_SIZES[@]}"; do
    total_size=$((total_size + size))
done

# Display worktrees to delete
echo -e "${RED}${BOLD}📋 Worktrees to delete (older than $DAYS_THRESHOLD days):${NC}"
echo ""

for i in "${!WORKTREES_TO_DELETE[@]}"; do
    dir="${WORKTREES_TO_DELETE[$i]}"
    size="${WORKTREE_SIZES[$i]}"
    age="${WORKTREE_AGES[$i]}"
    
    human_age=$(human_duration "$age")
    human_sz=$(human_size "$size")
    
    # Get branch name if possible
    branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    
    echo -e "   ${RED}✗${NC} ${BOLD}$dir${NC}"
    echo -e "     ${GRAY}Branch: $branch | Age: $human_age | Size: $human_sz${NC}"
done

echo ""
echo -e "${BOLD}Total space to reclaim: $(human_size $total_size)${NC}"
echo ""

# Ask for confirmation
echo -e -n "${YELLOW}${BOLD}Delete these ${#WORKTREES_TO_DELETE[@]} worktree(s)? [y/N] ${NC}"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${GRAY}Aborted.${NC}"
    exit 0
fi

echo ""
echo -e "${BOLD}${BLUE}🗑️  Deleting worktrees...${NC}"
echo ""

# Delete with progress bar
deleted_size=0
deleted_count=0

for i in "${!WORKTREES_TO_DELETE[@]}"; do
    dir="${WORKTREES_TO_DELETE[$i]}"
    size="${WORKTREE_SIZES[$i]}"
    
    # Draw progress bar
    draw_progress_bar "$deleted_size" "$total_size"
    echo -e -n "Deleting: ${GRAY}$(basename "$dir")${NC}                    "
    
    # Try git worktree remove first
    if git worktree remove --force "$dir" 2>/dev/null; then
        ((deleted_count++))
    else
        # Fallback: manual removal
        rm -rf "$dir" 2>/dev/null && ((deleted_count++))
    fi
    
    deleted_size=$((deleted_size + size))
done

# Final progress bar at 100%
draw_progress_bar "$total_size" "$total_size"
echo ""
echo ""

# Summary
echo -e "${GREEN}${BOLD}✓ Cleanup complete!${NC}"
echo -e "  ${GRAY}Deleted: $deleted_count worktree(s)${NC}"
echo -e "  ${GRAY}Reclaimed: $(human_size $total_size)${NC}"
