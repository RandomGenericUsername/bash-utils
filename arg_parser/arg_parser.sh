#!/bin/bash


declare -A ARG_VALUES
declare -A ARG_MULTI_VALUES
declare -A ARG_FLAGS
declare -A MANDATORY_ARGUMENTS_VALUES

# Function to print debug messages
debug() {
    if [[ $DEBUG == "true" ]]; then
        echo "[ARG PARSER DEBUG: $@]"
    fi
}

# Function to parse arguments
set_options() {
    while [[ "$#" -gt 0 ]]; do
        local array_name="$1"
        local var_name="$2"
        shift 2

        debug "Parsing options for array: $array_name, Variable: $var_name"

        eval "local -a options=(\"\${${array_name}[@]}\")"

        for opt in "${options[@]}"; do
            debug "Mapping option $opt to variable $var_name"
            ARG_VALUES["$opt"]="$var_name"
            ARG_MULTI_VALUES["$opt"]=false
        done
    done

    debug "Parsed ARG_VALUES:"
    for key in "${!ARG_VALUES[@]}"; do
        debug "$key -> ${ARG_VALUES[$key]}"
    done
}

# Function to enable multi-value for specific arguments
enable_multi_value_option() {
    while [[ "$#" -gt 0 ]]; do
        local option="$1"
        shift

        if [[ -n "${ARG_VALUES[$option]}" ]]; then
            ARG_MULTI_VALUES["$option"]=true
        else
            echo "Error: $option is not a recognized option"
            exit 1
        fi
    done
}

# Function to enable flags (options without values)
enable_flag() {
    while [[ "$#" -gt 0 ]]; do
        local option="$1"
        shift

        if [[ -n "${ARG_VALUES[$option]}" ]]; then
            ARG_FLAGS["$option"]=true
        else
            echo "Error: $option is not a recognized option"
            exit 1
        fi
    done
}


# Function to get the value of a parsed argument
get_arg_value() {
    local var_name=$1
    debug "Getting value of $var_name"
    if [[ "$(declare -p $var_name 2>/dev/null)" =~ "declare -a" ]]; then
        eval "echo \${$var_name[@]}"
    else
        echo "${!var_name}"
    fi
}

# Function to set mandatory arguments and their allowed values by coordinate
set_mandatory_arguments() {
    local num_args="$1"
    shift

    # Set the number of mandatory arguments
    export MANDATORY_ARGUMENTS="$num_args"

    debug "Setting $num_args mandatory arguments"


    # Loop through the arguments to parse pairs (coordinate and values)
    while [[ "$#" -gt 0 ]]; do
        # Extract the coordinate and its allowed values
        local coord="${1%%:*}"  # Extract the coordinate number before the colon
        local values="${1#*:}"  # Extract the values after the colon, preserving spaces
        shift

        # Ensure the coordinate is within the number of mandatory arguments
        if [[ "$coord" -gt "$num_args" ]]; then
            echo "Error: Coordinate $coord exceeds the number of mandatory arguments ($num_args)."
            exit 1
        fi

        debug "Setting allowed values for position $coord: $values"

        # Store the allowed values for this coordinate as a space-separated string
        MANDATORY_ARGUMENTS_VALUES["$coord"]="$values"
    done
}


# Function to initialize a flag variable
initialize_flag() {
    local flag="$1"
    local var_name="${ARG_VALUES[$flag]}"
    eval "$var_name=false"
}

# Function to add a positional argument to the list
add_positional_argument() {
    local arg="$1"
    positional_args+=("$arg")
    debug "Adding $arg to positional arguments"
}

# Function to set a flag to true
set_flag_true() {
    local var_name="$1"
    eval "$var_name=true"
    debug "Set flag $var_name to true"
}

# Function to add a value to a multi-value option
add_multi_value_option() {
    local var_name="$1"
    local value="$2"
    eval "$var_name+=(\"$value\")"
    debug "Added $value to $var_name"
}

# Function to set a single-value option
set_single_value_option() {
    local var_name="$1"
    local value="$2"
    eval "$var_name=\"$value\""
    debug "Set $var_name to $value"
}

# Function to parse a single argument
parse_argument() {
    local key="$1"
    shift

    if [[ "${ARG_FLAGS[$key]}" == true ]]; then
        set_flag_true "${ARG_VALUES[$key]}"
    elif [[ "${ARG_MULTI_VALUES[$key]}" == true ]]; then
        while [[ -n "$1" && "$1" != -* ]]; do
            add_multi_value_option "${ARG_VALUES[$key]}" "$1"
            shift
        done
    else
        if [[ -n "$1" && "${1:0:1}" != "-" ]]; then
            set_single_value_option "${ARG_VALUES[$key]}" "$1"
            shift
        else
            echo "Error: $key requires a non-empty argument."
            exit 1
        fi
    fi
}

# Function to validate positional arguments against allowed values
validate_positional_argument() {
    local arg="$1"
    local position="$2"
    local allowed_values="${MANDATORY_ARGUMENTS_VALUES[$position]}"

    debug "Validating argument '$arg' for position $position against allowed values: $allowed_values"

    if [[ -n "$allowed_values" ]]; then
        local found=false
        for value in $allowed_values; do
            debug "Checking if '$arg' matches '$value'"
            if [[ "$arg" == "$value" ]]; then
                found=true
                break
            fi
        done

        if [[ "$found" == false ]]; then
            echo "Error: Argument '$arg' is not allowed for position $position."
            echo "Allowed values for position $position: $allowed_values"
            exit 1
        fi
    fi
}

# Function to validate all positional arguments
validate_all_positional_arguments() {
    for ((i = 1; i <= $MANDATORY_ARGUMENTS; i++)); do
        validate_positional_argument "${POSITIONAL_ARGS[i-1]}" "$i"
    done
}

# Main function to parse command line arguments
parse_command_line() {
    local positional_args=()
    debug "Parsing command line arguments..."

    # Initialize all flags
    for flag in "${!ARG_FLAGS[@]}"; do
        initialize_flag "$flag"
    done

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        if [[ -n "${ARG_VALUES[$1]}" ]]; then
            parse_argument "$@"
        else
            add_positional_argument "$1"
            shift
        fi
    done

    export POSITIONAL_ARGS=("${positional_args[@]}")
    debug "Positional arguments captured: ${POSITIONAL_ARGS[*]}"

    if [[ "${MANDATORY_ARGUMENTS:-0}" -gt 0 ]]; then
        if [[ ${#POSITIONAL_ARGS[@]} -lt $MANDATORY_ARGUMENTS ]]; then
            echo "Error: At least $MANDATORY_ARGUMENTS positional argument(s) required, but only ${#POSITIONAL_ARGS[@]} provided => { ${POSITIONAL_ARGS[*]} }"
            exit 1
        fi

        validate_all_positional_arguments
    fi
}
