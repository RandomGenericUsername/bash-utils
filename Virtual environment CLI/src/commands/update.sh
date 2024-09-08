#!/bin/bash

help_update() {
    echo "Usage: env.sh update <variable_name> <new_value1> [new_value2 ...] [--config <config-file>]"
    echo ""
    echo "Updates the value of a variable. For regular variables, it works as a set command. For arrays and associative arrays, it appends new values."
    echo "If the variable doesn't exist yet, it calls the corresponding set function."
    echo ""
    echo "Examples:"
    echo "  env.sh update cached_wallpapers 'New Wallpaper' 'Another Wallpaper'"
    echo "  env.sh update mode_descriptions 'New Mode':'Description for new mode'"
    echo "  env.sh update regular_variable 'new_value'"
    exit 1
}

# Source the existing set.sh module (where set_* functions are defined)
source "$SCRIPT_DIR/src/commands/set.sh"

# Function to update a regular variable
update_regular_var() {
    local var_name="$1"
    local new_value="$2"

    # Update the existing variable
    sed -i "/^${var_name}=/d" "$REGULAR_VARIABLES"
    echo "$var_name=$new_value" >> "$REGULAR_VARIABLES"
    return 0
}

# Function to update an array variable
update_array_var() {
    local var_name="$1"
    shift
    local new_values=("$@")

    # Retrieve existing array and append new values
    local existing_values
    existing_values=$(grep "^${var_name}=" "$ARRAY_VARIABLES" | cut -d'=' -f2-)
    existing_values="${existing_values:1:-1}"  # Remove parentheses

    # Combine existing and new values
    local updated_values="$existing_values"
    for val in "${new_values[@]}"; do
        updated_values+=" \"$val\""
    done

    # Write back the updated array
    sed -i "/^${var_name}=/d" "$ARRAY_VARIABLES"
    echo "$var_name=($updated_values)" >> "$ARRAY_VARIABLES"
    return 0
}

# Function to update an associative array variable
update_associative_array_var() {
    local var_name="$1"
    shift
    declare -A assoc_array

    # Retrieve existing associative array
    while IFS='=' read -r key_line value; do
        key_line=$(echo "$key_line" | sed -e "s/^${var_name}\[\"//" -e 's/\"\]$//')
        value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
        assoc_array["$key_line"]="$value"
    done < <(grep "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES")

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
    sed -i "/^${var_name}\[/d" "$ASSOCIATIVE_ARRAY_VARIABLES"
    for key in "${!assoc_array[@]}"; do
        echo "${var_name}[\"$key\"]=\"${assoc_array[$key]}\"" >> "$ASSOCIATIVE_ARRAY_VARIABLES"
    done

    return 0
}

# Main update function
update() {
    if [[ $# -lt 2 ]]; then
        help_update
        exit 1
    fi

    var_type_options_identifier=("--vt" "--variable-type")
    options=("var_type_options_identifier" "var_type_options")
    set_options "${options[@]}"
    parse_command_line "$@"
    
    local var_name="${POSITIONAL_ARGS[0]}"
    local args=("${POSITIONAL_ARGS[@]:1}")
    local variable_type="$(get_arg_value "var_type_options")"

    # Check if the variable exists by determining its type
    local var_type
    var_type=$(get_variable_type "$var_name")

    # If the variable doesn't exist and --vt is provided, initialize with the given type
    if [[ -z "$var_type" ]]; then
        if [[ -n "$variable_type" ]]; then
            echo "Variable does not exist, initializing as '$variable_type'."
            if [[ "$variable_type" == "array" ]]; then
                set_array_var "$var_name" "${args[@]}"
            elif [[ "$variable_type" == "associative_array" ]]; then
                set_associative_array_var "$var_name" "${args[@]}"
            else
                set_regular_var "$var_name" "${args[0]}"
            fi
        else
            # No --vt flag provided, fall back to default behavior (treat as regular)
            set_regular_var "$var_name" "${args[0]}"
        fi
        return 0
    fi

    # Handle updates for existing variables
    if [[ "$var_type" == "regular" ]]; then
        update_regular_var "$var_name" "${args[0]}"
    elif [[ "$var_type" == "array" ]]; then
        update_array_var "$var_name" "${args[@]}"
    elif [[ "$var_type" == "associative_array" ]]; then
        update_associative_array_var "$var_name" "${args[@]}"
    else
        echo "Error: Unsupported variable type for update."
        return 1
    fi
}