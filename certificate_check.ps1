$Title = "EventSentry Script: Check if Certificate is installed in Local Computer"
$host.UI.RawUI.WindowTitle = $Title
 
# Define the certificate thumbprint to search for
$CertificateThumbprintToSearch = "CERTIFICATE_THUMBPRINT_GOES_HERE" # Replace with actual thumbprint or test input
$CertificateThumbprintToSearch = $CertificateThumbprintToSearch.ToUpper().Trim()

# Toggle to enable or disable printing all thumbprints for debugging 
$PrintAllThumbprints = $false # Set to $false to disable printing all certificates, $true to show all

Write-Output "EventSentry Certificate Check: Searching for certificate with thumbprint: $CertificateThumbprintToSearch"

# List of LocalMachine subfolders to check
$localMachineStores = @(
    "My",                      # Personal Certificates
    "Root",                    # Trusted Root Certification Authorities
    "CA",                      # Intermediate Certification Authorities
    "TrustedPublisher",        # Trusted Publishers
    "AuthRoot",                # Third-Party Root Certification Authorities
    "Disallowed",              # Untrusted Certificates
    "Remote Desktop",          # Remote Desktop Certificates
    "TrustedPeople"            # Trusted People
)

$foundCertificate = $false

# Iterate through each store and list certificates
foreach ($storeName in $localMachineStores) {
    Write-Output "Checking certificates in LocalMachine\${storeName}..."

    try {
        # Open the certificate store
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store $storeName, "LocalMachine"
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

        # List all certificates in the current store if enabled
        if ($PrintAllThumbprints) {
            Write-Output "Listing all certificates in LocalMachine\${storeName}:"
            foreach ($cert in $store.Certificates) {
                $certThumbprint = $cert.Thumbprint.ToUpper().Trim()
                Write-Output "  Thumbprint: $certThumbprint"
            }
        }

        # Check for matching thumbprint
        foreach ($cert in $store.Certificates) {
            $certThumbprint = $cert.Thumbprint.ToUpper().Trim()
            if ($certThumbprint -eq $CertificateThumbprintToSearch) {
                Write-Output "  Match found in LocalMachine\${storeName} for thumbprint: $certThumbprint"
                $foundCertificate = $true
            }
        }

        # Close the store
        $store.Close()
    } catch {
        Write-Error "Failed to access LocalMachine\${storeName}: $($_.Exception.Message)"
    }
}

# Final result
if ($foundCertificate) {
    Write-Host 'OK -'$Title
    Write-Output "OK -Certificate with thumbprint $CertificateThumbprintToSearch found."
    exit 0
} else {
    Write-Host 'ERR -'$Title
    Write-Output "ERR - Certificate with thumbprint $CertificateThumbprintToSearch not found in any LocalMachine store."
    exit 1
}
