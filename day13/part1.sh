#!/usr/bin/bash
. ../aoc23.sh

process_data() {
	declare -g -a data
	local possible_vreflections="" possible_hreflections="" line vmpos num_left num_right start_index_left length left right hmpos
	for ((line_number=0; line_number<${#data[@]}; line_number++)); do
		line=${data[line_number]}

		# Check for horizontal reflection on this line
		if [[ $line_number -eq 0 ]]; then
			for ((vmpos=1; vmpos<${#line}; vmpos++)); do
				possible_vreflections+=" $vmpos"
			done
		fi
		new_possible_vreflections=""
		for vmpos in $possible_vreflections; do
			num_left=$vmpos
			num_right=$((${#line} - vmpos))
			if [[ $num_left -le $num_right ]]; then
				start_index_left=0
				length=$num_left
			else
				start_index_left=$((vmpos - num_right))
				length=$num_right
			fi
			left=${line:$start_index_left:$length}
			right=${line:$vmpos:$length}
			rev $right
			if [[ "$left" == "$_result" ]]; then
				new_possible_vreflections+=" $vmpos"
			fi
		done
		possible_vreflections=$new_possible_vreflections
	done
	# Check for possible hreflections
	for ((hmpos=1; hmpos<${#data[@]}; hmpos++)); do
		num_above=$hmpos
		num_below=$((${#data[@]} - hmpos))
		if [[ $num_above -le $num_below ]]; then
			start_index_above=0
			length=$num_above
		else
			start_index_above=$((hmpos - num_below))
			length=$num_below
		fi
		reflects=true
		for ((i=$start_index_above,j=$((hmpos + length - 1)); i<hmpos; i++,j--)); do
			line_above=${data[i]}
			line_below=${data[j]}
			if [[ $line_above != $line_below ]]; then
				reflects=false
				break
			fi
		done
		if [[ "$reflects" == "true" ]]; then
			possible_hreflections+=" $hmpos"
		fi
	done
	_result=$((100*possible_hreflections + possible_vreflections))
}

declare -g -a data=()
accumulator=0
while read line; do
	if [[ -z "$line" ]]; then
		process_data
		accumulator=$((accumulator + _result))
		data=()
	else
		data+=("$line")
	fi
done <<<"$input_data"$'\n'
echo $accumulator
