#!/usr/bin/bash

set -e

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

declare -A CARD_VALUES=(
	[A]=14
	[K]=13
	[Q]=12
	[J]=11
	[T]=10
	["9"]=9
	["8"]=8
	["7"]=7
	["6"]=6
	["5"]=5
	["4"]=4
	["3"]=3
	["2"]=2
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
	for COUNT in ${COUNTS[@]}; do
		if [[ "$COUNT" == 5 ]]; then
			# 5 of a kind
			RESULT="8$HAND"
			return
		elif [[ "$COUNT" == 4 ]]; then
			# 4 of a kind
			RESULT="7$HAND"
			return
		elif [[ "$COUNT" == 3 ]]; then
			if [[ "$SEEN2" == 1 ]]; then
				# Full House A
				RESULT="6$HAND"
				return
			fi
			SEEN3=1
		elif [[ "$COUNT" == 2 ]]; then
			if [[ "$SEEN3" == 1 ]]; then
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
		# One pair
		RESULT="3$HAND"
	else
		# High card
		RESULT="2$HAND"
	fi
}

compare_hands() {
	local HAND1=$1 HAND2=$2 RATE1 RATE2 CARD1 CARD2 VALUE1 VALUE2 I
	HAND1=$1
	HAND2=$2
	for ((I=0;I<6; I++)); do
		CARD1=${HAND1:$I:1}
		VALUE1=${CARD_VALUES[$CARD1]}
		CARD2=${HAND2:$I:1}
		VALUE2=${CARD_VALUES[$CARD2]}
		if [[ "$VALUE1" -gt "$VALUE2" ]]; then
			RESULT=-1
			#echo "$HAND2 < $HAND1"
			return
		elif [[ "$VALUE1" -lt "$VALUE2" ]]; then
			RESULT=1
			#echo "$HAND1 < $HAND2"
			return
		fi
	done
	RESULT=0
}

sort_ratedhands_bids() {
	local J I HAND1 HAND2
	# This is a very inefficient sorting algorithm
	for ((J=0; J<${#RATEDHANDS_BIDS[@]}; J++)); do
		for ((I=0; I<${#RATEDHANDS_BIDS[@]}-1; I++)); do
			HAND1=${RATEDHANDS_BIDS[$I]}
			HAND2=${RATEDHANDS_BIDS[$((I+1))]}
			compare_hands "$HAND1" "$HAND2"
			if [[ "$RESULT" == -1 ]]; then
				RATEDHANDS_BIDS[$I]=$HAND2
				RATEDHANDS_BIDS[$((I+1))]=$HAND1
			fi
		done
	done
}

declare -a RATEDHANDS_BIDS
while IFS= read HAND; do
	rate_hand "$HAND"
	RATEDHANDS_BIDS+=("${RESULT}")
done <<<"$INPUT_DATA"

sort_ratedhands_bids

ACCUMULATOR=0
for ((I=0;I<${#RATEDHANDS_BIDS[@]}; I++)); do
	HAND=${RATEDHANDS_BIDS[$I]}
	BID=${HAND#* }
	ACCUMULATOR=$((ACCUMULATOR+BID*(I+1)))
done
echo $ACCUMULATOR
