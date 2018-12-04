#!/bin/sh

set -o errexit
set -o noglob

configfile="/etc/jobber.conf"

if [[ ! -f "${configfile}" ]]; then
  touch ${configfile}

  if [[ -n "${JOBS_NOTIFY_CMD}" ]]; then
    cat > ${configfile} <<_EOF_
[prefs]
  notifyProgram: ${JOBS_NOTIFY_CMD}
_EOF_

  fi
  cat >> ${configfile} <<_EOF_
[jobs]
_EOF_
  i=0
  while true; do
    i=$(expr ${i} + 1)

    JOB_NAME=$(eval echo "\$JOB_NAME${i}")
    JOB_TIME=$(eval echo "\$JOB_TIME${i}")
    JOB_COMMAND=$(eval echo "\$JOB_COMMAND${i}")
    JOB_ON_ERROR=$(eval echo "\$JOB_ON_ERROR${i}")
    JOB_NOTIFY_ERR=$(eval echo "\$JOB_NOTIFY_ERR${i}")
    JOB_NOTIFY_FAIL=$(eval echo "\$JOB_NOTIFY_FAIL${i}")

    if [[ -z "${JOB_NAME}" ]]; then break; fi

    cat >> ${configfile} <<_EOF_
- name: ${JOB_NAME}
  time: '${JOB_TIME}'
  cmd: ${JOB_COMMAND}
  onError: ${JOB_ON_ERROR}
  notifyOnError: ${JOB_NOTIFY_ERR}
  notifyOnFailure: ${JOB_NOTIFY_FAIL}

_EOF_
  done
fi

cat ${configfile}
echo

exec "$@"
