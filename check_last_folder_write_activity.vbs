' Determines whether any file in a select folder has been updated within the
' last MAX_AGE_IN_SECONDS
'
' Returns 0 if at least one file has been modified within the last MAX_AGE_IN_SECONDS
' seconds, otherwise returns 1. Check return code through %ERRORLEVEL%.

Option Explicit

'*******************************************************************************
'* DEFINE CONSTANTS
'*******************************************************************************
Const FOLDER_TO_CHECK = "C:\logfiles"
Const MAX_AGE_IN_SECONDS = 120

'*******************************************************************************
'* DECLARE VARIABLES
'*******************************************************************************
Dim fso, fileObj, timeStart, diffSeconds, recentFileName

'*******************************************************************************
'* Set environment, open folder and initialize
'*******************************************************************************
Set fso = CreateObject("Scripting.FileSystemObject")

recentFileName = ""
timeStart = Now()

For Each fileObj in fso.GetFolder(FOLDER_TO_CHECK).Files

    diffSeconds = DateDiff("s", fileObj.DateLastModified, timeStart)
    
    If diffSeconds < MAX_AGE_IN_SECONDS Then
        recentFileName = fileObj.Name
        Exit For
    End If
Next

If Len(recentFileName) = 0 Then
    WScript.Echo "WARNING: No files were modified in the last " & MAX_AGE_IN_SECONDS & " seconds."
    WScript.Quit(1)
Else
    WScript.Echo "OK: File """ & recentFileName & """ was modified " & diffSeconds & " seconds ago."
    WScript.Quit(0)
End If
