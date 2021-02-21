#!/bin/bash

DIRNAME="$(dirname $0)"

OLD_IFS="${IFS}"
IFS="
"
for DATA in $(cat "${DIRNAME}/registre.txt");
do
    TAMANY="$(echo $RANDOM | grep -Eo ^[0-9] | head -n1)"
    USERNAME=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 1${TAMANY} | head -n 1)
    PASSWORD=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)

    NOM=$(echo "$DATA" | cut -f1 -d:)
    DNI=$(echo "$DATA" | cut -f2 -d:)
    EMAIL=$(echo "$DATA" | cut -f3 -d: | sed 's/@/%40/g')
    TELEFON=$(echo "$DATA" | cut -f4 -d:)

    CUQUI="$(curl http://ripollesliders.cat/registre.php \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:85.0) Gecko/20100101 Firefox/85.0' \
    -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'X-Requested-With: XMLHttpRequest' -H 'Origin: http://ripollesliders.cat' -H 'Connection: keep-alive' \
    -H 'Referer: http://ripollesliders.cat/registre.php' \
    -v 2>&1| grep "^< Set-Cookie" | cut -f3 -d' ' | cut -f1 -d';')"

    curl 'http://ripollesliders.cat/save.php' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:85.0) Gecko/20100101 Firefox/85.0' \
    -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'X-Requested-With: XMLHttpRequest' -H 'Origin: http://ripollesliders.cat' -H 'Connection: keep-alive' \
    -H 'Referer: http://ripollesliders.cat/registre.php' -H "Cookie: ${CUQUI}" \
    --data-raw 'form=2&nom='"${NOM}"'&dni='"${DNI}"'&correue='"${EMAIL}"'&telefon='"${TELEFON}"'&usuari='"${USERNAME}"'&contrasenya='"${PASSWORD}"'&contrasenya1='"${PASSWORD}"'&'

    echo "$USERNAME:$PASSWORD" >> passwordgen.txt

    SLEEP="$(echo $RANDOM | grep -Eo ^[0-9])"
    sleep "${SLEEP-1}s"
done
IFS="${OLD_IFS}"

echo "FI"

