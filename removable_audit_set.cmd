@ECHO off
setlocal
:: Script to check if Removable Audit is enabled. See KB: https://www.eventsentry.com/kb/410
%systemroot%\System32\reg.exe QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Storage" 2> nul | %SystemRoot%\System32\findstr /I "HotplugSecureOpen" | %SystemRoot%\System32\findstr /I "0x1" >nul
IF %ERRORLEVEL% == 0 Goto Check2
ECHO HI
SET /P AREYOUSURE=Removable Audit Registry key is not set. Do you want to set it Y/[N]?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
%SystemRoot%\System32\reg.exe ADD "HKLM\System\CurrentControlSet\Control\storage" /f /v HotPlugSecureOpen /t REG_DWORD /d 1 2> nul
%systemroot%\System32\reg.exe QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Storage" 2> nul | %SystemRoot%\System32\findstr /I "HotplugSecureOpen" | %SystemRoot%\System32\findstr /I "0x1" >nul
	IF %ERRORLEVEL% == 0 (
		Goto Check2
	) ELSE (
		ECHO Error setting registry entry.
		EXIT /b 1	
)
:Check2
%SystemRoot%\System32\AuditPol.exe /get /category:"Object Access" 2> nul | %SystemRoot%\System32\findstr /I "Removable storage" | %SystemRoot%\System32\findstr /I "Success" >nul
IF %ERRORLEVEL% == 0 (
	ECHO Registry key and Audit policy correctly set.
	EXIT /b 0
	)
ECHO Registry key set but Audit policy must be changed, see: https://system32.eventsentry.com/security/auditing
EXIT /b 0
:END
ECHO Cancelled.
EXIT /b 1
endlocal