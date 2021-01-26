function Global:Conduct-PingSweep {
    <#
    .SYNOPSIS
        Sends ICMP echo request packets to a range of IPv4 addresses between two given addresses.

    .DESCRIPTION
        This function lets you sends ICMP echo request packets ("pings") to
        a range of IPv4 addresses using an asynchronous method.

        Therefore this technique is very fast but comes with a warning.
        Ping sweeping a large subnet or network with many swithes may result in
        a peak of broadcast traffic.
        Use the -Interval parameter to adjust the time between each ping request.
        For example, an interval of 60 milliseconds is suitable for wireless networks.
        The RawOutput parameter switches the output to an unformated
        [System.Net.NetworkInformation.PingReply[]].

    .INPUTS
        None
        You cannot pipe input to this funcion.

    .OUTPUTS
        The function only returns output from successful pings.

        Type: System.Net.NetworkInformation.PingReply

        The RawOutput parameter switches the output to an unformated
        [System.Net.NetworkInformation.PingReply[]].

    .NOTES
        Author  : G.A.F.F. Jakobs
        Created : August 30, 2014
        Version : 6

    .EXAMPLE
        Conduct-PingSweep -StartAddress 192.168.1.1 -EndAddress 192.168.1.254 -Interval 20

        IPAddress                                 Bytes                     Ttl           ResponseTime
        ---------                                 -----                     ---           ------------
        192.168.1.41                                 32                      64                    371
        192.168.1.57                                 32                     128                      0
        192.168.1.64                                 32                     128                      1
        192.168.1.63                                 32                      64                     88
        192.168.1.254                                32                      64                      0

        In this example all the ip addresses between 192.168.1.1 and 192.168.1.254 are pinged using
        a 20 millisecond interval between each request.
        All the addresses that reply the ping request are listed.

    .LINK
        http://gallery.technet.microsoft.com/Fast-asynchronous-ping-IP-d0a5cf0e

    #>
    [CmdletBinding(ConfirmImpact='Low')]
    Param(
        [parameter(Mandatory = $true, Position = 0)]
        [System.Net.IPAddress]$StartAddress,
        [parameter(Mandatory = $true, Position = 1)]
        [System.Net.IPAddress]$EndAddress,
        [int]$Interval = 30,
        [Switch]$RawOutput = $false
    )

    $timeout = 2000

    function New-Range ($start, $end) {

        [byte[]]$BySt = $start.GetAddressBytes()
        [Array]::Reverse($BySt)
        [byte[]]$ByEn = $end.GetAddressBytes()
        [Array]::Reverse($ByEn)
        $i1 = [System.BitConverter]::ToUInt32($BySt,0)
        $i2 = [System.BitConverter]::ToUInt32($ByEn,0)
        for($x = $i1;$x -le $i2;$x++){
            $ip = ([System.Net.IPAddress]$x).GetAddressBytes()
            [Array]::Reverse($ip)
            [System.Net.IPAddress]::Parse($($ip -join '.'))
        }
    }

    $IPrange = New-Range $StartAddress $EndAddress

    $IpTotal = $IPrange.Count

    Get-Event -SourceIdentifier "ID-Ping*" | Remove-Event
    Get-EventSubscriber -SourceIdentifier "ID-Ping*" | Unregister-Event

    $script:ProgressBarEndpointsProgressBar.Maximum = $IpTotal
    $script:ProgressBarEndpointsProgressBar.Value   = 0
    $script:ProgressBarQueriesProgressBar.Maximum = $IpTotal
    $script:ProgressBarQueriesProgressBar.Value   = 0

    $IPrange | foreach {

        [string]$VarName = "Ping_" + $_.Address
        New-Variable -Name $VarName -Value (New-Object System.Net.NetworkInformation.Ping)
        Register-ObjectEvent -InputObject (Get-Variable $VarName -ValueOnly) -EventName PingCompleted -SourceIdentifier "ID-$VarName"
        (Get-Variable $VarName -ValueOnly).SendAsync($_,$timeout,$VarName)
        Remove-Variable $VarName

        try {
            $pending = (Get-Event -SourceIdentifier "ID-Ping*").Count
        }
        catch [System.InvalidOperationException]{}

        $index = [array]::indexof($IPrange,$_)

        $script:ProgressBarEndpointsProgressBar.Value   = ($index / $IpTotal) * 100
        $script:ProgressBarQueriesProgressBar.Value   = (($index - $pending)/$IpTotal * 100)

        #Write-Progress -Activity "Sending ping to" -Id 1 -status $_.IPAddressToString -PercentComplete (($index / $IpTotal) * 100)
        #Write-Progress -Activity "ICMP requests pending" -Id 2 -ParentId 1 -Status ($index - $pending) -PercentComplete (($index - $pending)/$IpTotal * 100)

        Start-Sleep -Milliseconds $Interval
    }

    Write-Progress -Activity "Done sending ping requests" -Id 1 -Status 'Waiting' -PercentComplete 100

    While($pending -lt $IpTotal){
        Wait-Event -SourceIdentifier "ID-Ping*" | Out-Null
        Start-Sleep -Milliseconds 10
        $pending = (Get-Event -SourceIdentifier "ID-Ping*").Count
        #Write-Progress -Activity "ICMP requests pending" -Id 2 -ParentId 1 -Status ($IpTotal - $pending) -PercentComplete (($IpTotal - $pending)/$IpTotal * 100)
        $script:ProgressBarQueriesProgressBar.Value   = (($index - $pending)/$IpTotal * 100)
    }

    if ($RawOutput) {
        $Reply = Get-Event -SourceIdentifier "ID-Ping*" | ForEach {
            If($_.SourceEventArgs.Reply.Status -eq "Success"){
                $_.SourceEventArgs.Reply
            }
            Unregister-Event $_.SourceIdentifier
            Remove-Event $_.SourceIdentifier
        }
    }
    else {
        $Reply = Get-Event -SourceIdentifier "ID-Ping*" | ForEach {
            If($_.SourceEventArgs.Reply.Status -eq "Success"){
                $_.SourceEventArgs.Reply | select @{
                      Name="IPAddress"   ; Expression={$_.Address}},
                    @{Name="Bytes"       ; Expression={$_.Buffer.Length}},
                    @{Name="Ttl"         ; Expression={$_.Options.Ttl}},
                    @{Name="ResponseTime"; Expression={$_.RoundtripTime}}
            }
            Unregister-Event $_.SourceIdentifier
            Remove-Event $_.SourceIdentifier
        }
    }
    if($Reply -eq $Null){
        Write-Verbose "Conduct-PingSweep : No ip address responded" -Verbose
    }

    return $Reply
}

Conduct-PingSweep -StartAddress 10.10.10.0 -EndAddress 10.10.10.255 -Interval 5

