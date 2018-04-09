## Known bugs
- errors in case the user login name contains spaces (on Windows)
- some rich history entries are meaningless or contain weird information (scrn, cd)

## New feature Ideas
- dynamic window/screen title changes with current executed command
- preexec() and postexec() hooks
- highlight also the command text
- rework mdfilter to do following:
  1. longer '~~~~~~~~' delimiter for code blocks
  2. no highlighting inside the code block
  (if it is even possible on **all** flavors of 'sed')

- This might be another big change: rework rich history
  * dependency on $HISTTIMEFORMAT='%Y-%m-%d %T', maybe epoch time would be better
  * more info about command: +running time
  * the `hh` function is quite ugly
  * new module to convert previous history into rich file (with some info missing)

## Features, not a bugs!
- rich history is updated after command finishes beacuse we need return code!
- `suu` on debian based systems starts shell without controlling terminal
  This is feature of 'su' command there - it detaches terminal from process
  Check `man su` on debian.

