<#
https://isc.sans.edu/forums/diary/No+Wireshark+No+TCPDump+No+Problem/19409/

https://github.com/microsoft/etl2pcapng/

https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/converting-etl-files-to-pcap-files/ba-p/1133297

# Converts etl file to html
netsh trace convert input='C:\Users\admin\AppData\Local\Temp\NetTraces\NetTrace.etl' output='c:\trace.html'


Defaults:
	capture        = no (specifies whether packet capture is enabled in addition to trace events)
	capturetype    = physical (specifies whether packet capture needs to be enabled for physical network adapters only, virtual switch only, or both physical network adapters and virtual switch)
	report         = no (specifies whether a complementing report will be generated along with the trace file)
	persistent     = no (specifies whether the tracing session continues across reboots, and is on until netsh trace stop is issued)
	maxSize        = 250 MB (specifies the maximum trace file size, 0=no maximum)
	fileMode       = circular
	overwrite      = yes (specifies whether an existing trace output file will be overwritten)
	correlation    = yes (specifies whether related events will be correlated and grouped together)
	perfMerge      = yes (specifies whether performance metadata is merged into trace)
	traceFile      = %LOCALAPPDATA%\Temp\NetTraces\NetTrace.etl (specifies location of the output file)
	providerFilter = no (specifies whether provider filter is enabled)
#>

$InformationTabControl.SelectedTab = $Section3ResultsTab
#$InformationTabControl.SelectedTab = $Section3MonitorJobsTab

$ExecutionStartTime = Get-Date
$CollectionName = "Endpoint Packet Capture"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

New-Item -Type Directory -Path "$script:CollectedDataTimeStampDirectory\$CollectionName\" -ErrorAction SilentlyContinue

$script:ProgressBarEndpointsProgressBar.Value = 0

[int]$MaxSize        = $NetworkEndpointPacketCaptureMaxSizeComboBox.text
[int]$CaptureSeconds = $NetworkEndpointPacketCaptureDurationComboBox.text
$CaptureType = 'physical'
$Report      = 'Yes'
$etl2pcapng  = "$Dependencies\Executables\Packet Capture\etl2pcapng\x64\etl2pcapng.exe"
$DateTime    = (Get-Date).ToString('yyyyMMdd_HHmmss')
$TraceName   = 'NetTrace'

$EndpointEtlTraceFile = "C:\Windows\Temp\$TraceName.etl" # Remote Host
$EndpointCabTraceFile = "C:\Windows\Temp\$TraceName.cab"
$PacketCaptureName = "Endpoint Packet Capture - $DateTime.pcapng"
#$OutCsv     = = "$script:CollectedDataTimeStampDirectory\Endpoint Packet Capture-$DateTime.csv"


Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "netsh trace start capture=yes capturetype=$CaptureType report=$Report persistent=no maxsize=$MaxSize overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"
Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "netsh trace stop"
$PoShEasyWin.Refresh()

Invoke-Command -ScriptBlock {
    param(
		$CaptureType,
		$Report,
		$MaxSize,
		$EndpointEtlTraceFile,
		$CaptureSeconds
	)
	Invoke-Expression "netsh trace start capture=yes capturetype=$CaptureType report=$Report persistent=no maxsize=$MaxSize overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"
	Start-Sleep -Seconds $CaptureSeconds
	Invoke-Expression 'netsh trace stop' | Out-Null
} -argumentlist @($CaptureType,$Report,$MaxSize,$EndpointEtlTraceFile,$CaptureSeconds) -Session $PSSession


foreach ($Session in $PSSession) {
	try {
		$LocalEtlFilePath = "$script:CollectedDataTimeStampDirectory\$CollectionName\$($Session.ComputerName) - $TraceName.etl"
		$LocalCabFilePath = "$script:CollectedDataTimeStampDirectory\$CollectionName\$($Session.ComputerName) - $TraceName.cab"
		$OutPcapNG        = "$script:CollectedDataTimeStampDirectory\$CollectionName\$($Session.ComputerName) - $PacketCaptureName"

		$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying data from $($Session.ComputerName)")
		Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $EndpointEtlTraceFile -Destination $LocalEtlFilePath -FromSession $Session -Force"
		$PoShEasyWin.Refresh()

		# Attempts to copy the files from the remote hosts
		Copy-Item -Path $EndpointEtlTraceFile -Destination $LocalEtlFilePath -FromSession $Session -Force
		Copy-Item -Path $EndpointCabTraceFile -Destination $LocalCabFilePath -FromSession $Session -Force

		$FileSize = [math]::round(((Get-Item $LocalEtlFilePath).Length/1mb),2)
		$ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Network Trace File is $FileSize MB")
		$PoShEasyWin.Refresh()

		# Uses etl2pcapng.exe to convert the network capture the file format from .etl to .pcapng
		$ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Converting .etl to .pcap")
		$PoShEasyWin.Refresh()
		& $etl2pcapng $LocalEtlFilePath $OutPcapNG | Out-Null

		$FileSize = [math]::round(((Get-Item $OutPcapNG).Length/1mb),2)
		$ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Pcap File is $FileSize MB")
		$PoShEasyWin.Refresh()
	}
	catch {
		# If an error occurs, it will display it
		$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy Error: $($_.Exception)")
		Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
		$PoShEasyWin.Refresh()
		break
	}

	try {
		# Attempts to remove the etl and cab files
		$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Cleaning up Endpoint Packet Capture (.etc/.cab) files")
		Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$EndpointEtlTraceFile' -Force"
		Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$EndpointCabTraceFile' -Force"
		$PoShEasyWin.Refresh()
		Start-Sleep -Seconds 3
		Invoke-Command -ScriptBlock {
			param(
				$EndpointEtlTraceFile,
				$EndpointCabTraceFile
			)
			Remove-Item -Path $EndpointEtlTraceFile -Force
			Remove-Item -Path $EndpointCabTraceFile -Force
		} -ArgumentList @($EndpointEtlTraceFile,$EndpointCabTraceFile) -Session $Session
	}
	catch {
		# If a error occurs, it will display it
		$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Remove Error: $($_.Exception)")
		Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Remove Error: $($_.Exception)"
		$PoShEasyWin.Refresh()
		break
	}
}

if ( $OptionPacketKeepEtlCabFilesCheckBox.checked -eq $false ) {
    Remove-Item -Path "$script:CollectedDataTimeStampDirectory\$CollectionName\*.etl" -Force
    Remove-Item -Path "$script:CollectedDataTimeStampDirectory\$CollectionName\*.cab" -Force
}

Invoke-Item -Path "$script:CollectedDataTimeStampDirectory\$CollectionName\"

$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9IXgEvI72MN/glpn8Ep1NxaA
# NqqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUNThktCs30yL6v8/jDEI1SOV5vz4wDQYJKoZI
# hvcNAQEBBQAEggEAdG1k0byI52yQzA7nnkuuLYeIY11MnlaCfJVy1eU92HoppiO4
# 9Km3Ol2L7Wvq3fa6TOars/2cz2gCgJVf2Hv5/9c2qQ8HvVAPJ+9e6Qyr8httWGwN
# e67j+ZTjy5OBeBeGBwUMgzTR7pOFuhT8ulmxZi6FU6PC1jI0DXYVKg1hE6UcrN6c
# AXlGxQ+aGVdzewsfjqL3N1S7hXUjJMk6NLbRKTT43R6sNBkHLiZ3unxpRxCgkzKZ
# vA16gSmTFHWS2QG61mPbDQ1iwmHxuqw+UuuC4jSVvscHAw/h0E7veYlBse+Ctk5h
# axAKUtSPLaCgDYxd8kKhAlD49JpkBIL1bvZEoQ==
# SIG # End signature block
