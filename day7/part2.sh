#!/usr/bin/bash

set -e

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

quicksort() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	declare COMP_FUNC=$2
	local START_INDEX=${3:-0}
	# END_INDEX is exclusive, not inclusive of the index itself
	local END_INDEX=${4:-${#ARRAY[@]}}
	local LEN=$((END_INDEX-START_INDEX))
	local L R LINDEX RINDEX TINDEX PIVOT LEFTLEN
	declare -a LEFTCOPY

	if [[ $LEN -lt 2 ]]; then
		return
	elif [[ $LEN -eq 2 ]]; then
		LINDEX=$START_INDEX
		RINDEX=$((LINDEX+1))
		L=${ARRAY[$LINDEX]}
		R=${ARRAY[$RINDEX]}
		$COMP_FUNC "$L" "$R"
		if [[ "$RESULT" -lt 0 ]]; then
			ARRAY[$LINDEX]=$R
			ARRAY[$RINDEX]=$L
		fi
		return
	fi
	PIVOT=$((START_INDEX+(END_INDEX-START_INDEX)/2))
	LEFTLEN=$((PIVOT-START_INDEX))
	quicksort "$ARRAY_NAME" "$COMP_FUNC" "$START_INDEX" "$PIVOT"
	quicksort "$ARRAY_NAME" "$COMP_FUNC" "$PIVOT" "$END_INDEX"
	LEFTCOPY=("${ARRAY[@]:${START_INDEX}:${LEFTLEN}}")
	LINDEX=0
	RINDEX=$PIVOT
	while [[ "$LINDEX" -lt "$LEFTLEN" || "$RINDEX" -lt "$END_INDEX" ]]; do
		TINDEX=$((START_INDEX+LINDEX+RINDEX-PIVOT))
		if [[ "$LINDEX" -ge "$LEFTLEN" ]]; then
			RESULT=-1
		elif [[ "$RINDEX" -ge "$END_INDEX" ]]; then
			RESULT=1
		else
			$COMP_FUNC "${LEFTCOPY[$LINDEX]}" "${ARRAY[$RINDEX]}"
		fi

		if [[ "$RESULT" -gt 0 ]]; then
			ARRAY[$TINDEX]=${LEFTCOPY[$LINDEX]}
			LINDEX=$((LINDEX+1))
		else
			ARRAY[$TINDEX]=${ARRAY[$RINDEX]}
			RINDEX=$((RINDEX+1))
		fi
	done
}

comp() {
	local LEFT=$1 RIGHT=$2
	RESULT=$((RIGHT-LEFT))
}

declare -A CARD_VALUES=(
	[A]=14
	[K]=13
	[Q]=12
	[T]=10
	["9"]=9
	["8"]=8
	["7"]=7
	["6"]=6
	["5"]=5
	["4"]=4
	["3"]=3
	["2"]=2
	[J]=1
)


rate_hand() {
	local HAND=$1 CARD VALUE COUNT SEEN3 SEEN2 I
	unset COUNTS
	declare -a COUNTS
	for ((I=0;I<5; I++)); do
		CARD=${HAND:$I:1}
		VALUE=${CARD_VALUES[$CARD]}
		COUNT=${COUNTS[$VALUE]} || COUNT=0
		COUNTS[$VALUE]=$((COUNT+1))
	done

	SEEN3=0
	SEEN2=0
	for VALUE in ${!COUNTS[@]}; do
		COUNT=${COUNTS[$VALUE]}
		if [[ "$COUNT" == 5 ]]; then
			# 5 of a kind
			RESULT="8$HAND"
			return
		elif [[ "$VALUE" == 1 ]]; then
			# Don't base a hand on Jokers
			continue
		elif [[ "$COUNT" == 4 ]]; then
			# 4 of a kind
			if [[ "${COUNTS[1]}" -gt 0 ]]; then
				# 5 of a kind (J)
				RESULT="8$HAND"
				return
			else
				RESULT="7$HAND"
				return
			fi
			return
		elif [[ "$COUNT" == 3 ]]; then
			if [[ "${COUNTS[1]}" -gt 1 ]]; then
				# 5 of a kind (JJ)
				RESULT="8$HAND"
				return
			elif [[ "${COUNTS[1]}" -gt 0 ]]; then
				# 4 of a kind (J)
				RESULT="7$HAND"
				return
			elif [[ "$SEEN2" == 1 ]]; then
				# Full House A
				RESULT="6$HAND"
				return
			fi
			SEEN3=1
		elif [[ "$COUNT" == 2 ]]; then
			if [[ "${COUNTS[1]}" -gt 2 ]]; then
				# 5 of a kind (JJJ)
				RESULT="8$HAND"
				return
			elif [[ "${COUNTS[1]}" -gt 1 ]]; then
				# 4 of a kind (JJ)
				RESULT="7$HAND"
				return
			elif [[ "${COUNTS[0]}" -gt 0 ]]; then
				if [[ "$SEEN2" == 1 ]]; then
					# Full House (J)
					RESULT="6$HAND"
					return
				fi
			elif [[ "$SEEN3" == 1 ]]; then
				# Full House B
				RESULT="6$HAND"
				return
			elif [[ "$SEEN2" == 1 ]]; then
				# Two Pair
				RESULT="4$HAND"
				return
			fi
			SEEN2=1
		fi
	done
	if [[ "$SEEN3" == 1 ]]; then
		# Three of a Kind
		RESULT="5$HAND"
	elif [[ "$SEEN2" == 1 ]]; then
		if [[ "${COUNTS[1]}" -gt 0 ]]; then
			# 3 of a kind (J)
			RESULT="5$HAND"
		else
			# One pair
			RESULT="3$HAND"
		fi
	else
		if [[ "${COUNTS[1]}" == 4 ]]; then
			# 5 of a kind (JJJJ)
			RESULT="8$HAND"
		elif [[ "${COUNTS[1]}" == 3 ]]; then
			# 4 of a kind (JJJ)
			RESULT="7$HAND"
		elif [[ "${COUNTS[1]}" == 2 ]]; then
			# 3 of a kind (JJ)
			RESULT="5$HAND"
		elif [[ "${COUNTS[1]}" == 1 ]]; then
			# One pair (J)
			RESULT="3$HAND"
		else
			# High card
			RESULT="2$HAND"
		fi
	fi
	set +x
}

compare_hands() {
	local HAND1=$1 HAND2=$2 RATE1 RATE2 CARD1 CARD2 VALUE1 VALUE2 I
	for ((I=0;I<6; I++)); do
		CARD1=${HAND1:$I:1}
		VALUE1=${CARD_VALUES[$CARD1]}
		CARD2=${HAND2:$I:1}
		VALUE2=${CARD_VALUES[$CARD2]}
		RESULT=$((VALUE2-VALUE1))
		if [[ "$RESULT" != 0 ]]; then
			return
		fi
	done
	RESULT=0
}
declare -a RATEDHANDS_BIDS
while IFS= read HAND; do
	rate_hand "$HAND"
	RATEDHANDS_BIDS+=("${RESULT}")
done <<<"$INPUT_DATA"
quicksort RATEDHANDS_BIDS compare_hands
ACCUMULATOR=0
for ((I=0;I<${#RATEDHANDS_BIDS[@]}; I++)); do
	HAND=${RATEDHANDS_BIDS[$I]}
	BID=${HAND#* }
	ACCUMULATOR=$((ACCUMULATOR+BID*(I+1)))
done
echo $ACCUMULATOR
