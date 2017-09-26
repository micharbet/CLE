
#        CLE Tips And Tweaks
  ---------- a.k.a. TNT ------------
  warning highly explosive material!
  ----------------------------------

This document presents useful ideas how to customize CLE to your very own
preferences. Some tips may require to install additional software.


## Prompting
The first thing you may want to customize. Go beyond just color change!

### Nice double line prompt
```
cle p0 '\A'
cle p1 '%h (%i)\n'
cle p2 '%cK%e %u -> %cL\u'
cle p3 '\w %>'
```

### Five shades of grey
`cle p3 '\w %cW>%cw>%cN>%cK>%ck>'`
Employs escape sequences from bright white through 'normal' to black. Looks
good on "Solarized" color theme in terminal. Try to reverse the order.

### Something similar but in any color
`cle p3 '\w %cR>%cr>%cD>'`
This uses 'D' - terminal escape sequence for dim attribute

### Show previous working directory in prompt
`cle p3 '(%vOLDPWD) \w %>'
You will see where have you been before recent 'cd something'. Try to
issue `cd -` or simple `-` to swap between PWD and OLDPWD.

### GIT branch in prompt?
Insert module 'git' and use new function 'gicwb':
`cle p3 '\w%cy:$(gicwb) %cW%>'`
iThe `gicwb` simply executes `git symbolic-ref --short HEAD` whenever there
is `.git` directory underneath. Note, this is not CLE feature! Pure bash is
able to execute commands within prompt string if there is something like:
`PS1='string $(the_command) other string'`


## How to enhance 'cle' command
CLE is highly extensible. You can add new fuctions, replace existing ones or
Add more functionality into 'cle' command itself. Do you miss a feature? Be
brave and write module. Read more in _Modules.md_


## Various startup files
Tweak CLE using one of startup files. Avoid editing .clerc whenever posible.
Besides modules described in separate document, CLE finds and executes
following files:
- `/etc/clerc-system`
- `$HOME/.clerc-local`
- `$HOME/.cleusr-YOURLOGIN`
First two files are quite easy to understand. They resides where theyare and
are executed as expected. The third one, `.cleusr-YOURNAME` is sort of special
as it is also packed transferred to remote account and executed when you start
new session with `ssg`, `suu`, `sudd` Using this file you can apply your own
settings without well-known copy/paste technology applied to varios files.
Just deploy once, use anywhere - that's CLE!


## Override internal functions
Besides introducing new functions you can override any intenal CLE function
with oyur own code. Doing this is easy. You just need to ensure the new code
serves the same purpose. 

For example put following snippet into `.cleusr-YOURNAME` :

```
_defcf () {
	CLE_P0='\A'
	CLE_P1='%h ${CLE_IP:+(%i)} %cK%vOLDPWD\n'
	CLE_P2='%cK%e %u -> %cL\u'
	CLE_P3='\w %>'
	case $USER@$HOSTNAME in
	mich@*redhat.com)
		CLE_CLR=Wbw
		CLE_P2='%cK%e \u'
		;;
	mich@*)
		CLE_CLR=Cbw
		CLE_P2='%cK%e \u'
		;;
	marbet*) CLE_CLR=Wbw ;;
	root@*redhat.com) CLE_CLR=Wrw ;;
	root@*) CLE_CLR=Crw ;;
	*@*redhat.com) CLE_CLR=Wgw ;;
	*) CLE_CLR=RgW ;;
	esac
}
```
Important information here is that function `_defcf` is CLE's iternal and
ensures setting default prompt scheme (yeah, that red-yellow-green scheme
called 'marley'). Feel free to inspect the function with `declare -f _defcf`
If you replace this function by puting the code into the right file (again,
`.cleusr-YOURNAME`) you'll get unified cool prompt that by color distinguishes
between hosts/domains/usernames. Feel free to modify the snippet in your very
own way!

BTW, another features contained in the prompt are displayin IP address of the
host, and variable $OLDPWD that contains working directory before most recent
command `cd`

Such you can override almost any CLE internal fuction except the `cle` itself.
For example somebody might want to use wider colour palette. Why not to rewrite
function `_setp` responsible for setting prompt color? 

