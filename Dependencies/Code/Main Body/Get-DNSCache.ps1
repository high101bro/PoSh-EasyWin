function Get-DNSCache {
    param(
        $NetworkConnectionSearchDNSCache,
        $Regex
    )
    $DNSQueryCache = Get-DnsClientCache
    $DNSQueryFoundList = @()
    foreach ($DNSQuery in $NetworkConnectionSearchDNSCache) {
        if ($Regex -eq $true){
            $DNSQueryFoundList += $DNSQueryCache | Where-Object {
                ($_.name -match $DNSQuery) -or ($_.entry -match $DNSQuery) -or ($_.data -match $DNSQuery)
            }
        }
        if ($Regex -eq $false){
            $DNSQueryFoundList += $DNSQueryCache | Where-Object {
                ($_.name -eq $DNSQuery) -or ($_.entry -eq $DNSQuery) -or ($_.data -eq $DNSQuery)
            }
        }
    }
    $DNSQueryFoundList | Select-Object -Property PSComputerName, Entry, Name, Data, Type, Status, Section, TTL, DataLength
}

