$ErrorActionPreference = 'SilentlyContinue'

#$env:computername
#$ErrorActionPreference = 'SilentlyContinue'

$SHA256  = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
$MD5     = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")
$regkeys = @(
'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices',
'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce',
'HCCU:\Software\Microsoft\Windows\Curre ntVersion\RunOnce\Setup',
'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon',
'HKLM:\Software\Microsoft\Active Setup\Installed Components',
'HKLM:\System\CurrentControlSet\Servic es\VxD',
'HKCU:\Control Panel\Desktop',
'HKLM:\System\CurrentControlSet\Control\Session Manager',
'HKLM:\System\CurrentControlSet\Services',
'HKLM:\System\CurrentControlSet\Services\Winsock2\Parameters\Protocol_Catalog\Catalog_Entries',
'HKLM:\System\Control\WOW\cmdline',
'HKLM:\System\Control\WOW\wowcmdline',
'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit',
'HKLM:\Software\Microsoft\Windows\Curr entVersion\ShellServiceObjectDelayLoad',
'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\run',
'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\load',
'HKCU:\Software\Microsoft\Windows\Curre ntVersion\Policies\Explorer\run',
'HLKM:\Software\Microsoft\Windows\Curr entVersion\Policies\Explorer\run'
)
$Startups = @()
foreach ($key in $regkeys) {
    $entry = Get-ItemProperty -Path $key
    $entry = $entry | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
    #$entry.psobject.Properties |ft
    foreach($item in $entry.PSObject.Properties) {
        $value = $item.value.replace('"', '')
        # The entry could be an actual path
        if(Test-Path $value) {

            $filebytes   = [system.io.file]::ReadAllBytes($value)
            $AuthenticodeSignature = Get-AuthenticodeSignature $value
            $HashObject  = New-Object PSObject -Property @{
                Name     = Split-Path $Value -Leaf
                Path     = $value
                SignatureStatus = $AuthenticodeSignature.Status
                SignatureCompany = ($AuthenticodeSignature.SignerCertificate.SubjectName.Name -split ',')[0].TrimStart('CN=')
                MD5      = [System.BitConverter]::ToString($md5.ComputeHash($filebytes)) -replace "-", "";
                SHA256   = [System.BitConverter]::ToString($sha256.ComputeHash($filebytes)) -replace "-","";
                PSComputerName = $env:COMPUTERNAME
            }
            $Startups += $HashObject
        }
    }
}
$Startups | Select-Object PSComputerName, Name, Path, MD5, SHA256, SignatureStatus, SignatureCompany

