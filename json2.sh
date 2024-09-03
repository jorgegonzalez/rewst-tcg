#!/usr/bin/env bash
# This script generates a CSV file from all `.png` files in each subdirectory
# and a master CSV file in the root directory.

set -e

# Check if directory argument is provided
if [ -z "$1" ]; then
    echo "Please provide the directory path as an argument."
    exit 1
fi

base_url="https://raw.githubusercontent.com/jorgegonzalez/rewst-tcg/main"
root_output_file="output.csv"

# Create the master CSV header with the new columns
echo "name,url,rarity,mana_cost,type,power_toughness,abilities,flavor_text" > "$root_output_file"

# Function to process each directory
process_directory() {
  local dir="$1"
  local output_file="$dir/output.csv"

  # Check if output.csv already exists in the directory
  if [ -f "$output_file" ]; then
    echo "Skipping $dir: $output_file already exists."
    return
  fi

  # Create CSV header for the current directory with new columns
  echo "name,url,rarity,mana_cost,type,power_toughness,abilities,flavor_text" > "$output_file"

  # Find all .png files in the current directory (excluding "Symbols")
  find "$dir" -maxdepth 1 -type f -name "*.png" -not -path "*/Symbols/*" | while IFS= read -r file; do
    echo "Processing file: $file" # Debugging line

    # Get the filename without extension
    filename=$(basename "$file" .png)

    # Encode the path to handle spaces and special characters
    encoded_path=$(echo "$file" | sed 's/ /%20/g;s/\&/%26/g;s/#/%23/g;s/(/%28/g;s/)/%29/g')

    # Create the URL
    url="${base_url}/${encoded_path#./}"
    echo "Adding to CSV: $filename, $url" # Debugging line

    # Append the entry to the subdirectory CSV with null values for new columns
    echo "\"$filename\",\"$url\",\"\",\"\",\"\",\"\",\"\",\"\"" >> "$output_file"

    # Append the entry to the master CSV in the root directory
    echo "\"$filename\",\"$url\",\"\",\"\",\"\",\"\",\"\",\"\"" >> "$root_output_file"
  done
}

# Find all subdirectories and process them
find "$1" -type d ! -path "*/Symbols/*" | while IFS= read -r dir; do
  process_directory "$dir"
done

echo "CSV output has been saved to all subdirectories and consolidated in $root_output_file"
