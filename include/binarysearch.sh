# Search condition to find an integer in a sorted array
searchcondition_equals() {
        # Template variables
        local SEARCH_TARGET=$1; shift
        # Search Condition variables
        local ARRAY_NAME=$1
        local TEST_INDEX=$2
        declare -n ARRAY=$ARRAY_NAME
        # look for number
        RESULT=$((${ARRAY[$TEST_INDEX]}-${SEARCH_TARGET}))
}


binarysearch_array() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	shift
	local SEARCH_CONDITION=$@
	local OLD_PIVOT PIVOT
	local MIN_INDEX=0 MAX_INDEX=${#ARRAY[@]}
	while [[ "$MIN_INDEX" -lt "$MAX_INDEX" ]]; do
		local OLD_PIVOT=$PIVOT
		local PIVOT=$((MIN_INDEX+(MAX_INDEX-MIN_INDEX)/2))
		if [[ "$OLD_PIVOT" == "$PIVOT" ]]; then
			break
		fi
		${SEARCH_CONDITION} $ARRAY_NAME $PIVOT
		if [[ "$RESULT" -eq 0 ]]; then
			RESULT=$PIVOT
			return 0
		elif [[ "$RESULT" -gt 0 ]]; then
			MAX_INDEX=$PIVOT
		else
			MIN_INDEX=$((PIVOT+1))
		fi
	done
	RESULT=-1
	return -1
}
