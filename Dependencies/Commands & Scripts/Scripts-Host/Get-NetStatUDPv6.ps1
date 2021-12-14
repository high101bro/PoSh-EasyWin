$NetworkConnections = netstat -nao -p UDPv6
$NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
	$line = $line -replace '^\s+',''
	$line = $line -split '\s+'
	$properties = @{
			Protocol = $line[0]
		    LocalAddress  = (($line[1] -split ']')[0]).TrimStart('[')
    		LocalPort     = (($line[1] -split ']')[1]).TrimStart(':')
			RemoteAddress = (try {(($line[2] -split ']')[0]).TrimStart('[')} catch {$line[2]})
			RemotePort    = (try {(($line[2] -split ']')[1]).TrimStart('[')} catch {$null})
			ProcessId = $line[3]
	}
	$Connection = New-Object -TypeName PSObject -Property $properties
	$proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[3])
	$Connection | Add-Member -MemberType NoteProperty ParentProcessId $proc.ParentProcessId
	$Connection | Add-Member -MemberType NoteProperty Name $proc.Caption
	$Connection | Add-Member -MemberType NoteProperty ExecutablePath $proc.ExecutablePath
	$Connection | Add-Member -MemberType NoteProperty PSComputerName $env:COMPUTERNAME
	if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
		$MD5  = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
		$hash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
		$Connection | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
	}
	else {
		$Connection | Add-Member -MemberType NoteProperty MD5 $null
	}
	$Connection | Add-Member -MemberType NoteProperty CommandLine $proc.CommandLine
	$Connection
}
$NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,Name,ProcessId,ParentProcessId,MD5,ExecutablePath,CommandLine



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOg/CgwaENQql45IzOD7nKgd+
# fvugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUUkrXQiQTFJU8JdL6yxHgps12ZrEwDQYJKoZI
# hvcNAQEBBQAEggEALgOJs4tyFENwg0B+7pe02W9VH6Ph/a4Yss7Xm2c+vRR70WpS
# wg15LvaP0Ei2G8qIPB2LL7AybhDysv/a26Cb1kLfbcxTiEK6At8novqIsM+zXkHn
# jcC0pXOQcSyn5jQaccy9jRCAqDyoGFXQzcim2MRBOJb0A1GAnFYIwReVje+zO51h
# wmprtBhiebla+s5BfJr2sx7SOrQ9/DfwNtx3v7LrMb2OFxHK2BQ7z28JuM95sAsr
# UNKRgehN++iAMElOekRs0av31MW6IygVbwIjqB2y4j4QnapOjODu1InBsy/HY/np
# iHMwzSiLmkNwpT+xZh5nYMkaZMLk2I6cwOmnFw==
# SIG # End signature block
