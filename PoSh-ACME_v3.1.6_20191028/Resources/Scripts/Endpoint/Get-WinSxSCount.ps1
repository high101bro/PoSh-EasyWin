<# 
# WinSxS is short of 'Windows Side by Side'. The WinSxS feature is used by many applications to prevent problems that can arise due to updated and duplicated 
version of DLLs. DLL side-loading attack makes use of WinSxS directory. This is located in C:\Windows\WinSxS and 
holds multiple versions of DLLs. When an application uses this directory to retrieve DLL, then it needs to have 
a manifest. Manifest lists the DLL that can be used at run time by this application and is used by loaded to 
determine which version of DLL to use.
#>

[PSCustomObject]@{ 
    Name           = 'Windows Side by Side (Count)'
    PSComputerName = hostname
    FileCount      = $((Get-ChildItem -Path 'C:\Windows\WinSxS').count)
}