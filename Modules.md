(DRAFT)
# Use modules to enhance CLE funcionality

## What are modules
Besides basic fuctionalities CLE is extensible framework. Various modules can
be added to enhance or modify the environment. For example CLE doesn't contain
functions to backup/restore settings. If there is a module with providing such
it can be downloaded and installed. Important word here is "download". 
CLE uses it's own repository. The reason for this is compatibility among
various distributions and operating systems so no dependancy on rpm/deb/etc.

- where are stored (.cle)
- different types of modules (mod-* vs. cle-* vs. bin-*)
- mod-* code is executed upon each CLE session startup
- cle-* mainly 'cle' command enhancements, code is executed on demand only
- bin-* not true modules but rather standalone scripts


## How to use modules
`cle mod`


## How do they work internally
Modularity is built into the environment but all module tasks are more
complex so they were moved into module itself (crazy enough, isn't it?)
The CLE contains a just routine to download and initialize that main mod-mod.

Modules store remains in GitHub and by default they are downloaded from
the URL based on $CLE_SRC variable. After download the module is stored
into `$HOME/.cle folder`, naming convention is 'mod-*' The environment runs
all mod-* files upon its startup


## How to write your own cool stuff


