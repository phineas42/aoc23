min() {
        unset RESULT
        declare -g RESULT=$1
        shift
        local N
        for N in $@; do
                if [[ $N -lt $RESULT ]]; then
                        RESULT=$N
                fi
        done
}

min_array() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	min ${ARRAY[@]}
}
