$ADGroupList  = @()
$ADGroupNames = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
foreach ($Group in $ADGroupNames) {
    $GroupMembers = Get-ADGroupMember $Group | Select -ExpandProperty Name
    foreach ($Member in $GroupMembers) {
        $AdGroupList += [PSCustomObject]@{Group=$Group;Member=$Member}
    }
}
return $ADGroupList

