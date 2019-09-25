
#   Command Live Environment

##   Enhanced shell experience

CLE is a resource that can be loaded upon interactive shell startup. It makes
regular work with command line easier by adding fancy features named below:

 - a colorized and customizable **prompt** string including server time and
   exit code with highlighting
 - it allows you to save/edit and reuse **aliases** in an easy way
 - rich **history** with timestamps, return codes and additional information
 - **seamless** transfer of the environment and settings to remote sessions
 - configuration right from the commandline with immediate effect, no restarts
 - quick acess to documentation
 - open framework for customization with tweaks and modules
 - install once on your workstation, use everywhere you log in

CLE is compatible with bash and zsh, one resource file for both shells.


## 1. CLE setup and basic usage

All the mentioned functionality is encoded into _single file_ and no other
executables are needed. Download and run this file by sourcing into
the current shell context using a trailing dot:

    `wget http://git.io/clerc`
    `. clerc`

* Note: you can alternatively download with `curl` from real source:

    `curl -O https://raw.githubusercontent.com/micharbet/CLE/master/clerc`

  This is necessary on OSX as there's no `wget` in default installation.
  The `http://git.io/clerc` is only redirecting shortcut.


Now The CLE is activated and you can configure this environment to be
persistent with the command:

    `cle deploy`

CLE copies itself to `$HOME/.cle-YOURLOGIN/rc` and adds two lines into `.bashrc`
ev. `.zshrc` if you run Z-shell. Then it will be started upon each login. Note,
this is the **one and only** installation step you need to perform. Typically
you'll only install this on your workstation's account. Do not deploy CLE as
root! It would work, and no harm is expected, however it's not recommended.
In case you insist on using the root account as your working account, please
read the document 'TipsAndTweaks.md' and find the corresponding section.


### lssh utility (ssh wrapper)

The CLE is able to pass itself over ssh to a remote system. Use the wrapper
called `lssh` instead of the regular 'ssh' command for a login into a remote
account and CLE will be copied over then started seamlessly:

    `lssh username@remote.host`


### lsu, lsudo, lksu utilities (su/sudo/ksu wrappers)

Those wrappers serve the same purpose as the original su, sudo and ksu
utilities, however they add CLE to the sessions.


### lscreen - GNU screen wrapper

This wrapper is a workaround to the original GNU screen to allow using CLE
inside a screen session. By default `lscreen` searches for _yours_ opened
and/or detached session and jumps into it if found. Otherwise it creates
a new screen. Another added value is a configuration file with a nice status
line and shortcuts such as Ctrl-Left/Right to switch between windows.


### Other utilities
- `aa`  improved alias management
- `h`   add colors to regular `history` output
- `hh`  rich history, find more information and search by various criteria
- `cle` command and control center of the environment.

Find more helpful information directly from command line:
- `cle help` to show all commands defined byt he environment
- `cle doc`  to download and display documentation files


## 2. Compatibility

CLE has been tested on various systems containing bash version 3.x 4.x and
zsh. It works with different flavors of basic utilities (GNU vs. BSD). Strict
attention was paid to highly multiplattform compatibility.

Tested systems include the following:
- Linux Mint
- Fedora 23+
- Arch Linux
- RHEL 5 (bash v3!)
- RHEL 6
- RHEL 7
- CentOS
- NetBSD
- FreeBSD
- OS X (bash v3!)
- Android (some terminal software requires different tweaks, WIP) 

It also works well with at least the following terminal emulators:
- Terminator, Gnome Terminal, other VTE based teriminals
- Xfce Terminal
- xterm
- rxvt
- screen
- Linux console (limited color palette)



## 3. Requirements

Generally a basic OS installation should be sufficient. Some systems, however,
might require you to add missing utilities. Truly necessary utilities are:
- bash or zsh
- sed
- awk
- base64
- curl
- ssh (note, no scp required, e.g no openssh-clients on RHEL)
- GNU screen (only if you want to use 'lscreen' wrapper)



## 4. Why 'CLE' and bit of history

My shell environment has been developed over the years of work with command
line, where I always tried to have an easily distinguished prompt. It was
possible in diferent ways. Basically, I have been editing the shell resource
files .bashrc, .kshrc and manually transferring them to each new server and
account. Those files may still exist on some old boxes and in scattered
backup files. You all probably have something similar.

CLE itself begun as customized .bash resource file itself and a set of
utilities. This version worked without 'lssh', instead required installation
prior first use on remote account or update if anything changed. The setup was
simplified with the 'cle' script but the installation was still a necessary
step. Also, .bashrc changes might be unwelcome to other administrators. 
However this was first, primitive 'life' in command line.

Evolution continues. I removed the setup necessity in an ingenious way - by
passing the resource file compressed and base64 encoded through a shell
variable to the remote system. To be honest, I was inspired by the 'sshrc'
project. Result: no setup, no tweaks on the remote site no harm to the current
environment and consistent environment over all sessions!

The only thing you need is a working CLE on your workstation from where you
can manage the world :-) Everywhere you go you can now use the same
customizable environment! Use `lssh` instead of `ssh` or `lsu` instead of
`su - root` or `lsudo' in place of `sudo bash`. Those are live wrappers that
initiate CLE sessions. In biology terms, the environment can spread own DNA
giving the word 'live' it's true meaning. Or at least closer. [1]

CLE versions have no numbers but rather names. As of 2016 following releases
were issued:
- Spring, Easter, MayDay - 2016, very old versions
- HAlpha - 2017, code cleanup and high optimization
- RedH - 2017, adding new features
- Nova - 2018, big improvements, new features again, like rich history
- Zodiac - 2019, current release, basically the same functions as Nova
  but almost complete rewrite to ensure compatibility with Z-shell plus
  improved environment transfer incl. prompt settings, aliases and variables.

Also while CLE is big tweak itself, it tries to respect users and their own
settings. Initial versions used to be pushy, defining a lot of aliases, of
course those I liked. Wrong! I learned people use their own so I removed
them. Shell history as well. There's rich history and tweaks to the regular
one have been minimalized. The motto is: "Less tweaks, more options!"

[1] CLE is not a virus :-) It doesn't run itself on any host. Everything is
under the users' (your) control and responsibilty


## 5. LICENSE
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 Find complete text in the file LICENSE.md or at the following URL:
 https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html

