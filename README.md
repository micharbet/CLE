Command Live Environment
The shell improvements :-)

 bash tweaks
 - colorized prompt with exit code highlight
 - aliases and functions
 - history tweaks (personalized history for multi-admin environment, timestamps etc)
 - shell options

Run 'ssg remote.host' and the content of dot-clerc will be passed to the remote session
as resource script executed instead of .bashrc. This resource will be stored on remote 
account as .clerc-YOURNAME. Edit dot-clerc file locally and new version will be passed
to the remote system upon each login.

Useful files (on remote account):
 .aliases .aliases-YOURNAME for storing your own set of aliases, manage those
   with commands al, aload, alsav, aledi. E.g. create new alias and save it for
   future use using 'alsav' :-)
 .clerc_local file for local tweaks only on the particular machine



