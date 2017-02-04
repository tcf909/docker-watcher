#!/bin/bash

[[ "${DEBUG}" == "true" ]] && set -x

SOURCE="${1}"
shift

# Check if inotofywait is installed.
hash inotifywait 2>/dev/null
if [ $? -eq 1 ]; then
  echo "Unable to execute the script. Please make sure that inotify-utils
  is installed in the system."
  exit 1
fi

RUNNING=0
WAITING=()

RUN() {

    [[ "${DEBUG}" == "true" ]] && set -x

    FILE="${FILE}"

    [[ -z "${FILE}" ]] && echo "\$FILE not set. Exiting." && exit 1

    echo "Running command (${CMD})..."
    RESULT="$(eval "${1}")"
    EXIT=$?
    echo "Done at ($(date)) with exit status (${EXIT})."
    return ${EXIT}

}

inotifywait -m -e close_write -e moved_to --format '%w%f' "${SOURCE}" | \
while read TFILE; do

    [[ "${DEBUG}" == "true" ]] && set -x

    [[ "${RUNNING}" == 1 ]] && WAITING+=("${TFILE}") && continue

    RUNNING=1 && WAITING+=("${TFILE}")

    while [[ ${#WAITING[@]} > 0 ]]; do

        ORIG_CMD="$*"
        FILE="${WAITING[0]}"
        CMD="$(echo "${*}")"
        echo "Event triggered for (${FILE})..."

        RUN "${CMD}"
        EXIT=$?

        [[ "${EXIT}" != "0" ]] && echo "Problem with command (${CMD}). Return code (${EXIT}). Exiting." && exit ${EXIT}

	WAITING=("${WAITING[@]:1}")

    done

    RUNNING=0

done