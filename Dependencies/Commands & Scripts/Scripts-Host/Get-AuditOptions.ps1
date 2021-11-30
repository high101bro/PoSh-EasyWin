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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdr4zWAv1Rv+1jD9Lv/3I1TGp
# laigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUAfDRUFnYJlfMyao+gqV9FyufQoMwDQYJKoZI
# hvcNAQEBBQAEggEAKMNq1OlIKP3wIDgjcCIX20BTq0uMuUBiEwYuk7XKkZ8/HLJc
# lCZYMQ+u9l/yOOsh30LVgBA4otHX8HD4lF2snldRDd4JFTgEgH/SRsFsXJ0jVlZv
# m/E9BnEao9cV/3luJjYb1mqAH56yrP7751bUAQyo2j+90MgyzJ2xeAgFKzzEQL1W
# 7StvayBZ9Tpek0DJfTFNpTZIxWkZ5vrGXkx+LA10h0x+YbpQO6iUCnfqc54xydqH
# ip5ZL60HcQ7A44y207ZhDrD8kOE0Li9BRLGnOICL+9NEc1P0KdW0a7GTp50wRerJ
# t9EkjYwnuTo2gmhchF5ytoj+R/V3oMu/qyyFnw==
# SIG # End signature block
