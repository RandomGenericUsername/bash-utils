#!/bin/bash

# Function to retrieve the type of a variable
get_variable_type() {
    local var_name="$1"
    local var_type
    var_type=$(grep "^__VAR__TYPE__${var_name}=" "$ENV_CONFIG_FILE" | cut -d'=' -f2)
    echo "$var_type"
}

# Function to delete a regular variable
delete_regular_var() {
    local var_name="$1"
    if grep -q "^${var_name}=" "$REGULAR_VARIABLES"; then
        sed -i "/^${var_name}=/d" "$REGULAR_VARIABLES"
        return 0
    else
        print_debug "Regular variable $var_name does not exist." -t "debug"
        return 1
    fi
}

# Function to delete an array variable
delete_array_var() {
    local var_name="$1"
    if grep -q "^${var_name}=" "$ARRAY_VARIABLES"; then
        sed -i "/^${var_name}=/d" "$ARRAY_VARIABLES"
        return 0
    else
        print_debug "Array variable $var_name does not exist." -t "debug"
        return 1
    fi
}

# Function to delete an associative array variable
delete_associative_array_var() {
    local var_name="$1"
    if grep -q "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES"; then
        sed -i "/^${var_name}\[/d" "$ASSOCIATIVE_ARRAY_VARIABLES"
        return 0
    else
        print_debug "Associative array variable $var_name does not exist." -t "debug"
        return 1
    fi
}

# Main delete function
delete() {
    local var_name="$1"

    # Step 1: Check if the variable type is stored in the config file
    local var_type
    var_type=$(get_variable_type "$var_name")

    if [[ -z "$var_type" ]]; then
        print_debug "Variable type not found for \"$var_name\". It was probably deleted already!" -t "error"
        return 1
    fi

    # Step 2: Delete the variable based on its type
    case "$var_type" in
        "regular")
            delete_regular_var "$var_name"
            ;;
        "array")
            delete_array_var "$var_name"
            ;;
        "associative_array")
            delete_associative_array_var "$var_name"
            ;;
        *)
            echo "Unknown variable type for $var_name."
            return 1
            ;;
    esac

    # Step 3: Remove the variable type from the config file
    sed -i "/^__VAR__TYPE__${var_name}=/d" "$ENV_CONFIG_FILE"

    return 0
}
