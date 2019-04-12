
#        CLE Tips And Tweaks

  ---------- a.k.a. TNT ------------
  warning highly explosive material!
  ----------------------------------

This document presents useful ideas how to customize CLE to your very own
preferences. Some tips may require to install additional software.

## Content
1. Prompting
2. Installation tweaks
3. Startup tweaks
4. How to enhance CLE


## 1. Prompting
The first thing you may want to customize. Go beyond just color change!

### Nice double line prompt
```
   cle p0 '\A'
   cle p1 '^h (^i)\n'
   cle p2 '^CK^e ^u -> ^CL\u'
   cle p3 '\w >'
```

### Five shades of grey
`cle p3 '\w ^CW>^Cw>^CN>^CK>^Ck>'`
Employs escape sequences from bright white through 'normal' to black. Looks
good on "Solarized" color theme in terminal. Try to reverse the order.


### Something similar but in any color
`cle p3 '\w ^CR>^Cr>^CD>'`
This uses '^CD' - terminal escape sequence for dim attribute that is
unfortunately not widely supported on terminals


### Show previous working directory in prompt
`cle p3 '(^vOLDPWD) \w >'
You will see where have you been before recent 'cd something'. Try to
issue `cd -` or simple `-` to swap between PWD and OLDPWD.


### GIT branch in prompt?
Simply, yes!
```
   cle p3 '\w^Cy:^g ^C3\$'
```
Function `gicwb` simply executes `git symbolic-ref --short HEAD` whenever
there is `.git` directory underneath. Following items are in the example above
- `\w` stand for displaying of current working directory (regular bash)
- `^Cy` is CLE enhancement for switching to yellow color
- `:` nothing more than a colon, just the character
- `^g` runs the function
- `^C3` switch color back to defined for prompt part 3


### Change dark grey of status part
Do you want it green? Use this: `cle p0 '^Cg^e'`
If you desire to change also error code highlight, edit tweak file (described
below) and alter color table with following lines:
```
	# this goes to file $HOME/.cle-YOURNAME/tw
	_Ce=$_Cr	#  plain red status highlight
```


## 2. Installation tweaks

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
3. start new session (new terminal window) if everything works, close
   the previous one

See section 'Variables' in document _HOWTO.md_ for more details about
how $CLE_USER is determined and used.


### How to deploy CLE into different folder

The environment is by default stored in following folder:`$HOME/.cle-YOURNAME`
and almost all files are created there. You may want for example to use
'.config' as the default place for your resource and configuration files. 
It's definitely possible! You need to be aware of following facts:
1. The installation folder must be hidden one (with dot at the beginning).
2. Value of $CLE_USER is derived from the path, there must be either one
   of `cle-YOURNAME` or `cle/YOURNAME`. The word 'cle' and delimiter are
   important.
3. The relative pathname will be used on remote sessions (lssh) and all folders
   will be created.
4. All changes are yours own only, other users may happily use defaults.

Thus, following folders are valid (relative to home directory)
- .cle-user1/  (default)
- .config/cle-user1
- .abc/cle/user1

Regarding fact No.3 and 4: folder '.config' exists mainly on desktop accounts,
there is rarely such folder for root or any other subsystem and servers. Do
the reloacation only if you _know_ what are you doing and why.

Well, this is how. Basically the procedure is the same like in previous
chapter (Deploying for root). Say you're going to use .config as the base:
1. `mv .cle-YOURNAME .config/cle-YOURNAME`
2. edit .bashrc file, find section starting CLE (should be at the end):
```
     # Command Live Environment
     [ -f /home/YOURNAME/.cle-YOURNAME/rc ] && . /home/YOURNAME/.cle-YOURNAME/rc
```
   Replace correspondig pathnames:
```
     # Command Live Environment
     [ -f /home/YOURNAME/.config/cle-YOURNAME/rc ] && . /home/YOURNAME/.config/cle-YOURNAME/rc
```
3. start new session (new terminal window) if everything works, close
   the previous one

There is another way, use module `cle-rcmove`. The module does all steps above
for you and checks if necessary requirements are met.
1. Add the module: `cle mod add rcmove`
2. Use it: `cle rcmove .config`

More about modules in dedicated document.



## 3. Startup tweaks

Always customize CLE using one of tweak files. Avoid editing .clerc whenever
posible. Besides modules described in separate document, CLE finds and executes
following files:
- `$HOME/.cle-local`
  Local account's tweak is executed when CLE is started.
- `$HOME/.cle-YOURLOGIN/tw`
  This file is executed on CLE startup and moreover, it is packed, transferred
  and executed on remote account along with the main resource file everytime
  new session is initiated with `lssh` or any of `lsu*` wrappers. Using this file
  you can apply your own settings in just one single file that resides on your
  workstation. 

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
4. go to different account: `lssh account@somewhere.else` and try new function
   there. It should work.
5. bonus: you also created in-script help strings and you can see them in
   output of `cle help` and `cle help psg`
6. enjoy and tweak more!


### Suppress /etc/motd (variable CLE_MOTD)

Upon remote login (lssh) message of the day is displayed. This is ensured with
variable `$CLE_MOTD`. Note the variable is empty when you're already in command
prompt. This ensures /etc/motd will be displayed only once. The variable gains
otuput of `uptime` while CLE is initiated and displays it after /etc/motd. This
is normal behavior however you can add add `unset CLE_MOTD` to your tweak file
and message of the day will never be shown.


### Tweaking only on particular accounts

Some tweaks may be applicable only on particular hosts/accounts. Use 'case'
statement like for example this:
```
   # we're using $USER - not $CLE_USER!
   case $USER@$HOSTNAME in
      user1@destination1.example.com)
         # this will be executed only on one account
         ;;
      *@destination1.example.com)
         # executed on all other accounts on the same host
         ;;
      user2@*|user3@*)
         # executed for user2 and user3 on anyhost
         ;;
   esac
```
Be creative, make your own 'case', you can use it to define for example extra
aliases. special prompt settings (see next section) etc.


### Override internal functions

Besides introducing new functions you can override any intenal CLE function
with oyur own code. Doing this is easy and tricky at the same time. You need
to ensure the new code serves the same purpose. 


## 4. How to enhance CLE

CLE is highly extensible. Did I tell this? really? Well, you can add new
fuctions, replace existing ones or add more functionality into 'cle'
command itself. Do you miss a feature? Be brave and write your module.
Read more in _Modules.md_ Are you really brave? Publish your work. Others
may enjoy it too! For this check  _Contribute.md_


