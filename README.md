# Scripts
A collection of scripts that extend EventSentry's functionality. For more information: [EventSentry Validation Scripts](https://www.eventsentry.com/validationscripts)


## Scripts descriptions
[antiransom_shutdown.vbs](antiransom_shutdown.vbs): This script, given a user name as a command line argument,  utilizes the "net session" command to find the host with the most recent file access activity associated with the given user name.
Attempts to shut down the remote host when given the additional "shutdown" command line parameter. More information and script used on this [Blog Article](https://www.eventsentry.com/blog/2016/09/defeating-ransomware-with-eventsentry-remediation.html)

[block_utilman1.cmd](block_utilman1.cmd)  Windows bath script to perform a number of tasks to alleviate the threat: Block access to the file (this includes delete, rename, and execution); Change the user password; Turn off the computer. Script used for "Detecting and automatically recovering from bypassing Windows logons with utilman.exe" Video demostration [Here](https://www.eventsentry.com/videos/Final.mp4) link article [KB-433](https://www.eventsentry.com/kb/433).

[check_last_file_modify.vbs](check_last_file_modify.vbs) Checks when a file was last modified

[disable_insecure_ciphers.ps1](disable_insecure_ciphers.ps1) Powershell script to disable insecure ciphers on Windows Server and Desktop. Info: [Validation Script](https://www.eventsentry.com/validationscripts/guid/78fcd8a8-18af-49f4-8a64-bccb901e5557)

[Log4J-Vuln-Scanner.cmd](Log4J-Vuln-Scanner.cmd) Windows Batch + Powershell script to search for Log4J libraries and check if they contain vulnerable class to CVE-2021-44228/CVE-2021-45046 [Validation Script](https://www.eventsentry.com/validationscripts/guid/a01ac7ca-b4f4-44e2-badd-dd7eb11e765d)

[msdiagtool-CVE-2022-30190.cmd](msdiagtool-CVE-2022-30190.cmd) Microsoft Recommended workaroud for CVE-2022-30190 [Validation Script](https://www.eventsentry.com/validationscripts/guid/6644dbf9-c673-4ab9-8c1d-6781bac0659d) - [MS CVE-2022-30190](https://msrc-blog.microsoft.com/2022/05/30/guidance-for-cve-2022-30190-microsoft-support-diagnostic-tool-vulnerability/)

[noaccfiles.ps1](noaccfiles.ps1) PowerShell script that outputs files not accessed or modified in a certain number days. Used in KB 454 "How can I list files that weren't modified in the last X days?" [KB-454](https://www.eventsentry.com/kb/454)

[powershell-logging.reg](powershell-logging.reg) Registry file to enable PowerShell logging for validation script "PowerShell: Logging should be enabled". For more information read this [EventSentry Blog Post](https://www.eventsentry.com/blog/2018/01/powershell-p0wrh11-securing-powershell.html#:%7E:text=Enabling%20Logging)

[SMBv3_compression_set_vul-200313_181916.cmd](SMBv3_compression_set_vul-200313_181916.cmd) CVE advisory [CVE-2020-0796](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-0796) explains a remote code execution vulnerability that exists in the way that the Microsoft Server Message Block 3.1.1 (SMBv3) protocol handles certain requests that affect Windows 10 and Windows Server. This script is intended to quickly patch that vulnerability. Script used in article on how to quickly patch vulnerability using EventSentry [KB-415](https://www.eventsentry.com/kb/415)

[removable_audit_set.cmd](removable_audit_set.cmd) This script will help to set the correct registry key to enable Removable Storage Audit. See [KB-410](https://www.eventsentry.com/kb/410)

[crypto_to_usd.ps1](crypto_to_usd.ps1) Outputs the current USD value of a crypto coin, can be integrated with EventSentry's performance monitoring to support charting and alerts. Simply pass the symbol name (e.g. BTC) as an argument.

[stix.vbs](stix.vbs) Transforms STIX file into EventSentry's threat intel format.

