#!/bin/bash



check(){
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
    print "Valid venv installation at: $install_path" -t "info"
    exit 0
}
