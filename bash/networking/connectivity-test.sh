#!/bin/bash

# Define the target IP address and port to test
TARGET_IP_OR_FQDN="microsoft.com"
TARGET_PORT=443

# Define the output file to write the results to
OUTPUT_FILE="/var/log/connectivity.log"

# Loop forever and perform a connectivity test every minute
while true; do
    # Perform the connectivity test using netcat and capture the output
    nc -vv -z -w 3 $TARGET_IP_OR_FQDN $TARGET_PORT >> $OUTPUT_FILE 2>&1
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
        STATUS="SUCCESS"
    else
        STATUS="FAILURE"
    fi

    # Write the results to the output file
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP - $TARGET_IP_OR_FQDN:$TARGET_PORT - $STATUS" >> $OUTPUT_FILE

    # Wait for 1 minute before performing the next connectivity test
    sleep 60
done