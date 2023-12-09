#!/usr/bin/bash
set -e

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

. ../include/max.sh
. ../include/sum.sh
declare -a DERIVATIVES
ACCUMULATOR=0
while read HISTORY; do
	HISTORY_ARRAY=($HISTORY)
	DERIVATIVES=("$HISTORY")
	DEPTH=0
	sum_array HISTORY_ARRAY
	while [[ "$RESULT" != 0 ]]; do
		DEPTH=$((DEPTH+1))
		DELTAS_UP=(${DERIVATIVES[$((DEPTH-1))]})
		DELTAS=()
		for ((I=1;I<${#DELTAS_UP[@]};I++)); do
			DELTAS+=($((${DELTAS_UP[$I]}-${DELTAS_UP[$I-1]})))
		done
		DERIVATIVES+=("${DELTAS[*]}")
		sum_array DELTAS
	done

	while [[ "$DEPTH" -gt 0 ]]; do
		DELTAS=(${DERIVATIVES[$DEPTH]})
		DELTAS_UP=(${DERIVATIVES[$((DEPTH-1))]})
		DELTAS_UP=($((${DELTAS_UP[0]}-${DELTAS[0]})) ${DELTAS_UP[@]})
		DERIVATIVES[$((DEPTH-1))]="${DELTAS_UP[*]}"
		DEPTH=$((DEPTH-1))
	done
	NEW_HISTORY_ARRAY=(${DERIVATIVES[0]})
	FIRST_VALUE=${NEW_HISTORY_ARRAY[0]}
	ACCUMULATOR=$((ACCUMULATOR+FIRST_VALUE))
done <<<"$INPUT_DATA"
echo $ACCUMULATOR
