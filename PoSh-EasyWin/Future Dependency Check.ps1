function Launch-InputForm {
    param(
        $Title = 'PoSh-EasyWin',
        $Message = 'Please input the necessary data:'
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $TestWSManForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = $Title
        Height = 150
        Width  = 300
        StartPosition = 'CenterScreen'
    }

    $TestWSManOkButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'OK'
        Left   = 115
        Top    = 75
        Height = 23
        Width  = 75
        DialogResult = [System.Windows.Forms.DialogResult]::OK
    }
    $TestWSManForm.AcceptButton = $TestWSManOkButton
    $TestWSManForm.Controls.Add($TestWSManOkButton)

    $TestWSManCancelButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Cancel'
        Left   = 195
        Top    = 75
        Height = 23
        Width  = 75
        DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    }
    $TestWSManForm.CancelButton = $TestWSManCancelButton
    $TestWSManForm.Controls.Add($TestWSManCancelButton)

    $TestWSManLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = $Message
        Left   = 10
        Top    = 20
        Height = 20
        Width  = 280
    }
    $TestWSManForm.Controls.Add($TestWSManLabel)

    $TestWSManTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Left   = 10
        Top    = 40
        Height = 20
        Width  = 260
    }
    $TestWSManForm.Controls.Add($TestWSManTextBox)

    $TestWSManForm.Topmost = $true

    $TestWSManForm.Add_Shown({$TestWSManTextBox.Select()})
    $TestWSManResult = $TestWSManForm.ShowDialog()

    if ($TestWSManResult -eq [System.Windows.Forms.DialogResult]::OK) {
        return $TestWSManTextBox.text
    }
}

$TestWsManRemoteEndpoint = Launch-InputForm -Title 'PoSh-EasyWin' -Message 'Enter a remote computer name to test WinRM with:'









clear
sleep 1


<#
Write-Output ".NET Versions Installed:"
if ((Test-Path        "HKLM:Software\Microsoft\.NETFramework\Policy\v1.0\3705")) {
    Write-Output "   $((Get-ItemProperty "HKLM:Software\Microsoft\.NETFramework\Policy\v1.0\3705").version)"     #1.0
}
if ((Test-Path        "HKLM:Software\Microsoft\NET Framework Setup\NDP\v1.1.4322")) {
    Write-Output "   $((Get-ItemProperty "HKLM:Software\Microsoft\NET Framework Setup\NDP\v1.1.4322").version)"  #1.1
}
if ((Test-Path        "HKLM:Software\Microsoft\NET Framework Setup\NDP\v2.0.50727")) {
    Write-Output "   $((Get-ItemProperty "HKLM:Software\Microsoft\NET Framework Setup\NDP\v2.0.50727").version)" #2.0
}
if ((Test-Path        "HKLM:Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup")) {
    Write-Output "   $((Get-ItemProperty "HKLM:Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup").version)" #3.0
}
if ((Test-Path        "HKLM:Software\Microsoft\NET Framework Setup\NDP\v3.5")) {
    Write-Output "   $((Get-ItemProperty "HKLM:Software\Microsoft\NET Framework Setup\NDP\v3.5").version)"       #3.5
}
if ((Test-Path        "HKLM:Software\Microsoft\NET Framework Setup\NDP\v4\Client")) {
    Write-Output "   $((Get-ItemProperty "HKLM:Software\Microsoft\NET Framework Setup\NDP\v4\Client").version) Client"  #4.0 Client Profile
}
if ((Test-Path        "HKLM:Software\Microsoft\NET Framework Setup\NDP\v4\Full")) {
    Write-Output "   $((Get-ItemProperty "HKLM:Software\Microsoft\NET Framework Setup\NDP\v4\Full").version) Full"    #4.0 Full Profile
}
#>

<#
Write-Output ".NET Versions Installed:"
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
    Get-ItemProperty -name Version,Release -EA 0 |
    Where { $_.PSChildName -match '^(?!S)\p{L}'} |
    Select PSChildName, Version, Release
#>


''

$PSWriteHTMLPath = "C:\Windows\System32\cmd.exe"

if ($PSversionTable.PSVersion.Major -eq 2){
    Write-Output "PowerShell v$($PSversionTable.PSVersion.Major).$($PSversionTable.PSVersion.Minor) Detected"
    if (Test-Path $PSWriteHTMLPath){
        Write-Output "   PSWriteHTML Module Found"
        Write-Output "      Unsupported (Requires v5.1+)"
    }
    else {
        Write-Output "   PSWriteHTML Module Not Found"
        Write-Output "      Unsupported (Requires v5.1+)"
    }
    Write-Output "   PowerShell Charts"
    Write-Output "      Supported (Requires v3.0+)"
    Write-Output "   Copy-Item over PSSession"
    Write-Output "      Unsupported (Requires v5.0+)"
}
elseif ($PSversionTable.PSVersion.Major -eq 3){
    Write-Output "PowerShell v$($PSversionTable.PSVersion.Major).$($PSversionTable.PSVersion.Minor) Detected"
    if (Test-Path $PSWriteHTMLPath){
        Write-Output "   PSWriteHTML Module Found"
        Write-Output "      Unsupported (Requires v5.1+)"
    }
    else {
        Write-Output "   PSWriteHTML Module Not Found"
        Write-Output "      Unsupported (Requires v5.1+)"
    }
    Write-Output "   PowerShell Charts"
    Write-Output "      Supported (v3.0+)"
    Write-Output "   Copy-Item over PSSession"
    Write-Output "      Unsupported (Requires v5.0+)"
}
elseif ($PSversionTable.PSVersion.Major -eq 4){
    Write-Output "PowerShell v$($PSversionTable.PSVersion.Major).$($PSversionTable.PSVersion.Minor) Detected"
    if (Test-Path $PSWriteHTMLPath){
        Write-Output "   PSWriteHTML Module Found"
        Write-Output "     Unsupported (Requires v5.1+)"
    }
    else {
        Write-Output "   PSWriteHTML Module Not Found"
        Write-Output "      Unsupported (Requires v5.1+)"
    }
    Write-Output "   PowerShell Charts"
    Write-Output "      Supported (v3.0+)"
    Write-Output "   Copy-Item over PSSession"
    Write-Output "      Unsupported (Requires v5.0+)"
}
elseif ($PSversionTable.PSVersion.Major -eq 5 -and $PSversionTable.PSVersion.Minor -lt 1){
    Write-Output "PowerShell v$($PSversionTable.PSVersion.Major).$($PSversionTable.PSVersion.Minor) Detected"
    if (Test-Path $PSWriteHTMLPath){
        Write-Output "   PSWriteHTML Module Found"
        Write-Output "      Unsupported (Requires v5.1+)"
    }
    else {
        Write-Output "   PSWriteHTML Module Not Found"
        Write-Output "      Unsupported (Requires v5.1+)"
    }
    Write-Output "   PowerShell Charts"
    Write-Output "      Supported (v3.0+)"
    Write-Output "   Copy-Item over PSSession"
    Write-Output "      Supported (v5.0+)"
}
elseif ($PSversionTable.PSVersion.Major -ge 5 -and $PSversionTable.PSVersion.Minor -ge 1){
<#
    $PSVersionResults = @()
    $PSVersionResults += @{
        'PowerShell Version'       = "v$($PSversionTable.PSVersion.Major).$($PSversionTable.PSVersion.Minor)"
    }
    $PSVersionResults += @{
        'PSWriteHTML Module'       = if (Test-Path $PSWriteHTMLPath){"Supported (v5.1)"}else{"Supported (v5.1) - MODULE NOT FOUND!"}
    }
    $PSVersionResults += @{
        'PowerShell Charts'        = "Supported (v3.0+)"
    }
    $PSVersionResults += @{
        'Copy-Item over PSSession' = "Supported (v5.0+)"

    }
$PSVersionResults
#>
    Write-Output "PowerShell v$($PSversionTable.PSVersion.Major).$($PSversionTable.PSVersion.Minor) Detected"
    if (Test-Path $PSWriteHTMLPath){
        Write-Output "   PSWriteHTML Module Found"
        Write-Output "      Supported (v5.1)"
    }
    else {
        Write-Output "   PSWriteHTML Module Not Found"
        Write-Output "      Supported (v5.1+)"
    }
    Write-Output "   PowerShell Charts"
    Write-Output "      Supported (v3.0+)"
    Write-Output "   Copy-Item over PSSession"
    Write-Output "      Supported (v5.0+)"
}

""


Write-Output "Checking local WinRM Service (Windows Remote Management)"
if ((Get-Service -Name WinRM).status -eq 'Running'){
    Write-Output "   Service Running"
}
else {
    Write-Output "   Service Not Running"
}


Write-Output "Testing Remote WinRM Service"
if ((Get-Service -Name WinRM).status -eq 'Running'){
    Write-Output "   Service Running"
}
else {
    Write-Output "   Service Not Running"
}

Write-Output "Testing WSMan with endpoint: $TestWsManRemoteEndpoint"
if (Test-WSMan -ComputerName $TestWsManRemoteEndpoint -ea 0){
    Write-Output "   Success"
}
else {
    Write-Output "   Failed"
    Write-Output "   $($Error[0].Exception.Message)"
}



""
$ExecutablePath = "C:\Windows\System32\cmd.exe"
if (Test-Path $ExecutablePath){
    Write-Output "PSExec.exe"
    Write-Output "   File Located:  '$ExecutablePath'"
    Write-Output "   MD5 FileHash:  $((Get-FileHash -Path $ExecutablePath -Algorithm MD5).Hash)"
}
$ExecutablePath = "C:\Windows\System32\cmd.exe"
if (Test-Path $ExecutablePath){
    Write-Output "Sysmon.exe"
    Write-Output "   File Located:  '$ExecutablePath'"
    Write-Output "   MD5 FileHash:  $((Get-FileHash -Path $ExecutablePath -Algorithm MD5).Hash)"
}
$ExecutablePath = "C:\Windows\System32\cmd.exe"
if (Test-Path $ExecutablePath){
    Write-Output "Procmon.exe"
    Write-Output "   File Located:  '$ExecutablePath'"
    Write-Output "   MD5 FileHash:  $((Get-FileHash -Path $ExecutablePath -Algorithm MD5).Hash)"
}
$ExecutablePath = "C:\Windows\System32\cmd.exe"
if (Test-Path $ExecutablePath){
    Write-Output "Autoruns.exe"
    Write-Output "   File Located:  '$ExecutablePath'"
    Write-Output "   MD5 FileHash:  $((Get-FileHash -Path $ExecutablePath -Algorithm MD5).Hash)"
}
$ExecutablePath = "C:\Windows\System32\cmd.exe"
if (Test-Path $ExecutablePath){
    Write-Output "etl2pcap.exe"
    Write-Output "   File Located:  '$ExecutablePath'"
    Write-Output "   MD5 FileHash:  $((Get-FileHash -Path $ExecutablePath -Algorithm MD5).Hash)"
}
$ExecutablePath = "C:\Windows\System32\cmd.exe"
if (Test-Path $ExecutablePath){
    Write-Output "WinPmem.exe"
    Write-Output "   File Located:  '$ExecutablePath'"
    Write-Output "   MD5 FileHash:  $((Get-FileHash -Path $ExecutablePath -Algorithm MD5).Hash)"
}

