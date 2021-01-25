<# TODO: Remote Screenshot Implementation
$ComputerListScreenShotButtonAdd_Click = {

    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    Generate-ComputerList

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    $VerifyAction = Verify-Action -Title "Verification: Endpoint ScreenShot" -Question "Connecting Account:  $Username`n`nConduct a screenshot on the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
    $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text 
        $LocalSavePath = "$RetrieveFilesSaveDirectory\Screenshots"
        if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Screenshots") ) {
            New-Item -Type Directory -Path $LocalSavePath
        }
        
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Session to $script:ComputerTreeViewSelected")

        $TargetComputer = $script:ComputerTreeViewSelected


        # This brings specific tabs to the forefront/front view
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
                Invoke-Command -ScriptBlock {
                    param($TargetComputer,$LocalSavePath)
                    function Get-RemoteScreenshot {
                    #
                    #.SYNOPSIS
                    #    This script contains the required functions/task template to create screenshot of the remote PC
                    #.NOTES
                    #    Modified by high101bro
                    #.LINK
                    #    https://github.com/krzydoug/Tools/blob/master/Get-RemoteScreenshot.ps1
                    #
                    [cmdletbinding()]
                    Param(
                        [Parameter(
                            Mandatory=$True,
                            ValueFromPipeline=$True,
                            ValueFromPipelineByPropertyName=$True
                        )]
                        [string[]]$ComputerName,
                        [Parameter()]             
                        [ValidateScript({
                            Test-Path -Path $_ 
                        })]
                        [string]$Path
                    )
                    begin {
                        $ErrorActionPreference = 'stop'
                        # Defining functions

                        Function Take-Screenshot {
                            Param($ComputerName)
                            $ErrorActionPreference = 'stop'
                            $localpsscript = "c:\Windows\Temp\Take-Screenshot.ps1"
                            $localvbscript = "c:\Windows\Temp\launch.vbs"

                            $psscript = @'
                Function Take-Screenshot{
                [CmdletBinding()]
                Param(
                    [ValidateScript({
                        Test-Path -Path $_
                    })]
                    [string]$Path
                )
    
                #Define helper function that generates and saves screenshot
                Function GenScreenshot{
                    $ScreenBounds = [Windows.Forms.SystemInformation]::VirtualScreen
                    $ScreenshotObject = New-Object Drawing.Bitmap $ScreenBounds.Width, $ScreenBounds.Height
                    $DrawingGraphics = [Drawing.Graphics]::FromImage($ScreenshotObject)
                    $DrawingGraphics.CopyFromScreen( $ScreenBounds.Location, [Drawing.Point]::Empty, $ScreenBounds.Size)
                    $DrawingGraphics.Dispose()
                    $ScreenshotObject.Save($FilePath)
                    $ScreenshotObject.Dispose()
                }
                Try{
                    #load required assembly
                    Add-Type -Assembly System.Windows.Forms            
                    # Build filename from PC, user, and the current date/time.
                    $FileName = "${env:computername}-${env:username}-{0}.png" -f (Get-Date).ToString("yyyyMMdd-HHmmss")
                    $FilePath = Join-Path $Path $FileName
                    #run screenshot function
                    GenScreenshot
                
                    Write-Verbose "Saved screenshot to $FilePath."
                }
                Catch{
                    Write-Error $Error[0]
                }
        }
        Take-Screenshot -path C:\Windows\Temp
'@
                            $task = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
    <RegistrationInfo>
    <Date>2020-06-15T11:47:39.2496369</Date>
    <URI>\Remote Screenshot</URI>
    <SecurityDescriptor></SecurityDescriptor>
    </RegistrationInfo>
    <Triggers />
    <Principals>
    <Principal id="Author">
        <GroupId>S-1-5-32-545</GroupId>
        <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
    </Principals>
    <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
        <Duration>PT10M</Duration>
        <WaitTimeout>PT1H</WaitTimeout>
        <StopOnIdleEnd>true</StopOnIdleEnd>
        <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
    </Settings>
    <Actions>
    <Exec>
        <Command>wscript.exe</Command>
        <Arguments>$localvbscript /B</Arguments>
    </Exec>
    </Actions>
</Task>
"@
                            $VBscript = @"
    Dim objShell,objFSO,objFile
    Set objShell=CreateObject("WScript.Shell")
    Set objFSO=CreateObject("Scripting.FileSystemObject")
    'enter the path for your PowerShell Script
    strPath="$localpsscript"
    'verify file exists
    If objFSO.FileExists(strPath) Then
    'return short path name
        set objFile=objFSO.GetFile(strPath)
        strCMD="powershell -nologo -ex bypass -nop -Command " & Chr(34) & "&{" &_
            objFile.ShortPath & "}" & Chr(34)
        'Uncomment next line for debugging
        'WScript.Echo strCMD
   
        'use 0 to hide window
        objShell.Run strCMD,0
    Else
    'Display error message
        WScript.Echo "Failed to find " & strPath
        WScript.Quit
   
    End If
"@
                            # Gathering environment variables
                            $taskfile = Join-Path $env:TEMP -ChildPath "Screenshot-Task.xml"
                            
                            if ( -not $Path ){$Path = $env:TEMP}
                            $RemotePath = "\\$ComputerName\c$\Windows\Temp\"
                            
                            if ( -not ( test-path $RemotePath ) ){
                                New-Item -Path $RemotePath -ItemType Directory | Out-Null
                            }

                            # script on the remote host from calling hosts context
                            $psscriptfile = Join-Path $RemotePath -ChildPath "Take-Screenshot.ps1"
                            
                            $vbscriptfile = Join-Path $RemotePath -ChildPath "launch.vbs"

                            # Search pattern for screenshot filename
                            $FileName = "$ComputerName-*-{0}" -f (Get-Date).ToString("yyyyMMdd-HH")

                            try {
                                # Creating remote files on $ComputerName

                                # Create the ps1, vbs, and the task template on the remote PC
                                $psscript | Set-Content -Path $psscriptfile -Encoding Ascii -Force
                                $task     | Set-Content -Path $taskfile -Encoding Ascii
                                $VBscript | Set-Content -Path $vbscriptfile -Encoding Ascii
                                
                                # Attempts to create, run, and then delete scheduled task
                                # Creating scheduled task on $ComputerName
                                schtasks /create /xml $taskfile /tn "\Remote Screenshot" /S $ComputerName /F | Out-Null
                                Start-Sleep -Milliseconds 500

                                # Running scheduled task on $ComputerName
                                schtasks /run /tn "\Remote Screenshot" /S $ComputerName | out-null

                                do {
                                    Start-Sleep -Seconds 1
                                    $taskstatus = ((schtasks /query /tn "Remote Screenshot" /S $ComputerName /FO list | Select-String -Pattern 'Status:') -split ':')[1].trim()
                                }
                                until ($taskstatus -ne 'running')
                                
                                $retries = 0
                                do {
                                    Write-Verbose "Loop $retries waiting for file creation on $ComputerName"
                                    Start-Sleep -Seconds 2
                                    $RemoteFile = Get-ChildItem -Path $RemotePath -Filter "$filename*" -File | Select-Object -last 1 -ExpandProperty name
                                    $retries++
                                }
                                until ($RemoteFile.count -gt 0 -or $retries -eq 5)

                                # Deleting scheduled task on $ComputerName
                                schtasks /delete /tn "\Remote Screenshot" /S $ComputerName /F | Out-Null
                                
                                if ($RemoteFile.count -gt 0){
                                    # Moving screenshot from $ComputerName to the local pc
                                    $LocalFile      = Join-Path $Path -ChildPath $RemoteFile
                                    $FileRemotePath = Join-Path $RemotePath -ChildPath $RemoteFile
                                    $LocalFile      = Move-Item -Path $FileRemotePath -Destination $Path -Force -PassThru
                                    Start-Sleep -Milliseconds 500
                                }
                            }
                            Catch {
                                Write-Error $Error[0]
                            }
                            Finally{
                                # Deleting temporary files

                                try {
                                    Remove-Item $psscriptfile,$taskfile,$vbscriptfile -Force -ErrorAction SilentlyContinue
                                    if($LocalFile){$LocalFile | Invoke-Item}
                                }
                                catch {
                                    Write-Error $Error[0]
                                }
                            }
                        }
                    }
                    process {
                        foreach ($Computer in $ComputerName) {
                            Take-Screenshot -ComputerName $Computer
                        }
                    }
                    end {}
                }
                if ($TargetComputer -eq 'localhost' -or $TargetComputer -eq '127.0.0.1' ) {
                    $TargetComputer = $env:ComputerName
                }
                Get-RemoteScreenshot -ComputerName "$TargetComputer" -Path "$LocalSavePath"
            } -ArgumentList @($TargetComputer,$LocalSavePath) -Credential $script:Credential
        }
        else {
                Invoke-Command -ScriptBlock {
                    param($TargetComputer,$LocalSavePath)
                    function Get-RemoteScreenshot {
                    #
                    #.SYNOPSIS
                    #    This script contains the required functions/task template to create screenshot of the remote PC
                    #.NOTES
                    #    Modified by high101bro
                    #.LINK
                    #    https://github.com/krzydoug/Tools/blob/master/Get-RemoteScreenshot.ps1
                    #
                    [cmdletbinding()]
                    Param(
                        [Parameter(
                            Mandatory=$True,
                            ValueFromPipeline=$True,
                            ValueFromPipelineByPropertyName=$True
                        )]
                        [string[]]$ComputerName,
                        [Parameter()]             
                        [ValidateScript({
                            Test-Path -Path $_ 
                        })]
                        [string]$Path
                    )
                    begin {
                        $ErrorActionPreference = 'stop'
                        # Defining functions

                        Function Take-Screenshot {
                            Param($ComputerName)
                            $ErrorActionPreference = 'stop'
                            $localpsscript = "c:\Windows\Temp\Take-Screenshot.ps1"
                            $localvbscript = "c:\Windows\Temp\launch.vbs"

                            $psscript = @'
                Function Take-Screenshot{
                [CmdletBinding()]
                Param(
                    [ValidateScript({
                        Test-Path -Path $_
                    })]
                    [string]$Path
                )
    
                #Define helper function that generates and saves screenshot
                Function GenScreenshot{
                    $ScreenBounds = [Windows.Forms.SystemInformation]::VirtualScreen
                    $ScreenshotObject = New-Object Drawing.Bitmap $ScreenBounds.Width, $ScreenBounds.Height
                    $DrawingGraphics = [Drawing.Graphics]::FromImage($ScreenshotObject)
                    $DrawingGraphics.CopyFromScreen( $ScreenBounds.Location, [Drawing.Point]::Empty, $ScreenBounds.Size)
                    $DrawingGraphics.Dispose()
                    $ScreenshotObject.Save($FilePath)
                    $ScreenshotObject.Dispose()
                }
                Try{
                    #load required assembly
                    Add-Type -Assembly System.Windows.Forms            
                    # Build filename from PC, user, and the current date/time.
                    $FileName = "${env:computername}-${env:username}-{0}.png" -f (Get-Date).ToString("yyyyMMdd-HHmmss")
                    $FilePath = Join-Path $Path $FileName
                    #run screenshot function
                    GenScreenshot
                
                    Write-Verbose "Saved screenshot to $FilePath."
                }
                Catch{
                    Write-Error $Error[0]
                }
        }
        Take-Screenshot -path C:\Windows\Temp
'@
                            $task = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
    <RegistrationInfo>
    <Date>2020-06-15T11:47:39.2496369</Date>
    <URI>\Remote Screenshot</URI>
    <SecurityDescriptor></SecurityDescriptor>
    </RegistrationInfo>
    <Triggers />
    <Principals>
    <Principal id="Author">
        <GroupId>S-1-5-32-545</GroupId>
        <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
    </Principals>
    <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
        <Duration>PT10M</Duration>
        <WaitTimeout>PT1H</WaitTimeout>
        <StopOnIdleEnd>true</StopOnIdleEnd>
        <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
    </Settings>
    <Actions>
    <Exec>
        <Command>wscript.exe</Command>
        <Arguments>$localvbscript /B</Arguments>
    </Exec>
    </Actions>
</Task>
"@
                            $VBscript = @"
    Dim objShell,objFSO,objFile
    Set objShell=CreateObject("WScript.Shell")
    Set objFSO=CreateObject("Scripting.FileSystemObject")
    'enter the path for your PowerShell Script
    strPath="$localpsscript"
    'verify file exists
    If objFSO.FileExists(strPath) Then
    'return short path name
        set objFile=objFSO.GetFile(strPath)
        strCMD="powershell -nologo -ex bypass -nop -Command " & Chr(34) & "&{" &_
            objFile.ShortPath & "}" & Chr(34)
        'Uncomment next line for debugging
        'WScript.Echo strCMD
   
        'use 0 to hide window
        objShell.Run strCMD,0
    Else
    'Display error message
        WScript.Echo "Failed to find " & strPath
        WScript.Quit
   
    End If
"@
                            # Gathering environment variables
                            $taskfile = Join-Path $env:TEMP -ChildPath "Screenshot-Task.xml"
                            
                            if ( -not $Path ){$Path = $env:TEMP}
                            $RemotePath = "\\$ComputerName\c$\Windows\Temp\"
                            
                            if ( -not ( test-path $RemotePath ) ){
                                New-Item -Path $RemotePath -ItemType Directory | Out-Null
                            }

                            # script on the remote host from calling hosts context
                            $psscriptfile = Join-Path $RemotePath -ChildPath "Take-Screenshot.ps1"
                            
                            $vbscriptfile = Join-Path $RemotePath -ChildPath "launch.vbs"

                            # Search pattern for screenshot filename
                            $FileName = "$ComputerName-*-{0}" -f (Get-Date).ToString("yyyyMMdd-HH")

                            try {
                                # Creating remote files on $ComputerName

                                # Create the ps1, vbs, and the task template on the remote PC
                                $psscript | Set-Content -Path $psscriptfile -Encoding Ascii -Force
                                $task     | Set-Content -Path $taskfile -Encoding Ascii
                                $VBscript | Set-Content -Path $vbscriptfile -Encoding Ascii
                                
                                # Attempts to create, run, and then delete scheduled task
                                # Creating scheduled task on $ComputerName
                                schtasks /create /xml $taskfile /tn "\Remote Screenshot" /S $ComputerName /F | Out-Null
                                Start-Sleep -Milliseconds 500

                                # Running scheduled task on $ComputerName
                                schtasks /run /tn "\Remote Screenshot" /S $ComputerName | out-null

                                do {
                                    Start-Sleep -Seconds 1
                                    $taskstatus = ((schtasks /query /tn "Remote Screenshot" /S $ComputerName /FO list | Select-String -Pattern 'Status:') -split ':')[1].trim()
                                }
                                until ($taskstatus -ne 'running')
                                
                                $retries = 0
                                do {
                                    Write-Verbose "Loop $retries waiting for file creation on $ComputerName"
                                    Start-Sleep -Seconds 2
                                    $RemoteFile = Get-ChildItem -Path $RemotePath -Filter "$filename*" -File | Select-Object -last 1 -ExpandProperty name
                                    $retries++
                                }
                                until ($RemoteFile.count -gt 0 -or $retries -eq 5)

                                # Deleting scheduled task on $ComputerName
                                schtasks /delete /tn "\Remote Screenshot" /S $ComputerName /F | Out-Null
                                
                                if ($RemoteFile.count -gt 0){
                                    # Moving screenshot from $ComputerName to the local pc
                                    $LocalFile      = Join-Path $Path -ChildPath $RemoteFile
                                    $FileRemotePath = Join-Path $RemotePath -ChildPath $RemoteFile
                                    $LocalFile      = Move-Item -Path $FileRemotePath -Destination $Path -Force -PassThru
                                    Start-Sleep -Milliseconds 500
                                }
                            }
                            Catch {
                                Write-Error $Error[0]
                            }
                            Finally{
                                # Deleting temporary files

                                try {
                                    Remove-Item $psscriptfile,$taskfile,$vbscriptfile -Force -ErrorAction SilentlyContinue
                                    if($LocalFile){$LocalFile | Invoke-Item}
                                }
                                catch {
                                    Write-Error $Error[0]
                                }
                            }
                        }
                    }
                    process {
                        foreach ($Computer in $ComputerName) {
                            Take-Screenshot -ComputerName $Computer
                        }
                    }
                    end {}
                }
                if ($TargetComputer -eq 'localhost' -or $TargetComputer -eq '127.0.0.1' ) {
                    $TargetComputer = $env:ComputerName
                }
                Get-RemoteScreenshot -ComputerName "$TargetComputer" -Path "$LocalSavePath"
            } -ArgumentList @($TargetComputer,$LocalSavePath)
        }



        $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Conducting Screenshot")

        # Copy-Item -Path "C:\Windows\Temp\Screenshot.bmp" -Destination "$LocalSavePath\Screenshot - $($script:ComputerTreeViewSelected) - $((Get-Date).ToString('yyyyMMdd_HHmmsss')).bmp" -FromSession $session
        $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Copying screenshot to localhost")
        #"$LocalSavePath\Screenshot - $($script:ComputerTreeViewSelected) - $((Get-Date).ToString('yyyyMMdd_HHmmsss')).bmp"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "ScreenShot: $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
            Generate-NewRollingPassword
        }
    }
}
#>


$ComputerListRDPButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    Generate-ComputerList

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: Remote Desktop" -Question "Connecting Account:  $Username`n`nOpen a Remote Desktop session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
        $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text
    }
    elseif (-not $script:ComputerListEndpointNameToolStripLabel.text) {
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select Remote Desktop.','Remote Desktop')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"

            $Username = $null
            $Password = $null
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password
            #doesn't store in base64# $Password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))

            # The cmdkey utility helps you manage username and passwords; it allows you to create, delete, and display credentials for the current user
                # cmdkey /list                <-- lists all credentials
                # cmdkey /list:targetname     <-- lists the credentials for a speicific target
                # cmdkey /add:targetname      <-- creates domain credential
                # cmdkey /generic:targetname  <-- creates a generic credential
                # cmdkey /delete:targetname   <-- deletes target credential
            #cmdkey /generic:TERMSRV/$script:ComputerTreeViewSelected /user:$Username /pass:$Password
            cmdkey /delete:"$script:ComputerTreeViewSelected"
            cmdkey /delete /ras

            #doesn't store in base64# cmdkey /generic:$script:ComputerTreeViewSelected /user:"$Username" /pass:"$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(`"$Password`")))"

            cmdkey /generic:$script:ComputerTreeViewSelected /user:"$Username" /pass:"$Password"
            mstsc /v:$($script:ComputerTreeViewSelected):3389 /admin /noConsentPrompt /f

            # There seems to be a delay between the credential passing before credentials can be removed locally from cmdkey and them still being needed
            Start-Sleep -Seconds 5
            cmdkey /delete /ras
            cmdkey /delete:"$script:ComputerTreeViewSelected"

            if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
                Start-Sleep -Seconds 3
                Generate-NewRollingPassword
            }
        }
        else {
            #ensures no credentials are stored for use
            cmdkey /delete /ras
            cmdkey /delete:"$script:ComputerTreeViewSelected"

            mstsc /v:$($script:ComputerTreeViewSelected):3389 /admin /noConsentPrompt /f
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("mstsc /v:$($script:ComputerTreeViewSelected):3389 /NoConsentPrompt")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remote Desktop (RDP): $($script:ComputerTreeViewSelected)"
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  Cancelled")
    }
}

$ComputerListRDPButtonAdd_MouseHover = {
Show-ToolTip -Title "Remote Desktop Connection" -Icon "Info" -Message @"
+  Will attempt to RDP into a single host.
+  Command:
        mstsc /v:<target>:3389 /NoConsentPrompt
        mstsc /v:<target>:3389 /user:USERNAME /pass:PASSWORD /NoConsentPrompt
+  Compatiable with 'Specify Credentials' if permitted by network policy
"@
}


