
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
Add module 'git' and use new function 'gicwb':
```
cle mod add git
cle p3 '\w%cy:$(gicwb) %cW%>'
```
The `gicwb` simply executes `git symbolic-ref --short HEAD` whenever there
is `.git` directory underneath. Note, this is not CLE feature! Pure bash is
able to execute commands within prompt string if there is something like:
`PS1='string $(the_command) other string'` In the example above there are 
following items:
- `\w` stand for displaying of current working directory (regular bash)
- `$cy` is CLE enhancement for switching to yellow color
- `:` nothing more than a colon, just thich character
- `$(gicwb)` runs the function
- `%cW` switch color to bright white
- `%>` prompt character: '>' for users, '#' for root. i do not like default 
  dollar, feel free to use regular bash's `\$` instead of this CLE enhancement


## How to enhance CLE

CLE is highly extensible. Did I tell this? really? Well, you can add new
fuctions, replace existing ones or Add more functionality into 'cle'
command itself. Do you miss a feature? Be brave and write your module.
Read more in _Modules.md_ Are you really brave? Publish your work. Others
may enjoy it too! For this check  _Contribute.md_


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
serves the same purpose. You can write your functions into two places:
- .cleusr-YOURNAME  - this will be transferred and executed in remote session
- .clerc-local      - executen on the particular account only
- /etc/clerc-system - executed on any cle session at thist host

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
Using this you'll get unified cool prompt that by color distinguishes
between hosts/domains/usernames. Feel free to modify the snippet in your very
own way! One important fact: function `_defcf`is called on new sessions, where
no file `$HOME/.clecf-YOURNAME` exists. That means, it literally creates
default configuration but doesn't touch existing one. So if you open session
on previously visited account (having .clecf-* already there) nothing happens.
Use brute force in that case with command `cle reset`.

Note statement `case $USER@$HOSTNAME` that ensures differentiation based on
where you actually are. Of course replace 'mich', 'redhat.com' or eventually
rewrite the whole function to your own taste.

Important information here is that function `_defcf` is CLE's internal and
ensures setting default prompt scheme (yeah, that red-yellow-green scheme
called 'marley'). Feel free to inspect the function with `declare -f _defcf`

BTW, other features contained in the prompt are: displaying IP address of the
host - `${CLE_IP:+(%i)} and variable that contains working directory before
most recent command `cd` - `%vOLDPWD`. Note also `%cK` changing color to dim
gray. Read _Howto.md_ for detailed information about prompt settings.

You can override almost any CLE internal fuction except the `cle` itself.
For example somebody might want to use wider colour palette. Why not to rewrite
function `_setp` responsible for setting prompt color? You just need to be
familiar with the CLE internals, its variables and functions. Inspect and try
to understand the magic inside `.clerc` even if it might be tricky sometimes.
There can be also parts of the code that could be written more effectively
in Bash 4. but due to compatibility with older Bash 3 it is like it is. For
example: color table might be in bash array but that doesn't exist in Bash
older than version 4. Keep that in mind.



