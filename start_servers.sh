#/bin/bash

# kill process group when closed
trap "kill 0" SIGINT SIGTERM EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLICKER_SERVER_DIR=$DIR/rhombus-clicker-server
ID_SERVER_DIR=$DIR/rhombus-id-server

echo "> Starting Clicker Server ..."
ant -f $CLICKER_SERVER_DIR/ClickerServer/build.xml ClickerServer &
pidClickerServer="$!"

clickerServerPort=4444
idServerPort=4445
listeningAttempt=1
maxListeningAttempts=10
function checkListening()
{
	port=$1
	name=$2
	serverListening=`netstat -an | grep $port`
	if [ -z "$serverListening" ]; then
		echo "> $name not listening. Attempt $listeningAttempt of $maxListeningAttempts."
		((listeningAttempt++))
		if [ "$listeningAttempt" -le "$maxListeningAttempts" ]; then
			sleep $((2*$listeningAttempt))
			checkListening $1 "$2"
		fi
	else
		echo "> $name now listening on port $port..."
		listeningAttempt=1
	fi
}

sleep 2
checkListening $clickerServerPort "Clicker Server"

if [ "$listeningAttempt" -gt "$maxListeningAttempts" ]; then
	echo "> Clicker Server did not start listening to port $clickerServerPort in time. Aborting..."
	exit 1
fi

# check if clicker server still running
clickerServerRunning=`kill -0 "$pidClickerServer" 2>/dev/null && echo 1 || echo 0`

if [ "$clickerServerRunning" -eq "0" ]; then
    echo "> Clicker server failed."
    exit 1
fi


#
# Start ID Server
#
echo "> Starting ID Server ..."
ant -f $ID_SERVER_DIR/build.xml IdServer &
pidIdServer="$!"

sleep 1

# check if ID Server still running
idServerRunning=`kill -0 "$pidIdServer" 2>/dev/null && echo 1 || echo 0`

if [ "$idServerRunning" -eq "0" ]; then
    echo "> ID Server failed. Exiting..."
    kill 0
    exit 1
fi

sleep 2
checkListening $idServerPort "ID Server"

if [ "$listeningAttempt" -gt "$maxListeningAttempts" ]; then
	echo "> ID Server did not start listening to port $idServerPort in time. Aborting..."
	exit 1
fi


wait
