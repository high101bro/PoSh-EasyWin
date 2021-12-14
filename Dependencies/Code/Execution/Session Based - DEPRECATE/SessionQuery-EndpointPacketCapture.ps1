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
# NqqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUNThktCs30yL6v8/jDEI1SOV5vz4wDQYJKoZI
# hvcNAQEBBQAEggEAAC+ja2+vTQ6c6EqAZY1Fh1Nfa/cE6TKDgtGWowt4k3HXhdWo
# hwIW49bkR1a8GM2SFIC5zRb8WMF8k2IY7/eN2Xm/9girm9Cu6Eszn4Xotv0UsrUU
# O89kVe4Lec1cFxOwzVJ+TOui6P3qhIS3Vmsbq2g1Y5Bj7FGQyyRtSKfmwJeFgtBk
# hU+FlLpLnohFdyfx/lDAdop46xiWt4LnSjy/ZWvmG3tKNjBcxNpvqpZBBJYeCAPp
# 1BUqdWOTcZVD7dfFWpVw69gp46pgbYCZiUYyFaPC9GcPkDJCr9YOVP6IzJlUbfnk
# oXELTPWGfxz7RHuwntmg/zMYF0IDrpnW3fHpNg==
# SIG # End signature block
