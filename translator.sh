#!/bin/bash

PROMPT="drive> "
SPEED=5

function pifn_halt {
	echo drive 4 0
	echo drive 5 0
	echo drive 6 0
}

function pifn_exit {
	pifn_halt
	echo led 0 0 1
	for channel in 0 1 2 3
	do
		echo pwm $channel 0
	done
	echo quit
}

function speed {
	if [ -z "$2" ]
	then
		echo "echo speed=$SPEED"
	else
		if [ "$2" -lt 1 -o "$2" -gt 7 ]
		then
			echo "echo Speed should be 1 to 7"
		else
			SPEED="$2"
		fi
	fi
}

function bool_out {
	if [ -z "$3" -o '(' "$3" != "on" -a "$3" != "off" ')' ]
	then
		echo "echo Usage: $2 <on|off>"
	else
		if [ "$3" == "on" ]
		then
			echo pwm $1 1
		else
			echo pwm $1 0
		fi
	fi
}

function default {
	if [[ "$3" =~ [1-7] ]]
	then
		echo "$3"
	else
		echo "$1"
	fi
}

function camera_look {
	if [ -n "$2" ]
	then
		echo "servo 1 $2"
	fi

	if [ -n "$3" ]
	then
		echo "servo 0 $3"
	fi
}

(echo servo 0 0
echo servo 1 .55
echo led 0 1 0

echo "echo $PROMPT"
while read cmd
do
	case "`echo "$cmd" | cut -f 1 -d ' '`" in

	# Exit shell
	q|quit)
		pifn_exit
		exit 0
		;;

	# Halt: stops driving and straightens up wheels
	h)
		pifn_halt
		;;

	# Straight: straightens up wheels so it won't go round a corner
	s)
		echo drive 4 0
		echo drive 6 0
		;;

	# Forward
	f)
		echo drive 5 -`default $SPEED $cmd`
		;;

	# Backward
	b)
		echo drive 5 `default $SPEED $cmd`
		;;

	# Right
	r)
		val=`default 7 $cmd`
		echo drive 4 $val
		echo drive 6 -$val
		;;

	# Left
	l)
		val=`default 7 $cmd`
		echo drive 4 -$val
		echo drive 6 $val
		;;

	# Diagonal right
	dr)
		echo drive 4 7
		echo drive 6 7
		;;

	# Diagonal left
	dl)
		echo drive 4 -7
		echo drive 6 -7
		;;

	# Prints/sets speed
	zoom)
		speed $cmd
		;;

	# Camera home: looks forwards
	ch)
		echo servo 0 0
		echo servo 1 .55
		;;

	#Camera look: short hand for two servo commands
	cl)
		camera_look $cmd
		;;

	# Nod: nods camera up/down
	nod)
		echo servo 0 0
		echo servo 1 .2
		sleep .3
		echo servo 1 .55
		sleep .3
		echo servo 1 .2
		sleep .3
		echo servo 1 .55
		;;

	# Shake: shakes camera left/right
	shake)
		echo servo 1 .55
		echo servo 0 .3
		sleep .3
		echo servo 0 -.3
		sleep .3
		echo servo 0 .3
		sleep .3
		echo servo 0 0
		;;

	# Turn headlights on or off
	light|lights)
		bool_out 2 $cmd
		;;

	# Turn laser pointer on or off
	laser)
		bool_out 3 $cmd
		;;

	# Everything else: send it to echod as is
	*)
		echo $cmd
		;;
	esac

	echo "echo $PROMPT"
done

pifn_exit
)
