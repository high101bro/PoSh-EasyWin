function AddTreeNodeTo-TreeViewData {
    param (
        [switch]$Accounts,
        [switch]$Endpoint,
        $RootNode,
        $Category,
        $Entry,
        [switch]$DoNotPopulateMetadata,
        $Metadata,
        $IPv4Address,
        $ToolTip,
        $ImageIndex
    )
    if (-not $ImageIndex){
        $ImageIndex = $Metadata.ImageIndex
    }
    # checks if data is in date/datetime format, if so, it trims off the time
    if ($Category -match ".{1,2}/.{1,2}/.{4}") {
        #$Category = ($Category.ToString() -split ' ')[0]
        $Category = ([datetime]$Category).ToString("yyyy-MM-dd")
    }

    if ($Accounts) {
        $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = "$Entry"
            Text = "$Entry"
            ImageIndex = $ImageIndex
        }
        
        if (-not $DoNotPopulateMetadata) {
            # TAG: sub nodes, sub-nodes, child nodes, dropdown nodes
            # $MetadataCreated = New-Object System.Windows.Forms.TreeNode -Property @{
            #     Name = "Created"
            #     Text = "Created: $($Metadata.Created)"
            # }
            # $newNode.Nodes.Add($MetadataCreated)
    
            # $MetadataModified = New-Object System.Windows.Forms.TreeNode -Property @{
            #     Name = "Modified"
            #     Text = "Modified: $($Metadata.Modified)"
            # }
            # $newNode.Nodes.Add($MetadataModified)

            # $MetadataLockedOut = New-Object System.Windows.Forms.TreeNode -Property @{
            #     Name = "Locked Out"
            #     Text = "Locked Out: $($Metadata.LockedOut)"
            # }
            # $newNode.Nodes.Add($MetadataLockedOut)

            # $MetadataGroups = New-Object System.Windows.Forms.TreeNode -Property @{
            #     Name = 'Group Membership'
            #     Text = 'Group Membership'
            # }
            # $newNode.Nodes.Add($MetadataGroups)
            
            # $AccountGroups = $Metadata.MemberOf.split("`n")
            # $MetadataGroups.Nodes.Add("[ Count: $(if ($AccountGroups -ne $null) {$AccountGroups.Count} else {0}) ]")
            # foreach ($Group in $AccountGroups) {
            #     if ($AccountGroups -ne $null) {
            #         $MetadataEachGroup = New-Object System.Windows.Forms.TreeNode -Property @{
            #             Name = $Group
            #             Text = $Group
            #         }
            #         $MetadataGroups.Nodes.Add($MetadataEachGroup)
            #     }
            # }
        }

        if ($ToolTip) {
            $newNode.ToolTipText  = "$ToolTip"
        }
        else {
            $newNode.ToolTipText  = "No Unique Data Available"
        }
    
        If ($RootNode.Nodes.Tag -contains $Category) {
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        Else {
            $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
                Name        = $Category
                Text        = $Category
                Tag         = $Category
                ToolTipText = "Checkbox this Category to query select all child nodes"
                NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            $RootNode.Nodes.Add($CategoryNode)
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        $EndpointNode.Nodes.Add($newNode)
    }


    if ($Endpoint) {
        $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = "$Entry"
            Text = "$Entry"
            ImageIndex = $ImageIndex
        }

        #batman #TODO work on this
        # $MetadataOperatingSystem = New-Object System.Windows.Forms.TreeNode -Property @{
        #     Name = "OperatingSystem"
        #     Text = $($Metadata.OperatingSystem)
        #     Tag  = $($Metadata.OperatingSystem)
        #     ToolTipText = ""
        #     NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        #     ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
        # }
        # $newNode.Nodes.Add($MetadataOperatingSystem)
    
        if (-not $DoNotPopulateMetadata) {
            # TAG: sub nodes, sub-nodes, child nodes, dropdown nodes
            # $MetadataIPv4Address = New-Object System.Windows.Forms.TreeNode -Property @{
            #     Name = "IPv4Address"
            #     Text = $Metadata.IPv4Address
            # }
            # $MetadataIPv4Address.Bounds.Height = 0
            # $MetadataIPv4Address.Bounds.Width = 0
            # $newNode.Nodes.Add($MetadataIPv4Address)
    
            # $MetadataIPv4Ports = New-Object System.Windows.Forms.TreeNode -Property @{
            #     Name = 'Port Scan'
            #     Text = 'Port Scan'
            # }
            # $newNode.Nodes.Add($MetadataIPv4Ports)
    
            # $MetadataIPv4Ports.Nodes.Add("[ Count: $(if ($Metadata.PortScan -ne $null) {$Metadata.PortScan.split(',').Count} else{0}) ]")
            # foreach ($PortScan in ($Metadata.PortScan.split(','))) {
            #     if ($Metadata.PortScan -ne $null){
            #         $MetadataIPv4EachPort = New-Object System.Windows.Forms.TreeNode -Property @{
            #             Name = $PortScan
            #             Text = $PortScan
            #         }
            #         $MetadataIPv4Ports.Nodes.Add($MetadataIPv4EachPort)
            #     }
            # }
        }
    
        if ($ToolTip) {
            $newNode.ToolTipText  = "$ToolTip"
        }
        else {
            $newNode.ToolTipText  = "No Unique Data Available"
        }
    
        If ($RootNode.Nodes.Tag -contains $Category) {
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        Else {
            $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
                Name        = $Category
                Text        = $Category
                Tag         = $Category
                ToolTipText = "Checkbox this Category to query all its hosts"
                NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            $RootNode.Nodes.Add($CategoryNode)
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        $EndpointNode.Nodes.Add($newNode)
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0fLmEnwjL9X+L4LVwcHhcIf6
# YeWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUjhf9R5HSx/Pd65wL21gBryTKD54wDQYJKoZI
# hvcNAQEBBQAEggEAoETtLpcNbXpBKe7/5kL+X8/dlxZMp5y9tgKJlobUtq6HdrCZ
# WMgiKAVDPZmfCk+HqTvAvdA293r3+qyVH5OeTQdYgP8xAqu0BXXtLg8N2hC0qQc4
# Rw/LcfOBDbmfWluhsCF/0IJUJ7EJW9Sqq9aDY+VeO6XexcYb1y6QMCJybS1FOB8v
# uQSDUwmx+powYVLTpLl2G/vT3nugcAnJFGHjfE7+pY+upuh/jBkz62e5+HJRQzck
# aYBImruR/nCbj+8Joj39zdox10TEtuVGE2lGqXadqRknB/cemnYl/OzFy8jsp47S
# 9UVAOxpRwBwGm4eynZdOUIaPVW/1s3ljeEKk9Q==
# SIG # End signature block
