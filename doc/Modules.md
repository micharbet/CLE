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
`cle mod avail` - downloads index and displays modules available in repository
`cle mod ls`    - provides list of installed modules
`cle mod add [modname]` - installs/upgrades module
`cle mod del [modname]` - module removal

Note that add/del subcommands do not require full module name, you can use
just a part of the name and for the same reason prefix cle- or mod- is not
required. If more modules wit the same substring are found you will be able
to chose the right one. If you do not provide any module name all of them *)
are offered as numbered options. You can interrupt operation with Ctrl-C.
*) all of them means all available for operation 'add' and all installed for
operation 'del'

Module installation is simple - download the file and activate (execute the
code) if it's mod-* (because cle-* and bin/* are executed on demand only) On
the other side, module removal means not exactly deletion just the file is
moved int $HOME/.cle/inactive. Another fact is that any residuals of modules 
are still in memory of sessions started before removal. In other words, even
if mod-something has been removed, full deactivation happens in new session.


## 4. Modules repository

We've been talking about repository and downloading. There is variable 
`$CLE_SRC` that points to the CLE repository. By default is is GitHub's
URL where everything around CLE is stored. You can however create your own
repository and change value of `$CLE_SRC` accordingly. Do this in following
cases:
1. you have your own CLE development branch
2. Copy of CLE is stored on different place. You can have protected
   infrastructure that has no access to GitHub but you want to have all
   resources available.
3. anything else...

Set the `$CLE_SRC` in one of following files:
- account's tweak `$HOME/.cle-local`
- your personal tweak `$HOME/.cle-YOURNAME/tw` (remember this file is
  transferred and executed over all ssg/su/sudo sessions. You might want to
  create 'if' statement and ensure redirecting only on particular hosts.)
- /etc/cle-systweak - global files for all CLE sessions on particular host
 (^^^ this needs to be done!)

Downloading of modules is done with `curl` utility. Any URL valid for curl
can be used. For this reason, the repository can be also a local folder when
URL of style `file://....` is used.


## 5. List of basic available modules

### cle-mod - the basic one
This one allows installations and removal other modules. The modularity is
built in CLE but module maintenace is kept in separate file. First request
to 'cle mod [operation]' downloads and install this file and then performs
the action. The 'cle-mod' is not required however. If you install/or create
your own modules manually they will work.

### mod-mancolor
Almost descriptive name. This module doesn't add any new feature to the CLE.
It only defines LESS_TERMCAP_* variables with ansi escapes to colorize manual
pages.

### mod-fsps
Defines following filesystem and process related functions:
   `dfh` `dush` `dusk` `psg`
They appear in `cle help` output. Those functions could be safely be defined
as aliases, but why not to have this :-)

### cle-rcmove
This module makes it easy to move CLE installation folder to a different
location. It's described in 'TipsAndTweks.md'.

### cle-hist
Rich history by default starts with using CLE and doesn't contain items
from `.bash_history` file. This module is able to import old records.
However the only information that may be contained in old history file is
timestamp. No return code and other information may be restored. Imported
records will be marked with session ID like 'username-OLD' and working
directory will be shown as '/un/known' and they all will appear at the
beginning of rich file. Use command `cle hist import`
 Note: upon very first start of CLE on the account, the `.bash_history` is
 copied into personal file `.history-username` so all regular seraching
 methods like 'Ctrl-R' will work.
Planned features of this modules are: removing selected entries, archiving
and restoring.

### mod-git
Functions / shortcuts to 'git' commands. Maybe the most useful is function
`gicwb`. It simply prints out curren working branch (hence it's name) and is
useful if you want to display that information in prompt. Document
'TipsAndTweaks.md' provides an example of such use. Find all added functions
in built-in help (`cle help gi`)

### mod-example
Template of module. Use it how it names.


## 6. How to write your own cool stuff
(This section needs to be written)

