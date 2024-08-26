get_var_from_config() {
    local var_name="$1"

    # Check if the config file exists
    if [[ ! -f "$ENV_CONFIG_FILE" ]]; then
        echo "Error: Configuration file not found."
        return 2
    fi

    # Source the config file
    source "$ENV_CONFIG_FILE"

    # Check if the variable is defined
    if [[ -n "${!var_name+x}" ]]; then
        echo "${!var_name}"
        return 0
    else
        echo ""
        return 1
    fi
}
