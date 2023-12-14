rev() {
	unset _result
	declare -g _result=""
	local str=$1
	local i
	for ((i=${#str}-1; i>=0; i--)); do
		_result+=${str:$i:1}
	done
}
