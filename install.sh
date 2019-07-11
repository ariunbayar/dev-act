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
config_destination="/etc/activity_monitor.conf"

read -e -p "Enter activity monitor server name (domain or ip address): " \
    -i "localhost" server_ip
read -e -p "Enter port the activity monitor is running: " \
    -i "80" server_port


# Install scrot via apt-get
echo -e "\n    Installing ImageMagick for screenshot\n"
apt install imagemagick -y


# Install python3 via apt-get
echo -e "\n    Installing Python3 for mouse and keyboard activity\n"
apt install python3 -y


# Install systemd service

systemd_service_destination="/etc/systemd/system/activity_monitor.service"
echo "[Unit]
Description=Activity Monitor service

[Service]
ExecStart=${executable_destination} ${config_destination}
Type=simple
PIDFile=/var/run/activity_monitor.pid
Restart=always
KillSignal=SIGQUIT

[Install]
WantedBy=multi-user.target" > "${systemd_service_destination}"

[ $? -eq 0 ] && sayok || sayerr
echo -e "${systemd_service_destination}"


# Output the sample config file

echo "# Configuration file for Activity Monitor
# See: /usr/local/bin/activity_monitor

Server ${server_ip}
Port ${server_port}

ScreenshotInterval 60" > ${config_destination}

[ $? -eq 0 ] && sayok || sayerr
echo -e "${config_destination}"


# Copy the service script
cp "${script_dir}/activity_monitor" "${executable_destination}"
[ $? -eq 0 ] && sayok || sayerr
echo -e "${executable_destination}"


echo -e "
\033[01m\033[32mInstallation for Developer Activity Monitor is complete.\033[0m

Enable service with following command.

    systemctl enable activity_monitor

Start service with:

    systemctl start activity_monitor
"
