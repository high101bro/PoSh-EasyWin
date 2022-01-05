
<# 
    .Synopsis 
    Returns info about the page file size of a Windows computer. Defaults to local machine. 

    .Description 
    Returns the pagefile size info in MB. Also returns the PageFilePath, PageFileTotalSize, PagefileCurrentUsage,
    and PageFilePeakusage. Also returns if computer is using a TempPafeFile and if the machine's pagefile is
    managed by O/S (AutoManaged = true) or statically set (AutoManaged = False)

    .Notes 
    NAME: Get-PageFileInfo 
    ORIGINAL AUTHOR: Mike Kanakos 
    MODIFIED BY: high101bro for compatibility with PoSh-EasyWin    
#> 

$PageFileResults = Get-CimInstance -Class Win32_PageFileUsage | Select-Object *
$CompSysResults = Get-CimInstance win32_computersystem -Namespace 'root\cimv2'

$PageFileStats = [PSCustomObject]@{
    FilePath              = $PageFileResults.Description
    AutoManagedPageFile   = $CompSysResults.AutomaticManagedPagefile
    "TotalSize(in MB)"    = $PageFileResults.AllocatedBaseSize
    "CurrentUsage(in MB)" = $PageFileResults.CurrentUsage
    "PeakUsage(in MB)"    = $PageFileResults.PeakUsage
    TempPageFileInUse     = $PageFileResults.TempPageFile
}
$PageFileStats 















