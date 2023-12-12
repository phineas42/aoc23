prime_factorize() {
	unset _result
	declare -g -a _result
	local num=$1
	local i
	for ((i=2; i<$((num / 2)); )); do
		if [[ $((num % i)) -eq 0 ]]; then
			_result[i]=$((${_result[i]:-0} + 1))
			num=$((num / i))
		else
			i=$((i + 1))
		fi
	done
	_result[num]=$((${result[num]:-0} + 1))
}
