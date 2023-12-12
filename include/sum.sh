sum_array() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name
	_result=0
	local addend
	for addend in ${array[@]}; do
		_result=$((_result + addend))
	done
}
