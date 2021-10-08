
$Section1CollectionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Collections"
    UseVisualStyleBackColor = $True
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ImageIndex = 0
}
$MainLeftTabControl.Controls.Add($Section1CollectionsTab)

$MainLeftCollectionsTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
# Index 0 = Query
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png"))
# Index 1 = Accounts
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Accounts.png"))
# Index 2 = Event-Viewer
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Event-Viewer.png"))
# Index 3 = Registry 
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Registry.png"))
# Index 4 = File-Search
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\File-Search.png"))
# Index 5 = Network
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Network.png"))
# Index 6 = Packet Capture
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\pcap.png"))
# Index 7 = Processes
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Processes.png"))
# Index 8 = Event Logs / Chainsaw
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\ChainSaw.png"))


$MainLeftCollectionsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Collections TabControl"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * (557 + 5)}
    ShowToolTips  = $True
    SelectedIndex = 0
    ImageList     = $MainLeftCollectionsTabControlImageList
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Multiline = $true
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
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Event Logs CSV.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Event Logs CSV.ps1"

# This tab contains fields specific to pulling back event logs for viewing with Windows Event Viewer and/or processing with Chainsaw.exe
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Event Logs EVTX.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Event Logs EVTX.ps1"


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


# This tab contains fields specific to search for specific process related information
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Processes.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Processes.ps1"
