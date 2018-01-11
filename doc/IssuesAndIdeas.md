## Known bugs
- strange behaviour when setting '%h', see this:

	[0] 16:26 mich stalker ~/d/CLE >  cle p2 '%h %>'
	bash: printf: ` ': invalid format character
	]0;cle p2 '

  it looks like conficlting with used 'printf', maybe complete removal of %> would be better

- errors in case the user login name contains spaces (on Windows)

- some rich history entries are meaningless or contains wird information (scrn, cd)

## New feature Ideas
- dynamict window/screen title changes with current executed command
- preexec() and postexec() hookso

## Features, not a bugs!
- rich history is updated after command finishes beacuse we need return code!

