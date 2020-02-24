<# 
.SYNOPSIS
Gets a count of WinSxS files.

.DESCRIPTION
WinSxS (or Windows SxS) is short of 'Windows Side by Side'. The WinSxS feature is used by many applications to attempt to alleviate problems that arise from the use of dynamic-link libraries (DLLs). Such problems include version conflicts, missing DLLs, duplicate DLLs, and incorrect or missing registration. Windows stores multiple versions of a DLL in C:\Windows\WinSxS and loads them on demany to reduce dependency problems for applications that include a side-by-side manifest.

DLL side-loading attack makes use of WinSxS directory. When an application uses this directory to retrieve DLL, it needs to have a manifest. This application manifest lists the DLL that can be used at run time by this application and is used to determine which version of DLL to use.
#>

[PSCustomObject]@{ 
    Name           = 'Windows Side by Side (Count)'
    PSComputerName = hostname
    FileCount      = $((Get-ChildItem -Path 'C:\Windows\WinSxS').count)
}