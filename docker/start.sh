#!/usr/bin/env bash

# default values
tag="[start.sh]"
CONNECT_PID=0

function info {
  echo "$tag (INFO) : $1"
}
function warn {
  echo "$tag (WARN) : $1"
}
function error {
  echo "$tag (ERROR): $1"
}

handleSignal() {
  info 'Stopping... '
  if [ $CONNECT_PID -ne 0 ]; then
    kill -s TERM "$CONNECT_PID"
    wait "$CONNECT_PID"
  fi
  info 'Stopped'
  exit
}

trap "handleSignal" SIGHUP SIGINT SIGTERM
info "Starting the couchbase connector: $CONNECT_BIN $CONNECT_CFG $CB_CONNECT_CFG"
$CONNECT_BIN $CONNECT_CFG $CB_CONNECT_CFG &
CONNECT_PID=$!
wait