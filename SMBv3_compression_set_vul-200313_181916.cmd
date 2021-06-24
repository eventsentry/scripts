@ECHO off

:: This script will disable SMBv3 Compression due to vulnerability CVE-2020-0796
:: If cannot set key will exit on errorlevel 1
:: v0.3 03/2020

%SystemRoot%\system32\reg.exe query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" 2>nul | %SystemRoot%\system32\findstr.exe /I "DisableCompression " | %SystemRoot%\system32\findstr.exe /I "0x1" >nul

IF %ERRORLEVEL% == 0 (
	ECHO OK - Reg key exists
	EXIT /b 0
) ELSE (
    GOTO SETVAR
)

:SETVAR
%SystemRoot%\system32\reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v DisableCompression /t REG_DWORD /d 1 /f 2>nul

%SystemRoot%\system32\reg.exe query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" 2>nul | %SystemRoot%\system32\findstr.exe /I "DisableCompression " | %SystemRoot%\system32\findstr.exe /I "0x1" >nul

IF %ERRORLEVEL% == 0 (
	ECHO OK - Reg key set
	EXIT /b 0
) ELSE (
    ECHO ERR - Can not set reg key
    EXIT /b 1
)