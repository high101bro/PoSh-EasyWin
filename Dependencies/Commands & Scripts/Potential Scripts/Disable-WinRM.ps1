function Disable-WinRM {
	[cmdletbinding()]
	Param([String[]] $Targets)

	$VerbosePreference = "Continue"

	if ( -Not (Test-Path .\PsExec.exe)) {
		Write-Warning "You must have PsExec.exe in the current working directory to run this function!"
		Exit
	}

	foreach ($i in $Targets)
	{
		# Disable WinRM over PsExec
		Write-Verbose "Executing winrm delete listener on $i"
		.\PsExec.exe \\$i -s winrm.cmd delete winrm/config/Listener?Address=*+Transport=HTTP
		Write-Verbose "Executing sc stop winrm on $i"
		.\PsExec.exe \\$i -s sc stop winrm
		Write-Verbose "Executing sc config winrm start= disabled on $i"
		.\PsExec.exe \\$i -s sc config winrm start= disabled
	}
}

