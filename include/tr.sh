tr() {
	unset _result
	declare -g _result=""
	local str=$1
	local in_chars=$2
	local out_chars=$3
	local i j char
	for ((i=0; i<${#str}; i++)); do
		char="${str:$i:1}"
		for ((j=0; j<${#in_chars}; j++)); do
			if [[ "$char" == "${in_chars:$j:1}" ]]; then
				char="${out_chars:$j:1}"
				break
			fi
		done
		_result+="$char"
	done
}
