#!/bin/bash

# Convert ASCII digits to Devanagari numerals
to_devanagari() {
    sed 'y/0123456789/०१२३४५६७८९/'
}

# Convert English day names to Nepali
convert_days() {
    sed -e 's/Sunday/आइतबार/g' \
        -e 's/Monday/सोमबार/g' \
        -e 's/Tuesday/मङ्गलबार/g' \
        -e 's/Wednesday/बुधबार/g' \
        -e 's/Thursday/बिहिबार/g' \
        -e 's/Friday/शुक्रबार/g' \
        -e 's/Saturday/शनिबार/g'
}

# Convert English month abbreviations to Nepali numerals
convert_months_abbr_to_numbers() {
    sed -e 's/Jan/०१/g' \
        -e 's/Feb/०२/g' \
        -e 's/Mar/०३/g' \
        -e 's/Apr/०४/g' \
        -e 's/May/०५/g' \
        -e 's/Jun/०६/g' \
        -e 's/Jul/०७/g' \
        -e 's/Aug/०८/g' \
        -e 's/Sep/०९/g' \
        -e 's/Oct/१०/g' \
        -e 's/Nov/११/g' \
        -e 's/Dec/१२/g'
}

# Accept format string as argument, default to "%A, %b %d, %Y %H:%M"
fmt="${1:-%A, %b %d, %Y %H:%M}"

# Get date/time and convert everything to Nepali
# Order: date -> days -> months -> AM/PM -> Devanagari numerals

date +"$fmt" \
    | convert_days \
    | convert_months_abbr_to_numbers \
    | sed -e 's/ AM/ बिहान/g' -e 's/ PM/ बेलुका/g' \
    | to_devanagari
