#!/bin/bash

DICT="/usr/share/dict"


ORANGE="\033[1;33m"
GREEN="\033[1;32m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
RESET="\033[0m"

DEBUG=0

debug() {
    if ! [ "DEBUG" = "1" ]; then
        return 0
    fi

    echo -e "${CYAN}DEBUG: $1${RESET}"
}

_main() {

    read -p "Choose language[EN/it]: " lang

    local LANG=""

    while [ "${LANG}" = "" ]; do
        case "${lang}" in
            "" | EN | en)
                LANG="EN"
                DICT="${DICT}/words"
                break
            ;;
            IT | it)
                LANG="IT"
                DICT="${DICT}/italian"
                break
            ;;
            *)
                echo -e "Invalid language '${lang}' selected!"
            ;;
        esac
    done

    echo -e "Selected language is ${GREEN}${LANG}${RESET}"

    local WORDS="$(grep -E "^[a-z]{5}$" ${DICT})"
    local WORDS_LEN="$(echo "${WORDS}" | wc -l)"

    local NUM="$(od -An -N2 -d /dev/urandom)"
    local NUM=$((NUM % WORDS_LEN))


    local WORD="$(echo "${WORDS}" | head -${NUM} | tail -1 | tr '[:lower:]' '[:upper:]')"

    debug "Selected word is: ${WORD}"

    local TRIES=""
    local LAST_TRY=""

    for i in 1 2 3 4 5 6 ; do
        local TRY=""
        while :; do
            read -p "${i}> " TRY
            if ! [ "$(echo ${TRY} | wc -c)" = "6" ]; then
                continue;
            fi
            if grep -qi "${TRY}" ${DICT} ; then
                break
            fi
        done

        local TRY="$(echo "${TRY}" | head -c 5 | tr '[:lower:]' '[:upper:]')"

        debug "User input is: ${TRY}"

        for ((i = 0; i < 5; i++)); do
            local C_TRY="${TRY:i:1}"
            local C_WORD="${WORD:i:1}"

            if [ "${C_TRY}" = "${C_WORD}" ]; then
                local COL="${GREEN}"
            elif grep -q "${C_TRY}" <<< "${WORD}"; then
                local COL="${ORANGE}"
            else
                local COL=""
            fi

            TRIES="${TRIES}${COL}${C_TRY} ${RESET}"

        done

        LAST_TRY="${TRY}"

        TRIES="${TRIES}\n"

        echo -e "${TRIES}"

        if [ "${LAST_TRY}" = "${WORD}" ]; then
            break
        fi

    done

    if [ "${LAST_TRY}" = "${WORD}" ]; then
        echo -e "Congratulations for your win!!!"
    else
        echo -e "What a looser... The word was ${CYAN}${WORD}${RESET}"
    fi

}

_main

