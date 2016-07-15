#   Command Live Environment
## _The shell improvements :-)_


## Content
 - What is CLE
 - Setup and usage
 - CLE internals
 - ToDo list
 - Why CLE + history
 
## What is CLE 
CLE contains following bash tweaks:
 - colorized **prompt** with server time and exit code highlight (customizable)
 - personalized and customizable **aliases** and functions
 - **history** tweaks (personalized history for multi-admin environment
   incl. timestamps)
 - shell options
 - controlled with command `cle`
 - **ssg** - the ssh wrapper
 - **suu** - the sudo wrapper
 - self contained **help** (check this out: `cle help`)
 - can show this file with `cle readme`


## CLE setup and usage
All the mentioned functionality is encoded into __single file__ and no other
executables are needed. Run this file in the current shell context using
trailing dot:

    . clerc

The CLE is activated now and you can setup this environment as persistent with
command:

    cle deploy user

CLE copies itself to `$HOME/.clerc` and adds two lines into your `.bashrc`
si it will be started upon each login. Note this is the *only* one
installation step you need to perform. Typically you'd do it on your account
on your workstation.

There is also possibility to setup CLE systemwide. Issue command
`cle deploy system` and content of active resource file will be copied
into `/etc/profile.d/cle.sh` thus activated for all users on that particular
machine. This step is however not required.


### ssg utility (ssh wrapper)

The CLE is able to pass itself over ssh. Use 'ssg' wrapper instead of regular
ssh for login into remote account and CLE will be copied and started seamlessly
and also without altering current remote server environment. Run

    ssg username@remote.host

The content of clerc will be passed to the remote session and executed as a
resource script instead of .bashrc. The resource is stored on the remote 
account in file `.clerc-tmp-YOURNAME`. So from the name you can see that the
file is jus temporary - it can be (and will be) overwritten on another login.
Also note that the filename contains your name - this is to clearly distinguish
users accessing the same account (e.g. multiple administrators)


### suu utility (sudo wrapper)

The 'suu' does the same job like ssg bout it transfers CLE over sudo command.
You can run `suu` alone or `suu username`. Without username the root
is chosen by deafult, obviously.

### Useful files
 `.aliases` `.aliases-YOURNAME` for storing your own set of aliases, manage those
   with commands al, alilo, alisav, alied. You can e.g. create new alias
   directly on the command line, test it, improve and when satisfied save it
   for future use using `alisa` :-)

 `.clerc_local` file for small local tweaks only on the particular machine -
    this is not transferred with `ssg / suu`

 `.cleprompt` or `.cleprompt-YOURNAME` - this file is created automatically and
   stores current prompt settings

## CLE internals

First, look at the script :-)
However you can inspect variables. They are named with trailing `$CLE_` Check 
all of them with command `cle env`. Another command shows you list of all
related files: `cle ls`


## CLE ToDo List:

- bash completion for ssg
- create mosh wrapper similar to ssh
- ~~create su/sudo wrapper~~
- ~~cle deploy system~~
- troubleshooting section
- cle edit
- man page
- find way to turn off cle on particular account when it is deployed systemwide
- more prompt tweaks: e.g. 'cle retcode on/off' 'cle wintitle on/off'
- ~~allow passing local aliases further~~ `$CLE_MYFILES` variable for this and more
- regarding CLE_MYFILES, consider 'cle command' to maintain this
- ~~custom defined functions in .functions file~~ plugins in $HOME/.cle/ folder!
- custom .clerc-NAME maybe instead of .clerc_local
- what about 'cle update' that would download fresh new version from GIT?? (WIP)
- cle backup might be nice
- add 'Tweaks' section in this document


## Why 'CLE' and where are previous versions?

 CLE was developed over years of work in command line, where I always tried
to have easily distinguished prompt. It has been always possible to accomplish
this goal in diferent ways. Mainly editing resource files like .bashrc .kshrc
and/or manually transfer those files to each server and account. So the very
first version was just a backup of my .kshrc (long, long ago I used mainly
Korn Shell) This version does exist probably on some old boxes or maybe in
scattered backup files. You all probably have something similar.

 Second version contained resource file itself and minimal set of
utilities (scripts like 'cle', 'hlp', etc - some of them are part of different
project 'rootils' now) This version worked without 'ssg' however required to be
installed on each particular account. This was much easier using 'cle' script
but still it was necessary step and and affected remote account with changes
that might be also unwelcome by other administrators. BTW, in version 2 current 
name "Command Live Environment" was introduced as I considered it was bringing
more live into plain command line. This version was developed in specific
armed forces controlled environment and is not publicly available.

 In third version I removed necessity to setup by ingenious way -
passing resource file encoded with base64 through a shell variable to the
remote system. Result is no setup, no other tweaks on remote site  and no harm
to the current environment! Whoa! The only what you need is working CLE on
your workstation that you are using to manage the world :-)
You can always use the same and still customizable environment everywhere.
Encoding `ssg`, `suu` utilities and `cle` managment script into the sinle file
was just a nature evolution that enhanced word 'Live'. The `clerc` resource
file now contains a mechanism of multiplication it's own DNA [1] This all with
embeded self documentation and ways of customization.


[1] CLE is not a virus :-) all the mutliplication is done in controlled way
and you, the user is the one who know what you're doing.
