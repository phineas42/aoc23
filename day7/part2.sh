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

declare -A CARD_RANKS=(
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
	declare -a BINS
	for ((I=0;I<5; I++)); do
		CARD=${HAND:$I:1}
		VALUE=${CARD_RANKS[$CARD]}
		COUNT=${COUNTS[$VALUE]} || COUNT=0
		COUNTS[$VALUE]=$((COUNT+1))
	done
	for VALUE in ${!COUNTS[@]}; do
		if [[ "$VALUE" != ${CARD_RANKS[J]} ]]; then
			COUNT=${COUNTS[$VALUE]}
			BINS+=("$COUNT $VALUE")
		fi
	done

	quicksort BINS compare_bins

	JOKER_COUNT=${COUNTS[${CARD_RANKS[J]}]:-0}
	if [[ "$JOKER_COUNT" -eq 5 ]]; then
		RESULT="8$HAND"
		# echo "$HAND: $RESULT 5 of a kind "
		return
	fi

	ORDER1=(${BINS[0]})
	ORDER2=(${BINS[1]})
	COUNT1=${ORDER1[0]}
	VALUE1=${ORDER1[1]}
	COUNT2=${ORDER2[0]}
	VALUE2=${ORDER2[1]}
	if [[ "$COUNT1" -eq 5 ]]; then
		RESULT="8$HAND"
		# echo "$HAND: $RESULT 5 of a kind"
		return
	elif [[ "$COUNT1" -eq 4 ]]; then
		RESULT="$((7+JOKER_COUNT))$HAND"
		# echo "$HAND: $RESULT $((4+JOKER_COUNT)) of a kind"
		return
	elif [[ "$COUNT1" -eq 3 ]]; then
		if [[ "$JOKER_COUNT" -gt 0 ]]; then
			RESULT="$((6+JOKER_COUNT))$HAND"
			# echo "$HAND: $RESULT $((3+JOKER_COUNT)) of a kind"
			return
		elif [[ "$COUNT2" -eq 2 ]]; then
			RESULT="6$HAND"
			# echo "$HAND: $RESULT Full house"
			return
		else
			RESULT="5$HAND"
			# echo "$HAND: $RESULT Three of a kind"
			return
		fi
	elif [[ "$COUNT1" -eq 2 ]]; then
		if [[ "$JOKER_COUNT" -gt 1 ]]; then
			RESULT="$((5+JOKER_COUNT))$HAND"
			# echo "$HAND: $RESULT $((2+JOKER_COUNT)) of a kind"
			return
		elif [[ "$JOKER_COUNT" -eq 1 ]]; then
			if [[ "$COUNT2" -eq 2 ]]; then
				RESULT="6$HAND"
				# echo "$HAND: $RESULT full house"
				return
			else
				RESULT="5$HAND"
				# echo "$HAND: $RESULT Three of a kind"
				return
			fi
		elif [[ "$COUNT2" -eq 2 ]]; then
			RESULT="4$HAND"
			# echo "$HAND: $RESULT Two pair"
			return
		else
			RESULT="3$HAND"
			# echo "$HAND: $RESULT One pair"
			return
		fi
	else
		if [[ "$JOKER_COUNT" -gt 2 ]]; then
			RESULT="$((4+JOKER_COUNT))$HAND"
			# echo "$HAND: $RESULT $((1+JOKER_COUNT)) of a kind"
			return
		elif [[ "$JOKER_COUNT" -eq 2 ]]; then
			RESULT="5$HAND"
			# echo "$HAND: $RESULT Three of a kind"
			return
		elif [[ "$JOKER_COUNT" -eq 1 ]]; then
			RESULT="3$HAND"
			# echo "$HAND: $RESULT One pair"
			return
		else
			RESULT="2$HAND"
			# echo "$HAND: $RESULT High card"
			return
		fi
	fi
}

compare_bins() {
	local COUNT1=${1% *} COUNT2=${2% *}
	RESULT=$((COUNT1-COUNT2))
}

compare_hands() {
	local HAND1=$1 HAND2=$2 RATE1 RATE2 CARD1 CARD2 VALUE1 VALUE2 I
	for ((I=0;I<6; I++)); do
		CARD1=${HAND1:$I:1}
		VALUE1=${CARD_RANKS[$CARD1]}
		CARD2=${HAND2:$I:1}
		VALUE2=${CARD_RANKS[$CARD2]}
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
