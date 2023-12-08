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
