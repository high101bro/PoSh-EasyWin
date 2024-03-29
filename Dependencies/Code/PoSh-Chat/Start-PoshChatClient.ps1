param(
    $EncryptionKey = 'PoSh-EasyWin_Team_Chat_Server',
    $Port = 15600
)

Function Set-EncryptionKey {
    param(
        [string]$string
    )
    $length = $string.length
    $pad = 32-$length
    if (($length -lt 8) -or ($length -gt 32)) {Throw "String must be between 16 and 32 characters"}
    $encoding = New-Object System.Text.ASCIIEncoding
    $bytes = $encoding.GetBytes($string + "0" * $pad)
    return $bytes
}
$CipherKey = Set-EncryptionKey -string $EncryptionKey

# Hashes the EncryptionKey, used to compare if connections have same key
$KeyStream = [IO.MemoryStream]::new([byte[]][char[]]$EncryptionKey)
$HashedKey = Get-FileHash -InputStream $KeyStream -Algorithm SHA256 | Select-Object -ExpandProperty Hash

$ParamHT = @{
    Port          = $Port
    EncryptionKey = $EncryptionKey
    CipherKey     = $CipherKey
    HashedKey     = $HashedKey
}


$RunSpace=[RunspaceFactory]::CreateRunspace()
$RunSpace.ApartmentState = "STA"
$RunSpace.ThreadOptions = "ReuseThread"
$RunSpace.Open()
$PowerShell = [PowerShell]::Create()
$PowerShell.Runspace = $RunSpace
$PowerShell.Runspace.SessionStateProxy.SetVariable("pwd",$pwd)
$handle = $PowerShell.AddScript({
    Param (
        $Port,
        $EncryptionKey,
        $CipherKey,
        $HashedKey
    )
    <#
    [pscustomobject]@{
        Port          = $Port
        EncryptionKey = $EncryptionKey
        CipherKey     = $CipherKey
        HashedKey     = $HashedKey
    }
    #>

    Add-Type assemblyName PresentationFramework
    Add-Type assemblyName PresentationCore
    Add-Type assemblyName WindowsBase
    
    ##Functions   
    Function Open-PoshChatAbout {
	    $RunSpace=[RunspaceFactory]::CreateRunspace()
	    $RunSpace.ApartmentState = "STA"
	    $RunSpace.ThreadOptions = "ReuseThread"
	    $RunSpace.Open()
	    $PowerShell = [PowerShell]::Create()
	    $PowerShell.Runspace = $RunSpace
        $PowerShell.Runspace.SessionStateProxy.SetVariable("pwd",$pwd)
	    [void]$PowerShell.AddScript({
        [xml]$xaml = @"
        <Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            x:Name="AboutWindow" Title="About" Height="170" Width="330" ResizeMode="NoResize" WindowStartupLocation ="CenterScreen" ShowInTaskbar="False">
                <Window.Background>
                <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
                    <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' />
                    <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
                </LinearGradientBrush>
            </Window.Background>
            <StackPanel>
                    <Label FontWeight = 'Bold' FontSize = '20'>PowerShell Chat </Label>
                    <Label FontWeight = 'Bold' FontSize = '16' Padding = '0'> Version: 1.1 </Label>
                    <Label FontWeight = 'Bold' FontSize = '16' Padding = '0'> Created By: Boe Prox </Label>
                    <Label Padding = '10'> <Hyperlink x:Name = 'AuthorLink'> http://learn-powershell.net </Hyperlink> </Label>
                    <Button x:Name = 'CloseButton' Width = '100'> Close </Button>
            </StackPanel>
        </Window>
"@
        #Load XAML
        $reader=(New-Object System.Xml.XmlNodeReader $xaml)
        $AboutWindow=[Windows.Markup.XamlReader]::Load( $reader )


        #Connect to Controls
        $CloseButton = $AboutWindow.FindName("CloseButton")
        $AuthorLink = $AboutWindow.FindName("AuthorLink")

        #PsexecLink Event
        $AuthorLink.Add_Click({
            Start-Process "http://learn-powershell.net"
        })

        $CloseButton.Add_Click({
            $AboutWindow.Close()
        })

        #Show Window
        [void]$AboutWindow.showDialog()
        }).BeginInvoke()
    }
    Function Script:Save-Transcript {
        $saveFile = New-Object Microsoft.Win32.SaveFileDialog
        $saveFile.Filter = "Text documents (.txt)|*.txt"
        $saveFile.DefaultExt = '.txt'
        $saveFile.FileName = ("{0:yyyyddmm_hhmmss}ChatTranscript" -f (Get-Date))
        $saveFile.OverwritePrompt = $True
        $return = $saveFile.ShowDialog()
        If ($return) {
            $Message = new-object System.Windows.Documents.TextRange -ArgumentList $MainMessage.Document.ContentStart,$MainMessage.Document.ContentEnd
            $Message.text | Out-File $saveFile.FileName
        }
    }
    Function Script:New-ChatMessage {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine=$True)]
            [string]$Message,
            [parameter()]
            [string]$Foreground,
            [parameter()]
            [string]$Background,
            [parameter()]
            [switch]$Bold
        )
        Begin {
            $Run = New-Object System.Windows.Documents.Run
            $Run.Foreground = $Foreground
            If ($PSBoundParameters['Bold']) {
                $run.FontWeight = 'Bold'
            }
        }
        Process {
            $Run.Text = $Message
        }
        End{
            Write-Output $Run
        }
    }

    Function Script:Invoke-FontDialog {
        [cmdletbinding()]
        Param (
            $Control,
            [switch]$ShowColor,
            [switch]$FontMustExist,
            [switch]$HideEffects
        )
        Begin {
            $Script:fontDialog = new-object windows.forms.fontdialog
            $fontDialog.AllowScriptChange = $False
            If ($PSBoundParameters['ShowColor']) {
                $fontDialog.Showcolor = $True
                $fontDialog.Color = $colors[$Control.Foreground.Color.ToString()]
            }
            If ($PSBoundParameters['FontMustExist']) {
                $fontDialog.FontMustExist = $True
            }
            If ($PSBoundParameters['HideEffects']) {
                $fontDialog.ShowEffects = $False
            }
            $styles = New-Object System.Collections.Arraylist
            $textDecorations = $Control.TextDecorations | Select-Object -Expand Location
            If ($textDecorations -contains "Underline") {
                $Styles.Add("Underline") | Out-Null
            }
            If ($textDecorations -contains "Strikethrough") {
                $Styles.Add("Strikeout") | Out-Null
            }
            If ($Inputbox_txt.FontStyle -eq "Italic") {
                $Styles.Add("Italic") | Out-Null
            }
            If ($Inputbox_txt.FontWeight -eq "Bold") {
                $Styles.Add("Bold") | Out-Null
            }
            If ($styles.count -eq 0) {
                $style = "Regular"
            } Else {
                $style = $styles -join ","
            }
        }
        Process {
            $fontDialog.Font = New-Object System.Drawing.Font -ArgumentList $Control.Fontfamily.source,$Control.FontSize,$Style,"Point"
            If ($fontDialog.ShowDialog() -eq "OK") {
                $Control.fontsize =  $FontDialog.Font.Size
                If ($PSBoundParameters['ShowColor']) {
                    $Control.Foreground = $colors[$FontDialog.Color.Name]
                }
                $Control.FontFamily = $fontDialog.Font.FontFamily.Name
                If ($fontDialog.Font.Bold) {
                    $Control.FontWeight = "Bold"
                } Else {
                    $Control.FontWeight = "Regular"
                }
                If ($fontDialog.Font.Italic) {
                    $Control.FontStyle = "Italic"
                } Else {
                    $Control.FontStyle = "Normal"
                }
                If (-Not $PSBoundParameters['HideEffects']) {
                    $textDecorationCollection = new-object System.Windows.TextDecorationCollection
                    If ($fontDialog.Font.Underline) {
                        $underline = New-Object System.Windows.TextDecoration
                        $underline.Location = 'Underline'
                        $textDecorationCollection.Add($underline)
                    }
                    If ($fontDialog.Font.Strikeout) {
                        $strikethrough = New-Object System.Windows.TextDecoration
                        $strikethrough.Location = 'strikethrough'
                        $textDecorationCollection.Add($strikethrough)
                    }
                    If ($textDecorationCollection.Count -gt 0) {
                        #Sometimes a control does not have a TextDecorations property
                        If ($Control | Get-Member -Name TextDecorations) {
                            $Control.TextDecorations = $textDecorationCollection
                        }
                    }
                }
            }
        }
    }

    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$xaml = @"
<Window
    xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
    xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
    x:Name="Window" Title="PoSh-EasyWIn Team Chat" Height="600" Width="900" WindowStartupLocation="CenterScreen" ShowInTaskbar="True">
    <Window.Background>
        <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
            <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' />
            <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
        </LinearGradientBrush>
    </Window.Background>
    <Grid ShowGridLines = 'false'>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width ='175*'> </ColumnDefinition>
            <ColumnDefinition Width ='Auto'> </ColumnDefinition>
            <ColumnDefinition Width ='75*'> </ColumnDefinition>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = '*'/>
            <RowDefinition Height = '10'/>
            <RowDefinition Height = '80'/>
        </Grid.RowDefinitions>
       <Menu Width = 'Auto' HorizontalAlignment = 'Stretch' Grid.Row = '0' Grid.ColumnSpan = '3'>
        <Menu.Background>
            <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
                <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' />
                <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
            </LinearGradientBrush>
        </Menu.Background>
            <MenuItem x:Name = 'FileMenu' Header = '_File'>
                <MenuItem x:Name = 'SaveTranscript' Header = '_Save Transcript' ToolTip = 'Saves the chat transcript.' InputGestureText ='Ctrl+S'> </MenuItem>
                <Separator />
                <MenuItem x:Name = 'ExitMenu' Header = 'E_xit' ToolTip = 'Exits the client.' InputGestureText ='Ctrl+E'> </MenuItem>
            </MenuItem>
            <MenuItem x:Name = 'EditMenu' Header = '_Edit'>
                <MenuItem x:Name = 'FontMenu' Header = '_Font'>
                    <MenuItem x:Name = 'MessageWindowFont' Header = '_MessageWindow'/>
                    <MenuItem x:Name = 'OnlineUsersFont' Header = '_OnlineUsers'/>
                    <MenuItem x:Name = 'InputBoxFont' Header = '_InputBox'/>
                </MenuItem>
            </MenuItem>
            <MenuItem x:Name = 'HelpMenu' Header = '_Help'>
                <MenuItem x:Name = 'AboutMenu' Header = '_About' ToolTip = 'Show the current version and other information.'> </MenuItem>
            </MenuItem>
        </Menu>
        <RichTextBox x:Name = 'MainMessage_txt' Grid.Column = '0' Grid.Row = '1' IsReadOnly = 'True' VerticalScrollBarVisibility='Visible'>
            <FlowDocument>
                <Paragraph x:Name = 'Paragraph'/>
            </FlowDocument>
        </RichTextBox>
        <Label Grid.Column='1' Grid.Row = '1' Width='8' Grid.RowSpan = '3' HorizontalAlignment = 'Center' VerticalAlignment = 'Stretch'
        Background = 'LightGray'/>
        <Label Grid.Column = '0' Grid.Row = '2' Grid.ColumnSpan = '3' Background = 'LightGray'/>
        <ListView x:Name = 'OnlineUsers' Grid.Column = '2' Grid.Row = '1' />
        <Grid Grid.Column = '0' Grid.Row = '3' ShowGridLines = 'false'>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width ='175*'> </ColumnDefinition>
            <ColumnDefinition Width ='Auto'> </ColumnDefinition>
        </Grid.ColumnDefinitions>
            <TextBox x:Name = 'Input_txt' AcceptsReturn = 'True' VerticalScrollBarVisibility='Visible' TextWrapping = 'Wrap'
            Grid.Column = '0' HorizontalAlignment = 'Stretch'/>
            <Button x:Name = 'Send_btn' Width = '50' Height = '25' Content = 'Send' Grid.Column = '1'/>
        </Grid>
        <Grid Grid.Column = '2' Grid.Row = '3' ShowGridLines = 'false'>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width ='Auto'> </ColumnDefinition>
                <ColumnDefinition Width ='5'> </ColumnDefinition>
                <ColumnDefinition Width ='*'> </ColumnDefinition>
                <ColumnDefinition Width ='Auto'> </ColumnDefinition>
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height = 'Auto'/>
                <RowDefinition Height = 'Auto'/>
                <RowDefinition Height = '*'/>
            </Grid.RowDefinitions>
            <Label Content = 'UserName' HorizontalAlignment = 'Stretch' Grid.Column = '0' Grid.Row = '0'/>
            <TextBox x:Name = 'username_txt' HorizontalAlignment = 'Stretch' Grid.Column = '2' Grid.Row = '0'/>
            <Label Content = 'Server' HorizontalAlignment = 'Stretch' Grid.Column = '0' Grid.Row = '1'/>
            <TextBox x:Name = 'servername_txt' HorizontalAlignment = 'Stretch' Grid.Column = '2' Grid.Row = '1'/>
            <Button x:Name = 'Connect_btn' MaxWidth = '75' Height = '20' Content = 'Connect'
            Grid.Column = '0' Grid.Row = '2' HorizontalAlignment = 'stretch'/>
            <Button x:Name = 'Disconnect_btn' MaxWidth = '75' Height = '20' Content = 'Disconnect'
            Grid.Column = '2' Grid.Row = '2' HorizontalAlignment = 'stretch' IsEnabled = 'False'/>
            <Label Grid.Column = '3' Grid.Row = '2' Width ='5'/>
        </Grid>
    </Grid>
</Window>
"@
    #Load XAML
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)

    $Window=[Windows.Markup.XamlReader]::Load( $reader )

    ##Controls
    $MessageWindowFont = $Window.FindName("MessageWindowFont")
    $OnlineUsersFont = $Window.FindName("OnlineUsersFont")
    $InputBoxFont = $Window.FindName("InputBoxFont")
    $Script:Paragraph = $Window.FindName('Paragraph')
    $Script:OnlineUsers = $Window.FindName('OnlineUsers')
    $SendButton = $Window.FindName('Send_btn')
    $Script:ConnectButton = $Window.FindName('Connect_btn')
    $DisconnectButton = $Window.FindName('Disconnect_btn')
    $Username_txt = $Window.FindName('username_txt')
    $Server_txt = $Window.FindName('servername_txt')
    $Inputbox_txt = $Window.FindName('Input_txt')
    $Script:MainMessage = $Window.FindName('MainMessage_txt')
    $ExitMenu = $Window.FindName('ExitMenu')
    $SaveTranscript = $Window.FindName('SaveTranscript')
    $AboutMenu = $Window.FindName('AboutMenu')

    ##Events
    ##InputBox Font event
    $InputBoxFont.Add_Click({
        Invoke-FontDialog -Control $Inputbox_txt -ShowColor -FontMustExist
    })
    ##OnlineUser Font event
    $OnlineUsersFont.Add_Click({
        Invoke-FontDialog -Control $OnlineUsers -ShowColor -FontMustExist
    })
    ##MessageWindow Font event
    $MessageWindowFont.Add_Click({
        Invoke-FontDialog -Control $MainMessage -FontMustExist
    })

    #ExitMenu
    $ExitMenu.Add_Click({
        $Window.Close()
    })

    #SaveTranscriptMenu
    $SaveTranscript.Add_Click({
        Save-Transcript
    })

    #AboutMenu
    $AboutMenu.Add_Click({
        Open-PoshChatAbout
    })

    #Add PoSh-EasyWIn Icon to Form
    # $Window.add_Loaded({
    #     $Window.Icon = $script:Icon
    # })

    #Connect
    $ConnectButton.Add_Click({
        #Get Server IP
        $Server = $Server_txt.text

        #Get Username
        $Global:Username = $Username_txt.text
        If ($username -match "^[A-Za-z0-9_!]*$") {
            $ConnectButton.IsEnabled = $False
            $DisconnectButton.IsEnabled = $True
            If ($Server -AND $Username) {
                ### $Message = "[$env:COMPUTERNAME] {0}: " -f $username
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("ATTEMPTING TO CONNECT TO CHAT SERVER:") -ForeGround DarkOrange -Bold))
                $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("     {0}  " -f "DateTime:") -ForeGround DarkOrange -Bold))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f (Get-Date).ToString()) -ForeGround Gray))
                $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("     {0}  " -f "User Name:") -ForeGround DarkOrange -Bold))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $username) -ForeGround Gray))
                $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("     {0}  " -f "Computer Name:") -ForeGround DarkOrange -Bold))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $env:COMPUTERNAME) -ForeGround Gray))
                $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("     {0}  " -f "Server Name or IP:") -ForeGround DarkOrange -Bold))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $Server) -ForeGround Gray))
                $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("     {0}  " -f "Connecting Port:") -ForeGround DarkOrange -Bold))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $Port) -ForeGround Gray))
                $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("     {0}  " -f "Encryption Key:") -ForeGround DarkOrange -Bold))
                $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $EncryptionKey) -ForeGround Gray))
                $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                # $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))

                #Connect to server
                $Endpoint = new-object System.Net.IPEndpoint ([ipaddress]::any,$SourcePort)
                $TcpClient = [Net.Sockets.TCPClient]$endpoint
                Try {
                    $TcpClient.Connect($Server,$Port)
                    $Global:ServerStream = $TcpClient.GetStream()
                    $data = [text.Encoding]::Ascii.GetBytes($Username)
                    $ServerStream.Write($data,0,$data.length)
                    $ServerStream.Flush()
                    If ($TcpClient.Connected) {
                        $Window.Title = ("{0}: Connected as {1}" -f $Window.Title,$Username)
                        #Kick off a job to watch for messages from clients
                        $newRunspace = [RunSpaceFactory]::CreateRunspace()
                        $newRunspace.Open()
                        $newRunspace.SessionStateProxy.setVariable("TcpClient", $TcpClient)
                        $newRunspace.SessionStateProxy.setVariable("MessageQueue", $MessageQueue)
                        $newRunspace.SessionStateProxy.setVariable("ConnectButton", $ConnectButton)
                        $newPowerShell = [PowerShell]::Create()
                        $newPowerShell.Runspace = $newRunspace
                        $sb = {
                            #Code to kick off client connection monitor and look for incoming messages.
                            $client = $TCPClient
                            $serverstream = $Client.GetStream()
                            #While client is connected to server, check for incoming traffic
                            While ($client.Connected) {
                                Try {
                                    [byte[]]$inStream = New-Object byte[] 200KB
                                    $buffSize = $client.ReceiveBufferSize
                                    $return = $serverstream.Read($inStream, 0, $buffSize)
                                    If ($return -gt 0) {
                                        $Messagequeue.Enqueue([System.Text.Encoding]::ASCII.GetString($inStream[0..($return - 1)]))
                                    }
                                } Catch {
                                    #Connection to server has been closed
                                    $Messagequeue.Enqueue("~S")
                                    Break
                                }
                            }
                            #Shutdown the connection as connection has ended
                            $client.Client.Disconnect($True)
                            $client.Client.Close()
                            $client.Close()
                            $ConnectButton.IsEnabled = $True
                            $DisconnectButton.IsEnabled = $False
                        }
                        $job = "" | Select Job, PowerShell
                        $job.PowerShell = $newPowerShell
                        $Job.job = $newPowerShell.AddScript($sb).BeginInvoke()
                        $ClientConnection.$Username = $job
                    }
                } Catch {
                    #Errors Connecting to server
                    $Paragraph.Inlines.Add((New-ChatMessage -Message ("Unable to connect to {0}! Please try again later!" -f $RemoteServer) -ForeGround Red))
                    $ConnectButton.IsEnabled = $True
                    $TcpClient.Close()
                    $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                    $ClientConnection.user.PowerShell.EndInvoke($ClientConnections.user.Job)
                    $ClientConnection.user.PowerShell.Runspace.Close()
                    $ClientConnection.user.PowerShell.Dispose()
                }
            }
        } Else {
            #Username is not in correct format
            $Paragraph.Inlines.Add((New-ChatMessage -Message ("`'{0}`' is not a valid username! Acceptable characters are 'A-Za-z0-9!_'. Spaces are not allowed!" -f $username) -ForeGround Red))
            $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
        }
    })

    #Send message
    $SendButton.Add_Click({
        #Encrypts the message
        Function Set-EncryptedData {
            param(
                $key,
                [string]$PlainText
            )
            $securestring = new-object System.Security.SecureString
            $chars = $plainText.toCharArray()
            foreach ($char in $chars) {$secureString.AppendChar($char)}
            $encryptedData = ConvertFrom-SecureString -SecureString $secureString -Key $key
            return $encryptedData
        }
        $EncryptedMessage = Set-EncryptedData -key $CipherKey -PlainText $Inputbox_txt.Text

        #Send message to server
        If (($Inputbox_txt.Text).StartsWith("@")) {
            # $Messagequeue.Enqueue(("~I{0}{1}{2}" -f $username,"~~",$Inputbox_txt.Text))
            $Messagequeue.Enqueue(("~I{0}{1}{2}" -f $username,"~~",$EncryptedMessage))
        }
        # $Message = "~M{0}{1}{2}" -f $username,"~~",$Inputbox_txt.Text
        $Message = "~M{0}{1}{2}" -f $username,"~~",$EncryptedMessage
        $data = [text.Encoding]::Ascii.GetBytes($Message)
        $ServerStream.Write($data,0,$data.length)
        $ServerStream.Flush()
        $Inputbox_txt.Clear()
    })

    #Load Window
    $Window.Add_Loaded({
        #Dictionary of colors for Fonts
        $script:colors = @{}
        $Color = [windows.media.colors] | Get-Member -static -Type Property | Select-Object -Expand Name | ForEach-Object {
            $colors["$([windows.media.colors]::$_)"] = $_
            $colors[$_] = "$([windows.media.colors]::$_)"
        }
        #Date placeholder for later use
        $Global:Date = Get-Date -Format ddMMyyyy
        #Used for managing the queue of messages in an orderly fashion
        $Global:MessageQueue =  [System.Collections.Queue]::Synchronized((New-Object System.collections.queue))
        #Used for managing client connection
        $Global:ClientConnection = [hashtable]::Synchronized(@{})
        #Create Timer object
        $Global:timer = New-Object System.Windows.Threading.DispatcherTimer
        #Fire off every 1 seconds
        $timer.Interval = [TimeSpan]"0:0:1.00"
        #Add event per tick
        $timer.Add_Tick({
            [Windows.Input.InputEventHandler]{ $Global:Window.UpdateLayout() }
            If ($Messagequeue.Count -gt 0) {
                $Message = $Messagequeue.Dequeue()
                #If a different day then when client started
                If ($date -ne (Get-Date -Format ddMMyyyy)) {
                    $date = (Get-Date -Format ddMMyyyy)
                    $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0} " -f (Get-Date).ToShortDateString()) -ForeGround Black -Bold))
                    $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                }
                Switch ($Message) {
                    {$_.Startswith("~B")} {
                        #Message
                        $data = ($_).SubString(2)
                        $split = $data -split ("{0}" -f "~~")
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[$env:COMPUTERNAME] {0}: " -f $split[0]) -ForeGround Black))
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $split[1]) -ForeGround Orange))
                    }
                    {$_.Startswith("~I")} {
                        #Message
                        $data = ($_).SubString(2)
                        $split = $data -split ("{0}" -f "~~")
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[$env:COMPUTERNAME] {0}: " -f $split[0]) -ForeGround Black))
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $split[1]) -ForeGround Blue))
                    }
                    {$_.Startswith("~M")} {
                        #Message #User message
                        $data = ($_).SubString(2)
                        $split = $data -split ("{0}" -f "~~")

                        Function Get-EncryptedData {
                            param(
                                $key,
                                $data
                            )
                            $data | ConvertTo-SecureString -key $key `
                            | ForEach-Object {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
                        }

                        $PlainTextMessage = Get-EncryptedData -key $CipherKey -data $split[1]

                        if ($PlainTextMessage) {
                            # Adds Time to Console
                            $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))

                            # Adds ComputerName & Username to Console
                            $Paragraph.Inlines.Add((New-ChatMessage -Message ("[$env:COMPUTERNAME] {0}: " -f $split[0]) -ForeGround Blue))
                            
                            # Adds PlainText Message to Console
                            # $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $split[1]) -ForeGround Black))
                            $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $PlainTextMessage) -ForeGround Black))
                        }
                        elseif ($PlainTextMessage.length -eq 0 ) {
                            continue
                        }
                        else {
                            # Adds Time to Console
                            $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))

                            # Adds ComputerName & Username to Console
                            $Paragraph.Inlines.Add((New-ChatMessage -Message ("[$env:COMPUTERNAME] {0}: " -f $split[0]) -ForeGround Blue))
                            
                            # Adds PlainText Message to Console
                            # $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f $split[1]) -ForeGround Black))
                            $Paragraph.Inlines.Add((New-ChatMessage -Message ("{0}" -f "[Message Using Different Encryption Key]") -ForeGround Red))

                        }
                    }
                    {$_.Startswith("~D")} {
                        #Disconnect
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[$env:COMPUTERNAME] {0} has disconnected from the server" -f $_.SubString(2)) -ForeGround Green))
                        #Remove user from online list
                        $OnlineUsers.Items.Remove($_.SubString(2))
                    }
                    {$_.StartsWith("~C")} {
                        #Connect
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))
                        $Message = ("[$env:COMPUTERNAME] {0}: " -f $_.SubString(2))
                        $Paragraph.Inlines.Add((New-ChatMessage -Message $message -ForeGround Blue))
                        $Message = ("CONNECTED TO THE CHAT SERVER")
                        $Paragraph.Inlines.Add((New-ChatMessage -Message $message -ForeGround Green -Bold))
                        ##Add user to online list
                        If ($Username -ne $_.SubString(2)) {
                            $OnlineUsers.Items.Add($_.SubString(2))
                        }
                        # $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                    }
                    {$_.StartsWith("~S")} {
                        #Server Shutdown
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))
                        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[$env:COMPUTERNAME] {0}: SERVER HAS DISCONNECTED." -f $username) -ForeGround Red -Bold))
                        $TcpClient.Close()
                        $ClientConnection.user.PowerShell.EndInvoke($ClientConnections.user.Job)
                        $ClientConnection.user.PowerShell.Runspace.Close()
                        $ClientConnection.user.PowerShell.Dispose()
                        $ConnectButton.IsEnabled = $True
                        $DisconnectButton.IsEnabled = $False
                        $OnlineUsers.Items.Clear()
                    }
                    {$_.StartsWith("~Z")} {
                        #List of connected users
                        $online = (($_).SubString(2) -split "~~")
                        #Add online users to window
                        $Online | ForEach-Object {
                            $OnlineUsers.Items.Add($_)
                        }
                    }
                    Default {
                        $MainMessage.text += ("[{0}] {1}" -f (Get-Date).ToString(),$_)
                    }
                }
            $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
            $MainMessage.ScrollToEnd()
            }
        })
        #Start timer
        $timer.Start()
        If (-NOT $timer.IsEnabled) {
            $Window.Close()
        }
    })

    $Window.Add_Closed({
        If ($TcpClient) {
            $TcpClient.Close()
        }
        If ($ClientConnection.user) {
            $ClientConnection.user.PowerShell.EndInvoke($ClientConnection.user.Job)
            $ClientConnection.user.PowerShell.Runspace.Close()
            $ClientConnection.user.PowerShell.Dispose()
        }
    })

    #Disconnect from server
    $DisconnectButton.Add_Click({
        #Get Server IP
        $Server = $Server_txt.text

        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[{0}] " -f (Get-Date).ToString()) -ForeGround Gray))
        $Paragraph.Inlines.Add((New-ChatMessage -Message ("[$env:COMPUTERNAME] {0}: DISCONNECTING FROM THE CHAT SERVER: {1}" -f $username,$Server) -ForeGround Red -Bold))
        $Paragraph.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
        #Shutdown client runspace and socket
        $TcpClient.Close()
        $ClientConnection.user.PowerShell.EndInvoke($ClientConnection.user.Job)
        $ClientConnection.user.PowerShell.Runspace.Close()
        $ClientConnection.user.PowerShell.Dispose()
        $ConnectButton.IsEnabled = $True
        $DisconnectButton.IsEnabled = $False
        $OnlineUsers.Items.Clear()
    })

    $Window.Add_KeyDown({
        $key = $_.Key
        If ([System.Windows.Input.Keyboard]::IsKeyDown("RightCtrl") -OR [System.Windows.Input.Keyboard]::IsKeyDown("LeftCtrl")) {
            Switch ($Key) {
            "E" {$Window.Close()}
            "RETURN" {
                Write-Verbose ("Sending message")
                If (($Inputbox_txt.Text).StartsWith("@")) {
                    $Messagequeue.Enqueue(("~I{0}{1}{2}" -f $username,"~~",$Inputbox_txt.Text))
                }
                $Message = "~M{0}{1}{2}" -f $username,"~~",$Inputbox_txt.Text
                $data = [text.Encoding]::Ascii.GetBytes($Message)
                $ServerStream.Write($data,0,$data.length)
                $ServerStream.Flush()
                $Inputbox_txt.Clear()
            }
            "S" {Save-Transcript}
            Default {$Null}
            }
        }
    })

    [void]$Window.showDialog()

})

# Method 1: Passing in Variables
#https://devblogs.microsoft.com/scripting/beginning-use-of-powershell-runspaces-part-2/
$PowerShell.AddParameters($ParamHT)

# # Method 2: Passing in Variables
# $PowerShell.AddParameter('Port',$Port)
# $PowerShell.AddParameter('EncryptionKey',$EncryptionKey)
# $PowerShell.AddParameter('CipherKey',$CipherKey)
# $PowerShell.AddParameter('HashedKey',$HashedKey)

# # Method 3: Passing in Variables
# $PowerShell.AddArgument($Port)
# $PowerShell.AddArgument($EncryptionKey)
# $PowerShell.AddArgument($CipherKey)
# $PowerShell.AddArgument($HashedKey)



# Start the Tool
    # Parameters not valid with .BeginInvoke()
    #.BeginInvoke()
$PowerShell.Invoke()
$PowerShell.Dispose()












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2zXXS6CKvoHR8soKC1ptXFAH
# x/agggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUt+aB5QatXkYQt70FeB7SDPMIB0gwDQYJKoZI
# hvcNAQEBBQAEggEALNML0kAcZnhlX6ksnkrTXntTlIfdIN4kiKT/VwyOfr3BwvPU
# 0EIVA7ibRHZtFbv1Lf3RQ5aJ81/LfcKbUVDZv76zyJPG1hcbfDGqkAJNrzOF6+vG
# PQDIOz/yFdz185UdL1ESR9VNjaol/X4e+KMRNrKBXq7ojsIWrFgooFsJRuJTvBbh
# 1C4WNO/IhILiPEL/ryie6XVLaIh/5Kvy0xn73dxiwHcolMR2LN7Iul++rME/cXpS
# e0Su2BA0zel7Trq03JEZ2LyxK0vyMXR3nN6pdc/bDojgdEykN25XMamYV09YkJKi
# EKd1BR5OhJsVQ51lJ3Jf1AfHQh9inHRd/c5J9A==
# SIG # End signature block
