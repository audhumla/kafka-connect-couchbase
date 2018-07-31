echo "*************************************************************************************"
echo "BEGINNING to start the couchbase connector with $CONNECT_BIN $CONNECT_CFG $CB_CONNECT_CFG"
echo "*************************************************************************************"

tag="[start-connect.sh]"

function info {
  echo "$tag (INFO) : $1"
}
function warn {
  echo "$tag (WARN) : $1"
}
function error {
  echo "$tag (ERROR): $1"
}

echo "*************************************************************************************"
echo "About to start the couchbase connector with $CONNECT_BIN $CONNECT_CFG $CB_CONNECT_CFG"
echo "*************************************************************************************"

CONNECT_PID=0

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

echo "==============================================================================="
echo "Starting the couchbase connector with $CONNECT_BIN $CONNECT_CFG $CB_CONNECT_CFG"
echo "==============================================================================="

$CONNECT_BIN $CONNECT_CFG $CB_CONNECT_CFG &
CONNECT_PID=$!

wait