#!/bin/bash

function sayok() {
    echo -en "\033[01m[  \033[32mOK\033[0m  \033[01m]\033[0m "
}

function sayerr() {
    echo -en "\033[01m[ \033[31mERR\033[0m  \033[01m]\033[0m "
}

if [ "$EUID" -ne 0 ]; then
    echo "${sayerr} Sudo or root permission is required!"
    exit
fi

script_dir=$(dirname "$(readlink -e "$0")")
executable_destination="/usr/local/bin/activity_monitor"

read -e -p "Enter activity monitor server name (domain or ip address): " \
    -i "localhost" server_ip
read -e -p "Enter port the activity monitor is running: " \
    -i "80" server_port


# Install scrot via apt-get
apt install imagemagick -y


# Install systemd service

systemd_service_destination="/etc/systemd/system/activity_monitor.service"
echo "[Unit]
Description=Activity Monitor service

[Service]
ExecStart=${executable_destination}
Type=simple
PIDFile=/var/run/activity_monitor.pid
Restart=always
KillSignal=SIGQUIT

[Install]
WantedBy=multi-user.target" > "${systemd_service_destination}"

[ $? -eq 0 ] && sayok || sayerr
echo -e "${systemd_service_destination}"


# Output the sample config file
config_destination="/etc/activity_monitor.conf"
echo "# Configuration file for Activity Monitor
# See: /usr/local/bin/activity_monitor
Server ${server_ip}
Port ${server_port}" > ${config_destination}

[ $? -eq 0 ] && sayok || sayerr
echo -e "${config_destination}"


# Copy the service script
cp "${script_dir}/activity_monitor" "${executable_destination}"
[ $? -eq 0 ] && sayok || sayerr
echo -e "${executable_destination}"
