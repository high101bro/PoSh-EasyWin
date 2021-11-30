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
# H2egggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/ivRy7N3PEFEbNpR9F+OiHD1ohkwDQYJKoZI
# hvcNAQEBBQAEggEAh7edKLgnENxtARuHcDRHaHNx/DPDtRU6ZNyBSghGnUqarlz4
# pVVPh4kukgEOuraNRF1rYOJPahasayJAh/oDGamPlF1Dpldmw8DkF+J12IrZ2RmX
# V46TYBD0BGMtxG97zv8WFW/ufoAoWpx2Gze9X+unY5r0+/AXomH0gCwDQLlic0hk
# vFF75kZ6HCuT9lpmBFflUv9lUUSgwk/WfRFuppKtMgY2qgbU7hcxDSJ9wodBAP4U
# zTsHxTpiag73ySFZ/HnUl4oAZR5XLd6qnAHUqppMvTwJy+l5q1c2f+8tLQh/KaZ0
# EulX3AyjmapjDKWI4lApJV6WsZm6sou24AOtFw==
# SIG # End signature block
