# DESCRIPTION: Unlock user from Production Network

# Check for RSAT ActiveDirectory module
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "The ActiveDirectory module (RSAT) is not installed." -ForegroundColor Yellow
    $Install = Read-Host "Would you like to install it now? (y/n)"

    if ($Install -eq 'y') {
        Write-Host "Installing RSAT ActiveDirectory tools..." -ForegroundColor Cyan
        try {
            Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -ErrorAction Stop
            Write-Host "Installation complete. Please re-run the script." -ForegroundColor Green
        } catch {
            Write-Host "Installation failed: $_" -ForegroundColor Red
            Write-Host "Try running the script as Administrator." -ForegroundColor Yellow
        }
        exit
    } else {
        Write-Host "RSAT is required to continue. Exiting." -ForegroundColor Red
        exit
    }
}

# Prompt for admin credentials
$Cred = Get-Credential -Message "Enter domain admin credentials (DOMAIN\username)"

# DC hostname or IP
$DC = "172.21.2.60"

# Prompt for the locked-out username
$Username = Read-Host "Enter the username to unlock"

# Check if locked, then unlock
$User = Get-ADUser -Identity $Username -Properties LockedOut -Server $DC -Credential $Cred

if ($User.LockedOut) {
    Unlock-ADAccount -Identity $Username -Server $DC -Credential $Cred
    Write-Host "[$Username] has been unlocked." -ForegroundColor Green
} else {
    Write-Host "[$Username] is NOT currently locked out." -ForegroundColor Yellow
}