function Get-DNSCache {
    param($NetworkConnectionSearchDNSCache)
    $DNSQueryCache = Get-DnsClientCache
    $DNSQueryFoundList = @()
    foreach ($DNSQuery in $NetworkConnectionSearchDNSCache) {
        $DNSQueryFoundList += $DNSQueryCache | Where-Object {($_.name -match $DNSQuery) -or ($_.entry -match $DNSQuery) -or ($_.data -match $DNSQuery) }
    }
    $DNSQueryFoundList | Select-Object -Property PSComputerName, Entry, Name, Data, Type, Status, Section, TTL, DataLength
}