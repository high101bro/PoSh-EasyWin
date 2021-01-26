function Enable-WinRMPsExec {
	[cmdletbinding()]
	Param([String[]] $SMBTargets)
	$ChangedTargets = @()

	if ( -Not (Test-Path .\PsExec.exe)) {
		Write-Warning "You must have PsExec.exe in the current working directory to run this function!"
		continue
	}

	foreach ($i in $SMBTargets) {
		# Enable WinRM over PsExec
		Write-Verbose "Executing winrm quickconfig -q on $i with PsExec"
		$a = .\PsExec.exe \\$i -s winrm.cmd quickconfig -q 2>&1>$null
		if ( Test-WSMan $i -EA SilentlyContinue ) {
			Write-Verbose "Success enabling PSRemoting on $i with PsExec"
			$ChangedTargets += $i
		} else {
			Write-Warning "PsExec Failed!"
		}
	}
	return $ChangedTargets
}

