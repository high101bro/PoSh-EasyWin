<#
.Synopsis
    Monitor Directories for differences

.Parameter ComputerName
    Specify the computer(s) you want to query

.Parameter PathToMonitor
    The direcoty path to monitor

.Parameter Baseline
    The switch used to collect establish a baseline

.Parameter OutCsvFile
    Filename of output .csv

.Parameter Monitor
    The switch used to run a continous monitor

.Parameter ReferenceCsvFile
    The reference .csv file to monitor against

.Example
    Monitor-Directory -ComputerName Server1,Server2 -Baseline -Directory c:\Windows\System32

.Example
    Monitor-Directory -ComputerName Server1,Server2 -Monitor -Directory c:\Windows\System32


#>

param (
    
    [Parameter(
        Mandatory=$false
        )][string[]]$PathToMonitor,
    [Parameter(
        Mandatory=$false
        )][string[]]$ComputerName = "localhost",
    [Parameter(
        Mandatory=$false
        )][int]$SecondsBetweenComparison = 5,


    [Parameter(
        Mandatory=$true,
        ParameterSetName='Baseline'
        )][switch]$Baseline,
    [Parameter(
        Mandatory=$false,
        ParameterSetName='Baseline'
        )][string]$OutCsvName = '.\Monitor-Directory(Baseline).xml',


    [Parameter(
        Mandatory=$true,
        ParameterSetName='Monitor'
        )][switch]$Monitor,
    [Parameter(
        Mandatory=$false,
        ParameterSetName='Monitor'
        )][string]$ReferenceCsvFile = '.\Monitor-Directory(Baseline).xml'
)


<#
if ($Baseline) {
    Invoke-Command -Computername $ComputerName -ScriptBlock { 
        param($PathToMonitor)
        Get-ChildItem -Path $PathToMonitor -Force 
    } -ArgumentList $PathToMonitor `
    | Select-Object -Property PSComputerName, BaseName, FullName, CreationTime, LastAccessTime, LastWriteTime `
    | Sort-Object -Property Name `
    | Export-Clixml -Path $OutCsvName 
}
#>
if ($Monitor){
    $ReferenceObject = Invoke-Command -Computername $ComputerName -ScriptBlock { 
        param($PathToMonitor)
        Get-ChildItem -Path $PathToMonitor -Force 
    } -ArgumentList $PathToMonitor `
    | Select-Object -Property PSComputerName, BaseName, FullName, CreationTime, LastAccessTime, LastWriteTime `
    | Sort-Object -Property Name
    
    while ($true){

        $DifferenceObject = Invoke-Command -Computername $ComputerName -ScriptBlock { 
            param($PathToMonitor)
            Get-ChildItem -Path $PathToMonitor -Force 
        } -ArgumentList $PathToMonitor `
        | Select-Object -Property PSComputerName, BaseName, FullName, CreationTime, LastAccessTime, LastWriteTime `
        | Sort-Object -Property Name

        $NewItemList = @()
        ForEach ($RefItem in $ReferenceObject) {
            foreach ($DifItem in $DifferenceObject) {
                if (($RefItem.FullName -eq $DifItem.FullName) -and ($RefItem.LastWriteTime -ne $DifItem.LastWriteTime)) {
                    write-host "[$($DifItem.PScomputerName)] File Writen: $($DifItem.LastWriteTime) - $($DifItem.FullName)"
                }

                <#
                The NtfsDisableLastAccessUpdate registry setting is enabled by default in Windows 7. This was a performance tweak that many people used in earlier OSes because it prevents a lot of excessive writes to the hard drive.

                If you actually want the Last Access date updated the way it used to be, simply set the registry value to 0.

                For future reference in case the doc link stops working, the key is located in:

                HKLM\SYSTEM\CurrentControlSet\Control\FileSystem
                It's a REG_DWORD value called NtfsDisableLastAccessUpdate that can be set to 0 or 1.

                You can also use the following commands:
                # fsutil behavior query disablelastaccess
                   if value is 1, then lastaccess file update is disabled
                # fsutil behavior set disablelastaccess 0
                   enables lastaccesstime on files... reduces system performance
                # fsutil behavior set disablelastaccess 1
                   disables it
                #>
                #if (($RefItem.FullName -eq $DifItem.FullName) -and ($RefItem.LastAccessTime -ne $DifItem.LastAccessTime)) {
                #    write-host "[$($DifItem.PScomputerName)] File Accessed: $($DifItem.LastAccessTime) - $($DifItem.FullName)"
                #}
                

                if ($DifItem.FullName -notin $ReferenceObject.FullName) {
                    if ($DifItem.Fullname -notin $NewItemList) {
                        $NewItemList += $DifItem.FullName
                        write-host "[$($DifItem.PScomputerName)] New File: $($DifItem.CreationTime) - $($DifItem.FullName)"
                        #"{0,-10}{1,20}{2,30}{3,-30}" -f "[$($DifItem.PScomputerName)]", "New File:", "$($DifItem.CreationTime)", "$($DifItem.FullName)"
                    }
                }
            
            }
        }
        Start-Sleep -Seconds 5 #$SecondsBetweenComparison
        "`n===========================================================================================================================`n"
        #clear        
    }

}