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

declare -a RANGES
declare -a PENDING_RANGES
while read LINE; do
	if [[ "$LINE" =~ ^seeds:\ (.*) ]]; then
		while read -d ' ' START; do
			read -d ' ' LEN
			RANGES+=("$START $LEN")
			PENDING_RANGES+=("$START $LEN")
		done <<<"${BASH_REMATCH[1]}"
		declare -p RANGES
	elif [[ "$LINE" =~ ^[[:digit:]] ]]; then
		read DEST_START SRC_START LEN <<<$LINE
		SRC_END=$((SRC_START+LEN-1))
		DEST_END=$((DEST_START+LEN-1))
		for ((I=0;I<${#RANGES[@]};I++)); do
			# Determine if any overlap occurs between the current range and the remap range
			read RANGE_START RANGE_LEN <<<"${RANGES[$I]}"
			RANGE_END=$((RANGE_START+RANGE_LEN-1))
			echo "    RANGE:[$RANGE_START - $RANGE_END] SRC:[$SRC_START-$SRC_END] DEST:[$DEST_START-$DEST_END]"
			if [[ $RANGE_END -ge $SRC_START && \
				$RANGE_END -le $SRC_END ]]; then
				if [[ $RANGE_START -lt $SRC_START ]]; then
					#Left overlap
					echo "        Left"
					PENDING_RANGES[$I]="$RANGE_START $((SRC_START-RANGE_START))"
					PENDING_RANGES[$I]+=" $DEST_START $((RANGE_LEN-(SRC_START-RANGE_START)))"
				else
					#Subsumption
					echo "        Subsumed"
					PENDING_RANGES[$I]="$((RANGE_START+DEST_START-SRC_START)) $RANGE_LEN"
				fi
			elif [[ $RANGE_START -le $SRC_END && \
				$RANGE_START -ge $SRC_START ]]; then
				#Right overlap
				echo "        Right"
				PENDING_RANGES[$I]="$((RANGE_START+DEST_START-SRC_START)) $((RANGE_LEN-(RANGE_END-SRC_END)))"
				PENDING_RANGES[$I]+=" $((SRC_END+1)) $((RANGE_END-SRC_END))"
			elif [[ $RANGE_START -lt $SRC_START && \
				$RANGE_END -gt $SRC_END ]]; then
				#Supersumption
				echo "        Super"
				PENDING_RANGES[$I]="$RANGE_START $((SRC_START-RANGE_START))"
				PENDING_RANGES[$I]+=" $DEST_START $LEN"
				PENDING_RANGES[$I]+=" $((SRC_END+1)) $((RANGE_END-SRC_END))"
			else
				echo "        no overlap"
				# if [[ $RANGE_END -lt $SRC_START || $RANGE_START -gt $SRC_END ]]; then
				#no overlap
				:
			fi
			echo -n "    "
			declare -p PENDING_RANGES
		done
	elif [[ "$LINE" == "" ]]; then
		PENDING_RANGES_DUMP="${PENDING_RANGES[*]}"
		RANGES=()
		PENDING_RANGES=()
		while read -d ' ' START; do
			read -d ' ' LEN
			RANGES+=("$START $LEN")
			PENDING_RANGES+=("$START $LEN")
		done <<<"${PENDING_RANGES_DUMP}"
		echo
		declare -p RANGES
	fi
done <<<"$INPUT_DATA"
declare -a STARTS
while read -d ' ' START; do
	read -d ' ' LEN
	STARTS+=($START)
done <<<"${RANGES[*]}"
min ${STARTS[@]}
echo $RESULT
