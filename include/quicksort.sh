default_comp() {
	unset RESULT
	declare -g RESULT
	local L=$1
	local R=$2
	local I DIFF
	for ((I=0;I<${#L}&&I<${#R};I++)); do
		DIFF=$((R-L))
		if [[ "$DIFF" != 0 ]]; then
			RESULT=$DIFF
			return 0
		fi
	done
	RESULT=$((${#R}-${#L}))
}

quicksort_array() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	declare COMP_FUNC=${2:-default_comp}
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
	quicksort_array "$ARRAY_NAME" "$COMP_FUNC" "$START_INDEX" "$PIVOT"
	quicksort_array "$ARRAY_NAME" "$COMP_FUNC" "$PIVOT" "$END_INDEX"
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
