# How to live with CLE

## Run and Deploy
Issue following commands to first run and hook the environment into bash
startup resource scripts.
```
. clerc
cle deploy user` or `cle deploy system
```

## Prompting

Prompt string has following parts and default values:

```
  [0] 13:25 user tweaked.hostname /working/directory >
    \   /    |          |                 |
     \ /     |          |                 P3='\w %> '
      |      |          P2='%h'
      |      P1='\u'
      P0='%e \A'
```

### Related commands
- `cle color COLORCODE`
  Set prompt colors. Values useful for COLORCODE can be chosen from predefined
  styles - red, green, blue, yellow, cyan, magenta, white, tricolora, marley
  or alternatively use 3-letter color codes consisting of letters rgbcmykw
  and RGBCMYKW, where capitals denotes bright version of the colour. Those
  three letters correspond with prompt parts P1-P3. Colour of P0 is always gray.

- `cle p0|p1|p2|p3` 'prompt string'
  Set P0-P3 strings, use either regular strings and special options. Special
  options cover all basic options described in `man bash` like e.g. \w, \u, \A,
  etc. and the set is enhanced by following CLE defined options
  (note character '%'):

   %h ... tweaked hostname, removed toplevel and subdomain, retaining other
          levels. E.g. six1.lab.brq.redhat.com shows like 'six1.lab.brq'

   %> ... similar to bash \$; dollar sign is replaced by '>' (I hate those $)

   %i ... remote host IP

   %u ... name of original CLE user (value of $CLE_USER)

   %e ... return code from recent command, in P0 it isenclosed in brackets
          and changing color

   %cX .. set color. Replace X with some of rgbcmykw or respective capitals
          this is an addition to previously set colors

   %vVARIABLE
      ... place any VARIABLE into prompt string

  Issuing command `cle p0` (or p1 .. p3 respectively) without string resets
  the default value of give prompt part.

- `cle time on|off`
  Turns server time in P0 on/off

- `cle reset`
  Resets prompt settings to default values including color to 'marley' style

All those prompt settings are immediately applied and stored in configuration
file .clecf-$CLE_USER.

- `cle title on|off`
  This in fact has nothing with prompt settings. Sometimes it can be helplful
  to turn off window titling feature. It should be done for console
  automatically however in case of terminal without this capabilty some strange
  strings might appear. Use `cle title off` to avoid them.


## CLE sessions (remote and local)

Purpose of this environment is to be seamlessly transferrable from workstation
to remote sessions without any installation. At the same time it allows
different users to use same remote account with different custom settings
and/or different CLE versions. This is useful in multi-admin environments. All
users, even on the same machine and account are perfectly separated with help
of variable $CLE_USER that is inherited over all sessions initiated from the
workstation. At the same time, no default settings on the remote servers are
altered so anybody who hates any change can still use old good ssh with its
poor settings.

Use following commands to initiate CLE sessions:
- `ssg [account@]remote.host`
This command is in fact 'ssh' wrapper that packs whole CLE - copies clerc file
to remote host and runs bash session with transferred environment. The
environment resource file is in home directory named .clerc-remote-$CLE_USER
where CLE_USER is first CLE username, typically logname from workstation.

- `suu [account]`
This command has similar functionality than `ssg` but it is sudo wrapper for
local sessions

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
`alias something='command --opt1 --opt2'`
`unalias removethis`
`aa s`

Now 'something' is saved into alias store file and recalled on all future CLE
startups. The second alias 'removethis' is deleted.


### Edit alias set
`aa edit` function runs editor on current working alias set allowing more
complex changes. Note that recent alias set is backed up.


### Reload aliases
Use `aa l` in case of mischmatch, if working alias set has been unintentionally
damaged, etc.


## History management

Command `hh` without parameters shows complete history list, exactly like
command `history`. Other functionalities in this version:

### Searching through history

-`hh number`    show last number of commands
-`hh string`    searches history list for given string using grep


### Sharing history between sessions

-`hh s`         immeditely appends current history into file
-`hh l`         loads history from file.

Use `hh s` in one session and `hh l` in another to history share. This doesn't
work over different remote sessions, of course.


## Updating
`cle update`
Downloads most recent version of CLE from the original source. Changes can be
reviewed before replacement. All steps must be acknowledged. Update is
meaningful only on the account or machine where CLE has been deployed. On
remote sessions it has just temporary effect.


## Documentation
-`cle help [command]`
  Prints out CLE's internal self-documentation strings.

-`cle readme`
  Downloads docs from CLE source.

-`cle man`
  Downloads and shows this file.

## Files
- .clerc or .clerc-remote-$CLE_USER
  The CLE itself.

- .clerc-local
  Local tweak file, executed upon each CLE startup

- .cleuser-$CLE_USER
  User's own tweak, executed upon CLE startup and also transferred along
  with ssg/suu

- .history-$CLE_USER
  Personal history file. History is enhanced with timestamps.

- .aliases-$CLE_USER
  Saved user's set of aliases.

- .cle/mod-*
  Modules enhancing CLE functionality.

- .cle/host-*
  Host related tweaks - transferred along with ssg and executed on particular
  host. This functionality in not implemented yet.


## Variables

CLE defines it's own shell variables. Most important and interesting ones are
named  obviously like $CLE_* There are some variables with shorter names like
e.g color table ($CT_*). Those variables can be inspected using command
 `cle env`

- CLE_RC       the CLE resource script itself
- CLE_USER     original user who first initiated the environment. This value
               is inherited over sessions. The most important variable here
- CLE_CF       configuration file name, typically $HOME/.clecf-$CLE_USER
- CLE_EXE      log and list of all files executed upon environment startup
- CLE_VERSION  self descriptive
- CLE_ALIASES  user's aliases store
- CLE_PCOLOR   prompt color
- CLE_P0 .. CLE_P3
               prompt parts strings defined with `cle p0 .. cle p3` command
- CLE_CUSTOMRC custom tweak file, typically $HOME/.cleusr-$CLE_USER if that
               file exists
- CLE_WTITLE   string to be terminal window title
- CLE_SRC      web store of CLE for updates and documentation downloads
- CLE_DIR      where are current cle files, usually its $HOME
- CLE_TODIR    if this value is set before remote ssg session starts, it causes
               the environment will be placed to other path than $HOME. This is
               useful on systems without home directories.
- CLE_IP       contains IP address in case of remote session


## CLE modules

...to be documented
