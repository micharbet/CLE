
## Zodiac
2019 - 2020
- added zsh compatibility
- look&feel changes
- live sessions inherit their prompt setup from workstation
- rich history improved, added more info, contain also elapsed time
- added modules `mod-mosh`, `cle-prompt` and `cle-palette`
- code optimalization, cleanup, bugfixes and introducing new bugs


## Nova
New star shines on the sky
22 Oct 2018

At the beginning no new features were planned, rather a reorganization
of files, startup sequences etc. Like e.g. clerc files, configuration, modules and
other data created quite a mess in home directory, scattering files here and there.
This was not nice. Everything important to CLE now goes into single directory:
$HOME/.cle-username/
With exceptions (e.g. rich history file in $HOME/.history-ALL)

Now we have:

    clean homedir
    optimized routines
    easy to maintain and backup the environment
    more easier to understand what's what
    development is done in file clerc.sh that contains extended comments and
    debug printouts. The shortened version, clerc is generated using sed.

Important changes and new features:

    renamed session wrappers into 'Live Commands' (note the letter 'L')
    ssg -> lssh
    suu -> lsu
    ksuu -> lksu
    sudd -> lsudo
    scrn -> lscreen
    aliases are transferred from CLE workstation to new sessions
    autocompletion for lssh and builtin cle * commands, where it also provides
    current prompt strings for editing directly on the command line
    using module cle-rcmove the folder with the environment can be moved
    somewhere else. E.g. into $HOME/.config/cle-$USERNAME/
    show /etc/motd, this can be turned off
    cle help uses mdfilter and produces nice colored cheatsheet
    last but not least: the documentation kept not only up to date but also thanks to
    a native speaker Joseph Lemmons through grammar corrections fixes and spell
    checks it gained gained better readability.

And, the filesize remains still around 16kB!

## RedH
After strip-down (optimization) in HAlpha release, new functionalities were added:
scrn - the GNU screen wrapper
hh - rich history viewer
aa - alias management improved
cle doc - indexed documentation available on-line besides the previous 'cle help' built-in doc.
cle mod - modularity reworked

## HAlpha
Code optimalization

## MayDay
May 2017
- new remote session functions:
  * sudd  - sudo wrapper
  * suu   - su wrapper (previous suu removed)
  * kksu  - ksu wrapper (kerberized su)

## Easter
Apr 2017

## Spring
21 Mar 2017

## Numbered versions 3.x
