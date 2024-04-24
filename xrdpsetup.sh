#!/bin/bash

LOG_FILE="/var/log/reboot.log"

# Start of the script
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Starting script execution..." | sudo tee -a $LOG_FILE

# Add xrdpsetup.sh to cron jobs at reboot
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Adding xrdpsetup.sh to cron jobs at reboot..." | sudo tee -a $LOG_FILE
(crontab -l 2>/dev/null; echo "@reboot /path/to/xrdpsetup.sh") | crontab -

# Display current cron jobs
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Current cron jobs:" | sudo tee -a $LOG_FILE
crontab -l | sudo tee -a $LOG_FILE

# Function to log command outputs
log_command() {
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Running command: $1" | sudo tee -a $LOG_FILE
    eval $1 2>&1 | sudo tee -a $LOG_FILE
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo "[$(date "+%Y-%m-%d %H:%M:%S")] Error: Command failed - '$1'" | sudo tee -a $LOG_FILE 1>&2
        exit 1
    fi
}

# Update the package list
log_command "sudo apt-get update -y"

# Upgrade all installed packages
log_command "sudo apt-get upgrade -y"

# Install xrdp and configure it
log_command "sudo apt-get install xrdp -y"

# Configure firewall for xrdp
log_command "sudo ufw allow 3389/tcp"

# Set permissions for /etc/skel
log_command "sudo chown root:root /etc/skel"
log_command "sudo chmod 755 /etc/skel"

# Configure default session for new users
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Configuring default session for new users..." | sudo tee -a $LOG_FILE
echo "gnome-session" | sudo tee /etc/skel/.xsession | sudo tee -a $LOG_FILE

# Install Ubuntu desktop environment
log_command "sudo apt-get install ubuntu-desktop -y"

# Restart xrdp service
log_command "sudo systemctl restart xrdp"

# Log the reboot action
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Logging reboot action..." | sudo tee -a $LOG_FILE
echo "[$(date "+%Y-%m-%d %H:%M:%S")] - System is rebooting" | sudo tee -a $LOG_FILE > /dev/null

# Reboot the system silently
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Rebooting the system..." | sudo tee -a $LOG_FILE
sudo nohup shutdown -r now > /dev/null 2>&1 &
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Reboot command issued." | sudo tee -a $LOG_FILE
