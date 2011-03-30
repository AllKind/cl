#!/usr/local/bash-4.2/bin/bash

if ((${BASH_VERSINFO[0]} < 4)); then
	printf "bash version 4+ is required\n" >&2
	exit 1
fi

# --------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------

LANG=C

declare -Ar FG_COLORS=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [white]=37)
declare -Ar BG_COLORS=([black]=40 [red]=41 [green]=42 [yellow]=43 [blue]=44 [magenta]=45 [cyan]=46 [white]=47)
declare -Ar ANSI_MODES=([normal]=0 [bold]=1 [faint]=2 [italic]=3 [underline]=4 [blink]=5 [fastblink]=6 [inverse]=7 [invisible]=8)
declare -ar ARR_COLNAMES_MAP=(
"black bla"
"red r"
"green g"
"yellow y"
"blue blu"
"magenta m"
"cyan c"
"white w"
)
declare -ar ARR_MODNAMES_MAP=(
"normal n"
"bold bo"
"faint fai"
"italic it"
"underline u"
"blink bli"
"fastblink fas"
"inverse inve"
"invisible invi"
)
declare -A AAR_FGNAMES_ALL
declare -A AAR_BGNAMES_ALL
declare -A AAR_MODNAMES_ALL

# --------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------

pr_sep() {
printf "%s\n" "---------------------------------------------------------"
}

get_variants() { # create unique variations of code names
local -i i_lengl=${#1} i_lengs=${#2}
while ((i_lengl >= i_lengs)); do
	printf "%s\n" ${1:0:i_lengl--}
done
}

set_variants() { # set variations of code names
local name n_long n_short variant
for name in ${!ARR_COLNAMES_MAP[@]}; do
	set -- ${ARR_COLNAMES_MAP[$name]}
	n_long=$1 n_short=$2
	for variant in $(get_variants $n_long $n_short); do
		AAR_FGNAMES_ALL[$variant]=${FG_COLORS[$n_long]}
		AAR_BGNAMES_ALL[$variant]=${BG_COLORS[$n_long]}
	done
done
for name in ${!ARR_MODNAMES_MAP[@]}; do
	set -- ${ARR_MODNAMES_MAP[$name]}
	n_long=$1 n_short=$2
	for variant in $(get_variants $n_long $n_short); do
		AAR_MODNAMES_ALL[$variant]=${ANSI_MODES[$n_long]}
	done
done
readonly AAR_FGNAMES_ALL AAR_BGNAMES_ALL AAR_MODNAMES_ALL
}

list() { # List colors and modes
local x
local -i i
local STR_FGNAMES=$(printf "%s\n" "${!FG_COLORS[@]}" | sort)
local STR_MODENAMES=$(printf "%s\n" "${!ANSI_MODES[@]}" | sort)
pr_sep; printf "Colors: Long-form | Shortest-form - Fore- / Background\n"; pr_sep
for x in $STR_FGNAMES; do
	for i in ${!ARR_COLNAMES_MAP[@]}; do
		set -- ${ARR_COLNAMES_MAP[i]}
		[[ $1 = $x ]] && printf " %-9s | %-6s - %s / %s\n" $x $2 ${FG_COLORS[$x]} ${BG_COLORS[$x]} && break
	done
done
pr_sep; printf "Modes: Long-form | Shortest-form - Code\n"; pr_sep
for x in $STR_MODENAMES; do
	for i in ${!ARR_MODNAMES_MAP[@]}; do
		set -- ${ARR_MODNAMES_MAP[i]}
		[[ $1 = $x ]] && printf " %-9s | %-6s - %s\n" $x $2 ${ANSI_MODES[$x]} && break
	done
done
}

show() { # Print the color table
local x
local -i i_mode i_fg i_bg
eval declare -ar ARR_ANSI_MODES=( $(for x in ${!ANSI_MODES[@]}; do printf "[%s]=%s\n" ${ANSI_MODES[$x]} $x; done) )
eval declare -ar ARR_FG_COLORS=( $(for x in ${!FG_COLORS[@]}; do printf "[%s]=%s\n" ${FG_COLORS[$x]} $x; done) )
eval declare -ar ARR_BG_COLORS=( $(for x in ${!BG_COLORS[@]}; do printf "[%s]=%s\n" ${BG_COLORS[$x]} $x; done) )
for i_mode in ${!ARR_ANSI_MODES[@]}; do
	pr_sep
	printf " Mode: %-12s Code: ESC[%s;Foreground;Background\n" ${ARR_ANSI_MODES[i_mode]} $i_mode
	pr_sep
	for i_fg in ${!ARR_FG_COLORS[@]}; do
		for i_bg in ${!ARR_BG_COLORS[@]}; do
			printf '\e[%s;%s;%sm %02s;%02s ' ${i_mode} $i_fg $i_bg $i_fg $i_bg
		done
		printf '\e[0m'
		echo
	done
done
}

ismode() { # check if name is a known mode
[[ ${AAR_MODNAMES_ALL[$1]} ]]
}

iscolor() { # check if name is a known color
[[ ${AAR_FGNAMES_ALL[$1]} ]]
}

add_code() {
arr_ansi_seq+="$1;"
}

cl() { # assemble the ansi code sequence
local -i i_bg=i_fg=0
declare -a arr_ansi_seq=()
[[ -z $1 ]] && set -- "off"
while (( $# )); do
	if [[ $1 = off ]]; then
		arr_ansi_seq=(0)
		break
	elif ismode "$1"; then
		add_code "${AAR_MODNAMES_ALL[$1]}"
	elif iscolor "$1"; then
		if ! ((i_fg)); then
			i_fg=1
			add_code "${AAR_FGNAMES_ALL[$1]}"
		elif ! ((i_bg)); then
			i_bg=1
			add_code "${AAR_BGNAMES_ALL[$1]}"
		else
			printf "Only 2 colors are allowed\n" >&2
			return 1
		fi
	else
		printf "\`%s' - unknown descriptor\n" "$1" >&2
		return 1
	fi
	shift
done
printf '\e'"[${arr_ansi_seq[*]%;}m"
}

# --------------------------------------------------------------
# MAIN
# --------------------------------------------------------------

case "$1" in
	--help)
		printf "${0##*/} - Colorize shell [script] output\n\n"
		printf "${0##*/} [mode [...]] [fg-color] [bg-color]\n"
		printf "${0##*/} --help | --list | --show\n\n"
		exit
	;;
	--list)
   		list
		exit
	;;
	--show)
   		show
		exit
	;;
esac
[[ $1 && $1 != off ]] && set_variants
cl "$@"
exit $?

