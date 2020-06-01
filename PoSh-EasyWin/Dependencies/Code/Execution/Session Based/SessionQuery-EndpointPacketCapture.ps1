<#
https://isc.sans.edu/forums/diary/No+Wireshark+No+TCPDump+No+Problem/19409/

https://github.com/microsoft/etl2pcapng/

https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/converting-etl-files-to-pcap-files/ba-p/1133297

# Converts etl file to html
netsh trace convert input='C:\Users\admin\AppData\Local\Temp\NetTraces\NetTrace.etl' output='c:\trace.html'


Defaults:
	capture=no (specifies whether packet capture is enabled
		in addition to trace events)
	capturetype=physical (specifies whether packet capture needs to be
		enabled for physical network adapters only, virtual switch
		only, or both physical network adapters and virtual switch)
	report=no (specifies whether a complementing report will be generated
		along with the trace file)
	persistent=no (specifies whether the tracing session continues
		across reboots, and is on until netsh trace stop is issued)
	maxSize=250 MB (specifies the maximum trace file size, 0=no maximum)
	fileMode=circular
	overwrite=yes (specifies whether an existing trace output file will
		be overwritten)
	correlation=yes (specifies whether related events will be correlated
		and grouped together)
	perfMerge=yes (specifies whether performance metadata is merged
		into trace)
	traceFile=%LOCALAPPDATA%\Temp\NetTraces\NetTrace.etl
		(specifies location of the output file)
	providerFilter=no (specifies whether provider filter is enabled)
#>

$CollectionCommandStartTime = Get-Date
$CollectionName = "Endpoint Network Packet Capture"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

New-Item -Type Directory -Path "$script:CollectedDataTimeStampDirectory\$CollectionName\" -ErrorAction SilentlyContinue

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
$PacketCaptureName = "Endpoint Packet Capture - $DateTime.pcapng"
#$OutCsv     = = "$script:CollectedDataTimeStampDirectory\Endpoint Packet Capture-$DateTime.csv"


$ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          $CollectionName")
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

		$ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Copying data from $($Session.ComputerName)")
		Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $EndpointEtlTraceFile -Destination $LocalEtlFilePath -FromSession $Session -Force"
		$PoShEasyWin.Refresh()

		# Attempts to copy the files from the remote hosts
		Copy-Item -Path $EndpointEtlTraceFile -Destination $LocalEtlFilePath -FromSession $Session -Force
		Copy-Item -Path $EndpointCabTraceFile -Destination $LocalCabFilePath -FromSession $Session -Force
		
		$FileSize = [math]::round(((Get-Item $LocalEtlFilePath).Length/1mb),2)    
		$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Network Trace File is $FileSize MB")
		$PoShEasyWin.Refresh()

		# Uses etl2pcapng.exe to convert the network capture the file format from .etl to .pcapng
		$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Converting .etl to .pcap")
		$PoShEasyWin.Refresh()
		& $etl2pcapng $LocalEtlFilePath $OutPcapNG | Out-Null

		$FileSize = [math]::round(((Get-Item $OutPcapNG).Length/1mb),2)    
		$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Pcap File is $FileSize MB")
		$PoShEasyWin.Refresh()
	}
	catch {
		# If an error occurs, it will display it
		$ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy Error: $($_.Exception)") 
		Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
		$PoShEasyWin.Refresh()
		break
	}

	try {
		# Attempts to remove the etl and cab files
		$ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Cleaning up Endpoint Packet Capture files from $($Session.ComputerName)")
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
		$ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Remove Error: $($_.Exception)") 
		Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Remove Error: $($_.Exception)"
		$PoShEasyWin.Refresh()
		break
	}
}

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500
 




















































# Creates an html version... meh
####& netsh trace convert input='C:\Users\admin\AppData\Local\Temp\NetTraces\NetTrace.etl' output='c:\trace.html'

<# # Not sure if I want to pursue this as it can be quite resource intensive and timely... at least currently
# Uses netsh to convert network capture from .etl to .csv
& netsh trace convert input=$etlFile output=$OutCsv dump=csv
$PacketCsv = Import-csv $OutCsv -Delimiter "," -Header @('EventName','Trace','EventID','Version','Channel','Level','OpCode','Task','KeyWord','PID','TID','ProcessorNumber','InstanceID','ParentInstanceID','ActivityID','RelatedActivityID','Clock-Time','Kernel(ms)','User(ms)','UserData','u','v','HexData','x','y','z','ab','ac','ad','ae','af','ag','ah','ai','aj','ak','al','am','an','ao') | Select -Property HexData
#Remove-Item $OutCsv -Force

$Results = @()
foreach ($HexData in $PacketCsv){
    #'486f7374' = 'Host'
#    if ($HexData -match '0x' -and $HexData -match '486f7374'){
    if ($HexData -match '0x'){
        # Removes the 0x prefix at the beginning of the Hex String, ie 0xAABBCCDD to AABBCCDD
        $HexString = $HexData.HexData.TrimStart('0x')

        # Splits the hex stings into groups of two, ie AABBCCDD to AA BB CC DD
        $HexPairs = $HexString -replace '(..(?!$))','$1 '
        #$HexPairs = '74 68 69 73 20 69 73 20 6f 6e 6c 79 20 61 20 74 65 73 74' # = 'This is only a test'

        # Converts the hex pairs into an array/list
        $HexList = $HexPairs -split ' '

        # Converts the hex data into ascii
        $ASCII = ''
        $HexList | forEach { [char]([convert]::toint16($_,16)) } | forEach { $ASCII += $_ }
        $Results += $ASCII
            #Note   #[Char][Byte]97
                    #[Byte][Char]'a'
    }
}
#>


#$Logs = Get-WinEvent -path $etlFile -Oldest
#$logs[0]
#$logs[0].Message
#$logs.Message
#$logs.Where({$_.id -eq 1348}).count
#$logs.count
#$logs.Where({$_.Message}).TimeCreated
#$logs.Where({$_.Message}) | Select Message
#$Logs.where({$_.Message -match '1532'})[0] | select -ExpandProperty properties | select -expand value


