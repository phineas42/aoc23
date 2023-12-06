#!/usr/bin/bash

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

declare -a RESULT

die() {
	echo "$1"
	exit 1
}

find_index() {
	local PATTERN STRING BEGIN SUBSTRING I
	PATTERN=$1
	STRING=$2
	BEGIN=$3
	BEGIN=${BEGIN:-0}
	for (( I=$BEGIN; I<${#STRING}; I++ )); do
		SUBSTRING=${STRING:$I}
		if [[ "$SUBSTRING" =~ ^$PATTERN ]]; then
			RESULT=($I "${BASH_REMATCH[0]}")
			return
		fi
	done	
	RESULT=(-1 "")
}

# Locate symbols
declare -a SYMBOLS
LINE_NUMBER=0
while read LINE; do
	INDEX=0
	BEGIN=0
	while [[ "$INDEX" != -1 ]]; do
		find_index "[^\.[:digit:]]" "$LINE" $BEGIN
		INDEX=${RESULT[0]}
		MATCH_STRING=${RESULT[1]}
		BEGIN=$((INDEX+${#MATCH_STRING}))
		if [[ "$INDEX" != -1 ]]; then
			SYMBOLS+=("$MATCH_STRING $INDEX $LINE_NUMBER")
		fi
	done
	LINE_NUMBER=$((LINE_NUMBER+1))
done <<<"$INPUT_DATA"

# Locate Numbers
LINE_NUMBER=0
while read LINE; do
	INDEX=0
	BEGIN=0
	while [[ "$INDEX" != -1 ]]; do
		find_index "[[:digit:]]+" "$LINE" $BEGIN
		INDEX=${RESULT[0]}
		MATCH_STRING=${RESULT[1]}
		BEGIN=$((INDEX+${#MATCH_STRING}))
		if [[ "$INDEX" != -1 ]]; then
			#Classify number
			for SYMBOL_ENTRY in "${SYMBOLS[@]}"; do
				read SYMBOL SYMBOL_X SYMBOL_Y <<<"$SYMBOL_ENTRY"
				if [[ "$SYMBOL_X" -ge $((INDEX-1)) && \
				      "$SYMBOL_X" -le $BEGIN && \
				      "$SYMBOL_Y" -ge $((LINE_NUMBER-1)) && \
				      "$SYMBOL_Y" -le $((LINE_NUMBER+1)) ]]; then
					#Found a part number
					ACCUMULATOR=$((ACCUMULATOR+MATCH_STRING))
					continue
				fi
			done
		fi
	done
	LINE_NUMBER=$((LINE_NUMBER+1))
done <<<"$INPUT_DATA"
echo "$ACCUMULATOR"
