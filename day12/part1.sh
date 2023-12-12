#!/usr/bin/bash
. ../aoc23.sh

apply_groups() {
	local pattern=$1
	declare -a groups=($2)
	local index=0
	local group=${groups[0]}
	#local indent=${3:-}
	local count_solutions=0
	local remain skipped subpattern recursepattern
	#echo "${indent}pattern: \"$pattern\" groups:$2"
	sum_array groups 1
	# minimum number of character that must remain in pattern after this group?
	remain=$((_result + ${#groups[@]} - 1))
	#echo -n "${indent}"; declare -p remain
	while [[ $((index + group)) -lt $((1 + ${#pattern} - remain)) ]]; do
		skipped=${pattern:0:$index}
		if [[ "$skipped" =~ \# ]]; then
			# you can't skip over any "#"
			break
		fi
		subpattern=${pattern:$index:$((group+1))}
		#printf "${indent}%02d \"%s\"\n" $index $subpattern
		if [[ "$subpattern" =~ ^[\?\#]{$group}[\?\.]?$ ]]; then
			#echo "${indent}match"
			recursepattern=${pattern:$((index+group+1))}
			if [[ ${#groups[@]} -eq 1 ]]; then
				#echo "${indent}last group"
				if [[ "$recursepattern" =~ ^[\?\.]*$ ]]; then
					count_solutions=$((count_solutions + 1))
				fi
			else
				#echo "${indent}time to recurse"
				apply_groups "$recursepattern" "${groups[*]:1}" # "  $indent"
				count_solutions=$((count_solutions + _result))
			fi
		fi
		index=$((index + 1))
	done
	_result=$count_solutions
	#echo "${indent}=$_result"
}

accumulator=0
while read pattern groups_str; do
	#echo $pattern $groups_str
	IFS=,
	groups=($groups_str)
	unset IFS
	apply_groups "$pattern" "${groups[*]}"
	accumulator=$((accumulator + _result))
done <<<"$input_data"
echo $accumulator
