#   Command Live Environment
## _The shell improvements :-)_

CLE enhances bash with following tweaks:
 - colorized and tweakable **prompt** string including server time and exit
   code highlight
 - save/edit and reuse **aliases** in easy way
 - rich **history** with timestamps, return codes and additional information
 - super easy installation ONLY on your workstation
 - **seamless** transfer of the environment from workstation to remote
   sessions without installation
 - various shell options
 - configuration from commandline with immediate effect, no restarts
 - self documenting feature
 - open framework for tweaks and further customization
 

## CLE setup and usage
All the mentioned functionality is encoded into __single file__ and no other
executables are needed. Run this file in the current shell context using
trailing dot:

    `. clerc`

The CLE is activated now and you can setup this environment as persistent with
command:

    `cle deploy`

CLE copies itself to `$HOME/.clerc` and adds two lines into your `.bashrc`
si it will be started upon each login. Note this is the *only* one
installation step you need to perform. Typically you'd do it on your account
on your workstation.


### ssg utility (ssh wrapper)

The CLE is able to pass itself over ssh. Use 'ssg' wrapper instead of regular
'ssh' for login into remote account and CLE will be copied over and started
seamlessly:

    `ssg username@remote.host`


### suu, sudd, kksu utilities (su/sudo/ksu wrappers)

Those wrappers serve the same purpose like original su, sudo and ksu utilities
however they add CLE to the sessions.


### scrn - GNU screen wrapper

This wrapper is workaround allowing starting CLE inside screen session. Added
value here is configuration file with nice status line and switching between
sessions with Ctrl-Left/Right.


### other utilities
- `aa`  manges aliases
- `hh`  makes history searches easier
- `cle` the most important one - this is the command and control center
        of the environment


## Compatibility

CLE has been tested on various systems containing bash version 3.x and 4.x
and different flavors of basic utilities (GNU vs. BSD) High attention was paid
to write highly compatible code so some of nice features of bash4 couldn't be
used. And, various flavor of 'sed' utility is another different story.

Tested systems include following:
- Linux Mint
- Fedora 23+
- RHEL 5 (bash v3)
- RHEL 6
- RHEL 7
- NetBSD
- FreeBSD
- OS X
- Android (some terminal software requires different tweaks, WIP) 

It also works well with at least following terminal emulators:
- Terminator
- Gnome Terminal
- xterm
- rxvt
- screen


## Requirements

Generaly basic OS installation should be sufficient. Some systems might however
require to add missing utilities. Those really necessary are:
- bash (yeah, minimal FreeBSD setup did't contain this!)
- sed
- base64
- curl
- ssh (note, no scp required, e.g no openssh-clients on RHEL)
- GNU screen (only if you want to use it with 'scrn' wrapper)


## Why 'CLE' and bit of history

 CLE was developed over years of work in command line, where I always tried
to have easily distinguished prompt. It has been possible to accomplish
this goal in diferent ways. Basically by editing shell resource files like
.bashrc .kshrc and/or manually transfer those files to each new server and
account. So the very first version was just a backup of my .kshrc (yes, long
ago I used mainly Korn Shell) This version does exist probably on some old
boxes and in scattered backup files. You all probably have something similar.

 Second version contained resource file itself and minimal set of
utilities (scripts like 'cle', 'hlp', etc - some of them are part of different
project 'rootils' now) This version worked without 'ssg' however required to be
installed on each particular account. The setup was done using 'cle' script
but still it was necessary step. Also, changes on those accouts might be
unwelcomed by other administrators. BTW, in version 2, the current name was
introduced as I considered it was bringingmore live into poor, plain command
line.

 In third version I removed necessity to setup by ingenious way -
passing resource file encoded with base64 through a shell variable to the
remote system. Result is no setup, no tweaks on remote site and no harm
to the current environment! Whoa! The only what you need is working CLE on
your workstation from where you manage the world :-)

You can always use the same and still customizable environment everywhere.
Incorporating `ssg`, `suu` utilities and `cle` managment function into the
sinle file was just a nature evolution that enhanced word 'Live': the `clerc`
resourcefile now contains a mechanism of multiplication it's own DNA [1]


[1] CLE is not a virus :-) Everything, all the spreading is done in controlled
way and you, the user is the one who know what you're doing.
