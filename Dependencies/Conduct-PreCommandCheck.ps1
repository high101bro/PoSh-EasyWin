function Conduct-PreCommandCheck {
    param(
        $CollectedDataTimeStampDirectory, 
        $IndividualHostResults, 
        $CollectionName, 
        $TargetComputer
    )
    # Removes the individual results
    Remove-Item -Path "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -Force -ErrorAction SilentlyContinue
    # Removes the compiled results
    Remove-Item -Path "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv" -Force -ErrorAction SilentlyContinue
    # Creates a directory to save compiled results
    New-Item -ItemType Directory -Path "$($IndividualHostResults)\$($CollectionName)" -Force -ErrorAction SilentlyContinue
}