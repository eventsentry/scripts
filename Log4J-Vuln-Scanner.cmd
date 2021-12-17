@Echo off
:: EventSentry Validation Script to search LOG4J Vulnerable libraries in all local hard drives.
ECHO Process started at %date%-%time%
ECHO Vulnerable Log4J Libraries Found (if any):
for /F "skip=1" %%C in ('%SystemRoot%\System32\wbem\wmic logicaldisk where drivetype^=3 get caption') do for /F %%D in ("%%C") do PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "gci %%D\ -rec -force -include log4j*.jar -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -exp Path" | %SystemRoot%\System32\findstr.exe log4
ECHO Process finished at %date%-%time%
IF %ERRORLEVEL% == 0 EXIT /B 1
IF %ERRORLEVEL% == 1 EXIT /B 0