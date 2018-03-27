
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
cle p3 '\w >'
```

### Five shades of grey
`cle p3 '\w %cW>%cw>%cN>%cK>%ck>'`
Employs escape sequences from bright white through 'normal' to black. Looks
good on "Solarized" color theme in terminal. Try to reverse the order.


### Something similar but in any color
`cle p3 '\w %cR>%cr>%cD>'`
This uses '%cD' - terminal escape sequence for dim attribute that is
unfortunately not widely supported on terminals


### Show previous working directory in prompt
`cle p3 '(%vOLDPWD) \w >'
You will see where have you been before recent 'cd something'. Try to
issue `cd -` or simple `-` to swap between PWD and OLDPWD.


### GIT branch in prompt?
Add module 'git' and use new function 'gicwb':
```
cle mod add git
cle p3 '\w%cy:$(gicwb) %cW>'
```
The `gicwb` simply executes `git symbolic-ref --short HEAD` whenever there
is `.git` directory underneath. Note, this is not CLE feature! Pure bash is
able to execute commands within prompt string if there is something like:
`PS1='string $(the_command) other string'` In the example above there are 
following items:
- `\w` stand for displaying of current working directory (regular bash)
- `$cy` is CLE enhancement for switching to yellow color
- `:` nothing more than a colon, just the character
- `$(gicwb)` runs the function
- `%cW` switch color to bright white
- `>` prompt character, i do not like default dollar, feel free to use regular
  bash's '\$' instead


## CLE startup tweaks

### Deploying for user root
In case you really insist on using root as your default login account and
want to have cle deployed here, you can do it same way like for any other
user. Remember following: there is variable **$CLE_USER** that makes it
possible to work on multi-admin environment. But, in your case its value 
would be string 'root' If somebody else would do the same and you both
would meet as administrators of the same server, you'd get into conflict
because resource folder and used configuration file would be the same.

To avoid this situation do following steps after deployment:
1. rename '.cle-root' to '.cle-YOURNAME'
2. open .bashrc in editor and replace all occurences of '.cle-root'
   with the name chosen in step #1

See section 'Variables' in document _HOWTO.md_ for more details about
how $CLE_USER is determined and used.


## Various startup files

Tweak CLE using one of startup files. Avoid editing .clerc whenever posible.
Besides modules described in separate document, CLE finds and executes
following files:
- `$HOME/.cle-local`
  Local account's tweak is executed when CLE is started here.
- `$HOME/.cle-YOURLOGIN/tw`
  This file is packed, transferred and executed on remote account along with
  the main resource file everytime new session is initiated with `ssg` or any
  of `su*` wrappers. Using this file you can apply your own settings in just
  one single file that resides on your workstation. 

Try for example this:
1. using text editor create tweak file .cle-YOURNAME/tw with following content:
```
   ## My own worldwide tweak
   ## psg string     -- grepped process list
   psg () (
      [ $1 ] || { echo 'psg: missing process name'; return 1; }
      ps -ef | grep $1 | grep -v grep
   )
```
2. restart environment (`cle reload`) or start new terminal
3. try new function: `psg bash`; you should see all running shells only
4. go to different account: `ssg account@somewhere.else` and try new function
   there. It should work.
5. bonus: you also created in-script help strings and you can see them in
   output of `cle help` and `cle help psg`
6. enjoy and tweak more!


## Override internal functions

Besides introducing new functions you can override any intenal CLE function
with oyur own code. Doing this is easy and tricky at the same time. You need
to ensure the new code serves the same purpose. 

In this example you will override _defcf function that by default resets the
prompt settings to scheme 'marley' But you might want to use your own colors
and not to perform prompt setup on each new account.

Add following code into the tweak file:
```
  # my own default config generator
  # replace 'my-work.com' with your domain
  # replace 'mich' with your login name
  _defcf () {
     # two-line prompt string wit IP address
     CLE_P0='\A'
     CLE_P1='%h ${CLE_IP:+(%i)}\n'
     CLE_P2=' %cK%e \u'
     CLE_P3='\w >>'
     # different colours for various destinations
     case $USER@$HOSTNAME in
       mich@*my-work.com)
         CLE_CLR=Wbw ;;
       mich@*)
         CLE_CLR=Cbw ;;
       root@*my-work.com)
         CLE_CLR=WRw
         CLE_P3='\w #' ;;
       root@*)
         CLE_CLR=CRw
         CLE_P3='\w #' ;;
       *)
         CLE_CLR=Ygw ;;
     esac
  }
```
Overridden function creates unified cool prompt that by color distinguishes
between hosts/domains/usernames. Feel free to modify the snippet in your very
own way! One important fact: function `_defcf` is called on new sessions, where
no configuration file exists. That means, it literally creates default config
but doesn't touch existing one. So if you open session on previously visited
account nothing happens. Use brute force in that case with command `cle reset`.

It is not enough to simply set CLE_CLR and CLE_Px values because configuration
is applied after tweak. For this it would be always overwritten. Moreover,
this method - overriding the _defcf function is universal as it allows you
to alter those new defaults.

Note statement `case $USER@$HOSTNAME` that ensures differentiation based on
where you actually are. Of course replace 'mich', 'my-work.com' or eventually
rewrite the whole function to your own taste.

Pro tip: inspect the function with command `declare -f _defcf`

You can override almost any CLE internal fuction except the `cle` itself.
For example somebody might want to use wider colour palette. Why not to rewrite
function `_setp` responsible for setting prompt color? You just need to be
familiar with the CLE internals, its variables and functions. Inspect and try
to understand the magic inside `clerc` even if it might be tricky sometimes.
There can be also parts of the code that could be written more effectively
in Bash 4. but due to compatibility with older Bash 3 it is like it is. For
example: color table might be in associative array but that doesn't exist in
Bash older than version 4. Keep that in mind.



## How to enhance CLE

CLE is highly extensible. Did I tell this? really? Well, you can add new
fuctions, replace existing ones or add more functionality into 'cle'
command itself. Do you miss a feature? Be brave and write your module.
Read more in _Modules.md_ Are you really brave? Publish your work. Others
may enjoy it too! For this check  _Contribute.md_


