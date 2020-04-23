$EnumerationPingSweepIPNetworkCIDRTextboxAdd_KeyDown = { 
    if ($_.KeyCode -eq "Enter") { 
        Conduct-PingSweep 
    } 
}
