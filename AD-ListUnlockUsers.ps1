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

# Call the function to check for the module
Check-ADModule

# Import the Active Directory module
Import-Module ActiveDirectory

# Function to get locked out users
function Get-LockedOutUsers {
    # Search for locked out user accounts
    $users = Search-ADAccount -LockedOut | Select-Object SamAccountName, Name
    if ($users) {
        return $users
    } else {
        return $null
    }
}

# Display all locked out users and ask if a user should be unlocked
function DisplayAndUnlockUsers {
    $lockedUsers = Get-LockedOutUsers
    if ($lockedUsers -ne $null) {
        # Display locked users
        Write-Host "Locked Out Users:"
        $lockedUsers | Format-Table -Property SamAccountName, Name

        # Ask if the user wants to unlock an account
        $answer = Read-Host "Do you want to unlock a user? (Y/N)"
        if ($answer -eq "y") {
            $selectedUser = $lockedUsers | Out-GridView -Title "Select a user from the list to unlock" -PassThru
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
