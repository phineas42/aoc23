. ${BASH_SOURCE[0]%/*}/factor.sh

lcm_array() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	local L R ML MR INCL INCR
	RESULT=${ARRAY[0]}
	for ((I=1;I<${#ARRAY[@]};I++)); do
		L=$RESULT
		R=${ARRAY[$I]}
		ML=$L
		MR=$R
		while [[ "$ML" -ne "$MR" ]]; do
			if [[ "$ML" -gt "$MR" ]]; then
				if [[ $(( (ML-MR) % R )) == 0 ]]; then
					MR=$ML
				else
					INCR=$((((ML-MR) / R)+1))
					MR=$((MR+R*INCR))
				fi
			else
				if [[ $(( (MR-ML) % L )) == 0 ]]; then
					ML=$MR
				else
					INCL=$((((MR-ML) / L)+1))
					ML=$((ML+L*INCL))
				fi
			fi
		done
		RESULT=$ML
	done
}

lcm_array_by_factors() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	local R L_FACTOR R_FACTOR L_POWER R_POWER
	declare -a L_FACTORS=()
	for R in ${ARRAY[@]}; do
		prime_factorize $R
		# RESULT is the prime factors of R. Process it in-place
		for R_FACTOR in ${!RESULT[@]}; do
			R_POWER=${RESULT[$R_FACTOR]}
			L_POWER=${L_FACTORS[$R_FACTOR]:-0}
			if [[  $L_POWER -lt $R_POWER ]]; then
				L_FACTORS[$R_FACTOR]=$R_POWER
			fi
		done
	done
	RESULT=1
	for L_FACTOR in ${!L_FACTORS[@]}; do
		RESULT=$((RESULT*L_FACTOR**${L_FACTORS[$L_FACTOR]}))
	done
}


lcm() {
	local L R ML MR INCL INCR
	RESULT=1
	for R in $@; do
		L=$RESULT
		ML=$L
		MR=$R
		while [[ "$ML" -ne "$MR" ]]; do
			if [[ "$ML" -gt "$MR" ]]; then
				if [[ $(( (ML-MR) % R )) == 0 ]]; then
					MR=$ML
				else
					INCR=$((((ML-MR) / R)+1))
					MR=$((MR+R*INCR))
				fi
			else
				if [[ $(( (MR-ML) % L )) == 0 ]]; then
					ML=$MR
				else
					INCL=$((((MR-ML) / L)+1))
					ML=$((ML+L*INCL))
				fi
			fi
		done
		RESULT=$ML
	done
}
