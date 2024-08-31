#!/bin/bash

help_install() {
    echo "Usage: env.sh install <path>"
    echo ""
    echo "Installs the environment management system at the specified directory."
    echo "This setup creates the necessary files to manage regular variables, arrays,"
    echo "and associative arrays within the environment."
    echo ""
    echo "Arguments:"
    echo "  <path>  The directory where the environment files will be created."
    echo ""
    echo "Exit Codes:"
    echo "  0  Installation successful."
    echo "  1  Error during installation (e.g., directory not writable or files cannot be created)."
    exit 1
}

install() {
    local install_path="$1"
    [[ "$install_path" == "." ]] || [[ "$install_path" == "./" ]] && install_path=$INVOKE_DIR
    
    if [ -z "$install_path" ]; then
        print_debug "No installation path provided." -t "error"
        help_install
        return 1
    fi

    #source "$SCRIPT_DIR/src/utils/validate_config.sh"  
    # Check if a venv is already installed in the given path
    if [[ -d "$install_path" ]] && $(validate_config "$install_path"); then
        print_debug "venv is already installed at $install_path" -t "error"
        exit 1
    fi

    # Check if directory exists or can be created
    mkdir -p "$install_path"
    if [ $? -ne 0 ]; then
        print_debug "Unable to create directory at $install_path." -t "error"
        return 1
    fi

    # Check if files can be created
    touch "$install_path/testfile"
    if [ $? -ne 0 ]; then
        print_debug "Cannot write to $install_path." -t "error"
        return 1
    fi
    rm "$install_path/testfile"  # Clean up

    # Create environment files
    print_debug "Installing environment system in $install_path..." -t "debug"
    touch "$install_path/env-regular.conf"
    touch "$install_path/env-array.conf"
    touch "$install_path/env-assoc-array.conf"

    # Replace placeholders in the template and write to the new config.sh
    sed "s|{{ENV_PATH}}|$install_path|g" "$CONFIG_TEMPLATE" > "$install_path/env.conf"

    print_debug "Environment system installed successfully in $install_path." -t "info"

    return 0
}
