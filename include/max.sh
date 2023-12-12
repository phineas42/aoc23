max() {
        unset _result
        declare -g _result
        local num
	_result=$1; shift
        for num in $@; do
                if [[ $num -gt $_result ]]; then
                        _result=$num
                fi
        done
}

max_array() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name
	local num
	_result=${array[0]}
	for num in ${array[@]:1}; do
		if [[ $num -gt $_result ]]; then
			_result=$num
		fi
	done
}
