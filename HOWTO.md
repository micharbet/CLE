# How to live with CLE

### Run and Deploy
1. `. clerc`
2. `cle deploy user` or `cle deploy system`

### Prompting
Prompt string has following parts and default values:
```
  [0] 13:25 user tweaked.hostname /working/directory >
    \   /    |          |                 |
     \ /     }          }                 P3='\w %> '
      |      |          P2='%h'
      |      P1='\u'
      P0='%e \A'
```

- `cle color COLORCODE`
- `cle p0|p1|p2|p3`
- `cle time on|off`

### ssg & suu

### Alias management

### History management

### Updating
`cle update`

### Files
.clerc
.clerc-local
.clerc-remote-CLE_USER
.cleuser-CLE_USER
.history-CLE_USER
.aliases-CLE_USER
.cle/mod-*
.cle/host-*
