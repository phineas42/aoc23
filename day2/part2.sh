#!/usr/bin/bash

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

max() {
	if [[ $1 -gt $2 ]]; then
		RESULT=$1
	else
		RESULT=$2
	fi
}

ACCUMULATOR=0
while read LINE; do
	[[ "$LINE" =~ ^Game\ ([[:digit:]]*):\ (.*)$ ]]
	GAME_NUMBER=${BASH_REMATCH[1]}
	declare -A MINS=([red]=0 [green]=0 [blue]=0)
	IFS=\;
	read -a SETS <<<"${BASH_REMATCH[2]}"
	for SET in "${SETS[@]}"; do
		IFS=\,
		read -a SUBSETS <<<"$SET"
		for SUBSET in "${SUBSETS[@]}"; do
			[[ "$SUBSET" =~ ([[:digit:]]*)\ (red|blue|green) ]]
			COUNT=${BASH_REMATCH[1]}
			COLOR=${BASH_REMATCH[2]}
			max $COUNT ${MINS[$COLOR]}
			MINS[$COLOR]=$RESULT
		done
	done
	ACCUMULATOR=$((ACCUMULATOR+${MINS[red]}*${MINS[green]}*${MINS[blue]}))
done <<<"$INPUT_DATA"
echo $ACCUMULATOR
