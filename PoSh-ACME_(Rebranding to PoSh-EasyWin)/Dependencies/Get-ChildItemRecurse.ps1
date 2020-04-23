$GetChildItemRecurse = @"
    Function Get-ChildItemRecurse {
        Param(
            [String]`$Path   = `$PWD,
            [String]`$Filter = "*",
            [Byte]`$Depth    = `$MaxDepth
        )
        `$CurrentDepth++
        `$RecursiveListing = New-Object PSObject
        Get-ChildItem `$Path -Filter `$Filter -Force | Foreach { 
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value `$TargetComputer -Force
            #`$RecursiveListing | Add-Member -MemberType NoteProperty -Name DirectoryName -Value `$_.DirectoryName -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Directory -Value `$_.Directory -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Name -Value `$_.Name -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name BaseName -Value `$_.BaseName -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Extension -Value `$_.Extension -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Attributes -Value `$_.Attributes -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name CreationTime -Value `$_.CreationTime -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value `$_.LastWriteTime -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name LastAccessTime -Value `$_.LastAccessTime -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value `$_.FullName -Force
            `$RecursiveListing | Add-Member -MemberType NoteProperty -Name PSIsContainer -Value `$_.PSIsContainer -Force
                                        
            If (`$_.PsIsContainer) {
                If (`$CurrentDepth -le `$Depth) {                
                    Get-ChildItemRecurse -Path `$_.FullName -Filter `$Filter -Depth `$MaxDepth -CurrentDepth `$CurrentDepth
                }
            }
            return `$RecursiveListing
        }
    }
"@