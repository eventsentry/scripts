# Scripts
A collection of scripts that extend EventSentry's functionality. For more information: [EventSentry Validation Scripts](https://www.eventsentry.com/validationscripts)


## Scripts descriptions
[AD-ListUnlockUsers.ps1](AD-ListUnlockUsers.ps1): This script is for listing locked users in your AD (if any) and let you unlock them. Great to have it on hand on any machine of your AD instead to need to log in into your DC and search for the user. RSAT need to be installed (from optional features) or you can run `Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online` or `Get-WindowsCapability -Name RSAT* -Online | Where-Object Name -like "*Directory*" | Add-WindowsCapability -Online` for Windows 11

[antiransom_shutdown.vbs](antiransom_shutdown.vbs): This script, given a user name as a command line argument,  utilizes the "net session" command to find the host with the most recent file access activity associated with the given user name.
Attempts to shut down the remote host when given the additional "shutdown" command line parameter. More information and script used on this [Blog Article](https://www.eventsentry.com/blog/2016/09/defeating-ransomware-with-eventsentry-remediation.html)

[block_utilman1.cmd](block_utilman1.cmd)  Windows bath script to perform a number of tasks to alleviate the threat: Block access to the file (this includes delete, rename, and execution); Change the user password; Turn off the computer. Script used for "Detecting and automatically recovering from bypassing Windows logons with utilman.exe" Video demostration [Here](https://www.eventsentry.com/videos/Final.mp4) link article [KB-433](https://www.eventsentry.com/kb/433).

[certificate_check.ps1](certificate_check.ps1) Script to check if specific certificate is installed on local computer. You can edit and add the certificate ThumbPrint. Script will check if that particular certificate is installed on local computer. It also has an option to enable printing all local certificate's ThumbPrint.

[check_last_file_modify.vbs](check_last_file_modify.vbs) Checks when a file was last modified

[disable_insecure_ciphers.ps1](disable_insecure_ciphers.ps1) Powershell script to disable insecure ciphers on Windows Server and Desktop. Info: [Validation Script](https://www.eventsentry.com/validationscripts/guid/78fcd8a8-18af-49f4-8a64-bccb901e5557)

[es_linux_process_cpu.ps1](es_linux_process_cpu.ps1) This script can easily be integrated with EventSentry's performance monitoring functionality (option "executable") See KB 473 for more information There is a signed version of this script [es_linux_process_cpu_signed.ps1](es_linux_process_cpu_signed.ps1) in case you generate a user with the same username and put the tools in the same folder (no need to edit the script) and you can run this script under secure environments where the script must be signed.


[DomainExpirationCheck.ps1](DomainExpirationCheck.ps1) Powershell script to check if domain registration is about to expire (in less than 30 days or less). using WhoIsXMLApi.com / Will exit errorlevel 0 if no expiration or error / Will exit errorlevel 1 if is about to expire / Will exit errorlevel 998 (warning) if there was an error querying the server or there was no expiration day in API reply (domain not fully supported)

[DomainTrustFix.ps1](DomainTrustFix.ps1) Simple Powershell script that will fix the relationship of the machine with the Active Directory Domain. Often broken by a machine that was inactive for more than 60 days.

[Log4J-Vuln-Scanner.cmd](Log4J-Vuln-Scanner.cmd) Windows Batch + Powershell script to search for Log4J libraries and check if they contain vulnerable class to CVE-2021-44228/CVE-2021-45046 [Validation Script](https://www.eventsentry.com/validationscripts/guid/a01ac7ca-b4f4-44e2-badd-dd7eb11e765d)

[msdiagtool-CVE-2022-30190.cmd](msdiagtool-CVE-2022-30190.cmd) Microsoft Recommended workaroud for CVE-2022-30190 [Validation Script](https://www.eventsentry.com/validationscripts/guid/6644dbf9-c673-4ab9-8c1d-6781bac0659d) - [MS CVE-2022-30190](https://msrc-blog.microsoft.com/2022/05/30/guidance-for-cve-2022-30190-microsoft-support-diagnostic-tool-vulnerability/)

[noaccfiles.ps1](noaccfiles.ps1) PowerShell script that outputs files not accessed or modified in a certain number days. Used in KB 454 "How can I list files that weren't modified in the last X days?" [KB-454](https://www.eventsentry.com/kb/454)

[postgresql_ram_tuning.ps1](postgresql_ram_tuning.ps1) PowerShell script to print recommended ram settings on key settings for tunning PostgreSQL performance. Script can use the machine ram or user input. For more information check EventSentry KB on [How can I optimize the performance of the built-in EventSentry (PostgreSQL) database?](https://www.eventsentry.com/kb/232-how-can-i-optimize-the-performance-of-the-built-in-eventsentry-postgresql-database)

[powershell-logging.reg](powershell-logging.reg) Registry file to enable PowerShell logging for validation script "PowerShell: Logging should be enabled". For more information read this [EventSentry Blog Post](https://www.eventsentry.com/blog/2018/01/powershell-p0wrh11-securing-powershell.html#:%7E:text=Enabling%20Logging)

[SMBv3_compression_set_vul-200313_181916.cmd](SMBv3_compression_set_vul-200313_181916.cmd) CVE advisory [CVE-2020-0796](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-0796) explains a remote code execution vulnerability that exists in the way that the Microsoft Server Message Block 3.1.1 (SMBv3) protocol handles certain requests that affect Windows 10 and Windows Server. This script is intended to quickly patch that vulnerability. Script used in article on how to quickly patch vulnerability using EventSentry [KB-415](https://www.eventsentry.com/kb/415)

[Test-TLSVersion.ps1](Test-TLSVersion.ps1) Easy script to check the minium version of TLS on specific host/ip and port. Related KB Article: [KB-513](https://www.eventsentry.com/kb/513)


[removable_audit_set.cmd](removable_audit_set.cmd) This script will help to set the correct registry key to enable Removable Storage Audit. See [KB-410](https://www.eventsentry.com/kb/410)

[crypto_to_usd.ps1](crypto_to_usd.ps1) Outputs the current USD value of a crypto coin, can be integrated with EventSentry's performance monitoring to support charting and alerts. Simply pass the symbol name (e.g. BTC) as an argument.

[stix.vbs](stix.vbs) Transforms STIX file into EventSentry's threat intel format.

