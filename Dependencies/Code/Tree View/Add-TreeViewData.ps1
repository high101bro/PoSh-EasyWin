function Add-TreeViewData {
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
# YeWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUjhf9R5HSx/Pd65wL21gBryTKD54wDQYJKoZI
# hvcNAQEBBQAEggEARDaHKfm7saukXQHQscQiQsg/2CWGjkULgcDRpl47gsYjQgJ/
# RBdNJcaHMQE98mao12RWe6BxECTkfS7xpLbnhLQPGGqhCtZqiyj9+nlMrTqXfBC8
# unsD6a8a9vu245c0WE+ZcEE/AXI4nCNM1lZwZrUdas8GnnV2ZYw9pIuBuHFXeWPf
# 7aTlxHQfw9im5sEFWOO5pvN/x736WHo0y0mZBdstStPE8C8jN9EnkKUiNVYRVI/g
# Nb+XmJJBCu1rBZ3K7c2IZU6MIipruueFTf1735QQa+6557X889inT9hzDty2She2
# JeeDloOnIN2LgUPv/zOju9xdUZtVlouqIu2dLg==
# SIG # End signature block
