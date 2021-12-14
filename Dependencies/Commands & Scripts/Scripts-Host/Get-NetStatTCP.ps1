$NetworkConnections = netstat -nao -p TCP
$NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
	$line = $line -replace '^\s+',''
	$line = $line -split '\s+'
	$properties = @{
		Protocol      = $line[0]
		LocalAddress  = ($line[1] -split ":")[0]
		LocalPort     = ($line[1] -split ":")[1]
		RemoteAddress = ($line[2] -split ":")[0]
		RemotePort    = ($line[2] -split ":")[1]
		State         = $line[3]
		ProcessId     = $line[4]
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
$NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,Name,ProcessId,ParentProcessId,MD5,ExecutablePath,CommandLine



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuEbsr9OoEg3m/3+dU1p3PS1L
# 3VCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDM2exlCWexydMMUpMjBgQBIJlocwDQYJKoZI
# hvcNAQEBBQAEggEAk/js+a135aMhsSJ0s8HTCzbMTh5H3QhRK9CrV9QPEY0Y2veK
# TJe0rwt3ivLMX6YzttUTT2Dkc8VU9iJ9sERgnQHDloeBKIXnT0FJ31UBFxmkPFIZ
# 92mZDKlJODvVoyhzk44PsdsFvoK6rlxYVbLGjWW2E7B4fA21HOSGQc2mzFMmM2bP
# rTYuw+nw071TTLsYacRjVidy3KAdxDy3DSEkuNTnYi8MRCU6hUUHTEVKTqwjtdMt
# llwthlktwcZKaelyjIwIYQ15D39d1eflCBUvIvV3IP+jnULhna+3vei2d3EGYnI/
# Qoclhqlh2WAKJRurN+S3qL5r25Mflp17Mq9irw==
# SIG # End signature block
