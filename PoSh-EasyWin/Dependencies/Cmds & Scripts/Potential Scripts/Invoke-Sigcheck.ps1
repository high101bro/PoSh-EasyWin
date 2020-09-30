Invoke-Command -ComputerName $PSTargets -ScriptBlock ${Function:Invoke-Sigcheck} -ArgumentList $url

# Ref: Matt Graeber https://specterops.io/assets/resources/SpecterOps_Subverting_Trust_in_Windows.pdf
function Invoke-Sigcheck {
	[cmdletbinding()]
	Param([String] $url)

	$verifyHashFunc = 'HKLM:\SOFTWARE\Microsoft\Cryptography\OID\EncodingType 0\CryptSIPDllVerifyIndirectData'
	$PowerShellSIPGuid = '{603BCC1F-4B59-4E08-B724-D2C6297EF351}'
	$PESIDPGuid = '{C689AAB8-8E78-11D0-8C47-00C04FC295EE}'

	if ((Get-ItemProperty -Path "$verifyHashFunc\$PowerShellSIPGuid\" -Name "FuncName").FuncName -ne "PsVerifyHash") {
		Write-Error "The System Signature Trust is Subverted!!!"
		Exit
	} elseif ((Get-ItemProperty -Path "$verifyHashFunc\$PowerShellSIPGuid\" -Name "Dll").Dll -ne "C:\Windows\System32\WindowsPowerShell\v1.0\pwrshsip.dll") {
		Write-Error "The System Signature Trust is Subverted!!!"
		Exit
	} elseif ((Get-ItemProperty -Path "$verifyHashFunc\$PESIDPGuid\" -Name "FuncName").FuncName -ne "CryptSIPVerifyIndirectData") {
		Write-Error "The System Signature Trust is Subverted!!!"
		Exit
	} elseif ((Get-ItemProperty -Path "$verifyHashFunc\$PESIDPGuid\" -Name "Dll").Dll -ne "C:\Windows\System32\WINTRUST.DLL" -AND (Get-ItemProperty -Path "$verifyHashFunc\$PESIDPGuid\" -Name "Dll").Dll -ne "WINTRUST.DLL") {
		Write-Error "The System Signature Trust is Subverted!!!"
		Exit
	}

	$urls = $url + "sigcheck.exe"
	$path = "C:\sigcheck.exe"
	(New-Object Net.WebClient).DownloadFile($urls, $path)
	$results = & $path -AcceptEULA -c -u -e -s -r -NoBanner C:\Windows\System32 | ConvertFrom-Csv
	$results += & $path -AcceptEULA -c -u -e -s -r -NoBanner C:\Windows\SysWOW64 | ConvertFrom-Csv
	$results
	Remove-Item $path
}

