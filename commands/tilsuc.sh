#! /usr/bin/env bash


verbose() {
    >&2 echo "verbose: ${@}" && "${@}"
}


do_tilsuc() {
    count=0
    while true; do
        (( count+=1 ))
        >&2 echo "==> tilsuc: Trying No.${count}: ${@}"
        verbose "${@}"
        if [[ $? -eq 0 ]]; then
            break
        fi

        verbose sleep 1
    done
}


do_tilsuc "${@}"
