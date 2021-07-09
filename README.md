# Scripts
A collection of scripts that extend EventSentry's functionality.

## Scripts descriptions
[antiransom_shutdown.vbs](antiransom_shutdown.vbs): This script, given a user name as a command line argument,  utilizes the "net session" command to find the host with the most recent file access activity associated with the given user name.
Attempts to shut down the remote host when given the additional "shutdown" command line parameter. More information and script used on this [Blog Article](https://www.eventsentry.com/blog/2016/09/defeating-ransomware-with-eventsentry-remediation.html)

[block_utilman1.cmd](block_utilman1.cmd)  Windows bath script to perform a number of tasks to alleviate the threat: Block access to the file (this includes delete, rename, and execution); Change the user password; Turn off the computer. Script used for "Detecting and automatically recovering from bypassing Windows logons with utilman.exe" Video demostration [Here](https://www.eventsentry.com/videos/Final.mp4) link article [KB-433](https://www.eventsentry.com/kb/433).

[check_last_file_modify.vbs](check_last_file_modify.vbs) Checks when a file was last modified

[noaccfiles.ps1](noaccfiles.ps1) PowerShell script that outputs files not accessed or modified in a certain number days. Used in KB 454 "How can I list files that weren't modified in the last X days?" [KB-454](https://www.eventsentry.com/kb/454)

[SMBv3_compression_set_vul-200313_181916.cmd](SMBv3_compression_set_vul-200313_181916.cmd) CVE advisory [CVE-2020-0796](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-0796) explains a remote code execution vulnerability that exists in the way that the Microsoft Server Message Block 3.1.1 (SMBv3) protocol handles certain requests that affect Windows 10 and Windows Server. This script is intended to quickly patch that vulnerability. Script used in article on how to quickly patch vulnerability using EventSentry [KB-415](https://www.eventsentry.com/kb/415)

[removable_audit_set.cmd](removable_audit_set.cmd) This script will help to set the correct registry key to enable Removable Storage Audit. See [KB-410](https://www.eventsentry.com/kb/410)
