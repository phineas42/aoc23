#!/usr/bin/bash
. ../aoc23.sh
declare -a gaps_vertical
declare -a gaps_horizontal
declare -a galaxies=()
row_number=0
used_rows=()
user_cols=()
width=
height=
while read line; do
	if [[ -z "$width" ]]; then
		width=${#line}
	fi
	if [[ "$line" =~ ^\.*$ ]]; then
		gaps_horizontal[row_number]=1
	else
		used_rows[row_number]=1
		find_index "#" $line
		while [[ ${_result[0]} -ne -1 ]]; do
			index=${_result[0]}
			galaxies+=("$row_number $index")
			used_cols[index]=1
			find_index "#" $line $((index + 1))
		done
	fi
	row_number=$((row_number + 1))
done <<<"$input_data"
height=$row_number

# Determine vertical gaps
for ((col_number=0; col_number<width; col_number++)); do
	if [[ -z "${used_cols[col_number]:-}" ]]; then
		gaps_vertical[col_number]=1
	fi
done

get_distance() {
	unset _result
	declare -g _result
	local galaxy_index_L=$1
	local galaxy_index_R=$2
	local galaxy_L=(${galaxies[galaxy_index_L]})
	local galaxy_R=(${galaxies[galaxy_index_R]})
	local galaxy_L_row=${galaxy_L[0]}
	local galaxy_L_col=${galaxy_L[1]}
	local galaxy_R_row=${galaxy_R[0]}
	local galaxy_R_col=${galaxy_R[1]}
	local i local delta_row delta_col
	if [[ "$galaxy_R_row" -lt "$galaxy_L_row" ]]; then
		galaxy_R_row=$galaxy_L_row
		galaxy_L_row=${galaxy_R[0]}
	fi
	delta_row=$((galaxy_R_row - galaxy_L_row))
	for ((i=galaxy_L_row+1; i<galaxy_R_row; i++)); do
		if [[ -n "${gaps_horizontal[i]:-}" ]]; then
			delta_row=$((delta_row + 1))
		fi
	done
	if [[ "$galaxy_R_col" -lt "$galaxy_L_col" ]]; then
		galaxy_R_col=$galaxy_L_col
		galaxy_L_col=${galaxy_R[1]}
	fi
	delta_col=$((galaxy_R_col - galaxy_L_col))
	for ((i=galaxy_L_col+1; i<galaxy_R_col; i++)); do
		if [[ -n "${gaps_vertical[i]:-}" ]]; then
			delta_col=$((delta_col + 1))
		fi
	done
	abs $((delta_row + delta_col))
}

accumulator=0
declare -a distances
galaxy_indices=(${!galaxies[@]})
for galaxy_index in ${galaxy_indices[@]}; do
	distances[galaxy_index]=""
	for target_index in ${galaxy_indices[@]:$((galaxy_index + 1 ))}; do
		get_distance $galaxy_index $target_index
		distances[galaxy_index]+=" $_result"
		accumulator=$((accumulator+$_result))
	done
done
echo $accumulator
