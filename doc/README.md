
#   Command Live Environment

##   Enhanced shell experience

CLE adds the following functionalities to bash:
 - a colorized and customizable **prompt** string including server time and exit
   code highlighting
 - it allows you to save/edit and reuse **aliases** in an easy way
 - rich **history** with timestamps, return codes and additional information
 - the super easy installation is only on your workstation, and yet...
 - **seamless** transfer of the environment from the workstation to remote
   sessions without remote installation!
 - configuration from the commandline with immediate effect, no restarts
 - self documenting features
 - open framework for tweaks and further customization
 


## 1. CLE setup and basic usage

All the mentioned functionality is encoded into _single file_ and no other
executables are needed. Download and run this file either by sourcing into
the current shell context using a trailing dot:

    `wget http://git.io/clerc`
    `. clerc`

* Note, the `http://git.io/clerc` is shortcut. If not sure use real source
  `https://raw.githubusercontent.com/micharbet/CLE/master/clerc`

The CLE will be activated and you can configure this environment to be
persistent with the command:

    `cle deploy`

CLE copies itself to `$HOME/.cle-YOURLOGIN/rc` and adds two lines into `.bashrc`
so it will be started upon each login. Note this is the **one and only**
installation step you need to perform. Typically you'll only install this on
your workstation's account. Note: do not deploy CLE as root! It would work,
and no harm is expected, however it's not recommended. In case you insist on
using the root account as your working account, please read the document
'TipsAndTweaks.md' and find the corresponding section.


### lssh utility (ssh wrapper)

The CLE is able to pass itself over ssh to a remote system. Use the ssh wrapper
called `lssh` instead of the regular 'ssh' command for a login into a remote
account and CLE will be copied over then started seamlessly:

    `lssh username@remote.host`


### lsu, lsudo, lksu utilities (su/sudo/ksu wrappers)

Those wrappers serve the same purpose as the original su, sudo and ksu utilities,
however they add CLE to the sessions.


### lscreen - GNU screen wrapper

This wrapper is a workaround to the original GNU screen to allow using CLE
inside a screen session. By default `lscreen` searches for _yours_ opened/detached
session and jumps into it if finds one. Otherwise it creates a new screen.
Another added value is a configuration file with a nice status line and
shortcuts enabled such as Ctrl-Left/Right to switch between windows.


### Other utilities
- `aa`  manages aliases
- `h`   colors regular history
- `hh`  makes history searches easier
- `cle` the most important one - this is the command and control center
      of the environment. Issue `cle help` to read more.

Read HOWTO.md and other documents to find out more about this environment.


## 2. Compatibility

CLE has been tested on various systems containing bash version 3.x and 4.x
and different flavors of basic utilities (GNU vs. BSD). Strict attention was
paid to writing highly compatible code, and so some of the nice features of
bach4 could not be used. And, various flavors of the 'sed' utility is another
story.

Tested systems include the following:
- Linux Mint
- Fedora 23+
- RHEL 5 (bash v3!)
- RHEL 6
- RHEL 7
- NetBSD
- FreeBSD
- OS X (bash v3!)
- Android (some terminal software requires different tweaks, WIP) 

It also works well with at least the following terminal emulators:
- Terminator
- Gnome Terminal
- Xfce Terminal
- xterm
- rxvt
- screen
- Linux console (limited color palette)



## 3. Requirements

Generally a basic OS installation should be sufficient. Some systems, however,
might require you to add missing utilities. Truly necessary utilities are:
- bash (yeah, minimal FreeBSD setup didn't contain this shell!)
- sed
- base64
- curl
- ssh (note, no scp required, e.g no openssh-clients on RHEL)
- GNU screen (only if you want to use 'lscreen' wrapper)



## 4. Why 'CLE' and bit of history

 CLE was developed over years of work at the command line, where I always tried
to have an easily distinguished prompt. It has been possible to accomplish this
goal in diferent ways over time. Basically, I have been editing the shell
resource files .bashrc, .kshrc and/or manually transferring those files to each
new server and account. The very first version was just a backup of my .kshrc
(yes, long ago I used mainly the Korn Shell). This version probably still exists
on some old boxes and in scattered backup files. You all probably have something
similar.

 The second version contained the resource file itself and a minimal set of
utilities (scripts such as 'cle', 'hlp', etc - some of them are part of
a different project 'rootils' now). This version worked without 'ssg', instead
requiring installation on each separate account. The setup was simplified with
the 'cle' script but installation was still a necessary step. Also, shell
changes might be unwelcome to other administrators. BTW, the current name
"The CLE" was only introduced in Version 2 as I considered it as bringing more
life into the poor, plain command line.

 In the third version I removed the setup necessity in an ingenious way - by
passing the resource file encoded with base64 through a shell variable to the
remote system. To be honest, I was inspired by the 'sshrc' project. Result: no
setup, no tweaks on the remote site and no harm to the current environment!
The only thing you need is a working CLE on your workstation from where you
can manage the world :-) Everywhere you go you can now use the same basic and
still customizable environment!

Incorporating the `lssh` and `lsu*` wrappers together with the `cle` management
function into one single resource file was just a natural evolution that gave
the word 'Live' its true meaning -- the `clerc` now contains a mechanism for
multiplying its own DNA [1].

[1] CLE is not a virus :-) It doesn't run itself on any host. Everything is
under the users' (your) control and responsibilty. All the spreading is initiated
and driven by a user who must know what he or she is doing. Feel free to inspect
the source code!



## 5. LICENSE
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 Find complete text in the file LICENSE.md or at the following URL:
 https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html

