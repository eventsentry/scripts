#Specify Number of days
$numDays = '10'
$strMonPath = "C:\Temp"
$strLogPath = "C:\Logs"

Function Get-NeglectedFiles
{
 Param([string[]]$path,
       [int]$numberDays)
 $cutOffDate = (Get-Date).AddDays(-$numberDays)
 Get-ChildItem -Path $path |
 Where-Object {$_.LastWriteTime -le $cutOffDate}
}

If(!(test-path $strLogPath))
{
      New-Item -ItemType Directory -Force -Path $strLogPath
}

Get-NeglectedFiles -path $strMonPath -numberDays $numDays | select name, lastwritetime  | Export-Csv -Path $strLogPath\NotModifiedFiles.csv -NoTypeInformation