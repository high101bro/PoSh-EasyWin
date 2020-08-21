
# PowerShell comes with assemblies that allow it to understand many .NET classes natively, but WPF isn't one of them. To work with WPF in PowerShell, you must first add the assembly into your current session using the Add-Type command.
Add-Type -AssemblyName PresentationFramework


# Once you've loaded the assembly, you can now begin creating a basic window. WPF represents Windows in XML, so you'll have all of the familiar XML properties like namespaces. To create the most basic window in WPF, I'm going to create an XML string and cast it to an XML object using [xml]:
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window">
    <Grid x:Name="Grid">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <TextBox x:Name = "PathTextBox"
            Width="150"
            Grid.Column="0"
            Grid.Row="0"
        />
        <Button x:Name = "ValidateButton"
            Content="Validate"
            Grid.Column="1"
            Grid.Row="0"
        />
        <Button x:Name = "RemoveButton"
            Content="Remove"
            Grid.Column="0"
            Grid.Row="1"
        />
    </Grid>
</Window>
"@

# After I have created the XAML string, I need to create an object the XamlReader class understands. To do that, I will pass it to the XmlNodeReader class as an argument. This will create an XmlNodeReader object for me.
$reader = (New-Object System.Xml.XmlNodeReader $xaml)

# I'll then pass the XmlNodeReader object to the Load() static method on the XamlReader class to create our window and then use the ShowDialog() method to display the window on the screen. This should display an extremely simple window.
$window = [Windows.Markup.XamlReader]::Load($reader)


$validateButton = $window.FindName("ValidateButton")
$removeButton = $window.FindName("RemoveButton")
$pathTextBox = $window.FindName("PathTextBox")
 
$ValidateButton.Add_Click({
    If(-not (Test-Path $pathTextBox.Text)){
        $pathTextBox.Text = ""
    }
})
 
$removeButton.Add_Click({
    If($pathTextBox.Text){
        If(Test-Path $pathTextBox.Text){
            Remove-Item $pathTextBox.Text
        }
    }
})

$window.ShowDialog()











