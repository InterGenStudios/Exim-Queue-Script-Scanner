#!/bin/bash
# -------------------------------------------------------
# Exim-Queue Script-Scanner: Scans the entire Exim queue for php scripts
# Github: https://github.com/InterGenStudios/eqss
# ---------------------------------------------------
# InterGenStudios: 6-27-15
# Copyright (c) 2015: Christopher 'InterGen' Cork  InterGenStudios
# URL: https://intergenstudios.com
# --------------------------------
# License: GPL-2.0+
# URL: http://opensource.org/licenses/gpl-license.php
# ---------------------------------------------------
# Exim-Queue Script-Scanner is free software:
# You may redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software
# Foundation, either version 2 of the License, or (at your discretion)
# any later version.
# ------------------

# Timestamp for logging
TIMESTAMP="$(date +"%m-%d-%Y_at_%T")"

# Repeating header gives a cleaner look
HEADER () {
    clear
    printf "\n\n"
    echo -e "\e[1m\e[34m_____________________________________________________________________________\e[0m"
    printf "\n"
    echo -e "\e[1m\e[32m       Exim-Queue Script-Scanner\e[0m   ran on $TIMESTAMP"
    echo -e "\e[1m\e[34m_____________________________________________________________________________\e[0m"
    printf "\n\n"
}

# The actual do-work function
SCANNER () {
    printf "\n\n"
    echo -e "\e[1m\e[32m-------------\e[0m"
    LINE1="$(echo -e "\e[1m\e[32min Exim ID: \e[1m\e[37m$each\e[0m")"
    LINE2="$(exim -Mvh "$each" | grep -i script | awk '{print $2" "$3" "$4" "$5}')"
    DOMAIN="$(echo "$LINE2" | awk '{print $2}' | sed -e "s/\// /g" | awk '{print $1}')"
    ACCOUNT="$(grep -A 2 "$DOMAIN" /usr/local/apache/conf/httpd.conf | head -3 | tail -1 | awk '{print $2}' | sed -e "s/\// /g" | awk '{print $2}')"
    echo -e "\e[1m\e[32mScript sent from the $ACCOUNT Account $LINE1  >>>  \e[1m\e[37m$LINE2\e[0m"
    echo -e "\e[1m\e[32m-------------\e[0m"
    printf "\n\n"
    unset LINE1 LINE2 DOMAIN ACCOUNT
}

# Repeating header gives a cleaner look
HEADER

# Pause for effect
echo -e "\e[1m\e[32mStarting scan, please stand by....\e[0m"
sleep 3
tput cuu 1 && tput el

# Do the actual work
for each in $(exim -bp | awk '{print $3}'); do
    SCANNER 2>&1 | tee >> queuerun
    tput cuu 7 && tput el
done

# Repeating header gives a cleaner look
HEADER

# Set up layout for customer presentation
echo " " > scriptsfound-header
echo " " >> scriptsfound-header
echo "=================================" >> scriptsfound-header
echo Exim-Queue_Script-Scanner Results >> scriptsfound-header
echo "=================================" >> scriptsfound-header
echo " " >> scriptsfound-header
echo " " >> scriptsfound-header
echo " " >> scriptsfound-header
echo " " >> scriptsfound-header
grep -B 1 X-PHP queuerun | grep '.php' > scriptsfound-body
echo " " > scriptsfound-footer
echo " " >> scriptsfound-footer
echo " " >> scriptsfound-footer
echo " " >> scriptsfound-footer
echo "=======================================================" >> scriptsfound-footer
echo -e "\e[1m\e[32mExim-Queue_Script-Scanner ran on $TIMESTAMP" >> scriptsfound-footer
echo "=======================================================" >> scriptsfound-footer
echo " " >> scriptsfound-footer
echo " " >> scriptsfound-footer

# Generate single document for presentation
cat scriptsfound-header > scriptsfound
cat scriptsfound-body >> scriptsfound
cat scriptsfound-footer >> scriptsfound

# Clear color entries from presentation
sed -i -e 's/\[1m//g' -e 's/\[32m//g' -e 's/\[0m//g' -e 's/\[37m//g' scriptsfound

# Generate a raw pastefile for presentation
curl -d name=EximQueueScriptScanner -d private=1 --data-urlencode text@scriptsfound -s http://nobits.ml/api/create > pastefile
sed -i 's/view/view\/raw/' pastefile

# On-screen display for user
printf "\n\n"
echo -e "\e[1m\e[4m\e[34mExim-Queue_Script-Scanner Pastefile:\e[0m"
printf "\n"
echo -e "\e[1m\e[32m   ======>  \e[1m\e[37m$(cat pastefile)\e[0m"

# Create the log directory if it doesn't already exist, clear the escape characters from the log, file the log
mkdir -p /root/support/logs/eqss_logs
sed -i 's/[\x01-\x1F\x7F]//g' scriptsfound
mv scriptsfound /root/support/logs/eqss_logs/queue-scan_"$TIMESTAMP"

# Note the log for the user
printf "\n\n"
echo -e "\e[1m\e[37mA log of this scan can be found at \e[1m\e[32m/root/support/logs/eqss_logs\e[0m"
printf "\n\n"

# Tidy up presentation generation files
rm scriptsfound-body scriptsfound-footer scriptsfound-header queuerun pastefile

# Clean exit
exit 0
