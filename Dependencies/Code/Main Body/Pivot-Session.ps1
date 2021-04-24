param(
    $CredentialXML,
    $TargetComputer,
    $PivotHost
)
$Credential = Import-CliXML $CredentialXML
function Pivot-PSSession {
    param(
        $SessionId,
        $TargetComputer
    )
    while ($Command -ne "exit") {
        $Session = Get-PSSession -Id $SessionId
        $PivotHost = $Session.ComputerName
        Write-Host "[$PivotHost -> $TargetComputer]: Pivot> " -NoNewline
        $Command = Read-Host
        
        if ($Command -eq '' -or $Command -eq $null) {
            continue
        }        
        elseif ($Command -ne "exit") {
            function Pivot-Command {
                param(
                    $Command,
                    $TargetComputer,
                    $Credential
                )
                Invoke-Command `
                -ScriptBlock {
                    param($Command)
                    Invoke-Expression -Command "$Command"
                } `
                -ArgumentList @($Command,$null) `
                -ComputerName $TargetComputer `
                -credential $Credential `
                -HideComputerName
            }
            $PivotCommand = "function Pivot-Command { ${function:Pivot-Command} }"
            Invoke-Command `
            -ScriptBlock {
                param($PivotCommand,$Command,$TargetComputer,$Credential)
                . ([ScriptBlock]::Create($PivotCommand))

                Pivot-Command -Command $Command -TargetComputer $TargetComputer -Credential $Credential
            
            } `
            -Session $Session `
            -ArgumentList @($PivotCommand,$Command,$TargetComputer,$Credential) `
            -HideComputerName
        }
        elseif ($command -eq "exit") {
            $Session = Get-PSSession -Id $SessionId | Remove-PSSession
        }
        else {
            $Session = Get-PSSession -Id $SessionId | Remove-PSSession
        }
    }
}

$PivotSession = New-PSSession -ComputerName $PivotHost -Credential $Credential
Pivot-PSSession -SessionId $PivotSession.Id -TargetComputer $TargetComputer


            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

















