hamming_distance() {
	unset _result
	declare -g _result=0
	local str_a=$1
	local str_b=$2
	local i
	for ((i=0; i<${#str_a}; i++)); do
		if [[ ${str_a:$i:1} != ${str_b:$i:1} ]]; then
			((++_result))
		fi
	done
}
