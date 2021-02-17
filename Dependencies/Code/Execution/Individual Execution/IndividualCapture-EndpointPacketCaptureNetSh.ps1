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



<#
Note:
        Multiple filters may be used together. However the same filter may not be repeated.
        e.g. 'netsh trace start capture=yes Ethernet.Type=IPv4 IPv4.Address=157.59.136.1'

        Filters need to be explicitly stated when required. If a filter is not specified, it is treated as "don't-care".
         e.g. 'netsh trace start capture=yes IPv4.SourceAddress=157.59.136.1'
              This will capture IPv4 packets only from 157.59.136.1, and it will also capture packets with non-IPv4 Ethernet Types, since the Ethernet.Type filter is not explicitly specified.
         e.g. 'netsh trace start capture=yes IPv4.SourceAddress=157.59.136.1 Ethernet.Type=IPv4'
              This will capture IPv4 packets only from 157.59.136.1. Packets with other Ethernet Types will be discarded since an explicit filter has been specified.

        Capture filters support ranges, lists and negation (unless stated otherwise).
         e.g. Range: 'netsh trace start capture=yes Ethernet.Type=IPv4 Protocol=(4-10)'
              This will capture IPv4 packets with protocols between 4 and 10 inclusive.
         e.g. List: 'netsh trace start capture=yes Ethernet.Type=(IPv4,IPv6)'
              This will capture only IPv4 and IPv6 packets.
         e.g. Negation: 'netsh trace start capture=yes Ethernet.Type=!IPv4'
              This will capture all non-IPv4 packets.

        Negation may be combined with lists in some cases.
         e.g. 'netsh trace start capture=yes Ethernet.Type=!(IPv4,IPv6)'
               This will capture all non-IPv4 and non-IPv6 packets.

        'NOT' can be used instead of '!' to indicate negation. This requires parentheses to be present around the values to be negated.
         e.g. 'netsh trace start capture=yes Ethernet.Type=NOT(IPv4)'
#>




<#
Protocol=<protocol>
         Matches the specified filter against the IP protocol.
        e.g. Protocol=6
        e.g. Protocol=!(TCP,UDP)
        e.g. Protocol=(4-10)

Assigned Internet Protocol Numbers
https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
In the Internet Protocol version 4 (IPv4) [RFC791] there is a field called "Protocol" to identify the next level protocol.  This is an 8 bit field.  In Internet Protocol version 6 (IPv6) [RFC8200], this field is called the "Next Header" field.
Values that are also IPv6 Extension Header Types should be listed in the IPv6 Extension Header Types registry at [IANA registry ipv6-parameters].
    
Decimal 	Keyword 	Protocol 	IPv6 Extension Header 	Reference 
0	HOPOPT	IPv6 Hop-by-Hop Option	Y	[RFC8200]
1	ICMP	Internet Control Message		[RFC792]
2	IGMP	Internet Group Management		[RFC1112]
3	GGP	Gateway-to-Gateway		[RFC823]
4	IPv4	IPv4 encapsulation		[RFC2003]
5	ST	Stream		[RFC1190][RFC1819]
6	TCP	Transmission Control		[RFC793]
7	CBT	CBT		[Tony_Ballardie]
8	EGP	Exterior Gateway Protocol		[RFC888][David_Mills]
9	IGP	any private interior gateway (used by Cisco for their IGRP)		[Internet_Assigned_Numbers_Authority]
10	BBN-RCC-MON	BBN RCC Monitoring		[Steve_Chipman]
11	NVP-II	Network Voice Protocol		[RFC741][Steve_Casner]
12	PUP	PUP		[Boggs, D., J. Shoch, E. Taft, and R. Metcalfe, "PUP: An Internetwork Architecture", XEROX Palo Alto Research Center, CSL-79-10, July 1979; also in IEEE Transactions on Communication, Volume COM-28, Number 4, April 1980.][[XEROX]]
13	ARGUS (deprecated)	ARGUS		[Robert_W_Scheifler]
14	EMCON	EMCON		[<mystery contact>]
15	XNET	Cross Net Debugger		[Haverty, J., "XNET Formats for Internet Protocol Version 4", IEN 158, October 1980.][Jack_Haverty]
16	CHAOS	Chaos		[J_Noel_Chiappa]
17	UDP	User Datagram		[RFC768][Jon_Postel]
18	MUX	Multiplexing		[Cohen, D. and J. Postel, "Multiplexing Protocol", IEN 90, USC/Information Sciences Institute, May 1979.][Jon_Postel]
19	DCN-MEAS	DCN Measurement Subsystems		[David_Mills]
20	HMP	Host Monitoring		[RFC869][Bob_Hinden]
21	PRM	Packet Radio Measurement		[Zaw_Sing_Su]
22	XNS-IDP	XEROX NS IDP		["The Ethernet, A Local Area Network: Data Link Layer and Physical Layer Specification", AA-K759B-TK, Digital Equipment Corporation, Maynard, MA. Also as: "The Ethernet - A Local Area Network", Version 1.0, Digital Equipment Corporation, Intel Corporation, Xerox Corporation, September 1980. And: "The Ethernet, A Local Area Network: Data Link Layer and Physical Layer Specifications", Digital, Intel and Xerox, November 1982. And: XEROX, "The Ethernet, A Local Area Network: Data Link Layer and Physical Layer Specification", X3T51/80-50, Xerox Corporation, Stamford, CT., October 1980.][[XEROX]]
23	TRUNK-1	Trunk-1		[Barry_Boehm]
24	TRUNK-2	Trunk-2		[Barry_Boehm]
25	LEAF-1	Leaf-1		[Barry_Boehm]
26	LEAF-2	Leaf-2		[Barry_Boehm]
27	RDP	Reliable Data Protocol		[RFC908][Bob_Hinden]
28	IRTP	Internet Reliable Transaction		[RFC938][Trudy_Miller]
29	ISO-TP4	ISO Transport Protocol Class 4		[RFC905][<mystery contact>]
30	NETBLT	Bulk Data Transfer Protocol		[RFC969][David_Clark]
31	MFE-NSP	MFE Network Services Protocol		[Shuttleworth, B., "A Documentary of MFENet, a National Computer Network", UCRL-52317, Lawrence Livermore Labs, Livermore, California, June 1977.][Barry_Howard]
32	MERIT-INP	MERIT Internodal Protocol		[Hans_Werner_Braun]
33	DCCP	Datagram Congestion Control Protocol		[RFC4340]
34	3PC	Third Party Connect Protocol		[Stuart_A_Friedberg]
35	IDPR	Inter-Domain Policy Routing Protocol		[Martha_Steenstrup]
36	XTP	XTP		[Greg_Chesson]
37	DDP	Datagram Delivery Protocol		[Wesley_Craig]
38	IDPR-CMTP	IDPR Control Message Transport Proto		[Martha_Steenstrup]
39	TP++	TP++ Transport Protocol		[Dirk_Fromhein]
40	IL	IL Transport Protocol		[Dave_Presotto]
41	IPv6	IPv6 encapsulation		[RFC2473]
42	SDRP	Source Demand Routing Protocol		[Deborah_Estrin]
43	IPv6-Route	Routing Header for IPv6	Y	[Steve_Deering]
44	IPv6-Frag	Fragment Header for IPv6	Y	[Steve_Deering]
45	IDRP	Inter-Domain Routing Protocol		[Sue_Hares]
46	RSVP	Reservation Protocol		[RFC2205][RFC3209][Bob_Braden]
47	GRE	Generic Routing Encapsulation		[RFC2784][Tony_Li]
48	DSR	Dynamic Source Routing Protocol		[RFC4728]
49	BNA	BNA		[Gary Salamon]
50	ESP	Encap Security Payload	Y	[RFC4303]
51	AH	Authentication Header	Y	[RFC4302]
52	I-NLSP	Integrated Net Layer Security TUBA		[K_Robert_Glenn]
53	SWIPE (deprecated)	IP with Encryption		[John_Ioannidis]
54	NARP	NBMA Address Resolution Protocol		[RFC1735]
55	MOBILE	IP Mobility		[Charlie_Perkins]
56	TLSP	Transport Layer Security Protocol using Kryptonet key management		[Christer_Oberg]
57	SKIP	SKIP		[Tom_Markson]
58	IPv6-ICMP	ICMP for IPv6		[RFC8200]
59	IPv6-NoNxt	No Next Header for IPv6		[RFC8200]
60	IPv6-Opts	Destination Options for IPv6	Y	[RFC8200]
61		any host internal protocol		[Internet_Assigned_Numbers_Authority]
62	CFTP	CFTP		[Forsdick, H., "CFTP", Network Message, Bolt Beranek and Newman, January 1982.][Harry_Forsdick]
63		any local network		[Internet_Assigned_Numbers_Authority]
64	SAT-EXPAK	SATNET and Backroom EXPAK		[Steven_Blumenthal]
65	KRYPTOLAN	Kryptolan		[Paul Liu]
66	RVD	MIT Remote Virtual Disk Protocol		[Michael_Greenwald]
67	IPPC	Internet Pluribus Packet Core		[Steven_Blumenthal]
68		any distributed file system		[Internet_Assigned_Numbers_Authority]
69	SAT-MON	SATNET Monitoring		[Steven_Blumenthal]
70	VISA	VISA Protocol		[Gene_Tsudik]
71	IPCV	Internet Packet Core Utility		[Steven_Blumenthal]
72	CPNX	Computer Protocol Network Executive		[David Mittnacht]
73	CPHB	Computer Protocol Heart Beat		[David Mittnacht]
74	WSN	Wang Span Network		[Victor Dafoulas]
75	PVP	Packet Video Protocol		[Steve_Casner]
76	BR-SAT-MON	Backroom SATNET Monitoring		[Steven_Blumenthal]
77	SUN-ND	SUN ND PROTOCOL-Temporary		[William_Melohn]
78	WB-MON	WIDEBAND Monitoring		[Steven_Blumenthal]
79	WB-EXPAK	WIDEBAND EXPAK		[Steven_Blumenthal]
80	ISO-IP	ISO Internet Protocol		[Marshall_T_Rose]
81	VMTP	VMTP		[Dave_Cheriton]
82	SECURE-VMTP	SECURE-VMTP		[Dave_Cheriton]
83	VINES	VINES		[Brian Horn]
84	TTP	Transaction Transport Protocol		[Jim_Stevens]
84	IPTM	Internet Protocol Traffic Manager		[Jim_Stevens]
85	NSFNET-IGP	NSFNET-IGP		[Hans_Werner_Braun]
86	DGP	Dissimilar Gateway Protocol		[M/A-COM Government Systems, "Dissimilar Gateway Protocol Specification, Draft Version", Contract no. CS901145, November 16, 1987.][Mike_Little]
87	TCF	TCF		[Guillermo_A_Loyola]
88	EIGRP	EIGRP		[RFC7868]
89	OSPFIGP	OSPFIGP		[RFC1583][RFC2328][RFC5340][John_Moy]
90	Sprite-RPC	Sprite RPC Protocol		[Welch, B., "The Sprite Remote Procedure Call System", Technical Report, UCB/Computer Science Dept., 86/302, University of California at Berkeley, June 1986.][Bruce Willins]
91	LARP	Locus Address Resolution Protocol		[Brian Horn]
92	MTP	Multicast Transport Protocol		[Susie_Armstrong]
93	AX.25	AX.25 Frames		[Brian_Kantor]
94	IPIP	IP-within-IP Encapsulation Protocol		[John_Ioannidis]
95	MICP (deprecated)	Mobile Internetworking Control Pro.		[John_Ioannidis]
96	SCC-SP	Semaphore Communications Sec. Pro.		[Howard_Hart]
97	ETHERIP	Ethernet-within-IP Encapsulation		[RFC3378]
98	ENCAP	Encapsulation Header		[RFC1241][Robert_Woodburn]
99		any private encryption scheme		[Internet_Assigned_Numbers_Authority]
100	GMTP	GMTP		[[RXB5]]
101	IFMP	Ipsilon Flow Management Protocol		[Bob_Hinden][November 1995, 1997.]
102	PNNI	PNNI over IP		[Ross_Callon]
103	PIM	Protocol Independent Multicast		[RFC7761][Dino_Farinacci]
104	ARIS	ARIS		[Nancy_Feldman]
105	SCPS	SCPS		[Robert_Durst]
106	QNX	QNX		[Michael_Hunter]
107	A/N	Active Networks		[Bob_Braden]
108	IPComp	IP Payload Compression Protocol		[RFC2393]
109	SNP	Sitara Networks Protocol		[Manickam_R_Sridhar]
110	Compaq-Peer	Compaq Peer Protocol		[Victor_Volpe]
111	IPX-in-IP	IPX in IP		[CJ_Lee]
112	VRRP	Virtual Router Redundancy Protocol		[RFC5798]
113	PGM	PGM Reliable Transport Protocol		[Tony_Speakman]
114		any 0-hop protocol		[Internet_Assigned_Numbers_Authority]
115	L2TP	Layer Two Tunneling Protocol		[RFC3931][Bernard_Aboba]
116	DDX	D-II Data Exchange (DDX)		[John_Worley]
117	IATP	Interactive Agent Transfer Protocol		[John_Murphy]
118	STP	Schedule Transfer Protocol		[Jean_Michel_Pittet]
119	SRP	SpectraLink Radio Protocol		[Mark_Hamilton]
120	UTI	UTI		[Peter_Lothberg]
121	SMP	Simple Message Protocol		[Leif_Ekblad]
122	SM (deprecated)	Simple Multicast Protocol		[Jon_Crowcroft][draft-perlman-simple-multicast]
123	PTP	Performance Transparency Protocol		[Michael_Welzl]
124	ISIS over IPv4			[Tony_Przygienda]
125	FIRE			[Criag_Partridge]
126	CRTP	Combat Radio Transport Protocol		[Robert_Sautter]
127	CRUDP	Combat Radio User Datagram		[Robert_Sautter]
128	SSCOPMCE			[Kurt_Waber]
129	IPLT			[[Hollbach]]
130	SPS	Secure Packet Shield		[Bill_McIntosh]
131	PIPE	Private IP Encapsulation within IP		[Bernhard_Petri]
132	SCTP	Stream Control Transmission Protocol		[Randall_R_Stewart]
133	FC	Fibre Channel		[Murali_Rajagopal][RFC6172]
134	RSVP-E2E-IGNORE			[RFC3175]
135	Mobility Header		Y	[RFC6275]
136	UDPLite			[RFC3828]
137	MPLS-in-IP			[RFC4023]
138	manet	MANET Protocols		[RFC5498]
139	HIP	Host Identity Protocol	Y	[RFC7401]
140	Shim6	Shim6 Protocol	Y	[RFC5533]
141	WESP	Wrapped Encapsulating Security Payload		[RFC5840]
142	ROHC	Robust Header Compression		[RFC5858]
143	Ethernet	Ethernet		[RFC-ietf-spring-srv6-network-programming-28]
144-252		Unassigned		[Internet_Assigned_Numbers_Authority]
253		Use for experimentation and testing	Y	[RFC3692]
254		Use for experimentation and testing	Y	[RFC3692]
255	Reserved			[Internet_Assigned_Numbers_Authority]





Ethernet.Address=<MAC address>
         Matches the specified filter against both source and destination
         MAC addresses.
        e.g. Ethernet.Address=00-0D-56-1F-73-64


Ethernet.SourceAddress=<MAC address>
         Matches the specified filter against source MAC addresses.
        e.g. Ethernet.SourceAddress=00-0D-56-1F-73-64


Ethernet.DestinationAddress=<MAC address>
         Matches the specified filter against destination MAC addresses.
        e.g. Ethernet.DestinationAddress=00-0D-56-1F-73-64


Ethernet.Type=<ethertype>
         Matches the specified filter against the MAC ethertype.
        e.g. Ethernet.Type=IPv4
        e.g. Ethernet.Type=NOT(0x86DD)
        e.g. Ethernet.Type=(IPv4,IPv6)


IPv4.Address=<IPv4 address>
         Matches the specified filter against both source and destination
         IPv4 addresses.
        e.g. IPv4.Address=157.59.136.1
        e.g. IPv4.Address=!(157.59.136.1)
        e.g. IPv4.Address=(157.59.136.1,157.59.136.11)


IPv4.SourceAddress=<IPv4 address>
         Matches the specified filter against source IPv4 addresses.
        e.g. IPv4.SourceAddress=157.59.136.1


IPv4.DestinationAddress=<IPv4 address>
         Matches the specified filter against destination IPv4 addresses.
        e.g. IPv4.DestinationAddress=157.59.136.1


IPv6.Address=<IPv6 address>
         Matches the specified filter against both source and destination
         IPv6 addresses.
        e.g. IPv6.Address=fe80::5038:3c4:35de:f4c3\%8
        e.g. IPv6.Address=!(fe80::5038:3c4:35de:f4c3\%8)


IPv6.SourceAddress=<IPv6 address>
         Matches the specified filter against source IPv6 addresses.
        e.g. IPv6.SourceAddress=fe80::5038:3c4:35de:f4c3\%8


IPv6.DestinationAddress=<IPv6 address>
         Matches the specified filter against destination IPv6 addresses.
        e.g. IPv6.DestinationAddress=fe80::5038:3c4:35de:f4c3\%8





netsh trace start InternetClient provider=Microsoft-Windows-TCPIP level=5 keywords=ut:ReceivePath,ut:SendPath.
Level	Setting	Description
1	Critical	Only critical events will be shown.
2	Errors	Critical events and errors will be shown.
3	Warnings	Critical events, errors, and warnings will be shown.
4	Informational	Critical events, errors, warnings, and informational events will be shown.
5	Verbose	All events will be shown.

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
Command:
===========================================================================
"netsh trace start capture=yes capturetype=$CaptureType report=$Report persistent=no maxsize=$MaxSize overwrite=yes correlation=yes perfMerge=yes traceFile=$EndpointEtlTraceFile"

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
#$script:OptionJobTimeoutSelectionComboBox.text = [int]$CaptureSeconds + 60



# Sets the job timeout back to the orginal setting
#$script:OptionJobTimeoutSelectionComboBox.text = $JobTimeoutOriginalSetting




$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()






