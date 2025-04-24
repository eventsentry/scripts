# This script can easily be integrated with EventSentry's performance monitoring functionality (option "executable")
# See KB 473 for more information

If ($args.Length -le 0)
{
    Write-Host "Hostname argument required"
    Exit(1)
}

# Path to the plink utility
$pathToPlink = "c:\tools\ssh\plink.exe"

# User for SSH login
$sshUser = "sshUser"

# Path to SSH public key cert, user/pass auth can be used an alternative, can also be customized to use cmd arg
$sshPathToCert = "C:\tools\ssh\sshCert"

$procInstance = @{}

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.Arguments = '-batch -i ' + $sshPathToCert + ' -l ' + $sshUser + ' ' + $args[0] + ' "ps -eo %cpu,cmd"'
$pinfo.FileName = $pathToPlink
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null

$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()

$processes = @()
$cpuValues = @()

$lines = $stdout.Split("`n")

ForEach ($line in $lines)
{
    $tokens = $line.Split(" ")
       
    If ($tokens.Count -gt 2)
    {
        $cpuUsage = $tokens[1]
        $processName = $tokens[2]
        
        try
        {
            $cpuValues += [Math]::Round($cpuUsage)
            
            $processName = $processName.TrimEnd(":")
            $processName = $processName.TrimEnd(")")
            $processName = $processName.TrimStart("-")
            $processName = $processName.TrimStart("(")
            
            $processNameOutput = $processName
            
            If ($procInstance[$processName] -gt 0)
            { 
                $processNameOutput += "#"
                $processNameOutput += $procInstance[$processName] 
            }
            
            $processes += $processNameOutput            
                    
            If ($procInstance[$processName] -eq '')
                { $procInstance[$processName] = 1 }
            Else
                { $procInstance[$processName]++ }
        }
        catch {
        }
    }
}

$processes -join ","
$cpuValues -join ","
