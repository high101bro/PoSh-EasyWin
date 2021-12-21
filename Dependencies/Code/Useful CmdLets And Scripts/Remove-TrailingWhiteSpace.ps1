param(
    $FilePath = '.',
    [switch]$Save
)

if ($Save){
    $script:ReportName = "Statistics of Removing Trailing White Spaces.txt"
    "Overall Statistics After Processing" > ./$script:ReportName  
}

$Files = Get-ChildItem -Path $FilePath -Recurse

$OriginalTotal = 0
$TrimmedTotal = 0
$SpaceSavedTotal = 0

Foreach ($File in $Files) {
    $BufferStringOriginal = ""
    $BufferStringTrimmed = ""
    $JustTheFiles = $File | Where-Object {$_.PSIsContainer -eq $false -and $_.extension -eq '.ps1'}
    $JustTheFiles = $JustTheFiles.FullName | Where-Object {$_ -ne ''}    

    try {
        foreach($line in $(Get-Content -Path "$JustTheFiles")) {
            $BufferStringOriginal += "$($line)`n"
            $BufferStringTrimmed += "$($line.TrimEnd())`n"
        }

        $OriginalSize = [System.Text.Encoding]::UTF8.GetByteCount($BufferStringOriginal) / 1KB
        $OriginalTotal += $OriginalSize
        $OriginalSize = [Math]::Round($OriginalSize,2)


        $TrimmedSize = [System.Text.Encoding]::UTF8.GetByteCount($BufferStringTrimmed) / 1KB
        $TrimmedTotal += $TrimmedSize
        $TrimmedSize = [Math]::Round($TrimmedSize,2)

        $SpaceSaved = $OriginalSize - $TrimmedSize

        "===================================================================================================="
        "$($File.FullName)"
        $O = "{0,-10} : {1} KB" -f "Original",$OriginalSize
        $T = "{0,-10} : {1} KB" -f "Trimmed",$TrimmedSize
        $S = "{0,-10} : {1} KB" -f "Saved",$SpaceSaved
        Write-Host $O -ForegroundColor Red 
        Write-Host $T -ForegroundColor Green
        Write-Host $S -ForegroundColor Cyan
        Write-Host ""

        if ($Save) {
            # Saves Processed Individual Files
            $BufferStringTrimmed | Out-File -FilePath $File.FullName -Force

            # Updates the Report
            "====================================================================================================" >> ./$script:ReportName
            "$($File.FullName)" >> ./$script:ReportName  
            $O >> ./$script:ReportName  
            $T >> ./$script:ReportName  
            $S >> ./$script:ReportName  
        }
    }
    catch {
        continue
    }    
}

$SpaceSavedTotal += $OriginalTotal - $TrimmedTotal

"===================================================================================================="
"Overall Statistics After Processing"
$O = "{0,-10} : {1} KB" -f "Original",$OriginalTotal
$T = "{0,-10} : {1} KB" -f "Trimmed",$TrimmedTotal
$S = "{0,-10} : {1} KB" -f "Saved",$SpaceSavedTotal
Write-Host $O -ForegroundColor Red 
Write-Host $T -ForegroundColor Green
Write-Host $S -ForegroundColor Cyan
Write-Host ""

if ($Save) {
    # Updates the Report
    "====================================================================================================" >> ./$script:ReportName
    "Overall Statistics After Processing" >> ./$script:ReportName  
    $O >> ./$script:ReportName  
    $T >> ./$script:ReportName  
    $S >> ./$script:ReportName  
}

