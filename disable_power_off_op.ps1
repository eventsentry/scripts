# Disables the power off option from the start menu on Windows. Useful for virtual machines or remote access where it may be difficult to power the machine back on

New-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\Start\HideShutDown\ -Name Value -Value 1 -PropertyType DWORD -Force
