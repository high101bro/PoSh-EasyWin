
# The .ImageList allows for the images to be loaded from disk to memory only once, then referenced using their index number
$ButtonImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
$script:ComputerTreeViewIconList = Get-ChildItem "$Dependencies\Images\Icons\Endpoint"

$ButtonImageList.Images.Add([System.Drawing.Image]::FromFile("$EasyWinIcon"))
$ButtonImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Icon OU LightYellow.png"))


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


    $ContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip
    $ContextMenuStrip.ShowCheckMargin  = $true
    $ContextMenuStrip.ShowImageMargin  = $true
    $ContextMenuStrip.ShowItemToolTips = $true
    $ContextMenuStrip.GripMargin = @{Left=0;Top=0;Right=0;Bottom=0}
    $ContextMenuStrip.Padding = @{Left=0;Top=0;Right=0;Bottom=0}

    $ContextMenuStripPoShEasyWinToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::Fromfile("$Dependencies\Images\favicon.jpg")
        # BackgroundImage = [System.Drawing.Image]::Fromfile("$Dependencies\Images\high101bro Logo Color Transparent.png")
        # BackgroundImageLayout = 'Tile' #Stretch
        Text = 'PoSh-EasyWin'
        Padding = @{Left=0;Top=0;Right=0;Bottom=0}
        Add_Click = {}
    }
    $ContextMenuStrip.Items.add($ContextMenuStripPoShEasyWinToolStripMenuItem)

    $ContextMenuStriphigh101broToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::Fromfile("$Dependencies\Images\high101bro Logo Color Transparent.png")
        Text = 'high101bro'
        Padding = @{Left=0;Top=0;Right=0;Bottom=0}
        Add_Click = {}
    }
    $ContextMenuStrip.Items.add($ContextMenuStriphigh101broToolStripMenuItem)

    # $ContextMenuStrip.DisplayStyle = [System.Drawing.ToolStripItemDisplayStyle]::ImageAndText 

#    $ContextMenuStrip.ImageList         = $ButtonImageList
    # $ContextMenuStrip.ImageKey        = -1 # the default image
#    $ContextMenuStrip.Image = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PoSh-EasyWin Image 01.png")
    # $Button.ShortcutsEnabled = $true
    $Button.ContextMenuStrip = $ContextMenuStrip
}


