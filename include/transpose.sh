transpose_array() {
	unset _result
	declare -g -a _result=()
	local array_name=$1
	declare -n array=$array_name
	local original_height=${#array[@]}
	local original_width=${#array[0]}
	local row col char
	for ((row=0; row < original_height; row++)); do
		for ((col=0; col < original_width; col++)); do
			_result[col]+=${array[row]:$col:1}
		done
	done
}
