# Command Live Environment
_The shell improvements :-)_

CLE contains following bash tweaks:
 - colorized **prompt** with server time and exit code highlight (customizable)
 - personalized and customizable **aliases** and functions
 - **history** tweaks (personalized history for multi-admin environment, timestamps etc)
 - shell options
 - controlled with command `cle`
 - **ssg** - the ssh wrapper (read below)
 - self contained **help** 


### CLE setup

All the above functionality is encoded into __single file__ and no other
executalbes are needed. Run this file in the current shell using dot

    . clerc

The CLE is configured now and you can make this permannet with command

    cle deploy user

CLE copies itself to $HOME/.clerc and add two lines into your .bashrc
si it will be started upon each login. Note this is the *only* one
installation step you need to perform.


### ssg utility (ssh wrapper)

The CLE is able to pass itself over ssh. Use 'ssg' wrapper instead of regular
ssh for login into remote account and CLE will be copied and started seamlessly
and also without altering current remote server environment. Run

    ssg username@remote.host

The content of clerc will be passed to the remote session and executed as a
resource script instead of .bashrc. This resource is stored on the remote 
account as .clerc-YOURNAME.

### Useful files
 .aliases .aliases-YOURNAME for storing your own set of aliases, manage those
   with commands al, alilo, alisav, alied. You can e.g. create new alias
   and save it for future use using 'alisa' :-)

 .clerc_local file for small local tweaks only on the particular machine -
    not transferred wit ssg



### CLE ToDo List:

- bash completion
- include mosh wrapper similar to ssh
- cle deploy system
- cle edit
- man page


*** Why 'CLE' and where are previous versions?

 CLE was developed over years of work in command line, where I always tried
to have easily distinguished prompt. It has been always possible to accomplish
this goal in diferent ways. Mainly editing resource files like .bashrc .kshrc
and/or manually transfer those files to each server and account. So the very
firs version was just a backup of my .kshrc (long, long ago I used mainly
Korn Shell) This version does exist probably on some old boxes or maybe in
scattered backup files. You all probably have something similar.

 Second version contained resource itself and minimal set of
utilities (scripts like 'cle', 'hlp', etc - some of them are part of different
project 'rootils') This version worked without 'ssg' however required to be
installed on each particular account. This was much easier using 'cle' script
but still it was necessary step and and affected remote account with changes
that might be unwelcome by other administrators. BTW, in version 2 current 
name "Command Live Environment" was introduced as I considered it was bringing
more live into plain command line. This version was developed in specific
armed forces controlled environment and is not publicly available.

 In third version I solved issues with necessity of setup by ingenious way -
passing resource file encoded with base64 through a shell variable to the
remote system. Result is no setup and no harm to current environment! Whoa!
And you can always use the same and still customizable environment everywhere.
Encoding `ssg` utility and `cle` managment script into the sinle file was just
a nature evolution that enhanced word 'Live'. The `clerc` resource file now
contains a mechanism of multiplication it's own DNA 1) This all with embeded
self documentation and ways of customization.


1) CLE is not a virus :-) all the mutliplication is done in controlled way
and you, the user is the one who know what you're doing.
