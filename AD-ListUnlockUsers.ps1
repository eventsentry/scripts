# Check if the Active Directory module is available
function Check-ADModule {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        Write-Host "The Active Directory module is not available. Please install the RSAT (Remote Server Administration Tools) for this script to work." -ForegroundColor Red
        Write-Host "You can install RSAT from the 'Optional Features' settings on Windows 10/11 or download it from Microsoft's official website depending on your Windows version." -ForegroundColor Yellow
        exit 1
    } else {
        # Import the module if available
        Import-Module ActiveDirectory
    }
}

# Call the function to check for the module, you can comment the next line if you dont want to check if RSAT is installed each time
Check-ADModule

# Import the Active Directory module
Import-Module ActiveDirectory

# Function to get domain lockout duration
function Get-DomainLockoutDuration {
    $policy = Get-ADDefaultDomainPasswordPolicy
    if ($policy.LockoutDuration -ne [TimeSpan]::Zero) {
        $duration = $policy.LockoutDuration.ToString()
        Write-host ""
        Write-Host "This Domain lockout duration is set to $duration."
    } else {
        Write-host ""
        Write-Host "Domain lockout policy is set to never automatically unlock locked out accounts."
    }
}

# Function to get locked out users
function Get-LockedOutUsers {
    # Search for locked out user accounts and retrieve relevant properties
    $users = Search-ADAccount -LockedOut | Get-ADUser -Properties lockoutTime | Select-Object SamAccountName, Name, LockedOut, lockoutTime
    if ($users) {
        return $users
    } else {
        return $null
    }
}

# Display all locked out users and ask if a user should be unlocked
function DisplayAndUnlockUsers {
    # Display domain lockout duration
    Write-Host (Get-DomainLockoutDuration)

    $lockedUsers = Get-LockedOutUsers
    if ($lockedUsers -ne $null) {
        # Display locked users and lockout time
        $lockedUsers | ForEach-Object {
            $lockoutDateTime = [DateTime]::FromFileTime($_.lockoutTime)
            $lockoutDuration = (Get-Date) - $lockoutDateTime
            "$($_.Name) has been locked out for $($lockoutDuration.Days) days, $($lockoutDuration.Hours) hours, $($lockoutDuration.Minutes) minutes."
        }

        # Ask if the user wants to unlock an account
        Write-Host ""
        $answer = Read-Host "Do you want to unlock a user? (yes/no)"
        if ($answer -eq "yes") {
            $selectedUser = $lockedUsers | Out-GridView -Title "Select a user to unlock" -PassThru
            if ($selectedUser) {
                Unlock-User -UserSamAccountName $selectedUser.SamAccountName
            } else {
                Write-Host "No user selected."
            }
        } else {
            Write-Host "No changes made."
        }
    } else {
        Write-Host "No locked users found."
    }
}

# Function to unlock a selected user
function Unlock-User {
    param ($UserSamAccountName)
    # Unlock the user account
    Unlock-ADAccount -Identity $UserSamAccountName
    Write-Host "$UserSamAccountName has been unlocked."
}

# Execute the function to display and potentially unlock users
DisplayAndUnlockUsers
