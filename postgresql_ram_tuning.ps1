# v0.1B
# EventSentry PosgreSQL configuration tuning for better RAM usage.
# Project repository URL: https://github.com/eventsentry/scripts

function Validate-RAM {
    param(
        [int]$ramGB
    )
    
    if ($ramGB -ge 1 -and $ramGB -le 1024000) {
        if ($ramGB -lt 8000) {
            Write-Host "Error: Insufficient RAM. Minimum required RAM is 8GB/8000MB."
            exit
        }
        return $ramGB
    } else {
        Write-Host "Error: RAM must be between 1GB and 1024GB."
        exit
    }
}

# Main script
$manualInput = Read-Host "Enter RAM amount in MB (or press Enter to use installed RAM)"

if ([string]::IsNullOrWhiteSpace($manualInput)) {
    $ram = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1024000
    Validate-RAM -ramGB $ram
} else {
    $ram = [int]$manualInput
    Validate-RAM -ramGB $ram
}

$sharedBuffers = [Math]::Ceiling(($ram * 0.20) / 1024)
$workMem = [Math]::Ceiling(($ram * 0.20 / 200) * 0.25)
$maintenanceWorkMem = [Math]::Ceiling($ram * 0.05)
$effectiveCacheSize = [Math]::Ceiling(($ram / 2) / 1024)

Write-Host Installed RAM: $ram. Results are rounded up. 

Write-Host "These settings must be updated/added in the postgreSQL config file."
Write-Host "(default location is C:\Program Files\EventSentry\data14\postgresql_eventsentry.conf)"
Write-Host "shared_buffers= $($sharedBuffers)GB                 # Between 15 and 20 % of total physical ram"
Write-Host "work_mem= $($workMem)MB                       # Total Ram * 0.25 / max_connection. 200 was used as is the default max_connection"
Write-Host "Maintenance_work_mem= $($maintenanceWorkMem)MB         # Total Ram * 0.05 - Used for mantenice operations"
Write-Host "effective_cache_size= $($effectiveCacheSize)GB           # Max of free ram used for disk cache (50% of total ram)"
