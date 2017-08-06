$ErrorActionPreference = "Stop"
(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alwsl/alwsl/master/alwsl.bat') -replace "`n", "`r`n" | Out-File -Encoding ASCII alwsl.bat
Start-Process -Wait -Verb RunAs -ArgumentList "-Command","Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux" powershell
.\alwsl.bat install
bash -c 'pacman --noconfirm -Syu'
bash -c 'pacman --noconfirm -S git curl'
bash -c 'curl -sSfL https://raw.githubusercontent.com/arcnmx/dotfiles/master/bin/download.sh | sh -s -- -r -s personal'
bash -c '/.dotfiles/dot.sh newuser arc wheel'
.\alwsl.bat user default arc
