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

STARTING_NODES=()
for NODE in ${!NODES[@]}; do
	if [[ "$NODE" =~ ..A ]]; then
		STARTING_NODES+=($NODE)
	fi
done

# determine solution pattern for each starting node individually
declare -a SOLUTIONS
for NODE in ${STARTING_NODES[@]}; do
	COUNT=0
	CURRENT_NODE=${NODE}
	while [[ "$CURRENT_NODE" =~ [^Z]$ ]]; do
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
	SOLUTIONS+=($COUNT)
done

lcm() {
        local ARRAY_NAME=$1
        declare -n ARRAY=$ARRAY_NAME
	local L R ML MR
	RESULT=${ARRAY[0]}
	for ((I=1;I<${#ARRAY[@]};I++)); do
		L=$RESULT
		R=${ARRAY[$I]}
		ML=$L
		MR=$R
		while [[ "$ML" -ne "$MR" ]]; do
			if [[ "$ML" -gt "$MR" ]]; then
				if [[ $(( (ML-MR) % R )) == 0 ]]; then
					MR=$ML
				else
					INCR=$((((ML-MR) / R)+1))
					MR=$((MR+R*INCR))
				fi
			else
				if [[ $(( (MR-ML) % L )) == 0 ]]; then
					ML=$MR
				else
					INCL=$((((MR-ML) / L)+1))
					ML=$((ML+L*INCL))
				fi
			fi
		done
		RESULT=$ML
	done
}
lcm "SOLUTIONS"
echo $RESULT
