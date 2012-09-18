#!/bin/bash

main_javascript_file=/usr/local/node/docs/project/app.js

usage="$(basename $0) option
where:
    option = start | restart | stop"

if [ ! $# -eq 1 ]; then
	echo -e "\e[0;31mError: $(basename $0) requires 1 argument!\e[0m"
	echo "$usage"
	exit 1
fi

if [[ $1 =~ ^("start"|"START")$ ]]; then # Start the node process

	# check to see if node process exists
	server_online=`ps -a | grep node`

	if [ -n "$server_online" ]; then
		echo "Node server appears to be online:"
		echo "  PID TTY          TIME CMD"
		echo -e "$server_online \e[0;32m<--\e[0m"
		exit 2
	fi

	echo "Starting Node Process"
	echo "node $main_javascript_file &" 
	/usr/local/node/bin/node $main_javascript_file &

elif [[ $1 =~ ^("restart"|"RESTART"|"bounce"|"BOUNCE")$ ]]; then # Restart the node process

	node_pid=`ps -e | pgrep -x node`

	if [ ! -n "$node_pid" ]; then
		echo "No node process was found"
		exit 2
	fi

	echo "Killing Node Process"
	echo "kill -9 $node_pid"
	kill -9 $node_pid

	echo "Starting Node Process"
	echo "node $main_javascript_file &" 
	/usr/local/node/bin/node $main_javascript_file &

elif [[ $1 =~ ^("kill"|"KILL"|"stop"|"STOP")$ ]]; then # Kill the node process

	node_pid=`ps -e | pgrep -x node`

	if [ ! -n "$node_pid" ]; then
		echo "No node process was found"
		exit 2
	fi

	echo "Killing Node Process"
	echo "kill -9 $node_pid"
	kill -9 $node_pid

else
	echo -e "\e[0;31mThe command '$1' is not recognized...\e[0m"
	echo "$usage"
	exit 1
fi
