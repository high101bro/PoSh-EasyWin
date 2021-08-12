function Enable-WinRMWMI {
	[cmdletbinding()]
	Param([String[]] $WMITargets)
	$ChangedTargets = @()

	foreach ($i in $WMITargets) {
		# Enable WinRM over WMI
		Write-Verbose "Executing winrm quickconfig -q on $i with WMI"
		$a = Invoke-WmiMethod -class Win32_process -name Create -ArgumentList "CMD.EXE /c winrm quickconfig -q" -ComputerName $i -EnableAllPrivileges 2>&1>$null
		$a = Start-Sleep 3
		if ( Test-WSMan $i -EA SilentlyContinue ) {
			Write-Verbose "Success enabling PSRemoting on $i with WMI"
			$ChangedTargets += $i
		} else {
			Write-Warning "WMI Failed!"
		}
	}
	return $ChangedTargets
}

