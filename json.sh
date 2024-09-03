#!/bin/bash

# Check if the user provided an input file
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_json_file>"
    exit 1
fi

# Input file from command-line argument
input_json="$1"
output_json="output.json"

# Transform the JSON
jq '{
  cards: [
    .cards[] | {
      name: .name,
      mana_cost: (.mana_cost // ""),
      type: (.type // ""),
      power_toughness: (.power_toughness // ""),
      abilities: (if .abilities then (.abilities | join(", ")) else "" end),
      flavor_text: (.flavor_text // ""),
      rarity: (.rarity // "")
    }
  ]
}' "$input_json" > "$output_json"

echo "JSON transformation complete. Output saved to $output_json"
