#!/usr/bin/bash
. ../aoc23.sh
declare -g -a data=()
while read line; do
	if [[ -n $line ]]; then
		data+=("$line")
	fi
done <<<"$input_data"$'\n'
num_rows=${#data[@]}
load=0
boulder_queue_depth=()
for ((i=num_rows-1; i>=0; i--)); do
	row=${data[i]}
	distance=$((num_rows - i))
	for ((col=0; col<${#row}; col++)); do
		char=${row:$col:1}
		case $char in
			'#')
				# bank the current values
				#
				last_distance=$((distance - 1))
				first_distance=$((distance - boulder_queue_depth[col]))
				add_load=$(((last_distance+first_distance)*boulder_queue_depth[col]/2))
				load=$((load + add_load))
				boulder_queue_depth[col]=0
				;;
			'O')
				# increment weight
				#
				boulder_queue_depth[col]=$(( boulder_queue_depth[col] + 1))
				;;
			'.')
				:
				;;
		esac
	done
done
distance=$((num_rows+1))
for ((col=0; col<${#row}; col++)); do
	last_distance=$((distance - 1))
	first_distance=$((distance - boulder_queue_depth[col]))
	add_load=$(((last_distance+first_distance)*boulder_queue_depth[col]/2))
	load=$((load + add_load))
done
echo $load
