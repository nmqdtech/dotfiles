#!/bin/bash

# Variables:

datafile="$HOME/.local/share/prayer"
city="Taroudant"
country="Morocco"
method=1
api="https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=$method"
icon="󱠧 "

[ "$(stat -c %y $datafile 2>/dev/null | cut -d ' ' -f1)" != "$(date '+%Y-%m-%d')" ] &&
    curl -s "$api" | jq | grep -E 'Fajr|Dhuhr|Asr|Maghrib|Isha' | head -n 5 | sed 's/ //g ; s/"//g ; s/,$// ; s/:/ /' > $datafile

Fajr="$(cat $datafile | sed -n '1p' | awk '{print $2}')"
Dhuhr="$(cat $datafile | sed -n '2p' | awk '{print $2}')"
Asr="$(cat $datafile | sed -n '3p' | awk '{print $2}')"
Maghrib="$(cat $datafile | sed -n '4p' | awk '{print $2}')"
Isha="$(cat $datafile | sed -n '5p' | awk '{print $2}')"

# Fajr="$(cat $datafile | sed -n '1p')"
# Dhuhr="$(cat $datafile | sed -n '2p')"
# Asr="$(cat $datafile | sed -n '3p')"
# Maghrib="$(cat $datafile | sed -n '4p')"
# Isha="$(cat $datafile | sed -n '5p')"

salawat=( $Fajr $Dhuhr $Asr $Maghrib $Isha )

timediff() {
    t1="$(date -d "$1" +%s)"
    t2="$(date +%s)"
    tf="$(date -d "@$(echo $(( (t1 - t2) )))" +%Hh%M)"
}

output() {
    for prayer in "${salawat[@]}"
    do
        timediff $prayer $date
        echo $tf
    done
}

echo "Next in" $(output | sort -n | head -n1)

