#
# Returns an error code <> 0 if at least one site or
# application pool are not running
#

$exitCode = 0

[Void][Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")

$sm = New-Object Microsoft.Web.Administration.ServerManager

foreach($site in $sm.Sites)
{
    $root = $site.Applications | where { $_.Path -eq "/" }
	
	if ($site.state -ne "Started")
	{
		Write-Output ("[ERROR] Site """ + $site.Name + """ (using " + $root.ApplicationPoolName + ") is """ + $site.state + """")
		$exitCode = $exitCode + 1
	}
}

foreach($appPool in $sm.ApplicationPools)
{
	if ($appPool.state -ne "Started")
	{
		Write-Output ("[ERROR] Application Pool """ + $appPool.Name + """ is """ + $appPool.state + """")
		$exitCode = $exitCode + 1
	}
}

if ($exitCode -eq 0)
{
	Write-Output "[OK] All sites and application pools are started"
}

exit $exitCode
