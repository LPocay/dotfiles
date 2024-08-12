#!/bin/bash

connected_monitors=$(xrandr | grep " connected" | awk '{ print$1 }')

# Define the names of the laptop and external monitors
laptop_monitor="eDP"
external_monitor="HDMI"
display_port_monitor="DP"

laptop_monitor_name=$(echo "$connected_monitors" | grep "^$laptop_monitor")
external_monitor_name=$(echo "$connected_monitors" | grep "^$external_monitor")
external_dp_monitor_name=$(echo "$connected_monitors" | grep "^$display_port_monitor")

if echo "$connected_monitors" | grep -q "^$external_monitor"; then
    # External monitor is connected
    xrandr --output $external_monitor_name --auto --primary --output $laptop_monitor_name --off
    echo "External monitor is connected. Setting external monitor as primary and turning off laptop monitor."
    if echo "$connected_monitors" | grep -q "^$display_port_monitor"; then
      xrandr --output $external_dp_monitor_name --auto --left-of $external_monitor_name
      echo "External monitor DP is connected. Setting external DP monitor left of primary."
    fi
else
    # External monitor is not connected
    echo "External monitor is not connected. No changes made."
fi
