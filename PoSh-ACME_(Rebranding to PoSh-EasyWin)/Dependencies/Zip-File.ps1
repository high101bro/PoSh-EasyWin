# Useful resources
# https://theposhwolf.com/howtos/PowerShell-and-Zip-Files/

function Zip-File {
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true,Position=1)]
        [string]$Destination,
        [Parameter(Mandatory=$false,Position=2)]
        [ValidateSet("Fastest","Optimal","NoCompression")]
        [string]$Compression = "Optimal",
        [Parameter(Mandatory=$false,Position=3)]
        [switch]$TimeStamp
    )
    function Select-CompressionLevel{
        #[Reflection.Assembly]::LoadFile('C:\WINDOWS\System32\zipfldr.dll')
        Add-Type -Assembly System.IO.Compression.FileSystem
        $CompressionToUse = $null
        switch($Compression) {
            "Fastest"       {$CompressionToUse = [System.IO.Compression.CompressionLevel]::Fastest}
            "Optimal"       {$CompressionToUse = [System.IO.Compression.CompressionLevel]::Optimal}
            "NoCompression" {$CompressionToUse = [System.IO.Compression.CompressionLevel]::NoCompression}
            #default {$CompressionToUse = [System.IO.Compression.CompressionLevel]::Fastest}
        }
        return $CompressionToUse
    }

    Write-Verbose "Starting zip process..."

    #If the target item is a directory, the directory will be directly compressed
    if ((Get-Item $Path).PSIsContainer){
        $Destination = ($Destination + "\" + (Split-Path $Path -Leaf) + ".zip")
        if (Test-Path -Path $Destination) { Remove-Item -Path $Destination -Force -Recurse }
    }
    #If the target item is not a directory, it will copy the item to c:\Windows\Temp
    else {
        $FileName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        $NewFolderName = "c:\Windows\Temp\tmp-" + $FileName

        New-Item -ItemType Directory -Path $NewFolderName -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $Path $NewFolderName

        $Path = $NewFolderName
        $Destination = $Destination + "\$FileName.zip"
        if (Test-Path -Path $Destination) { Remove-Item -Path $Destination -Force -Recurse }
    }    
    if ($TimeStamp) {
        $TimeInfo         = New-Object System.Globalization.DateTimeFormatInfo
        $CurrentTimestamp = Get-Date -Format $TimeInfo.SortableDateTimePattern
        $CurrentTimestamp = $CurrentTimestamp.Replace(":", "-")
        $Destination      = $Destination.Replace(".zip", ("-" + $CurrentTimestamp + ".zip"))
    }

    $CompressionLevel  = Select-CompressionLevel
    $IncludeBaseFolder = $false

    #[Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
    Add-Type -AssemblyName "System.IO.Compression.Filesystem"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Path, $Destination, $CompressionLevel, $IncludeBaseFolder)

    try {Remove-Item -Path $NewFolderName -Force -Recurse} catch{}

    Write-Verbose "Zip process complete."
}