<#
    .SYNOPSIS
    A security-enabled local group membership was enumerated

    .DESCRIPTION
    Subcategory:

        Audit Security Group Management

    Event Description:

        This event generates when a process enumerates the members of a security-enabled local group on the computer or device.

        This event doesn't generate when group members were enumerated using Active Directory Users and Computers snap-in.

    Recommendations:
    
        If you have a list of critical local security groups in the organization, and need to specifically monitor these groups for any access (in this case, enumeration of group membership), monitor events with the “Group\Group Name” values that correspond to the critical local security groups. Examples of critical local groups are built-in local administrators, built-in backup operators, and so on.

        If you need to monitor each time the membership is enumerated for a local or domain security group, to see who enumerated the membership and when, monitor this event. Typically, this event is used as an informational event, to be reviewed if needed.

    .EXAMPLE
    None
    .LINK
    https://github.com/high101bro/PoSh-EasyWin
    .NOTES
    None
#>

Get-WinEvent -FilterHashtable @{LogName='Security';Id=4799} `
| Where-Object {$_.Properties[8].Value -ne 'Registry'} `
| Select-Object @{n='GroupName';e={$_.Properties[0].value}},@{n='CreatorProcess';e={$_.Properties[8].Value}}  `
| Group-Object -Property GroupName, CreatorProcess `
| Select-Object -Property Count, Name

<# Deprecated
Get-WinEvent -FilterHashtable @{LogName='Security';Id=4799} `
| Where-Object {$_.Properties[8].Value -ne 'Registry'} `
| Select-Object @{n='CreatorProcess';e={$_.Properties[8].Value}} `
| Group-Object -Property CreatorProcess
#>