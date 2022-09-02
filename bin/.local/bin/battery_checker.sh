#!/bin/bash


while true; do
    battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')

    if [ $battery_level -lt 10 ]; then
        notify-send "Battery is lower than 10%!" "Please connect your charger."
        sleep 60
    elif [ $battery_level -lt 20 ]; then
        notify-send "Battery is lower than 20%!" "Consider connecting your charger."
        sleep 300
    else
        sleep 300
    fi
done

