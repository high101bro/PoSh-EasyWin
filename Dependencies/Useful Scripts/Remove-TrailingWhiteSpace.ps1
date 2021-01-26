<#
    .Description
    This script removes white spaces at the end of each line in a script

    .Example
    foreach ($file in $(Get-ChildItem -Recurse | where {$_.name -like "*.ps1"})) { & ".\Dependencies\Useful Scripts\Remove-TrailingWhiteSpace.ps1" -InputFile $File.fullname -OutputFile $file.FullName}
#>

param($InputFile, $OutputFile, [switch]$verbose)

write-host "Removing trailing spaces from $InputFile"

$InitialFileSize = (Get-Item $InputFile).Length


$content = (Get-Content $InputFile -Raw) -split "\n"


$LineCount = 0
$ModifiedCount = 0
$ModifiedData = ''
ForEach ($line in $content) {
    $LineCount += 1
     if ($line -match "\s+$"){
        $ModifiedCount += 1
        $modifiedData += "$($line -replace '\s+$','')`n"
        if ($verbose){
            Write-host $line -ForegroundColor Red
            Write-Host "Removing white space from line:  $LineCount"
        }
     }
     else {
        $modifiedData += "$($line)`n"
        if ($verbose){
            Write-host $line -ForegroundColor White
        }
    }
}
$ModifiedData | Set-Content $OutputFile -Force

$ModifiedFileSize = (Get-Item $OutputFile).Length
$ModifiedFileSize = (Get-Item $OutputFile).Length
Write-Host "=========================================================="
Write-Host " Initial Filesize in bytes:  $InitialFileSize"
Write-Host "Modified Filesize in bytes:  $ModifiedFileSize"
Write-Host "Space Savings in bytes:      $($InitialFileSize - $ModifiedFileSize)"
Write-Host "Finished!"


