#!/usr/bin/env bash

# Rofi script using NetworkManager backend

# Get a list of available networks and add a disconnect option
networks=$(nmcli -t -f SSID dev wifi | sort | uniq | grep -v '^--$')
options="Disconnect\n$networks"

# Show the options in rofi and get the selected one
selected=$(echo "$options" | rofi -dmenu -p "Select Network")

# Exit if no option is selected
if [ -z "$selected" ]; then
    exit 1
fi

# Ensure the Disconnect option is handled properly before proceeding
if [ "$selected" == "Disconnect" ]; then
    nmcli dev disconnect wlan0
    notify-send "Disconnected from the network"
    exit 0
fi

# Proceed only if a valid network is selected

# Ask for the password
password=$(rofi -dmenu -password -p "Enter password for $selected")

# Connect to the selected network
nmcli dev wifi connect "$selected" password "$password"