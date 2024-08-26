#!/bin/bash

# Function to retrieve the type of a variable
get_variable_type() {
    local var_name="$1"
    local var_type
    var_type=$(grep "^__VAR__TYPE__${var_name}=" "$ENV_CONFIG_FILE" | cut -d'=' -f2)
    #echo "Debug: Retrieved variable type for ${var_name}: ${var_type}" >&2
    echo "$var_type"
}

# Function to retrieve a regular variable
get_regular_var() {
    local var_name="$1"
    local var_value
    
    if grep -q "^${var_name}=" "$REGULAR_VARIABLES"; then
        var_value=$(grep "^${var_name}=" "$REGULAR_VARIABLES" | cut -d'=' -f2-)
        echo "$var_value"
        return 0
    else
        echo ""
        return 1
    fi
}

get_array_var() {
    local var_name="$1"
    local var_value
    if grep -q "^${var_name}=" "$ARRAY_VARIABLES"; then
        var_value=$(grep "^${var_name}=" "$ARRAY_VARIABLES" | cut -d'=' -f2-)
        var_value="${var_value:1:-1}"  # Remove parentheses
        # Properly quote each element without adding extra quotes
        echo "$var_value" | sed -E 's/("[^"]+")/\1/g'
        return 0
    else
        echo ""
        return 1
    fi
}


get_associative_array_var() {
    local var_name="$1"
    if grep -q "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES"; then
        grep "^${var_name}\[" "$ASSOCIATIVE_ARRAY_VARIABLES" | while IFS='=' read -r key value; do
            key=$(echo "$key" | sed -e "s/^${var_name}\[\"//" -e 's/\"\]$//')
            value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
            echo "$key:$value"
        done
        return 0
    else
        echo ""
        return 1
    fi
}

# Main get function
get() {
    local var_name="$1"

    # Step 1: Check if the variable type is stored in the config file
    local var_type
    var_type=$(get_variable_type "$var_name")

    # Remove quotes from the variable type
    var_type="${var_type%\"}"
    var_type="${var_type#\"}"

    if [[ -z "$var_type" ]]; then
        #echo "Debug: Variable type not found for ${var_name}" >&2
        echo ""  # Variable type not found
        return 3
    fi

    #echo "Debug: Variable type for ${var_name} is ${var_type}" >&2

    # Step 2: Retrieve the variable based on its type
    case "$var_type" in
        "regular")
            get_regular_var "$var_name"
            ;;
        "array")
            get_array_var "$var_name"
            #echo "Debug: Array type detected, but not yet implemented" >&2
            ;;
        "associative_array")
            get_associative_array_var "$var_name"
            #echo "Debug: Associative array type detected, but not yet implemented" >&2
            ;;
        *)
            #echo "Debug: Unknown variable type for ${var_name}: ${var_type}" >&2
            echo ""  # Unknown variable type
            return 1
            ;;
    esac

    return 0
}
