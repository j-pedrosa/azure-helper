#!/usr/bin/bash
    
SERVER=$1
DELAY=0
PROTOCOL_VERSIONS='ssl3 tls1 tls1_1 tls1_2 tls1_3'
CIPHERS=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')


for protocol_version in ${PROTOCOL_VERSIONS[@]}; do
    echo -n Testing $protocol_version...
    result=$(echo -n | openssl s_client -connect $SERVER -$protocol_version 2>&1)
        if [[ $? == 0 ]]; then
        echo "YES"
    else
        echo "NO"
    fi
done
for cipher in ${CIPHERS[@]}; do
    echo -n Testing $cipher...
    result=$(echo -n | openssl s_client -cipher "$cipher" -connect $SERVER 2>&1)
    if [[ "$result" =~ ":error:" ]]; then
        error=$(echo -n $result | cut -d':' -f6)
        echo NO \($error\)
    else
        if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]]; then
            echo YES
        else
            echo UNKNOWN RESPONSE
            echo $result
        fi
    fi
    sleep $DELAY
done