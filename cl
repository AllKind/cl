#!/bin/bash

# --------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------

LANG=C

if ((${BASH_VERSINFO[0]} >= 4)); then
	declare -Ar FG_COLORS=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [white]=37)
	declare -Ar BG_COLORS=([black]=40 [red]=41 [green]=42 [yellow]=43 [blue]=44 [magenta]=45 [cyan]=46 [white]=47)
	declare -Ar ANSI_MODES=([normal]=0 [bold]=1 [faint]=2 [italic]=3 [underline]=4 [blink]=5 [fastblink]=6 [inverse]=7 [invisible]=8)
	declare -A AAR_FGNAMES_ALL
	declare -A AAR_BGNAMES_ALL
	declare -A AAR_MODNAMES_ALL
else
	declare -ar ARR_ANSI_MODES=(normal bold faint italic underline blink fastblink inverse invisible)
	declare -ar ARR_FG_COLORS=([30]=black [31]=red [32]=green [33]=yellow [34]=blue [35]=magenta [36]=cyan [37]=white)
	declare -ar ARR_BG_COLORS=([40]=black [41]=red [42]=green [43]=yellow [44]=blue [45]=magenta [46]=cyan [47]=white)
	declare -a ARR_FGNAMES_ALL
	declare -a ARR_BGNAMES_ALL
	declare -a ARR_MODNAMES_ALL
fi
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

# --------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------

pr_sep() {
printf "%s\n" "---------------------------------------------------------"
}

if ((${BASH_VERSINFO[0]} < 4)); then
	cl_get_fg_code() {
		local -i i
		for i in ${!ARR_FG_COLORS[@]}; do
			[[ ${ARR_FG_COLORS[i]} = $1 ]] && printf "%d\n" $i && return
		done
	}
	cl_get_bg_code() {
		local -i i
		for i in ${!ARR_BG_COLORS[@]}; do
			[[ ${ARR_BG_COLORS[i]} = $1 ]] && printf "%d\n" $i && return
		done
	}
	cl_get_ansi_code() {
		local -i i
		for i in ${!ARR_ANSI_MODES[@]}; do
			[[ ${ARR_ANSI_MODES[i]} = $1 ]] && printf "%d\n" $i && return
		done
	}
fi

if ((${BASH_VERSINFO[0]} < 4)); then
	cl_get_fg_code_all() {
		local -i i
		local x
		for i in ${!ARR_FGNAMES_ALL[@]}; do
			for x in ${ARR_FGNAMES_ALL[i]}; do
				[[ $x = $1 ]] && printf "%d\n" $i && return
			done
		done
	}
	cl_get_bg_code_all() {
		local -i i
		local x
		for i in ${!ARR_BGNAMES_ALL[@]}; do
			for x in ${ARR_BGNAMES_ALL[i]}; do
				[[ $x = $1 ]] && printf "%d\n" $i && return
			done
		done
	}
	cl_get_ansi_code_all() {
		local -i i
		local x
		for i in ${!ARR_MODNAMES_ALL[@]}; do
			for x in ${ARR_MODNAMES_ALL[i]}; do
				[[ $x = $1 ]] && printf "%d\n" $i && return
			done
		done
	}
fi

cl_get_variants() { # create unique variations of code names
	local -i i_lengl=${#1} i_lengs=${#2}
	while ((i_lengl >= i_lengs)); do
		printf "%s\n" ${1:0:i_lengl--}
	done
}

if ((${BASH_VERSINFO[0]} >= 4)); then
	cl_set_variants() { # set variations of code names
		local name n_long n_short variant
		for name in ${!ARR_COLNAMES_MAP[@]}; do
			set -- ${ARR_COLNAMES_MAP[$name]}
			n_long=$1 n_short=$2
			for variant in $(cl_get_variants $n_long $n_short); do
				AAR_FGNAMES_ALL[$variant]=${FG_COLORS[$n_long]}
				AAR_BGNAMES_ALL[$variant]=${BG_COLORS[$n_long]}
			done
		done
		for name in ${!ARR_MODNAMES_MAP[@]}; do
			set -- ${ARR_MODNAMES_MAP[$name]}
			n_long=$1 n_short=$2
			for variant in $(cl_get_variants $n_long $n_short); do
				AAR_MODNAMES_ALL[$variant]=${ANSI_MODES[$n_long]}
			done
		done
		readonly AAR_FGNAMES_ALL AAR_BGNAMES_ALL AAR_MODNAMES_ALL
	}
else
	cl_set_variants() { # set variations of code names
		local name n_long n_short variant
		local -i fg_code bg_code
		for name in ${!ARR_COLNAMES_MAP[@]}; do
			set -- ${ARR_COLNAMES_MAP[$name]}
			n_long=$1 n_short=$2 fg_code=$(cl_get_fg_code $1) bg_code=$(cl_get_bg_code $1)
			for variant in $(cl_get_variants $n_long $n_short); do
				ARR_FGNAMES_ALL[fg_code]="${ARR_FGNAMES_ALL[fg_code]} $variant"
				ARR_BGNAMES_ALL[bg_code]="${ARR_BGNAMES_ALL[bg_code]} $variant"
			done
		done
		for name in ${!ARR_MODNAMES_MAP[@]}; do
			set -- ${ARR_MODNAMES_MAP[$name]}
			n_long=$1 n_short=$2 fg_code=$(cl_get_ansi_code $1)
			for variant in $(cl_get_variants $n_long $n_short); do
				ARR_MODNAMES_ALL[fg_code]="${ARR_MODNAMES_ALL[fg_code]} $variant"
			done
		done
		readonly ARR_FGNAMES_ALL ARR_BGNAMES_ALL ARR_MODNAMES_ALL
	}
fi

cl_list() { # List colors and modes
local x
local -i i
if ((${BASH_VERSINFO[0]} >= 4)); then
	local STR_FGNAMES=$(printf "%s\n" "${!FG_COLORS[@]}" | sort)
	local STR_MODENAMES=$(printf "%s\n" "${!ANSI_MODES[@]}" | sort)
else
	local STR_FGNAMES=$(printf "%s\n" "${ARR_FG_COLORS[@]}" | sort)
	local STR_MODENAMES=$(printf "%s\n" "${ARR_ANSI_MODES[@]}" | sort)
fi
pr_sep; printf "Colors: Long-form | Shortest-form - Fore- / Background\n"; pr_sep
for x in $STR_FGNAMES; do
	for i in ${!ARR_COLNAMES_MAP[@]}; do
		set -- ${ARR_COLNAMES_MAP[i]}
		if [[ $1 = $x ]]; then
			if ((${BASH_VERSINFO[0]} >= 4)); then
			   printf " %-9s | %-6s - %s / %s\n" $x $2 ${FG_COLORS[$x]} ${BG_COLORS[$x]}
			else
				printf " %-9s | %-6s - %s / %s\n" $x $2 $(cl_get_fg_code $x) $(cl_get_bg_code $x)
			fi
			break
		fi
	done
done
pr_sep; printf "Modes: Long-form | Shortest-form - Code\n"; pr_sep
for x in $STR_MODENAMES; do
	for i in ${!ARR_MODNAMES_MAP[@]}; do
		set -- ${ARR_MODNAMES_MAP[i]}
		if [[ $1 = $x ]]; then
			if ((${BASH_VERSINFO[0]} >= 4)); then
				printf " %-9s | %-6s - %s\n" $x $2 ${ANSI_MODES[$x]} && break
			else
				printf " %-9s | %-6s - %s\n" $x $2 $(cl_get_ansi_code $x) && break
			fi
		fi
	done
done
}

cl_show() { # Print the color table
local x
local -i i_mode i_fg i_bg
if ((${BASH_VERSINFO[0]} >= 4)); then
	eval declare -ar ARR_ANSI_MODES=( $(for x in ${!ANSI_MODES[@]}; do printf "[%s]=%s\n" ${ANSI_MODES[$x]} $x; done) )
	eval declare -ar ARR_FG_COLORS=( $(for x in ${!FG_COLORS[@]}; do printf "[%s]=%s\n" ${FG_COLORS[$x]} $x; done) )
	eval declare -ar ARR_BG_COLORS=( $(for x in ${!BG_COLORS[@]}; do printf "[%s]=%s\n" ${BG_COLORS[$x]} $x; done) )
fi
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

# check if name is a known mode
if ((${BASH_VERSINFO[0]} >= 4)); then
	cl_ismode() {
		[[ ${AAR_MODNAMES_ALL[$1]} ]]
	}
else
	cl_ismode() {
		local -i i
		local x
		for i in ${!ARR_MODNAMES_ALL[@]}; do
			for x in ${ARR_MODNAMES_ALL[i]}; do
				[[ $x = $1 ]] && return
			done
		done
		return 1
	}
fi

# check if name is a known color
if ((${BASH_VERSINFO[0]} >= 4)); then
	cl_iscolor() {
		[[ ${AAR_FGNAMES_ALL[$1]} ]]
	}
else
	cl_iscolor() {
		local -i i
		local x
		for i in ${!ARR_FGNAMES_ALL[@]}; do
			for x in ${ARR_FGNAMES_ALL[i]}; do
				[[ $x = $1 ]] && return
			done
		done
		return 1
	}
fi

_cl_add_code() {
	str_ansi_seq+="$1;"
}

cl() { # assemble the ansi code sequence
local -i i_bg=i_fg=0
local str_ansi_seq=""
if [[ $1 ]]; then
   cl_set_variants
else
	set -- "off"
fi
while (( $# )); do
	if [[ $1 = off ]]; then
		str_ansi_seq=(0)
		break
	elif cl_ismode "$1"; then
		if ((${BASH_VERSINFO[0]} >= 4)); then
			_cl_add_code "${AAR_MODNAMES_ALL[$1]}"
		else
			_cl_add_code $(cl_get_ansi_code_all $1)
		fi
	elif cl_iscolor "$1"; then
		if ! ((i_fg)); then
			i_fg=1
			if ((${BASH_VERSINFO[0]} >= 4)); then
				_cl_add_code "${AAR_FGNAMES_ALL[$1]}"
			else
				_cl_add_code $(cl_get_fg_code_all $1)
			fi
		elif ! ((i_bg)); then
			i_bg=1
			if ((${BASH_VERSINFO[0]} >= 4)); then
				_cl_add_code "${AAR_BGNAMES_ALL[$1]}"
			else
				_cl_add_code $(cl_get_bg_code_all $1)
			fi
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
printf "\e[${str_ansi_seq%;}m"
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
   		cl_list
		exit
	;;
	--show)
   		cl_show
		exit
	;;
esac
cl "$@"
exit $?

