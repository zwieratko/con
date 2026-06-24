#!/usr/bin/env bash

# https://devhints.io/bash

# first: check if ~/.ssh/config exists? if not, exit?
if ! [ -f "${HOME}/.ssh/config" ]; then
    echo "Sorry, we can not continue without config file?!"
    exit 1
fi

# we need to read all hosts from config
# how? to array?
# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# https://stackoverflow.com/a/13825568
mapfile -t allHosts < <(awk 'tolower($1) == "host" && $2 != "*" {print $2}' "${HOME}/.ssh/config")
totalHosts="${#allHosts[@]}"
exceptLast="2"
visibleHost=$((totalHosts - exceptLast))
fromHost="0"
if ! ((fromHost < visibleHost)); then
    echo "Sorry, no hosts available after filtering (total: ${totalHosts}, from: ${fromHost}, excluded: ${exceptLast})."
    exit 1
fi

# check if user launch the script with parameter?
# if parameter is in range of visibleHosts => connect user
# if parameter is out of range exit
# if there is no parameter continue
if [ -n "${1}" ]; then
    targetHost="${1}"
else
    for ((i = fromHost; i < visibleHost; i++)); do
        echo "${i}: ${allHosts[${i}]}"
    done

    read -p "Please, choose the host number: " -r targetHost
    echo
    # echo "You choose: ${targetHost}: ${allHosts[${targetHost}]}"
fi

# check if user choice is in range of visibleHosts
# if yes, ok, connect
# if no, nok, exit
if [[ ${targetHost} =~ ^[0-9]+$ ]] && ((targetHost >= fromHost)) && ((targetHost < visibleHost)); then
    echo
    echo "We are connecting to ${allHosts[${targetHost}]} ..."
    echo
    ssh "${allHosts[${targetHost}]}"
else
    echo "Sorry, host: >>> ${targetHost} <<< doesn't exists."
    exit 1
fi

echo
echo "Bye, bye..."
exit 0
