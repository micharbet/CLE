# Internal CLE functions

CLE is written in form of resource file sourced from .bashrc on your
workstation. This file installs it's variables and functions into current
interactive shell session. Variables are named mostly like '$CLE_xxx' and there
are some exceptions (color table '$_Cx'). Functions are named with leading
underscore - those are meant to be used internally. Other functions like 'cle'
'hh' or 'aa' serve as user's commands

Besides file 'clerc' there is another one 'clerc-long'. The long version
contains enhanced comments. Those can help you to understand how the
environment works. Download and inspect this file:

  https://raw.githubusercontent.com/micharbet/CLE/master/clerc-long

Note: The code is identical, you can safely replace long version in your
profile. All development edits are happening in this file and enhanced comments
are removed automatically upon git commit.

