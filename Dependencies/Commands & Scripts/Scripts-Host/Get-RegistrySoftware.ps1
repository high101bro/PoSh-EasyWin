<#
.Description
	Gets the software installed by using the registry.
#>
$Software = @()
$Paths    = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")
ForEach($Path in $Paths) {
Write-Verbose  "Checking Path: $Path"
#  Create an instance of the Registry Object and open the HKLM base key
Try  {$reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$env:Computername,'Registry64')}
Catch  {Write-Error $_ ; Continue}
#  Drill down into the Uninstall key using the OpenSubKey Method
Try  {
	$regkey=$reg.OpenSubKey($Path)
	# Retrieve an array of string that contain all the subkey names
	$subkeys=$regkey.GetSubKeyNames()
	# Open each Subkey and use GetValue Method to return the required  values for each
	ForEach ($key in $subkeys){
		Write-Verbose "Key: $Key"
		$thisKey=$Path+"\\"+$key
		Try {
			$thisSubKey=$reg.OpenSubKey($thisKey)
			# Prevent Objects with empty DisplayName
			$DisplayName =  $thisSubKey.getValue("DisplayName")
			If ($DisplayName  -AND $DisplayName  -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {
				$Date = $thisSubKey.GetValue('InstallDate')
				If ($Date) {
					Try {$Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)}
					Catch{Write-Warning "$($env:Computername): $_ <$($Date)>" ; $Date = $Null}
				}
				# Create New Object with empty Properties
				$Publisher =  Try {$thisSubKey.GetValue('Publisher').Trim()}
					Catch {$thisSubKey.GetValue('Publisher')}
				$Version = Try {
					#Some weirdness with trailing [char]0 on some strings
					$thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))
				}
					Catch {$thisSubKey.GetValue('DisplayVersion')}
				$UninstallString =  Try {$thisSubKey.GetValue('UninstallString').Trim()}
					Catch {$thisSubKey.GetValue('UninstallString')}
				$InstallLocation =  Try {$thisSubKey.GetValue('InstallLocation').Trim()}
					Catch {$thisSubKey.GetValue('InstallLocation')}
				$InstallSource =  Try {$thisSubKey.GetValue('InstallSource').Trim()}
					Catch {$thisSubKey.GetValue('InstallSource')}
				$HelpLink = Try {$thisSubKey.GetValue('HelpLink').Trim()}
					Catch {$thisSubKey.GetValue('HelpLink')}
				$Object = [pscustomobject]@{
					Computername = $env:Computername
					DisplayName = $DisplayName
					Version  = $Version
					InstallDate = $Date
					Publisher = $Publisher
					UninstallString = $UninstallString
					InstallLocation = $InstallLocation
					InstallSource  = $InstallSource
					HelpLink = $thisSubKey.GetValue('HelpLink')
					EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize')*1024)/1MB,2))
				}
				$Object.pstypenames.insert(0,'System.Software.Inventory')
				$Software += $Object
				}
			}
			Catch {Write-Warning "$Key : $_"}
		}
	}
	Catch  {}
	$reg.Close()
}
$Software


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIkgHPMHCL/vGzba+ypNt3+Lb
# H2egggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/ivRy7N3PEFEbNpR9F+OiHD1ohkwDQYJKoZI
# hvcNAQEBBQAEggEAf1Qy9EJbsed6QbFToZD7r9WZdQ0zpkwQL8AKwzhAQeynpHWT
# me3FDfwjAdXR9hnmiQ07g+sdfvW8YZpkEbtyRvteN2I8vomM3kFnP41zB38+IUvf
# WPIaPFVPXE7L9WDgpuV4eKYiMQgPBvjNao5fFIspf4k4UMKx73aZ5kCMECw5EfDV
# H7gniyjsaxLOkI2YYXBmanIPnxBY7AdU5u3dJiXP5dBl4B4Hf4HwKcaRRqmFHu0X
# nT3ZH2lkgex5mxbHbLHifLb/Htvle2pshFZbx2/5pGDcTInkkW3Z4I47Wia8FDrx
# um0sT11wMPd2U/dAtA2ZtQI8LiVtWCEqYhvtmA==
# SIG # End signature block
