#!/bin/bash

# -----------------------------------------------------------------
# cl - Colorize shell [script] output 
#
# https://sourceforge.net/projects/colorize-shell
# https://github.com/AllKind/cl
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Copyright (C) 2013 AllKind (AllKind@fastest.cc)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Examples:
#
# cl bold yellow    - set current shell foreground colour to bold yellow
# cl off            - turn off colors (off can be omitted)
# cl --print red    - show generated code for forground color red
# printf "foo %b bar\n" "$(cl red yellow)fox$(cl)"    - display fox
# + in red on yellow background
# -----------------------------------------------------------------

# bash version check
if [ -z "$BASH" ]; then
	printf "\`BASH' variable is not available. Not running bash?\n" >&2
	exit 3
fi
if [ ${BASH_VERSINFO[0]} -lt 3 ]; then
	printf "${0##*/} requires bash version 3.1 or higher.\n" >&2
	exit 3
fi
if ((BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] == 0)); then
	printf "${0##*/} requires bash version 3.1 or higher.\n" >&2
	exit 3
fi

# --------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------

LANG=C
: ${CL_DIR_DATA:=~}
: ${CL_FILE_VARIANTS:=.cl_variants}
CL_FILE_VARIANTS="${CL_FILE_VARIANTS}_bash${BASH_VERSINFO[0]}"
declare P_FORMAT

if ((BASH_VERSINFO[0] >= 4)); then
	declare -Ar AAR_FG_COLORS=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [white]=37)
	declare -Ar AAR_BG_COLORS=([black]=40 [red]=41 [green]=42 [yellow]=43 [blue]=44 [magenta]=45 [cyan]=46 [white]=47)
	declare -Ar AAR_ANSI_MODES=([normal]=0 [bold]=1 [faint]=2 [italic]=3 [underline]=4 [blink]=5 [fastblink]=6 [inverse]=7 [invisible]=8)
	declare -A AAR_FGNAMES_ALL AAR_BGNAMES_ALL AAR_MODNAMES_ALL
else
	declare -ar ARR_ANSI_MODES=(normal bold faint italic underline blink fastblink inverse invisible)
	declare -ar ARR_FG_COLORS=([30]=black [31]=red [32]=green [33]=yellow [34]=blue [35]=magenta [36]=cyan [37]=white)
	declare -ar ARR_BG_COLORS=([40]=black [41]=red [42]=green [43]=yellow [44]=blue [45]=magenta [46]=cyan [47]=white)
	declare -a ARR_FGNAMES_ALL ARR_BGNAMES_ALL ARR_MODNAMES_ALL
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
printf "%s\n" "--------------------------------------------------------"
}

cl_get_variants() { # create unique variations of code names
local -i i_lengl=${#1} i_lengs=${#2}
while ((i_lengl >= i_lengs)); do
	printf "%s\n" ${1:0:i_lengl--}
done
}

if ((BASH_VERSINFO[0] < 4)); then
# retrieve codes from names (bash prior to v4)
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
# retrieve codes from names (bash prior to v4) - incl. variants
	cl_get_fg_code_all() {
		local x
		local -i i
		for i in ${!ARR_FGNAMES_ALL[@]}; do
			for x in ${ARR_FGNAMES_ALL[i]}; do
				[[ $x = $1 ]] && printf "%d\n" $i && return
			done
		done
	}
	cl_get_bg_code_all() {
		local x
		local -i i
		for i in ${!ARR_BGNAMES_ALL[@]}; do
			for x in ${ARR_BGNAMES_ALL[i]}; do
				[[ $x = $1 ]] && printf "%d\n" $i && return
			done
		done
	}
	cl_get_ansi_code_all() {
		local x
		local -i i
		for i in ${!ARR_MODNAMES_ALL[@]}; do
			for x in ${ARR_MODNAMES_ALL[i]}; do
				[[ $x = $1 ]] && printf "%d\n" $i && return
			done
		done
	}
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
	cl_save_variants() { # print (for saving) the code name variation arrays
		declare -p ARR_FGNAMES_ALL ARR_BGNAMES_ALL ARR_MODNAMES_ALL
	}
	cl_ismode() { # check if name is a known mode
		local x
		local -i i
		for i in ${!ARR_MODNAMES_ALL[@]}; do
			for x in ${ARR_MODNAMES_ALL[i]}; do
				[[ $x = $1 ]] && return
			done
		done
		return 1
	}
	cl_iscolor() { # check if name is a known color
		local x
		local -i i
		for i in ${!ARR_FGNAMES_ALL[@]}; do
			for x in ${ARR_FGNAMES_ALL[i]}; do
				[[ $x = $1 ]] && return
			done
		done
		return 1
	}
else
	cl_set_variants() { # set variations of code names
		local name n_long n_short variant
		for name in ${!ARR_COLNAMES_MAP[@]}; do
			set -- ${ARR_COLNAMES_MAP[$name]}
			n_long=$1 n_short=$2
			for variant in $(cl_get_variants $n_long $n_short); do
				AAR_FGNAMES_ALL[$variant]=${AAR_FG_COLORS[$n_long]}
				AAR_BGNAMES_ALL[$variant]=${AAR_BG_COLORS[$n_long]}
			done
		done
		for name in ${!ARR_MODNAMES_MAP[@]}; do
			set -- ${ARR_MODNAMES_MAP[$name]}
			n_long=$1 n_short=$2
			for variant in $(cl_get_variants $n_long $n_short); do
				AAR_MODNAMES_ALL[$variant]=${AAR_ANSI_MODES[$n_long]}
			done
		done
		readonly AAR_FGNAMES_ALL AAR_BGNAMES_ALL AAR_MODNAMES_ALL
	}
	cl_save_variants() { # print (for saving) the code name variation arrays
		declare -p AAR_FGNAMES_ALL AAR_BGNAMES_ALL AAR_MODNAMES_ALL
	}
	cl_ismode() { # check if name is a known mode
		[[ ${AAR_MODNAMES_ALL[$1]} ]]
	}
	cl_iscolor() { # check if name is a known color
		[[ ${AAR_FGNAMES_ALL[$1]} ]]
	}
fi

cl_list() { # List colors and modes
local x fgc bgc
local -i i
if ((BASH_VERSINFO[0] >= 4)); then
	local STR_FGNAMES=$(printf "%s\n" "${!AAR_FG_COLORS[@]}" | sort)
	local STR_MODENAMES=$(printf "%s\n" "${!AAR_ANSI_MODES[@]}" | sort)
else
	local STR_FGNAMES=$(printf "%s\n" "${ARR_FG_COLORS[@]}" | sort)
	local STR_MODENAMES=$(printf "%s\n" "${ARR_ANSI_MODES[@]}" | sort)
fi
pr_sep; printf "Colors: Long-form | Shortest-form - Fore- / Background\n"; pr_sep
for x in $STR_FGNAMES; do
	for i in ${!ARR_COLNAMES_MAP[@]}; do
		set -- ${ARR_COLNAMES_MAP[i]}
		if [[ $1 = $x ]]; then
			if ((BASH_VERSINFO[0] >= 4)); then
				fgc=${AAR_FG_COLORS[$x]} bgc=${AAR_BG_COLORS[$x]}
			else
				fgc=$(cl_get_fg_code $x) bgc=$(cl_get_bg_code $x)
			fi
			printf " %-9s | %-6s - %s / %s\n" $x $2 $fgc $bgc
			break
		fi
	done
done
pr_sep; printf "Modes: Long-form | Shortest-form - Code\n"; pr_sep
for x in $STR_MODENAMES; do
	for i in ${!ARR_MODNAMES_MAP[@]}; do
		set -- ${ARR_MODNAMES_MAP[i]}
		if [[ $1 = $x ]]; then
			if ((BASH_VERSINFO[0] >= 4)); then
				fgc=${AAR_ANSI_MODES[$x]}
			else
				fgc=$(cl_get_ansi_code $x)
			fi
			printf " %-9s | %-6s - %s\n" $x $2 $fgc
			break
		fi
	done
done
}

cl_show() { # Print the color table
local x
local -i i_mode i_fg i_bg
if ((BASH_VERSINFO[0] >= 4)); then
	eval declare -ar ARR_ANSI_MODES=($(for x in ${!AAR_ANSI_MODES[@]};do printf "[%s]=%s\n" ${AAR_ANSI_MODES[$x]} $x;done))
	eval declare -ar ARR_FG_COLORS=($(for x in ${!AAR_FG_COLORS[@]};do printf "[%s]=%s\n" ${AAR_FG_COLORS[$x]} $x;done))
	eval declare -ar ARR_BG_COLORS=($(for x in ${!AAR_BG_COLORS[@]};do printf "[%s]=%s\n" ${AAR_BG_COLORS[$x]} $x;done))
fi
for i_mode in ${!ARR_ANSI_MODES[@]}; do
	pr_sep
	printf " Mode: %-12s Code: ESC[%s;Foreground;Background\n" ${ARR_ANSI_MODES[i_mode]} $i_mode
	pr_sep
	for i_fg in ${!ARR_FG_COLORS[@]}; do
		for i_bg in ${!ARR_BG_COLORS[@]}; do
			printf '\e[%s;%s;%sm %02s;%02s ' ${i_mode} $i_fg $i_bg $i_fg $i_bg
		done
		printf '\e[0m\n'
	done
done
}

_cl_add_code() { # add a code sequence to the ansi_code string
	str_ansi_seq+="$1;"
}

cl() { # assemble the ansi code sequence
local -i i_bg=i_fg=0
local str_ansi_seq=""
if [[ -z $1 || $1 = off ]]; then
	str_ansi_seq=0
	shift $#
fi
while (( $# )); do
	if cl_ismode "$1"; then
		if ((BASH_VERSINFO[0] >= 4)); then
			_cl_add_code "${AAR_MODNAMES_ALL[$1]}"
		else
			_cl_add_code $(cl_get_ansi_code_all $1)
		fi
	elif cl_iscolor "$1"; then
		if ! ((i_fg)); then
			i_fg=1
			if ((BASH_VERSINFO[0] >= 4)); then
				_cl_add_code "${AAR_FGNAMES_ALL[$1]}"
			else
				_cl_add_code $(cl_get_fg_code_all $1)
			fi
		elif ! ((i_bg)); then
			i_bg=1
			if ((BASH_VERSINFO[0] >= 4)); then
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
printf $P_FORMAT "\e[${str_ansi_seq%;}m"
}

# --------------------------------------------------------------
# MAIN
# --------------------------------------------------------------

case "$1" in
	--help)
		printf "${0##*/} - Colorize shell [script] output\n\n"
		printf "${0##*/} [--print] [mode [...]] [fg-color] [bg-color]\n"
		printf "${0##*/} --help | --list | --show | --variants\n\n"
	;;
	--list)
   		cl_list
	;;
	--show)
   		cl_show
	;;
	--variants)
		printf "(Re)creating variants file: %s\n" "$CL_DIR_DATA/$CL_FILE_VARIANTS"
		cl_set_variants
		cl_save_variants > "$CL_DIR_DATA/$CL_FILE_VARIANTS"
	;;
	""|off)
		cl $1
	;;
	*)
		if [[ $1 = --print ]]; then
			P_FORMAT="%q\n"
			shift
		else
			P_FORMAT=""
		fi
		if [[ -r $CL_DIR_DATA/$CL_FILE_VARIANTS ]]; then
			. "$CL_DIR_DATA/$CL_FILE_VARIANTS" || exit $?
		else
		   cl_set_variants
		   cl_save_variants > "$CL_DIR_DATA/$CL_FILE_VARIANTS" || exit $?
		fi
		cl "$@"
esac
exit $?

