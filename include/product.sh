product_array() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name
	local skip=${2:-0}
	local len=${3:-}
	_result=1
	local multiplicand
	if [[ -n "$len" ]]; then
		for multiplicand in ${array[@]:$skip:$len}; do
			_result=$((_result * multiplicand))
		done
	else
		for multiplicand in ${array[@]:$skip}; do
			_result=$((_result * multiplicand))
		done
	fi
}
