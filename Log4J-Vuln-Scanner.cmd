@Echo off
:: EventSentry Validation Script to search LOG4J Vulnerable libraries in all local hard drives.
SET _exitcode=0
ECHO. >%temp%\es_log4jerr.log 2>NUL
ECHO. >%temp%\es_vul_log4.log 2>NUL
ECHO LOG4J Vulnerable Libraries Scanner started at %TIME%.
for /F "skip=1" %%C in ('%SystemRoot%\System32\wbem\wmic logicaldisk where drivetype^=3 get caption ^|findstr /r /v "^$"') do (
    ECHO Processing Drive [%%C]
    for /F %%D in ("%%C") do PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "gci %%D\ -rec -include log4j*.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path" 2>>%temp%\es_log4jerr.log | %SystemRoot%\System32\findstr.exe /V "2.16 2.17 2.18" >>%temp%\es_vul_log4.log
    ECHO Finished Processing Drive [%%C]
    ECHO.
    )
:: Resetting Errorlevel
ECHO Scanner Finished at %TIME%.
VER >NUL
%SystemRoot%\System32\findstr.exe /ic:"log4" %temp%\es_vul_log4.log
IF %ERRORLEVEL% == 1 GOTO ERRORCHK
ECHO Vulnerable Library Found:
TYPE %temp%\es_vul_log4.log
ECHO.
SET _exitcode=1
:ERRORCHK
VER >NUL
%SystemRoot%\System32\findstr.exe /ic:"error" %temp%\es_log4jerr.log
IF %ERRORLEVEL% == 1 EXIT /B %_exitcode%
ECHO ERROR Executing PowerShell Script:
TYPE %temp%\es_log4jerr.log
DEL %temp%\es_log4jerr.log >NUL 2>NUL
DEL %temp%\es_vul_log4.log >NUL 2>NUL
EXIT /B 1