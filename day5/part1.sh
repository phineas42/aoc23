#!/usr/bin/bash

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

min() {
	RESULT=$1
	shift
	local N
	for N in $@; do
		if [[ $N -lt $RESULT ]]; then
			RESULT=$N
		fi
	done
}

while read LINE; do
	if [[ "$LINE" =~ ^seeds:\ (.*) ]]; then
		NUMBERS_STR=${BASH_REMATCH[1]}
		NUMBERS=($NUMBERS_STR)
		PENDING_NUMBERS=($NUMBERS_STR)
	elif [[ "$LINE" =~ ^[[:digit:]] ]]; then
		read DEST_BEGIN SRC_BEGIN LEN <<<$LINE
		for ((I=0;I<${#NUMBERS[@]};I++)); do
			NUMBER=${NUMBERS[$I]}
			if [[ $NUMBER -ge $SRC_BEGIN && $((NUMBER-SRC_BEGIN)) -lt $LEN ]]; then
				PENDING_NUMBERS[$I]=$((NUMBER+DEST_BEGIN-SRC_BEGIN))
			fi
		done
	elif [[ "$LINE" == "" ]]; then
		NUMBERS=(${PENDING_NUMBERS[*]})
	fi
done <<<"$INPUT_DATA"
min ${PENDING_NUMBERS[@]}
echo $RESULT
