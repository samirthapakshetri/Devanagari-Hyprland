#!/usr/bin/env bash
# Script parses /proc/uptime to get the system uptime
# and prints it in a human-readable Nepali format (Devanagari)

if [[ -r /proc/uptime ]]; then
    s=$(< /proc/uptime)
    s=${s/.*}
else
    echo "त्रुटि uptime.sh: समय निर्धारण गर्न असमर्थ." >&2
    exit 1
fi

# Calculate days, hours, minutes, seconds
DAYS=$((s / 60 / 60 / 24))
HOURS=$((s / 60 / 60 % 24))
MINUTES=$((s / 60 % 60))

# Prepare Nepali labels
day_label="दिन"
hour_label="घण्टा"
minute_label="मिनेट"

# Build uptime components if non-zero
parts=()
[[ $DAYS -gt 0 ]] && parts+=("${DAYS} ${day_label}")
[[ $HOURS -gt 0 ]] && parts+=("${HOURS} ${hour_label}")
[[ $MINUTES -gt 0 ]] && parts+=("${MINUTES} ${minute_label}")
[[ $SECONDS -gt 0 ]] && parts+=("${SECONDS} ${second_label}")

# Join with commas
IFS="," read -r -a output <<< "${parts[*]}"
joined=$(printf "%s" "${parts[0]}")
for ((i=1; i<${#parts[@]}; i++)); do
    joined+=", ${parts[i]}"
done

# Fallback if everything zero
[[ -z "$joined" ]] && joined="0 ${second_label}"

echo "$joined"
