# Bash Argument Parsing Utility

This utility is designed to be integrated into Bash scripts, providing a flexible and robust way to define, parse, and manage various command-line arguments. It supports the following types of arguments:

* **Positional arguments**: Capture arguments based on their position.
* **Single-value options**: Handle options that take a single value (e.g., `--file /path/to/file`).
* **Multi-value options**: Allow options to accept multiple values (e.g., `--ids 1 2 3`).
* **Flags**: Enable or disable specific features without requiring a value (e.g., `--verbose`).


## Getting started
```bash
#!/bin/bash

# Enable debug.
#export DEBUG=true

# Source the utility
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/arg_parser.sh"

# Define the identifiers for each option/flag
log_files_option_identifiers=("-l" "--logs" "--log-files")
start_date_option_identifiers=("-s" "--start-date")
end_date_option_identifiers=("-e" "--end-date")
json_output_option_identifiers=("--json")

# Set these identifiers as options/flags by calling 'set_options'
options=(
    "log_files_option_identifiers" "log_files"
    "start_date_option_identifiers" "start_date"
    "end_date_option_identifiers" "end_date"
    "json_output_option_identifiers" "json_output"
)
set_options "${options[@]}"

# Enable multi-value for log files
enable_multi_value_option "${log_files_option_identifiers[@]}"

# Enable JSON output as a flag
enable_flag ${json_output_option_identifiers[@]} 

# This script takes as arguments:
# 1. The name of a module to launch
# 2. The utility to launch on that module
# 3. the id of the user

# Set the number of mandatory arguments and their allowed values
mandatory_arguments=3
# Set the allowed values for the 'module' argument
allowed_modules=("logs" "audit" "inspect")
# Set the allowed values for the 'util' argument
allowed_utils=("clean" "install" "remove" "deep-clean" "restore")
# Since id of the user doesn't have constrains there is no need to define allowed values.

# pass the allowed values to each argument
set_mandatory_arguments $mandatory_arguments 1:"${allowed_modules[*]}" 2:"${allowed_utils[*]}"

# Pass the arguments to the argument parser
parse_command_line "$@"

# Get the values of the options
LOG_FILES=$(get_arg_value "log_files")
START_DATE=$(get_arg_value "start_date")
END_DATE=$(get_arg_value "end_date")

# Get the values of the flags
JSON_OUTPUT=$(get_arg_value "json_output")

# Get the value of the arguments
MODULE="${POSITIONAL_ARGS[0]}"
UTILITY="${POSITIONAL_ARGS[1]}"
USER_ID="${POSITIONAL_ARGS[2]}"

# Output the options 
echo "Log Files: ${LOG_FILES[@]}"
echo "Start Date: ${START_DATE}"
echo "End Date: ${END_DATE}"

# Output the flags 
echo "JSON Output: ${JSON_OUTPUT}"

# Output the arguments 
echo "Module: $MODULE"
echo "Utility: $UTILITY"
echo "User ID: $USER_ID"


# Flags get the value 'true' if they are passed, else 'false'
if [[ $JSON_OUTPUT == true ]]; then
    echo "Outputting results in JSON format..."
    # Add JSON formatting logic here
fi

```

## Features

### Command-line options
Define command-line options by mapping multiple identifiers (e.g., `-f`, `--file`) to variables. This allows your script to handle various forms of the same option, making it flexible and user-friendly.

### Multi-value options
Enable options to accept multiple values by configuring them with the `enable_multi_value_option` function. This is useful for options that may receive a list of inputs, such as files or directories.

### Flags
Flags are options that do not require a value and are typically used to enable or disable specific features (e.g., `--verbose`). You can define these flags using the `enable_flag` function. This is useful for toggling behaviors in your script without needing to pass a value.
