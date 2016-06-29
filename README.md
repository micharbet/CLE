# Command Live Environment
_The shell improvements :-)_

CLE contains following bash tweaks:
 - colorized prompt with server time and exit code highlight (customizable)
 - customizable aliases and functions
 - history tweaks (personalized history for multi-admin environment, timestamps etc)
 - shell options
 - controlled with comman 'cle'
 - ssg - the ssh wrapper (read below)
 - self contained help 


### CLE setup

All the above functionality is incoded into single file and no other
executalbes are needed. 
Run this file in the current shell using dot

    . clerc

The CLE is configured and you can make this permannet with command

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

