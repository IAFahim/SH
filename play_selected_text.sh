#!/bin/bash

# Get selected text from clipboard
selected_text=$(xclip -o -selection clipboard)

# kill
pidof mpg123 | xargs kill -9

# Check if text is selected
if [ -z "$selected_text" ]; then
    echo "No text selected."
    exit 1
fi

# Play the selected text
gtts-cli "$selected_text" | mpg123 -
