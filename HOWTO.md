
# How to live with CLE

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
          this is an addition to previously set colors

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

All those prompt settings are immediately applied and stored in configuration
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

- `suu [account]`
- `sudd [account]`
- `kksu [account]`
Those are wrappers to su/sudo/ksu commands. Use appropriate one to switch user
context for your particular purpose. CLE is not transferred but the current
.clerc-YOURNAME is re-used for switched session.

- `scrn [-r]`
GNU screen requires this wrappaer mainly on remote sessions, where CLE is not
deployed. As added value screen is started with newly generated configuration
file .screenrc-$CLE_USER. This configuration contains nice status line with
list of currently running screens and allows to switch between them with simple
shortcut Ctrl-Left/Right arrow. Also before starting the screen itself it
check if there are sessions already running. Those are offered to join and
cooperate in shared mode or alternatively you can take control over such
sessions if you issue 'scrn -r'

Remember, what is transferred from workstation is '.clerc' file. Configuration
remains stored locally on machine and in separated file for each user. This
allows to use different prompt settings on various accounts - this is another
step to distinguish not only commands and their outputs but also servers
by their prompt colours.


## Alias management

CLE defines default aliases for basic commands like ls, mv, rm, and several cd
enhancements. Some of them are system dependent - there are different options
for colorful outputs in 'ls' etc. User can define it's own aliases and have
them stored for future use.

### alias definition and save
Use known bash command `alias` and CLE function `aa` in following way:
```
   alias something='command --opt1 --opt2'
   unalias removethis
   aa s
```

Command `aa` without any parameter show current alias set in nicer way than
original built-in command.

Now 'something' is saved into alias store file and recalled on all future CLE
startups. The second alias 'removethis' is deleted.

### Edit alias set
`aa ed` function runs editor on current working alias set allowing more
complex changes. Note that recent alias set is backed up.

### Reload aliases
Use `aa l` in case of mischmatch, if working alias set has been unintentionally
damaged, etc.

Note: there is `_defalias` built-in function that defines basic alias set upon
each CLE start. Those predefined aliases override the ones saved with 'aa s'
command. However, the function itself can be replaced. Learn more in further
documentation.


## History management

CLE intorduces persisten rich history. Persistent means that the record are
not deleted. The file can grow to megabytes and holds complete history over
the time. The word 'rich' points to more information contained in each
history record. this history file exists besides 'regular' file. So in fact
there are two history files:
1. convenitional bash managed but personalized in CLE, .history-$CLE_USER
2. rich history file .history-ALL
Note that .history-ALL is not personalized and stores record from all sessions
and from all users (e.g. inenvironments where more real users access root's
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

New command `hh` works with rich history. When issued without arguments
it prints out 100 recent records. However you can alter it's behavior or in
other words filter the output using options and arguments. So use:
- `hh string` to grep search for given string in rich history file. The grep
  is applied to whole file, so you can search for specific date/time, session
  identification, you can use regular expressions, etc.
- `hh number` prints out recent 'number' records. Note the number can be in
  rane 1 .. 999.

Options allowed in 'hh' are as follows:
`-t` search only commands issued in current session
`-s` filters only succesful commands (return code zero)
`-c` strips out additional information and output just commands

Examples:
- `hh -sc tar` - this prints out only successful 'tar' commands without rich
               information, ready for copy/paste.
- `hh -s 20`   - shows successful commands among recent 20 records
- `hh -t tar`  - search for all (successful or not) tar issued in this terminal
- `hh 06-24`   - search all commands issued on 24th June, regardless the year


## Searching for help

CLE can assist you. There is help built-in script itself, issue `cle help` to
extract those information. Basically they are contained in double-hashmark
denoted comments. It's that somple. In case you need more use command `cle doc`
that downoads documentation index from git source and offers files (like this
one) through menu. Files are in .md (markdown) format and are filtered through
built-in function (mdfilter) hilighting formatted items.


## Keeping CLE fresh

`cle update`
Downloads most recent version of CLE from the original source. Changes can be
reviewed before replacement. All steps must be acknowledged. Update is
meaningful only on the account or machine where CLE has been deployed. On
remote sessions it has just temporary effect.


## Files

Here comes list of files that plays various roles in the environment. Some
of them are executed upon sartup, others are created to hold specific infos.

- .clerc or .clerc-remote-$CLE_USER
  The CLE itself.

- .clerc-local
  Account's local tweak file

- .cleusr-$CLE_USER
  User's own tweaks, executed upon CLE startup and also transferred along
  with .clerc whem 

- .history-$CLE_USER
  Personal history file, bash managed.

- .history-ALL
  Rich history file managed by CLE

- .aliases-$CLE_USER
  Saved user's set of aliases.

- .cle/mod-*
  Modules enhancing CLE functionality.


## Variables

CLE defines it's own shell variables. Most important and interesting ones are
named  obviously like $CLE_* There are some variables with shorter names like
e.g color table ($CT_*). Those variables can be inspected using command
 `cle env`

- CLE_USER     original user who first initiated the environment. This value
               is inherited over all local and remote sessions. The most
               important variable here
- CLE_D        directory with configuration files
- CLE_DRC      directory containing resource files might differ from $CLE_D
               Note, DIR and DRC are usually $HOME but not necesarily. they may
               differ in case $HOME does't exist and/or on local 'su' sessions
               Also: CLE_D must be writable, CLE_DRC can be read-only
- CLE_RC       the CLE resource script itself
- CLE_RCU      custom tweak file, typically $HOME/.cleusr-$CLE_USER
- CLE_CF       path to configuration file, typically $HOME/.clecf-$CLE_USER
- CLE_EXE      log and list of all files executed upon environment startup
- CLE_VER      current environment version
- CLE_ALIASES  user's aliases store
- CLE_PCOLOR   prompt color
- CLE_Pn       prompt parts strings defined with command `cle p0 .. cle p3`
- CLE_WT       string to be terminal window title
- CLE_SRC      web store of CLE for updates and documentation downloads
- CLE_IP       contains IP address in case of remote session
- CLE_THN      tweaked hostname - main domain part removed
- CLE_HIST     path to rich history file
- CLE_EXE      colon separated log of scripts executed by CLE


## CLE modules and further tweaks
...to be documented in separate file

