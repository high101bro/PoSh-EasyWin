$EnumerationResolveDNSNameButtonAdd_Click = {
    if ($($EnumerationComputerListBox.SelectedItems).count -eq 0){
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("DNS Resolution:  Make at least one selection")
    }
    else {
        if (Verify-Action -Title "Verification: Resolve DNS" -Question "Conduct a DNS Resolution of the following?" -Computer $($EnumerationComputerListBox.SelectedItems -join ', ')) {
            #for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) { $EnumerationComputerListBox.SetSelected($i, $true) }

            #$EnumerationComputerListBoxSelected = $EnumerationComputerListBox.SelectedItems
            #$EnumerationComputerListBox.Items.Clear()

            # Resolve DNS Names
            $DNSResolutionList = @()
            foreach ($Selected in $($EnumerationComputerListBox.SelectedItems)) {
                $DNSResolution      = (((Resolve-DnsName $Selected).NameHost).split('.'))[0]
                $DNSResolutionList += $DNSResolution
                $EnumerationComputerListBox.Items.Remove($Selected)
            }
            foreach ($Item in $DNSResolutionList) { $EnumerationComputerListBox.Items.Add($Item) }
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("DNS Resolution:  Cancelled")
        }
    }
}


