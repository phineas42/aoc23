#!/usr/bin/bash
. ../aoc23.sh

process_data() {
	declare -g -a data
	set +e
	local section=$1
	local possible_vreflections="" possible_hreflections="" line length hmpos width height hammed reflects line_above line_below start_index_above
	(( width = ${#data[0]} ))
	(( height = ${#data[@]} ))

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
		hammed=false
		for ((i=$start_index_above,j=$((hmpos + length - 1)); i<hmpos; i++,j--)); do
			line_above=${data[i]}
			line_below=${data[j]}
			if [[ $line_above != $line_below ]]; then
				if [[ $hammed == true ]]; then
					reflects=false
					break
				else
					hamming_distance $line_above $line_below
					if [[ $_result == 1 ]]; then
						hammed=true
					else
						reflect=false
						break
					fi
				fi
			fi
		done
		if [[ "$reflects" == "true" && "$hammed" == "true" ]]; then
			let _result=100*hmpos
			return
		fi
	done
	
	transpose_array data
	data=(${_result[@]})

	# Check for possible hreflections on transposed data
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
		hammed=false
		for ((i=$start_index_above,j=$((hmpos + length - 1)); i<hmpos; i++,j--)); do
			line_above=${data[i]}
			line_below=${data[j]}
			if [[ $line_above != $line_below ]]; then
				if [[ $hammed == true ]]; then
					reflects=false
					break
				else
					hamming_distance $line_above $line_below
					if [[ $_result == 1 ]]; then
						hammed=true
					else
						reflect=false
						break
					fi
				fi
			fi
		done
		if [[ "$reflects" == "true" && "$hammed" == "true" ]]; then
			let _result=hmpos
			return
		fi
	done
}

declare -g -a data=()
accumulator=0
section=0
while read line; do
	if [[ -z "$line" ]]; then
		process_data $section
		accumulator=$((accumulator + _result))
		data=()
		section=$((section+1))
	else
		data+=("$line")
	fi
done <<<"$input_data"$'\n'
echo $accumulator
