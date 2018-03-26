
# How to live with CLE

This document covers following areas:
- installation
- new prompt look, its philosophy and customization
- session wrappers
- working with aliases
- rich history
- related files
- shell variables


## Run and Deploy
Issue following commands to first run and hook the environment into bash
startup resource scripts.

```
  . clerc
  cle deploy
```

You can as well run clerc as a regular script e.g.:

```
  chmod 755 clerc
  ./clerc
  cle deploy
```

Before deploying, you can test all the new features mentioned below like 
prompting, remote sessions, rich history, etc.

Important: do the deployment only on your working account. This will be
further referenced as 'CLE workstation' It is absolutely not necessary
to 'cle deploy' on all visited accounts. Also do not deploy CLE into root's
account. It would work without issues, basically no harm is expected, only
unexpected behaviour may occur in multi-admin evirinment (the one where more
people have administrator permissions). In case you use 'root' as your default
login and insist on that please kindly find and follow corresponding section
in file TipsAndTweaks.md


## Prompting

First thing you notice when you start CLE is the prompt. It has new colours
and provide more information. It is virtually divided into four parts p0 - p3
showing by default following info:

p0: exit code of recent command (non zero values are highlighted) + system time
p1: username
p2: shortened hostname
p3: current working directory and prompt character

Prompt parts strings are stored in variables $CLE_P0..3 and can be easily
inspect or changed using command  `cle p0..p3` moreover, each part can have
it's own color. The color scheme is manipulated using command `cle color`.
See below illustration and read description of prompt customization commands.

Prompt parts and default values:

```
     gray   red         yellow            green ('marley' scheme)
      |      |            |                 |
  [0] 13:25 user shortened.hostname /working/directory $
    \   /    |            |                 |
     \ /     |            |                 '\w %> '
      |      |            '%h'
      |      '\u'
      '%e \A'
```

### Related commands
- `cle p0|p1|p2|p3 ['prompt string']`
  Set p0-p3 strings, use either regular strings and special options. Special
  options cover all basic options described in `man bash` like e.g. \w, \u, \A,
  etc. and the set is enhanced by following CLE defined options
  (note character '%'):

   %h ... shortened hostname, removed toplevel and subdomain, retaining other
          levels. E.g. six1.lab.brq.redhat.com shows like 'six1.lab.brq'
          (the value of $CLE_SHN)

   %i ... remote host IP

   %u ... name of original CLE user (value of $CLE_USER)

   %e ... return code from recent command enclosed in brackets, red if >0

   %cX .. set color. Replace X with some of rgbcmykw or respective capitals
          This overrides the color defined with 'cle color ...' command. In
          fact. not only 'rgbcmykw' can be used, there are more. It looks for
          codes in color table $_C* (inspect the list of items with command
          `echo ${!_C*}` that prints all variable names beginning with _C)
          Color table also cntains following codes:

            L .... bold

            D .... dim (doesn't work everywhere)

            V .... reverse fg/bg

            U .... underline

            u .... underline end

            E .... special error code highiht

            N .... reset all colors

            0-3 .. color of corresponding prompt part 

          Note, color table is mostly created usint 'tput' command ensuring
          compatibility across systems and terminals.

   %vVARIABLE
      ... place any VARIABLE into prompt string. This will result in following
          string: `VARIABLE=its_value`, so showing also the name which may be
          convenient. Note that the value alone can be placed by simple $VAR.
          Both ways are useful to watch a variable or to display any own
          dynamic content

  You may want to try e.g. following:
```
       cle p3 '\w MyText %cW%vOLDPWD %c3>'
       cd /var/log
       -
       cd /etc
       cd            # observe the $OLDPVD variable
```

- `cle color COLORCODE`
  Set prompt colors. Values of COLORCODE string can be chosen from predefined
  styles - red, green, blue, yellow, cyan, magenta, white, tricolora, marley
  or alternatively use 3-letter color codes consisting of letters rgbcmykw
  and RGBCMYKW, where capitals denotes bright version of the colour. Those
  three letters correspond with prompt parts P1-P3. 

  Try for exapmle those commands, then find your very own style:
```
      cle color green
      cle color Cyg
      cle color tricolora    # set colours to your taste
```
Note that part zero is always gray by default. It is however possible to
change it e.g. like this:

     `cle p0 '%cW%e'    # bright white status`


- `cle time [off]`
  Toggles server time in P0 off or on.

- `cle reset`
  Resets prompt strings to default values and color to 'marley' style.
  Note: this employs function _defcf that can be tweaked, find respective
  document to learn more.

All prompt settings are immediately applied and stored in configuration
file referenced with $CLE_CF.

- `cle title [off]`
  This in fact has nothing with prompt settings. Sometimes it can be helplful
  to turn off window titling feature. It should be done for console
  automatically however in case of terminal without this capabilty some strange
  strings might appear. Use `cle title off` to avoid them.


_Note following:_ you can anytime inspect CLE variables with command `cle env`
with this you will opbtain list and values of all variables whose names start
with 'CLE_' e.g. If you configure prompt you can watch how CLE_CLR and CLE_Px
changes.


## CLE sessions (remote and local)

Purpose of this environment is not only to be nice but also to be practical
and useful. So it also seamlessly transfer itself from workstation to remote
sessions **without** any installation. At the same time it allows different
users to work on the same remote account with personalized settings and/or
different CLE versions. This is useful in multi-admin environments. All users,
even on the same machine and account (e.g. root) are working within their own
settings (prompt, aliases, history) separated with help of variable $CLE_USER
that is inherited from first login on workstation through all subsequent
sessions. At the same time, no default settings on the remote servers are
altered so anybody who hates any change can still use old good ssh (su, sudo)
and work in shell ith its default/poor settings.

Use following commands to initiate CLE sessions:

- `ssg [ssh-options] [account@]remote.host`
This command is in fact 'ssh' wrapper that packs whole CLE - copies rc file
to remote host and runs bash session with the transferred environment.
New folder is created on remote systems ($CLE_RD) where the rc itself (renamed
to rc-$CLE_WS) and local configuration are stored. This folder is by default
created in home directory but there might be a case where a user has no home.
If so, the $CLE_RD is created in /tmp.
By default the $CLE_RD is following: .cle-$CLE_USER

Remember, what is transferred from workstation is 'rc' file. Configuration
remains local for each visited account. This allows to differ prompt settings
for various destinations - this is another step to distinguish at first glance
not only commands and their outputs but also servers by their prompt colours.

In other words, set your own propmt using `cle color` and `cle p...` on each
account where you work.

Also if you use your own tweak file ($CLE_TW) it is packed along with resource
and executed on remote account. This is very powerful feature allowing you
to customize your environment in one own script. The tweak file can of course
contain specific parts for various destinations. Find more information
in file 'TipsAndTweaks.md'


- `suu [account]`
- `sudd [account]`
- `ksuu [account]`
Those are wrappers to su/sudo/ksu commands. Use appropriate one to switch user
context for your particular purpose. CLE is not transferred but the originating
$CLE_RC is re-used for switched session. Tweak file is executed too but prompt
configuration is own. Exactly like in case of `ssg`.


- `scrn [-j] [session_name]`
GNU screen requires this wrappaer mainly on remote sessions, where CLE is not
deployed and hooked into .bashrc. As added value screen is started with
customized configuration file $CLE_D/screenrc. This configuration contains
fancy status line with list of currently running screens and allows to switch
between them with simple shortcut Ctrl-Left/Right arrow.

There is also enhanced functionality that reattaches running sessions. The
wrapper first checks if there are sessions already running or detached.
Those are offered to join in cooperative mode (at the end it runs `screen -x`)
If no running/detached session is found the wrapper starts new one.

You can run more sessions - if you specify 'session_name' as optional parameter
the named session will be created (and might be joined later). Following is
screen naming convence:

    $PID.$TTY-CLE.$CLE_USER[-session_name]
      e.g. '2785.pty3.mich'
      or   '2327.pty4.mich-research'

Check all this with known command `screen -ls`

Next, there is option '-j'. Use this to search and join other user's sessions
to cooperate in multi-admin environments. Optional parameter 'session_name' 
narrows down searching through the list of all screens, not only those
invoked with CLE. When '-j' is used, no new screen is started. instead the
error message printed out if no session with given name is found.


## Alias management

CLE defines default aliases for basic commands like ls, mv, rm, and several cd
enhancements. Some of them are system dependent - there are different options
for colorful outputs in 'ls' etc. User can define it's own aliases and have
them stored for future use.

Watch `cle help` - it contains list of basic aliases defined idirectly inr
the environment and issue plain `aa` to see current set of aliases.

Variable $CLE_ALI refers to the file where aliases are stored. This file is
read upon environment startup. It may not exist in case no more than basic
aliases are set.

### Alias definition and save
Use known bash command `alias` and CLE function `aa` in following way:
```
   alias newalias='command --opt1 --opt2'
   unalias oldalias
   aa -s
```

Or, define and store new alias in one step:
```
   aa newalias='command --with options`
```

Now 'newalias' is saved into alias store file and recalled on all future CLE
startups. The 'oldalias' is deleted and will not appear in new sessions.


### Edit alias set
`aa -e` function runs editor on current working alias set allowing more
complex changes. Note that recent alias set is backed up.


### Reload aliases
Use `aa -l` in case of mischmatch, if working alias set has been unintentionally
damaged, etc.



## History management

Command line history in CLE is personalized in several ways:
1. Each user on the system has its own bash managed history that is stored
   in file $HOME/.history-$CLE_USER (this replaces .bash_history)
2. There is one file - $HOME/.history-ALL, managed by CLE routines where
   history of all commands issued by every user is collected. This is called
   the _rich history_

The rich history is persistent. That means the records are adding only to the
file not deleted, file is not truncated. As the rich history file grows it
holds complete history over time. Next, the word 'rich' refers to enhanced
information contained in each history record. The records are textual,
one-per-line with following fields:

```
  2017-06-30 14:31:26 mich-22793 0 /home/mich/d/CLE ls -al
    |           |      |         | |                |
    |           |      |         | |                issued command
    |           |      |         | working directory
    |           |      |         |
    |           |      |         return code of the command
    |           |      |
    |           |      session ID ( $CLE_USER-shellpid )
    date and time
```

Special record appears when session is started. Those are denoted with '@'
at the place of return code. In that case working directory contains terminal
name and instead of command there is additional information in square brackets.


### Searching through history

Function `h` is simple shortcut for regular 'history' command. Basically it
just colorizes it's output highliting sequence number and the command itself.
Use the `h` with the same parameters like `history` command. This just more
sophisticated alias.

New command `hh` works with the rich history.
When issued without arguments it prints out 100 recent records. However you
can alter it's behavior or in other words filter the output using options
and arguments. So use basic filters:
- `hh string` to grep search for given string in rich history file. The grep
  is applied to whole file, so you can search for specific date/time, session
  identification, you can use regular expressions, etc.
- `hh number` prints out recent 'number' records. Note the number can be in
  rane 1 .. 999.

Advanced filtering is done using options:
`-t` search only commands issued in current session
`-d` narrow down search to current day's sessions
`-s` filters only succesful commands (return code zero)
`-c` strip out additional information and output just commands
`-l` pass the output into 'less' command
`-f` instead of issued commands prints out visited folders

Examples:
- `hh -sc tar` - this prints out only successful 'tar' commands without rich
               information, ready for copy/paste.
- `hh -s 20`   - shows successful commands among recent 20 records
- `hh -t tar`  - search for all (successful or not) tar issued in this terminal
- `hh 06-24`   - search all commands issued on 24th June, regardless the year


## Searching for help

CLE contains built-in descriptions of its functions. Issue `cle help` to
extract those information. You can also obtain information about particular
buit-in function. Try e.g `cle help hh`

If you need more use command `cle doc` that downoads documentation index from
git source and offers files (incl. this one) through menu. Files are written
in .md (markdown) format and are passed through built-in function (mdfilter)
that hilights formatted items.

Self documenting feauture `cle help` automatically searches in all files
invoked upon startup, e.g. custom tweaks, modules, etc. All those texts
are nothing else just comments introduced with double hash `##`. It's that
simpe! Look at clerc itself as a good example.


## Keeping CLE fresh

`cle update`
Downloads the most recent version of CLE from the original source. Changes can
be reviewed before replacement. All steps must be acknowledged. Update is
meaningful only on the account where CLE has been deployed (CLE workstation).
On remote sessions it would have just temporary effect and is not recommended..


## Files

The environment is by default installed into home directory within subfolder
named `.cle-username` Technically speaking the folder with CLE is this:

   `$HOME/.cle-$CLE_USER`

Following files can be found there:
- `rc`                  The CLE itself ($CLE_RC)
- `cf`                  Configuration file ($CLE_CF)
- `tw`                  User's own tweaks, executed upon CLE startup and also
                      transferred along with the main resource, so executed
                      on remote sessions ($CLE_TW)
- `aliases`             Saved user's set of aliases ($CLE_ALI)
- `mod-*` and `cle-*`   Modules enhancing CLE functionality.

Some files however remain in main home directory:
- `.cle-local`          Local account's tweak file
- `.history-username `  Personal history file, bash managed.
- `.history-ALL`        Rich history file ($CLE_HIST)

The username is stored in the variable $CLE_USER - this is set upon login on
workstation and the variable is passed further into subsequent sessions.


## Variables

CLE defines it's own shell variables. Most important and interesting ones are
named like $CLE_* There are also variables with shorter names beginning with
underscore, e.g color table ($_C*) or internal $_H, $_E, etc. Command `cle env`
shows values in main variable set and following is their description:

- `CLE_USER`  original user who first initiated the environment.
- `CLE_D`     directory with configuration files
- `CLE_RC`    absolute path the CLE resource script itself
- `CLE_RD`    relative path to folder containing resource files
- `CLE_RH`    home directory part of path to resource file.
- `CLE_TW`    custom tweak file
- `CLE_CF`    path to configuration file
- `CLE_WS     contains hostname if started on workstation
- `CLE_CLR`   prompt color scheme
- `CLE_Pn`    prompt parts strings defined with command `cle p0 .. cle p3`
- `CLE_WT`    string to be terminal window title
- `CLE_IP`    contains IP address in case of remote session
- `CLE_SHN`   shortened hostname - main domain part removed
- `CLE_ALI`   user's aliases store
- `CLE_HIST`  path to rich history file
- `CLE_EXE`   colon separated log of scripts executed by CLE
- `CLE_SRC`   web store of CLE for updates and documentation downloads
- `CLE_VER`   current environment version

Let's get back to the variable `$CLE_USER` - the most important variable here.
You might notice how often is the variable mentioned here. It's value is set
upon first login on the workstation and then is passed further into all
subsequent sessions (ssg, suu, sudd...) There it becomes part of pathnames and
ensures private space even on shared accounts (e.g. when root is accessed by
more users)


## Advanced features and tweaks

CLE is modular. Modules are just another scripts adding custom functions
to the environment. Over the development it has revealed that not every 
single idea has to be included (keeping the main code as small as possible).
Very specific functionalities have been (re)moved into modules and it's
user's choice to include them into his/her environment. It is also possible
and easy to write own modules. This topis is covered in separated document.
Read _Modules.md_ to learn more.

CLE itself is a tweak but it can be customized further more. One way might
seem to be editing 'rc' file itself but this is discouraged. There are files
dedicated to exactly this purpose. Find more information on how to use them
in document _TipsAndTweaks.md_

In case of issue in main resource (the clerc file), if you feel there is
missing important functionality or if you just wrote nice module that you
want to share follow the document _Contribute.md_

Love CLE? Hate it? Do you want to improve something? Read _Feedback.md_ and
chose any of the options how to report.

Thank you for reading and using!

