function script:Invoke-PSWriteHTMLEndpointSnapshot {
    param(
        $InputData = $null,
        [switch]$MenuPrompt
    )
    if ($MenuPrompt) { script:Launch-NetworkConnectionGUI }

    script:Invoke-PSWriteHTMLProcess -InputData $InputData.GetProcessesEnriched

    script:Invoke-PSWriteHTMLNetworkConnections -InputData $InputData.GetNetworkConnectionsTCPEnriched
}