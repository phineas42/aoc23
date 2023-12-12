# Search condition to find an integer in a sorted array
searchcondition_equals() {
	unset _result
	declare -g _result
        # Template variables
        local search_target=$1; shift
        # Search Condition variables
        local array_name=$1 test_index=$2
        declare -n array=$array_name
        # look for number
	_result=$((${array[test_index]} - ${search_target}))
}


binarysearch_array() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name; shift
	local search_condition=$@
	local old_pivot pivot
	local min_index=0 max_index=${#array[@]}
	while [[ "$min_index" -lt "$max_index" ]]; do
		local old_pivot=${pivot:-}
		local pivot=$((min_index + (max_index - min_index)/2))
		if [[ "$old_pivot" == "$pivot" ]]; then
			break
		fi
		${search_condition} $array_name $pivot
		if [[ "$_result" -eq 0 ]]; then
			_result=$pivot
			return 0
		elif [[ "$_result" -gt 0 ]]; then
			max_index=$pivot
		else
			min_index=$((pivot + 1))
		fi
	done
	_result=-1
	return -1
}
