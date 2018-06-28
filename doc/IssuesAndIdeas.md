## Known bugs
- There are errors in cases where the user login name contains spaces (on Windows)
- Some rich history entries are meaningless or contain weird information (scrn, cd)

## New feature Ideas
- dynamic window/screen title changes with current executed command
- preexec() and postexec() hooks
- highlight the command text also
- rework mdfilter to do the following:
  1. longer '~~~~~~~~' delimiter for code blocks
  2. no highlighting inside the code block
  (if it is even possible on **all** flavors of 'sed')
- split _setp into _setc and _setp
- enclose color table definition into function to allow override
- write separate command 'cle' for purpose of creating distribution packages
   -after installing packages user's environment will not be altered, but issuing 
    the simple command `cle` it will activate the environment
   -this command can contain some more functionality, add its calling into
    function 'cle'

- This might be another big change: rework rich history
  * dependency on $HISTTIMEFORMAT='%Y-%m-%d %T', maybe epoch time would be better
  * more info about command: +running time
  * the `hh` function is quite ugly

## Features, not bugs!
- rich history is updated after command finishes beacuse we need return codes!
- `suu` on debian based systems starts shell without controlling terminal
  This is a feature of the 'su' command there - it detaches terminal from process
  Check `man su` on debian.

