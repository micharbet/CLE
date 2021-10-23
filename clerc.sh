#!/bin/sh
##
## ** CLE : Command Live Environment **
##
#* author:  Michael Arbet (marbet@redhat.com)
#* home:    https://github.com/micharbet/CLE
#* version: 2021-10-15 (Aquarius)
#* license: GNU GPL v2
#* Copyright (C) 2016-2021 by Michael Arbet

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# CLE provides:
# -improved look&feel: responsive colorful prompt, highlighted exit code
# -persistent alias store - command 'aa'
# -rich history - commands 'h' and 'hh'
# -seamless remote CLE session, with no installation - use 'lssh' instead 'ssh'
# -local live session - lsu/lsudo (su/sudo wrappers)
# -setup from command line, eg. 'cle color RGB'
# -find more using 'cle help' and 'cle doc'
#
# Quick setup:
# 1. Download and execute this file within your shell session
# 2. Integrate it into your profile:
#	$ . clerc
#	$ cle deploy
# 3. Enjoy!

[ -f $HOME/CLEDEBUG ] && { CLE_DEBUG=1; }				# dbg

# Check if the shell is interactive and CLE not yet started
#: required for scp compatibility and also prevents loop upon `cle reload`
[ -t 0 -a -z "$CLE_EXE" ] || dbg_print "Warning! nested CLE start"	# dbg
[ -t 0 -a -z "$CLE_EXE" ] || return

# Now it really starts, warning: magic inside!

#:------------------------------------------------------------:#
# Debugging helpers							# dbg
dbg_print () { [ $CLE_DEBUG ] && echo "DBG: $*" >/dev/tty; }		# dbg
dbg_var () (								# dbg
	eval "V=\$$1"							# dbg
	[ $CLE_DEBUG ] && printf "DBG: %-16s = %s\n" $1 "$V" >/dev/tty	# dbg
)									# dbg
dbg_sleep () { [ $CLE_DEBUG ] && sleep $*; }						# dbg
dbg_print; dbg_print pid:$$						# dbg

#:------------------------------------------------------------:#
# Startup sequence
#: First check how is this script executed
#:  - in case of a shell resource, this will be interactive session,
#:    prepare basic environment variables and do the shell specific tasks
#:  - in case of start as a command, open a shell and push this file
#:    as a resource
#: Then find out suitable shell and use it to run interactive shell session with
#: this file as init resource. The $CLE_RC variable must contain full path!
export CLE_RC
dbg_var CLE_RC
dbg_var CLE_ARG
dbg_var CLE_USER
dbg_var SHELL
dbg_var BASH
_C=$SHELL:$BASH:$0
dbg_print "startup case: '$_C'"
_T=/var/tmp/$USER
case  $_C in
*clerc*|*:*/rc*) # executed as a command from .cle-* directory
	#: IMPORTANT: code in this section must be strictly POSIX compatible with /bin/sh
	dbg_print executing the resource
	CLE_RC=$(cd `dirname $0`;pwd;)/$(basename $0) # full path to this file
	#: process command line options
	#: TODO - check if this is still necessary
	while [ $1 ]; do
		case $1 in
		-m)	CLE_MOTD=`uptime`
			export CLE_MOTD
			;;
		*)	echo "$0: unknown option '$1'"; exit 1;;
		esac
		shift
	done
	export CLE_PROF=1	#: profile files will be executed
	exec bash --rcfile $0
	;;
*bash:*bash) # bash session resource
	dbg_print sourcing to BASH
	CLE_RC=$BASH_SOURCE
	;;
*)	echo "CLE startup failed: 'case $_C'";;
esac

#:------------------------------------------------------------:#
#: Reaching this point means that the script is running
#: as a resource to the interactive session.
dbg_print ---------------
dbg_print Resource starts
dbg_print ---------------

# Use alias built-ins for startup
#: alias & unalias must be available in their natural form during CLE startup
#: and will be redefined at the end of resource
unset -f alias unalias 2>/dev/null
#: remove particular aliases that might be defined e.g. in .bashrc
#: those were causing confilcts, more of them might be added later
unalias aa h hh .. ... 2>/dev/null

# execute script and log its filename into CLE_EXE
# also ensure the script will be executed only once
_clexe () {
	[ -f "$1" ] || return 1
	[[ $CLE_EXE =~ :$1[:$] ]] && return
	CLE_EXE=$CLE_EXE:$1
	dbg_print _clexe $1
	source $1
}
CLE_EXE=$CLE_RC

# Run profile files
#: This must be done now, not later because files may contain confilcting settings.
#: E.g. there might be vte.sh defining own PROMPT_COMMAND and this completely
#: breaks rich history.
dbg_var CLE_PROF
if [ -n "$CLE_PROF" ]; then
	_clexe /etc/profile
	unset CLE_PROF
fi
_clexe $HOME/.bashrc

# Check first run
if [[ $CLE_RC =~ clerc ]]; then
	dbg_print First run
	CLE_DR=$HOME/.cle-`whoami`
	mkdir -m 755 -p $CLE_DR
	CLE_1=$CLE_DR/rc1
	cp $CLE_RC $CLE_1
	chmod 755 $CLE_1
	CLE_RC=$CLE_1
fi

# CLE_RC can be relative path, make it full
CLE_DR=$(cd `dirname $CLE_RC`;pwd;)
CLE_RC=$CLE_DR/`basename $CLE_RC`
dbg_var CLE_RC
dbg_var CLE_DR

# FQDN hack
#: Find the longest - the most complete hostname string.
#: Sometimes information from $HOSTNAME and command `hostname` differs.
#: also 'hostname -f' disabled because it requires working net & DNS!
#:_N=`hostname -f 2>/dev/null`
CLE_FHN=$HOSTNAME
_N=`hostname`
[ ${#CLE_FHN} -lt ${#_N} ] && CLE_FHN=$_N
#: and prepare shortened hostname without top domain, keep other subdomains
CLE_SHN=`sed 's:\.[^.]*\.[^.]*$::' <<<$CLE_FHN`

#: It is also difficult to get local IP addres. There is no simple
#: and multiplattform way to get it. See commands: ip, ifconfig,
#: hostname -i/-I, netstat...
#: Thus, on workstation its just empty string :-( Better than 5 IP's from `hostname -i`
CLE_IP=${CLE_IP:-`cut -d' ' -f3 <<<$SSH_CONNECTION`}

# where in the deep space CLE grows
CLE_VER=`sed -n 's/^#\* version: //p' $CLE_RC`
CLE_REL=`sed -n 's/.*(\(.*\)).*/\1/p' <<<$CLE_VER`
CLE_REL=dev					# REMOVE THIS ON RELEASE!!!!!
CLE_VER="$CLE_VER debug"			# dbg
CLE_SRC=https://raw.githubusercontent.com/micharbet/CLE/$CLE_REL

# find writable folder
#: there can be real situation where a remote account is restricted and have no
#: home folder. In such case CLE can save config and other files into /var/tmp.
#: Note, Live sessions have their respurce files always in /var/tmp/$USER but
#: this must not be writable in subsequent lsu/lsudo sessions.
#:  $CLE_D   is path to writable folder for config, aliases and other runtime files
#:  $CLE_DR  is path to folder containing startup resources
_H=$HOME
[ -w $_H ] || _H=$_T
[ -r $HOME ] || HOME=$_H	#: fix home dir if broken - must be at least readable
dbg_var HOME
[ $PWD = $_T ] && cd		#: go to real home if initiated in temporary home folder
CLE_D=$_H/`sed 's:/.*/\(\..*\)/.*:\1:' <<<$CLE_RC` #: regex cuts anything up to first DOTfolder
dbg_var CLE_D
mkdir -m 755 -p $CLE_D

# config, tweak, etc...
CLE_CF=$CLE_D/cf-$CLE_FHN	#: NFS homes may keep configs for several hosts
CLE_AL=$CLE_D/al
CLE_HIST=$_H/.clehistory
_N=`sed 's:.*/rc1*::' <<<$CLE_RC` #: resource suffix contains workstation name
dbg_print "_N should contain resource suffix. here it is: '$_N'"
CLE_WS=${_N/-/}
CLE_TW=$CLE_DR/tw$_N
CLE_ENV=$CLE_DR/env$_N
CLE_TTY=`tty|tr -d '/dev'`
CLE_XFUN=	#: list of functions for transfer to remote session
PROMPT_DIRTRIM=3

# who I am
#: determine username that will be inherited over the all
#: subsquent sessions initiated with lssh and su* wrappers
#: the regexp extracts username from following patterns:
#: - /any/folder/.cle-username/rcfile
#: - /any/folder/.config/cle-username/rcfile
#: important is the dot (hidden folder), word 'cle' with dash
_N=`sed -n 's;.*cle-\(.*\)/.*;\1;p' <<<$CLE_RC`
export CLE_USER=${CLE_USER:-${_N:-$(whoami)}}
dbg_var CLE_USER

#:------------------------------------------------------------:#
# Internal functions

_clebnr () {
cat <<EOT

$_CC   ___| |     ____| $_CN Command Live Environment activated
$_CB  |     |     __|   $_CN ...bit of life to the command line
$_Cb  |     |     |     $_CN Learn more:$_CL cle help$_CN and$_CL cle doc$_CN
$_Cb$_CD \____|_____|_____| $_CN Uncover the magic:$_CL less $CLE_RC$_CN

EOT
}

# boldprint
_clebold () { printf "$_CL$*$_CN\n";}

# simple question
_cleask () (
	PR="$_CL$* (y/N) $_CN"
	read -n 1 -s -p "$PR"
	echo ${REPLY:=n}
	[ "$REPLY" = "y" ]
)

# Create color table
#: initialize $_C* variables with terminal compatible escape sequences
#: following are basic ones:
_cletable () {
	dbg_print "_cletable updating color table"
	_C_=$TERM	#: save terminal type of this table
	_CN=`tput sgr0`
	_CL=`tput bold`
	_CU=`tput smul`;_Cu=`tput rmul`
	_CV=`tput rev`
	#: Note: dim and italic not available everywhere (e.g. RHEL)
	_CI=`tput sitm`;_Ci=`tput ritm`
	_CD=`tput dim`
	_Ck=$_CN$(tput setaf 0)
	_Cr=$_CN$(tput setaf 1)
	_Cg=$_CN$(tput setaf 2)
	_Cy=$_CN$(tput setaf 3)
	_Cb=$_CN$(tput setaf 4)
	_Cm=$_CN$(tput setaf 5)
	_Cc=$_CN$(tput setaf 6)
	_Cw=$_CN$(tput setaf 7)
	case `tput colors` in
	8)
		_CK=$_Ck$_CL
		_CR=$_Cr$_CL
		_CG=$_Cg$_CL
		_CY=$_Cy$_CL
		_CB=$_Cb$_CL
		_CM=$_Cm$_CL
		_CC=$_Cc$_CL
		_CW=$_Cw$_CL
		;;
	*)
		_CK=$_CN$(tput setaf 8)$_CL
		_CR=$_CN$(tput setaf 9)$_CL
		_CG=$_CN$(tput setaf 10)$_CL
		_CY=$_CN$(tput setaf 11)$_CL
		_CB=$_CN$(tput setaf 12)$_CL
		_CM=$_CN$(tput setaf 13)$_CL
		_CC=$_CN$(tput setaf 14)$_CL
		_CW=$_CN$(tput setaf 15)$_CL
		;;
	esac
	#: and... special color code for error highlight in prompt
	_Ce=$_CR$_CL$_CV #: err highlight
}

# set prompt colors
_cleclr () {
	local C I CI E
	case "$1" in
	red)    C=RrR;;
	green)  C=GgG;;
	yellow) C=YyY;;
	blue)   C=BbB;;
	cyan)   C=CcC;;
	magenta) C=MmM;;
	grey|gray) C=wNW;;
	tricolora) C=RBW;;
	marley) C=RYG;; # Bob Marley style :-) have a smoke and imagine...
	*)	C=$1;; #: any color combination
	esac
	# decode colors and prompt strings
	#: three letters ... dim status part _C0
	#: four letters .... user defined status color
	#: five letters .... also user defined commad highlighting (defauld bold)
	[ ${#C} = 3 ] && C=D${C}L || C=${C}L
	for I in {0..4};do
		eval "CI=\$_C${C:$I:1}"
		# check for exsisting color, ignore 'dim' and 'italic as they might not be defined
		if [[ -z "$CI" && ! ${C:$I:1} =~ [ID] ]]; then
			echo "Wrong color code '${C:$I:1}' in $1" && CI=$_CN
			E=1	#: error flag
		fi
		eval "_C$I=\$CI"
	done
	[ ${C:0:1} = D ] && _C0=$_C1$_CD #: dim color for status part 0
	if [ $E ]; then
		echo "Choose predefined scheme:$_CL"
		declare -f _cleclr|sed -n 's/^[ \t]*(*\(\<[a-z |]*\)).*/ \1/p'|tr -d '\n|'
		printf "\n${_CN}Alternatively create your own 3-5 letter combo using rgbcmykw/RGBCMYKW\n"
		printf "E.g.:$_CL cle color rgB\n"
		_cleclr gray	#: default in case of error
		return 1
	else
		CLE_CLR=${C:0:5}
	fi
}

# CLE prompt escapes
#:  - enhanced prompt escape codes introduced with ^ sign
_clesc () (
	CLESC="
	 -e 's/\^i/\$CLE_IP/g'
	 -e 's/\^h/\$CLE_SHN/g'
	 -e 's/\^H/\$CLE_FHN/g'
	 -e 's/\^U/\$CLE_USER/g'
	 -e 's/\^g/\$(_clegit)/g'
	 -e 's/\^?/\$_EC/g'
	 -e 's/\^E/\\$_PE\$_CE\\$_Pe\[\$_EC\]\\$_PE\$_CN\$_C0\\$_Pe/g'
	 -e 's/\^C\(.\)/\\$_PE\\\$_C\1\\$_Pe/g'
	 -e 's/\^v\([[:alnum:]_]*\)/\1=\$\1/g'
	 -e 's/\^\^/\^/g'
	"
	#: compose substitute command, remove unwanted characters
	SUBS=`tr -d '\n\t' <<<$CLESC`
	eval sed "$SUBS" <<<"$*"
)

_cle_r () {
	[ "$1" != h ] && return
	printf "\n$_Cr     ,==~~-~w^, \n    /#=-.,#####\\ \n .,!. ##########!\n((###,. \`\"#######;."
	printf "\n &######\`..#####;^###)\n$_CW   (@@$_Cr^#############\"\n$_CW"
	printf "    \\@@@\\__,-~-__,\n     \`&@@@@@69@@/\n        ^&@@@@&*\n$_CN\n"
}

# combine default/inherited prompt strings with values from config file
_clepcp () {
	local I
	#: use CLE_PBx
	for I in 0 1 2 3 T; do
		eval "CLE_P$I=\${CLE_PB$I:-\$CLE_P$I}"
		# MAYBE REMOVE THIS [ $1 ] && unset CLE_P{B,Z}$I
	done
}

# craft the prompt from defined strings
_cleps () {
	[ "$CLE_PT" ] && PS1="$_PE\${_CT}$(_clesc $CLE_PT)\${_Ct}$_Pe" || PS1=''
	PS1=$PS1`_clesc "^C0$CLE_P0^C1$CLE_P1^C2$CLE_P2^C3$CLE_P3^CN^C4"`
	PS2=`_clesc "^C3>>> ^CN^C4"`
}

# default prompt strings and colors
_cledefp () {
	CLE_P0='^E \t '
	CLE_P1='\u '
	CLE_P2='^h '
	CLE_P3='\w \$ '
	CLE_PT='\u@^H'
	#: decide by username and if the host is remote
	case "$USER-${CLE_WS#$CLE_FHN}" in
	root-)	_DC=red;;	#: root@workstation
	*-)	_DC=marley;;	#: user's basic color scheme
	root-*)	_DC=RbB;;	#: root@remote
	*-*)	_DC=blue;;	#: user@remote
	esac
}

# save configuration
_clesave () (
	echo "# $CLE_VER"
	_clevdump "CLE_CLR|CLE_PB."
) >$CLE_CF


# prompt callback functions
#: 
#: Important note about code efficiency:
#: As _cleprompt function is executed *every* time you push <enter> key, its code
#: needs to be as simple as possible. All commands here should be internals.
#: Internal commands don't invoke (fork) new processes and as such they
#: are much easier to system resources.
#: E.g. construction `C=${C#*;}` could be written as C=$(sed 's/[^;]*;\(.*\)/\1/' <<<$C)
#: Not only the actually used expression is shorter but also much faster since `sed`
#: would be executed as new process from binary file
#: The same rule applies to CLE internal functions used and called within prompt
#: callback. Namely: `_cleprompt` `_clepreex` `_clerh`
#:
_PST='${PIPESTATUS[@]}'		#: status of all command in pipeline
[ "$BASH_VERSINFO" = 3 ] && _PST='$?' #: RHEL5/bash3 workaround
_cleprompt () {
	eval "_EC=$_PST"
	local IFS S DT C
	dbg_var _HT
	[[ $_EC =~ [1-9] ]] || _EC=0 #: just one zero if all ok
	unset IFS
	C=$_HN	#: already prepared by _clepreex()
	history -a	#: immediately record commands so they are available in new shell sessions
	DT=${C/;*}	#: extract date
	C=${C/$DT;}	#: extract pure command
	if [[ $C =~ ^\# ]]; then
		_clerh '#' "$PWD" "$C"	# record a note to history
	elif [ $_HT ]; then	# check timer - indicator of executed command
		S=$((SECONDS-${_HT:-$SECONDS}))
		_clerh "$DT" $S "$_EC" "$PWD" "$C"
		[ "$_EC" = 0 ] && _CE="" || _CE="$_Ce" #: highlight error code
		_HT=
	else
		_CE=''
		_EC=0 #: reset error code so it doesn not disturb on other prompts
	fi
	trap _clepreex DEBUG
}

CLE_HTF='%F %T'
HISTTIMEFORMAT=${HISTTIMEFORMAT:-$CLE_HTF }	#: keep already tweaked value if exists

#: Bash workaround to Z-shell preexec()function.
#: This fuction is used within prompt calback. Read code efficiency note above!
#: _HP and _HN - previous and next command taken from shell history are compared
#: sequence number have to be cut out as they are not necessarily the same over sessions
history -cr $HISTFILE
_HP=`HISTTIMEFORMAT=";$CLE_HTF;" history 1`	#: prepare history for comaprison
_HP=${_HP#*;}	#: strip sequence number
#: dbg_var _HP
_clepreex () {
	_HN=`HISTTIMEFORMAT=";$CLE_HTF;" history 1`
	_HN=${_HN#*;}	#: strip sequence number
	#dbg_var _HP
	dbg_var _HN
	dbg_var BASH_COMMAND
	echo -n $_CN	#: reset tty colors
	[ "$_HP" = "$_HN" ] && return
	_HP=$_HN
	trap "" DEBUG
	_HT=$SECONDS	#: start history timer $_HT
}

# rich history record
#: This fuction is used within prompt calback. Read code efficiency note above!
_clerh () {
	local DT RC REX ID V VD W
	#: three to five arguments, timestamp and elapsed seconds may be missing
	case $# in
	3)	DT=`date "+$CLE_HTF"`;SC='';;
	4)	DT=`date "+$CLE_HTF"`;SC=$1;shift;;
	5)	DT=$1;SC=$2;shift 2;;
	esac
	#: ignore commands that dont want to be recorded
	REX="^cd\ |^cd$|^-$|^\.\.$|^\.\.\.$|^aa$|^lscreen|^h$|^hh$|^hh\ "
	[[ $3 =~ $REX ]] && return
	#: working dir (substitute home with ~)
	W=${2/$HOME/\~}
	#: create timestamp if missing
	ID="$DT;$CLE_USER-$$"
	REX='^\$[A-Za-z0-9_]+' #: regex to identify simple variables
	case "$3" in
	echo*) #: create special records for `echo $VARIABLE`
		echo -E "$ID;$SC;$1;$W;$3"
		for V in $3; do
			if [[ $V =~ $REX ]]; then
				V=${V/\$/}
				VD=`_clevdump $V`
				echo -E "$ID;;$;;${VD:-unset $V}"
			fi
		done;;
	xx) # directory bookmark
		echo -E "$ID;;*;$W;" ;;
	\#*) #: notes to rich history
		echo -E "$ID;;#;$W;$3" ;;
	*) #: regular commands
		echo -E "$ID;$SC;$1;$W;$3" ;;
	esac
} >>$CLE_HIST


# read inherited environment
[ $CLE_WS ] && _clexe $CLE_ENV

# colorize LS
case $OSTYPE in
linux*)		alias ls='ls --color=auto';;
darwin*)	export CLICOLOR=1; export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd;;
FreeBSD*)       alias ls='ls -G "$@"';;
*)		alias ls='ls -F';; # at least some file type indication
esac

# colorized GREP except on busybox
#: busybox identified by symlinked 'grep' file
if [ -L `command which grep` ];then
	#: Fedora defines this mess :(
	unalias grep egrep fgrep xzgrep xzegrep xzfgrep zgrep zegrep zfgrep 2>/dev/null
else
	alias grep='grep --color=auto'
fi

# Remove alias 'which' if there is no version supporting extended options
#: This weird construction ensures that the 'which' will work even in case
#: there's an alias containing extended options inherited from such workstation
#: E.g. Fedora supports option --read-alias but Debian and BSD do not have this
#: version of 'which' command.
{ alias|command which -i which || unalias which; } >/dev/null 2>&1

## ** cd command enhancements **
## `.. ...`     - up one or two levels
## `-`  (dash)  - cd to recent dir
- () { cd - >/dev/null; _clevdump OLDPWD;}
.. () { cd ..;}
... () { cd ../..;}
## `xx` & `cx`   - bookmark $PWD & use later
xx () { _XX=$PWD; echo path bookmark: $_XX; }
cx () { cd $_XX; }

##
## ** Alias management **
aa () {
	local ATMP=$CLE_AL.tmp
	case "$1" in
	"")	## `aa`         - show aliases
		#: also make the output nicer and more easy to read
		builtin alias|sed "s/^alias \([^=]*\)=\(.*\)/$_CL\1$_CN	\2/";;
	-s)	## `aa -s`      - save aliases
		if [ $CLE_WS ]; then
			#: keep only localy defined aliases on remote sessions
			#: this allows cleanup - alias removed on workstation is not propagated
			grep "^alias " $CLE_ENV >$ATMP
			builtin alias | diff - $ATMP | sed -n 's/^< \(.*\)/\1/p' >$CLE_AL
			rm -f $ATMP
		else
			builtin alias >$CLE_AL
		fi;;
	-e)	## `aa -e`      - edit aliases
		builtin alias >$ATMP
		vi $ATMP
		builtin unalias -a
		. $ATMP
		rm -f $ATMP;;
	*=*)	## `aa a='b'`   - create new alias and save
		builtin alias "$*"
		aa -s;;
	*)	builtin alias "$*";;
	esac
}


##
## ** History tools **
## `h`               - shell 'history' wrapper
h () (
	(HISTTIMEFORMAT=";$CLE_HTF;" history "$@")|( IFS=';'; while read -r N DT C;do
		echo -E "$_CB$N$_Cb $DT $_CN$_CL$C$_CN"
	done;) 
)

## `hh [opt] [srch]` - query the rich history
_RHI=1		#: current index to history
_RHLEN=0	#: max index
hh () {
	local O S N OPTIND MOD OUT
	while getopts "a:mtwsncflbex0123456789" O; do
		case $O in
		a)	## `hh -a string`    - search for any string in history
			S=$S"&&/${OPTARG//\//\\/}/" ;;
		m)	## `hh -m`           - my commands, exclude other users
			S=$S"&& \$2~/$CLE_USER/";;
		[0-9])	## `hh -0..9`        - 0: today's commands, 1: yesterday's, etc.
			S=$S"&& \$1~/$(date -d -${O}days '+%F')/";;
		t)	## `hh -t`           - commands from current session
			S=$S"&& \$2==\"$CLE_USER-$$\"";;
		w)	## `hh -w`           - search for commands issued from current working directory`
			N=${PWD/$HOME/\~}
			S=$S"&& \$5==\"$N\"";;
		s)	## `hh -s`           - select successful commands only
			S=$S"&& \$4==0";;
		n)	## `hh -n`           - narrow output, hide time and session id
			MOD=n;;
		c)	## `hh -c`           - show only commands
			MOD=c;;
		f) 	## `hh -f`           - show working folder history
			MOD=f;;
		b)	## `hh -b`           - show unique commands in buffer
			OUT='>/dev/null';;
		l)	## `hh -l`           - display using 'less'
			OUT='|less -r +G';;
		e)	## `hh -e`           - edit the rich history file
			vi + $CLE_HIST
			return;;
		x)	## `hh -x`           - remove the most recent history record
			# TODO: maybe some args, numbers, etc
			sed -i '$ d' $CLE_HIST
			history -d -2	#: also remove from regular BASH history
			return;;
		*)	cle help hh;return
		esac
	done

	_RHARG=$*
	dbg_var OPTIND
	shift $((OPTIND-1))

	N=+1	#: everything because 'tail -n +1' works like 'cat'
	if [ $* ]; then
		#: select either number of records or search string
		#: replace slashes wit bsckslash-slash for sed with this nice pattern
		[[ $* =~ ^[0-9]+$ ]] && N=$* || S=$S"&& \$4~/[0..9 ]/ &&/.+;.+;.*;.*;.*;.*${*//\//\\/}/"
	else
		#: fallback to 100 records if there is no search expression
		[ "$S" ] || N=100
	fi

	dbg_var OUT
	dbg_var N
	dbg_var S
	#: dbg_sleep 3
	#: AWK script to search and display in rich history file
	local AW='BEGIN { FS=";" }
	//'$S' {	#: search conditions will be added
		#:     update colors according to exit status
		CST=CE; CFL=CN; CCM=CL
		if($4=="0") { CST=CO; CFL=CN; CCM=CL }
		if($4=="#") { CST=CH; CFL=CH; CCM=CH }
		if($4=="@") { CST=CS; CFL=CS; CCM=CS }
		#:     real command can contain semicolon, grab the whole rest of line
		CMD=substr($0,index($0,$6))
		#:     output modifiers
		if(MOD~"n") {
			FORM=CST " %-9s" CFL " %-20s:" CCM " %s\n" CN
			printf FORM,$4,$5,CMD
		}
		else if(MOD~"c") print CMD
		else if(MOD~"f") CMD=$5
		else {
			FORM=CD "%s" CS " %-13s" CD " %5s" CST " %-5s" CFL " %-10s:" CCM " %s\n" CN
			printf FORM,$1,$2,$3,$4,$5,CMD
		}
		if( $4~/^[0-9 ]+$/ ) CMDS[I++]=CMD
	}
	END {	#: now select only unique commands for rich history buffer
		UNIQ="\n"
		while(I-- && N<100 ) { #: maximum records
			C=CMDS[I] "\n"
			if( ! index(UNIQ,"\n" C) ) { UNIQ=UNIQ C; N++ }
		}
		print UNIQ >TREV
	}'

	#: execute filter stream
	local TREV=`mktemp /tmp/clerh.XXXX`
	eval tail -n $N $CLE_HIST \| awk -v CN='$_CN' -v CL='$_CL' -v CD='$_CB' -v CS='$_Cb' -v CO='$_Cg' -v CE='$_Cr' -v CH='$_Cy' -v MOD='$MOD' -v TREV=$TREV '"$AW"' $OUT

	#: fill the rich history buffer
	_RHBUF=() #: array of commands from history
	_RHLEN=0 #: length of the array
	_RHI=0 #: current index to the array
	while read S; do
		[ -n "$S" ] && _RHBUF[$((++_RHLEN))]=$S
	done <$TREV
	dbg_var _RHLEN
	rm -f $TREV
	[ "$OUT" = '>/dev/null' -o "$MOD" = f ] && _clerhbuf
}

# rich history up/down shortcut routines
#: if the current command line contains pure number, use it as an index to history buffer
_clerhdown () {
	[[ $READLINE_LINE =~ ^[0-9]+$ ]] && _RHI=$READLINE_LINE || ((_RHI--))
	[ $_RHI -lt 0 ] && _RHI=0
	READLINE_LINE=${_RHBUF[$_RHI]}
	READLINE_POINT=${#READLINE_LINE}
}

_clerhup () {
	[[ $READLINE_LINE =~ ^[0-9]+$ ]] && _RHI=$READLINE_LINE || ((_RHI++))
	[ $_RHI -gt $_RHLEN ] && _RHI=$_RHLEN
	READLINE_LINE=${_RHBUF[$_RHI]}
	READLINE_POINT=${#READLINE_LINE}
}

#: print out the rich history buffer
_clerhbuf () {
	local A N=$_RHLEN
	while [ $N -ge 1 ]; do
		[ $N -eq $_RHI ] && A='*' || A=' ' #: mark current position in buffer
		printf "$_CN$_CB$A%6d: $_CN$_C4%s\n" $N "${_RHBUF[$N]}"
		((N--))
	done
	echo "$_CN$_C3 $_RHLEN records, search:$_CN$_C4 'hh $_RHARG'"
}

#: keyboard shortcuts to rich history
bind -x '"\ek": "_clerhup"'		#: Alt-K  up in rich history
bind -x '"\ej": "_clerhdown"'		#: Alt-J  down in rich history
bind -x '"\eh": "hh -b $READLINE_LINE"'	#: Alt-H  serach in rich history using content of command line
bind -x '"\el": "_clerhbuf"'		#: Alt-L  list commands from rich history buffer

#: show current working branch
#: define this function only on hosts where git is installed
if which git >/dev/null 2>&1; then
	_clegit () (
		# go down the folder tree and look for .git
		#: Because this function is supposed to use in prompt we want to save
		#: cpu cycles. Do not call `git` if not necessary.
		while [ "$PWD" != / ]; do
			if [ -d .git ]; then
				#: verify dirty status
				git diff-index --quiet HEAD -- && CH="(%s)" || CH="$_CR(%s !)"
				printf "$CH" "$(git symbolic-ref --short HEAD)"
			fi
			cd ..
		done
	)
else
	#: otherwise just an empty one
	_clegit () { return; };
fi


#: Highly sophisticated markdown ascii filter :-D
#: Just replaces special strings in markdown files and augments the output
#: with escape codes to highlight.
#: Not perfect, but it helps and is simple, isn't it?
_clemdf () {
	sed -e "s/^###\(.*\)/$_CL\1$_CN/"\
	 -e "s/^##\( *\)\(.*\)/\1$_CU$_CL\2$_CN/"\
	 -e "s/^#\( *\)\(.*\)/\1$_CL$_CV \2 $_CN/"\
	 -e "s/\*\*\(.*\)\*\*/$_CL\1$_CN/"\
	 -e "s/\<_\(.*\)_\>/$_CU\1$_Cu/g"\
	 -e "s/\`\`\`/$_CD~~~~~~~~~~~~~~~~~$_CN/"\
	 -e "s/\`\([^\`]*\)\`/$_Cg\1$_CN/g" | less -erFX
}

#: dump variables in reusable way
_clevdump () (
	#: awk: 1. exits when reaches functions
	#:      2. finds variables matching regular expression
	declare | awk '/^('$1')=/{print}'
)

#:------------------------------------------------------------:#

##
## ** Live session wrappers **

# Environment packer
#: On workstation do following:
#:  -copy resource file, tweak and selected variables to temporary folder
#: If required for remote session do following:
#:  -pack the folder with tar, and store as base64 encoded string into $C64
#: Always: prepare $RH and $RC for live session wrappers
CLE_XFILES=
_clepak () {
        RH=${CLE_DR/\/.*/}      #: resource home is path until first dot
        RD=${CLE_DR/$RH\//}     #: relative path to resource directory

	dbg_var  RH
	dbg_var RD
	dbg_var CLE_XFILES

        pushd . >/dev/null      #: keep curred working directory while using relative paths
        if [ $CLE_WS ]; then
                #: this is live session, all files *should* be available, just set vars
                cd $RH
                RC=${CLE_RC/$RH\//}
                TW=${CLE_TW/$RH\//}
                EN=${CLE_ENV/$RH\//}
                dbg_print "_clepak: rc already there: $(ls -l $RC)"
        else
                #: live session is to be created - copy startup files
		#: as per issue #78 "/var/tmp mounted noexec"
		#: try to create files at any other place first
                RH=/var/tmp/$USER
                dbg_print "_clepak: preparing $RH/$RD"
                #: by default prepare files in /var/tmp; fall back to the home dir
                mkdir -m 0755 -p $RH/$RD 2>/dev/null && cd $RH || cd
                EN=$RD/env-$CLE_FHN
		#: construct list of files to transfer
		XF=$EN
		for F in $CLE_XFILES tw rc; do
			RC=$RD/$F-$CLE_FHN
			cp $CLE_DR/$F $RC 2>/dev/null && XF="$XF $RC" #: only existing items!
		done
		#: side effect: $RC now contains relative path to clerc file
		dbg_var XF
		dbg_var RC

                #: prepare environment to transfer: color table, prompt settings, WS name and custom exports
                echo "# evironment $CLE_USER@$CLE_FHN" >$EN
                _clevdump "CLE_PB.|^_C." >>$EN
                _clevdump "$CLE_XVARS" >>$EN
                _clevdump "CLE_DEBUG" >>$EN                     # dbg
                cat $CLE_AL >>$EN 2>/dev/null
                #: Add selected functions to transfer
                for XFUN in $CLE_XFUN; do
                        declare -f $XFUN >>$EN
                done
        fi
        #: save the envrironment tarball into $C64 if required
        #: Note: I've never owned this computer, I had Atari 800XL instead :-)
        #: Anyway, the variable name can be considered as a tribute to the venerable 8-bit
        dbg_var PWD
        [ $1 ] && C64=`tar chzf - $XF 2>/dev/null | base64 | tr -d '\n\r '`
	popd >/dev/null
}

## `lssh [usr@]host`   - access remote system and take CLE along
lssh () (
	[ "$1" ] || { cle help lssh;return 1;}
	_clepak tar
	[ $CLE_DEBUG ] && _clebold "C64 contains following:" && echo -n $C64 |base64 -d|tar tzf -			# dbg
	#: remote startup
	#: - create destination folder, unpack tarball and execute the code
	command ssh -t $* "
		#: looking for suitable place in case $HOME is read only or doesn't exist
		for H in \$HOME /var/tmp/\$USER /tmp\$USER; do
			mkdir -m 755 -p \$H/`dirname $RC` && break
		done
		cd \$H
		export CLE_DEBUG='$CLE_DEBUG'	# dbg
		[ \"\$OSTYPE\" = darwin ] && D=D || D=d
		echo $C64|base64 -\$D|tar xzmf -
		exec bash --rcfile \$H/$RC"
		#: it is not possible to use `base64 -\$D <<<$C64|tar xzf -`
		#: systems with 'ash' instead of bash would generate an error (e.g. Asustor)
)

#: Following are su* wrappers
#: TODO: consider how to use _clepak and how to execute the environment with regard to issue #78

## `lsudo [user]`      - sudo wrapper; root is the default account
lsudo () (
	_clepak
	dbg_print "lsudo runs: $RH/$RC"
        sudo -i -u ${1:-root} sh $RH/$RC
)

## `lsu [user]`        - su wrapper
#: known issue - on debian systems controlling terminal is detached in case 
#: a command ($CLE_RC) is specified, use 'lsudo' instead
lsu () (
        _clepak
	S=
        [[ $OSTYPE =~ [Ll]inux ]] && S="-s /bin/sh"
        eval su $S -l ${1:-root} $RH/$RC
)

#:------------------------------------------------------------:#
#: all fuctions declared, startup continues

_clexe $HOME/.cle-local
_clexe $CLE_AL
_clexe $CLE_TW
for _T in $CLE_D/mod-*; do
	_clexe $_T
done

# print MOTD + more
if [ "$CLE_MOTD" ]; then
	[ -f /etc/motd ] && cat /etc/motd
	printf "\n$CLE_MOTD"
	_clebold "\n CLE $CLE_VER\n"
	unset CLE_MOTD
fi

#: Enhnace PATH by user's own bin folders
for _T in $HOME/bin $HOME/.local/bin; do
	[[ -d $_T && ! $PATH =~ $_T ]] && PATH=$PATH:$_T
done

# create the prompt in several steps
# 1. default prompt strings
_cledefp

# 2. override with inherited strings
# MAYBEREMOVETHIS [ $CLE_WS ] && _clepcp x

# 3. create color table if necessary
[ "$TERM" != "$_C_" -o -z "$_CN" ] && _cletable

# 4. get values from config file
_clexe $CLE_CF
_clepcp

# 5. terminal specific
#: $_CT and $_Ct are codes to create window title
#: also in screen the title should be short and obviously no title on text console

case $TERM in
linux)	 CLE_PT='';;	# no tits on console
screen*) CLE_PT='\u'
	printf "\e]0; screen: $CLE_USER@$CLE_FHN$_Ct\007"
	_CT=$'\ek'; _Ct=$'\e\\';;
*)	_CT=$'\e]0;'; _Ct=$'\007';;
esac

# 6. shell specific
#: $_PE nad $_Pe keep strings to enclosing control charaters in prompt
shopt -s checkwinsize
_PE='\['; _Pe='\]'

# 7. craft the prompt string
_cleps
_cleclr ${CLE_CLR:-$_DC}

PROMPT_COMMAND=_cleprompt

# completions
#: Command 'cle' completion
#: as an addition, prompt strings are filled for convenience :)
_clecomp () {
	#: list of subcommands, this might be reworked to have possibility of expansion
	#: with modules (TODO)
	#: 'cle deploy' is hidden intentionaly
	local A=(color p0 p1 p2 p3 cf mod env update reload doc help)
	local C
	COMPREPLY=()
	case $3 in
	p0) COMPREPLY="'$CLE_P0'";;
	p1) COMPREPLY="'$CLE_P1'";;
	p2) COMPREPLY="'$CLE_P2'";;
	p3) COMPREPLY="'$CLE_P3'";;
	#'') COMPREPLY=$A;;
	esac
	[ "$3" != "$1" ] && return
	for C in ${A[@]}; do
		[[ $C =~ ^$2 ]] && COMPREPLY+=($C)
	done
}
complete -F _clecomp cle

# lssh completion
#: there are two possibilities of ssh completion _known_hosts is more common...
declare -F _known_hosts >/dev/null && complete -F _known_hosts lssh
#: while _ssh is better
#: The path is valid at least on fedora and debian with installed bash-completion package
_N=/usr/share/bash-completion
_clexe $_N/bash_completion
_clexe $_N/completions/ssh && complete -F _ssh lssh

# redefine alias builtins
#: those definitions must be here, only after config and tweaks not to mess
#: with builtin shell functions during startup. This also speeds up the thing
alias () {
	[ -n "$1" ] && aa "$@" || builtin alias
}

unalias () {
	[ "$1" = -a ] && cp $CLE_AL $CLE_AL.bk
	builtin unalias "$@"
	aa -s
}

# check manual/initial run
[ $CLE_1 ] && cat <<EOT
 It seems you started CLE running file '$CLE_1'.
 Since this is the first run, consider setup in your profile.
 Run following command to hook CLE into your $HOME/.bashrc:
$_CL    cle deploy
EOT

[ -r . ] || cd #: go home if this is unreadable directory

# record this startup into rich history
_T=${CLE_WS:-WS}
_T=${STY:-$_T}
_T=${TMUX:-$_T}
_clerh @ $CLE_TTY "[$_T $HOME ${CLE_RC/$HOME/\~}]"
[ $CLE_DEBUG ] && _clerh @ $PWD "[version $CLE_VER]"
[ $CLE_DEBUG ] && _C=${CLE_EXE//$HOME/\~}
#: [ $CLE_DEBUG ] && _clerh @ $PWD "[EXE: ${_C//:/ }]"

##
## ** CLE command & control **
cle () {
	local C I P S N
	C=$1;shift
	if declare -f _cle_$C >/dev/null;then #: check if an add-on function exists
		_cle_$C $*
		return $?
	elif [ -f $CLE_D/cle-$C ]; then	#: check module
		. $CLE_D/cle-$C $*
		return $?
	fi
	case $C in
	color)  ## `cle color COLOR`       - set prompt color
		[ $1 ]  && _cleclr $1 && _clesave;;
	p?)	## `cle p0-p3 [str]`       - show/define prompt parts
		I=${C:1:1}
		if [ "$1" ]; then
			#: store the value only if it's different
			#: this is to prevent situation when inherited value is set in configuration
			#: causing to break the inheritance later
			S=$*
			eval "[ \"\$S\" != \"\$CLE_P$I\" ] && { CLE_PB$I='$*';_clepcp;_cleps;_clesave; }" || :
		else
			_clevdump CLE_P$I
		fi;;
	title)	## `cle title off|string`  - turn off window title or set the string
		case "$1" in
		off)	CLE_PT='';;
		'')	_clepcp;;
		*)	cle pT "$*";;
		esac
		_cleps;;
	cf)	## `cle cf [ed|reset|rev]` - view/edit/reset/revert configuration
		case "$1" in
		ed)	vi $CLE_CF  && . $CLE_RC;;
		reset)	mv -f $CLE_CF $CLE_CF-bk;;
		rev)	cp $CLE_CF-bk $CLE_CF;;
		"")
			if [ -f $CLE_CF ]; then
				_clebold $_CU$CLE_CF:
				cat $CLE_CF
			else
				echo Default/Inherited configuration
			fi
			return;;
		esac
		cle reload;;
	deploy) ## `cle deploy`            - hook CLE into user's profile
		P=$HOME/.cle-$USER	#: new directory for CLE
		mkdir -p $P
		cp $CLE_RC $P/rc
		CLE_RC=$P/rc
		unset CLE_1
		I='# Command Live Environment'
		S=$HOME/.${SHELL##*/}rc	#: hook into user's login shell rc
		grep -A1 "$I" $S && _clebold CLE is already hooked in $S && return 1
		_cleask "Do you want to add CLE to $S?" || return
		echo -e "\n$I\n[ -f $CLE_RC ] && . $CLE_RC\n" | tee -a $S
		cle reload;;
	update) ## `cle update [master]`   - install fresh version of CLE
		N=$CLE_D/rc.new
		#: update by default from the own branch
		#: master brach or other can be specified in parameter
		curl -k ${CLE_SRC/$CLE_REL/${1:-$CLE_REL}}/clerc >$N #: use different branch if specified
		#: check correct download and its version
		S=`sed -n 's/^#\* version: //p' $N`
		[ "$S" ] || { echo "Download error"; return 1; }
		echo current: $CLE_VER
		echo "new:     $S"
		diff $CLE_RC $N >/dev/null && { echo No difference; return 1;}
		_cleask Do you want to install new version? || return
		#: now replace CLE code
		cp $CLE_RC $CLE_D/rc.bk
		chmod 755 $N
		mv -f $N $CLE_RC
		cle reload
		#: update modules if necessary
		N=cle-mod
		[ -f "$CLE_D/$N" ] || return
		echo updating modules
		curl -k $CLE_SRC/modules/$N >$CLE_D/$N && cle mod update
		;;
	reload) ## `cle reload           ` - reload CLE
		unset CLE_EXE
		. $CLE_RC && echo CLE reloaded: $CLE_RC $CLE_VER;;
	mod)    ## `cle mod`               - cle module management
		#: this is just a fallback to initialize modularity
		#: downloaded cle-mod overrides this code
		_cleask Activate CLE modules? || return
		N=cle-mod
		P=$CLE_D/$N
		curl -k $CLE_SRC/modules/$N >$P
		grep -q "# .* $N:" $P || { _clebold Module download failed; rm -f $P; return 1;}
		cle mod "$@";;
	env)	## `cle env`               - inspect variables
		_clevdump 'CLE.*'|awk -F= "{printf \"$_CL%-12s$_CN%s\n\",\$1,\$2}";;
	ls)	_clebold CLE_D: $CLE_D; ls -l $CLE_D; _clebold CLE_DR: $CLE_DR; ls -l $CLE_DR;;	# dbg
	exe)	echo $CLE_EXE|tr : \\n;;							# dbg
	debug)	case $1 in									# dbg
		"")	dbg_var CLE_DEBUG ;;							# dbg
		off)	CLE_DEBUG=''								# dbg
			rm ~/CLEDEBUG;;								# dbg
		*)	CLE_DEBUG=on								# dbg
			touch ~/CLEDEBUG;;							# dbg
		esac;;										# dbg
	help|-h|--help) ## `cle help [fnc]`        - show help
		#: double hash denotes help content
		P=`ls $CLE_D/cle-* 2>/dev/null`
		awk -F# "/\s##\s*.*$@|^##\s*.*$@/ { print \$3 }" ${CLE_EXE//:/ } $P | _clemdf;;
	doc)	## `cle doc`               - show documentation
		#: obtain index of doc files
		I=`curl -sk $CLE_SRC/doc/index.md`
		#: $I - index must contain word LICENSE - part of doc files
		[[ $I =~ LICENSE ]] || { echo Unable to get documentation;return 1;}
		#: choose one to read
		PS3="$_CL doc # $_CN"
		select N in $I;do
			[ $N ] && curl -sk $CLE_SRC/doc/$N |_clemdf; break
		done;;
	"")	#: do nothing, just show off
		_clebnr
		sed -n 's/^#\*\(.*\)/\1/p' $CLE_RC #: print lines starting with '#*' - header
		;;
	*)	echo unimplemented function: cle $C;
		echo check cle help;
		return 1
		;;
	esac
}

#: final cleanup
unset _T _H _C _N _DC

# that's all, folks...

