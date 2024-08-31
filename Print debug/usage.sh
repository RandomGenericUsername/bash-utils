
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/print-debug" 

###################### Print a info message ######################
print_debug "This is a 'info' message" -t "info"
###################################################################

###################### Print a warning message ######################
print_debug "This is a 'warn' message" -t "warn"
###################################################################

###################### Print a success message ######################
print_debug "This is a 'success' message" -t "success"
###################################################################

###################### Print an error message ######################
print_debug "This is an 'error' message" -t "error"
###################################################################

###################### Print a debug message ######################
print_debug "This won't get printed because the 'ENABLE_DEBUG' variable is not set to 'true'"
ENABLE_DEBUG="true"
print_debug "This is a 'debug' message" 
unset $ENABLE_DEBUG
###################################################################

###################### Print a message and log it ######################
ENABLE_LOG="true"
LOG="/tmp/logs/install.log"
mkdir -p "/tmp/logs"
print_debug "This is a 'info' message that will be logged at:$LOG" -t "info"
###################################################################
