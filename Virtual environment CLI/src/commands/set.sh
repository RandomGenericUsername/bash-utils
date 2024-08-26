#!/bin/bash

help_set() {
    echo "Usage: env.sh set <variable_name> <value1> [value2 ...] [--config <config-file>]"
    echo ""
    echo "Sets a variable in the environment. Can be used for regular variables, arrays, and associative arrays."
    echo ""
    echo "Examples:"
    echo "  env.sh set wallpaper_path /path/to/file"
    echo "  env.sh set available_modes 'Battery saver' 'High performance' 'Default'"
    echo "  env.sh set mode_descriptions 'Battery saver':'Battery saver mode' 'High performance':'High performance mode'"
    exit 1
}


# Function to update variable type in config.sh
update_variable_type() {
    local var_name="$1"
    local var_type="$2"

    # Remove existing entry if present
    sed -i "/^__VAR__TYPE__${var_name}=/d" "$ENV_CONFIG_FILE"

    # Append new entry with the variable type
    echo "__VAR__TYPE__${var_name}=$var_type" >> "$ENV_CONFIG_FILE"
}

set_regular_var() {
    local var_name="$1"
    local var_value="$2"

    if grep -q "^${var_name}=" "$REGULAR_VARIABLES"; then
        sed -i "/^${var_name}=/d" "$REGULAR_VARIABLES"
    fi

    echo "$var_name=$var_value" >> "$REGULAR_VARIABLES"
    
    # Update type in config file
    update_variable_type "$var_name" "regular"
    
    return 0
}

set_array_var() {
    local var_name="$1"
    shift
    local values=("$@")

    if grep -q "^${var_name}=" "$ARRAY_VARIABLES"; then
        sed -i "/^${var_name}=/d" "$ARRAY_VARIABLES"
    fi

    printf "%s=(" "$var_name" >> "$ARRAY_VARIABLES"
    for val in "${values[@]}"; do
        printf "\"%s\" " "$val" >> "$ARRAY_VARIABLES"
    done
    echo ")" >> "$ARRAY_VARIABLES"
    # Update type in config file
    update_variable_type "$var_name" "array"
    return 0
}

set_associative_array_var() {
    local var_name="$1"
    shift
    declare -A assoc_array
    local return_code=0

    # Check if the variable already exists and delete old entries
    if grep -q "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES"; then
        sed -i "/^${var_name}\[/d" "$ASSOCIATIVE_ARRAY_VARIABLES"
    fi

    # Regex pattern to match key-value pairs with optional quotes and spaces
    local key_value_regex='^\"?([^\":]+)\"?\s*:\s*\"?([^\":]+)\"?$'

    # Iterate over arguments to parse key-value pairs
    while [[ "$#" -gt 0 ]]; do
        if [[ "$1:$2:$3" =~ $key_value_regex ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            assoc_array["$key"]="$value"
            shift 3
        elif [[ "$1" =~ $key_value_regex ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            assoc_array["$key"]="$value"
            shift 1
        else
            echo "Error: Invalid input format. Key-value pairs must be separated by ':'."
            return 1
        fi
    done

    # Write the associative array to the config file
    for key in "${!assoc_array[@]}"; do
        echo "${var_name}[\"${key}\"]=\"${assoc_array[$key]}\"" >> "$ASSOCIATIVE_ARRAY_VARIABLES"
    done

    # Update the type in the config file
    update_variable_type "$var_name" "associative_array"

    return $return_code
}

set() {
    # Parse the command and call the appropriate function
    if [[ $# -lt 2 ]]; then
        help_set
        exit 1
    fi

    local var_name="$1"
    shift

    # Store the arguments in an array
    local args=("$@")

    # Debug output
    # Check if it's an associative array (key:value pairs)
    if [[ "$*" =~ ":" ]]; then
        set_associative_array_var "$var_name" "$@"
    elif [[ "$#" -gt 1 ]]; then
        set_array_var "$var_name" "$@"
    else
        set_regular_var "$var_name" "$1"
    fi
}