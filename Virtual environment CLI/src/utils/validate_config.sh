validate_config() {
    local env_path="$1"
    local config_file="$1/env.conf"

    if [[ -z "$env_path" ]];then
        print_debug "No path to an environment was specified..." -t "error"
        exit 1
    fi

    if [[ ! -f "$config_file" ]];then
        print_debug "No config file found at $env_path..." -t "info"
        exit 1
    fi

    # Load the template variables
    source "$CONFIG_TEMPLATE"

    # Load the variables from the config file to validate
    source "$config_file"

    # Check if all template variables are defined in the config file
    for var in ENV_PATH REGULAR_VARIABLES ARRAY_VARIABLES ASSOCIATIVE_ARRAY_VARIABLES; do
        if [ -z "${!var}" ]; then
            print_debug "Error: The configuration file is missing the variable $var thus is not valid..." -t "error"
            exit 1
        fi
    done
    print_debug "Valid config file found at $env_path" -t "debug"
    return 0
}