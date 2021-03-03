$EnumerationPingSweepExecutionButtonAdd_Click = {
    if (Verify-Action -Title "Verification: Ping Sweep" -Question "Conduct a Ping Sweep of the following?" -Computer $(
        $EnumerationPingSweepIPNetworkCIDRTextbox.Text
    )) {
        $ResultsListBox.Items.Clear()
        Conduct-PingSweep
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Ping Sweep:  Cancelled")
    }
}


