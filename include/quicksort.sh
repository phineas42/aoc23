default_comp() {
	unset _result
	declare -g _result
	local arg_L=$1
	local arg_R=$2
	local i diff
	for ((i=0; i<${#arg_L} && i<${#arg_R}; i++)); do
		diff=$((arg_R - arg_L))
		if [[ "$diff" != 0 ]]; then
			_result=$diff
			return 0
		fi
	done
	# if the arguments are equal up to the end of the shorter one, use length.
	_result=$((${#arg_R} - ${#arg_L}))
}

quicksort_array() {
	local array_name=$1
	declare -n array=$array_name
	declare comp_func=${2:-default_comp}
	local start_index=${3:-0}
	# end_index is exclusive, not inclusive of the index itself
	local end_index=${4:-${#array[@]}}
	local len=$((end_index - start_index))
	local elem_L elem_R index_L index_R index_target pivot len_L
	declare -a copy_L

	if [[ $len -lt 2 ]]; then
		return
	elif [[ $len -eq 2 ]]; then
		index_L=$start_index
		index_R=$((index_L + 1))
		elem_L=${array[index_L]}
		elem_R=${array[index_R]}
		$comp_func "$elem_L" "$elem_R"
		if [[ "$_result" -lt 0 ]]; then
			array[index_L]=$elem_R
			array[index_R]=$elem_L
		fi
		return
	fi
	pivot=$((start_index + (end_index - start_index)/2))
	len_L=$((pivot - start_index))
	quicksort_array "$array_name" "$comp_func" "$start_index" "$pivot"
	quicksort_array "$array_name" "$comp_func" "$pivot" "$end_index"
	copy_L=("${array[@]:${start_index}:${len_L}}")
	index_L=0
	index_R=$pivot
	while [[ "$index_L" -lt "$len_L" || "$index_R" -lt "$end_index" ]]; do
		index_target=$((start_index + index_L + index_R - pivot))
		if [[ "$index_L" -ge "$len_L" ]]; then
			_result=-1
		elif [[ "$index_R" -ge "$end_index" ]]; then
			_result=1
		else
			$comp_func "${copy_L[index_L]}" "${array[index_R]}"
		fi

		if [[ "$_result" -gt 0 ]]; then
			array[index_target]=${copy_L[index_L]}
			index_L=$((index_L + 1))
		else
			array[index_target]=${array[index_R]}
			index_R=$((index_R + 1))
		fi
	done
}
