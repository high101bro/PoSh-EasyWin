$MainCenterTabControlAdd_Click = { 
    if ($this.SelectedTab -match 'Main') {
        $this.Width  = 370
        $this.Height = 278
    }
    elseif ($this.SelectedTab -match 'Options') {
        $this.Width  = 370
        $this.Height = 340
    }
    elseif ($this.SelectedTab -match 'Statistics') {
        $this.Width  = 370
        $this.Height = 278
    }
}

$MainCenterTabControlAdd_MouseHover = {
<#
    if ($this.SelectedTab -match 'Main') {
        Show-ToolTip -Title "Main Tab" -Icon "Info" -Message @"
+  Displays the main fields to configure and use PoSh-EasyWin
"@  
    }
    elseif ($this.SelectedTab -match 'Options') {
        Show-ToolTip -Title "Options Tab" -Icon "Info" -Message @"
+  Displays various options to configure
"@  
    }
    elseif ($this.SelectedTab -match 'Statistics') {
        Show-ToolTip -Title "Statistics Tab" -Icon "Info" -Message @"
+  Displays basic statistics and updates during PoSh-EasyWin execution
+  Contained within is the ability to easily view the Log File 
"@  
    }
#>
}
