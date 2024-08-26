#!/bin/bash

help_uninstall() {
    echo "Usage: env.sh uninstall [<path> | --config <config-file>]"
    echo ""
    echo "Uninstalls the environment system."
    echo "This removes the environment directory and its associated files."
    echo ""
    echo "Options:"
    echo "  <path>           The directory where the environment is installed."
    echo "  --config, -c     Specify a custom configuration file to determine the installation path."
    echo ""
    echo "Exit Codes:"
    echo "  0  Uninstallation successful."
    echo "  1  Error during uninstallation (e.g., path not found, files cannot be deleted)."
    exit 1
}

uninstall() {

    if [[ -z "$1" ]] && [[ -z "$ENV_PATH" ]];then
        print "No installation or environment path provided..." -t "error"
        exit 1
    fi

    local install_path="$1"
    if [[ -z "$install_path" ]]; then
        validate_config "$ENV_PATH"
        install_path=$(get_var_from_config "ENV_PATH")
    fi
    validate_config "$install_path"
    rm -rf "$install_path"
    print "Environment uninstalled successfully from $install_path." -t "info"
    exit 0
}
