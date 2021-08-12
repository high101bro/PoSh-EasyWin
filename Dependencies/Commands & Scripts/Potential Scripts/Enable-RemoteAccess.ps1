function Enable-RemoteAccess {
	[cmdletbinding()]
	Param([String[]] $Targets)

	$VerbosePreference = "Continue"

	$SMBConfirmation = Read-Host "`n`nIf WinRM/PSRemoting is DISABLED, attempt to ENABLE with PsExec? [y/n]"
	$WMIConfirmation = Read-Host "`nIf WinRM/PSRemoting and SMB is DISABLED, attempt to ENABLE with WMI? [y/n]"

	$PSTargets = @()
	$SMBTargets = @()
	$WMITargets = @()
	$NoRemoteTargets = @()
	$SMBChangedTargets = @()
	$SMBFailedTargets = @()
	$WMIChangedTargets = @()
	$WMIFailedTargets = @()


	foreach ($i in $Targets) {
		Write-Verbose "Testing Remote Management Options for $i"
		if ( Test-WSMan $i -EA SilentlyContinue ) {
			Write-Verbose "PSRemoting Enabled on $i"
			$PSTargets += $i
		} elseif ( Test-Path \\$i\admin$ -EA SilentlyContinue ) {
			Write-Verbose "SMB Enabled on $i"
			$SMBTargets += $i
		} elseif ( Invoke-WmiMethod -class Win32_process -name Create -ArgumentList "CMD.EXE /c ipconfig" -ComputerName $i -EA SilentlyContinue ) {
			Write-Verbose "WMI Enabled on $i"
			$WMITargets += $i
		} else {
			Write-Verbose "NO REMOTING Enabled on $i"
			$NoRemoteTargets += $i
		}
	}

	Write-Host "`n========================================================================"
	Write-Host "Pre-Execution Report"
	Write-Host "`nPowerShell Remoting Targets:"
	Write-Host $PSTargets
	Write-Host "`nSMB/PsExec Remoting Targets:"
	Write-Host $SMBTargets
	Write-Host "`nWMI Remoting Targets:"
	Write-Host $WMITargets
	Write-Host "`nTargets with NO REMOTING Options:"
	Write-Host $NoRemoteTargets
	Write-Host "`n========================================================================`n"

	if (($SMBConfirmation -eq "y") -OR ($SMBConfirmation -eq "Y")) {
		Write-Host "You have elected to enable PSRemoting via PsExec."
	} else {
		Write-Host "You have elected NOT to enable PSRemoting via PsExec."
	}
	if (($WMIConfirmation -eq "y") -OR ($WMIConfirmation -eq "Y")) {
		Write-Host "You have elected to enable PSRemoting via WMI."
	} else {
		Write-Host "You have elected NOT to enable PSRemoting via WMI."
	}
	$ExecuteConfirmation = Read-Host "`nAre you sure you want to execute? [y/n]"

	if (($ExecuteConfirmation -eq "y") -OR ($ExecuteConfirmation -eq "Y")) {
		if (($SMBConfirmation -eq "y") -OR ($SMBConfirmation -eq "Y")) {
			Write-Verbose "Executing PsExec..."
			if ( -Not (Test-Path .\PsExec.exe)) {
				Write-Warning "You must have PsExec.exe in the current working directory to run this function!"
				continue
			}
			# Enable WinRM via PsExec
			$SMBChangedTargets = Enable-WinRMPsExec -SMBTargets $SMBTargets

			#Write-Verbose "`n`nValue of SMBChangedTargets: $SMBChangedTargets"

			# Determine which systems failed enabling PSRemoting via PsExec and store in variable SMBFailedTargets
			if ($SMBChangedTargets -ne $null) {
				$SMBFailedTargets = Compare-Object -ReferenceObject $SMBChangedTargets -DifferenceObject $SMBTargets -PassThru
			} else {
				$SMBFailedTargets = $SMBTargets
			}

			# If PsExec fails on systems and WMI is allowed by user, Attempt enable via WMI
			if (($SMBFailedTargets -ne $null) -AND (($WMIConfirmation -eq "y") -OR ($WMIConfirmation -eq "Y")) ) {
				Write-Verbose "Adding SMB Failed Targets to WMI Targets..."
				$WMITargets += $SMBFailedTargets
			}
		}
		if (($WMIConfirmation -eq "y") -OR ($WMIConfirmation -eq "Y")) {
			Write-Verbose "Executing WMI..."
			$WMIChangedTargets += Enable-WinRMWMI -WMITargets $WMITargets

			#Write-Verbose "`n`nValue of WMIChangedTargets: $WMIChangedTargets"

			# Determine which systems failed enabling PSRemoting via PsExec and store in variable WMIFailedTargets
			if ($WMIChangedTargets -ne $null) {
				$WMIFailedTargets = Compare-Object -ReferenceObject $WMIChangedTargets -DifferenceObject $WMITargets -PassThru
			} else {
				$WMIFailedTargets = $WMITargets
			}
		}
	} else {
		Write-Verbose "Exiting..."
		continue
	}

	Write-Host "`n========================================================================"
	Write-Host "Post-Execution Report"
	Write-Host "`nPowerShell Remoting Targets:"
	Write-Host $PSTargets
	Write-Host "`n`nSMB/PsExec Remoting Targets SUCCESS enabling PSRemoting:"
	Write-Host $SMBChangedTargets
	Write-Host "`nSMB/PsExec Remoting Targets FAILED enabling PSRemoting:"
	Write-Host $SMBFailedTargets
	Write-Host "`n`nWMI Remoting Targets SUCCESS enabling PSRemoting:"
	Write-Host $WMIChangedTargets
	Write-Host "`nWMI Remoting Targets FAILED enabling PSRemoting:"
	Write-Host $WMIFailedTargets
	Write-Host "`n`nTargets with NO REMOTING Options:"
	Write-Host $NoRemoteTargets
	$PSTargets += $SMBChangedTargets
	$PSTargets += $WMIChangedTargets
	Write-Host "`n`nFINAL Targets ready for PSRemoting:"
	Write-Host $PSTargets
	Write-Host "========================================================================`n"

	return $PSTargets
}

