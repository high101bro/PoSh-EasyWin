$OptionGUITopWindowCheckBoxAdd_Click = { 
    # Option to toggle if the Windows is not the top most
    if   ( $OptionGUITopWindowCheckBox.checked ) { 
        $PoShEasyWin.Topmost = $true  
    }
    else { 
        $PoShEasyWin.Topmost = $false 
    }
}
