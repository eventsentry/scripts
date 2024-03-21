# Define the API key at the beginning of the script for easy maintenance
$apiKey = "API_FROM_WHOISXMLAPI"

# List of domains to check
$domains = @("domain1.com", "domain2.com")
# Set a flag to track if any domain is about to expire
$aboutToExpire = $false

foreach ($domain in $domains) {
    $whoisApiUrl = "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=$apiKey&domainName=$domain&outputFormat=JSON"

    # Use Invoke-RestMethod to query the WHOIS API
    $response = Invoke-RestMethod -Uri $whoisApiUrl

    # Check for API error response
    if ($response.ErrorMessage) {
        Write-Output "ERROR: API Error for domain $domain : $($response.ErrorMessage.msg)"
        $aboutToExpire = $true
        continue
    }

    # Check if the API response contains the expiration date
    if ($response.WhoisRecord -and $response.WhoisRecord.expiresDate) {
        $expirationDate = $response.WhoisRecord.expiresDate
        $expirationDateTime = [datetime]::Parse($expirationDate)
        $daysUntilExpiration = ($expirationDateTime - (Get-Date)).Days

        # Check if the domain is less than 30 days from expiration
        if ($daysUntilExpiration -lt 30) {
            Write-Output "ERROR: Domain $domain is about to expire in $daysUntilExpiration days."
            $aboutToExpire = $true
        } else {
            Write-Output "OK: Domain $domain expires in $daysUntilExpiration days."
        }
    } else {
        Write-Output "Warning: No expiration information available for domain $domain (Domain is not fully supported by whoisxmlapi)"
        $noInfo = $true
    }
}

# Exit with error 1 if any domain is about to expire
if ($aboutToExpire) {
    exit 1
}
if ($noInfo) {
    exit 998
}
