' Lists all logical drives on the local computer which are configured for 
' software RAID. Returns an %ERRORLEVEL% of 1 if any redundant drive is 
' not in a "Healthy" state. Returns 0 otherwise.
'
' Supports Windows Vista/7, Windows 2008/R2

Option Explicit

Dim WshShell, oExec
Dim RegexParse
Dim hasError : hasError = 0

Set WshShell = WScript.CreateObject("WScript.Shell")
Set RegexParse = New RegExp

' Execute diskpart
Set oExec = WshShell.Exec("%comspec% /c echo list volume | diskpart.exe")

RegexParse.Pattern = "\s\s(Volume\s\d)\s+([A-Z])\s+(.*)\s\s(NTFS|FAT)\s+(Mirror|RAID-5)\s+(\d+)\s+(..)\s\s([A-Za-z]*\s?[A-Za-z]*)(\s\s)*.*"

While Not oExec.StdOut.AtEndOfStream
    Dim regexMatches
    Dim Volume, Drive, Description, Redundancy, RaidStatus
    Dim CurrentLine : CurrentLine = oExec.StdOut.ReadLine
    
    Set regexMatches = RegexParse.Execute(CurrentLine)
    If (regexMatches.Count > 0) Then
        Dim match
        Set match = regexMatches(0)
        
        If match.SubMatches.Count >= 8 Then
            Volume      = match.SubMatches(0)
            Drive       = match.SubMatches(1)
            Description = Trim(match.SubMatches(2))
            Redundancy  = match.SubMatches(4)
            RaidStatus  = Trim(match.SubMatches(7))
        End If

        If RaidStatus <> "Healthy" Then
            hasError = 1
            WScript.StdOut.Write "**WARNING** "
        End If
        
        WScript.StdOut.WriteLine "Status of " & Redundancy & " " & Drive & ": (" & Description & ") is """ & RaidStatus & """"
    End If
Wend

If (hasError) Then
    WScript.StdOut.WriteLine ""
    WScript.StdOut.WriteLine "WARNING: One or more redundant drives are not in a ""Healthy"" state!"
End If

WScript.Quit(hasError)
