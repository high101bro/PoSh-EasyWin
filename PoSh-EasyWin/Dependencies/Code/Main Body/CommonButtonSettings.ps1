
function CommonButtonSettings {
    param($Button)
    $Button.Font      = New-Object System.Drawing.Font("$ButtonFont",11,0,0,0)
    $Button.ForeColor = "Black"
    $Button.Flatstyle = 'Flat'
    $Button.UseVisualStyleBackColor = $true
    #$Button.FlatAppearance.BorderSize        = 1
    $Button.BackColor = 'LightGray'
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
    <#
    $Button.BackColor = 'LightSkyBlue'
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DodgerBlue
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::PowderBlue

    $contextMenuStrip1 = New-Object System.Windows.Forms.ContextMenuStrip
    $contextMenuStrip1.Items.Add("Item 1")
    $contextMenuStrip1.Items.Add("Item 2")  
    $Button.ShortcutsEnabled = $false
    $Button.ContextMenuStrip = $contextMenuStrip1
    #>
}
