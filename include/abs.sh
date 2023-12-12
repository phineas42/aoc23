abs() {
	unset _result
	declare -g _result
	if [[ "$1" -lt 0 ]]; then
		_result=$((-$1))
	else
		_result=$1
	fi
}
