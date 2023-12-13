sum_array() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name
	local skip=${2:-0}
	local len=${3:-}
	_result=0
	local addend
	if [[ -n "$len" ]]; then
		for addend in ${array[@]:$skip:$len}; do
			_result=$((_result + addend))
		done
	else
		for addend in ${array[@]:$skip}; do
			_result=$((_result + addend))
		done
	fi
}
