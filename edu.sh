#!/bin/bash

sleep "$(echo $RANDOM | grep -Eo ^[0-9][0-9])m"

DIRNAME="$(dirname $0)"

for KEYPAR in $(cat "${DIRNAME}/passwords.txt");
do
    USERNAME="$(echo "$KEYPAR" | cut -f1 -d:)"
    PASSWORD="$(echo "$KEYPAR" | cut -f2- -d:)"
    TIMESTAMP="$(date +%s)"

    curl -X POST -F "RL_username=${USERNAME}" -F "RL_password=${PASSWORD}" -c "${USERNAME}.${TIMESTAMP}" http://ripollesliders.cat/ > /dev/null 2>&1

    curl -b "${USERNAME}.${TIMESTAMP}" 'http://ripollesliders.cat/votacions.php?c=5' 2>/dev/null | strings | grep Casanova -A 10 | sed 's/>/>\n/g' | sed -n "/<form/,/<\/form>/p" | grep input | grep hidden > "INPUT.${TIMESTAMP}"

    FIELDS=""
    while read -r LINE;
    do
        NAME="$(echo "$LINE" | grep -Eo 'name="[^"]*"' | cut -f2 -d\")"
        VALUE="$(echo "$LINE" | grep -Eo 'value="[^"]*"' | cut -f2 -d\")"
        FIELDS="${FIELDS} -F ${NAME}=${VALUE}"
    done < "INPUT.${TIMESTAMP}"

    sleep "$(echo $RANDOM | grep -Eo ^[0-9])s"

    curl -b "${USERNAME}.${TIMESTAMP}" -X POST $FIELDS 'http://ripollesliders.cat/votacions.php?c=5' >/dev/null 2>/dev/null

    rm -f "INPUT.${TIMESTAMP}" "${USERNAME}.${TIMESTAMP}"

    sleep "$(echo $RANDOM | grep -Eo ^[0-9])m"

done

