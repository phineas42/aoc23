sum_array() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name
	local skip=${2:-0}
	_result=0
	local addend
	for addend in ${array[@]:$skip}; do
		_result=$((_result + addend))
	done
}
