# Frequently Asked Questions about CLE

## 1. How fast is the CLE
This question must be answered in multiple parts:
a) Truth is that the environment startup employs reading and executing of
kilobytes of code. However on contemporary systems, the delay is virtually
unnoticeable. Except really slow hardware (e.g. Raspbeery Pi 1)
b) Here it worths to mention that there are routines executed upon every
prompt string. However they are composed exclusively of shell internal
functions resulting in fast code even on mentioned raspberry!
c) The code and tweaks are copied to the destination host. Files are packed
with tar, gzipped and pushed over ssh connection. Here the delay caused by
additional data transfer may be measured but in practice it is hard to spot
on fast networks. Even oversea connection is initiated sooner than you may
get annoyed. (and in those cases, the ping RTT matters more so characters
echoing will be slow anyway)


## 2. Does it work on my system?
As long as your system is posix compatible, it should work.
Minilal requirements are as follows:
- shell: bash ver 3+ and/or zsh ver. 5+
- coreutils: tar, base64, sed, su, sudo
- network commands: curl, ssh
- ncurses: tput
- optional: screen, ksu
Generally, the base installation matches the requirements. CLE is developed
and tested on following operating systems:
- Linux (various distributions, the oldest one RHEL/CentOS 5)
- OSX
- Free / Net BSD
Reported correct fuctionality on Windows 10.


## Will it work with `ash` and busybox?
Simple answer is no.
First, there are many implementations of busybox with various level of
compiled-in utilities. This makes it quite difficult to rely on particular
commandi and even if the functionality is there, it may be simplified.
Second, `ash` is missing some features of larger shells. Particularly,
there is no regular expression comparison like e.g. `[[ $VAR =~ ^string ]]`.


## Will it work on csh/tcsh?
As those re too different from bash, it is not possible to write common code.


## Will CLE work on ksh?
Maybe... maybe yes. I plan to check this option and will eventually work
on ksh compatibility if this proves viable.


## Can I start live session with `mosh` ?
Not yet, but the functionality is in development


## Why CLE doesn't always run in 'screen'?
CLE doesn't tweak remote account in any way. New shell is started in regular
way, with resources defined by system.
Use `lscreen` wrapper instead of regular 'screen'


## Why tmux session is started with plain old boring prompt?
Same reason as in 'screen'.
Except that there is not live tmux wrapper yet. It's planned enhancement.


## Why I do not see rich history record of the command that runs in another window?
Rich history is updated after command finishes beacuse it waits for return code
and to calculate elapsed time.


## `lsu` on debian based systems starts shell without controlling terminal. Why?
This is a feature of the `su` command there - it detaches terminal from process
Check `man su` on debian. And use `lsudo` instead.


