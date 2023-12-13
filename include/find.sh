#find_index() {
#	unset _result
#	declare -g -a _result=(-1 "")
#        local pattern=$1 string=$2 begin=${3:-0} substring i
#        for (( i=$begin; i<${#string}; i++ )); do
#                substring=${string:$i}
#                if [[ "$substring" =~ ^$pattern ]]; then
#                        _result=($i "${BASH_REMATCH[0]}")
#                        return
#                fi
#        done
#}

find_index() {
	unset _result
	declare -g -a _result
        local pattern=$1 string=$2 begin=${3:-0} before_len match_len after_len
	if [[ "${string:$begin}" =~ ($pattern)(.*)$ ]]; then
		after_len=${#BASH_REMATCH[-1]}
		match_len=${#BASH_REMATCH[1]}
		before_len=$((${#string}-after_len-match_len))
		_result=($before_len "${BASH_REMATCH[0]}")
	else
		_result=(-1 "")
	fi
}
