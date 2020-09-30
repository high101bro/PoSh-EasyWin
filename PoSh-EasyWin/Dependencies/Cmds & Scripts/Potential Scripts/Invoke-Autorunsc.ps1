Invoke-Command -ComputerName $PSTargets -ScriptBlock ${Function:Invoke-Autorunsc} -ArgumentList $url

function Invoke-Autorunsc {
	[cmdletbinding()]
	Param([String] $url)
	# python -m SimpleHTTPServer 8080
	#$urla = $url + "autorunsc.exe"
	$path = "C:\blue_temp\autorunsc.exe"
	#(New-Object Net.WebClient).DownloadFile($urla, $path)
	$results = & $path -AcceptEULA -h -c -NoBanner -a * -s -t | ConvertFrom-Csv
	Remove-Item $path
	Remove-Item C:\blue_temp
	$results
}

