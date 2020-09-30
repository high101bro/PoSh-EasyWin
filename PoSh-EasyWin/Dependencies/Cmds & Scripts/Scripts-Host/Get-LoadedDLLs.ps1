	[cmdletbinding()]
	Param([bool] $NoHash = $false)
	$results = Get-Process | Select-Object -ExpandProperty Modules -ErrorAction SilentlyContinue | Sort-Object FileName -Unique | ForEach-Object {
		if ($_.FileName -ne $null -AND -NOT $NoHash) {
			$md5  = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
			$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($_.FileName)))
			$_ | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
		}
		else {
			$_ | Add-Member -MemberType NoteProperty MD5 $null
		}
		$_
	}
	$results | Select-Object -Property ModuleName,FileName,MD5,Size,Company,Description,FileVersion,Product,ProductVersion


