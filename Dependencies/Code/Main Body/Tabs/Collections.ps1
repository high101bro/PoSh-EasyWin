
$Section1CollectionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Collections"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainLeftTabControl.Controls.Add($Section1CollectionsTab)


$MainLeftCollectionsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Collections TabControl"
    Location = @{ X = $FormScale * $TabRightPosition
                  Y = $FormScale * $TabhDownPosition }
    Size     = @{ Width  = $FormScale * $TabAreaWidth
                  Height = $FormScale * $TabAreaHeight }
    ShowToolTips  = $True
    SelectedIndex = 0
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section1CollectionsTab.Controls.Add($MainLeftCollectionsTabControl)


# This tab contains all the individual commands within the command treeview, such as the
# PowerShell, WMI, and Native Commands using the WinRM, RPC/DCOM, and SMB protocols
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Queries.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Queries.ps1"


# This tab contains fields specific to assist with querying account information such as
# account logon activeity, currently logged on users, and PowerShell logons
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Accounts.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Accounts.ps1"


# This tab contains fields specific to assist with querying event logs
# It also has the settings to specify and limit collections to narrow queries,  
# reduce unnecessary data returned, and lower collection time 
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Event Logs.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Event Logs.ps1"


# This tab contains fields specific to assist with querying the registry
# for names, keys, and values
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Registry.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Registry.ps1"


# This tab contains fields specific to assist with querying for file names and hashes
# Also supports searching for Alternate Data Streams (ADS) and their extraction/retrieval
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections File Search.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections File Search.ps1"


# This tab contains fields specific to assist with querying network status
# Such as local/remote IPs and ports, processes that start connnections, and dns cache
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Network.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Network.ps1"


# This tab contains fields specific to packet capturing
# Feilds for the legacy netsh trace and the upcoming native Win10 Packet Capture
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Packet Capture.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Packet Capture.ps1"
