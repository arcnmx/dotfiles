(New-Object System.Net.WebClient).DownloadString(https://raw.githubusercontent.com/alwsl/alwsl/master/alwsl.bat) | Out-File alwsl.bat
alwsl.bat # install
bash -c 'pacman --noconfirm -Syuw && rm /etc/ssl/certs/ca-certificates.crt && update-ca-trust && pacman --noconfirm -Su'
bash -c 'pacman --noconfirm -S git curl'
bash -c 'curl -sSfL https://raw.githubusercontent.com/arcnmx/dotfiles/master/bin/download.sh | sh -s -- -r -s personal'
bash -c '/.dotfiles/dot.sh newuser arc wheel'
alwsl.bat default arc
