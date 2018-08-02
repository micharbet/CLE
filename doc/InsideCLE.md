# Internal CLE functions

CLE is written in the form of resource files sourced from .bashrc on your
workstation. This file installs its variables and functions into the current
interactive shell session. Variables are named starting with '$CLE_xxx' with
are some exceptions (color table '$_Cx'). Functions that are named with leading
underscores are meant to be used internally. Other functions like 'cle'
'hh' or 'aa' serve as users' commands

Besides the file 'clerc' there is another one called 'clerc-long'. The long version
contains enhanced comments. Those can help you to understand how the
environment works. Download and inspect this file from here:

  https://raw.githubusercontent.com/micharbet/CLE/master/clerc-long

Note: The code is identical, you can safely replace the long version in your
profile. All development edits happen in this file and enhanced comments
are removed automatically upon git commit.

