$script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseEnter = {
    if ($this.text -eq "Enter IP, Range, or Subnet") {
        $this.text = ""
    }
}

$script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter IP, Range, or Subnet"
    }
}

$script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseHover = {
    Show-ToolTip -Title "Access Endpoints from IP or Subnet" -Icon "Info" -Message @"
+  This textbox identifies the host(s) that can access the quarantined endpoint(s).
+  CAUTION! If there's an error in the entry, the endpoint(s) may become completely inaccessible over the network.
+  Use the following list as guidelines to fill the textbox:
     -  Single IPv4 Address: 1.2.3.4
     -  Single IPv6 Address: fe80::1
     -  IPv4 Subnet (by network bit count): 1.2.3.4/24
     -  IPv6 Subnet (by network bit count): fe80::1/48
     -  IPv4 Subnet (by network mask): 1.2.3.4/255.255.255.0
     -  IPv4 Range: 1.2.3.4-1.2.3.7
     -  IPv6 Range: fe80::1-fe80::9
     -  Keyword: Any, LocalSubnet, DNS, DHCP, WINS, DefaultGateway, Internet, Intranet, IntranetRemoteAccess,
     PlayToDevice. NOTE: Keywords can be restricted to IPv4 or IPv6 by appending a 4 or 6 (for example, keyword
     "LocalSubnet4" means that all local IPv4 addresses are matching this rule).
"@
}


