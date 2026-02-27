@echo off

:: This script has been automatically created by the configuration assistant
:: and will purge data older than 30 days. You can customize this
:: script to keep the data longer, or to purge data in a more granular fashion.
:: Search the documentation for "es_db_purge" for more information
::
:: v1.1 Update
:: Since auto_db_purge.cmd has been deprecated in newer versions of EventSentry,
:: this updated version is intended for users who want to remain on older versions
:: or prefer to continue using the local purge script instead of the newer
:: WebReports purge utility.

:: Set data retention days next
SET PURGE_AGE=120d

:: Path of the EventSentry Database Purge Utility (This normally dont need to be changed)
SET EXE="C:\Program Files\EventSentry\Database Wizards\es_db_purge.exe"

:: --- Do not edit below this line ---

echo Date/Time : %DATE% %TIME%
echo Computer  : %COMPUTERNAME%
echo.


IF NOT EXIST %EXE% (
    echo ERROR: es_db_purge.exe not found at %EXE%
    exit /b 1
)

%EXE% "Primary Database" AllTables %PURGE_AGE% postgres a /shrinkindexes /count
