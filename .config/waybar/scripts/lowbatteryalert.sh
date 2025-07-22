#!/bin/bash

BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/BAT0/status)
FLAG_FILE="/tmp/battery_action.flag"

if [[ "$STATUS" == "Discharging" ]]; then

    # 🔊 Alarm + Notification at 20%
    if [[ "$BATTERY_LEVEL" -le 20 && "$BATTERY_LEVEL" -gt 11 ]]; then
        if [[ ! -f "$FLAG_FILE.20" ]]; then
            notify-send "🔋 Battery Low" "Battery is at ${BATTERY_LEVEL}%"
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
            touch "$FLAG_FILE.20"
        fi
    fi

    # 😴 Sleep at 11% (No notification/sound)
    if [[ "$BATTERY_LEVEL" -le 11 && "$BATTERY_LEVEL" -gt 7 ]]; then
        if [[ ! -f "$FLAG_FILE.11" ]]; then
            systemctl suspend
            touch "$FLAG_FILE.11"
        fi
    fi

    # ⛔ Shutdown at 7% (No notification/sound)
    if [[ "$BATTERY_LEVEL" -le 7 ]]; then
        if [[ ! -f "$FLAG_FILE.07" ]]; then
            sleep 5
            systemctl poweroff
            touch "$FLAG_FILE.07"
        fi
    fi

elif [[ "$STATUS" == "Charging" && "$BATTERY_LEVEL" -ge 90 ]]; then
    # 🔔 Alert at 90% or more while charging
    if [[ ! -f "$FLAG_FILE.90" ]]; then
        notify-send "🔌 Battery Almost Full" "Battery is at ${BATTERY_LEVEL}%"
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
        touch "$FLAG_FILE.90"
    fi

else
    # Charging or Full: Reset discharging action flags
    rm -f "$FLAG_FILE.20" "$FLAG_FILE.11" "$FLAG_FILE.07"

    # Reset full-charge flag if battery drops below 90%
    if [[ "$BATTERY_LEVEL" -lt 90 ]]; then
        rm -f "$FLAG_FILE.90"
    fi
fi
