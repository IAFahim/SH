#!/bin/bash
#
# A script to read ONLY the currently highlighted text aloud.
# It will ignore the standard (Ctrl+C) clipboard.
#
# Dependencies: xclip, gtts-cli, mpg123
#

# --- Pre-flight Checks ---
for cmd in xclip gtts-cli mpg123; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed." >&2
    exit 1
  fi
done

# kill
pidof mpg123 | xargs kill -9

# Get selected text. ONLY use the primary selection (highlighted text).
selected_text=$(xclip -o -selection primary 2>/dev/null)

# Check if we actually got any text
if [ -z "$selected_text" ]; then
    echo "No text selected." # Changed the message to be more specific
    exit 0
fi

# Let the user know what's happening
echo "Reading selected text: \"$(echo "$selected_text" | cut -c 1-70)...\""

set -o pipefail

# Play the selected text
gtts-cli "$selected_text" | mpg123 --quiet -

if [ $? -ne 0 ]; then
  echo "Error: Failed to generate or play audio." >&2
  exit 1
fi

echo "Finished."
