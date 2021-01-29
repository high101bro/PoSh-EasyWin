$ADUserList = Get-ADUser -filter * | Select-Object -ExpandProperty SamAccountName
foreach ($SamAccountName in $ADUserList) {                        
    $GroupMemberships = Get-ADPrincipalGroupMembership -Identity $SamAccountName
    $GroupMemberships | Add-Member -MemberType NoteProperty -Name SamAccountName = $SamAccountName -Force
    $GroupMemberships | Select-Object -Property SamAccountName, @{Name="Group Name";Expression={$_.Name}}, SID, GroupCategory, GroupScope, DistinguishedName
} 