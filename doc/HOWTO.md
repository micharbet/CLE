
# How to live with CLE
This document covers once again installation. Also understanding of its
components, how to customize the environment and initiating sessions.


## Run and Deploy
Issue following commands to first run and hook the environment into bash
startup resource scripts.

```
  . clerc
  cle deploy
```

It is important to start the environment using a dot (ev. command 'source')
to run it in current shell context. Do not make file 'clerc' executable.


## Prompting

Prompt string has following parts and default values:

```
  [0] 13:25 user tweaked.hostname /working/directory >
    \   /    |          |                 |
     \ /     |          |                 CLE_P3='\w %> '
      |      |          CLE_P2='%h'
      |      CLE_P1='\u'
      CLE_P0='%e \A'
```

### Related commands
- `cle color COLORCODE`
  Set prompt colors. Values useful for COLORCODE can be chosen from predefined
  styles - red, green, blue, yellow, cyan, magenta, white, tricolora, marley
  or alternatively use 3-letter color codes consisting of letters rgbcmykw
  and RGBCMYKW, where capitals denotes bright version of the colour. Those
  three letters correspond with prompt parts P1-P3. Colour of P0 is always gray.

- `cle p0|p1|p2|p3 ['prompt string']`
  Set P0-P3 strings, use either regular strings and special options. Special
  options cover all basic options described in `man bash` like e.g. \w, \u, \A,
  etc. and the set is enhanced by following CLE defined options
  (note character '%'):

   %h ... tweaked hostname, removed toplevel and subdomain, retaining other
          levels. E.g. six1.lab.brq.redhat.com shows like 'six1.lab.brq'

   %> ... similar to bash \$; dollar sign is replaced by '>' (I hate those $)

   %i ... remote host IP

   %u ... name of original CLE user (value of $CLE_USER)

   %e ... return code from recent command enclosed in brackets, red if >0

   %cX .. set color. Replace X with some of rgbcmykw or respective capitals
          This overrides the color defined with 'cle color ...' command. In
          fact. not only 'rgbcmykw' can be used, there are more. It looks for
          codes in color table $_T* (inspect the list of items with command
          `echo ${!_T*}` - print all variable names beginning with _T)
          Non color items are as follows:

            L ... bold

            D ... dim

            V ... reverse fg/bg

            U ... underline

            u ... underline end

            E ... special error code highiht

            N ... reset all colors

   %vVARIABLE
      ... place any VARIABLE into prompt string. This will result in following
          string: `VARIABLE=its_value`, so showing also the name which may be
          convenient. Note that the value alone can be placed by simple $VAR.

  Without 'prompt string' current value of respecive part is printed.

- `cle time [off]`
  Turns server time in P0 off or on if no parameter is given.

- `cle reset`
  Resets prompt strings to default values and color to 'marley' style.
  Note: this employs function _defcf that can be tweaked, find respective
  document to learn more.

All prompt settings are immediately applied and stored in configuration
file .clecf-$CLE_USER.

- `cle title [off]`
  This in fact has nothing with prompt settings. Sometimes it can be helplful
  to turn off window titling feature. It should be done for console
  automatically however in case of terminal without this capabilty some strange
  strings might appear. Use `cle title off` to avoid them.


## CLE sessions (remote and local)

Purpose of this environment is also seamless transferr itself from workstation
to remote sessions without any installation. At the same time it allows
different users to workon the same remote account with personalized settings
and/or different CLE versions. This is useful in multi-admin environments. All
users, even on the same machine and account are perfectly separated with help
of variable $CLE_USER that is inherited over all sessions initiated from the
workstation. At the same time, no default settings on the remote servers are
altered so anybody who hates any change can still use old good ssh (su, sudo)
into an account with its default/poor settings.

Use following commands to initiate CLE sessions:

- `ssg [account@]remote.host`
This command is in fact 'ssh' wrapper that packs whole CLE - copies clerc file
to remote host and runs bash session with transferred environment. The
environment resource file is in home directory named .clerc-remote-$CLE_USER
where CLE_USER is first CLE username, typically logname from workstation.

Remember, what is transferred from workstation is '.clerc' file. Configuration
remains stored locally on machine and in separated file for each user. This
allows to use different prompt settings on various accounts - this is another
step to distinguish not only commands and their outputs but also servers
by their prompt colours.

- `suu [account]`
- `sudd [account]`
- `kksu [account]`
Those are wrappers to su/sudo/ksu commands. Use appropriate one to switch user
context for your particular purpose. CLE is not transferred but the current
.clerc-YOURNAME is re-used for switched session.

- `scrn [-j] [session_name]`
GNU screen requires this wrappaer mainly on remote sessions, where CLE is not
deployed and hooked into .bashrc. As added value screen is started with
customized configuration file .screenrc-$CLE_USER. This configuration contains
nice status line with list of currently running screens and allows to switch
between them with simple shortcut Ctrl-Left/Right arrow.

Before start it checks if there are sessions already running or detached.
Those are offered to join in cooperative mode (in fact it runs `screen -x`)

This wrapper is ready to environments where there might be e.g. multiple
administrators. If issued without arguments it checks if you already have
opened and/or detached sessions and joins them if found. Otherwise it creates
new one. Such new session is always named by following convence:

    $PID.$TTY-CLE.$CLE_USER  e.g. '2785.pty3.mich'

So again, CLE_USER is the key to find your session. You can run more sessions
if you add session_name as parameter, then it will be named like e.g.
'2785.pty3.mich-session_name' Check all this with `screen -ls`

There is option '-j' use this to search and join other user's sessions to
cooperate in multi-admin environments. The parameter 'session_name' in this
case narrows down searching but doesn't create new session. Using option `-j`
you are searching through all screen session, not only those invoked with CLE.


## Alias management

CLE defines default aliases for basic commands like ls, mv, rm, and several cd
enhancements. Some of them are system dependent - there are different options
for colorful outputs in 'ls' etc. User can define it's own aliases and have
them stored for future use.

### Alias definition and save
Use known bash command `alias` and CLE function `aa` in following way:
```
   alias newalias='command --opt1 --opt2'
   unalias oldalias
   aa -s
```

Define and store new alias in one step:
```
   aa newalias='command --with options`
```

Now 'newalias' is saved into alias store file and recalled on all future CLE
startups. The 'oldalias' is deleted and will not appear in new sessions.

Command `aa` without any parameter shows current alias set in nicer way than
original built-in command.


### Edit alias set
`aa -e` function runs editor on current working alias set allowing more
complex changes. Note that recent alias set is backed up.


### Reload aliases
Use `aa -l` in case of mischmatch, if working alias set has been unintentionally
damaged, etc.

Note: there are predefined aliases that are set to their defaults upon each CLE
start. To see them inspect function '_defalias' either in clerc code or with
command `decalre -f  _defalias`.


## History management

CLE introduces persistent rich history. Persistent means that the records are
not deleted, file is not truncated. The file can grow to megabytes and holds
complete history over time. The word 'rich' refers to amount of information
contained in each history record. This history file exists besides 'regular'
file. So in fact there are two history files:
1. convenitional bash managed .history-$CLE_USER (replaces .bash_history)
2. rich history file .history-ALL
Note that .history-ALL is not personalized and stores record from all sessions
and from all users (e.g. in environments where more real users access root's
account). This rich history file cosist of one-per-line record in following
format:

```
  2017-06-30 14:31:26 mich-22793 0 /home/mich/d/CLE ls -al
    |           |      |         | |                |
    |           |      |         | |                issued command
    |           |      |         | working directory
    |           |      |         return code of the command
    |           |      session ID ( $CLE_USER-shellpid )
    date and time
```

Special record appears when session is started. Those  are denoted with '@'
at the place of return code. In that case working directory contains terminal
name and instead of command there is additional information in square brackets.


### Searching through history

Function `h` is simple shortcut for regular 'history' command. Basically it
just colorizes it's output highliting sequence number and the command itself.
Use the `h` with the same parameters like `history` command. This just more
sophisticated alias.

New command `hh` works with rich history.
When issued without arguments it prints out 100 recent records. However you
can alter it's behavior or in other words filter the output using options
and arguments. So use:
- `hh string` to grep search for given string in rich history file. The grep
  is applied to whole file, so you can search for specific date/time, session
  identification, you can use regular expressions, etc.
- `hh number` prints out recent 'number' records. Note the number can be in
  rane 1 .. 999.

Options allowed in 'hh' are as follows:
`-t` search only commands issued in current session
`-d` narrow down search to current day's sessions
`-s` filters only succesful commands (return code zero)
`-c` strips out additional information and output just commands
`-l` pass the output into 'less' command
`-f` instead of issued commands prints out their working directories (folders)

Examples:
- `hh -sc tar` - this prints out only successful 'tar' commands without rich
               information, ready for copy/paste.
- `hh -s 20`   - shows successful commands among recent 20 records
- `hh -t tar`  - search for all (successful or not) tar issued in this terminal
- `hh 06-24`   - search all commands issued on 24th June, regardless the year


## Searching for help

CLE contains built-in descriptions of its functions. Issue `cle help` to
extract those information. In principle they can be found as double-hashmark
denoted comments. It's that simple. If you need more use command `cle doc`
that downoads documentation index from git source and offers files (incl. this
one) through menu. Files use .md (markdown) format and are passed through
built-in function (mdfilter) hilighting formatted items.

You can also obtain information about particular buit-in function. Try e.g.
  `cle help hh`

Self documenting feauture `cle help` automatically searches in all files
invoked upon startup, e.g. custom resources, modules, etc. All those texts
are nothing else just comments introduced with `##`. Look at .clerc itself
as a good example.


## Keeping CLE fresh

`cle update`
Downloads most recent version of CLE from the original source. Changes can be
reviewed before replacement. All steps must be acknowledged. Update is
meaningful only on the account where CLE has been deployed (CLE workstation).
On remote sessions it would have just temporary effect and is not allowed.


## Files

Here comes list of files that plays various roles in the environment. Some
of them are executed upon sartup, others are created to hold specific infos.

- `.clerc` or `.clerc-remote-$CLE_USER`
  The CLE itself.
- `.clerc-local`
  Account's local tweak file
- `.cleusr-$CLE_USER`
  User's own tweaks, executed upon CLE startup and also transferred along
  with .clerc whem 
- `.history-$CLE_USER`
  Personal history file, bash managed.
- `.history-ALL`
  Rich history file managed by CLE
- `.aliases-$CLE_USER`
  Saved user's set of aliases.
- `.cle`
  Working directory for various other CLE stuff
- `.cle/mod-*`
  Modules enhancing CLE functionality.


## Variables

CLE defines it's own shell variables. Most important and interesting ones are
named like $CLE_* There are alse variables with shorter names beginning with
underscore, e.g color table ($_T*) or internal $_H, $_E, etc. Command 'cle env'
shows values in main variable set and following is their description:

- `CLE_USER`  original user who first initiated the environment. This value
            is inherited over all local and remote sessions. The most
            important variable here!
- `CLE_D`     directory with configuration files
- `CLE_DM`    directory for modules and enhancements
- `CLE_DRC`   directory containing resource files might differ from $CLE_D
            Note, CLE_D and CLE_DRC are usually $HOME but not necesarily.
            They may differ in case $HOME does't exist and/or when 'su*'
            session has been initiated. Also: CLE_D must be writable while
            CLE_DRC can be read-only.
- `CLE_RC`    the CLE resource script itself
- `CLE_RCU`   custom tweak file, typically $HOME/.cleusr-$CLE_USER
- `CLE_CF`    path to configuration file, typically $HOME/.clecf-$CLE_USER
- `CLE_CLR`   prompt color
- `CLE_Pn`    prompt parts strings defined with command `cle p0 .. cle p3`
- `CLE_WT`    string to be terminal window title
- `CLE_IP`    contains IP address in case of remote session
- `CLE_THN`   tweaked hostname - main domain part removed
- `CLE_ALI`   user's aliases store
- `CLE_HIST`  path to rich history file
- `CLE_EXE`   colon separated log of scripts executed by CLE
- `CLE_SRC`   web store of CLE for updates and documentation downloads
- `CLE_VER`   current environment version


## Advanced features and tweaks

CLE is modular. Modules are just another scripts adding custom functions
to the environment. Over the development it has revealed that not every 
single idea has to be included (keeping the main code as small as possible).
Very specific functionalities have been (re)moved into modules and it's
user's choice to include them into his/her environment. It is also possible
and easy to write own modules. This topis is covered in separated document,
read 'Modules.md' to learn more.

CLE itself is a tweak but it can be customized further more. One way might
seem to be edit 'clerc' file but this is discouraged. There are plenty of
files (see above) that are dedicated to exactly this purpose. Find more
information on how to use them in document 'TipsAndTweaks.md'

In case of issue in main resource (clerc file), if you feel there is
missing important functionality or if you just wrote nice module that you
want to share follow the document 'Contribute.md'

Love CLE? Hate it? Do you want to improve something? Read 'Feedback.md' and
chose any of the options how to report.

Thank you for reading and using!

