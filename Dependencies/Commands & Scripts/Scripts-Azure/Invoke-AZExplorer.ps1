﻿<#
.SYNOPSIS  
    Invoke-AZExplorer is a set of functions that retrieve vital data from an Azure and 0365 environment used for intrusion analysis.

.EXAMPLE
    .\Invoke-AZExplorer.ps1

.NOTES  
    File Name      : Invoke-AZExplorer.ps1
    Version        : v.0.1
    Author         : @WiredPulse
    Prerequisite   : PowerShell
    Created        : 22 Jan 21
#> 

 function Get-TenantConfigs{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Tenant Configurations..." -ForegroundColor Green
    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Organization Configurations..." -ForegroundColor Green
    Get-OrganizationConfig | export-csv $path\OrganizationConfig.csv
	
    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Remote Admin Configurations..." -ForegroundColor Green
    Get-RemoteDomain | export-csv $path\RemoteDomain.csv
	
    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Transport Rules..." -ForegroundColor Green
    Get-TransportRule | export-csv $path\TransportRule.csv
	
    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Transport Configurations..." -ForegroundColor Green 
    Get-TransportConfig | export-csv $path\TransportConfig.csv

}

function Get-Users{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving User List..." -ForegroundColor Green
     
    $azUsers = Get-AzureADuser -All:$true | Select-Object * -ExpandProperty extensionproperty 
    foreach($azuser in $azusers){
        $msolUser = Get-MsolUser -ObjectId $azuser.objectid
        $object = [PSCustomObject]@{
                Displayname = $azuser.DisplayName
                Mail = $azuser.Mail
                WhenCreated = $msolUser.WhenCreated
                CreatedDateTime = $azuser.extensionproperty.createdDateTime
                ObjectID = $azuser.ObjectID
                OnPremisesSecurityIdentifier = $azuser.OnPremisesSecurityIdentifier
                AccountEnabled = $azuser.AccountEnabled
                DirSyncEnabled = $azuser.DirSyncEnabled
                ProvisionedPlans = $azuser.ProvisionedPlans
                RefreshTokensValidFromDateTime = $azuser.RefreshTokensValidFromDateTime
                PasswordResetNotRequiredDuringActivate = $msolUser.PasswordResetNotRequiredDuringActivate
                PasswordNeverExpires = $msolUser.PasswordNeverExpires
                StrongPasswordRequired = $msolUser.StrongPasswordRequired
                LastPasswordChangeTimestamp = $msolUser.LastPasswordChangeTimestamp
                onPremisesDistinguishedName = $azuser.extensionproperty.onPremisesDistinguishedName
        }
            $object | export-csv $path\SPNCertsAndSecrets.csv -Append
    }

}

function Get-ADDirectoryAdmins{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Tenant Admins..." -ForegroundColor Green

    $object = foreach ($role in Get-AzureADDirectoryRole){
        $members = (Get-AzureADDirectoryRoleMember -ObjectId $role.objectid).userprincipalname
            if($members.length -eq 0){
                [pscustomobject]@{
                    GroupName = $role.displayname
                    Members = "None"
                    RoleDisabled = $role.RoleDisabled
                    IsSystem = $role.IsSystem
                    ObjectID = $role.ObjectId
                }
            }
        foreach($member in $members){
            [pscustomobject]@{
                GroupName = $role.DisplayName
                Members = $member
                RoleDisabled = $role.RoleDisabled
                IsSystem = $role.IsSystem
                ObjectID = $role.ObjectId
            }
        }
    }
    $object | export-csv $path\Admins.csv -Append

}

function Get-SPNandAppDetails{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Service Principals Information..." -ForegroundColor Green
    $servicePrincipals = get-azureadserviceprincipal -all $true | Sort-Object -Property displayname

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Registered Applications..." -ForegroundColor Green
    $applications = Get-AzureADApplication -all $true | Sort-Object -Property DisplayName

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Service Principal Certificate and Password Details..." -ForegroundColor Green
        foreach ($spn in $servicePrincipals) {
            $keys = $spn.keycredentials
            foreach ($key in $keys){
                $newapp = [PSCustomObject]@{
                    AppName = $spn.DisplayName
                    AppObjectID = $spn.ObjectID
                    KeyID = $key.KeyID
                    StartDate = $key.startdate
                    EndDate = $key.endDate
                    KeyType = $Key.Type
                    CredType = "X509Certificate"
                }
            $newapp | export-csv $path\SPNSecrets.csv -Append
            }
        }
    foreach ($spn in $servicePrincipals) {
        $passwords = $spn.PasswordCredentials
        foreach ($pass in $passwords){
            $newapp = [PSCustomObject]@{
                AppName = $spn.DisplayName
                AppObjectID = $spn.ObjectID
                KeyID = $pass.KeyID
                StartDate = $pass.startdate
                EndDate = $pass.endDate
                KeyType = $null
                CredType = "PasswordSecret"
            }
            $newapp | export-csv $path\SPNSecrets.csv -Append
        }
    }
    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Registered Applications Certificate and Password Details..." -ForegroundColor Green
        foreach ($app in $applications) {
            $keys = $app.keycredentials
            foreach ($key in $keys){
                $newapp = [PSCustomObject]@{
                    AppName = $app.DisplayName
                    AppObjectID = $app.ObjectID
                    KeyID = $key.KeyID
                    StartDate = $key.startdate
                    EndDate = $key.endDate
                    KeyType = $Key.Type
                    CredType = "X509Certificate"
                }
            $newapp | export-csv $path\AppSecrets.csv -Append
        }
    }
    foreach ($app in $applications) {
        $passwords = $app.PasswordCredentials
        foreach ($pass in $passwords){
            $newapp = [PSCustomObject]@{
                AppName = $app.DisplayName
                AppObjectID = $app.ObjectID
                KeyID = $pass.KeyID
                StartDate = $pass.startdate
                EndDate = $pass.endDate
                KeyType = $pass.Type
                CredType = "PasswordSecret"
            }
            $newapp | export-csv $path\AppSecrets.csv -Append
        }
    }

}

function Get-AppRolesAssignment{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Application Role Assignments..." -ForegroundColor Green
    Get-AzureADUser | Get-AzureADUserAppRoleAssignment | Select-Object PrincipalDisplayname, CreationTimestamp, ResourceDisplayName, ObjectID | Sort-Object principaldisplayname | export-csv $path\AppRoleAssignment.csv

}

function Get-CreatedObjects{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Created Objects..." -ForegroundColor Green
    $azUsers = Get-AzureADuser -All:$true 
    foreach($azuser in $azUsers){
        $createdObjects = Get-AzureADUserCreatedObject -ObjectId $azuser.ObjectId -All
        foreach($createdObject in $createdObjects){
            $object = [PSCustomObject]@{
                    Displayname = $azuser.DisplayName
                    UserObjectID = $azuser.ObjectId
                    ObjectDisplayname = $createdObject.Displayname
                    ObjectObjectID = $createdObject.ObjectID
                    ObjectDescription = $createdObject.description
                    WhenCreated = $msolUser.WhenCreated
            }
            $object | export-csv $path\CreatedObjects.csv -Append
        }
    }

}

function Get-Domain{
    
    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Domains..." -ForegroundColor Green
    Get-AzureADDomain | Select-Object Name, AuthenticationType, SupportedServices | export-csv $path\Domain.csv

}

function Get-Apps{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Applications..." -ForegroundColor Green
    Get-AzureADApplication| select-object DisplayName, ObjectID, AppID, ReplyUrls, AvailableToOtherTenants, AllowGuestSignIn, AllowPassthroughUser,IsDisabled | export-csv $path\Apps.csv
}

function Get-ADGroupMembers{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Group Members..." -ForegroundColor Green
    foreach($grp in Get-AzureADGroup){
        $grpMembers = Get-AzureADGroupMember -ObjectId $grp.objectid
        foreach($grpMember in $grpMembers){
            $object = [PSCustomObject]@{
                GroupName = $grp.DisplayName
                User = $grpMember.displayname
                UserPrincipalName = $grpMember.UserPrincipalName
                UserType = $grpMember.usertype
            }
            $object | export-csv $path\ADGroupMembers.csv -Append
        }
    }

}

function Get-AdGroup{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Groups..." -ForegroundColor Green
    Get-MsolGroup -All:$true | export-csv $path\ADGroups.csv

}

function Get-ServicePrincipalOwner{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Service Principals Owners..." -ForegroundColor Green
    foreach($servPrincipal in Get-AzureADServicePrincipal -All:$true){
        $owner = Get-AzureADServicePrincipalOwner -ObjectId $servPrincipal.objectid
            $object = [PSCustomObject]@{
                ServicePrincipal = $servPrincipal.displayname
                ServicePrincipalObjectID= $servPrincipal.objectid
                Owner = $owner.displayname
                UserPrincipalName = $owner.UserPrincipalName
            }
            $object | export-csv $path\ServicePrincipalOwner.csv -Append
        }
}

function Get-ServicePrincipal{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Service Principals..." -ForegroundColor Green
    Get-AzureADServicePrincipal -all:$true | export-csv $path\ServicePrincipal.csv

}

function Get-ServicePrincipalSSO{

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Service Principals Single Sign-On..." -ForegroundColor Green
    Get-AzureADServicePrincipal -All:$true |?{$_.Tags -eq "WindowsAzureActiveDirectoryCustomSingleSignOnApplication"} | export-csv $path\ServicePrincipalSSO.csv

}

function Get-AppPermissions{

# https://gist.github.com/psignoret/9d73b00b377002456b24fcb808265c23

[CmdletBinding(DefaultParameterSetName = 'ByObjectId')]
param(

    [Parameter(ParameterSetName = 'ByObjectId', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    $ObjectId,
    
    [Parameter(ParameterSetName = 'ByAppId', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    $AppId,

    [switch] $Preload
)

begin {

    Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Retrieving Application Permissions..." -ForegroundColor Green
    try {
        $tenant_details = Get-AzureADTenantDetail
    } catch {
        throw "You must call Connect-AzureAD before running this script."
    }
    Write-Verbose ("TenantId: {0}, InitialDomain: {1}" -f `
                    $tenant_details.ObjectId, `
                    ($tenant_details.VerifiedDomains | Where-Object { $_.Initial }).Name)

    $script:ObjectByObjectId = @{}
    $script:ObjectByObjectClassId = @{}

    function CacheObject($Object) {
        if ($Object) {
            if (-not $script:ObjectByObjectClassId.ContainsKey($Object.ObjectType)) {
                $script:ObjectByObjectClassId[$Object.ObjectType] = @{}
            }
            $script:ObjectByObjectClassId[$Object.ObjectType][$Object.ObjectId] = $Object
            $script:ObjectByObjectId[$Object.ObjectId] = $Object
        }
    }

    function GetObjectByObjectId($ObjectId) {
        Write-Debug ("GetObjectByObjectId: ObjectId: '{0}'" -f $ObjectId)
        if (-not $script:ObjectByObjectId.ContainsKey($ObjectId)) {
            Write-Verbose ("Querying Azure AD for object '{0}'" -f $ObjectId)
            $object = Get-AzureADObjectByObjectId -ObjectId $ObjectId
            if ($object) {
                CacheObject -Object $object
            } else {
                throw ("Object not found for ObjectId: '{0}'" -f $ObjectId)
            }
        }
        return $script:ObjectByObjectId[$ObjectId]
    }

    $cache_preloaded = $false
    $behavior = $null
}

process {
    if ($PSCmdlet.ParameterSetName -eq "ByObjectId") {
        try {
            $client = GetObjectByObjectId -ObjectId $ObjectId
        } catch {
            Write-Error ("Unable to retrieve client ServicePrincipal object by ObjectId: '{0}'" -f $ObjectId)
            throw $_
        }
    } elseif ($PSCmdlet.ParameterSetName -eq "ByAppId") {
        try {
            $client = Get-AzureADServicePrincipal -Filter ("appId eq '{0}'" -f $AppId)
            CacheObject -Object $client
        } catch {
            Write-Error ("Unable to retrieve client ServicePrincipal object by AppId: '{0}'" -f $AppId)
            throw $_
        }
    }

    Write-Verbose ("Client DisplayName: '{0}', ObjectId: '{1}, AppId: '{2}'" -f $client.DisplayName, $client.ObjectId, $client.AppId)

    Write-Verbose ("Retrieving a page of User objects and a page of ServicePrincipal objects...")
    if (($Preload) -and (-not $cache_preloaded)) {
        Get-AzureADServicePrincipal -Top 999 | ForEach-Object { CacheObject -Object $_ }
        Get-AzureADUser -Top 999 | ForEach-Object { CacheObject -Object $_ }
        $cache_preloaded = $true
    }

    Write-Verbose "Retrieving OAuth2PermissionGrants..."
    Get-AzureADServicePrincipalOAuth2PermissionGrant -ObjectId $client.ObjectId | ForEach-Object {
        $grant = $_
        if ($grant.Scope) {
            $grant.Scope.Split(" ") | Where-Object { $_ } | ForEach-Object {
                
                $scope = $_

                $resource = GetObjectByObjectId -ObjectId $grant.ResourceId
                $permission = $resource.OAuth2Permissions | Where-Object { $_.Value -eq $scope }

                $principalDisplayName = ""
                if ($grant.PrincipalId) {
                    $principal = GetObjectByObjectId -ObjectId $grant.PrincipalId
                    $principalDisplayName = $principal.DisplayName
                }

                New-Object PSObject -Property ([ordered]@{
                    "PermissionType" = "Delegated"          
                    "ClientObjectId" = $grant.ClientId
                    "ClientDisplayName" = $client.DisplayName
                    "ResourceObjectId" = $grant.ResourceId
                    "ResourceDisplayName" = $resource.DisplayName
                    "Permission" = $scope
                    "PermissionId" = $permission.Id
                    "PermissionDisplayName" = $permission.AdminConsentDisplayName
                    "PermissionDescription" = $permission.AdminConsentDescription
                    "ConsentType" = $grant.ConsentType
                    "PrincipalObjectId" = $grant.PrincipalId
                    "PrincipalDisplayName" = $principalDisplayName
                    "PermissionGrantId" = $grant.ObjectId
                }) | export-csv $path\AppPermissions.csv -Append
            }
        }
    }

    Write-Verbose "Retrieving App Role Assignments..."
    switch ($behavior) {
        "1P" {
            $assignments = @(Get-AzureADServiceAppRoleAssignedTo -ObjectId $client.ObjectId -All $true)
        }
        "3P" {
            $assignments = @(Get-AzureADServiceAppRoleAssignment -ObjectId $client.ObjectId -All $true)
        }
        default {
            $assignedTo = @(Get-AzureADServiceAppRoleAssignedTo -ObjectId $client.ObjectId -All $true)
            $assignments = @()
        
            if ($assignedTo.Count -gt 0 -and $assignedTo[0].PrincipalId -eq $client.ObjectId) {
                $assignments = $assignedTo
                $behavior = "1P"
            } else {
                $assignments = @(Get-AzureADServiceAppRoleAssignment -ObjectId $client.ObjectId -All $true)
                if (($assignedTo.Count -gt 0 -and $assignedTo[0].PrincipalId -ne $client.ObjectId) -or
                        ($assignments.Count -gt 0 -and $assignments[0].PrincipalId -eq $client.ObjectId)) {
                    $behavior = "3P" # $assignments is accurate
                } else {
                    if ($assignments.Count -gt 0 -and $assignments[0].PrincipalId -ne $client.ObjectId) {
                        $assignments = $assignedTo # ... which is actually @(), but doing this instead for clarity
                        $behavior = "3P"
                    } else {
                        # $assignments is accurate (empty)
                    }
                }
            }
        }
    } 

    $assignments | Where-Object { $_.PrincipalType -eq "ServicePrincipal" } | ForEach-Object {
        $assignment = $_

        $resource = GetObjectByObjectId -ObjectId $assignment.ResourceId
        $appRole = $resource.AppRoles | Where-Object { $_.Id -eq $assignment.Id }

        New-Object PSObject -Property ([ordered]@{
            "PermissionType" = "Application"
            "ClientObjectId" = $assignment.PrincipalId
            "ClientDisplayName" = $client.DisplayName
            "ResourceObjectId" = $assignment.ResourceId
            "ResourceDisplayName" = $resource.DisplayName
            "Permission" = $appRole.Value
            "PermissionId" = $assignment.Id
            "PermissionDisplayName" = $appRole.DisplayName
            "PermissionDescription" = $appRole.Description
            "ConsentType" = "N/A"
            "PrincipalObjectId" = "N/A"
            "PrincipalDisplayName" = "N/A"
            "PermissionGrantId" = $assignment.ObjectId
        }) | export-csv $path\AppPermissions.csv -Append
    }
}

}

write-host ("`#" * 90) -ForegroundColor yellow
write-host "  ____                _                _     __________            _                       " -ForegroundColor cyan
write-host " |_ _|_ ____   _____ | | _____        / \   |__  / ____|_  ___ __ | | ___  _ __ ___ _ __   " -ForegroundColor cyan
write-host "  | || '_ \ \ / / _ \| |/ / _ \_____ / _ \    / /|  _| \ \/ / '_ \| |/ _ \| '__/ _ \ '__|  " -ForegroundColor cyan
write-host "  | || | | \ V / (_) |   <  __/_____/ ___ \  / /_| |___ >  <| |_) | | (_) | | |  __/ |     " -ForegroundColor cyan
write-host " |___|_| |_|\_/ \___/|_|\_\___|    /_/   \_\/____|_____/_/\_\ .__/|_|\___/|_|  \___|_|     " -ForegroundColor cyan
write-host "                                                            |_|                            " -ForegroundColor cyan
write-host ("`#" * 90) -ForegroundColor yellow



$ModuleArray = @("AzureAD","MSOnline")
ForEach ($ReqModule in $ModuleArray){
    If ($null -eq (Get-Module $ReqModule -ListAvailable -ErrorAction SilentlyContinue)){
        Write-Verbose "Required module, $ReqModule, is not installed on the system."
        Write-Verbose "Installing $ReqModule from default repository"
        Install-Module -Name $ReqModule -Force
        Write-Verbose "Importing $ReqModule"
        Import-Module -Name $ReqModule
    } ElseIf ($null -eq (Get-Module $ReqModule -ErrorAction SilentlyContinue)){
        Write-Verbose "Importing $ReqModule"
        Import-Module -Name $ReqModule
    }
}

Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Connecting to AzureAD..." -ForegroundColor Green
Connect-AzureAD
Write-Host "[+] " -ForegroundColor Yellow -NoNewline; Write-Host "Connecting to MS Online..." -ForegroundColor Green
Connect-MsolService`n
$ErrorActionPreference = "silentlycontinue"
$date = Get-Date -UFormat %H-%M_%m-%d-%Y
$dev = New-Item -ItemType Directory "$Env:USERPROFILE\desktop\AzureExplorer_$date" | out-null
$path = "$Env:USERPROFILE\desktop\AzureExplorer_$date"

Get-TenantConfigs
Get-Users
Get-ADDirectoryAdmins
Get-SPNandAppDetails
Get-AppRolesAssignment
Get-CreatedObjects
Get-Domain
Get-Apps
Get-ADGroupMembers
Get-AdGroup
Get-ServicePrincipalOwner
Get-ServicePrincipalSSO
Get-ServicePrincipal
Get-AzureADServicePrincipal -All $true | Get-AppPermissions -Preload 

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMDnnBMupu0xV240foEEnQiJw
# S0egggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUU7r16HLoAnKe32pG2DDAwBsI4cQwDQYJKoZI
# hvcNAQEBBQAEggEAb2ZY5e1AAcRI061u1T3G4ipDiHnSBg5NItN/rZkXYgrQCUxY
# VvuMAeomgvPXQXcS5/XcpQrMf9M3NF9YBx+8F/LjlIoiknr+2dxtImScBEhDrpFT
# UdvkCiyBbtRdA27vG837mjPmc48ebjpvsB+IgY2qsUAmKI7lW18QN0KDLLO3nHqw
# twPo96nvQlfie9S7DBN5O5fsBnZldIdMIarVlvAzU/BQy/cVcUcqNtpYqi8Bm4Rb
# s6toOtj4wxpltnpSe00KeMuNu+TbDF62ztJyTDG7PeYlHvRbByIQSs69rQtBOj/r
# dokUZh0sklN7BcPlmwO67CFwoGke6tVgPC7FPA==
# SIG # End signature block
