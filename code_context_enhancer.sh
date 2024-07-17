#!/bin/bash

# Display warning message
echo "⚠️  WARNING ⚠️"
echo "This script will modify file structures and generate new files."
echo "It may overwrite existing files in the destination directory."
echo "Please ensure you have backed up your data before proceeding."
echo ""
read -p "Do you understand and wish to continue? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Operation cancelled."
    exit 1
fi
echo ""

# Function to prompt for input with a default value and validate
prompt_and_validate() {
    local prompt="$1"
    local default="$2"
    local validation_func="$3"
    local response

    while true; do
        read -p "$prompt [$default]: " response
        response="${response:-$default}"
        if $validation_func "$response"; then
            echo "$response"
            return 0
        else
            echo "Invalid input. Please try again."
        fi
    done
}

# Validation functions
validate_api_key() {
    [ ${#1} -ge 10 ]
}

validate_directory() {
    [ -d "$1" ]
}

validate_file_types() {
    [ "$1" = "all" ] || [[ "$1" =~ ^[a-zA-Z0-9]+(,[a-zA-Z0-9]+)*$ ]]
}

validate_process_type() {
    [[ "$1" =~ ^[mM]$ ]] || [[ "$1" =~ ^[iI]$ ]]
}

validate_output_file_type() {
    [[ "$1" =~ ^[a-zA-Z0-9]+$ ]]
}

validate_yes_no() {
    [[ "$1" =~ ^[yYnN]$ ]]
}

# Function to generate descriptions using Anthropic Claude's Messages API
generate_description() {
    local file_content="$1"
    local description

    # Escape special characters in the file content
    escaped_content=$(printf '%s' "$file_content" | jq -sR .)

    # Make API call to Anthropic Claude
    response=$(curl -s https://api.anthropic.com/v1/messages \
         --header "x-api-key: $ANTHROPIC_API_KEY" \
         --header "anthropic-version: 2023-06-01" \
         --header "content-type: application/json" \
         --data @- << EOF
{
    "model": "claude-3-haiku-20240307",
    "max_tokens": 1024,
    "messages": [
        {
            "role": "user",
            "content": "Briefly describe the functionality and purpose of this script in one sentence:\n\n$(echo $escaped_content | sed 's/^"//; s/"$//')"
        }
    ]
}
EOF
    )

    # Check for API errors
    if [[ $response == *"error"* ]] && [[ $response != *"content"* ]]; then
        echo "API Error: $response" >&2
        return 1
    fi

    # Extract description from API response
    description=$(echo "$response" | jq -r '.content[0].text' 2>/dev/null)

    # Check if description was successfully extracted
    if [ -z "$description" ] || [ "$description" == "null" ]; then
        echo "Failed to extract description from API response" >&2
        return 1
    else
        echo "$description"
    fi
}

# Function to get manual description input
get_manual_description() {
    local file_path="$1"
    local description

    echo "Would you like to enter a manual description for $file_path? (Y/N)" >&2
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Please enter a brief description (press Enter without typing to skip):" >&2
        read -r description
        if [ -z "$description" ]; then
            description="No description available."
        fi
    else
        description="No description available."
    fi

    echo "$description"
}

# Function to generate description with retry and manual input option
generate_description_with_retry() {
    local file_content="$1"
    local file_path="$2"
    local max_retries=3
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        description=$(generate_description "$file_content")
        if [ $? -eq 0 ]; then
            echo "$description"
            return 0
        fi
        ((retry_count++))
        echo "Retrying description generation for $file_path (attempt $retry_count of $max_retries)..." >&2
        sleep 2
    done

    echo "Failed to generate description for: $file_path" >&2
    get_manual_description "$file_path"
}

# Function to estimate total files
estimate_total_files() {
    local total=$(find "$SOURCE_DIR" -type f -name "$file_filter" | wc -l)
    echo "$total"
}

# User prompts
SOURCE_DIR=$(prompt_and_validate "Source folder" "./src" validate_directory)

DEST_DIR=$(prompt_and_validate "Destination folder" "." validate_directory)

FILE_TYPES=$(prompt_and_validate "File types to process (comma-separated, or 'all' for all types)" "all" validate_file_types)

PROCESS_TYPE=$(prompt_and_validate "Process files ([M]erged/[I]ndividual)" "M" validate_process_type)
PROCESS_TYPE=$(echo "$PROCESS_TYPE" | tr '[:upper:]' '[:lower:]')

echo "Description generation uses AI via Anthropic's API and requires an API key."
GENERATE_DESCRIPTIONS=$(prompt_and_validate "Generate AI descriptions? ([Y]es/[N]o)" "Y" validate_yes_no)
GENERATE_DESCRIPTIONS=$(echo "$GENERATE_DESCRIPTIONS" | tr '[:upper:]' '[:lower:]')

if [ "$GENERATE_DESCRIPTIONS" = "y" ]; then
    read -sp "Please enter Anthropic API Key: " ANTHROPIC_API_KEY
    echo
    if ! validate_api_key "$ANTHROPIC_API_KEY"; then
        echo "Error: Invalid API key. It should be at least 10 characters long."
        exit 1
    fi
fi

if [ "$PROCESS_TYPE" = "m" ]; then
    OUTPUT_FILE_TYPE=$(prompt_and_validate "Output file type (e.g., txt, lua)" "txt" validate_output_file_type)
fi

# Prepare file type filter
if [ "$FILE_TYPES" = "all" ]; then
    file_filter="*"
else
    IFS=',' read -ra TYPES <<< "$FILE_TYPES"
    file_filter=$(printf "*.%s " "${TYPES[@]}" | sed 's/ $//')
fi

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Estimate total files
total_files=$(estimate_total_files)

if [ "$PROCESS_TYPE" = "m" ]; then
    # Set destination file
    DEST_FILE="${DEST_DIR}/merged_scripts_${TIMESTAMP}.${OUTPUT_FILE_TYPE}"

    # Check if destination file exists
    if [ -f "$DEST_FILE" ]; then
        read -p "File $DEST_FILE already exists. Overwrite? (y/N): " confirm
        if [[ $confirm != [yY] ]]; then
            echo "Operation cancelled."
            exit 1
        fi
    fi

    # Create the destination file
    mkdir -p "$DEST_DIR"
    echo "" > "$DEST_FILE"

    # Counter for merged scripts
    script_count=0

    # Process files for merging
    while IFS= read -r -d '' file; do
        # Extract relative path
        relative_path="${file#$SOURCE_DIR/}"

        # Read file content
        content=$(<"$file")

        # Generate description if requested
        if [ "$GENERATE_DESCRIPTIONS" = "y" ]; then
            echo "Generating description for $relative_path..."
            description=$(generate_description_with_retry "$content" "$relative_path")
        fi

        # Write script information to destination file
        {
            echo "-- <script>"
            echo "-- <path>$relative_path</path>"
            if [ "$GENERATE_DESCRIPTIONS" = "y" ]; then
                echo "-- <description>$description</description>"
            fi
            echo "-- <code>"
            echo "$content"
            echo "-- </code>"
            echo "-- </script>"
            echo ""
        } >> "$DEST_FILE"

        # Increment script count and display progress
        ((script_count++))
        echo "Processed: $relative_path"

    done < <(find "$SOURCE_DIR" -type f -name "$file_filter" -print0)

    # Add summary comment at the end of the destination file
    echo "-- Total scripts merged: $script_count" >> "$DEST_FILE"
    echo "-- Date of merging: $(date)" >> "$DEST_FILE"

    echo "Merge complete. Total scripts merged: $script_count"
    echo "Merged file: $DEST_FILE"

else
    # Process files individually
    DEST_DIR="${DEST_DIR}/merged_scripts_${TIMESTAMP}"
    mkdir -p "$DEST_DIR"
    script_count=0

    while IFS= read -r -d '' file; do
        # Extract relative path
        relative_path="${file#$SOURCE_DIR/}"

        # Read file content
        content=$(<"$file")

        # Generate description if requested
        if [ "$GENERATE_DESCRIPTIONS" = "y" ]; then
            echo "Generating description for $relative_path..."
            description=$(generate_description_with_retry "$content" "$relative_path")
        fi

        # Create new filename
        new_filename=$(echo "$relative_path" | sed 's/\//_/g')
        dest_file="${DEST_DIR}/${new_filename}"

        # Check if destination file exists
        if [ -f "$dest_file" ]; then
            read -p "File $dest_file already exists. Overwrite? (y/N): " confirm
            if [[ $confirm != [yY] ]]; then
                echo "Skipping $relative_path"
                continue
            fi
        fi

        # Write script information to destination file
        {
            echo "-- <script>"
            echo "-- <path>$relative_path</path>"
            if [ "$GENERATE_DESCRIPTIONS" = "y" ]; then
                echo "-- <description>$description</description>"
            fi
            echo "-- <code>"
            echo "$content"
            echo "-- </code>"
            echo "-- </script>"
        } > "$dest_file"

        # Increment script count and display progress
        ((script_count++))
        echo "Processed: $relative_path"

    done < <(find "$SOURCE_DIR" -type f -name "$file_filter" -print0)

    echo "Individual processing complete. Total files processed: $script_count"
    echo "Files saved in: $DEST_DIR"
fi