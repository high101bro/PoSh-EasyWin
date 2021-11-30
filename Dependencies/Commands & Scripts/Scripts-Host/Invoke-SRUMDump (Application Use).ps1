<#
    .SYNOPSIS
        Invoke-SRUMDump (Application Use) is a pure PowerShell / .Net capability that enables the dumping of the System Resource Utilization Management (SRUM) database for CSVs. The database generally 
        contains 30 days of information that is vital to incident response and forensics.

    .NOTES  
        Modified by    : @high101bro (for use within PoSh-EasyWin)
        
        Based on:      : Invoke-SRUMDump.ps1
        Version        : v.0.2
        Author         : @WiredPulse
        Created        : 20 May 21
#>

[CmdletBinding()]
param(
    $ExportDir = "C:\Windows\Temp\srum\application_use"
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if(-not($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
    throw "Error: This script needs to be ran as a user with Administrator rights"
}

[string]$date = Get-Date -UFormat %m-%d-%Y
$ExportDir = $ExportDir+'_'+$date

if(-not(test-path $ExportDir)){
    new-item $ExportDir -ItemType Directory | out-null
}

if(test-path C:\Windows\System32\sru\SRUDB.dat){
    copy-item C:\Windows\System32\sru\SRUDB.dat $ExportDir
    $path = "$exportdir\SRUDB.dat"
    if(-not(test-path $path)){
        throw "Error: SrumDB couldn't be copied"
    }
}
else{
    throw "ERROR: SrumDB doesn't exist in C:\windows\system32\sru"
}

$lookupLUID = @{
    1 = "IF_TYPE_OTHER"
    2 = "IF_TYPE_REGULAR_1822"
    3 = "IF_TYPE_HDH_1822"
    4 = "IF_TYPE_DDN_X25"
    5 = "IF_TYPE_RFC877_X25"
    6 = "IF_TYPE_ETHERNET_CSMACD"
    7 = "IF_TYPE_IS088023_CSMACD"
    8 = "IF_TYPE_ISO88024_TOKENBUS"
    9 = "IF_TYPE_ISO88025_TOKENRING"
    10 = "IF_TYPE_ISO88026_MAN"
    11 = "IF_TYPE_STARLAN"
    12 = "IF_TYPE_PROTEON_10MBIT"
    13 = "IF_TYPE_PROTEON_80MBIT"
    14 = "IF_TYPE_HYPERCHANNEL"
    15 = "IF_TYPE_FDDI"
    16 = "IF_TYPE_LAP_B"
    17 = "IF_TYPE_SDLC"
    18 = "IF_TYPE_DS1"
    19 = "IF_TYPE_E1"
    20 = "IF_TYPE_BASIC_ISDN"
    21 = "IF_TYPE_PRIMARY_ISDN"
    22 = "IF_TYPE_PROP_POINT2POINT_SERIAL"
    23 = "IF_TYPE_PPP"
    24 = "IF_TYPE_SOFTWARE_LOOPBACK"
    25 = "IF_TYPE_EON"
    26 = "IF_TYPE_ETHERNET_3MBIT"
    27 = "IF_TYPE_NSIP"
    28 = "IF_TYPE_SLIP"
    29 = "IF_TYPE_ULTRA"
    30 = "IF_TYPE_DS3"
    31 = "IF_TYPE_SIP"
    32 = "IF_TYPE_FRAMERELAY"
    33 = "IF_TYPE_RS232"
    34 = "IF_TYPE_PARA"
    35 = "IF_TYPE_ARCNET"
    36 = "IF_TYPE_ARCNET_PLUS"
    37 = "IF_TYPE_ATM"
    38 = "IF_TYPE_MIO_X25"
    39 = "IF_TYPE_SONET"
    40 = "IF_TYPE_X25_PLE"
    41 = "IF_TYPE_ISO88022_LLC"
    42 = "IF_TYPE_LOCALTALK"
    43 = "IF_TYPE_SMDS_DXI"
    44 = "IF_TYPE_FRAMERELAY_SERVICE"
    45 = "IF_TYPE_V35"
    46 = "IF_TYPE_HSSI"
    47 = "IF_TYPE_HIPPI"
    48 = "IF_TYPE_MODEM"
    49 = "IF_TYPE_AAL5"
    50 = "IF_TYPE_SONET_PATH"
    51 = "IF_TYPE_SONET_VT"
    52 = "IF_TYPE_SMDS_ICIP"
    53 = "IF_TYPE_PROP_VIRTUAL"
    54 = "IF_TYPE_PROP_MULTIPLEXOR"
    55 = "IF_TYPE_IEEE80212"
    56 = "IF_TYPE_FIBRECHANNEL"
    57 = "IF_TYPE_HIPPIINTERFACE"
    58 = "IF_TYPE_FRAMERELAY_INTERCONNECT"
    59 = "IF_TYPE_AFLANE_8023"
    60 = "IF_TYPE_AFLANE_8025"
    61 = "IF_TYPE_CCTEMUL"
    62 = "IF_TYPE_FASTETHER"
    63 = "IF_TYPE_ISDN"
    64 = "IF_TYPE_V11"
    65 = "IF_TYPE_V36"
    66 = "IF_TYPE_G703_64K"
    67 = "IF_TYPE_G703_2MB"
    68 = "IF_TYPE_QLLC"
    69 = "IF_TYPE_FASTETHER_FX"
    70 = "IF_TYPE_CHANNEL"
    71 = "IF_TYPE_IEEE80211"
    72 = "IF_TYPE_IBM370PARCHAN"
    73 = "IF_TYPE_ESCON"
    74 = "IF_TYPE_DLSW"
    75 = "IF_TYPE_ISDN_S"
    76 = "IF_TYPE_ISDN_U"
    77 = "IF_TYPE_LAP_D"
    78 = "IF_TYPE_IPSWITCH"
    79 = "IF_TYPE_RSRB"
    80 = "IF_TYPE_ATM_LOGICAL"
    81 = "IF_TYPE_DS0"
    82 = "IF_TYPE_DS0_BUNDLE"
    83 = "IF_TYPE_BSC"
    84 = "IF_TYPE_ASYNC"
    85 = "IF_TYPE_CNR"
    86 = "IF_TYPE_ISO88025R_DTR"
    87 = "IF_TYPE_EPLRS"
    88 = "IF_TYPE_ARAP"
    89 = "IF_TYPE_PROP_CNLS"
    90 = "IF_TYPE_HOSTPAD"
    91 = "IF_TYPE_TERMPAD"
    92 = "IF_TYPE_FRAMERELAY_MPI"
    93 = "IF_TYPE_X213"
    94 = "IF_TYPE_ADSL"
    95 = "IF_TYPE_RADSL"
    96 = "IF_TYPE_SDSL"
    97 = "IF_TYPE_VDSL"
    98 = "IF_TYPE_ISO88025_CRFPRINT"
    99 = "IF_TYPE_MYRINET"
    100 = "IF_TYPE_VOICE_EM"
    101 = "IF_TYPE_VOICE_FXO"
    102 = "IF_TYPE_VOICE_FXS"
    103 = "IF_TYPE_VOICE_ENCAP"
    104 = "IF_TYPE_VOICE_OVERIP"
    105 = "IF_TYPE_ATM_DXI"
    106 = "IF_TYPE_ATM_FUNI"
    107 = "IF_TYPE_ATM_IMA"
    108 = "IF_TYPE_PPPMULTILINKBUNDLE"
    109 = "IF_TYPE_IPOVER_CDLC"
    110 = "IF_TYPE_IPOVER_CLAW"
    111 = "IF_TYPE_STACKTOSTACK"
    112 = "IF_TYPE_VIRTUALIPADDRESS"
    113 = "IF_TYPE_MPC"
    114 = "IF_TYPE_IPOVER_ATM"
    115 = "IF_TYPE_ISO88025_FIBER"
    116 = "IF_TYPE_TDLC"
    117 = "IF_TYPE_GIGABITETHERNET"
    118 = "IF_TYPE_HDLC"
    119 = "IF_TYPE_LAP_F"
    120 = "IF_TYPE_V37"
    121 = "IF_TYPE_X25_MLP"
    122 = "IF_TYPE_X25_HUNTGROUP"
    123 = "IF_TYPE_TRANSPHDLC"
    124 = "IF_TYPE_INTERLEAVE"
    125 = "IF_TYPE_FAST"
    126 = "IF_TYPE_IP"
    127 = "IF_TYPE_DOCSCABLE_MACLAYER"
    128 = "IF_TYPE_DOCSCABLE_DOWNSTREAM"
    129 = "IF_TYPE_DOCSCABLE_UPSTREAM"
    130 = "IF_TYPE_A12MPPSWITCH"
    131 = "IF_TYPE_TUNNEL"
    132 = "IF_TYPE_COFFEE"
    133 = "IF_TYPE_CES"
    134 = "IF_TYPE_ATM_SUBINTERFACE"
    135 = "IF_TYPE_L2_VLAN"
    136 = "IF_TYPE_L3_IPVLAN"
    137 = "IF_TYPE_L3_IPXVLAN"
    138 = "IF_TYPE_DIGITALPOWERLINE"
    139 = "IF_TYPE_MEDIAMAILOVERIP"
    140 = "IF_TYPE_DTM"
    141 = "IF_TYPE_DCN"
    142 = "IF_TYPE_IPFORWARD"
    143 = "IF_TYPE_MSDSL"
    144 = "IF_TYPE_IEEE1394"
    145 = "IF_TYPE_RECEIVE_ONLY"
}

function profiles{
    $keys = (Get-ChildItem 'Srum_Reg_Parse:\srum\Microsoft\WlanSvc\Interfaces\*\profiles\' -Exclude metadata -Recurse).pspath
    $global:table = @{}
    foreach($key in $keys){
        $parsed = ''
        try{
            $temp = [System.Text.Encoding]::ascii.GetString(((Get-ItemProperty ($key + '\metadata')).'channel hints'))
            for($i = 0; $i -lt 100; $i++){
                $temp = ($Temp.Split('?'))[0]
                if($temp[$i] -match "[-a-zA-Z0-9]"){
                    $parsed += @($temp[$i])
               }
            }
            $table[((Get-ItemProperty $key).profileindex)] = $parsed
        }
        catch{}
    }
}

function sids-app{
    foreach($item in $out){
        $item.UserId = $hashSid.get_item([int]"$($item.UserId)")  

        $item.AppId = $hashApp.get_item([int]"$($item.appid)")  
    }
}

Function Get-SRUMTableDataRows{
  Param(
      $Session,
      $JetTable,
      $BlobStrType=[System.Text.Encoding]::UTF16,
      $FutureTimeLimit = [System.TimeSpan]::FromDays(36500)
  )


$DBRows = [System.Collections.ArrayList]@()
Try{
    [Microsoft.Isam.Esent.Interop.ColumnInfo[]]$Columns = [Microsoft.Isam.Esent.Interop.Api]::GetTableColumns($Session, $JetTable.JetTableid)
    if ([Microsoft.Isam.Esent.Interop.Api]::TryMoveFirst($Session, $JetTable.JetTableid)){
        do{
            $Row = New-Object PSObject 
            foreach ($Column in $Columns){
                switch ($Column.Coltyp){
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Bit) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsBoolean($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::DateTime) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsDateTime($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::IEEEDouble) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsDouble($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::IEEESingle) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsFloat($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Long) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt32($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Binary) {
                        if ( $BlobStrType -eq [System.Text.Encoding]::UTF16 ) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid)
                        } else {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, $BlobStrType)
                        }
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::LongBinary) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumn($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::LongText) {
                        if ( $BlobStrType -eq [System.Text.Encoding]::UTF16 ) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid)
                        } 
                        else {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, $BlobStrType)
                        }
                        if (![System.String]::IsNullOrEmpty($Buffer)) {
                            $Buffer = $Buffer.Replace("`0", "")
                        }
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Text) {
                        if ( $BlobStrType -eq [System.Text.Encoding]::UTF16 ) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid)
                        } else {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, $BlobStrType)
                        }
                        if (![System.String]::IsNullOrEmpty($Buffer)) {
                            $Buffer = $Buffer.Replace("`0", "")
                        }
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Currency) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, [System.Text.Encoding]::UTF8)
                        if (![System.String]::IsNullOrEmpty($Buffer)) {
                            $Buffer = $Buffer.Replace("`0", "")
                        }
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Short) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt16($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    ([Microsoft.Isam.Esent.Interop.JET_coltyp]::UnsignedByte) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsByte($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    (14) {
                        $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt32($Session, $JetTable.JetTableid, $Column.Columnid)
                        break
                    }
                    (15) {
                        try{
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt64($Session, $JetTable.JetTableid, $Column.Columnid)
                        } 
                        catch{ 
                            $Buffer = "Error"
                        }
                        if ($Buffer -Ne "Error" -and $column.name -eq "ConnectStartTime"){
                            try {
                                $DateTime = [System.DateTime]::FromBinary($Buffer)
                                $DateTime = $DateTime.AddYears(1600)
                                $buffer = $DateTime
                                if ($DateTime -gt (Get-Date -Year 1970 -Month 1 -Day 1) -and $DateTime -lt ([System.DateTime]::UtcNow.Add($FutureTimeLimit))){
                                    $Buffer = $DateTime
                                }
                            }
                            catch {}
                        }
                        break
                    }
                    default {
                        Write-Warning -Message "Did not match column type to $_"
                        $Buffer = [System.String]::Empty
                        break
                    }
                }       
                $Row | Add-Member -type NoteProperty -name $Column.Name -Value $Buffer 
            }
            [void]$DBRows.Add($row)
        } 
        while ([Microsoft.Isam.Esent.Interop.Api]::TryMoveNext($Session, $JetTable.JetTableid))      
    }
}
Catch{
    throw "Error: Could not read table"
    Break
}
return $DBRows
}


$EsentDllPath = "$env:SYSTEMROOT\Microsoft.NET\assembly\GAC_MSIL\microsoft.isam.esent.interop\v4.0_10.0.0.0__31bf3856ad364e35\Microsoft.Isam.Esent.Interop.dll"
Add-Type -Path $EsentDllPath

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Connecting to the Database..."
[System.Int32]$FileType = -1
[System.Int32]$PageSize = -1
[Microsoft.Isam.Esent.Interop.Api]::JetGetDatabaseFileInfo($Path, [ref]$PageSize, [Microsoft.Isam.Esent.Interop.JET_DbInfo]::PageSize)
[Microsoft.Isam.Esent.Interop.Api]::JetGetDatabaseFileInfo($Path, [ref]$FileType, [Microsoft.Isam.Esent.Interop.JET_DbInfo]::FileType)
[Microsoft.Isam.Esent.Interop.JET_filetype]$DBType = [Microsoft.Isam.Esent.Interop.JET_filetype]($FileType)

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Opening a JET Session..."
[Microsoft.Isam.Esent.Interop.JET_INSTANCE]$Instance = New-Object -TypeName Microsoft.Isam.Esent.Interop.JET_INSTANCE
[Microsoft.Isam.Esent.Interop.JET_SESID]$Session = New-Object -TypeName Microsoft.Isam.Esent.Interop.JET_SESID
$Temp = [Microsoft.Isam.Esent.Interop.Api]::JetSetSystemParameter($Instance, [Microsoft.Isam.Esent.Interop.JET_SESID]::Nil, [Microsoft.Isam.Esent.Interop.JET_param]::DatabasePageSize, $PageSize, $null)
$Temp = [Microsoft.Isam.Esent.Interop.Api]::JetSetSystemParameter($Instance, [Microsoft.Isam.Esent.Interop.JET_SESID]::Nil, [Microsoft.Isam.Esent.Interop.JET_param]::Recovery, [int]$Recovery, $null)
$Temp = [Microsoft.Isam.Esent.Interop.Api]::JetSetSystemParameter($Instance, [Microsoft.Isam.Esent.Interop.JET_SESID]::Nil, [Microsoft.Isam.Esent.Interop.JET_param]::CircularLog, [int]$CircularLogging, $null)
[Microsoft.Isam.Esent.Interop.Api]::JetCreateInstance2([ref]$Instance, "Instance", "Instance", [Microsoft.Isam.Esent.Interop.CreateInstanceGrbit]::None)
$Temp = [Microsoft.Isam.Esent.Interop.Api]::JetInit2([ref]$Instance, [Microsoft.Isam.Esent.Interop.InitGrbit]::None)
[Microsoft.Isam.Esent.Interop.Api]::JetBeginSession($Instance, [ref]$Session, $UserName, $Password)

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Opening the Database..."
[Microsoft.Isam.Esent.Interop.JET_DBID]$DatabaseId = New-Object -TypeName Microsoft.Isam.Esent.Interop.JET_DBID
$Temp = [Microsoft.Isam.Esent.Interop.Api]::JetAttachDatabase($Session, $Path, [Microsoft.Isam.Esent.Interop.AttachDatabaseGrbit]::ReadOnly)
$Temp = [Microsoft.Isam.Esent.Interop.Api]::JetOpenDatabase($Session, $Path, $Connect, [ref]$DatabaseId, [Microsoft.Isam.Esent.Interop.OpenDatabaseGrbit]::ReadOnly)


$TableNameDBID="SruDbIdMapTable"
[Microsoft.Isam.Esent.Interop.Table]$TableDBID = New-Object -TypeName Microsoft.Isam.Esent.Interop.Table($Session, $DatabaseId, $TableNameDBID, [Microsoft.Isam.Esent.Interop.OpenTableGrbit]::None)
try{
    $NewTable = @{Name=$TableDBID.Name;Id=$TableDBID.JetTableid;Rows=@()}
    $DBRows = @()
    [Microsoft.Isam.Esent.Interop.ColumnInfo[]]$Columns = [Microsoft.Isam.Esent.Interop.Api]::GetTableColumns($Session, $TableDBID.JetTableid)
    $jettable = $Tabledbid
}
catch{
    throw "ERROR: Cannot access file, the file is locked or in use"
}

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Retrieving SruIdDbMap Table..."
$map = Get-SRUMTableDataRows -Session $Session -JetTable $TableDBId 
write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Translating SIDs and Applications from SruIdDbMap... This Could take up to 15 Minutes..."
$global:hashSid = @{}
$global:hashApp = @{}
foreach($mData in $map){
    if($mData.idtype -eq 3){
        try{
            $hex = $mData | Select-Object -ExpandProperty idblob
            $hexString = ($hex|ForEach-Object ToString X2) -join ''   
            $Bytes = [byte[]]::new($HexString.Length / 2)

            For($i=0; $i -lt $HexString.Length; $i+=2){
                $Bytes[$i/2] =[convert]::ToByte($HexString.Substring($i, 2), 16)
            }
            $idblobSid = (New-Object System.Security.Principal.SecurityIdentifier($Bytes,0)).Value
            $hashSid.add($mData.idindex, $idblobSid)
        }
        catch{
            $idblobSid = "Unable to Retrieve"
            $hashSid.add($mData.idindex, $idblobSid)
        }
    }
    else{
        try{
            $bytes = $mData | Select-Object -ExpandProperty idblob
            $idblobApp = [System.Text.Encoding]::unicode.GetString($bytes)
            $hashApp.add($mData.idindex, $idblobApp)
            }
        catch{
            $idblobApp = "Unable to Retrieve"
            $hashApp.add($mData.idindex, $idblobApp)
        }
    }
}


$tab = "{D10CA2FE-6FCF-4F6D-848E-B2E99266FA89}"
[Microsoft.Isam.Esent.Interop.Table]$Tab4 = New-Object -TypeName Microsoft.Isam.Esent.Interop.Table($Session, $DatabaseId, $Tab, [Microsoft.Isam.Esent.Interop.OpenTableGrbit]::None)

$NewTable = @{Name=$TableDBID.Name;Id=$TableDBID.JetTableid;Rows=@()}
$DBRows = @()
[Microsoft.Isam.Esent.Interop.ColumnInfo[]]$Columns = [Microsoft.Isam.Esent.Interop.Api]::GetTableColumns($Session, $Tab4.JetTableid)
$jettable = $tab4

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Retrieving Application Usage Table..."
$global:out = Get-SRUMTableDataRows -Session $Session -JetTable $Tab4

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Application Usage: Normalizing User SIDs and Applications..."
sids-app

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Exporting Application Usage Table to$exportDir\ApplicationUsage.csv..."
$out | Select-Object @{Name='SRUM Entry ID'; Expression='AutoIncID'}, @{Name='SRUM Entry Creation'; Expression='Timestamp'}, @{Name='Application'; Expression='Appid'}, @{Name='User SID'; Expression='UserID'}, BackgroundBytesRead, BackgroundBytesWritten, BackgroundContextSwitches, BackgroundCycleTime, BackgroundNumberOfFlushes, BackgroundNumReadOperations, BackgroundNumWriteOperations, FaceTime, ForegroundBytesRead, ForegroundBytesWritten, ForegroundContextSwitches, ForegroundCycleTime, ForegroundNumberOfFlushes, ForegroundNumReadOperations, ForegroundNumWriteOperations


[gc]::collect()
if($offline){
    remove-psdrive -Name SRUM_Reg_Parse
    reg unload hku\srum | Out-Null
}

write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Gracefully shutting down the Connection to the Database..."
Write-Verbose -Message "Shutting down database $Path due to normal close operation."
[Microsoft.Isam.Esent.Interop.Api]::JetCloseDatabase($Session, $DatabaseId, [Microsoft.Isam.Esent.Interop.CloseDatabaseGrbit]::None)
[Microsoft.Isam.Esent.Interop.Api]::JetDetachDatabase($Session, $Path)
[Microsoft.Isam.Esent.Interop.Api]::JetEndSession($Session, [Microsoft.Isam.Esent.Interop.EndSessionGrbit]::None)
[Microsoft.Isam.Esent.Interop.Api]::JetTerm($Instance)
write-host -ForegroundColor Yellow "[+] " -NoNewline; Write-Host -ForegroundColor Green "Shutdown Completed Successfully"

Remove-Item -Path "$exportdir\SRUDB.dat"
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU43Zaty6PDgKtTD+EWh/mRaJO
# KTagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUPCK8+cf1LHPynZEqq+RE4OHPRC0wDQYJKoZI
# hvcNAQEBBQAEggEAFrxloNKoiwBNuFtQ8WJbgjzoKeYTQ5H96Ewr4DBsQAlZ8XKL
# LlxokblOO590RjAsnB5KVmgYRwe1sUuN381u/+EvLyqT+eyzDESuyF02f+NkqWcb
# iY1lwGXfQTYKGTZtt0qBmZzJ5zyh0Bs3gRCGM1pVuxF19RCcIeZKxRajgyfAPpUP
# UuMD+Q6WXP8OU3hcniYO7nzglNYDfu5T823KbzI6vClbSQmJF5amnsOmDawuoiM+
# 9idG2SNVe04U4BiCfOvOKfKhPvYzM0k/FTuUGD3UZZ/vFV7VxfvRyujNK3Kv/S0t
# kuCtZgeFQydUEqZ8iYGZaLuy5Xu3Mr/yTwaopg==
# SIG # End signature block
