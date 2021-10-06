param(
    $CredentialXML,
    $ComputerList
)
function MultiEndpoint-PSSession {
    param(
        $SessionId,
        $ComputerList
    )
    while ($Command -ne "exit") {
        $PSSession = Get-PSSession -Id $SessionId

#        if ($PSSession.ComputerName.count -ge 1) {
#            Write-Host "MultiEndpoint [$($PSSession.ComputerName.count)]: > " -NoNewline
#        }
#        elseif ($PSSession.ComputerName.count -eq 0) {
            Write-Host "MultiEndpoint [$($PSSession.ComputerName.count)]: > " -NoNewline
#        }
        $Command = Read-Host
        
        if ($Command -eq '' -or $Command -eq $null) {
            continue
        }        
        elseif ($Command -ne "exit") {
            Invoke-Command `
            -ScriptBlock {
                param([string]$Command)
                . ([ScriptBlock]::Create("$Command")) | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $env:ComputerName -PassThru
            } `
            -Session $PSSession `
            -ArgumentList @($Command)
        }
        elseif ($command -eq "exit") {
            $PSSession = Get-PSSession -Id $SessionId | Remove-PSSession
        }
    }
}
$Credential = Import-CliXML "$CredentialXML"

$MultiEndpointSession = New-PSSession -ComputerName $ComputerList -Credential $Credential
MultiEndpoint-PSSession -SessionId $MultiEndpointSession.Id -ComputerList $ComputerList


