#!/bin/bash
#
# A script to read selected text or clipboard content aloud using Google's TTS.
# It automatically detects the language of the text.
#
# Dependencies: xclip, gtts-cli, mpg123
#

# --- Pre-flight Checks ---
# Ensure all required commands are available
for cmd in xclip gtts-cli mpg123; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed." >&2
    echo "Please install it to continue." >&2
    exit 1
  fi
done

# kill
pidof mpg123 | xargs kill -9


# Get selected text. Prioritize the primary selection (highlighted text),
# but fall back to the clipboard (copied text).
selected_text=$(xclip -o -selection primary 2>/dev/null) || selected_text=$(xclip -o -selection clipboard 2>/dev/null)

# Check if we actually got any text
if [ -z "$selected_text" ]; then
    echo "No text selected or in clipboard."
    exit 0 # Exit gracefully, not with an error.
fi

# Let the user know what's happening
# To avoid printing very long text to the terminal:
echo "Reading: \"$(echo "$selected_text" | cut -c 1-70)...\""

# Use `set -o pipefail` to ensure the script exits if gtts-cli fails (e.g., no internet)
set -o pipefail

# Play the selected text. gtts-cli will auto-detect the language.
gtts-cli "$selected_text" | mpg123 --quiet -

# Check the exit status of the pipeline for errors
if [ $? -ne 0 ]; then
  echo "Error: Failed to generate or play audio." >&2
  exit 1
fi

echo "Finished."
