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

#$MainBottomTabControl.SelectedTab = $Section3ResultsTab
$MainBottomTabControl.SelectedTab = $Section3MonitorJobsTab

$ExecutionStartTime = Get-Date
$CollectionName = "Endpoint Packet Capture"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

New-Item -Type Directory -path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\" -ErrorAction SilentlyContinue


$script:ProgressBarEndpointsProgressBar.Value = 0

[int]$MaxSize        = $NetworkEndpointPacketCaptureMaxSizeTextBox.text
[int]$CaptureSeconds = $NetworkEndpointPacketCaptureDurationTextBox.text
$CaptureType = 'physical'
$Report      = 'Yes'
$etl2pcapng  = "$Dependencies\Executables\Packet Capture\etl2pcapng\x64\etl2pcapng.exe"
$DateTime    = (Get-Date).ToString('yyyyMMdd_HHmmss')
$TraceName   = 'NetTrace'


$EndpointEtlTraceFile = "C:\Windows\Temp\$TraceName.etl" # Remote Host
$EndpointCabTraceFile = "C:\Windows\Temp\$TraceName.cab"
$PacketCaptureName    = "Endpoint Packet Capture - $DateTime.pcapng"
#$OutCsv     = = "$($script:CollectionSavedDirectoryTextBox.Text)\Endpoint Packet Capture-$DateTime.csv"


#$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
#Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "netsh trace start capture=yes capturetype=$CaptureType report=$Report persistent=no maxsize=$MaxSize overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"
#Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "netsh trace stop"
#$PoShEasyWin.Refresh()


foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $($script:CollectionSavedDirectoryTextBox.Text) `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


    $LocalEtlFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$TargetComputer - $TraceName.etl"
    $LocalCabFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$TargetComputer - $TraceName.cab"
    $OutPcapNG        = "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$TargetComputer - $PacketCaptureName"


    Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer $DateTime" -ScriptBlock {
        param(
            $ComputerListProvideCredentialsCheckBox,
            $script:Credential,
            $TargetComputer,
            $CaptureType,
            $Report,
            $MaxSize,
            $CaptureSeconds,
            $EndpointEtlTraceFile,
            $EndpointCabTraceFile,
            $LocalEtlFilePath,
            $LocalCabFilePath,
            $etl2pcapng,
            $OutPcapNG,
            $OptionPacketKeepEtlCabFilesCheckBox,
            $script:CollectionSavedDirectoryTextBox,
            $CollectionName
        )



        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            
            $Session = New-PSSession -ComputerName $TargetComputer -Credential $script:Credential
        }
        else {
            $Session = New-PSSession -ComputerName $TargetComputer
        }
    


        Invoke-Command -ScriptBlock {
            param(
                $CaptureType,
                $Report,
                $MaxSize,
                $CaptureSeconds,
                $EndpointEtlTraceFile
            )
            Invoke-Expression "netsh trace start capture=yes capturetype=$CaptureType report=$Report persistent=no maxsize=$MaxSize overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"
            Start-Sleep -Seconds $CaptureSeconds
            Invoke-Expression 'netsh trace stop' | Out-Null
        } -argumentlist @($CaptureType,$Report,$MaxSize,$CaptureSeconds,$EndpointEtlTraceFile) -Session $Session
        Start-Sleep -Seconds 1


        # Copies up the .etl and .cab files back to the localhost
        Copy-Item -Path $EndpointEtlTraceFile -Destination $LocalEtlFilePath -FromSession $Session -Force
        Copy-Item -Path $EndpointCabTraceFile -Destination $LocalCabFilePath -FromSession $Session -Force
        Start-Sleep -Seconds 1



        # Cleans up the .etl and .cab files from the endpoint
        Invoke-Command -ScriptBlock {
            param(
                $EndpointEtlTraceFile,
                $EndpointCabTraceFile
            )
            Remove-Item -Path $EndpointEtlTraceFile -Force
            Remove-Item -Path $EndpointCabTraceFile -Force
        } -argumentlist @($EndpointEtlTraceFile,$EndpointCabTraceFile) -Session $Session


        $Session | Remove-PSSession


        # Converts the Event Trace Log (.etl) file to a .pcap file
        & $etl2pcapng $LocalEtlFilePath $OutPcapNG | Out-Null

        Start-Sleep -Seconds 1


        if ( $OptionPacketKeepEtlCabFilesCheckBox.checked -eq $false ) {
            Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\*.etl" -Force
            Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\*.cab" -Force
        }
        

    } -ArgumentList @($ComputerListProvideCredentialsCheckBox,$script:Credential,$TargetComputer,$CaptureType,$Report,$MaxSize,$CaptureSeconds,$EndpointEtlTraceFile,$EndpointCabTraceFile,$LocalEtlFilePath,$LocalCabFilePath,$etl2pcapng,$OutPcapNG,$OptionPacketKeepEtlCabFilesCheckBox,$script:CollectionSavedDirectoryTextBox,$CollectionName)



    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PcapSwitch
}



#$FileSize = [math]::round(((Get-Item $OutPcapNG).Length/1mb),2)

# Temporarily changes the job timeout to allow completion of the packet capture
#$JobTimeoutOriginalSetting = $script:OptionJobTimeoutSelectionComboBox.text
#$script:OptionJobTimeoutSelectionComboBox.text = [int]$CaptureSeconds + 60


#Monitor-Jobs -CollectionName $CollectionName -NotExportFiles


# Sets the job timeout back to the orginal setting
#$script:OptionJobTimeoutSelectionComboBox.text = $JobTimeoutOriginalSetting




$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()






