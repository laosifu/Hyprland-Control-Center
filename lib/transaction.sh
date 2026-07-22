#!/usr/bin/env bash

TRANSACTION_ROLLBACKS=()

transaction_reset() {

    TRANSACTION_ROLLBACKS=()

}

transaction_register() {

    TRANSACTION_ROLLBACKS+=("$1")

}

transaction_commit() {

    transaction_reset

}

transaction_rollback() {

    local command

    local index

    for (( index=${#TRANSACTION_ROLLBACKS[@]}-1; index>=0; index-- ))
    do

        command="${TRANSACTION_ROLLBACKS[$index]}"

        eval "$command"

    done

    transaction_reset

}
