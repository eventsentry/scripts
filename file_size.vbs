' Checks the size of a single file
'
' Returns 0 if the file size is below the max size, or returns 1 
' if the size exceeds the max size. Check return code through %ERRORLEVEL%.

Option Explicit

Dim exitCode : exitCode = 0
Dim objFSO, objFile

' Set your values here
Const FILE_NAME = "C:\logs\cc.log"
Const MAX_FILESIZE_IN_BYTES = 10485760   ' 10 Mb

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(FILE_NAME)

If objFile.Size > MAX_FILESIZE_IN_BYTES Then 
    exitCode = 1
End If

Wscript.Quit exitCode
