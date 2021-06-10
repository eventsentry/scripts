# This script will disable the power off option from start menu on windows. Usefull for virtual machines or remote 
access that are difficult to turn them back on
New-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\Start\HideShutDown\ -Name Value -Value 1 
-PropertyType DWORD -Force

