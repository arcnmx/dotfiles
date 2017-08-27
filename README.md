# dotfiles.git

My settings and things.

    $ curl -sSfL https://raw.githubusercontent.com/arcnmx/dotfiles/master/bin/download.sh | sh -s -- -h
    $ ~/.dotfiles/dot.sh newuser arc wheel,audio,uucp

## OS X

[OS X additional instructions](OSX.md).

## Windows Subsystem for Linux

Populate a new Arch Linux installation with these dotfiles.

    $ iex (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/arcnmx/dotfiles/master/bin/alwsl.ps1')
