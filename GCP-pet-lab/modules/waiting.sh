#!/bin/bash

function waiting() {

    ### Function to wait for a key press
    function wait_for_key_press() {
        read -n 1 -s -t $1 key
        if [[ $key == "q" ]]; then
            return 0  # Space bar pressed
        fi
        sleep $1
        return 1  # No key pressed
    }

    DURATION=$1
    INTERVAL=$2
    ELAPSED=$3

    while [ $ELAPSED -lt $DURATION ]; do
        echo -n "${ELAPSED}s "
        ELAPSED=$((ELAPSED + INTERVAL))
        if wait_for_key_press $INTERVAL; then
            echo -e "\nInterrupted by user."
            break
        fi
    done
}