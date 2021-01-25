Function Get-LoginEvents {
    Param (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Name')]
        [string]$ComputerName = $env:ComputerName
        ,
        [datetime]$StartTime
        ,
        [datetime]$EndTime
    )
    Begin {
        enum LogonTypes {
            LocalSystem       = 0
            Interactive       = 2
            Network           = 3
            Batch             = 4
            Service           = 5
            Unlock            = 7
            NetworkClearText  = 8
            NewCredentials    = 9
            RemoteInteractive = 10
            CachedInteractive = 11
        }
        enum LogonDescription {
            LocalSystem                    = 0
            LocalLogon                     = 2
            RemoteLogon                    = 3
            ScheduledTask                  = 4
            ServiceAccountLogon            = 5
            ScreenSaver                    = 7
            CLeartextNetworkLogon          = 8
            RusAsUsingAlternateCredentials = 9
            RDP_TS_RemoteAssistance        = 10
            LocalWithCachedCredentials     = 11
        }

        $FilterHashTable = @{
            LogName   = 'Security'
            ID        = 4624
        }
        if ($PSBoundParameters.ContainsKey('StartTime')){
            $FilterHashTable['StartTime'] = $StartTime
        }
        if ($PSBoundParameters.ContainsKey('EndTime')){
            $FilterHashTable['EndTime'] = $EndTime
        }
    }
    Process {
        Get-WinEvent -ComputerName $ComputerName -FilterHashtable $FilterHashTable | ForEach-Object {
            [pscustomobject]@{
                ComputerName         = $ComputerName
                UserAccount          = $_.Properties.Value[5]
                UserDomain           = $_.Properties.Value[6]
                LogonType            = [LogonTypes]$_.Properties.Value[8]
                LogonDescription     = [LogonDescription]$_.Properties.Value[8]
                WorkstationName      = $_.Properties.Value[11]
                SourceNetworkAddress = $_.Properties.Value[19]
                TimeStamp            = $_.TimeCreated
            }
        }
    }
    End{}
}
Get-LoginEvents -StartTime $([datetime]::Today.AddHours(-24)) -EndTime $([datetime]::Today)


