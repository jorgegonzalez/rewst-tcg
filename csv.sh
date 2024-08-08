#!/bin/bash

# Check if jq and csvkit are installed
if ! command -v jq &> /dev/null || ! command -v csvformat &> /dev/null; then
    echo "jq and csvkit need to be installed. Install them with:"
    echo "sudo apt-get install jq csvkit"
    exit 1
fi

rm -f cards.csv

# Input and output file names
input_json="cards.json"
output_csv="cards.csv"

# Extract the data and create a CSV
jq -r '
    ["name", "type", "mana_cost", "power_toughness", "abilities", "flavor_text", "rarity"], # Header row
    (.cards[] |
    [
        .name // "",
        .type // "",
        .mana_cost // "",
        .power_toughness // "",
        (.abilities // [] | join("; ")),  # Handles array of text and joins them with a semicolon
        .flavor_text // "",
        .rarity // ""
    ]) | @csv
' $input_json > $output_csv

echo "CSV generated successfully as $output_csv"
