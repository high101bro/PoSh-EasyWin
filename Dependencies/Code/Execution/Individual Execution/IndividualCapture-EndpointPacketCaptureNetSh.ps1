<#
https://isc.sans.edu/forums/diary/No+Wireshark+No+TCPDump+No+Problem/19409/

https://github.com/microsoft/etl2pcapng/

https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/converting-etl-files-to-pcap-files/ba-p/1133297

# Converts etl file to html
netsh trace convert input='C:\Users\admin\AppData\Local\Temp\NetTraces\NetTrace.etl' output='c:\trace.html'


Defaults:
	capture        = no [yes/no] (specifies whether packet capture is enabled in addition to trace events)
	capturetype    = physical (specifies whether packet capture needs to be enabled for physical network adapters only, virtual switch only, or both physical network adapters and virtual switch)
	report         = no [yes/no] (specifies whether a complementing report will be generated along with the trace file)
	persistent     = no [yes/no] (specifies whether the tracing session continues across reboots, and is on until netsh trace stop is issued)
	maxSize        = 250 MB (specifies the maximum trace file size, 0=no maximum)
	fileMode       = circular [circular, single, append]
	overwrite      = yes [yes/no] (specifies whether an existing trace output file will be overwritten)
	correlation    = yes [yes/no] (specifies whether related events will be correlated and grouped together)
	perfMerge      = yes [yes/no] (specifies whether performance metadata is merged into trace)
	traceFile      = %LOCALAPPDATA%\Temp\NetTraces\NetTrace.etl (specifies location of the output file)
	providerFilter = no [yes/no] (specifies whether provider filter is enabled)
#>


#$InformationTabControl.SelectedTab = $Section3ResultsTab
$InformationTabControl.SelectedTab = $Section3MonitorJobsTab

$ExecutionStartTime = Get-Date
$CollectionName = "Endpoint Packet Capture"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

New-Item -Type Directory -path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\" -ErrorAction SilentlyContinue


$script:ProgressBarEndpointsProgressBar.Value = 0


$Report      = 'Yes'
$etl2pcapng  = "$Dependencies\Executables\Packet Capture\etl2pcapng\x64\etl2pcapng.exe"
$DateTime    = (Get-Date).ToString('yyyyMMdd_HHmmss')
$TraceName   = 'NetTrace'


$EndpointEtlTraceFile = "C:\Windows\Temp\$TraceName.etl" # Remote Host
$EndpointCabTraceFile = "C:\Windows\Temp\$TraceName.cab"
$PacketCaptureName    = "Endpoint Packet Capture - $DateTime.pcapng"
#$OutCsv     = = "$($script:CollectionSavedDirectoryTextBox.Text)\Endpoint Packet Capture-$DateTime.csv"


#$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
#Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "netsh trace start capture=yes capturetype=$NetworkEndpointPacketCaptureCaptureType report=$Report persistent=no maxsize=$NetworkEndpointPacketCaptureMaxSizeComboBox overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"
#Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "netsh trace stop"
#$PoShEasyWin.Refresh()


##################################################
if ($NetworkEndpointPacketCaptureDurationComboBox.text -match 'second') {
    $NetworkEndpointPacketCaptureDuration = [int]([int]($NetworkEndpointPacketCaptureDurationComboBox.text).split()[0])
}
elseif ($NetworkEndpointPacketCaptureDurationComboBox.text -match 'minute') {
    $NetworkEndpointPacketCaptureDuration = [int]([int]($NetworkEndpointPacketCaptureDurationComboBox.text).split()[0] * 60)
}
elseif ($NetworkEndpointPacketCaptureDurationComboBox.text -match 'hour') {
    $NetworkEndpointPacketCaptureDuration = [int]([int]($NetworkEndpointPacketCaptureDurationComboBox.text).split()[0] * 60 * 60)
}
else {
    $NetworkEndpointPacketCaptureDuration = [int]$NetworkEndpointPacketCaptureDurationComboBox.text
}

##################################################
$NetworkEndpointPacketCaptureCaptureType = "CaptureType=$($NetworkEndpointPacketCaptureCaptureTypeComboBox.text)"


##################################################
$NetworkEndpointPacketCaptureMaxSize = "MaxSize=$($NetworkEndpointPacketCaptureMaxSizeComboBox.text)"


##################################################
if ($NetworkEndpointPacketCaptureProtocolComboBox.text -eq 'No Filter'){ 
    $NetworkEndpointPacketCaptureProtocol = '' 
}
else { 
    $NetworkEndpointPacketCaptureProtocol = "Protocol=$($NetworkEndpointPacketCaptureProtocolComboBox.text)" 
}


##################################################
if ($NetworkEndpointPacketCaptureEtherTypeComboBox.text -eq 'No Filter'){ 
    $NetworkEndpointPacketCaptureEtherType = '' 
}
else { 
    $NetworkEndpointPacketCaptureEtherType = "Ethernet.Type=$($NetworkEndpointPacketCaptureEtherTypeComboBox.text)" 
}


<#
##################################################

if ($NetworkEndpointPcapCaptureSourceIPCheckbox.checked){
    if ($netshfilters -eq $true) {
        if ( (($NetworkEndpointPacketCaptureSourceIPRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPcapCaptureSourceIP = @"
&& IPv4.SourceAddress=($(($NetworkEndpointPacketCaptureSourceIPRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPcapCaptureSourceIP = @"
&& IPv4.SourceAddress=$($NetworkEndpointPacketCaptureSourceIPRichTextBox.text)
"@
        }
    }
    else {
        if ( (($NetworkEndpointPacketCaptureSourceIPRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPcapCaptureSourceIP = @"
IPv4.SourceAddress=($(($NetworkEndpointPacketCaptureSourceIPRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPcapCaptureSourceIP = @"
IPv4.SourceAddress=$($NetworkEndpointPacketCaptureSourceIPRichTextBox.text)
"@
        }
    }
    $netshfilters = $true
}
else { $NetworkEndpointPcapCaptureSourceIP = '' }


#IPv6.SourceAddress=<IPv6 address>


##################################################
if ($NetworkEndpointPcapCaptureSourceMACCheckbox.checked){ 
    if ($netshfilters -eq $true) {
        if ( (($NetworkEndpointPacketCaptureSourceMACRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPacketCaptureSourceMAC = @"
&& Ethernet.SourceAddress=($(($NetworkEndpointPacketCaptureSourceMACRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPacketCaptureSourceMAC = @"
&& Ethernet.SourceAddress=$($NetworkEndpointPacketCaptureSourceMACRichTextBox.text)
"@
        }        
    }
    else {
        if ( (($NetworkEndpointPacketCaptureSourceMACRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPacketCaptureSourceMAC = @"
Ethernet.SourceAddress=($(($NetworkEndpointPacketCaptureSourceMACRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPacketCaptureSourceMAC = @"
Ethernet.SourceAddress=$($NetworkEndpointPacketCaptureSourceMACRichTextBox.text)
"@
        }
    }
    $netshfilters = $true
}
else { $NetworkEndpointPacketCaptureSourceMAC = '' }


##################################################
if ($NetworkEndpointPcapCaptureDestinationIPCheckbox.checked){ 
    if ($netshfilters -eq $true) {
        if ( (($NetworkEndpointPacketCaptureDestinationIPRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPacketCaptureDestinationIP = @"
&& IPv4.DestinationAddress=($(($NetworkEndpointPacketCaptureDestinationIPRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPacketCaptureDestinationIP = @"
&& IPv4.DestinationAddress=$($NetworkEndpointPacketCaptureDestinationIPRichTextBox.text)
"@
        }
    }
    else {
        if ( (($NetworkEndpointPacketCaptureDestinationIPRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPacketCaptureDestinationIP = @"
IPv4.DestinationAddress=($(($NetworkEndpointPacketCaptureDestinationIPRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPacketCaptureDestinationIP = @"
IPv4.DestinationAddress=$($NetworkEndpointPacketCaptureDestinationIPRichTextBox.text)
"@
        }
    }
    $netshfilters = $true
}
else { $NetworkEndpointPacketCaptureDestinationIP = '' }


#IPv6.DestinationAddress=<IPv6 address>


##################################################
if ($NetworkEndpointPcapCaptureDestinationMACCheckbox.checked){ 
    if ($netshfilters -eq $true) {
        if ( (($NetworkEndpointPacketCaptureDestinationMACRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPacketCaptureDestinationMAC = @"
&& Ethernet.DestinationAddress=($(($NetworkEndpointPacketCaptureDestinationMACRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPacketCaptureDestinationMAC = @"
&& Ethernet.DestinationAddress=$($NetworkEndpointPacketCaptureDestinationMACRichTextBox.text)
"@
        }
    }
    else {
        if ( (($NetworkEndpointPacketCaptureDestinationMACRichTextBox.text).split("`r`n") | ? {$_ -ne ''}) -gt 1 ){
            $NetworkEndpointPacketCaptureDestinationMAC = @"
Ethernet.DestinationAddress=($(($NetworkEndpointPacketCaptureDestinationMACRichTextBox.text).split("`r`n") -join ','))
"@
        }
        else {
            $NetworkEndpointPacketCaptureDestinationMAC = @"
Ethernet.DestinationAddress=$($NetworkEndpointPacketCaptureDestinationMACRichTextBox.text)
"@
        }
    }
    $netshfilters = $true
}
else { $NetworkEndpointPacketCaptureDestinationMAC = '' }
#>


#perfMerge=yes correlation=yes
$PacketCaptureCommandNetSh = "netsh trace start Capture=Yes $NetworkEndpointPacketCaptureCaptureType Report=$Report Persistent=No overwrite=yes traceFile=$EndpointEtlTraceFile $NetworkEndpointPacketCaptureMaxSize $NetworkEndpointPacketCaptureProtocol $NetworkEndpointPacketCaptureEtherType"
# $NetworkEndpointPacketCaptureSourceMAC $NetworkEndpointPacketCaptureDestinationMAC $NetworkEndpointPcapCaptureSourceIP $NetworkEndpointPacketCaptureDestinationIP
$PacketCaptureCommandNetSh = $PacketCaptureCommandNetSh.replace('  ',' ').trim(' ')



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
            $EndpointEtlTraceFile,
            $EndpointCabTraceFile,
            $LocalEtlFilePath,
            $LocalCabFilePath,
            $etl2pcapng,
            $OutPcapNG,
            $OptionPacketKeepEtlCabFilesCheckBox,
            $script:CollectionSavedDirectoryTextBox,
            $CollectionName,
            $PacketCaptureCommandNetSh,
            $NetworkEndpointPacketCaptureDuration
        )


        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            
            $Session = New-PSSession -ComputerName $TargetComputer -Credential $script:Credential
        }
        else {
            $Session = New-PSSession -ComputerName $TargetComputer
        }


        Invoke-Command -ScriptBlock {
            param($PacketCaptureCommandNetSh,$NetworkEndpointPacketCaptureDuration)

            Invoke-Expression $PacketCaptureCommandNetSh
            Start-Sleep -Seconds $NetworkEndpointPacketCaptureDuration
            Invoke-Expression 'netsh trace stop' | Out-Null

        } -argumentlist @($PacketCaptureCommandNetSh,$NetworkEndpointPacketCaptureDuration) -Session $Session
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
        

    } -ArgumentList @(
        $ComputerListProvideCredentialsCheckBox,
        $script:Credential,
        $TargetComputer,
        $EndpointEtlTraceFile,
        $EndpointCabTraceFile,
        $LocalEtlFilePath,
        $LocalCabFilePath,
        $etl2pcapng,
        $OutPcapNG,
        $OptionPacketKeepEtlCabFilesCheckBox,
        $script:CollectionSavedDirectoryTextBox,
        $CollectionName,
        $PacketCaptureCommandNetSh,
        $NetworkEndpointPacketCaptureDuration
    )


    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
    
    $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Note:
===========================================================================
This uses netsh to create an event trace log and an associated report. Both are copied back for local processing and cleaned up on each endpoint. Once copied locally, each .etl file is converted to a .pcap with etl2pcap.exe. Then the .etl and report files are either deleted locally or saved depending if the option is set to do so. The .pcap files can be opened with WireShark for analysis which also include correlated PID information.

===========================================================================
Duration:
===========================================================================
$NetworkEndpointPacketCaptureDuration

===========================================================================
Command:
===========================================================================
$PacketCaptureCommandNetSh

"@
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PcapSwitch -DisableReRun -InputValues $InputValues
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $CollectionName -NotExportFiles
        Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }
}



#$FileSize = [math]::round(((Get-Item $OutPcapNG).Length/1mb),2)

# Temporarily changes the job timeout to allow completion of the packet capture
#$JobTimeoutOriginalSetting = $script:OptionJobTimeoutSelectionComboBox.text
#$script:OptionJobTimeoutSelectionComboBox.text = [int]$NetworkEndpointPacketCaptureDurationComboBox + 60



# Sets the job timeout back to the orginal setting
#$script:OptionJobTimeoutSelectionComboBox.text = $JobTimeoutOriginalSetting




$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()






