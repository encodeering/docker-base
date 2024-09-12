#!/usr/bin/env bash
set -euo pipefail

shiftuid () {
    if [ ! -z "${1:+x}" ]; then
        local name="${1}"
        local uid="$(id -u ${name})"

        usermod -u $((${uid}+50)) "${name}"

        find / -user "${uid}" -exec chown -h "${name}" {} \;
    fi
}

shiftgid () {
    if [ ! -z "${1:+x}" ]; then
        local name="${1}"
        local gid="$(id -g ${name})"

        groupmod -g $((${gid}+50)) "${name}"

        find / -group "${gid}" -exec chgrp -h "${name}" {} \;
    fi
}

# uid:gid
declare -A reserved
           reserved=(
               [0]="101:101" # nginx
           )

for value in "${reserved[@]}"; do
    shiftuid $(getent passwd "${value%%:*}" | cut -d: -f1)
    shiftgid $(getent group  "${value##*:}" | cut -d: -f1)
done
