#!/usr/bin/env bash
# Claude Code status line — inspired by Spaceship prompt theme
# Receives JSON via stdin

input=$(cat)

user=$(whoami)
host=$(hostname -s)
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir=$(pwd)
basename_dir=$(basename "$dir")

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
cur_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
cur_cache=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')

# Git branch (skip optional lock to avoid blocking)
git_branch=""
if git -C "$dir" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  git_branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
fi

# Colors (dim-friendly ANSI)
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
MAGENTA="\033[0;35m"
BLUE="\033[0;34m"
RESET="\033[0m"
DIM="\033[2m"

# Helper: format a raw token count as e.g. "42k" or "1.2m"
fmt_tokens() {
  local n="$1"
  if [ -z "$n" ] || [ "$n" = "null" ]; then echo "?"; return; fi
  if   [ "$n" -ge 1000000 ] 2>/dev/null; then
    printf "%.1fm" "$(echo "scale=1; $n / 1000000" | bc)"
  elif [ "$n" -ge 1000 ]    2>/dev/null; then
    printf "%dk"  "$(( n / 1000 ))"
  else
    printf "%d"   "$n"
  fi
}

# Build the status line
line=""

# user@host
line+="$(printf "${CYAN}%s${RESET}@${CYAN}%s${RESET}" "$user" "$host")"

# directory
line+=" $(printf "${YELLOW}%s${RESET}" "$basename_dir")"

# git branch
if [ -n "$git_branch" ]; then
  line+=" $(printf "${GREEN}on${RESET} ${MAGENTA}%s${RESET}" "$git_branch")"
fi

# model
if [ -n "$model" ]; then
  line+=" $(printf "| ${BLUE}%s${RESET}" "$model")"
fi

# context usage — progress bar + token numbers + percentage
if [ -n "$used" ]; then
  used_int=${used%.*}

  # Pick color based on threshold
  if [ "$used_int" -ge 80 ] 2>/dev/null; then
    CTX_COLOR="\033[0;31m"
  elif [ "$used_int" -ge 50 ] 2>/dev/null; then
    CTX_COLOR="\033[0;33m"
  else
    CTX_COLOR="\033[0;32m"
  fi

  # Build a 10-cell progress bar (▓ filled, ░ empty)
  bar_width=10
  filled=$(( used_int * bar_width / 100 ))
  [ "$filled" -gt "$bar_width" ] && filled=$bar_width
  empty=$(( bar_width - filled ))
  bar=""
  for i in $(seq 1 "$filled"); do bar+="▓"; done
  for i in $(seq 1 "$empty");  do bar+="░"; done

  # Resolve the best "used tokens" figure:
  #   prefer current_usage.input_tokens + cache_read if present,
  #   otherwise fall back to total_input_tokens.
  used_tokens=""
  if [ -n "$cur_input" ] && [ "$cur_input" != "null" ]; then
    cache_add=0
    if [ -n "$cur_cache" ] && [ "$cur_cache" != "null" ]; then
      cache_add=$cur_cache
    fi
    used_tokens=$(( cur_input + cache_add ))
  elif [ -n "$total_input" ] && [ "$total_input" != "null" ]; then
    used_tokens=$total_input
  fi

  used_fmt=$(fmt_tokens "$used_tokens")
  ctx_fmt=$(fmt_tokens  "$ctx_size")

  line+=" $(printf "${CTX_COLOR}%s${RESET} ${DIM}%s/%s${RESET} ${CTX_COLOR}%s%%${RESET}" \
    "$bar" "$used_fmt" "$ctx_fmt" "$used_int")"
fi

printf "%b\n" "$line"
