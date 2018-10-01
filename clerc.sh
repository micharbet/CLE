#!/usr/bin/env bash
#
## ** CLE : Command Live Environment **
#
#* author:  Michael Arbet (marbet@redhat.com)
#* home:    https://github.com/micharbet/CLE
#* version: 2018-09-30 (Nova)
#* license: GNU GPL v2
#* Copyright (C) 2016-2018 by Michael Arbet 
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# CLE provides:
# -a colorful prompt with highlighted exit code
# -persistent alias store with command 'aa'
# -rich command history using new command 'h' and 'hh'
# -seamless remote CLE session using 'lssh' command, with no installation
# -lsu/lsudo (su/sudo wrappers) with the same effect on localhost
# -work in gnu screen using 'lscreen'
# -connamd 'cle' with bash completion to alter settings
# -integrated documentation: 'cle help' and 'cle doc'
# -extensible framework enabling modules and further tweaks
# -online updates
#
# Installation:
# 1. Download and execute this file within your shell session
# 2. Integrate it into your profile:
#	$ . clerc
#	$ cle deploy
# 3. Enjoy!

#: If you're reading this text, you probably downloaded commented version
#: of CLE named ;clerc.sh' This is basically fine as the code is the same
#: however contains extended comments introduce with '#:' plus debugging
#: sequences. For this, th file is much longer. For general use there is
#: shortened file with removed unnecessary parts.
#: Note also other special comments - '##' denotes built-in documentation
#: while '#*' introduces header lines

# Check if the shell is running as an interactive session otherwise CLE is
# not needed. This is required for scp compatibility
#: Note: scp is sensitive to unexpected strings printed on stdout,
#: that means you should avoid printing anything unnecessary onto
#: non interactive sessions.
if [ -t 0 -a -z "$CLE_EXE" -a -z "$BASH_EXECUTION_STRING" ];then
# Now it really starts, warning: magic inside!

# debug stuff
[ -f $HOME/NOCLE ] && { PS1="[NOCLE] $PS1"; return; }  # debug
[ -f $HOME/CLEDEBUG ] && { CLE_DEBUG=1; echo CLE DEBUG ON; }
dbg_var () { [ $CLE_DEBUG ] && printf "%-16s = %s\n" $1 "${!1}" >/dev/tty; }
dbg_echo () { [ $CLE_DEBUG ] && echo "$*" >/dev/tty; }

# a little bit complicated way to find the absolute path
#: cross-plattform compatible way to determine absolute path to rc file
export CLE_RC=${BASH_SOURCE[0]}
CLE_RD=$(cd `dirname $CLE_RC`;pwd;)
CLE_RC=$CLE_RD/`basename $CLE_RC`

dbg_echo "-- preexec --"
dbg_echo '$0  = '$0
dbg_echo '$1  = '$1
dbg_var BASH_SOURCE[0]
dbg_var CLE_RC

#: check -m option to display /etc/motd
#: there might be more options in future and this simple check will
#: be replaced with 'getopts' then
[ "$1" = '-m' ] && export CLE_MOTD=`uptime`

# ensure bash session will be sourced with this rcfile
#: CLE can be executed as a regular script but such it would just exit without
#: effect. Following code recognizes this condition and re-executes bash with
#: the same file as resource script
[[ $0 =~ bash || $0 = -su ]] || exec /usr/bin/env bash --rcfile $CLE_RC
dbg_echo "-- afterexec --"
dbg_echo CLE resource init begins!

# execute script and log its filename into CLE_EXE
# also ensure the script will be executed only once
_clexe () {
	dbg_echo clexe $*
	[ -f "$1" ] || return 1
	[[ $CLE_EXE =~ :$1[:$] ]] && return
	CLE_EXE=$CLE_EXE:$1
	. $1
}
CLE_EXE=$CLE_RC

#: Run profile files as soon as possible.
#: Things in /etc/profile.d can override some settings.
#: E.g. there might be vte.sh defining own PROMPT_COMMAND and this completely
#: breaks rich history.
#: Also alias & unalias must be available as builtins in this phase
unset alias unalias
_clexe /etc/profile
_clexe $HOME/.bashrc
#: ...also thinking how important is to run .profile or .bash_profile

# who I am
#: determine username that will be inherited over the all
#: subsquent sessions initiated with lssh and su* wrappers
#: the regexp extracts username from following patterns:
#: - /any/folder/.cle-username/rcfile
#: - /any/folder/.config/cle-username/rcfile
#: - /any/folder/.config/cle/username/rcfile
#: important is the dot (hidden folder), word 'cle' and darh or slash
_N=`sed -n 's;.*cle[/-]\(.*\)/.*;\1;p' <<<$CLE_RC`
export CLE_USER=${CLE_USER:-${_N:-$USER}}
dbg_var CLE_USER

# short hostname: remove domain, leave subdomains
CLE_SHN=`hostname|sed 's;\.[^.]*\.[^.]*$;;'`
CLE_IP=`cut -d' ' -f3 <<<$SSH_CONNECTION`

# where in the deep space CLE grows
CLE_SRC=https://raw.githubusercontent.com/micharbet/CLE
CLE_VER=`sed -n 's/^#\* version: //p' $CLE_RC`
CLE_REL=`sed 's/.*(\(.*\)).*/\1/' <<<$CLE_VER`
CLE_VER="$CLE_VER debug"

# check first run
#: prepare environment if CLE has been initiated manually from downloaded file
if [[ $CLE_RC =~ /clerc ]]; then
	#: CLE_1 indicates first run (downloaded file started from comandline)
	#: 'rc1' prevents accidental overwrite of deployed environment
	CLE_RD=$HOME/.cle-$CLE_USER
	CLE_1=$CLE_RD/rc1
	mkdir -m 755 -p $CLE_RD
	cp $CLE_RC $CLE_1
	chmod 755 $CLE_1
	CLE_RC=$CLE_1
	dbg_echo First run, changing some values:
	dbg_var CLE_RC
fi

dbg_var CLE_RD
dbg_var CLE_RC

# find writable folder
#: there can be real situation where a remote account is restricted and have no
#: home folder. In such case CLE can be started from /tmp. Also, after su*
#: wrapper the folder containing main resource file can be and usually will be
#: in different place than current home.
#: Simply to say, this sequence ensures customized configuration for every
#: account accessed with CLE.
[ -w $HOME ] || { HOME=/tmp/$USER; echo Temporary home: $HOME; }
CLE_D=$HOME/`sed 's:/.*/\(\..*\)/.*:\1:' <<<$CLE_RC`
CLE_CF=$CLE_D/cf
mkdir -m 755 -p $CLE_D

# tweak and alias files have same suffix as rc
_I=`sed 's:.*/rc::' <<<$CLE_RC`
CLE_TW=$CLE_RD/tw$_I
CLE_ALW=$CLE_RD/al$_I
CLE_WS=${_I:1}	#: remove first character that might be '1' or '-'

# color table
#: initialize $_C* variables with terminal compatible escape sequences
#: following are basic ones:
_CN=`tput sgr0`
_CL=`tput bold`
_CU=`tput smul`;_Cu=`tput rmul`
_CD=`tput dim`
_CV=`tput rev`
#: The loop creates table of color codes r, g, b...
#: lower case is for dim variant, upper case stands for bright
#: try e.g 'echo $_Cg green $_CY bright yellow'
_I=0; for _N in k r g y b m c w; do
        _C=`tput setaf $_I`
        declare _C$_N=$_CN$_C
        declare _C$(tr a-z A-Z <<<$_N)=$_CL$_C
        ((_I+=1))
done
#: and... special color code for error highlight in prompt
_Ce=`tput setab 1;tput setaf 7` # err highlight


# boldprint
printb () { printf "$_CL$*$_CN\n";}

# simple question
ask () {
	read -p "$_CL$* (y/N) $_CN" -n 1 -s
	echo ${REPLY:=n}
	[ "$REPLY" = "y" ]
}

# banner
_banner () {
cat <<EOT

   ___| |     ____|  Command Live Environment activated
  |     |     __|    ...bit of life to the command line
  |     |     |      Learn more:$_CL cle help$_CN and$_CL cle doc$_CN
 \____|_____|_____|  Uncover the magic:$_CL less $CLE_RC$_CN
 
EOT
}

# default config
_defcf () {
	case $USER@$CLE_WS in
	root@)	CLE_CLR=red;;	#: root on workstation
	root@*) CLE_CLR=RbB;;	#: root on remote session
	*@) CLE_CLR=marley;;	#: user on workstation
	*@*) CLE_CLR=blue;;	#: user on remote session
	esac
	CLE_P0='%e \A'
	CLE_P1='\u'
	CLE_P2='%h'
	CLE_P3='\w \$'
}

# save configuration
_savecf () {
	cat <<-EOC
	# $CLE_USER $CLE_VER
	CLE_CLR=$CLE_CLR
	CLE_P0='$CLE_P0'
	CLE_P1='$CLE_P1'
	CLE_P2='$CLE_P2'
	CLE_P3='$CLE_P3'
	EOC
} >$CLE_CF

_cle_r () {
	[ "$1" != h ] && return
	printf "\n$_Cr     ,==~~-~w^, \n    /#=-.,#####\\ \n .,!. ##########!\n((###,. \`\"#######;."
	printf "\n &######\`..#####;^###)\n$_CW   (&@$_Cr^#############\"\n$_CW"
	printf "    \`&&@\\__,-~-__,\n     \`&@@@@@69@&'\n        '&&@@@&'\n$_CN\n"
}

# CLE prompt escapes
#: library of enhanced prompt escape codes
#: they are introduced with % sign
_clesc () (
	C=_C$1
	P=CLE_P$1
	printf "\\[\$$C\\]"
	sed <<<${!P}\
	 -e "s/%i/$CLE_IP/g"\
	 -e "s/%h/$CLE_SHN/g"\
	 -e "s/%u/$CLE_USER/g"\
	 -e "s/%e/\\\[\$_CE\\\][\$_E]\\\[\$_CN\$$C\\\]/g"\
	 -e "s/%c\(.\)/\\\[\\\$_C\1\\\]/g"\
	 -e "s/%v\([[:alnum:]]*\)/\1=\$\1/g"
)

# prompt composer
#: This is what you see...
#: compile PS1 string from values in $CLE_COLOR and $CLE_Px
#: Note how this function is self-documented!
_setp () {
	local CC I CI C
	C=${1:-$CLE_CLR}
	case "$C" in 
	red)	CC=RrR;;
	green)	CC=GgG;;
	yellow)	CC=YyY;;
	blue)	CC=BbB;;
	cyan)	CC=CcC;;
	magenta) CC=MmM;;
	white|grey|gray) CC=NwW;;
	tricolora) CC=RBW;;
	marley)	CC=RYG;; # Bob Marley style :-) have a smoke and imagine...
	???)	CC=$C;; # any 3 colors
	*)	# print help on colors
		printb "Unknown color '$CLE_CLR' Select predefined scheme:"
		declare -f _setp|sed -n 's/\(\<[a-z |]*\)).*/\1/p' 
		echo Alternatively create your own 3-letter combo using rgbcmykw/RGBCMYKW
		echo E.g. cle color rgB
		return 1
	esac
	# decode colors and prompt strings
	CC=K$CC
	PS1=""
	for I in {0..3};do
		CI=_C${CC:$I:1}
		[ -z "${!CI}" ] && printb "Wrong color code '${CC:$I:1}' in $C" && CI=_CN
		eval _C$I="'${!CI}'"
		PS1="$PS1`_clesc $I` "
	done
	PS1="$PS1\[\$_CN\]"
	PS2="\[\$_C1\] >>>\[\$_CN\] "
	_savecf
}

# prompt callback
#: As _prompt function is executed *every* time you push enter key its code
#: should be as simple as possible. In best case all commands here should be
#: bash internals. Those don't invoke new processes and as such they are much
#: easier to system resources.
_prompt () {
	_E=$? # save return code
	local N D T C OI=$IFS
	# highlight error code
	[ $_E = 0 ] && _CE="" || _CE="$_Ce"
	# window title & screen name
	[ "$CLE_WT" ] && printf "\033]0;$CLE_WT $PWD\007"
	[[ $TERM =~ screen ]] && echo -en "\ek$USER\e\\"
	# rich history
	history -a
	_H=`history 1`
	unset IFS
	if [ "$_H" != "$_HO"  -a -n "$_HO" ];then
		{ read -r N D T C; echo "$D $T $CLE_USER-$$ $_E $PWD $C" >>$CLE_HIST;} <<<$_H
	fi
	_HO=$_H
	IFS=$OI
}
PROMPT_DIRTRIM=2
PROMPT_COMMAND=_prompt
shopt -s checkwinsize


# window title
#: This is simple window title composer
#: By 'simple' I mean it should be much improved in next version. Ideas:
#: -compose full WT string into the variable and simplyfy corresponding part
#:  in _prompt function
#: -make decision based on different environments (shell window, text console,
#:  screen session, maybe termux, etc...)
_setwt () {
	CLE_WT=''
	[[ $TERM =~ linux ]] && return # no tits on console
	[[ $CLE_RC =~ remote ]] && CLE_WT="$CLE_USER -> "
	CLE_WT=$CLE_WT$USER@$CLE_SHN-$TTY
}

# markdown filter
#: "Highly sophisticated" highlighter :-D
#: Just replaces special strings in markdown files and augments the output
#: with escape codes to highlight.
#: Not perfect, but it helps and is simple, isn't it?
mdfilter () {
	sed -e "s/^###\(.*\)/$_CL\1$_CN/"\
	 -e "s/^##\( *\)\(.*\)/\1$_CU$_CL\2$_CN/"\
	 -e "s/^#\( *\)\(.*\)/\1$_CL$_CV \2 $_CN/"\
	 -e "s/\*\*\(.*\)\*\*/$_CL\1$_CN/"\
	 -e "s/\<_\(.*\)_\>/$_CU\1$_Cu/g"\
	 -e "s/\`\`\`/$_CD~~~~~~~~~~~~~~~~~$_CN/"\
	 -e "s/\`\([^\`]*\)\`/$_Cg\1$_CN/g"
}


#: CLE defines just basic aliases
#: Previously there were bunch of them, just because I liked e.g. various
#: 'ls' variants. However it revealed to be pushy and intrusive. Moreover
#: they all were enclosed in a function rendering default aliases difficult
#: to redefine.

# first load aliases inherited from CLE workstation
#: On workstation: ensure executing aliases only once
#: On live sessions: read inherited aliases first, allow redefining locally
CLE_AL=$CLE_D/al # this account's alias store
[ $CLE_AL != $CLE_ALW ] && _clexe $CLE_ALW

# colorize ls
case $OSTYPE in
linux*)		alias ls='ls --color=auto';;
darwin*)	export CLICOLOR=1; export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd;;
FreeBSD*)	alias ls='ls -G "$@"';;
*)		alias ls='ls -F';; # at least some file type indication
esac

# colorized grep except on busybox
#: busybox identified by symlinked 'grep' file
if [ -L `command which grep` ];then
	#: Fedora defines this mess :(
	unalias grep egrep fgrep xzgrep xzegrep xzfgrep zgrep zegrep zfgrep
else
	alias grep='grep --color=auto'
fi

# Remove alias 'which' if there is no version supporting extended options
#: This weird construction ensures the 'which' will work even in case an
#: aliased version with extended options (e.g. --read-alias on Fedora) was
#: defined on workstation and copied to remote session  
{ alias|command which -i which || unalias which; } >/dev/null 2>&1

#: transition - remove aliases defined in previous versions
unalias .. ... xx cx >/dev/null 2>&1 # transition

#: Those are just nice and I believe don't hurt :)
## ** cd command additions **
## `.. ...`     - up one or two levels
## `-`  (dash)  - cd to recent dir
- () { cd -;}
.. () { cd ..;}
... () { cd ../..;}
## `xx` & `cx`   - bookmark $PWD & use later
xx () { _XX=$PWD; echo path bookmark: $_XX; }
cx () { cd $_XX; }
#: Attempt to search for commands 'xx' and 'cx' on internet failed so I think
#: it's safe to use them.


##
## ** Alias management **
aa () {
	local AED=$CLE_AL.ed
	case "$1" in
	"")	## `aa`         - show aliases
		#: also meke the output nicer and more easy to read
                builtin alias|sed "s/^alias \(.*\)='\(.*\)'/$_CL\1$_CN	\2/";;
	-s)	## `aa -s`      - save aliases
		builtin alias >$CLE_AL;;
	-e)	## `aa -e`      - edit aliases
		builtin alias >$AED
		vi $AED
		builtin unalias -a
		. $AED;;
	*=*)	## `aa a='b'`   - create new alias and save
		builtin alias "$*"
		aa -s;;
	*)	cle help aa
		return 1
	esac
}

##
## ** History tools **
#: Following settings should not be edited, nor tweaked in other files.
#: Mainly $HISTTIMEFORMAT - the rich history feature is dependent on it!
HISTFILE=$HOME/.history-$CLE_USER
[ -f $HISTFILE ] || cp $HOME/.bash_history $HISTFILE 2>/dev/null
HISTCONTROL=ignoredups
HISTTIMEFORMAT="%Y-%m-%d %T "
CLE_HIST=$HOME/.history-ALL

## `h`               - bash 'history' wrapper
h () (
	history "$@"|while read N D T C;do
		echo "$_CB$N$_Cb $D $T $_CN$_CL$C$_CN"
	done
)

## `hh [opt] [srch]` - rich history viewer
#: Rich history viewer is a stream of filters
#: 1 - selects history records based on search criteria
#: 2 - extracts required information from selected lines
#: 3 - output (directly to stdout or to 'less')
#: The code is ...i'd say ugly, to be honest
#: Oh yeah, it's horrible code, I'll definitely rewrite it!
hh () (
	unset IFS	#: necessary if user manipulates with IFS value
	while getopts "cstdlf" O;do
		case $O in
		s) ONLY0=1;; ## `hh -s`           - print successful commands only
		c) ONLYC=1;; ## `hh -c`           - show just commands
		d) THIS=`date +%Y-%m-%d`;; ## `hh -d`           - today's commands
		t) THIS=$CLE_USER-$$;; ## `hh -t`           - commands from current session
		f) FMODE=1;NUM=0;OUTF="sort|uniq";; ## `hh -f`           - show working folder history
		l) NUM=0; OUTF="less -r +G";; ## `hh -l`           - show history with 'less'
		\?) cle help hh;return
	esac;done
	shift $((OPTIND-1))
	F1=${*:-${NUM:-100}}	## `hh [opt]`        - no search; print recent 100 items
	#:
	#: Filter #1 (search by options  -t -d and/or string)
	grep -w "$THIS" $CLE_HIST | case $F1 in  #FILTER1 (search)
	0)	## `hh [opt] 0`      - print all
		cat;;
	[1-9]|[1-9][0-9]|[1-9][0-9][0-9])
		## `hh [opt] number` - find last N entries
		tail -$F1;;
	*)	## `hh [opt] string` - search in history
		grep "$*"
	esac | while read -r D T U E P C;do #FILTER2 (format)
	 #:
	 #: Filter #2:
	 #:  - process option -f (visited folders)
	 if [ $FMODE ]; then
		[[ $P =~ ^/ ]] && echo $P
		continue
	 fi
	 #:  - process option -s (show only succeccsul commands)
	 [ $E != 0 -a "$ONLY0" ] && continue
	 #:  - colorize return code
	 case $E in
	 0)	EE=$_Cg;;
	 @)	EE=$_Cc;;
	 *)	EE=$_Cr
	 esac
	 #:  - hihglight commeted-out lines
	 [[ "$C" =~ ^# ]] && { E='#';EE=$_Cy;C=$_Cy$C$_CN;}
	 #:  - process option -c (otuput just command without other info)
	 [ "$ONLYC" ] && { [ $E = @ ] || echo $C;} ||\
		echo "$_Cb$D $T $_CB$U $EE$E $_CN$P $_CL$C$_CN"
	done | eval "${OUTF:-cat}" #FILTER3 (output)
)


# rich history record
#: used to record session init into rich history
_rhlog () {
	date "+$HISTTIMEFORMAT$CLE_USER-$$ @ $TTY [$*]" >>$CLE_HIST
}

##
## ** Live session wrappers **

# environment packer
#: grab *active* resource file, tweak file, pack it to tarball and store
#: into variable C64 as base64 encoded string.
#: Argument ($1) may contain additional suffix to filenames
#: Second outcome of _clepak is value in $RC - relative path to the resource 
#: file that should be run on remote system (it may contain the suffix)
#: Note: configuration is not packed in order to ensure unique cf on all
#:  remote accounts.
#: Note 2: _clepak is defined with curly brackets {} to pass variables RC and C64
#:  On the other side lssh is defined with () ensuring execution in its own context
#:  where all new variables are local only to lssh (and _clepak)
#: Note 3: _clepak is fuction even if it is used only once and could be
#:  included directly into lssh. However, this allows to create any other
#:  remote access wrapper
_clepak () {
	#: anything up to first dotted folder is home for .cle folder
	cd `sed 's:\(/.*\)/\..*:\1:' <<<$CLE_RC`
	RC=${CLE_RC/$PWD\//}
	TW=${CLE_TW/$PWD\//}
	AL=${CLE_ALW/$PWD\//}
	if [ $1 ];then
		#: change names and copy files when adding suffix
		#: this happens when doing lssh (from CLE ws)
		RC=$RC$1; TW=$TW$1; AL=$AL$1
		cp $CLE_RC $RC
		cp $CLE_TW $TW 2>/dev/null
		cp $CLE_AL $AL 2>/dev/null
	fi
	RCS="$RC $TW $AL"
	dbg_var PWD
	dbg_var RCS
	#:  I've never owned this computer, I had Atari 800XL :)
	C64=`tar chzf - $RCS 2>/dev/null | base64 | tr -d '\n\r '`
}

## `lssh [usr@]host`   - access remote system and take CLE along
lssh () (
	[ "$1" ] || { cle help lssh;return 1;}
	#: on CLE workstation, suffix to resource filename is added
	#: this 1. prevents overwriting on destination accounts
	#:  and 2. provides information about source of the session
	S= #: resource suffix is empty on remote sessions...
	[ $CLE_WS ] || S=-$CLE_SHN #: adding suffix when running on WS
	_clepak $S
	[ $CLE_DEBUG ] && echo -n $C64 |base64 -d|tar tzvf -
	command ssh -t $* "
		[ -w \$HOME ] && _H=\$HOME || _H=/tmp/\$USER
		[ $OSTYPE = darwin ] && _D=D || _D=d
		mkdir -m 755 -p \$_H; cd \$_H
		echo -n $C64|base64 -\$_D |tar xzf -;
		exec $RC -m"
)

#: Following are su* wrappers of different kinds including kerberos
#: version 'ksu'. They are basically simple, you see. Environment is not
#: packed and transferred when using them. Instead the original files from
#: user's home folder are used.
## `lsudo [user]`      - sudo wrapper; root is the default account
lsudo () (
	sudo -i -u ${1:-root} $CLE_RC
)

## `lsu [user]`        - su wrapper
#: known issue - on debian systems controlling terminal is detached in case 
#: a command ($CLE_RC) is specified, use 'lsudo' instead
lsu () (
	S=
	[[ $OSTYPE =~ [Ll]inux ]] && S="-s $BASH"
	eval su -l $S ${1:-root} $CLE_RC
)

## `lksu [user]`       - ksu wrapper
#: Kerberized version of 'su'
lksu () (
	ksu ${1:-root} -a -c $CLE_RC
)

## `lscreen [name]`    - gnu screen wrapper, join your recent session or start new
## `lscreen -j [name]` - join other screen sessions, ev. search by name
#: GNU screen wrapper is here 1) because of there was no way to tell screen
#: program to start CLE on more than first window and, 2) to allow easily
#: join detached own session and/or join cooperative session with more
#: participants.
lscreen () (
	#: get name of the screen to search and join
	#: base of session name is $CLE_USER and this can be extended
	NM=$CLE_USER${1:+-$1}
	[ "$1" = -j ] && NM=${2:-.}
	#: list all screens with that name and find how many of them are there
	SCRS=`screen -ls|sed -n "/$NM/s/^[ \t]*\([0-9]*\.[^ \t]*\)[ \t]*.*/\1/p"`
	NS=`wc -w <<<$SCRS`
	if [ $NS = 0 ]; then
		[ "$1" = -j ] && echo "No screen to join" && return 1
		#: No session with given name found, prepare to start new session
		SCF=$CLE_D/screenrc
		SN=$TTY-CLE.$NM
		_rhlog screen -S $SN
		_scrc >$SCF
		screen -c $SCF -S $SN $CLE_RC
	else
		#: is there only one such session or more?
		if [ $NS = 1 ]; then SN=$SCRS
		else
			#: we found more screens with simiilar names, choose one!
			printb "${_CU}Current '$NM' sessions:"
			PS3="$_CL choose # to join: $_CN"
			select SN in $SCRS;do
				[ $SN ] && break
			done
		fi
		_rhlog screen -x $SN
		#: send message to other screen, then join the session
		screen -S $SN -X echo "$CLE_USER joining"
		screen -x $SN
	fi
)

# screenrc generator
#: This generates nice configuration file with cool features:
#:  - always visible status line with list of windows, hostname and clock
#:  - feature to quickly switch using Ctrl+Left/Right Arrows
#:  - reads good old $HOME/.screenrc
#: Own screenrc file is necessary because otherwise it wouldn't start CLE in
#: subsequent windows created with 'C-a C-c' (note the bind commands, above
#: mentioned features are cool but this part is the important one)
_scrc () {
cat <<-EOS
	source $HOME/.screenrc
	altscreen on
	autodetach on
	# enables shift-PgUp/PgDn
	termcapinfo xterm* ti@:te@
	# change window with ctrl-left/right
	bindkey "^[[1;5D" prev
	bindkey "^[[1;5C" next
	defscrollback 9000
	hardstatus alwayslastline 
	hardstatus string '%{= Kk}%-w%{+u KC}%n %t%{-}%+w %-=%{KG}$CLE_SHN%{Kg} %c'
	bind c screen $CLE_RC
	bind ^c screen $CLE_RC
EOS
}

#: Enhnace PATH by user's own bin folder
[[ -d $HOME/bin && ! $PATH =~ $HOME/bin ]] && PATH=$PATH:$HOME/bin

# completions
#: Command 'cle' completion
#: as an addition, prompt strings are filled for convenience :)
_compcle () {
	#: list of subcommands, this might be reworked to have possibility of expansion
	#: with modules (TODO)
	#: 'cle deploy' is hidden intentionaly as user should do it only on when really needed
	local A=(color p0 p1 p2 p3 time title mod env update reset reload doc help)
	local C
	COMPREPLY=()
	case $3 in
	p0) COMPREPLY="'$CLE_P0'";;
	p1) COMPREPLY="'$CLE_P1'";;
	p2) COMPREPLY="'$CLE_P2'";;
	p3) COMPREPLY="'$CLE_P3'";;
	esac
	[ "$3" != "$1" ] && return
	for C in ${A[@]}; do
		[[ $C =~ ^$2 ]] && COMPREPLY+=($C)
	done
	}
complete -F _compcle cle

#: lssh completion
#: there are two possibilities of ssh completion _known_hosts is more common...
declare -F _known_hosts >/dev/null && complete -F _known_hosts lssh
#: while _ssh is better
#: The path is valid at least on fedora and debian with installed bash-completion package
_C=/usr/share/bash-completion/completions/ssh 
if [ -f $_C ]; then
	. $_C
	complete -F _ssh lssh
fi

# session startup
TTY=`tty|sed 's;[/dev];;g'`
_rhlog ${STY:-${SSH_CONNECTION:-$CLE_RC}}

# load modules from .cle folder
for _I in $CLE_D/mod-*;do
	_clexe $_I
done

# config & tweaks
_clexe $HOME/.cle-local
_clexe $CLE_AL
_clexe $CLE_TW
_clexe $CLE_CF || { _banner;_defcf;}
_setp
_setwt

# redefinei bash builtins
#: those definitions must be here, only after config and tweaks not to mess
#: with builtin shell functions during startup. This also speeds up the thing
alias () {
	if [ -n "$1" ]; then
		aa "$@"
	else
		builtin alias
	fi
}

unalias () {
	[ "$1" = -a ] && cp $CLE_AL $CLE_AL.bk
	builtin unalias "$@"
	aa -s
}


[ "$CLE_MOTD" ] && { cat /etc/motd;echo;echo $CLE_MOTD;unset CLE_MOTD; }

# check first run
[ $CLE_1 ] && cat <<EOT
 It seems you started CLE running '$CLE_RC'
 Since this is the first run, consider setup in your profile.
 Following command will hook CLE in $HOME/.bashrc:
$_CL	cle deploy
EOT

##
## ** CLE command & control **
#: This function must be at the very end!
#: The reason is to prevent it's redefine within modules and tweak files
#: Remember, you can replace any internal function if you need!
#: Regarding 'cle' itself, it contains check of existence '_cle_something'
#: shell function and runs it instead of built-in code when invoked as command
#: 'cle something'. This is how modularity has been implemented.
#: That means you can replace parts of code or enhance 'cle' command by
#: defining your own '_cle_something' bash functions
#: 
cle () {
	local C I MM BRC NC
	C=$1;shift
	#: find if there is additional function or module installed and
	#: execute that code
	if declare -f _cle_$C >/dev/null;then
		_cle_$C $*
		return $?
	elif [ -f $CLE_D/cle-$C ]; then
		. $CLE_D/cle-$C $*
		return $?
	fi
	#: execute built-in 'cle' subcommand
	case "$C" in
	color)	## `cle color COLOR` - set prompt color
		[ $1 ]  && _setp $1 && CLE_CLR=$1;;
	p?)	## `cle p0-p3 [str]` - show/define prompt parts
		I=CLE_P${C:1:1}
		[ "$*" ] && eval "$I='$*'" || echo "$I='${!I}'"
		_setp;;
	time)	## `cle time [off]`  - toggle server time in prompt
		[ "$1" = off ] && CLE_P0=%e || CLE_P0='%e \A'
		_setp;;
	title)	## `cle title [off]` - toggle window title
		[ "$1" = off ] && CLE_WT='' || _setwt;;
	deploy) ## `cle deploy`      - hook CLE into user's profile
		cp $CLE_RC $CLE_D/rc
		CLE_RC=$CLE_D/rc
		unset CLE_1
		I='# Command Live Environment'
		BRC=$HOME/.bashrc
		grep -A1 "$I" $BRC && printb CLE is already hooked in .bashrc && return 1
		ask "Do you want to add CLE to .bashrc?" || return
		echo -e "\n$I\n[ -f $CLE_RC ] && . $CLE_RC\n" | tee -a $BRC
		cle reload;;
	update) ## `cle update`      - install fresh version of CLE
		NC=$CLE_D/rc.new
		curl -k $CLE_SRC/master/clerc >$NC	# always update from master branch
		C=`sed -n 's/^#\* version: //p' $NC`
		[ "$C" ] || { echo "Download error"; return 1; }
		echo current: $CLE_VER
		echo "new:     $C"
		MM=`diff $CLE_RC $NC` && { echo No difference; return 1;}
		ask Do you want to see diff? && cat <<<"$MM"
		ask Do you want to install new version? || return
		BRC=$CLE_D/rc.bk
		cp $CLE_RC $BRC
		chmod 755 $NC
		mv -f $NC $CLE_RC
		cle reload
		printb New CLE activated, backup saved here: $BRC;;
	reload) ## `cle reload`      - reload CLE
		unset CLE_EXE
		. $CLE_RC
		echo CLE $CLE_VER;;
	reset)	## `cle reset`       - reset configuration
		rm -f $CLE_CF
		cle reload;;
	mod)	## `cle mod`         - cle module management
		#: this is just a fallback to initialize modularity
		#: downloaded cle-mod overrides this code (see the beginning
		#: of 'cle' function)
		ask Activate CLE modules? || return
		I=cle-mod
		MM=$CLE_D/$I
		curl -k $CLE_SRC/$CLE_REL/modules/$I >$MM
		grep -q "# .* $I:" $MM || { printb Module download failed; rm -f $MM; return 1;}
		cle mod "$@";;
	env)	## `cle env`         - print CLE_* variables
		for I in ${!CLE_*};do printf "$_CL%-12s$_CN%s\n" $I "${!I}";done;;
	doc)	## `cle doc`         - show documentation
		I=`curl -sk $CLE_SRC/$CLE_REL/doc/index.md`
		[[ $I =~ LICENSE ]] || { echo Unable to get documentation;return 1;}
		PS3="$_CL doc # $_CN"
		select C in $I;do
			[ $C ] && curl -sk $CLE_SRC/$CLE_REL/doc/$C |mdfilter|less -r; break
		done;;
	help|-h|-help)	## `cle help [fnc]`  - show help
		# double hash denotes help content
		_C=`ls $CLE_D/cle-* 2>/dev/null`
		awk -F# "/[\t ]## *\`*$1|^## *\`*$1/ { print \$3 }" ${CLE_EXE//:/ } $_C | mdfilter | less -erFX;;
	"")	_banner
		sed -n 's/^#\*\(.*\)/\1/p' $CLE_RC;; # header
# DEBUG
	ls)	printb CLE_D: $CLE_D; ls -l $CLE_D; printb CLE_RD: $CLE_RD; ls -l $CLE_RD;; #debug
	debug)	CLE_DEBUG=$1; dbg_var CLE_DEBUG;; #debug
	pak)	_clepak "$@" ; base64 -d <<<$C64| tar tzvf -;; #debug
	exe)	echo $CLE_EXE|tr : \\n;; #debug
# DEBUG
	*)	echo unimplemented: cle $C
		echo check cle help
		return 1
	esac
}

# remove temporary stuff
unset SUDO_COMMAND _I _N _C
fi
# that's all folks...

