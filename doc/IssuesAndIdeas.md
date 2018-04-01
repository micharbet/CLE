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

## Features, not a bugs!
- rich history is updated after command finishes beacuse we need return code!
- `suu` on debian based systems starts shell without controlling terminal
  This is feature of 'su' command there - it detaches terminal from process
  Check `man su` on debian.

