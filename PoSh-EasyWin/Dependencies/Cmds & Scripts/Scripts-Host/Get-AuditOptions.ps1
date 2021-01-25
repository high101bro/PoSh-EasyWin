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


