#!/bin/bash

# Create a temporary file to hold the merged cards
MERGED_FILE=$(mktemp)

# Initialize the merged cards JSON structure
echo '{"cards":[]}' > "$MERGED_FILE"

# Function to find and merge cards.json files recursively
merge_cards() {
    local dir=$1

    for entry in "$dir"/*; do
        if [ -d "$entry" ]; then
            merge_cards "$entry"
        elif [ -f "$entry" ] && [ "$(basename "$entry")" = "cards.json" ]; then
            jq -s '{cards: (.[0].cards + .[1].cards)}' "$MERGED_FILE" "$entry" > "${MERGED_FILE}.tmp"
            mv "${MERGED_FILE}.tmp" "$MERGED_FILE"
        fi
    done
}

rm ./cards.json

# Start merging from the current directory
merge_cards "."

# Output the merged JSON to the final file
OUTPUT_FILE="./cards.json"
cp "$MERGED_FILE" "$OUTPUT_FILE"

# Clean up
rm "$MERGED_FILE"

echo "Merged JSON saved to $OUTPUT_FILE"
