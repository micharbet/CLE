(DRAFT)
# Use modules to enhance CLE funcionality

## How do they work internally
Modularity is built into the environment but all module tasks are more
complex so they were moved into module itself (crazy enough, isn't it?)
The CLE contains a just routine to download and initialize that main mod-mod.

Modules store remains in GitHub and by default they are downloaded from
the URL based on $CLE_SRC variable. After download the module is stored
into `$HOME/.cle folder`, naming convention is 'mod-*' The environment runs
all mod-* files upon its startup


## How to use modules
So, first you need to issue `cle mod` to initiate the process.


## How to write your own cool stuff


