#!/usr/bin/bash
. ../aoc23.sh

declare -A cache

apply_groups() {
	local pattern=$1
	declare -a groups=($2)
	local index=0
	local group=${groups[0]}
	local skip=${3:-0}
	local count_solutions=0
	local remain skipped subpattern recursepattern
	#echo "${indent}pattern: \"$pattern\" groups:$2"
	local cache_key="$*"
	local cache_value=${cache[$cache_key]:-}
	if [[ -n "$cache_value" ]]; then
		_result=$cache_value
		return
	fi

	if [[ "${#groups[@]}" -gt 0 ]]; then
		sum_array groups 1
		# minimum number of character that must remain in pattern after this group?
		remain=$((_result + ${#groups[@]} - 1))
	else
		remain=0
	fi
	#echo -n "${indent}"; declare -p remain

	while [[ $((index + group)) -le $((${#pattern} - remain)) ]]; do
		skipped=${pattern:0:$index}
		if [[ "$skipped" =~ \# ]]; then
			# you can't skip over any "#"
			break
		fi
		subpattern=${pattern:$index:$((group+1))}
		#for ((i=0;i<skip;i++)); do
		#	echo -n " "
		#done
		#echo $pattern $index $((group+1))
		#for ((i=0;i<index+skip;i++)); do
		#	echo -n " "
		#done
		#echo $subpattern
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
				apply_groups "$recursepattern" "${groups[*]:1}" $((index + skip + ${#subpattern}))
				count_solutions=$((count_solutions + _result))
			fi
		fi
		index=$((index + 1))
	done
	_result=$count_solutions
	cache[$cache_key]=$_result
	#echo "${indent}=$_result"
}

accumulator=0
index=0
while read pattern groups_str; do
	echo "$pattern $groups_str (index $index)"
	results=()
	factors=()
	this_pattern="$pattern"
	this_groups_str="$groups_str"
	IFS=,
	this_groups=($this_groups_str)
	unset IFS
	apply_groups "$this_pattern" "${this_groups[*]}"
	if [[ "$_result" -eq 0 ]]; then
		continue
	fi
	results+=($_result)
	factors+=($_result)
	last_result=$_result
	last_factor=$_result
	for ((i=1; i<5; i++)); do
		this_pattern="$this_pattern?$pattern"
		this_groups_str="$this_groups_str,$groups_str"
		IFS=,
		groups=($this_groups_str)
		unset IFS
		apply_groups "$this_pattern" "${groups[*]}"
		results+=($_result)
		last_result=$_result
	done
	declare -p results
	accumulator=$((accumulator+_result))
	index=$((index+1))
done <<<"$input_data"
echo $accumulator
