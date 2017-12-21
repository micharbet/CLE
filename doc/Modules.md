# Use modules to enhance CLE funcionality

## What are modules

In addition to basic fuctionalities the CLE is in fact extensible framework.
Various modules can be added to enhance or modify the environment. For example
CLE doesn't contain functions to backup/restore settings. If there is a module
providing this it can be downloaded and installed. Important word here is
"to download". Remember, CLE itself is one resource file only! But it can
execute several files if they exist. CLE uses it's own repository to find and
download those files on user's request. The reason for using own repository
is compatibility among various distributions and operating systems so there
is no dependancy on rpm/deb/other packaging system nor the OS flavour (meaning
Linux/*BSD/Solaris/...)

Modules are internally stored in `$HOME/.cle folder`. Various types of modules 
can be found here as decribed in next chapter.


## Module types

Following modules are available in CLE:
- _mod-*_ this code is executed upon each CLE session startup
  Those modules may implement new bash functions, replace original CLE
  functions and alter variables.
- _cle-*_ contain scripts provides enhanced functionality to `cle` command
  Modules of this kind resides in the folder but are called on demand and
  only through command `cle` Good example is 'cle-mod'. This module contains
  code for working with modules itself, like adding, removing, etc. When you
  issue command `cle mod add` execution is redircted into `$HOME/.cle/cle-mod`
- _bin/*_ are not true modules but rather standalone / independent scripts
  Those files are stored in `$HOME/bin` folder. This folder is also added to
  `$PATH` when CLE starts. In contrast to true modules those files are not
  executed/sourced within the shell context (not `. $HOME/.cle/mod-*`) For
  this reason they cannot alter CLE environment. They are standalone scripts
  and in fact they can be coded in any language. Reason for including those
  scripts into CLE is ease of distribution from networked repository.


This table provides overview of module types and their main properties

```
          executed    can alter    can use        is
         on startup   variables   functions   independent 
                         and       defined      of CLE
                      functions   in .clerc
         ------------------------------------------------------
  mod-*      yes         yes         yes
  cle-*                  yes         yes
  bin/*                                          yes
```


## How to use modules

There is command `cle mod` for that puprpose. This command is somehow special.
When you inspect `.clerc` you can find corresponding section within `case`
statement. But this section just literally downloads module _cle-mod_ from
repository. When the module (for working with modules) is downloaded it will
be executed by `cle mod` command. Following is overview of subcommands:

`cle mod`       - shows URL of module repository and destination folder
`cle mod help`  - provides short overview of module related commands
`cle mod avail` - this downloads and displays moduls available in repository
`cle mod ls`    - provides list of modules installed in $HOME/.cle folder
`cle mod add [modname]` - installation/upgrade of module
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


## Module repository

We've been talking about repository and downloading. There is variable 
`$CLE_SRC` that points to the CLE repository. By default is is GitHub's
URL's where everything about CLE is saved. You can however create your own
repository and change value of `$CLE_RC` accordingly. Do this in following
cases:
1. you have your own CLE development branch
2. Copy of CLE is stored on different place. You can have protected
   infrastructure that has no access to GitHub but you want to have all
   resources available.
3. anything else...

Set the `$CLE_SRC` in one of following files:
- `$HOME/.clerc-local` on each account you need to alter
- `$HOME/.cleusr-YOURNAME` (remember this file is transferred and executed
  over all ssg/su/sudo sessions, for this you might want to create 'if'
  statement for this.)
- /etc/clerc-system - global files for all CLE sessions on particular host
 (^^^ this needs to be done!)

Downloading of modules is ensured with `curl` utility. Any URL valid for curl
can be used. For this reason, the repository can be also a local folder when
URL of tyle `file://....` is used.


## How to write your own cool stuff
(This section needs to be written)

