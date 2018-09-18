
# How to live with CLE

This document explains the philosophy of the environment and provides all
necessary details about its features and new commands. Chapters about
files and varibles provide brief insight to internals.

## Content
1. Run and Deploy
2. Prompting
3. CLE sessions (remote and local)
4. Alias management
5. History management
6. Searching for help
7. Keeping CLE fresh
8. Files
9. Variables
10. Advanced features and tweaks


## 1. Run and Deploy
Issue the following commands to first run and hook the environment into bash
startup resource scripts.

```
  . clerc
  cle deploy
```

You can also run clerc as a regular script with the same effect:

```
  chmod 755 clerc
  ./clerc
  cle deploy
```

Before deploying, you can test all the new features mentioned below like 
prompting, remote sessions, rich history, etc.

Important: do the deployment only on your working account. This will be
further referenced as 'CLE workstation'. It is absolutely not necessary
to run 'cle deploy' on all visited accounts. Also, do not deploy CLE into root's
account. It would work without issues, and would not cause any harm to the system,
but unexpected behaviour may occur in multi-admin environments (for example: more
then one person has administrator permissions). In case you insist on using 'root'
as your default login please kindly follow the corresponding section
in the file "TipsAndTweaks.md".


## 2. Prompting

The first thing you notice when you start CLE is the prompt. It has new colors
and provides more information. It is divided into four parts numbered p0 - p3
showing the following info by default:

p0: exit code of recent command (non zero values are highlighted) + system time
p1: username
p2: shortened hostname
p3: current working directory and prompt character

Prompt-part strings are stored in variables $CLE_P0..3 and can be easily
inspected or changed using the command `cle p0..p3`. Moreover, each part can have
its own color. The color scheme is manipulated using the command `cle color`.
See the below illustration and read descriptions of prompt customization commands.

Prompt parts and default values:

```
     gray   red         yellow            green ('marley' scheme)
      |      |            |                 |

  [0] 13:25 user shortened.hostname /working/directory $

    \   /    |            |                 |
     \ /     |            |              '\w \$'
      |      |           '%h'
      |     '\u'
   '%e \A'
```

In the prompt-part strings you can use backslash escapes as described in bash
manual plus enhnacing percent-sign escapes defined by CLE. Find their list below.


### Related commands
- `cle p0|p1|p2|p3 ['prompt string']`
  Set p0-p3 strings, use either regular strings or escape sequences. Those
  can be backslash escapes described in `man bash` like e.g. \w, \u, \A, etc
  and following percent enhancements defined in CLE:

   %h ... shortened hostname, removed toplevel and subdomain, retaining other
          levels. E.g. six1.lab.brq.redhat.com would appear 'six1.lab.brq'
          (the value of $CLE_SHN)

   %i ... remote host IP

   %u ... the name of original CLE user (value of $CLE_USER) - may be different
          than bash's '\u' 

   %e ... the return code from most recent command enclosed in brackets, red if >0

   %cX .. set color. Replace X with one of rgbcmykw or respective capitals.
          This overrides the color defined with 'cle color ...' command. In
          fact not only can 'rgbcmykw' be used, there are more! It looks for
          codes in the color table $_C* (inspect the list of items with command
          `echo ${!_C*}` that prints all variable names beginning with _C)
          The color table also cntains following codes:

            L .... bold

            D .... dim (doesn't work everywhere)

            V .... reverse fg/bg

            U .... underline

            u .... underline end

            e .... special error code highlight

            N .... reset all colors

            0-3 .. current color of corresponding prompt part 

          Note: color table is mostly created using the 'tput' command ensuring
          compatibility across systems and terminals.

   %vVARIABLE
          Place any VARIABLE into prompt string. This will result in the following
          string: **VARIABLE=its_value**, which will display the name which may be
          convenient. Note that the value alone can be displayed by placing simple
          '$VAR' into the string. Both ways are useful to watch a variable or
          to display any dynamic content.

  You may want to try e.g. following:
```
       cle p3 '\w MyText %cW%vOLDPWD %c3>'
       cd /var/log
       -
       cd /etc
       cd            # observe the $OLDPVD variable
```
  HINT: `cle` uses completion and particularly for prompting it can insert
    current prompt string. This means you don't have to define it from scratch or
    copy and paste. Just type e.g. following `cle p3` and press <TAB>

- `cle color COLORCODE`
  Set prompt colors. Values of COLORCODE string can be chosen from predefined
  styles - red, green, blue, yellow, cyan, magenta, white, tricolor, marley
  or alternatively use 3-letter color codes consisting of the letters rgbcmykw
  and RGBCMYKW, where capitals denotes bright version of the color. Those
  three letters correspond with prompt parts P1-P3. 

  Try these commands for example, then find your very own style:
```
      # set colors to your taste
      cle color green
      cle color Cyg
      cle color tricolora
```

Note that part #0 (status+time) is always gray by default. It is
possible to change it like this:
```
     cle p0 '%cg%e'    # green status
```

- `cle time [off]`
  Toggles server time in P0 off or on.

- `cle reset`
  Resets prompt strings to default values and color to 'marley' style.
  Note: this employs the function _defcf that can be tweaked, find the
  appropriate document to learn more.

All prompt settings are immediately applied and stored in a configuration
file referenced with $CLE_CF. That means:
1. You don't need to restart your shell session to apply changes
2. Prompt settings will be remembered and reused automatically

- `cle title [off]`
  This has nothing to do with prompt settings. However, sometimes it can be
  helplful to turn off the window titling feature. It should be off for consoles
  automatically, however in case of terminals without this capabilty some strange
  strings might appear. Use `cle title off` to avoid them.


_Note the following:_ you can inspect CLE variables with command `cle env`.
With this you will obtain a list and values of all variables whose names start
with 'CLE_' e.g. If you configure your prompt you can watch how CLE_CLR and CLE_Px
changes.


## 3. CLE sessions (remote and local)

The purpose of CLE is not only to be friendly but also to be practical
and useful. It seamlessly transfers itself from workstation to remote
sessions **without** any installation. At the same time it allows different
users to work on the same remote account with personalized settings and/or
different CLE versions. This is useful in multi-admin environments. All users,
even on the same machine and account (e.g. root@anyserver) are working within
their own settings (prompt, aliases, history) separated with help of variable
$CLE_USER that is inherited from the first login on the workstation through
all subsequent sessions. At the same time, no default settings on the remote
servers are altered so anyone who hates changes can still use default ssh, su
and sudo and work in their shells with default/poor settings.


### Use following commands to initiate CLE sessions:

- `lssh [ssh-options] [account@]remote.host`
This command is in fact an 'ssh' wrapper that packs the whole CLE - creates a copy
of the rc file on a remote host and runs a bash session with the copied environment.
A new folder ($CLE_RD) is created on the remote system with a resource file renamed
to 'rc-$CLE_WS' plus local configuration. This folder is by default created
in the home directory however there might be a case where the user has no home.
If so, the $CLE_RD is created in /tmp.
By default the $CLE_RD is named the following: .cle-$CLE_USER

Remember, what is transferred from workstation is the 'rc' file. Configuration
remains local for each visited account. This allows different prompt settings
for various destinations - this is another step to help distinguish at a glance
not only commands and their outputs but also servers by their prompt colors.

In other words, set your own prompt using `cle color` and `cle p...` on each
account where you work.

Also, if you use your own tweak file ($CLE_TW) it is packed along with the resource
and executed on the remote account. This is a very powerful feature allowing you
to customize your environment in your own script. The tweak file can of course
contain specific parts for various destinations. Find more information
i then file 'TipsAndTweaks.md'.


- `lsu [account]`
- `lsudo [account]`
- `lksu [account]`
Those are wrappers to su/sudo/ksu commands. Use the appropriate one to switch user
context for your particular purpose. CLE is not transferred but the originating
$CLE_RC is re-used for switched session. The tweak file is executed too but the
prompt configuration is your own, exactly like in the case of `lssh`.


- `lscreen [-j] [session_name]`
GNU screen requires this wrappaer mainly on remote sessions, where CLE is not
deployed and hooked into .bashrc. As an added value screen is started with
the customized configuration file $CLE_D/screenrc. This configuration contains
a fancy status line with a list of currently running screens and allows you to
switch between them with simple shortcuts such as Ctrl-Left/Right arrow.

There is also enhanced screen functionality that reattaches to running sessions. The
wrapper first checks if there are sessions already running or detached.
Those are offered to join in cooperative mode (at the end it runs `screen -x`)
If no running/detached session is found the wrapper starts a new one.

You can run more sessions - if you specify 'session_name' as an optional parameter
the named session will be created (and might be joined later). The following is
the screen naming convention:

    $PID.$TTY-CLE.$CLE_USER[-session_name]
      e.g. '2785.pty3.mich'
      or   '2327.pty4.mich-research'

Check all this with the standard command `screen -ls`

Next, there is the option '-j'. Use this to search and join other users' sessions
to cooperate in multi-admin environments. Optional parameter 'session_name' 
narrows down searching through the list of all screens, not just those
invoked with CLE. When '-j' is used, no new screen is started, instead there is an
error message printed out if no session with the given name is found.


## 4. Alias management

CLE defines only basic aliases for coloring output of some commands (ls,grep).
A user can define their own alias set that is saved in a file and restored in
each new session. New function `aa` enhances possibilities 

Use new command `aa` without any argument to review the current set of aliases.
Use

### Alias definition and save
Use the standard bash command `alias` or new CLE function `aa` in the following
ways:
```
   alias newalias='command --opt1 --opt2'
```

Or, use shortened form:
```
   aa newalias='command --with options`
```

Remove unwanted alias in known way:
```
   unalias oldalias
```

Now 'newalias' is saved into the alias store file and recalled on all future CLE
startups. The 'oldalias' is deleted and will not appear in new sessions.
All changes are automatically saved into file referenced in variable $CLE_AL
This file is read upon environment initialization.



### Edit alias set
The `aa -e` function runs an editor on the current working alias set allowing more
complex changes. Note that the current alias set is backed up first.


### Aliases and sessions
Alias set on CLE workstation is copied over remote sessions. That means if
you define `newalias` as previous example and use `lssh` to visit another host
you will have `newalias` available also there. You can define new aliases on
the remote account but they will of course not be transferred back to the
workstation. Note that alias existence might not necessarily mean that it will
work. Two such situation can occur and here is their troubleshooting:

 1. original command is missing - just ignore that alias
 2. the command on remote host has different options - override the inherited
    definition either with vlid options or without them
     `alias command='command'`


## 5. History management

Command line history in CLE is personalized in several ways:
1. Each user account on the system has its own bash managed history that is stored
   in the file $HOME/.history-$CLE_USER (this replaces .bash_history)
2. There is one file - $HOME/.history-ALL, managed by CLE routines where
   the history of all commands issued by every user is collected. This is called
   the _rich history_

The rich history is persistent. That means the records are being added to
the file and the file is not truncated. As the rich history file grows it holds
a complete history over time. Next, the word 'rich' refers to enhanced
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

Special records appear when a session is started. Those are denoted with an '@'
at the place of the command return code. Then, the part that would normally ne the 
working directory contains the terminal name and instead of the command there is
additional information in square brackets.


### Searching through history

The function `h` is a simple shortcut for the regular 'history' command. Basically it
just colorizes its output highlghting sequence number and the command itself.
Use the `h` with the same parameters of the `history` command. This is simply a more
sophisticated alias.

The new command `hh` works with the rich history.
When issued without arguments it prints out the 100 recent records. However, you
can alter its behavior or otherwise filter the output using options
and arguments. Use the following basic filters:
- `hh string` to grep-search for the given string in the rich history file. The grep
  is applied to the whole file, so you can search for a specific date/time, a session
  identification, or you can use regular expressions, etc.
- `hh number` prints out the most recent 'number' records. Note: the number can be in
  the range 1 .. 999.

Advanced filtering is done using these options:
`-t` search only commands issued in the current session
`-d` narrow down search to current days sessions
`-s` filters only succesful commands (return code zero)
`-c` strip out additional information and display just commands
`-l` pass the output into 'less' command
`-f` instead of issued commands prints out visited folders

Examples:
- `hh -sc tar` - this prints out only successful 'tar' commands without rich
               information, ready for copy/paste.
- `hh -s 20`   - shows successful commands among recent 20 records
- `hh -t tar`  - search for all tar commands (successful or not) issued in this terminal
- `hh 06-24`   - search all commands issued on 24th June, regardless of the year


## 6. Searching for help

CLE contains built-in descriptions of its functions. Issue `cle help` to
extract this information. You can also obtain information about particular
buit-in functions. Try `cle help hh` for example.

The self documenting feauture `cle help` automatically searches in all files
invoked upon startup, e.g. custom tweaks, modules, etc. All those texts
are nothing other than comments introduced with a double hash `##`. It's that
simple! Look at clerc itself as a good example.

If you need more, use the command `cle doc` that will download the documentation
index from the git source and which offers files (including this one) through a menu.
Files are written in .md (markdown) format and are passed through a built-in function
(mdfilter) that highlights formatted items.


## 7. Keeping CLE fresh

`cle update`
Downloads the most recent version of CLE from the original source. Changes to files
can be reviewed before replacement. All steps must be acknowledged by the user.
Additionally, the update is only applied to the account where CLE has been deployed,
the CLE workstation. On remote sessions an upgrade would just have a temporary effect
and is not recommended.


## 8. Files

The environment is installed by default into the home directory within a subfolder
named `.cle-username`. Technically speaking the folder containing CLE is this:

   `$HOME/.cle-$CLE_USER`

The following files can be found there:
- `rc`                  The CLE itself ($CLE_RC)
- `cf`                  Configuration file ($CLE_CF)
- `tw`                  User's own tweaks, executed upon CLE startup and also
                      transferred along with the main resource, and executed
                      on remote sessions ($CLE_TW)
- `al`                  Saved user's set of aliases ($CLE_AL)
- `mod-*` and `cle-*`   Modules enhancing CLE functionality.

Some files however remain in the main home directory:
- `.cle-local`          Local account's tweak file
- `.history-username `  Personal history file, managed by bash
- `.history-ALL`        Rich history file ($CLE_HIST)

The username is stored in the variable $CLE_USER - this is set upon login to the
workstation and the variable is passed further into subsequent sessions.
See the next section for details.

## 9. Variables

CLE defines its own shell variables. The most important and interesting ones are
named starting with "$CLE_*". There are also variables with shorter names beginning with
underscore, e.g color table ($_C*) or internal $_H, $_E, etc. Command `cle env`
shows values in the main variable set. The following is their description:

- `CLE_USER`  original user who first initiated the environment.
- `CLE_D`     absolute path to folder with configuration files
- `CLE_RC`    absolute path the CLE resource script itself
- `CLE_RD`    relative path to folder containing resource files
- `CLE_RH`    home directory part of path to resource file.
- `CLE_TW`    custom tweak file
- `CLE_CF`    path to configuration file
- `CLE_WS`    contains workstation's hostname on remote session
- `CLE_CLR`   prompt color scheme
- `CLE_Pn`    prompt-parts strings defined with command `cle p0 .. cle p3`
- `CLE_WT`    string to be terminal window title
- `CLE_IP`    contains IP address in case of remote session
- `CLE_SHN`   shortened hostname
- `CLE_AL`    user's aliases store
- `CLE_HIST`  path to rich history file
- `CLE_EXE`   colon separated log of scripts executed by CLE
- `CLE_SRC`   base of store for modules and documentation downloads
- `CLE_REL`   release name, $CLE_SRC/$CLE_REL points to content above
- `CLE_VER`   current environment version
- `CLE_MOTD`  ensures displaying /etc/motd upon remote login

### More details about some variables

Let's get back to the variable `$CLE_USER` - the most important variable here.
You might notice how often this variable is mentioned here. Its value is set
upon first login on the workstation and then it is passed further into all
subsequent sessions (lssh, lsu, lsudo...). When CLE initializes, one of the first
things it has to do is to determine the username. The trick is that it doesn't
necessarily follow value of the regular variable $USER. Username here is part of
the path to the resource file. E.g. if path is '/home/foo/.cle-mich/rc' the
string **'mich'** will be extracted and stored in $CLE_USER. Such CLE ensures:
1. private configuration on shared accounts or multi-admin environments (when
   root is accessed by multiple users)
2. custom tweaks and command line histories will be available
3. accountability

Another thing that might seem strange: `$CLE_SHN` - what does 'shortened hostname'
mean? For example, let's say you are working in a company 'example.com' where
internal infrastructure contains subdomains such as:
- prod.intranet.example.com 
- stage.intranet.example.com
- world.exapmle.com
And then imagine there are hosts named 'mail' in all these domains.
It is useful to see the FQDN in the prompt to be sure where exactly you're working,
but the last two words - 'example.com' can be safely omitted in favor of the prompt
string length and readability. This is exactly what `$CLE_SHN` will contain
and what will appear in the prompt when you use `%h`:
- mail.prod.intranet
- mail.stage.intranet
- mail.world
In plain bash you can place '\h' (hostname only) or '\H' (FQDN) into the prompt.
This is a workaround - something in between.


## 10. Advanced features and tweaks

CLE is modular. Modules are other scripts adding custom functionality
to the environment. During development it has been revealed that not every 
single idea has to be included (keeping the main code as small as possible).
Very specific functions have been (re)moved into modules and it is the users
choice to include them into his/her environment. It is also possible and easy
to write your own modules. This topic is covered in a separate document.
Read _Modules.md_ to learn more.

CLE itself is a tweak but it can be customized even further. One way might
appear to be by editing the 'rc' file itself but this is discouraged. There are files
dedicated to exactly this goal. Find more information on how to use them
in the document _TipsAndTweaks.md_

In case of an issue in the main resource (the clerc file), if you feel some important
functionality is missing or if you just wrote a nice module that you
want to share follow the document _Contribute.md_

Love CLE? Hate it? Do you want to improve something? Read _Feedback.md_ and
chose any of the options how to report.


### Thank you for reading and using!


