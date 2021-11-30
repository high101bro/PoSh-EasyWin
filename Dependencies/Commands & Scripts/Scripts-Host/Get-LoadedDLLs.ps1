	[cmdletbinding()]
	Param([bool] $NoHash = $false)
	$results = Get-Process | Select-Object -ExpandProperty Modules -ErrorAction SilentlyContinue | Sort-Object FileName -Unique | ForEach-Object {
		if ($_.FileName -ne $null -AND -NOT $NoHash) {
			$md5  = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
			$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($_.FileName)))
			$_ | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
		}
		else {
			$_ | Add-Member -MemberType NoteProperty MD5 $null
		}
		$_
	}
	$results | Select-Object -Property ModuleName,FileName,MD5,Size,Company,Description,FileVersion,Product,ProductVersion



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPlyq0X/MyuiqcX6+o/lDtTBO
# n7ygggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqZZnIhmxCnTuYWM+hdjQoXTuP5wwDQYJKoZI
# hvcNAQEBBQAEggEAuS+bspa0sj8LoAZ6v8BXy2qtANb3IMCxgG9nWc9xIfNIJ5u3
# OxrtqeRRV7o7b8anPS5DrN2MKnarudEGvceHRjOp12Gh/bDY6V5vz+vB1H+fYqx4
# qDDkhekVTlFNyC5ei0gvAYtbjtIg/53KqHogTacp1/dZr09K8Pc4B4oei0hZuibp
# fybuiU45jiwUke4+kN4Y60rRac5ekWpdcO6nZEbc6SIhLyduIShe4NgfH5esuqaY
# LCYoJem3hHIG6WBiBky6pwteTqKmo294hFZVxeebravCAsfY16cqWb37hvHDcU1+
# OYNr5P5SXpHLIkgjLOBWfCACjOnBlDhUb97flw==
# SIG # End signature block
