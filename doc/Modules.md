# Use modules to enhance CLE funcionality

## Content
1. What are modules
2. Module types
3. How to use modules
4. Modules repository
5. List of basic available modules
6. How to write your own cool stuff


## 1. What are modules

In addition to basic fuctionalities the CLE is in fact extensible framework.
Various modules can be added to enhance or modify the environment. For example
CLE doesn't contain functions to backup/restore settings. If there is a module
providing this it can be downloaded and installed. CLE uses it's own repository
to find and download those files on user's request. The reason for using own
repository is compatibility among various distributions and operating systems
so there is no dependancy on rpm/deb/other packaging system nor the OS flavour
(meaning Linux/*BSD/Solaris/...)

Modules are stored in folder `$CLE_D` (by default '$HOME/.cle-YOURNAME').
Various types of modules can be found here as decribed in one of chapters
below.


## 2. Module types

Two kinds of modules are available in CLE:
- _mod-*_ this code is executed - sourced into bash upon each CLE sessio
  startup. These modules may implement new bash functions, replace original CLE
  functions and alter variables. 

- _cle-*_ contain scripts enhancing functionality of built in `cle` command.
  Modules of this kind resides in the folder and are executed on demand only
  through command `cle`. Execution is in fact sourcing into current bash, no
  new process is created - like in previous type.
  Good example is 'cle-mod'. This one enables module management itself, like
  adding, removing, etc. When you issue command `cle mod add` execution is
  redircted into `$CLE_D/cle-mod`

Following chart provides overview of module types and their main properties

```
          executed    can alter    can use
         on startup   variables   functions
                         and       defined
                      functions   in .clerc
         ----------------------------------
  mod-*      yes         yes         yes
  cle-*                  yes         yes
```


## 3. How to use modules

There is command `cle mod` that maintains modularity. This command is sort of
special. When you inspect clerc you can find corresponding section within `case`
statement. But this section just literally downloads module _cle-mod_ from
repository. This happens only once. When the module (cle-mod) is downloaded it
will be executed instead of built-in code. The module defines following
subcommands:

`cle mod`       - shows URL of module repository and destination folder
`cle mod help`  - provides short overview of module related commands
`cle mod ls`    - provides list of all modules - installed and available
`cle mod add [modname]` - installs/upgrades module
`cle mod rm [modname]`  - module removal

Note that add/rm subcommands do not require full module name, you can use
just a part of the name and for the same reason prefix cle- or mod- is not
required. If more modules witih the same substring are found you will be able
to chose the right one using simple menu with numbered options. You can
interrupt the operation with Ctrl-C.

Module installation is simple - download the file and activate (execute the
code) if it's mod-* (cle-* is executed on demand only) On the other side,
module removal means not exactly deletion just the file is moved into
'$HOME/.cle/inactive'. Another fact is that any residuals of modules 
are still in memory of sessions started before removal. In other words, even
if mod-something has been removed, full deactivation happens in new session.


## 4. Modules repository

We've been talking about repository and downloading. The variables
`$CLE_SRC` points to the CLE repository. By default it is GitHub's URL
where everything around CLE is stored. You can however create your own
repository and change value of `$CLE_SRC` accordingly. Do this in following
cases:
1. you have your own CLE development branch
2. Copy of CLE is stored on different place. You can have protected
   infrastructure that has no access to GitHub but you want to have all
   resources available.

Set the `$CLE_SRC` in one of following files:
- account's tweak `$HOME/.cle-local`
- your personal tweak `$HOME/.cle-YOURNAME/tw` (remember this file is
  transferred and executed over all lssh/lsu/lsudo sessions. You might want to
  create 'if' statement and ensure redirecting only on particular hosts.)

Downloading of modules is done with `curl` utility. Any URL valid for curl
can be used. For this reason, the repository can be also a local folder when
URL of style `file://....` is used.


## 5. List of basic available modules

### cle-mod - the mods management
This one allows installations and removal other modules. The modularity is
built in CLE but module maintenace is kept in separate file. First request
to 'cle mod [operation]' downloads and install this file and then performs
the action. The 'cle-mod' is not required however. If you install/or create
your own modules manually they will work without this one.

### mod-mancolor
Almost descriptive name. This module doesn't add any new feature to the CLE.
It only defines LESS_TERMCAP_* variables with ansi escapes to colorize manual
pages.

### mod-fsps
Defines following filesystem and process related functions:
   `dfh` `dush` `dusk` `psg`
This module serves more as a concept but may be also practically useful.

### cle-rcmove
This module makes it easy to move CLE installation folder to a different
location. It's described in 'TipsAndTweks.md'.

### cle-ed
Add command `cle ed` as shortcut to various configuration files. See options
if you issue it without any option. Try e.g. `cle ed tw` and write your tweak
file that will run on every live session.

### mod-git
Functions / shortcuts to 'git' commands. Find all added functions
in built-in help (`cle help git`)

### mod-prompt
Contains pre-defined prompt settings. Besides the default one you can choose
between following:
`cle prompt rh`       - inspired by Red Hat's deault but with colors.
`cle prompt twoline`  - prompt on two lines, as its name says. It's almost the
                        same aone as described in document 'TipsAndTweaks.md'
`cle prompt triliner` - even more spacious prompt, adds an empty line for
                        better readability.

### cle-palette
This module changes color palettes. Set look and feel of your terminal with
following built-in palettes: `cga16`, `xterm`, `solarized`, `jellybeans`,
`gruvbox` or `rh`
Use the module as follows:
`cle palette`         - to view available color scheme names
`cle palette PALNAME` - set the terminal colors with selected palette
`cle palette show`    - display the palette colors
This module requires OSC capable terminal (xterm, VTE based terminals).

### mod-example
Template of module. Not available directly with, `cle mod` command. Find it
in github repository and  use how as an base of your own additions. Read next
(to be written) chapter.

### mod-lscreen
Implements GNU screen wrapper. When installed use following command:
 `lscreen [-j] [session_name]`
GNU screen requires this wrappaer mainly on remote sessions, where CLE is not
deployed and hooked into .bashrc. As an added value screen is started with
the customized configuration file $CLE_D/screenrc. This configuration contains
a fancy status line with a list of currently running screens and allows you to
switch between them with simple shortcuts such as Ctrl-Left/Right arrow.

GNU screen is often used to detach running session, when you disconnect from
network and reattach the same session later - leaving running tasks untouched.
CLE's enhanced `lscreen` makes this easier. It first looks for the detached
session and attach it if found.

You can run more sessions - if you specify 'session_name' as an optional parameter
the named session will be created (and might be joined later). The following is
the screen naming convention:

    $PID.$TTY-CLE.$CLE_USER[-session_name]
      e.g. '2785.pty3-CLE.mich'
      or   '2327.pty4-CLE.mich-research'

Check all this with the standard command `screen -ls`

Next, there is the option '-j'. Use this to search and join other users' sessions
to cooperate in multi-admin environments. Optional parameter 'session_name' 
narrows down searching through the list of all screens, not just those
invoked with CLE. When '-j' is used, no new screen is started, instead there is an
error message printed out if no session with the given name is found.

### mod-ltmux
Tmux wrapper implementation
TBD

## 6. How to write your own cool stuff
(This section needs to be written)

