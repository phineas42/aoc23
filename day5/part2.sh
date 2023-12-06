#!/usr/bin/bash

set -e

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

min() {
	unset RESULT
	declare -g RESULT=$1
	shift
	local N
	for N in $@; do
		if [[ $N -lt $RESULT ]]; then
			RESULT=$N
		fi
	done
}

split_pairs() {
	local PAYLOAD=$1
	unset RESULT
	declare -g -a RESULT
	while [[ "$PAYLOAD" =~ ([^\ ]+\ +[^\ ]+)(.*) ]]; do
		RESULT+=("${BASH_REMATCH[1]}")
		PAYLOAD="${BASH_REMATCH[2]}"
	done
}

drop_alternating() {
	local PAYLOAD=$1
	unset RESULT
	declare -g -a RESULT
	while [[ "$PAYLOAD" =~ ([^\ ]+)\ +[^\ ]+(.*) ]]; do
		RESULT+=("${BASH_REMATCH[1]}")
		PAYLOAD="${BASH_REMATCH[2]}"
	done
}

declare -a RANGES
declare -a PENDING_RANGES

while read LINE; do
	if [[ "$LINE" =~ ^seeds:\ (.*) ]]; then
		split_pairs "${BASH_REMATCH[1]}"
		RANGES=("${RESULT[@]}")
		PENDING_RANGES=("${RANGES[@]}")
	elif [[ "$LINE" =~ ^[[:digit:]] ]]; then
		read DEST_START SRC_START LEN <<<$LINE
		SRC_END=$((SRC_START+LEN-1))
		DEST_END=$((DEST_START+LEN-1))
		for ((I=0;I<${#RANGES[@]};I++)); do
			# Determine if any overlap occurs between the current range and the remap range
			read RANGE_START RANGE_LEN <<<"${RANGES[$I]}"
			RANGE_END=$((RANGE_START+RANGE_LEN-1))
			if [[ $RANGE_END -ge $SRC_START && \
				$RANGE_END -le $SRC_END ]]; then
				if [[ $RANGE_START -lt $SRC_START ]]; then
					#Left overlap
					PENDING_RANGES[$I]="$RANGE_START $((SRC_START-RANGE_START))"
					PENDING_RANGES[$I]+=" $DEST_START $((RANGE_LEN-(SRC_START-RANGE_START)))"
					RANGES[$I]="$RANGE_START $((SRC_START-RANGE_START))"
					RANGES[$I]+=" $SRC_START $((RANGE_LEN-(SRC_START-RANGE_START)))"
				else
					#Subsumption
					PENDING_RANGES[$I]="$((RANGE_START+DEST_START-SRC_START)) $RANGE_LEN"
				fi
			elif [[ $RANGE_START -le $SRC_END && \
				$RANGE_START -ge $SRC_START ]]; then
				#Right overlap
				PENDING_RANGES[$I]="$((RANGE_START+DEST_START-SRC_START)) $((RANGE_LEN-(RANGE_END-SRC_END)))"
				PENDING_RANGES[$I]+=" $((SRC_END+1)) $((RANGE_END-SRC_END))"
				RANGES[$I]="$RANGE_START $((RANGE_LEN-(RANGE_END-SRC_END)))"
				RANGES[$I]+=" $((SRC_END+1)) $((RANGE_END-SRC_END))"
			elif [[ $RANGE_START -lt $SRC_START && \
				$RANGE_END -gt $SRC_END ]]; then
				#Supersumption
				PENDING_RANGES[$I]="$RANGE_START $((SRC_START-RANGE_START))"
				PENDING_RANGES[$I]+=" $DEST_START $LEN"
				PENDING_RANGES[$I]+=" $((SRC_END+1)) $((RANGE_END-SRC_END))"
				RANGES[$I]="$RANGE_START $((SRC_START-RANGE_START))"
				RANGES[$I]+=" $SRC_START $LEN"
				RANGES[$I]+=" $((SRC_END+1)) $((RANGE_END-SRC_END))"
			else
				# if [[ $RANGE_END -lt $SRC_START || $RANGE_START -gt $SRC_END ]]; then
				#no overlap
				:
			fi
		done
		split_pairs "${RANGES[*]}"
		RANGES=("${RESULT[@]}")
		split_pairs "${PENDING_RANGES[*]}"
		PENDING_RANGES=("${RESULT[@]}")
	elif [[ "$LINE" == "" ]]; then
		split_pairs "${PENDING_RANGES[*]}"
		RANGES=("${RESULT[@]}")
		PENDING_RANGES=("${RANGES[@]}")
	fi
done <<<"$INPUT_DATA"
drop_alternating "${PENDING_RANGES[*]}"
min ${RESULT[@]}
echo $RESULT
