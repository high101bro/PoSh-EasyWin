
function Apply-CommonButtonSettings {
    param($Button)
    [System.Windows.Forms.Application]::EnableVisualStyles()
    
    $Button.Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    $Button.ForeColor = "Black"
    $Button.Flatstyle = 'Flat' #'Flat','Popup','Standard','System' -- #default=Standard
    $Button.UseVisualStyleBackColor = $true

    $Button.BackColor = 'DarkGray' #LightGray'
    $Button.FlatAppearance.BorderSize = 2
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Black
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::SlateGray
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::SlateGray

    # $Button.BackColor = 'LightGray'
    # $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    # $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
    # $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray

    # $Button.BackColor = [System.Drawing.Color]::PowderBlue
    # $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::DarkGray
    # $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DodgerBlue
    # $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::LightSkyBlue

    $contextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip
    $contextMenuStrip.Items.Add("PoSh-EasyWin")
    $contextMenuStrip.Items.Add("high101bro")
    $Button.ShortcutsEnabled = $true
    $Button.ContextMenuStrip = $contextMenuStrip
}


