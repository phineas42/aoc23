#!/usr/bin/bash

set -e

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

#Main
{
	read -a TIMES
	read -a DISTANCES
	TIMES=(${TIMES[@]:1})
	DISTANCES=(${DISTANCES[@]:1})
	IFS=''
	RACE_TIME="${TIMES[*]}"
	RACE_RECORD="${DISTANCES[*]}"
	unset IFS
} <<<"$INPUT_DATA"

get_distance() {
	local RACE_TIME=$1 HOLD_TIME=$2
	if [[ "$HOLD_TIME" -ge "$RACE_TIME" ]]; then
		RESULT=0
		return
	fi
	RESULT=$(((RACE_TIME-HOLD_TIME)*HOLD_TIME))
}

# The optimum hold_time is always race_time/2
# (The zero of d/dx of distance, where x is hold_time, is race_time/2)
MIN_HOLD=0
MAX_HOLD=$((RACE_TIME/2))

# Binary Search: Determine minimum hold_time to beat record
while [[ $MIN_HOLD != $MAX_HOLD ]]; do
	OLD_PIVOT=$PIVOT
	PIVOT=$((MIN_HOLD+(MAX_HOLD-MIN_HOLD)/2))
	if [[ "$OLD_PIVOT" != "$PIVOT" ]]; then
		get_distance $RACE_TIME $PIVOT
		if [[ $RESULT -eq $RACE_RECORD ]]; then
			MIN_HOLD=$((PIVOT+1))
			break
		elif [[ $RESULT -gt $RACE_RECORD ]]; then
			MAX_HOLD=$PIVOT
		else
			MIN_HOLD=$((PIVOT+1))
		fi
	else
		MIN_HOLD=$PIVOT
		MAX_HOLD=$PIVOT
	fi
done

# real MAX_HOLD is determined algebraicly from the MIN_HOLD
MAX_HOLD=$((RACE_TIME-MIN_HOLD))
echo $((MAX_HOLD-MIN_HOLD+1))
