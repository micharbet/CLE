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
      |      |           '^h'
      |     '\u'
   '^E \A'
```

In the prompt-part strings you can use backslash escapes as described in bash
manual plus enhnacing percent-sign escapes defined by CLE. Find their list below.

Now it worths to mention following: CLE works in Z-shell too. Despite different
prompt escapes used in zsh the environment ensures the bash prompt escapes can
be used in zsh! This was quite a challenge while development but enables great
portability. Well defined prompt will look the same on workstation where you 
use zsh and also transferred to remote live session runing bash.

Broad possibilities of zsh are however not disabled. You can still use them.
In such case two sets of shell defining items will appear in configuration.


### Related commands
- `cle p0|p1|p2|p3 ['prompt string']`
  Set p0-p3 strings, use either regular strings or escape sequences. Those
  can be backslash escapes described in `man bash` like e.g. \w, \u, \A, etc
  and following percent enhancements defined in CLE:

   ^g ... git working branch

   ^h ... shortened hostname, removed toplevel and subdomain, retaining other
          levels. E.g. six1.lab.brq.redhat.com would appear 'six1.lab.brq'

   ^H ... full host name - the value of $CLE_FHN. Ideally should be FQDN but
          it depends on system configuration. CLE makes best effort to obtain
          all domain information and reconstruct the hostname.

   ^i ... remote host IP

   ^U ... the name of original CLE user (value of $CLE_USER) - may be different
          than bash's '\u' 

   ^E ... the return code from most recent command enclosed in brackets, red if >0

   ^? ... most recent return code, the number only

   ^CX .. set color. Replace X with one of rgbcmykw or respective capitals.
          This overrides the color defined with 'cle color ...' command. In
          fact not only can 'rgbcmykw' be used, there are more! It looks for
          codes in the color table $_C* (inspect the list of items with command
          `echo ${!_C*}` that prints all variable names beginning with _C)
          The color table also cntains following codes:

            L .... bold

            D .... dim (doesn't work everywhere)

            I .... italic (also terminal dependent)

            V .... reverse fg/bg

            U .... underline

            u .... underline end

            e .... special error code highlight

            N .... reset all colors

            0-3 .. current color of corresponding prompt part 

          Note: color table is mostly created using the 'tput' command ensuring
          compatibility across systems and terminals.

   ^vVARIABLE
          Place any VARIABLE into prompt string. This will result in the following
          string: **VARIABLE=its_value**, which will display the name which may be
          convenient. Note that the value alone can be displayed by placing simple
          '$VAR' into the string. Both ways are useful to watch a variable or
          to display any dynamic content.

   ^^ ... the caret sign itself

  You may want to try e.g. following:
```
       cle p3 '\w MyText ^CW^vOLDPWD ^C3>'
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
     cle p0 '^Cg^E'    # green status
```

- `cle cf [ed|reset|rev]`
  Without argument shows configuration file if exists.
  You can reset prompt settings. Resetting removes configuration file.
  On workstation this means resets all prompt parts to default strings and
  color to 'marley' style. Reset on live session removes all local prompt
  definitions which causes fallback to strings inherited from workstation.

All prompt settings are immediately applied and stored in a configuration
file referenced with $CLE_CF. That means:
1. You don't need to restart your shell session to apply changes
2. Prompt settings will be remembered and reused automatically

- `cle title [off|string]`
  Sometimes it can be helplful to turn off the window titling feature. It
  should be off for consoles automatically, however in case of terminals
  without this capabilty some strange strings might appear. Use `cle title off`
  to avoid them.

  If you use any other string as a parameter the window title will be set
  accordingly. The title is rendered as part of prompt so all shell defined
  plus new CLE escapes can be used here.

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

Live sessions inherit following from CLE on workstation:
- the resource itself, so it can run
- tweak file, your very own commands that run everywhere
- aliases, yes, you define an alias and can use it anywhere else
- prompt settings - your prompt will look the same, except colors
- you can define variables that you need to transfer to other session

Remember, even if prompt settings are inherited, you can always use different
strings on live sessions. Use `cle p...` to override strings locally.

The tweak file ($CLE_TW) worths separate document as it is a very powerful
feature allowing you to customize the environment with your own script.
The tweak file is one for all sessions but can contain specific parts for
various destinations. Find more information in file _TipsAndTweaks.md_.



### Use following commands to initiate CLE sessions:

- `lssh [ssh-options] [account@]remote.host`
This command is in fact an 'ssh' wrapper that packs the whole CLE - creates
a copy of the rc file on a remote host and runs a bash session with the copied
environment. A new folder ($CLE_DR) is created on the remote system with
a resource file renamed to 'rc-$CLE_WS' plus local configuration. This folder
is by default created in /var/tmp directory. Previously home dir was used.
That would be natural way however, home might not necessarily exist - using
the temporary folder ensures successful start also in this case. Next, local
live session (e.g. lsudo) is initiated from the same files. Disabled read of
home folder could prevent startup of CLE for other users.  By default
the $CLE_DR is following: `/var/tmp/$USER/.cle-$CLE_USER`


- `lsu [account]`
- `lsudo [account]`
- `lksu [account]`
Those are wrappers to su/sudo/ksu commands. Use the appropriate one to switch
user context for your particular purpose. CLE is started from temporary folder
as discussed in paragraph above.

Unfortunately neither GNU `screen` nor `tmux` work optimaly with CLE. This is
due to fact that they are following login procedure which means:
- on workstation with deployed environment the CLE is started, which is ok
- on live remote sessions where CLE is typically not deployed, only regular
  shell session is started

Solution is to use wrappers `lscreen` eventually `ltmux` Both are however not
included in basic resource. You might want to install their respective modules
using `cle mod add lscreen` (or `cle mod add ltmux`) For more information about
those modules use `cle doc` and read file _Modules.md_.


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

Another side effects of the inheritance: once the alias was transferred to
the other account, it can be only removed with command `unalias` on all
touched systems separately. This is possible althought not very convenient
by placing `unalias not_needed_cmd` into tweak file.


## 5. History management

Command line history is enhanced in CLE:
1. _Regular shell history_ is almost untouched, the only tweak is timestamp
   record added to the commands. All the other features like 'ignore*' flags
   and history size definitions are kept. There is however an enhancement:
   function `h` - it displays the history in colors to easy distinguish
   commands from metadata.
2. _Rich history_ feature is added and managed by CLE. The rich history records
   keeps much more information, as expected by it's name. Particularly:
   - session-id (username and shell PID) 
   - time spent on execution
   - return code
   - folder where the command was issued
   The records are collected in file `$HOME/.clehistory` and its content can be
   viewed using command `hh` The rich history is persistent, the records are
   being added to the file and the file is never truncated.
   The rich history records are textual, one-per-line with following fields
   (as shown in terminal, internally they are separated by semicolon):

```
  2019-04-11 14:31:26 mich-b22793 3  0 	~/d/CLE : cls -al
    |           |      |          |  |  |          |
    |           |      |          |  |  |          |
    |           |      |          |  |  |          the command itself
    |           |      |          |  |  working directory
    |           |      |          |  |
    |           |      |          |  return code of the command
    |           |      |          time spent on the command
    |           |      session ID ( $CLE_USER-shellpid )
    date and time
```
Columns are diferentiated by colors so the command is clearly highlighted
and visible at first glance. Note also the red number showing non-zero return
code.

There are also special rich history records:
- a session start, denoted with '@' at the place of the return code with
  the terminal name and additional session originator info.
- notes: lines with hash at the begining don't do anything but are recorded
  Such you can place markers to rich history. Shown in yellow color on output.
- folder bookmarks are recorded with command `xx`
- variables - those special rich history records are created whenever you issue
  something like `echo $MYVARIABLE` 



### Searching through history

The function `h` is a simple shortcut to the regular 'history' command. It just
colorizes history output highlighting the command itself. Use the `h` with the
same parameters like the `history` command.

The new command `hh` works with the rich history. When issued without arguments
it prints out the 100 recent records. However, you can alter its behavior or
otherwise filter the output using options and arguments. Use the following
filters and their combinations:
- `hh string` to grep-search for the given string in the rich history file.
   The grep is applied to the whole file, so you can search for a specific
   date/time, a session identification, etc. As long as it uses grep, the
   search string can contain regular expressions.

Issue `hh` with options:
`-t` search only commands issued in the current session
`-d` narrow down search to current days sessions
`-s` filters only succesful commands (return code zero)
`-c` strip out additional information and display just commands
`-l` pass the output into 'less' command
`-f` instead of issued commands prints out visited folders
`-n` narrow output - omit timestamp leave more space for commands
`-m` my commands only, exclude other CLE user's entries that may
     appear in multi-admin environment

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

`cle update [master]`
Downloads the most recent version of CLE from the original source. Changes to
files can be reviewed before replacement. All steps must be acknowledged by the
user. By default the newest version of the release is downloaded. Using the
word 'master' as optional parameter you are trying to download from master
branch in guthub where even newer release can be published.

Update is meaningful on the CLE workstation. On remote sessions an upgrade have
only a temporary effect and can be used for testing



## 8. Files

The environment is stored by default into a subfolder named `.cle-username`
within the home directory. Technically speaking the folder containing CLE
is this:

   `$HOME/.cle-$CLE_USER`

The following files can be found there:
- `rc`                  The CLE itself ($CLE_RC)
- `cf-hostname`         Configuration file ($CLE_CF)
- `tw`                  User's own tweaks, executed upon CLE startup and also
                      transferred along with the main resource, and executed
                      on remote sessions ($CLE_TW)
- `al`                  Saved user's set of aliases ($CLE_AL)
- `mod-*` and `cle-*`   Modules enhancing CLE functionality.

The `rc`, `tw` and `al` files might have suffix '-hostname'. If not they are
used locally as a CLE workstation. The suffix presence indicates the origin
of those three files or in other words, from which workstation they have been
copied. On the other hand config file name contains local FQDN to allow
individual settings within NFS shared home folders.

Some files however remain in the main home directory:
- `.cle-local`          Local account's tweak file
- `.clehistory`         Rich history file ($CLE_HIST)



## 9. Variables

CLE defines its own shell variables. The most important and interesting ones
are named starting with "$CLE_*". There are also variables with shorter names
beginning with underscore, e.g color table ($_C*) or internal $_H, $_E, etc.
Command `cle env` shows values in the main variable set. The following is their
descriptions:

- `CLE_USER`  original user who first initiated the environment.
- `CLE_RC`    absolute path the CLE resource script itself
- `CLE_CF`    path to configuration file
- `CLE_TW`    custom tweak file
- `CLE_AL`    path to aliases store
- `CLE_DR`    path to folder containing resource files
- `CLE_D`     path to _writable_ folder with configuration files
- `CLE_WS`    workstation's hostname when running in live session
- `CLE_CLR`   prompt color scheme
- `CLE_Pn`    prompt-parts strings, running set
- `CLE_PBn`   user defined prompt-parts strings, bash compatible
- `CLE_PZn`   user defined prompt-parts, used only with zsh escapes
              if no CLE_PBn/CLE_PZn exits the prompt is defined by default
              or inherited strings
- `CLE_PT`    string defining terminal window title
- `CLE_IP`    contains IP address in case of remote session
- `CLE_FHN`   full hostname, ideally but not necessarily FQDN
- `CLE_SHN`   shortened hostname
- `CLE_FHN`   full hostname (FQDN)
- `CLE_HIST`  rich history file
- `CLE_EXE`   colon separated log of scripts executed by CLE
- `CLE_SRC`   url to git repo with  modules and documentation downloads
- `CLE_VER`   current environment version
- `CLE_MOTD`  ensures displaying /etc/motd upon remote login
- `CLE_HTF`   history time format
- `CLE_ENV`   path to file with exported environment
- `CLE_SH`    name of current shell
- `CLE_TTY`   terminal name

Note that filenames and paths are absolute unless explicitly mentioned!

There are more variables that are named with leading underscore. They are used
mainly internally, there's no need to access or change them unless you know
exacly what to do.

- `_Cx`         where x is any lettrer or number
              those variables define colors used in the environment
- `_PE, _Pe`    those two contain start and end of ANSI esc sequence for prompt
              This is important: color and other special sequences need to be
              enclosed so the shell can count the visible prompt characters.
- `_PN`         newline sequence for ZSH


### More details about some variables


### $CLE_USER

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


### $CLE_SHN - shortened hostname

Another thing that might seem strange: `$CLE_SHN` - what does 'shortened
hostname' mean? For example, let's say you are working in a company
'example.com' where internal infrastructure contains subdomains such as:
- prod.intranet.example.com 
- stage.intranet.example.com
- world.exapmle.com
And then imagine there are hosts named 'smtp' in all these domains. It is
useful to see the FQDN in the prompt to be sure where exactly you're working,
but the last two words - 'example.com' can be safely omitted in favor of
the prompt string length and readability. This is exactly what `$CLE_SHN`
contains and what will appear in the prompt when you use `^h`:
- smtp.prod.intranet
- smtp.stage.intranet
- smtp.world

In bash you can place '\h' (hostname only) or '\H' (FQDN) into the prompt.
CLE introduces shortened hostname that is in fact something in between.
Note that user can further manipulate the CLE_SHN string in the tweak file,
find more in document _TipsAndTweaks.md_.


### $CLE_AL and $CLE_ALW - two alias stores

On the workstation both point to the same file. Things are different in live
sessions. The `$CLE_ALW` points to a file with aliases copied from the
worktation and is executed first. This ensures you can use your aliases on
all sessions. The second one, `$CLE_AL` points to local store with aliases
used just on this particular account. This ensures you can redefine some of
inherited aliases or create new ones just for this system. Note. the local
definitions are not copied back to the workstation.



## 10. Advanced features and tweaks

CLE is modular. Modules are other scripts adding custom functionality
to the environment. During development it has been revealed that not every 
single idea has to be included (keeping the main code as small as possible).
Very specific functions have been (re)moved into modules and it is the users
choice to include them into his/her environment. It is also possible and easy
to write your own modules. This topic is covered in a separate document.
Read [[Modules]] to learn more.

CLE itself is a tweak but it can be customized even further. One way might
appear to be by editing the 'rc' file itself but this is discouraged. There are files
dedicated to exactly this goal. Find more information on how to use them
in the document [[TipsAndTweaks]]

In case of an issue in the main resource (the clerc file), if you feel some important
functionality is missing or if you just wrote a nice module that you
want to share follow the document [[ContributeAndFeedback]]

Love CLE? Hate it? Do you want to improve something? Read [[ContributeAndFeedback]] and chose any of the options how to report.


### Thank you for reading and using!


