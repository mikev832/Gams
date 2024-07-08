#!/bin/bash

# This is a script to automate Google Admin tasks for account creation and provisioning

# Function to log messages
log_message() {
    local message="$1"
    local type="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$type] $message" | tee -a "$LOGFILE"
}

# Determine script directory and set log file path
SCRIPT_DIR=$(dirname "$(realpath "$0")")
LOGFILE="$SCRIPT_DIR/Onboarding.log"

# Prompt for first name and last name
read -p "Enter first name: " FIRSTNAME
read -p "Enter last name: " LASTNAME

# Default username
DEFAULT_USERNAME="$FIRSTNAME.$LASTNAME"

# Prompt to use default username or custom username
read -p "Do you want to use the default username ($DEFAULT_USERNAME)? (y/n): " USE_DEFAULT
if [[ $USE_DEFAULT == "y" || $USE_DEFAULT == "Y" ]]; then
    USERNAME=$DEFAULT_USERNAME
else
    read -p "Enter custom username: " CUSTOM_USERNAME
    USERNAME=$CUSTOM_USERNAME
fi

# Email and password
EMAIL="$USERNAME@domain.com"
PASSWORD="Placeholder"

# Prompt for manager email
read -p "Enter manager email: " MANAGER_EMAIL

# Path to gam executable
gam=pathtogaminstall

# Log start of process
log_message "Starting user onboarding process for $FIRSTNAME $LASTNAME ($EMAIL)." "INFO"

# Create user
if $gam create user $EMAIL firstname $FIRSTNAME lastname $LASTNAME password $PASSWORD changepassword on; then
    log_message "User $FIRSTNAME $LASTNAME ($EMAIL) created successfully." "INFO"
else
    log_message "Error: Failed to create user $FIRSTNAME $LASTNAME ($EMAIL)." "ERROR"
    exit 1
fi

# Add a 30-second pause
log_message "Pausing for 30 seconds..." "INFO"
sleep 30

# Update user with manager
if $gam update user $EMAIL relation manager $MANAGER_EMAIL; then
    log_message "Manager $MANAGER_EMAIL assigned to user $EMAIL successfully." "INFO"
else
    log_message "Error: Failed to assign manager $MANAGER_EMAIL to user $EMAIL." "ERROR"
fi

# Add user to common groups
if $gam update group groupname@domain.com add member $EMAIL; then
    log_message "User $EMAIL added to group all@mobilabsolutions.com successfully." "INFO"
else
    log_message "Error: Failed to add user $EMAIL to group groupname@domain.com." "ERROR"
fi

if $gam update group groupname@domain.com add member $EMAIL; then
    log_message "User $EMAIL added to group groupname@domain.com" "INFO"
else
    log_message "Error: Failed to add user $EMAIL to group groupname@mobilabsolutions.com." "ERROR"
fi

if $gam update group groupname@domain.com add member $EMAIL; then
    log_message "User $EMAIL added to group groupname@domain.com successfully." "INFO"
else
    log_message "Error: Failed to add user $EMAIL to group groupname@domain.com." "ERROR"
fi

# Prompt to add user to cloud-adoption group
read -p "Is the user in groupname@domain.com? (y/n): " IN_CLOUD_ADOPTION
if [[ $IN_GROUP == "y" || $IN_GROUP == "Y" ]]; then
    if $gam update group groupname@domain.com add member $EMAIL; then
        log_message "User $EMAIL added to group groupname@domain.com successfully." "INFO"
    else
        log_message "Error: Failed to add user $EMAIL to group groupname@domain.com." "ERROR"
    fi
else
    log_message "User $EMAIL not added to groupname@domain.com as per user's decision." "INFO"
fi

log_message "User onboarding process for $FIRSTNAME $LASTNAME ($EMAIL) completed." "INFO"
