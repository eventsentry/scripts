' Converts a previously downloaded file in STIX format (fileStixInput) into
' EventSentry's threat intel format
'
' Requires EventSentry v4.2.3.26 or later

Dim fileStixInput
Dim fileEventSentryOutput

fileStixInput = "C:\resources\stix\STIX_IP_Watchlist.xml"
fileEventSentryOutput = "C:\windows\system32\eventsentry\temp\eventsentry_threatintel_custom.tmp"

Dim oXML
Set oXML = CreateObject("Microsoft.XMLDOM")

Dim objFSO
Set objFSO=CreateObject("Scripting.FileSystemObject")

oXML.Load(fileStixInput)

Dim objFileEventSentryOutput
Set objFileEventSentryOutput = objFSO.CreateTextFile(fileEventSentryOutput, True)

For Each rootNodes In oXML.DocumentElement.ChildNodes
    If rootNodes.nodeName = "stix:Indicators" Then
        For Each nodeIndicator In rootNodes.ChildNodes

            Dim ignoreIteration
            ignoreIteration = False

            For Each indicatorElements In nodeIndicator.ChildNodes
                
                If indicatorElements.nodeName = "indicator:Type" And indicatorElements.text <> "IP Watchlist" Then
                    ignoreIteration = True
                End If
                
                If ignoreIteration <> True Then
                    If (indicatorElements.nodeName = "indicator:Observable") Then
                        For Each cyboxObject In indicatorElements.ChildNodes
                            For Each cyboxProperty In cyboxObject.ChildNodes
                                If (cyboxProperty.getAttribute("category") = "ipv4-addr") Then
                                    For Each addrObj In cyboxProperty.ChildNodes
                                        If addrObj.nodeName = "AddressObject:Address_Value" Then
                                            Dim ipAddresses
                                            ipAddresses = Split(addrObj.text, "##comma##")
                                            
                                            For Each ipAddr In ipAddresses
                                                objFileEventSentryOutput.Write ipAddr & vbCRLF
                                            Next
                                        End if
                                    Next
                                End If
                            Next
                        Next
                    End If
                End If
            Next
        Next
    End If
Next

objFileEventSentryOutput.Close
