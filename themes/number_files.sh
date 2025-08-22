#!/usr/bin/env bash
# Desc: Prefix files in a directory with sequential numbers, keeping original name
#       Always uses 2-digit numbering with a hyphen after the number.
# Usage: ./number_files.sh /path/to/directory

dir="${1:-.}"

# Ensure directory exists
if [[ ! -d "$dir" ]]; then
  echo "Error: '$dir' is not a directory."
  exit 1
fi

# Find all numbered files, extract prefix, get the highest number
highest_num=$(find "$dir" -maxdepth 1 -type f \
  -regex '.*/[0-9][0-9]-.*' \
  -printf "%f\n" |
  sed -E 's/^([0-9]{2})-.*/\1/' |
  sort -n | tail -n 1)

# If no numbered files, start numbering from 0
if [[ -z "$highest_num" ]]; then
  highest_num=0
  start_from_zero=true
else
  start_from_zero=false
fi

# Determine starting number
if [[ "$start_from_zero" == true ]]; then
  next_num=0
else
  next_num=$((10#$highest_num + 1))
fi

# Select unnumbered files (no NN- at start) and rename them
find "$dir" -maxdepth 1 -type f \
  ! -regex '.*/[0-9][0-9]-.*' \
  -printf "%f\n" | while read -r fname; do
  new_prefix=$(printf "%02d" "$next_num")
  mv -- "$dir/$fname" "$dir/${new_prefix}-$fname"
  echo "Renamed: $fname -> ${new_prefix}-$fname"
  ((next_num++))
done
