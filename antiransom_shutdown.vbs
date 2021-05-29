Option Explicit

' ==================================================================================
' Description:
'
' This script, given a user name as a command line argument,  utilizes the "net session" command to find
' the host with the most recent file access activity associated with the given user name
'
' Attempts to shut down the remote host when given the additional "shutdown" command line parameter
'
' Usage
' =====
' cscript antiransom_shutdown.vbs <USERNAME>
' cscript antiransom_shutdown.vbs <USERNAME> shutdown
'
' IMPORTANT
' =========
' * User name must be passed WITHOUT domain name
' * This script will not work for users who have not connected to this server in more than 24 hours
'
' Examples
' ========
'
' 1. Find out from which host the user "jill.rogers" most recently accessed this server
' cscript.exe antiransom_shutdown.vbs jill.rogers
'
' 2. Shutdown the computer from which user "jill.rogers" most recently accessed this server from
' cscript.exe antiransom_shutdown.vbs jill.rogers shutdown

' ==================================================================================

'*******************************************************************************
'* DEFINE CONSTANTS
'*******************************************************************************
Const SHUTDOWN_WARNING = "Ransomware potentially detected on your computer. Contact your IT department immediately."
Const SHUTDOWN_TIMEOUT = "60"

' ==================================================================================

Function GetHostOfSmallestIdleTime(dictObj)

	Dim smallestIdleTime, objKey
	
	smallestIdleTime = 999999999
	
	For Each objKey in dictObj
		If objKey < smallestIdleTime Then
			smallestIdleTime = objKey
		End If
	Next
	
	GetHostOfSmallestIdleTime = dictObj(smallestIdleTime)

End Function

' ==================================================================================

Dim WshShell, oExec

If WScript.Arguments.Count = 0 Then
	Wscript.Echo "Argument missing, specify user name"
	Wscript.Quit(1)
End If

Set WshShell = WScript.CreateObject("WScript.Shell")
Set oExec = WshShell.Exec("net session")

Dim strText
Do While Not oExec.StdOut.AtEndOfStream
    strText = strText & oExec.StdOut.ReadLine() & "#"
Loop

Dim dictIdleTimeToRemoteHost
Set dictIdleTimeToRemoteHost = CreateObject("Scripting.Dictionary")

Dim arrayLines, sessionEntry
arrayLines = Split(strText, "#")

For Each sessionEntry in arrayLines
	Dim arrayTokens, token
	Dim colRemoteHost, colUsername
	Dim idleTime, colPos
	
	arrayTokens = Split(sessionEntry, " ")
	
	colRemoteHost = ""
	colUsername = ""
	idleTime = ""
	colPos = 0
	
	For Each token in arrayTokens
		If Len(token) > 0 Then
			
			' First column is host
			If colPos = 0 Then
				colRemoteHost = token
			End If
			
			' Second column is user
			If colPos = 1 Then
				colUsername = token
			End If

			' We only consider (parse) idle times less than 24 hours
			If Instr(token, ":") > 0 Then
				idleTime = token
			End If
			
			colPos = colPos + 1
		End If
	Next
	
	If Len(colRemoteHost) > 0 And Len(colUsername) > 0 Then
		If LCase(Wscript.Arguments.Item(0)) = LCase(colUsername) Then
		
			Dim numIdleTime, arrayTime
			
			arrayTime = Split(idleTime, ":")
			If ubound(arrayTime) = 2 Then
				numIdleTime = arrayTime(0)*3600 + arrayTime(1)*60 + arrayTime(2)
				dictIdleTimeToRemoteHost(numIdleTime) = colRemoteHost
			End If
		
		End If
	End If

Next

Dim mostRecentHostForUser
mostRecentHostForUser = GetHostOfSmallestIdleTime(dictIdleTimeToRemoteHost)		

If Len(mostRecentHostForUser) > 0 Then
	Wscript.Echo "Most recent activity from user """ & Wscript.Arguments.Item(0) & """ was from host """ & mostRecentHostForUser & """"
	
	If WScript.Arguments.Count = 2 Then
		If LCase(Wscript.Arguments.Item(1)) = "shutdown" Then
			Dim commandLine
			commandLine = "shutdown.exe /m " & mostRecentHostForUser & " /r /t " & SHUTDOWN_TIMEOUT & " /f /c """ & SHUTDOWN_WARNING & """"
			Set oExec = WshShell.Exec(commandLine)
			
			Wscript.Echo "Issued shutdown command to remote host."
		End If
	End If
	
	Wscript.Quit(0)
Else
	Wscript.Echo "No recent connection for user """ & Wscript.Arguments.Item(0) & """ was found."
	Wscript.Quit(2)
End If
