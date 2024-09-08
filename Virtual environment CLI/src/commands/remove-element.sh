#!/bin/bash

help_remove_element() {
    echo "Usage: env.sh remove-element <variable_name> <element>"
    echo ""
    echo "Removes an element from a variable. For regular variables, the entire variable is deleted. For arrays, it removes the element at the specified index. For associative arrays, it removes the key-value pair by the key."
    echo ""
    echo "Examples:"
    echo "  env.sh remove-element cached_wallpapers 2"
    echo "  env.sh remove-element mode_descriptions 'Battery saver'"
    echo "  env.sh remove-element wallpaper_dir"
    exit 1
}

# Function to remove a regular variable
remove_regular_var() {
    local var_name="$1"

    if grep -q "^${var_name}=" "$REGULAR_VARIABLES"; then
        sed -i "/^${var_name}=/d" "$REGULAR_VARIABLES"
        return 0
    else
        echo "Error: Regular variable '$var_name' does not exist."
        return 1
    fi
}

# Function to remove an element from an array by index
remove_array_element() {
    local var_name="$1"
    local index="$2"

    # Check if index is a valid number
    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo "Error: The array index must be a valid number."
        return 1
    fi

    # Retrieve the current array
    local existing_values
    if grep -q "^${var_name}=" "$ARRAY_VARIABLES"; then
        existing_values=$(grep "^${var_name}=" "$ARRAY_VARIABLES" | cut -d'=' -f2-)
        existing_values="${existing_values:1:-1}"  # Remove parentheses
    else
        echo "Error: Array variable '$var_name' does not exist."
        return 1
    fi

    # Convert the existing values into an array
    IFS=' ' read -r -a array <<< "$existing_values"

    # Check if index is within bounds
    if [[ "$index" -ge "${#array[@]}" || "$index" -lt 0 ]]; then
        echo "Error: Index out of bounds."
        return 1
    fi

    # Remove the element at the specified index
    unset 'array[index]'

    # Write back the updated array
    sed -i "/^${var_name}=/d" "$ARRAY_VARIABLES"  # Remove the old array
    if [[ "${#array[@]}" -gt 0 ]]; then
        echo "$var_name=(${array[*]})" >> "$ARRAY_VARIABLES"
    else
        echo "$var_name=()" >> "$ARRAY_VARIABLES"  # Empty array
    fi

    return 0
}

# Function to remove a key from an associative array
remove_associative_array_element() {
    local var_name="$1"
    local key="$2"

    # Retrieve the existing associative array
    declare -A assoc_array
    if grep -q "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES"; then
        # Load existing key-value pairs into assoc_array
        while IFS='=' read -r key_line value; do
            key_line=$(echo "$key_line" | sed -e "s/^${var_name}\[\"//" -e 's/\"\]$//')
            value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
            assoc_array["$key_line"]="$value"
        done < <(grep "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES")
    else
        echo "Error: Associative array variable '$var_name' does not exist."
        return 1
    fi

    # Check if the key exists
    if [[ -z "${assoc_array[$key]}" ]]; then
        echo "Error: Key '$key' does not exist in the associative array."
        return 1
    fi

    # Remove the key-value pair
    unset assoc_array["$key"]

    # Write back the updated associative array
    sed -i "/^${var_name}\[/d" "$ASSOCIATIVE_ARRAY_VARIABLES"  # Remove the old entries
    for k in "${!assoc_array[@]}"; do
        echo "${var_name}[\"$k\"]=\"${assoc_array[$k]}\"" >> "$ASSOCIATIVE_ARRAY_VARIABLES"
    done

    return 0
}

# Main remove-element function
remove_element() {
    if [[ $# -lt 2 ]]; then
        help_remove_element
        exit 1
    fi

    local var_name="$1"
    local element="$2"

    # Check the variable type
    local var_type
    var_type=$(get_variable_type "$var_name")

    if [[ "$var_type" == "regular" ]]; then
        remove_regular_var "$var_name"
    elif [[ "$var_type" == "array" ]]; then
        remove_array_element "$var_name" "$element"
    elif [[ "$var_type" == "associative_array" ]]; then
        remove_associative_array_element "$var_name" "$element"
    else
        echo "Error: Unsupported variable type for remove-element."
        return 1
    fi
}
