
#        CLE Tips And Tweaks
  ---------- a.k.a. TNT ------------
  warning highly explosive material!
  ----------------------------------

This document presents useful ideas how to customize CLE to your very own
preferences. Some tips may require to install additional software.


## Prompting
The first thing you may want to customize. Go beyond just color change!

### Nice double line prompt
```
cle p0 '\A'
cle p1 '%h (%i)\n'
cle p2 '%cK%e %u -> %cL\u'
cle p3 '\w %>'
```

### Five shades of grey
`cle p3 '\w %cW>%cw>%cN>%cK>%ck>'`
Employs escape sequences from bright white through 'normal' to black. Looks
good on "Solarized" color theme in terminal. Try to reverse the order.

### Something similar but in any color
`cle p3 '\w %cR>%cr>%cD>'`
This uses 'D' - terminal escape sequence for dim attribute

### Show previous working directory in prompt
`cle p3 '(%vOLDPWD) \w %>'
You will see where have you been before most recent 'cd something'. Try to
issue `cd -` or simple `-` to switch between PWD and OLDPWD.

### GIT branch in prompt?
`cle p3 '\w%cy:$([ -d .git -o -d ../.git ] && git symbolic-ref --short HEAD) %cW%>'`
Simply executes `git symbolic-ref --short HEAD` whenever there is .git directory
underneath. Note, this is not CLE feature! Pure bash is able to execute
commands if there is something like PS1='string $(the_command) other string'


## Various startup files

## How to enhance 'cle' command

## Override internal functions


