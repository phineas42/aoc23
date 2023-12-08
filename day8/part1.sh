#!/usr/bin/bash
set -e

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

declare -a INSTRUCTIONS
declare -A NODES
{
	read INSTRUCTIONS_STR
	for ((I=0;I<${#INSTRUCTIONS_STR};I++)); do
		INSTRUCTIONS+=(${INSTRUCTIONS_STR:$I:1})
	done
	read
	while read LINE; do
		[[ "$LINE" =~ (...)\ =\ \((...),\ (...)\) ]]
		NODES[${BASH_REMATCH[1]}]=${BASH_REMATCH[@]:2}
	done
} <<<"$INPUT_DATA"
declare -p INSTRUCTIONS
declare -p NODES

CURRENT_NODE=AAA
COUNT=0
TARGET_NODE=ZZZ
set -x
while [[ "$CURRENT_NODE" != "$TARGET_NODE" ]]; do
	echo $CURRENT_NODE
	NEXTS=(${NODES[$CURRENT_NODE]})
	INSTRUCTION_INDEX=$((COUNT % ${#INSTRUCTIONS[@]}))
	INSTRUCTION=${INSTRUCTIONS[$INSTRUCTION_INDEX]}
	case $INSTRUCTION in
		L)
			CURRENT_NODE=${NEXTS[0]}
			;;
		*)
			CURRENT_NODE=${NEXTS[1]}
			;;
	esac
	COUNT=$((COUNT+1))
done
echo $COUNT
