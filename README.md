#   Command Live Environment
## _The shell improvements :-)_

CLE contains following bash tweaks:
 - colorized **prompt** including server time and exit code highlight
 - personalized and customizable **aliases**
 - **history** tweaks, timestamps
 - shell options
 - configuration with immediate effect, no restarts
 - seamless transfer of the environment from workstation to remote sessions
 - self documenting feature
 - open framework for tweaks and further customization
 

## CLE setup and usage
All the mentioned functionality is encoded into __single file__ and no other
executables are needed. Run this file in the current shell context using
trailing dot:

    . clerc

The CLE is activated now and you can setup this environment as persistent with
command:

    cle deploy user

CLE copies itself to `$HOME/.clerc` and adds two lines into your `.bashrc`
si it will be started upon each login. Note this is the *only* one
installation step you need to perform. Typically you'd do it on your account
on your workstation.

There is also possibility to setup CLE systemwide. Issue command
`cle deploy system` and content of active resource file will be copied
into `/etc/profile.d/cle.sh` thus activated for all users on that particular
machine. This step is however not required.


### ssg utility (ssh wrapper)

The CLE is able to pass itself over ssh. Use 'ssg' wrapper instead of regular
'ssh' for login into remote account and CLE will be copied over and started
seamlessly:

    ssg username@remote.host


### suu utility (sudo wrapper)

The 'suu' does the same job like ssg bout it transfers CLE over sudo command.
You can run `suu` alone or `suu username`. Without username the root
is chosen by deafult, obviously.

In both cases ('ssg' and  'suu') the content of '.clerc' is passed to the
remote session and executed as a resource script instead of '.bashrc.'


### other utilities
`aa` manges aliases

`hh` makes history searches and sharing easier

`cle` the most important one - this is the command and control center
      of the environment


## Compatibility

CLE has been tested on various systems containing bash version 3.x and 4.x
and different flavors of basic utilities (GNU vs. BSD)
Those includes following:
- Linux Mint
- Fedora 23+
- RHEL 5 (bash v3)
- RHEL 6
- RHEL 7
- NetBSD
- OS X (bash v3 and BSD utilities)
- Android (some terminal software requires different tweaks, WIP) 

It also works well with at least following terminal emulators:
- Terminator
- Gnome Terminal
- xterm
- rxvt
- screen
- tmux


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
