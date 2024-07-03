#!/bin/bash

# Prompt for user email and manager email
read -p "Enter the email address of the user: " USER_EMAIL
read -p "Enter the email address of the manager: " MANAGER_EMAIL

# Path to GAM executable
gam=pathtogaminstall

# Function to send email
send_email() {
    local recipient="$1"
    local subject="$2"
    local body="$3"
    echo "$body" | mail -s "$subject" "$recipient"
}

# Step 1: Export user's groups to CSV and email to manager
$gam info user $USER_EMAIL > "$USER_EMAIL".csv
sleep 5
send_email "$MANAGER_EMAIL" "$USER_EMAIL has been offboarded and their Google Drive files and Calendar events have been transferred to you." "Please contact #sysadmin if you have any questions."
# Step 2: Transfer Drive contents to manager's Drive in a folder
$gam create datatransfer $USER_EMAIL gdrive $MANAGER_EMAIL privacy_level shared,private

# Step 3: Transfer Calendar events to manager's Calendar
$gam create datatransfer $USER_EMAIL calendar $MANAGER_EMAIL

# Step 4: Delegate access to manager
$gam user "$USER_EMAIL" delegate to "$MANAGER_EMAIL"

# Step 5: Delete User Groups
$gam user $USER_EMAIL delete groups

# Step 6: Suspend user
$gam update user "$USER_EMAIL" suspended on

# Success message
echo "Tasks completed successfully."
