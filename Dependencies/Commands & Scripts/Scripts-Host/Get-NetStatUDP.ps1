$NetworkConnections = netstat -nao -p UDP | select -First 10
$NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
	$line = $line -replace '^\s+',''
	$line = $line -split '\s+'
	$properties = @{
		Protocol      = $line[0]
		LocalAddress  = ($line[1] -split ":")[0]
		LocalPort     = ($line[1] -split ":")[1]
		RemoteAddress = ($line[2] -split ":")[0]
		RemotePort    = ($line[2] -split ":")[1]
		#State         = $line[3]
		ProcessId     = $line[3]
	}
	$Connection = New-Object -TypeName PSObject -Property $properties
	$proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
	$Connection | Add-Member -MemberType NoteProperty ParentProcessId $proc.ParentProcessId
	$Connection | Add-Member -MemberType NoteProperty Name $proc.Caption
	$Connection | Add-Member -MemberType NoteProperty ExecutablePath $proc.ExecutablePath
	$Connection | Add-Member -MemberType NoteProperty CommandLine $proc.CommandLine
	$Connection | Add-Member -MemberType NoteProperty PSComputerName $env:COMPUTERNAME
	if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
		$MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
		$hash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
		$Connection | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
	}
	else {
		$Connection | Add-Member -MemberType NoteProperty MD5 $null
	}
	$Connection
}
$NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,Name,ProcessId,ParentProcessId,MD5,ExecutablePath,CommandLine



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXovMn6bCRY2zK4n41KUNkM4r
# 7QugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtc9JtLwprxetd6tjGxAbSBemudswDQYJKoZI
# hvcNAQEBBQAEggEAGj83jyoLuOgJtD33P1nw25ge5LWh8cJhdHCA8zkx1mnFfr+0
# +2NkEtQoYJrSwO5d0eJtQ7JJ1sALu7sli1EnCB8xdMAoIyAfm1dR9IHmpK1Mz9NX
# sKX0ZEXBif6jaXsTyPXeXaOqpktinSFf4tijJwhhfR3cTKzTlnoIYTB3T/6CVVgv
# xow+IOqYSnD2m9wilgdBSAApQAIk8vAFJ++o5G0Dcgi0cJoeo4oj8EB4xzubiE/h
# 4e8gdYPNc7cw3m9i7leIGvmFP2YdWA3oklJrUNZgHjnZPyicw1zkUyko+lrZCCIl
# u/QYgMpDceh3jYuBphLzzRIBNokclSBF1FkNtA==
# SIG # End signature block
