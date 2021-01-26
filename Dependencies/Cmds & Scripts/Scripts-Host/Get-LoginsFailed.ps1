# Get Filaed Logins (30 days)
Get-Eventlog -LogName Security -InstanceId 4625 -After (Get-Date).AddDays(-30) `
    | Select TimeGenerated, ReplacementStrings `
    | Foreach {
        New-Object PSObject -Property @{
        SourceComputer = $_.ReplacementStrings[13]
        UserName       = $_.ReplacementStrings[5]
        IPAddress      = $_.ReplacementStrings[19]
        Date           = $_.TimeGenerated
    }
}

