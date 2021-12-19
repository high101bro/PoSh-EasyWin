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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCXcwdAyw3+8SlLjqwd1Px9X0
# wOKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUHGDgBduZGdGH9bPutcAFBXU5WR4wDQYJKoZI
# hvcNAQEBBQAEggEAtVVRTdk3nRn4OYi49wu8valBxdVI/lPo2iCJOhkAMkKxSSXq
# XlLoqhHC0VminBB/LIZ3tRho5utP+jsf7Q3aVkas87bhh0+UX6bNnRsy5G8F96ZM
# BiY7sAC+b88X5lv6mT6UH6E1gswk5igvC18J20QMJDmZv/2nz637l9c4RsnJJDY8
# 7jgpcdU+GfHRtpRK3ZnqQYTU86OsgZ28O5HYlboSB5mdhttamrvMvZZAVGNLepZk
# LrCY30joJ2w9RNR6Y0XS9Eya/1WHpUYPAiN8JXHqVeLfc4iCR2n1tefr1mbmWPWz
# DOUW2Y+5x41VSnIqRU562grKbntZ3pD6gGyhjA==
# SIG # End signature block
