$regConfig = @"
RegistryKey,Name
"HKLM:\SYSTEM\CurrentControlSet\Control\Lsa","scenoapplylegacyauditpolicy"
"HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit","ProcessCreationIncludeCmdLine_Enabled"
"HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription","EnableTranscripting"
"HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription","OutputDirectory"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging","EnableScriptBlockLogging"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging","EnableModuleLogging"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager",1
"HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest","UseLogonCredential"
"HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults","Allow*"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation","Allow*"
"@

$regConfig | ConvertFrom-Csv | ForEach-Object {
	if (-Not (Test-Path $_.RegistryKey)) {
		# Registry path does not exist -> document DNE
		#Write-Warning "Path $($_.RegistryKey) does not exist"
		New-Object PSObject -Property @{RegistryKey = $_.RegistryKey; Name = $_.Name; Value = "Does Not Exist"}
	}
	else {
		if ((Get-ItemProperty $_.RegistryKey | Select-Object -Property $_.Name).$_.Name -ne $null) {
			# Registry key exists. Document Value
			#Write-Warning "Key $($_.RegistryKey) if $(Get-ItemProperty $_.RegistryKey | Select-Object -Property $_.Name)"
			#Write-Warning "Property $($_.Name) exists. Documenting Value: $(Get-ItemProperty $_.RegistryKey | Select-Object -ExpandProperty $_.Name)"
			# Handle Cases where SubscriptionManager Value already exists.
			if ($_.RegistryKey -like "*SubscriptionManager*") {
				#Write-Warning "RegistryKey is Like SubscriptionManager"
				#Write-Warning "Property = $($_.Name)"
				$wecNum = 1
				# Backup each currently configured SubscriptionManager Values.
				while ( (Get-ItemProperty $_.RegistryKey | Select-Object -ExpandProperty $([string]$wecNum) -ErrorAction SilentlyContinue) ) {
					#Write-Warning "RegistryKey with property = $wecNum exists"
					New-Object PSObject -Property @{RegistryKey = $_.RegistryKey; Name = $wecNum; Value = $(Get-ItemProperty $_.RegistryKey | Select-Object -ExpandProperty $([string]$wecNum))}
					#Write-Warning "Incrementing wecNum"
					$wecNum++
				}
			}
			# Backup all non-SubscriptionManager Values to array.
			else {
				New-Object PSObject -Property @{RegistryKey = $_.RegistryKey; Name = $_.Name; Value = $(Get-ItemProperty $_.RegistryKey | Select-Object -ExpandProperty $_.Name)}
			}
		}
		else {
			# Registry key does not exist. Document DNE
			#Write-Warning "Property $($_.Name) DNE. Documenting Null"
			New-Object PSObject -Property @{RegistryKey = $_.RegistryKey; Name = $_.Name; Value = "Does Not Exist"}
		}
	}
}











# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiVoe81ITVnEAnS5vaZcDmNLB
# xSegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUIjmpEknw6x1gPid3UyATlOWQgmMwDQYJKoZI
# hvcNAQEBBQAEggEAqSThHljkNw+6N/gjwgU2WV2PUO7AlXQM14sGL518uXydY48X
# Y54vxX9cpmnoAqD9Mj0oOUqTq1DLzwzJvu9x2DSMdAdrrzftnnzN0+K88AoLBODn
# lT7/XHaJiokjnztKAWNipAiQTVnjbdV3NzYBqOv1tpuZnHoWLer0NzYeHFSxz640
# iCGjB3U80OdxN0uzSVeDqpgb9qFGzppYoDlb/o9qW1WjiqCmE+UhYZVg5E6aquXz
# axw8+k7PimB0R1xzUFEaAgdTutHqOdcEd+m0O2CUYBTA0kTMBcHtCpfexTF8XOBw
# tCpM6R1/0mTY9Am9X2eO493NsdfS6+/J08hDww==
# SIG # End signature block
