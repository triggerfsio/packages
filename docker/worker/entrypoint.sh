#!/bin/sh

if [ ! -z "${DEBUG}" ]; then
  DEBUGSTR="-debug ${DEBUG}"
fi
./triggerfs-worker -identity ${IDENTITY} ${DEBUGSTR}
