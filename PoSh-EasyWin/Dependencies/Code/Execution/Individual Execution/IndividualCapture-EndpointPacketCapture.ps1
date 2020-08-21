$CollectionName = "Endpoint Network Packet Capture"
$CollectionCommandStartTime = Get-Date 

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

New-Item -Type Directory -Path "$script:CollectedDataTimeStampDirectory\Individual Host Results\$CollectionName\" -ErrorAction SilentlyContinue

$script:ProgressBarEndpointsProgressBar.Value = 0

[int]$MaxSize        = $NetworkEndpointPacketCaptureMaxSizeTextBox.text
[int]$CaptureSeconds = $NetworkEndpointPacketCaptureDurationTextBox.text
$CaptureType = 'physical'
$Report = 'Yes'
$etl2pcapng = "$Dependencies\Network Packet Capture\etl2pcapng\x64\etl2pcapng.exe"
$DateTime   = (Get-Date).ToString('yyyyMMdd_HHmmss')
$TraceName  = 'NetTrace'

$EndpointEtlTraceFile = "C:\Windows\Temp\$TraceName.etl" # Remote Host
$EndpointCabTraceFile = "C:\Windows\Temp\$TraceName.cab"
$PacketCaptureName    = "Endpoint Packet Capture - $DateTime.pcapng"
#$OutCsv     = = "$script:CollectedDataTimeStampDirectory\Endpoint Packet Capture-$DateTime.csv"

$AdminShare                     = 'C$'
$TargetFolder                   = "Windows\Temp"
$LocalPath                      = "$script:CollectedDataTimeStampDirectory\Individual Host Results\$CollectionName\"

$ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          $CollectionName")
Create-LogEntry -LogFile $LogFile -TargetComputer "    $TargetComputer" -Message "netsh trace start capture=yes capturetype=$CaptureType report=$Report persistent=no maxsize=$MaxSize overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"
Create-LogEntry -LogFile $LogFile -TargetComputer "    $TargetComputer" -Message "netsh trace stop"
$PoShEasyWin.Refresh()


foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { $script:Credential = Get-Credential }
        $QueryCredentialParam = ", $script:Credential"
        $QueryCredential      = "-Credential $script:Credential"
    }
    else {
        $QueryCredentialParam = $null
        $QueryCredential      = $null        
    }

    Invoke-Command -ScriptBlock {
        param(
            $CaptureType,
            $Report,
            $MaxSize,
            $EndpointEtlTraceFile,
            $CaptureSeconds,
            $TargetComputer,
            $AdminShare,
            $TargetFolder,
            $TraceName,
            $LocalPath,
            $PacketCaptureName,
            $etl2pcapng
        )
        Invoke-Expression "netsh trace start capture=yes capturetype=$CaptureType report=$Report persistent=no maxsize=$MaxSize overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"
        Start-Sleep -Seconds $CaptureSeconds
        Invoke-Expression 'netsh trace stop' | Out-Null
        Start-Sleep -Seconds 5
        
        # Attempts to copy the files from the remote hosts
        Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$TraceName.etl" "$LocalPath" -Force
        Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$TraceName.cab" "$LocalPath" -Force
        Start-Sleep -Seconds 1

        $LocalEtlFilePath = "$LocalPath\$TraceName.etl"
        $OutPcapNG        = "$LocalPath\$TargetComputer - $PacketCaptureName"

        # Converts the .etl file to .pcapng
        & $etl2pcapng $LocalEtlFilePath $OutPcapNG | Out-Null        

        # Removes remote files
        Remove-Item -Path "\\$TargetComputer\$AdminShare\$TargetFolder\$TraceName.etl" -Force
        Remove-Item -Path "\\$TargetComputer\$AdminShare\$TargetFolder\$TraceName.cab" -Force
    } -ArgumentList @($CaptureType,$Report,$MaxSize,$EndpointEtlTraceFile,$CaptureSeconds,$TargetComputer,$AdminShare,$TargetFolder,$TraceName,$LocalPath,$PacketCaptureName,$etl2pcapng) -ComputerName $TargetComputer -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
}
#        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Copying data from $TargetComputer")
#        Create-LogEntry -LogFile $LogFile -TargetComputer "    $TargetComputer" -Message "Copy-Item -Path $EndpointEtlTraceFile -Destination $LocalEtlFilePath -FromSession $Session -Force"
#        $PoShEasyWin.Refresh()
#        $FileSize = [math]::round(((Get-Item $LocalEtlFilePath).Length/1mb),2)    
#        $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Network Trace File is $FileSize MB")
#        $PoShEasyWin.Refresh()
#        # Uses etl2pcapng.exe to convert the network capture the file format from .etl to .pcapng
#        $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Converting .etl to .pcap")
#        $PoShEasyWin.Refresh()
#        $FileSize = [math]::round(((Get-Item $OutPcapNG).Length/1mb),2)    
#        $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Pcap File is $FileSize MB")
#        $PoShEasyWin.Refresh()

Monitor-Jobs -CollectionName $CollectionName -NotExportFiles

$CollectionCommandEndTime  = Get-Date                    
$CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

