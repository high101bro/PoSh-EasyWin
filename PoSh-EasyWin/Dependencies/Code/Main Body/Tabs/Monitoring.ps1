
$Section1SMITHTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Monitoring"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftTabControl.Controls.Add($Section1SMITHTab)


$MainLeftSMITHTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Left   = $FormScale * $TabRightPosition
    Top    = $FormScale * $TabhDownPosition
    Width  = $FormScale * $TabAreaWidth
    Height = $FormScale * $TabAreaHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$Section1SMITHTab.Controls.Add($MainLeftSMITHTabControl)


# This tab contains fields specific to assist with querying account information such as
# account logon activeity, currently logged on users, and PowerShell logons
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitoring SMITH.ps1"
. "$Dependencies\Code\Main Body\Tabs\Monitoring SMITH.ps1"


# This tab contains fields specific to assist with querying event logs
# It also has the settings to specify and limit collections to narrow queries,  
# reduce unnecessary data returned, and lower collection time 
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitoring Accounts.ps1"
. "$Dependencies\Code\Main Body\Tabs\Monitoring Accounts.ps1"


# This tab contains fields specific to assist with querying event logs
# It also has the settings to specify and limit collections to narrow queries,  
# reduce unnecessary data returned, and lower collection time 
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitoring Event Logs.ps1"
. "$Dependencies\Code\Main Body\Tabs\Monitoring Event Logs.ps1"


# This tab contains fields specific to assist with querying the registry
# for names, keys, and values
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitoring Registry.ps1"
. "$Dependencies\Code\Main Body\Tabs\Monitoring Registry.ps1"


# This tab contains fields specific to assist with querying for file names and hashes
# Also supports searching for Alternate Data Streams (ADS) and their extraction/retrieval
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitoring File Search.ps1"
. "$Dependencies\Code\Main Body\Tabs\Monitoring File Search.ps1"


# This tab contains fields specific to assist with querying network status
# Such as local/remote IPs and ports, processes that start connnections, and dns cache
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitoring Network.ps1"
. "$Dependencies\Code\Main Body\Tabs\Monitoring Network.ps1"
