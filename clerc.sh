#!/usr/bin/env bash
##
## ** CLE : Command Live Environment **
##
#* author:  Michael Arbet (marbet@redhat.com)
#* home:    https://github.com/micharbet/CLE
#* version: 2024-06-11 (Aquarius)
#* license: MIT
#* Copyright (C) 2016-2024 by Michael Arbet

# CLE provides:
# -improved look&feel: responsive colorful prompt, highlighted exit code
# -persistent alias store - command 'aa'
# -rich history - commands 'h' and 'hh'
# -seamless remote CLE session, with no installation - use 'lssh' instead 'ssh'
# -local live session - lsu/lsudo (su/sudo wrappers)
# -setup from command line, eg. 'cle color RGB'
# -documentation available with 'cle help' and 'cle doc'
#
# Quick setup:
# 1. Download and execute this file within your shell session
# 2. Integrate into your profile:
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
dbg_print () { [ $CLE_DEBUG ] && echo "$_CN$_CD DBG: $*$_CN" >/dev/tty; }	# dbg
dbg_var () (								# dbg
	V=${!1}								# dbg
	[ $CLE_DEBUG ] && printf "$_CN$_CD DBG: %-16s = %s\n" $1 "$V$_CN" >/dev/tty	# dbg
)									# dbg
dbg_sleep () { [ $CLE_DEBUG ] && sleep $*; }				# dbg
dbg_print; dbg_print pid:$$						# dbg

#:------------------------------------------------------------:#
# Startup sequence
#: First check how is this script executed
#:  - if started as a command, re-execute bash and push this file as a resource
#:    This happens when run for the frst time and may happen in live sessions
#:  - if running as a shell resource, this means an interactive session,
#:    prepare the whole live environment
#: Then find out suitable shell and use it to run interactive shell session with
#: this file as init resource. The $CLE_RC variable must contain full path!
export CLE_RC
dbg_var CLE_RC
dbg_var CLE_ARG
dbg_var CLE_USER
dbg_var SHELL
dbg_var BASH
dbg_var BASH_SOURCE
dbg_print "startup case: '$SHELL:$0'"
case "$SHELL:$0" in
*clerc*|*:*/rc*) # executed as a command
	dbg_print executing the resource
	#: process command line options
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
*sh:*bash) # bash session resource
	dbg_print sourcing to BASH
	CLE_RC=$BASH_SOURCE
	;;
*)	echo "CLE startup failed";;
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
#: remove particular aliases that might be already defined e.g. in .bashrc
#: those were causing confilcts
unalias aa h hh .. ... 2>/dev/null

# execute script and log its filename into CLE_EXE
#: also ensure the script will be executed only once
#: always use function _clexe to execute particular files
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
	CLE_1=$CLE_DR/rc1	#: rc1 is used not to disrupt already installed environment if it exists
	cp $CLE_RC $CLE_1
	chmod 755 $CLE_1
	CLE_RC=$CLE_1
fi

#: CLE_RC can be relative path, convert to full
CLE_DR=$(cd ${CLE_RC%/*};pwd;)
CLE_RC=$CLE_DR/${CLE_RC##*/}
dbg_var CLE_RC
dbg_var CLE_DR

# FQDN hack
#: Find the longest - the most complete hostname string. Best effort.
#: Sometimes information from $HOSTNAME and command `hostname` differs.
#: also 'hostname -f' isn't used as it requires flawlessly configured 
#: networking and DNS
CLE_FHN=$HOSTNAME
_N=`hostname`
[ ${#CLE_FHN} -lt ${#_N} ] && CLE_FHN=$_N
#: now prepare shortened hostname by stripping top domain and keep the rest subdomains
CLE_SHN=${CLE_FHN%.*.*}

#: It is also difficult to get local IP addres. There is no simple
#: and multiplattform way to get it. See commands: ip, ifconfig,
#: hostname -i/-I, netstat...
#: Thus, on workstation its just empty string :-( Better than 5 IP's from `hostname -i`
_N=${SSH_CONNECTION% *}; CLE_IP=${_N##* }

# where in the deep space CLE grows
#: can't find better/faster method than 'sed'
CLE_VER=`sed -n 's/^#\* version: //p' $CLE_RC`
_N=${CLE_VER%)*}; CLE_REL=${_N#* (}
dbg_var CLE_REL
CLE_REL=dev					# REMOVE THIS ON RELEASE!!!!!
CLE_VER="$CLE_VER debug"			# dbg
CLE_SRC=https://raw.githubusercontent.com/micharbet/CLE/$CLE_REL

# find writable folder
#: there can be real situation where a remote account is restricted and have no
#: home folder. In such case CLE can save config and other files into /var/tmp.
#: Note, Live sessions have their resource files always in /var/tmp/$USER but
#: this must not be writable in subsequent lsu/lsudo sessions.
#:  $CLE_D   is path to writable folder for config, aliases and other runtime files
#:  $CLE_DR  is path to folder containing startup resources
_T=/var/tmp/$USER
_H=$HOME
[ -w $_H ] || _H=$_T
[ -r $HOME ] || HOME=$_H	#: fix home dir if broken - must be at least readable
dbg_var HOME
[ $PWD = $_T ] && cd		#: go to real home if initiated in temporary home folder
_N=.${CLE_RC#*.}		#: get the first DOTfolder (it can be .cle-name or .config/cle-name)
CLE_D=$_H/${_N%/*}		#: and use as writable path
dbg_var CLE_D
mkdir -m 755 -p $CLE_D

# config, tweak, etc...
CLE_CF=$CLE_D/cf-$CLE_FHN	#: NFS homes may keep configs for several hosts
#: TODO: allow to use global $CLE_D/cf even in NFSed environment like e.g. sdf
CLE_AL=$CLE_D/al
CLE_HIST=$_H/.clehistory
#: determine if CLE is running in a workstation mode (initial login)
#: or if it's a live session
#: Variable $CLE_WS is empty in the first case otherwice contains workstation's FQDN
#: and this is used as a suffix to inherited resource files (e.g. rc-workstation.name)
CLE_WS=${CLE_RC#$CLE_DR/rc}
CLE_TW=$CLE_DR/tw$CLE_WS
CLE_ENV=$CLE_DR/env$CLE_WS

# who I am
#: determine username that will be inherited over the all subsquent live sessions
#: extract the username from folder name .../.cle-USER/...
_N=${CLE_RC#*cle-}; _N=${_N%/rc*}
dbg_print "found username _N=$_N"
dbg_print "current CLE_USER=$CLE_USER"
export CLE_USER=${CLE_USER:-${_N:-$(whoami)}}
dbg_print "  final CLE_USER=$CLE_USER"

#:------------------------------------------------------------:#
# Internal functions

_clebnr () {
cat <<EOT

$_CC   ___| |     ____| $_CN     Command Live Environment
$_CB  |     |     __|   $_CN brings life to the command line!
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
#: use them with enhanced prompt definition as "^C*"
#: Note: toe ensure wide compatibility, a tput command is used. There are
#: however systems that do not contain it. To avoid errors at least basic
#: colors are defined directly with escape codes.
_cletable () {
	dbg_print "_cletable updating color table"
	_C_=$TERM	#: save terminal type of this table
	_Cn=$'\E[0m' #: for use inside prompt, may get additional color codes
	_CN=`tput sgr0`; _CN=${_CN:-$_Cn}
	_CL=`tput bold`; _CL=${_CL:-$'\E[1m'}
	_CU=`tput smul`;_Cu=`tput rmul`
	_CV=`tput rev`
	#: Note: dim and italic not available everywhere (e.g. RHEL)
	_CI=`tput sitm`;_Ci=`tput ritm`
	_CD=`tput dim`
	_Ck=$(tput setaf 0); _Ck=${_Ck:-$'\E[30m'}
	_Cr=$(tput setaf 1); _Cr=${_Cr:-$'\E[31m'}
	_Cg=$(tput setaf 2); _Cg=${_Cg:-$'\E[32m'}
	_Cy=$(tput setaf 3); _Cy=${_Cy:-$'\E[33m'}
	_Cb=$(tput setaf 4); _Cb=${_Cb:-$'\E[34m'}
	_Cm=$(tput setaf 5); _Cm=${_Cm:-$'\E[35m'}
	_Cc=$(tput setaf 6); _Cc=${_Cc:-$'\E[36m'}
	_Cw=$(tput setaf 7); _Cw=${_Cw:-$'\E[37m'}
	case `tput colors` in
	8|'')
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
		_CK=$(tput setaf 8)$_CL
		_CR=$(tput setaf 9)$_CL
		_CG=$(tput setaf 10)$_CL
		_CY=$(tput setaf 11)$_CL
		_CB=$(tput setaf 12)$_CL
		_CM=$(tput setaf 13)$_CL
		_CC=$(tput setaf 14)$_CL
		_CW=$(tput setaf 15)$_CL
		;;
	esac
	#: and... special color code for error highlight in prompt
	_Ce=$_CR$_CL #: err highlight
} 2>/dev/null

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
	#: three letters ... colors for p1-p3
	#: four letters .... fourth letter defines command color instead of bold
	#[ ${#C} = 3 ] && C=D${C}L || C=${C}L
	C=x${C}L	#: x - index shifter; L -  default bold for command itself
	for I in {1..4};do
		eval "CI=\$_C${C:$I:1}"
		# check for exsisting color, ignore if 'dim' and 'italic' are empty
		if [[ -z "$CI" && ! ${C:$I:1} =~ [ID] ]]; then
			echo "Wrong color code '${C:$I:1}' in $1" && CI=$_CN
			E=1	#: error flag
		fi
		eval "_C$I=\$CI"
	done
	_C5=$_C2$_CD	#: dim color for status
	if [ $E ]; then
		printf "Choose a predefined scheme: "
		declare -f _cleclr|sed -n 's/^[ \t]*(*\(\<[a-z |]*\)).*/ \1/p'|tr -d '\n|'
		printf "\nAlternatively create your own 3 or 4 letter combo using rgbcmykw/RGBCMYKW\n"
		printf " e.g.:$_CL cle color rgB\n"
		_cleclr gray	#: default in case of error
		return 1
	else
		CLE_PC=${C:1:4}
	fi
}

# CLE prompt escapes
#:  - enhanced prompt escape codes introduced with ^ sign
_clesc () (
	dbg_print ' _clesc'
	#: cannot add notes to relevant lines, they would break sed expressions. So...
	#: ^i       ... remote IP address
	#: ^h       ... shortened hostname
	#: ^H       ... FQDN (if could be obtained)
	#: ^s       ... elapsed seconds of recent command 
	#: ^tNUMBER ... threshold for displaying afterexec marker
	#: ^g       ... git branch and status
	#: ^?, ^e   ... return (error code)
	#: ^E       ... return code in square brackets, highlighted red if non zero
	#: ^Cx      ... change text color, x=one-letter-code
	#: ^vVAR    ... display variable name and value
	#: ^^       ... caret itself
	sed \
	 -e 's/\^i/\${CLE_IP}/g'\
	 -e 's/\^h/\${CLE_SHN}/g'\
	 -e 's/\^H/\${CLE_FHN}/g'\
	 -e 's/\^U/\${CLE_USER}/g'\
	 -e 's/\^s/\${_SEC}/g'\
	 -e 's/\^t[0-9]*//g'\
	 -e 's/\^g/\\[${_GITC}\\]${_GITB}/g'\
	 -e 's/\^[?e]/\${_EC}/g'\
	 -e 's/\^E/\\[\${_CE}\\](\${_EC})\\[\${_Cn}\${_C1}\\]/g'\
	 -e 's/\^C\([0-9]\)/\\[${_Cn}${_C\1}\\]/g'\
	 -e 's/\^C\(.\)/\\[${_C\1}\\]/g'\
	 -e 's/\^v\([[:alnum:]_]*\)/\1=\${\1}/g'\
	 -e 's/\^\^/\^/g'\
	<<<"$*"
)

_cle_r () {
	[ "$1" != h ] && return
	printf "\n$_Cr     ,~~---~^^, \n    /@=-. ##_##\\ \n .,(. ##########)\n(@###,. \`\"######@^."
	printf "\n \`@#####\`..#####\`,###)\n$_CW   (@@$_Cr^#############\"\n$_CW"
	printf "    \\@@@\\__,-~-__,\n     \`@@@@@@69@@/\n        *&@@@@&*\n$_CN\n"
}

# craft prompts from defined strings
_cleps () {
	dbg_print ' _cleps'
	local PT PA PB
	[ "$_ST" ] && PT=$_ST || PT=${CLE_PT:-$_PT}	#: _ST - shortened title for screen and tmux
	PA=${CLE_PA:-$_PA}
	PB=${CLE_PB:-$_PB}
	[ "$PT" ] && PS1="\\[\${_CT}$(_clesc $PT)\${_Ct}\\]" || PS1=''
	PS1=$PS1`_clesc "^CN^C1${CLE_P1:-$_P1}^CN^C2${CLE_P2:-$_P2}^CN^C3${CLE_P3:-$_P3}^CN^C4"`
	PS2=`_clesc "^C3>>> ^CN^C4"`
	[ "$PB" ] && PSB=`_clesc "^CN^C5$PB"`			#: PSB - before execution marker
	[ "$PA" ] && {
		PSA=`_clesc "^CN^CA$PA"`			#: PSA - after execution marker
		[ $BASH_VERSINFO -lt 5 ] && PSA=$(sed -e 's/\\.//g' -e 's/"/\\"/g' <<<"$PSA")
		PT=`sed -n 's/.*\^t\([0-9]*\).*/\1/p' <<<$PA`	#: search if afterexec threshold is defined
	}
	CLE_PAT=${PT:-0}	#: set afterexec prompt threshold
}

# default prompt strings and colors
#: Those defaults are get overridden on remote sessions through $CLE_ENV file
_cledefp () {
	_P1='\u '
	_P2='^h '
	_P3='\w \$ '
	_PB=
	_PA='-<(^e)>-'	#: the eye :-D
	_PT='\u@^H'
	#: decide color by username and if the host is remote
	case "$USER@$CLE_WS" in
	root@)	_DC=red;;	#: root@workstation
	*@)	_DC=marley;;	#: user's basic color scheme
	root@*)	_DC=RbB;;	#: root@remote
	*@*)	_DC=blue;;	#: user@remote
	esac
}

# save configuration
_clesave () (
	echo "# $CLE_VER"
	_clevdump CLE_P.
) >$CLE_CF

# prompt callback functions
#: 
#: Important note about code efficiency:
#: The _cleprompt function is executed *every* time you push <enter> key
#: so its code needs to be as simple as possible. All commands here should
#: ideally be bash internals. They don't invoke (fork) new processes and
#: as such they are much easier to system resources.
#: E.g. instead of C=$(sed 's/[^;]*;\(.*\)/\1/' <<<$C) we use `C=${C#*;}` 
#: Not only the latter expression is shorter but also much faster since `sed`
#: would be executed as new process from binary file
#: The same rule applies to CLE internal functions used and called within
#: prompt callback. Namely: `_cleprompt` `_clepreex` `_clerh`
#:
_PST='${PIPESTATUS[@]}'		#: status of all command in pipeline
[ "$BASH_VERSINFO" = 3 ] && _PST='$?' #: bash3 workaround
_TIM=				#: empty timer indicates no command has been issued
_cleprompt () {
	eval "_EC=$_PST"
	_EC=${_EC// /-}
	if [ "$_TIM" ]; then	# check if a command was issued
		[[ $_EC =~ [1-9] ]] && _CE=$_Ce || { _EC=0; _CE=; }	#: error code highlight
		_CA=${_CE:-$_C5}					#: afterexec marker color
		dbg_print "$_C5>>>>  End of command output  '$_CMD' <<<<$_CN"
		_SEC=$((SECONDS-_TIM))
		[[ $PS1 =~ _GIT ]] && _clegit
		history -a	#: immediately record commands so they are available in new shell sessions
		#: printout afterexecution marker
		if [ "$PSA" ] && [ $_SEC -ge "$CLE_PAT" -o "$_EC" != 0 ]; then
			#: decide if prompt expansion can be used (bash v5 and later)
			[ $BASH_VERSINFO -ge 5 ] && echo "${PSA@P}" || eval "echo \"$PSA\""
		fi
		 _clerh "$_DT" $_SEC "$_EC" "$PWD" "$_CMD"
	else
		#: no command issued
		#: reset error code and color so it doesn not disturb on later prompts
		_CE=
		_EC=0
	fi
	_TIM=
	trap _clepreex DEBUG
}

CLE_HTF='%F %T'
HISTTIMEFORMAT=${HISTTIMEFORMAT:-$CLE_HTF }	#: keep already tweaked value if exists

#: Bash workaround to Z-shell preexec()function.
#: This fuction is used within prompt calback. Read code efficiency note above!
history -cr $HISTFILE
_clepreex () {
	trap "" DEBUG
	_HR=`HISTTIMEFORMAT=";$CLE_HTF;" history 1` #: get new history record
	_HR=${_HR#*;}		#: strip sequence number
	_DT=${_HR/;*}		#: extract date and time
	_CMD=${_HR/$_DT;}	#: extract pure command
	dbg_print "${_CN}_clepreex: BASH_COMMAND = '$BASH_COMMAND'"
	dbg_print "${_CN}_clepreex:          _HR = '$_HR'"
	dbg_print "${_CN}_clepreex:         _CMD = '$_CMD'"

	if [ "$BASH_COMMAND" = "_cleprompt" ]; then
		[[ $_CMD =~ ^\# ]] && _clerh '#' "$PWD" "$_CMD"	#: record a note to history
	else
		[ "$_ST" ] && _SC=${_CMD:0:15} || _SC=${_CMD:0:99}	#: shorten command to display in terminal title
		[ "$_PT" ] && printf "$_CT%s$_Ct" "$_SC"		#: show executed command in the title
		[ "$PSB" ] && { [ $BASH_VERSINFO -ge 5 ] && echo "${PSB@P}" || eval "echo \"$PSB\""; }	#: display beforexec marker if defined
		dbg_print "$_C5>>>> Start of command output '$_CMD' -> '$BASH_COMMAND' <<<<$_CN"
		_TIM=$SECONDS	#: start history timer $_TIM
		echo -n $_CN	#: reset tty colors after prompt
	fi
}

# rich history record
#: This fuction is used within prompt calback. Read code efficiency note above!
_CPR=	#: previously recorded command
_clerh () {
	local DT RC REX ID V VD W
	#: three to five arguments, timestamp and elapsed seconds may be missing
	dbg_print "_clerh $# arguments: '$@'"
	case $# in
		#: here is an exception, calling the 'date' binary
		#: but only in special cases when no real command was executed
		#: means - not a big overhead
	3)	DT=`date "+$CLE_HTF"`;SC='';;
	4)	DT=`date "+$CLE_HTF"`;SC=$1;shift;;
	5)	DT=$1;SC=$2;shift 2;;
	esac
	#: ignore commands that dont want to be recorded
	REX="^cd\ |^cd$|^-$|^\.\.$|^\.\.\.$|^aa$|^lscreen|^h$|^hh$|^hh\ "
	[[ $3 =~ $REX ]] && return
	#: ignore repeating commands
	[ "$3" = "$_CPR" ] && return	#: do not record repeating items
	dbg_print "_clerh(): Cmd='$3' PrevCmd='$_CPR'"
	_CPR=$3
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
		dbg_print "directory bookmark: $PWD;"
		echo -E "$ID;;*;$PWD;" ;;
	\#*) #: notes to rich history
		dbg_print "note: $ID;;#;$W;$3"
		echo -E "$ID;;#;$W;$3" ;;
	*) #: regular commands
		dbg_print "regular command record: $ID;$SC;$1;$W;$3" 
		echo -E "$ID;$SC;$1;$W;$3" ;;
	esac
} >>$CLE_HIST


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
	local O S N D C OPTIND MOD OUT
	#: process commandline options into variables:
	#: $S   .. awk search string is composed out of comandline options
	#: $D   .. days condition set is separate, there are 'or' inside
	#: $MOD .. output modifers
	while getopts "a:mtwsncflbex0123456789" O; do
		case $O in
		t)	## `hh -t`           - commands from current session
			S=$S"&& \$2==\"^$CLE_USER-$$\"";;
		w)	## `hh -w`           - search for commands issued from current working directory`
			N=${PWD/$HOME/\~}
			S=$S"&& \$5==\"$N\"";;
		m)	## `hh -m`           - my commands, exclude other users
			S=$S"&& \$2~/^$CLE_USER-/";;
		[0-9])	## `hh -0..9`        - 0: today's commands, 1: yesterday's, etc.
			C="\$1~/$(date -d -${O}days '+%F')/"	#: one day condition
			[ "$D" ] && D="$D || $C" || D="$C";;	#: add to days 'or' condition set
		a)	## `hh -a string`    - search for any string in history
			S=$S"&&/${OPTARG//\//\\/}/" ;;
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
			# TODO: maybe... number of lines to remove ev. string? Or add enhanced functionality to a module?
			sed -i '$ d' $CLE_HIST
			history -d -2	#: also remove from regular BASH history
			return;;
		*)	cle help hh;return
		esac
	done
	S=$S"${D:+&& ( $D )}"		#: add days 'or' conditions (if any) to the serach string

	_RHARG="$*"	#: save the search arguments for future reference
	# dbg_var OPTIND
	shift $((OPTIND-1))

	N=+1	#: 'tail -n +1' works like 'cat'
	if [ "$*" ]; then
		#: select either number of records or compose search string
		[[ $* =~ ^[0-9]+$ ]] && N=$* || {
			C=${*//\//\\/}		#: replace slashes wit bsckslash-slash for awk with this nice pattern
			C=${C/ /\\ }
			S=$S"&& \$4~/[0..9 ]/ && /.+;.+;.*;.*;.*;.*$C/"
		}
	else
		#: fallback to 100 records if there is no search expression
		[ "$S" ] || N=100
	fi

	dbg_var OUT
	dbg_var N
	dbg_var S
	#: dbg_sleep 3
	#: AWK script to search and display in rich history file
	local AW='
	BEGIN {
		FS=";"
		#: simplest way of use defined colors I found so far
		CN="'$_CN'"
		CL="'$_CL'"
		CD="'$_CD'"
		CG="'$_CG'"
		CR="'$_CR'"
		Cy="'$_Cy'"
		Cb="'$_Cb'"
		CB="'$_CB'"
	}
	//'$S' {	#: search conditions will be pushed here from shell variable $S
		CMD=substr($0,index($0,$6))	#: real command can contain semicolon, grab the whole rest of line
		#:     update colors according to status in $4
		CST=CR; CFL=CN; CCM=CL
		if($4=="0") { CST=CG; CFL=CN; CCM=CL }
		if($4=="#" || $4=="$") { CST=Cy; CFL=Cy; CCM=Cy }
		if($4=="*") { CST=Cy; CFL=Cy; CCM=Cy; CMD="cd "$5 }
		if($4=="@") { CST=Cb; CFL=Cb; CCM=Cb }
		if($3!="") { ET=$3 "\"" } else { ET="" }
		#:     output modifiers
		if(MOD~"n") {
			FORM=CST "%-9s" CFL " %-25s:" CCM " %s\n" CN
			printf FORM,$4,$5,CMD
		}
		else if(MOD~"c") print CMD
		else if(MOD~"f") CMD=$5
		else {
			FORM=CB CD "%s" CN Cb CD" %-13s" CN CD " %6s" CN CST " %-5s" CFL " %-13s:" CCM " %s\n" CN
			printf FORM,$1,$2,ET,$4,$5,CMD
		}
		if( $4~/^[0-9 *]+$/ ) CMDS[I++]=CMD
	}
	END {	#: now select only unique commands for rich history buffer
		UNIQ="\n"
		while(I-- && N<100 ) { #: maximum records
			C=CMDS[I] "\n"
			if( ! index(UNIQ,"\n" C) ) { UNIQ=UNIQ C; N++ }
		}
		print UNIQ >REVB
	}'

	#: execute filter stream
	local REVB=`mktemp clerh.XXXXXX`	#: reverse history buffer
	eval tail -n $N $CLE_HIST \| awk -v MOD='$MOD' -v REVB=$REVB '"$AW"' $OUT

	#: fill the rich history buffer
	_RHBUF=() #: array of commands from history
	_RHLEN=0 #: length of the array
	_RHI=0 #: current index to the array
	while read -r S; do		#: RAW read with -r !!!
		[ -n "$S" ] && _RHBUF[$((++_RHLEN))]=$S
	done <$REVB
	rm -f $REVB
	dbg_var _RHLEN
	[ "$OUT" = '>/dev/null' -o "$MOD" = f ] && _clerhbuf
	[ $_RHLEN != 0 ] 	#: return error code if nothing has been found
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
	echo "$_CN$_CD $_RHLEN records ${_RHARG:+'hh $_RHARG'}"
}

#: keyboard shortcuts to rich history
bind -x '"\ek": "_clerhup"'		#: Alt-K  up in rich history
bind -x '"\ej": "_clerhdown"'		#: Alt-J  down in rich history
bind -x '"\eh": "hh -b $READLINE_LINE"'	#: Alt-H  serach in rich history using content of command line
bind -x '"\el": "_clerhbuf"'		#: Alt-L  list commands from rich history buffer

#: show current working branch
#: define this function only on hosts where git is installed
if which git >/dev/null 2>&1; then
	_clegit () {
		# go down the folder tree and look for .git
		#: Because this function is supposed to use in prompt we want to save
		#: cpu cycles. Do not call `git` if not necessary.
		local D=$PWD
		_GITC=
		_GITB=
		while [ "$D" != '' ]; do
			if [ -d $D/.git ]; then
				#: verify dirty status
				git diff-index --quiet HEAD -- || _GITC=$_Cr
				printf -v _GITB $'\ue0a0'%s "$(git symbolic-ref --short HEAD)"
			fi
			D=${D%/*}
		done
	}
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
CLE_XFUN=	#: list of functions for transfer to remote session
CLE_XFILES=	#: list of fies to takeaway
_clepak () {
	RH=${CLE_DR/\/.*/}      #: resource home is path until first dot
	RD=${CLE_DR/$RH\//}     #: relative path to resource directory
	dbg_var RH
	dbg_var RD
	dbg_var CLE_XFILES

	pushd . >/dev/null      #: keep curred working directory while using relative paths
	if [ $CLE_WS ]; then
		#: this is live session, all files *should* be available, just set vars
		cd $RH
		RC=${CLE_RC/$RH\//}
		XF=`ls $RD/*$CLE_WS`
	else
		#: Live session is to be prepared - copy startup files
		#: First prepare temporary folder
		#: TODO: consider issue #78 - /var/tmp mounted noexec - this may cause troubles
		#:       IDEA: use configurable variable ?
		for RH in /var/tmp /tmp /home; do
			dbg_print "_clepak: preparing $RH/$RD"
			mkdir -m 0755 -p $RH/$RD 2>/dev/null && break
		done
		cd $RH
		#: prepare environment file to transfer: color table, prompt settings, WS name
		#: aliases and custom variables (CLE_XVARS)
		EN=$RD/env-$CLE_FHN	#: Workstation's environmen file
		{
			echo "# evironment $CLE_USER@$CLE_FHN"
			echo "CLE_SESSION=$1"
			_clevdump "CLE_P.|^_C." | sed 's/^CLE_P\(.\)/_P\1/' #: translate _Px to CLE_Px
			_clevdump "$CLE_XVARS"
			#: exclude aliases from transfer based on comma separated list in CLE_EXALIAL
			#: - some aliases are just incompatible and other systems may define weird ones like
			#:   for example Feodra's x/z/grep variants do not work on BusyBox)
			#: - A user may want to keep some aliases on workstation only
			#: Example of use: CLE_EXALIAS=grep,vi,which.*
			XAL=${CLE_EXALIAS:-^$}
			grep -v "${XAL//,/=\\|}=" $CLE_AL 2>/dev/null
			#: Add selected functions to transfer
			for XFUN in $CLE_XFUN; do
				declare -f $XFUN
			done
			_clevdump "CLE_DEBUG"			# dbg
		} >$EN
		XF="$EN"
		#: copy files to takeaway temporary folder and add them, to the list
		#: add also custom files (CLE_XFILES)
		#: takeaway filenames are enhanced with worksation's name - $CLE_FHN
		#: NOTE: currently all takeaway files must be in cle folder
		#: TODO: think about other locations, ev. symlinks
		for F in $CLE_XFILES tw rc; do		#: 'rc' must be the ast item!
			RC=$RD/$F-$CLE_FHN
			cp $CLE_DR/$F $RC 2>/dev/null && XF="$XF $RC" #: only existing items!
		done
		#: side effect: $RC now contains relative path to clerc file
	fi
	#: store the envrironment as base64 encoded tarball into $C64 if required
	#: otherwise files are ready in $RD folder for local sessions and their list
	#; is in $RCLIST
	#: Note: I've never owned this computer, I had Atari 800XL instead :-)
	#: Anyway, the variable name can be considered as a tribute to the venerable 8-bit
	dbg_var PWD
	dbg_var XF
	dbg_var RC
	[ "$1" = lssh ] && C64=`tar chzf - $XF 2>/dev/null | base64 | tr -d '\n\r '`
	popd >/dev/null
}

#: pre and after live session helpers
_cleprelife () {
	[ -n "$CLE_PRELIFE" ] && eval $CLE_PRELIFE
}

_cleafterlife () {
	_EX=$?		#: save exit code of the live seeion
	tput reset	#: reset terminal and colors
	[ -f $CLE_D/mod-palette ] && . $CLE_D/mod-palette
	[ -n "$CLE_AFTERLIFE" ] && eval $CLE_AFTERLIFE
}

## `lssh [usr@]host`   - access remote system and run CLE
lssh () (
	[ "$1" ] || { cle help lssh;return 1;}
	_cleprelife lssh "$@"
	_clepak lssh
	[ $CLE_DEBUG ] && _clebold "C64 contains following:" && echo -n $C64 |base64 -d|tar tzf -			# dbg
	#: remote startup
	#: - create destination folder, unpack tarball and execute the code
	command ssh -t $* "
		#: looking for suitable place in case $HOME is read only or doesn't exist
		for H in \$HOME /var/tmp/\$USER /tmp/\$USER; do
			mkdir -m 755 -p \$H/${RC%/*} && break
		done
		cd \$H
		export CLE_DEBUG='$CLE_DEBUG'	# dbg
		[ \"\$OSTYPE\" = darwin ] && D=D || D=d
		echo $C64|base64 -\$D|tar xzmf - 2>/dev/null
		exec bash --rcfile \$H/$RC"
		#: it is not possible to use `base64 -\$D <<<$C64|tar xzf -`
		#: systems with 'ash' instead of bash would generate an error (e.g. Asustor)
	_cleafterlife lssh "$@"
	return $_EX
)

#: Following are su* wrappers
#: TODO: consider how to use _clepak and how to execute the environment with regard to issue #78

## `lsudo [user]`      - sudo wrapper; root is the default account
lsudo () (
	_cleprelife lsudo "$@"
	_clepak $CLE_SESSION:lsudo
	dbg_print "lsudo runs: $RH/$RC"
        sudo -i -u ${1:-root} $RH/$RC
	#: save exit code and eventually execute a code after live session
	_cleafterlife lsudo "$@"
	return $_EX
)

## `lsu [user]`        - su wrapper
#: known issue - on debian systems controlling terminal is detached in case 
#: a command ($CLE_RC) is specified, use 'lsudo' instead
lsu () (
	_cleprelife lsu "$@"
        _clepak $CLE_SESSION:lsu
	S=
        [[ $OSTYPE =~ [Ll]inux ]] && S="-s /bin/sh"
        eval su $S -l ${1:-root} $RH/$RC
	#: save exit code and eventually execute a code after live session
	_cleafterlife lsu "$@"
	return $_EX
)

#:------------------------------------------------------------:#
#: all fuctions declared, startup continues

# print MOTD + more
if [ "$CLE_MOTD" ]; then
	[ -f /etc/motd ] && cat /etc/motd
	printf "\n$CLE_MOTD"
	_clebold "\n CLE $CLE_VER\n"
	unset CLE_MOTD
fi

PROMPT_DIRTRIM=3 #: can be overridden in tweak file
# Enhnace PATH
for _T in $HOME/bin $HOME/.local/bin; do
	[[ -d $_T && ! $PATH =~ $_T ]] && PATH=$PATH:$_T
done

_cledefp	#: prompt defaults

# execute modules, tweaks and aliases
for _T in $CLE_D/mod-*; do
	_clexe $_T
done
_clexe $HOME/.cle-local
_clexe $CLE_TW

CLE_SESSION=$CLE_RC
[ $CLE_WS ] && _clexe $CLE_ENV

#: A few pre-defined aliases that may override alias definitions inherited from
#: the workstation. This is here for compatibility reasons. Some systems define 
#: for example --color=auto which does not work on others. Generally bash and
#: coreutils have more options than BSD or even BusyBox 
#: Otherwise the CLE does not contain too much customized aliases and functions
#: in order not to mess with the user's habits

# OS dependent colorized LS and GREP
case $OSTYPE in
linux*)		alias ls='ls --color=auto';;
darwin*)	export CLICOLOR=1; export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd;;
FreeBSD*)	alias ls='ls -G "$@"';;
*)		alias ls='ls -F';; # at least some file type indication
esac

#: busybox identified by symlinked 'grep' file
if [ -L `command which grep` ];then
	#: Fedora defines this mess :(
	unalias grep egrep fgrep xzgrep xzegrep xzfgrep zgrep zegrep zfgrep 2>/dev/null
else
	alias grep='grep --color=auto'
fi

#: now read local alias file where more custom aliases may be stored
_clexe $CLE_AL

#: override defaults with values from config file
_clexe $CLE_CF

#: terminal specific stuff
[ "$TERM" != "$_C_" -o -z "$_CN" ] && _cletable	# create color table if necessary
_CT=$'\e]0;'; _Ct=$'\007'	#: generic titling escapes
case $TERM in
linux)	 CLE_PT='';;	#: no tits on text console
screen*) printf "$_CT screen: $CLE_USER@$CLE_SHN$_Ct"	#: set main screen  title
	_ST='\u'			#: titles inside the screen should be short
	_CT=$'\ek'; _Ct=$'\e\\';;	#: screen's specific codes to set internal title
#: TODO: add tmux options
esac

# craft the prompt
_cleps
_cleclr ${CLE_PC:-$_DC}
PROMPT_COMMAND=_cleprompt

# completions
#: Command 'cle' completion
#: as an addition, prompt strings are filled for convenience :)
_clecomp () {
	#: list of subcommands, this might be reworked to have possibility of expansion
	#: with modules (TODO)
	#: 'cle deploy' is hidden intentionaly
	local A=(color p1 p2 p3 pb pa pt cf mod env update reload doc help)
	local F= #: PLACEHOLDER for _cle_* functions
	local E= #: PLACEHOLDER for cle-* modules
	local C
	COMPREPLY=()
	case $3 in
	p1) COMPREPLY="'${CLE_P1:-$_P1}'";;
	p2) COMPREPLY="'${CLE_P2:-$_P2}'";;
	p3) COMPREPLY="'${CLE_P3:-$_P3}'";;
	pb) COMPREPLY="'${CLE_PB:-$_PB}'";;
	pa) COMPREPLY="'${CLE_PA:-$_PA}'";;
	pt) COMPREPLY="'${CLE_PT:-$_PT}'";;
	color) COMPREPLY="'$CLE_PC'";;
	# '') COMPREPLY=$A;;	#:  TODO remove if not necessary
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
#: while _comp_cmd_ssh is better
#: The path is valid at least on fedora and debian with installed bash-completion package
_N=/usr/share/bash-completion
_clexe $_N/bash_completion
_clexe $_N/completions/ssh && complete -F _comp_cmd_ssh lssh

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
_T=${TMUX:+tmux:$TMUX}
_T=${_T:-${STY:+screen:$STY}}
_T=${_T:-${SSH_CLIENT:+ssh:${SSH_CLIENT%% *}}}
_T=${_T:-$CLE_SESSION}
_clerh @ ${CLE_WS:-WS} "[$_T]"
_clerh @ $SHELL "$BASH_VERSION, $CLE_VER"

##
## ** CLE command & control **
cle () {
	local C I P S N
	C=$1;shift      #: subcommand; now $@ contains the rest of command line
	if declare -f _cle_$C >/dev/null;then #: check if an add-on function _cle_*() exists
		_cle_$C $*
		return $?
	elif [ -f $CLE_D/cle-$C ]; then #: alternatively check if module cle-* exists
		. $CLE_D/cle-$C $*
		return $?
	fi
	#: fallback to built-in options
	case $C in
	color)  ## `cle color COLOR`       - set prompt color
		[ $1 ]  && _cleclr $1 && _clesave;;
	p?)	## `cle pX [str]`          - show/define prompt parts
		I=${C:1:1}; I=${I^}
		case "$1" in
		'')	_clevdump CLE_P$I;;
		' ')	unset CLE_P$I;;
		*)	S=$*
			#eval "[ \"\$S\" != \"\$_P$I\" ] && { CLE_P$I='$*';_clepcp;_cleps;_clesave; }" || :
			eval "CLE_P$I='$*'";;
		esac
		_cleps;_clesave
		;;
	cf)	## `cle cf [ed|reset|rev]` - view/edit/reset/revert configuration
		case "$1" in
		ed)	vi $CLE_CF  && . $CLE_RC;;
		reset)	mv -f $CLE_CF $CLE_CF-bk;;
		rev)	cp $CLE_CF-bk $CLE_CF;;
		"")
			_clebold "$_CU Default/Inherited configuration:"
			_clevdump _P. CLE_PC
			if [ -f $CLE_CF ]; then
				_clebold "$_CU$CLE_CF":
				cat $CLE_CF
			fi
			return;;
		*)	return;;
		esac
		cle reload;;
	deploy) ## `cle deploy`            - hook CLE into user's profile
		P=$HOME/.cle-$USER	#: new directory for CLE
		mkdir -p $P
		cp $CLE_RC $P/rc
		CLE_RC=$P/rc
		unset CLE_1
		I='# Command Live Environment'
		S=$HOME/.bashrc	#: hook into user's login shell rc
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
	ls)	_clebold CLE_D: $CLE_D; ls -l $CLE_D					# dbg
	       	if [ $CLE_D != $CLE_DR ]; then						# dbg
			_clebold CLE_DR: $CLE_DR					# dbg
			ls -l $CLE_DR							# dbg
		else									# dbg
			_clebold CLE_DR: same as above					# dbg
		fi;;									# dbg
	exe)	echo $CLE_EXE|tr : \\n;;						# dbg
	debug)	case $1 in								# dbg
		"")	dbg_var CLE_DEBUG ;;						# dbg
		off)	CLE_DEBUG=''							# dbg
			rm ~/CLEDEBUG;;							# dbg
		*)	CLE_DEBUG=on							# dbg
			touch ~/CLEDEBUG;;						# dbg
		esac;;									# dbg
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

