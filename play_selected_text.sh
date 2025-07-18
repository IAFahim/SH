#!/bin/bash
#
# A script to read selected text aloud, combining the best features
# of previous versions. It uses desktop notifications for feedback.
#
# Dependencies: xclip, gtts-cli, mpg123, notify-send (libnotify-bin)
#

# --- Configuration & Strict Mode ---
# Exit on error, error on unset variables, and fail pipelines on first error.
set -euo pipefail

# --- Pre-flight Checks ---
# Ensure all required commands are available
for cmd in xclip gtts-cli mpg123 notify-send; do
  if ! command -v "$cmd" &> /dev/null; then
    # Use notify-send for the error itself if it's available!
    if command -v notify-send &> /dev/null; then
      notify-send -u critical "Script Error" "Required command '$cmd' is not installed. Please install it."
    else
      echo "Error: Required command '$cmd' is not installed." >&2
    fi
    exit 1
  fi
done

# --- Main Logic ---
# Stop any currently playing audio from this script gracefully.
# The `|| true` prevents the script from exiting if no process is found.
pkill -f mpg123 || true

# Get selected text. Prioritize primary (highlighted) and fall back to clipboard (copied).
selected_text=$(xclip -o -selection primary 2>/dev/null) || selected_text=$(xclip -o -selection clipboard 2>/dev/null)

# Check if we actually got any text
if [[ -z "$selected_text" ]]; then
    notify-send -u normal "Text-to-Speech" "No text selected or in clipboard."
    exit 0
fi

# Optional: Validate that the input is printable text (from your script!)
# This is good practice but can be commented out if it causes issues with some languages.
if ! [[ "$selected_text" =~ ^[[:print:][:space:]]+$ ]]; then
    notify-send -u normal "Text-to-Speech" "Selection contains non-text data. Skipping."
    exit 0
fi

# Notify the user what's happening.
# Using -t to set a timeout in milliseconds (e.g., 3000ms = 3s)
notify-send -t 3000 "Reading Aloud..." "$(echo "$selected_text" | cut -c 1-100)..."

# Play the selected text. gtts-cli will auto-detect the language.
# The `||` part will catch failures from either gtts-cli or mpg123.
gtts-cli "$selected_text" | mpg123 --quiet - || {
  exit 1
}
