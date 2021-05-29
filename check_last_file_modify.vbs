' Checks when a file was last modified, useful if you need to ensure that a file
' (e.g. log file) is being updated and is not stale
' 
' Returns 0 if the file was modified recently, and 1 if the file was not recently
' modified. Check return code through %ERRORLEVEL%.

Option Explicit

'*******************************************************************************
'* DEFINE CONSTANTS
'*******************************************************************************
Const FILE_TO_CHECK = "C:\batch\test.txt"
Const MAX_AGE_IN_SECONDS = 120

'*******************************************************************************
'* DECLARE VARIABLES
'*******************************************************************************
Dim objShell, objExecObject
Dim FSO,File
Dim Date1,Date2,Hour1,Hour2,FileAge

'*******************************************************************************
'* Set environment and open output file
'*******************************************************************************
Set objShell = WScript.CreateObject("WScript.Shell")
set FSO = CreateObject("Scripting.FileSystemObject")
Set File = FSO.GetFile(FILE_TO_CHECK)

Date1 = Now()
Date2 = File.DateLastModified

FileAge = DateDiff("s", Date2, Date1)

If FileAge > MAX_AGE_IN_SECONDS Then
    WScript.echo "File", FILE_TO_CHECK, "was modified more than", MAX_AGE_IN_SECONDS, "seconds ago, it was modified", FileAge, "seconds ago."
    WScript.Quit(1)
Else
    WScript.echo "File", FILE_TO_CHECK, "was modified", FileAge, "seconds ago."
    WScript.Quit(0)
End if
