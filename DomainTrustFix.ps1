$Title = "EventSentry: Domain secure channel repair (Join Health)"
$host.UI.RawUI.WindowTitle = $Title

# Prompt for domain credentials instead of hardcoding on script
$cred = Get-Credential -Message "Enter domain credentials to repair trust"

try {
    $result = Test-ComputerSecureChannel -Repair -Credential $cred -ErrorAction Stop

    if ($result -eq $true) {
        Write-Host "Trust relationship successfully repaired."
        exit 0
    } else {
        Write-Host "Failed to repair trust relationship."
        exit 1
    }
} catch {
    Write-Host "Error during repair: $($_.Exception.Message)"
    exit 1
}
