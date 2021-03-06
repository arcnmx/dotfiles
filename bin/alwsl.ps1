$ErrorActionPreference = "Stop"
Set-ExecutionPolicy Unrestricted
Start-Process -Wait -Verb RunAs -ArgumentList "-Command","Set-ExecutionPolicy Unrestricted" powershell

# Enable developer mode
Start-Process -Wait -Verb RunAs -ArgumentList "add","HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock","/t","REG_DWORD","/f","/v","AllowDevelopmentWithoutDevLicense","/d","1" reg

# Install WSL
Start-Process -Wait -Verb RunAs -ArgumentList "-Command","Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux" powershell

# Install Arch using https://github.com/alwsl/alwsl
$ALWSL = "$env:TEMP\alwsl.bat"
(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alwsl/alwsl/master/alwsl.bat') -replace "`n", "`r`n" | Out-File -Encoding ASCII $ALWSL
& $ALWSL install

bash -lc 'pacman --noconfirm -Sy pacman'
bash -lc 'pacman --noconfirm -Syu'
bash -lc 'pacman --noconfirm -S git curl'

bash -lc 'curl -sSfL https://raw.githubusercontent.com/arcnmx/dotfiles/master/bin/download.sh | sh -s -- -r -s personal'

bash -lc '/.dotfiles/dot.sh newuser arc wheel'
& $ALWSL user default arc
