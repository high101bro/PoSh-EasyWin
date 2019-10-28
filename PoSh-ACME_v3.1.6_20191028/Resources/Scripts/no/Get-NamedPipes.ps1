#[System.IO.Directory]::GetFiles("\\.\\pipe\\")
#Invoke-Command -ScriptBlock { $NamedPipes = [System.IO.Directory]::GetFiles("\\.\\pipe\\") ; $NamedPipes }
(Get-ChildItem \\.\\pipe\\ -Force).FullName 
#$pipeName = "powershell"
#[System.IO.Directory]::GetFiles("\\.\pipe\") | where { $_ -match $pipeName }
