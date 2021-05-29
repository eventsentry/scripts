Dim processName, processNameForPerfmon
Dim computerName

If Wscript.Arguments.Count = 0 Then
    Wscript.Echo "INVALID SYNTAX: Specify a process instance name, e.g. ""svchost#1"""
    Wscript.Echo
    Wscript.Echo "Usage:   getPerfmonProcessPid.vbs PROCESS COMPUTER (optional)"
	Wscript.Echo "Example: getPerfmonProcessPid.vbs svchost#3"
	Wscript.Echo "Example: getPerfmonProcessPid.vbs svchost#3 SRV001"
    Wscript.Echo
    Wscript.Echo "Script prints the PID of the process. If process is associated with a"
    Wscript.Echo "one or more services, then all associated services will be shown as well"
    Wscript.Quit
End If

' Set remote computer if specified
If Wscript.Arguments.Count = 2 Then
    computerName = WScript.Arguments.Item(1)
Else
    computerName = "."
End If

processName = GetProcessNameWithoutInstance(WScript.Arguments.Item(0))
processNameForPerfmon = WScript.Arguments.Item(0)

' Used simply for easier sorting, requires .NET to be installed
Set processArray = CreateObject("System.Collections.ArrayList")

' Connect to WMI and execute query
Set objWMIService = GetObject("winmgmts:\\" & computerName & "\root\cimv2")
Set colProcessList = objWMIService.ExecQuery("Select * from Win32_Process WHERE Name='" & processName & ".exe'")

' Add minimum required data to array list
For Each objProcess in colProcessList
    dtmStartTime = objProcess.CreationDate
    If Not IsNull(objProcess.CreationDate) Then
        identifier = objProcess.CreationDate & "|" & objProcess.ProcessId
        processArray.Add identifier
    End If
Next

' WMI already appears to return processes sorted, but we do this just be sure
processArray.Sort()

Dim counter
counter = 0

' Display the data
For Each processData in processArray
    processIdPos = InStr(processData, "|")
    If processIdPos > 0 Then
        processNameWithInstance = processName
        
        If counter > 0 Then
            processNameWithInstance = processNameWithInstance & "#" & counter
        End If
        
        If processNameWithInstance = processNameForPerfmon Then
            Dim servicesList
			
			Wscript.Stdout.Write "Details for " & processNameForPerfmon & vbCRLF & vbCRLF

            pid = Mid(processData, processIdPos + 1)
			Wscript.Stdout.Write "Process ID: " & pid & vbCRLF & vbCRLF

			' Get service(s) associated with this PID
            servicesList = GetServiceNameFromPid(pid)
			If UBound(servicesList) > 0 Then
              Wscript.Stdout.Write "Associated Services:" & vbCRLF & "--------------------" & vbCRLF
              For Each service in servicesList
                Wscript.Stdout.Write service & vbCRLF
              Next
            End If

            Exit For
        End If
    End If
    
    counter = counter + 1
Next

' Returns 1 if "fileName" includes an extension (e.g. "notepad.exe"),
' otherwise 0
Function HasInstance(processName)
    HasInstance = 0
    
    If InStr(processName, "#") > 0 Then
        HasInstance = 1
    End If
End Function

' Returns the process name with an ".exe" extension, regardless of how it was passed in (svchost#3, notepad, ...)
Function GetProcessNameWithoutInstance(processName)
    If HasInstance(processName) = 0 Then
        GetProcessNameWithoutInstance = processName
    Else
        GetProcessNameWithoutInstance = Left(processName, InStr(processName, "#") - 1)
    End If
End Function

' Returns the name of the service which is associated with this PID
Function GetServiceNameFromPid(pid)
    Set colServices = objWMIService.ExecQuery("Select * from Win32_Service WHERE ProcessId=" & pid)
    
    Dim myServicesList()
    Dim arrayIndex
    
    arrayIndex = 0

    For Each objService in colServices
        ReDim Preserve myServicesList(arrayIndex + 1)

        myServicesList(arrayIndex) = objService.Name & " (" & objService.DisplayName & ")"
        arrayIndex = arrayIndex + 1
    Next
    
    GetServiceNameFromPid = myServicesList
End Function
