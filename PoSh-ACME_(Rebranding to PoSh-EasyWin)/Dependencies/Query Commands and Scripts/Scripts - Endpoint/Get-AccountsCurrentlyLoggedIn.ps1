<#
Uses the registry to list all users currently on the system
#>
if(-not(Test-Path HKU:\)) {
    New-PSDrive HKU Registry HKEY_USERS
}

 
Get-ChildItem HKU:\ | Where-Object { 
    ($_.Name -match ‘S-1-5-[0-2][0-2]-‘) -and ($_.Name -notmatch ‘_Classes’) 
} | Select-Object -Property PSChildName | % {
    ([ADSI] (“LDAP://<SID=” + $_.PSChildName + “>”)) | Select-Object -Property `
        @{Name='Name';Expression={$_.Name}}, `
        @{Name='LogonCount';Expression={$_.LogonCount}}, `
        AuthenticationType, DistinguishedName
}
