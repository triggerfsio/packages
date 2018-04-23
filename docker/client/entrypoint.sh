#!/bin/sh

if [ ! -z "${TIMEOUT}" ]; then
  TIMEOUTSTR="-timeout ${TIMEOUT}"
fi
./triggerfs-client -service ${SERVICE} -plugin ${PLUGIN} ${TIMEOUTSTR} -command ${COMMAND}
