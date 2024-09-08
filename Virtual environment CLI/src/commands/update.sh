#!/bin/bash

help_update() {
    echo "Usage: env.sh update <variable_name> <new_value1> [new_value2 ...] [--config <config-file>]"
    echo ""
    echo "Updates the value of a variable. For regular variables, it works as a set command. For arrays and associative arrays, it appends new values."
    echo ""
    echo "Examples:"
    echo "  env.sh update cached_wallpapers 'New Wallpaper' 'Another Wallpaper'"
    echo "  env.sh update mode_descriptions 'New Mode':'Description for new mode'"
    echo "  env.sh update regular_variable 'new_value'"
    exit 1
}

# Function to update a regular variable
update_regular_var() {
    local var_name="$1"
    local new_value="$2"

    if grep -q "^${var_name}=" "$REGULAR_VARIABLES"; then
        sed -i "/^${var_name}=/d" "$REGULAR_VARIABLES"
    fi

    echo "$var_name=$new_value" >> "$REGULAR_VARIABLES"
    return 0
}

# Function to update an array variable
update_array_var() {
    local var_name="$1"
    shift
    local new_values=("$@")

    # Retrieve existing array
    local existing_values
    if grep -q "^${var_name}=" "$ARRAY_VARIABLES"; then
        existing_values=$(grep "^${var_name}=" "$ARRAY_VARIABLES" | cut -d'=' -f2-)
        existing_values="${existing_values:1:-1}"  # Remove parentheses
    else
        existing_values=""  # No existing array
    fi

    # Combine existing values and new values
    local updated_values="$existing_values"
    for val in "${new_values[@]}"; do
        updated_values+=" \"$val\""
    done

    # Write back the updated array
    sed -i "/^${var_name}=/d" "$ARRAY_VARIABLES"  # Remove the old array
    echo "$var_name=($updated_values)" >> "$ARRAY_VARIABLES"
    
    return 0
}

# Function to update an associative array variable
update_associative_array_var() {
    local var_name="$1"
    shift
    declare -A assoc_array
    local return_code=0

    # Retrieve existing associative array
    if grep -q "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES"; then
        # Load existing key-value pairs into assoc_array
        while IFS='=' read -r key value; do
            key=$(echo "$key" | sed -e "s/^${var_name}\[\"//" -e 's/\"\]$//')
            value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
            assoc_array["$key"]="$value"
        done < <(grep "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES")
    fi

    # Add new key-value pairs
    local key_value_regex='^\"?([^\":]+)\"?\s*:\s*\"?([^\":]+)\"?$'
    while [[ "$#" -gt 0 ]]; do
        if [[ "$1" =~ $key_value_regex ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            assoc_array["$key"]="$value"  # Add or update key-value pair
            shift 1
        else
            echo "Error: Invalid input format. Key-value pairs must be separated by ':'."
            return 1
        fi
    done

    # Write back the updated associative array
    sed -i "/^${var_name}\[/d" "$ASSOCIATIVE_ARRAY_VARIABLES"  # Remove the old entries
    for key in "${!assoc_array[@]}"; do
        echo "${var_name}[\"$key\"]=\"${assoc_array[$key]}\"" >> "$ASSOCIATIVE_ARRAY_VARIABLES"
    done

    return $return_code
}

# Main update function
update() {
    if [[ $# -lt 2 ]]; then
        help_update
        exit 1
    fi

    local var_name="$1"
    shift

    # Check the variable type
    local var_type
    var_type=$(get_variable_type "$var_name")

    if [[ "$var_type" == "regular" ]]; then
        update_regular_var "$var_name" "$1"
    elif [[ "$var_type" == "array" ]]; then
        update_array_var "$var_name" "$@"
    elif [[ "$var_type" == "associative_array" ]]; then
        update_associative_array_var "$var_name" "$@"
    else
        echo "Error: Unsupported variable type for update."
        return 1
    fi
}
