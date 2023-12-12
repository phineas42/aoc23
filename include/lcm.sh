include_dir=${BASH_SOURCE[0]%/*}
if [[ "$include_dir" == "${BASH_SOURCE[0]}" ]]; then
	include_dir=.
fi
. ${include_dir}/factor.sh

lcm_array() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name
	local num_L num_R multiple_L multiple_R addend
	_result=${array[0]}
	for ((i=1; i<${#array[@]}; i++)); do
		num_L=$_result
		num_R=${array[i]}
		multiple_L=$num_L
		multiple_R=$num_R
		while [[ "$multiple_L" -ne "$multiple_R" ]]; do
			if [[ "$multiple_L" -gt "$multiple_R" ]]; then
				if [[ $(( (multiple_L - multiple_R) % num_R )) == 0 ]]; then
					multiple_R=$multiple_L
				else
					addend=$(( ((multiple_L - multiple_R) / num_R) + 1))
					multiple_R=$((multiple_R + num_R*addend))
				fi
			else
				if [[ $(( (multiple_R - multiple_L) % num_L )) == 0 ]]; then
					multiple_L=$multiple_R
				else
					addend=$(( ( (multiple_R - multiple_L) / num_L) + 1))
					multiple_L=$(( multiple_L + num_L*addend))
				fi
			fi
		done
		_result=$multiple_L
	done
}

lcm_array_by_factors() {
	unset _result
	declare -g _result
	local array_name=$1
	declare -n array=$array_name
	local num_R factor_L factor_R power_L power_R
	declare -a factors_L=()
	for num_R in ${array[@]}; do
		prime_factorize $num_R
		# _result is the prime factors of R. Process it in-place
		for factor_R in ${!_result[@]}; do
			power_R=${_result[factor_R]}
			power_L=${factors_L[factor_R]:-0}
			if [[  $power_L -lt $power_R ]]; then
				factors_L[factor_R]=$power_R
			fi
		done
	done
	_result=1
	for factor_L in ${!factors_L[@]}; do
		_result=$(( _result * factor_L**${factors_L[factor_L]}))
	done
}


lcm() {
	unset _result
	declare -g _result
	local num_L num_R multiple_L multiple_R addend
	_result=1
	for num_R in $@; do
		num_L=$_result
		multiple_L=$num_L
		multiple_R=$num_R
		while [[ "$multiple_L" -ne "$multiple_R" ]]; do
			if [[ "$multiple_L" -gt "$multiple_R" ]]; then
				if [[ $(( (multiple_L - multiple_R) % num_R )) == 0 ]]; then
					multiple_R=$multiple_L
				else
					addend=$(( ((multiple_L - multiple_R) / num_R) + 1))
					multiple_R=$((multiple_R + num_R*addend))
				fi
			else
				if [[ $(( (multiple_R - multiple_L) % num_L )) == 0 ]]; then
					multiple_L=$multiple_R
				else
					addend=$(( ((multiple_R - multiple_L) / num_L) + 1))
					multiple_L=$((multiple_L + num_L*addend))
				fi
			fi
		done
		_result=$multiple_L
	done
}
