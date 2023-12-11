#!/usr/bin/bash
set -e
INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

get_char() {
	local ROW=$1 COL=$2
	declare -g WIDTH HEIGHT
	if [[ "$ROW" -lt 0 || "$ROW" -ge $HEIGHT || "$COL" -lt 0 || "$COL" -ge $WIDTH ]]; then
		RESULT=
		return
	fi
	RESULT=${INPUT_ROWS[$ROW]:$COL:1}
}

ROW=0
START_ROW=
START_COL=
INPUT_ROWS=()

while read LINE; do
	HEIGHT=$((ROW+1))
	if [[ "$ROW" -eq 0 ]]; then
		WIDTH=${#LINE}
	fi
	INPUT_ROWS+=($LINE)
	if [[ -z "$START_ROW" ]]; then
		for ((COL=0;COL<${#LINE};COL++)); do
			get_char $ROW $COL
			if [[ "$RESULT" == S ]]; then
				START_ROW=$ROW
				START_COL=$COL
				break
			fi
		done
	fi
	ROW=$HEIGHT
done <<<"$INPUT_DATA"

# Save pipe locations for loop members
ROW=$START_ROW
COL=$START_COL
IN_DIR=
OUT_DIR=
declare -a LOOP_LOCS
while true; do
	if [[ -z "$OUT_DIR" || $OUT_DIR == E ]]; then
		get_char $ROW $((COL+1))
		case $RESULT in
			[\-7J])
				# East connection detected
				IN_DIR=W
				COL=$((COL+1))
				LOOP_LOCS[$(((ROW<<8)+COL))]=$RESULT
				case $RESULT in
					7) OUT_DIR=S ;;
					J) OUT_DIR=N ;;
					\-) OUT_DIR=E ;;
				esac
				;;
			S)	LOOP_LOCS[$(((ROW<<8)+COL+1))]=$RESULT; break ;; # end of loop of pipes
		esac
	fi
	if [[ -z "$OUT_DIR" || $OUT_DIR == S ]]; then
		get_char $((ROW+1)) $COL
		case $RESULT in
			[\|JL])
				# South connection detected
				IN_DIR=N
				ROW=$((ROW+1))
				LOOP_LOCS[$(((ROW<<8)+COL))]=$RESULT
				case $RESULT in
					J) OUT_DIR=W ;;
					L) OUT_DIR=E ;;
					\|) OUT_DIR=S ;;
				esac
				;;
			S)	LOOP_LOCS[$((((ROW+1)<<8)+COL))]=$RESULT; break ;; # end of loop of pipes
		esac
	fi
	if [[ -z "$OUT_DIR" || $OUT_DIR == W ]]; then
		get_char $ROW $((COL-1))
		case $RESULT in
			[\-LF])
				# West connection detected
				IN_DIR=E
				COL=$((COL-1))
				LOOP_LOCS[$(((ROW<<8)+COL))]=$RESULT
				case $RESULT in
					L) OUT_DIR=N ;;
					F) OUT_DIR=S ;;
					\-) OUT_DIR=W ;;
				esac
				;;
			S)	LOOP_LOCS[$(((ROW<<8)+COL-1))]=$RESULT; break ;; # end of loop of pipes
		esac
	fi
	if [[ -z "$OUT_DIR" || $OUT_DIR == N ]]; then
		get_char $((ROW-1)) $COL
		case $RESULT in
			[\|F7])
				# North connection detected
				IN_DIR=S
				ROW=$((ROW-1))
				LOOP_LOCS[$(((ROW<<8)+COL))]=$RESULT
				case $RESULT in
					F) OUT_DIR=E ;;
					7) OUT_DIR=W ;;
					\|) OUT_DIR=N ;;
				esac
				;;
			S)	LOOP_LOCS[$((((ROW-1)<<8)+COL))]=$RESULT; break ;; # end of loop of pipes
		esac
	fi
done

# Iterate over field
INSIDE_COUNT=0
COUNT=0
for ((ROW=0;ROW<$HEIGHT;ROW++)); do
	# 0 means true here
	IS_OUTSIDE=0
	PREV_PIECE=.
	PIPE_DIR=
	for ((COL=0;COL<$WIDTH;COL++)); do
		LOOP_PIECE=${LOOP_LOCS[$(((ROW<<8)+COL))]}

		if [[ -z "$LOOP_PIECE" ]]; then
			if [[ $IS_OUTSIDE -ne 0 ]]; then
				INSIDE_COUNT=$((INSIDE_COUNT+1))
				# DEBUG
				# echo -n $'\x1b[32m\xe2\x96\x88\x1b[0m'
			else
				:
				# echo -n $'\xe2\x96\x88'
			fi
			PREV_PIECE=.
			continue
		fi
		# case $LOOP_PIECE in
		# 	F)	PRINT_PIECE="┏"; ;;
		# 	7)	PRINT_PIECE="┓"; ;;
		# 	J)	PRINT_PIECE="┛"; ;;
		# 	L)	PRINT_PIECE="┗"; ;;
		# 	-)	PRINT_PIECE="━"; ;;
		# 	\|)	PRINT_PIECE="┃"; ;;
		# 	*)	PRINT_PIECE="▣"; ;;
		# esac
		# echo -n "$PRINT_PIECE"
		if [[ "$PREV_PIECE" == "-" ]]; then
			case "$LOOP_PIECE" in
				S)
					NORTH_PIECE="${LOOP_LOCS[$((((ROW-1)<<8)+COL))]}"
					SOUTH_PIECE="${LOOP_LOCS[$((((ROW+1)<<8)+COL))]}"
					if [[ -n "$NORTH_PIECE" && "$NORTH_PIECE" =~ [F7] ]]; then
						LOOP_PIECE="J"
					elif [[ -n "$SOUTH_PIECE" && "$SOUTH_PICE" =~ [LJ] ]]; then
						LOOP_PIECE="7"
					else
						LOOP_PIECE="-"
					fi
					;;&
				7)
					PREV_PIECE="|"
					if [[ "$PIPE_DIR" == "L" ]]; then
						IS_OUTSIDE=$((1-IS_OUTSIDE))
					fi
					;;
				J)
					PREV_PIECE="|"
					if [[ "$PIPE_DIR" == "F" ]]; then
						IS_OUTSIDE=$((1-IS_OUTSIDE))
					fi
					;;
			esac
		else
			case "$LOOP_PIECE" in
				S)
					NORTH_PIECE="${LOOP_LOCS[$((((ROW-1)<<8)+COL))]}"
					SOUTH_PIECE="${LOOP_LOCS[$((((ROW+1)<<8)+COL))]}"
					if [[ -n "$NORTH_PIECE" && "$NORTH_PIECE" =~ [F7] ]]; then
						if [[ -n "$SOUTH_PIECE" && $SOUTH_PIECE =~ [LJ] ]]; then
							LOOP_PIECE="|"
						else
							LOOP_PIECE="L"
						fi
					else
						LOOP_PIECE="F"
					fi
					;;&
				\|)	PREV_PIECE="|"; IS_OUTSIDE=$((1-IS_OUTSIDE)); ;;
				[FL])	PREV_PIECE="-"; PIPE_DIR=$LOOP_PIECE; ;;
			esac
		fi
	done
	# echo
done
echo $INSIDE_COUNT
