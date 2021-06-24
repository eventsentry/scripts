# Scripts
A collection of scripts that extend EventSentry's functionality.

## Scripts descriptions
[antiransom_shutdown.vbs](antiransom_shutdown.vbs): This script, given a user name as a command line argument,  utilizes the "net session" command to find the host with the most recent file access activity associated with the given user name.
Attempts to shut down the remote host when given the additional "shutdown" command line parameter. More information and script used on this [Blog Article](https://www.eventsentry.com/blog/2016/09/defeating-ransomware-with-eventsentry-remediation.html)

[check_last_file_modify.vbs](check_last_file_modify.vbs) Checks when a file was last modified

[noaccfiles.ps1](noaccfiles.ps1) PowerShell script that outputs files not accessed or modified in a certain number days. Used in KB 454 "How can I list files that weren't modified in the last X days?" [KB-454](https://www.eventsentry.com/kb/454)
