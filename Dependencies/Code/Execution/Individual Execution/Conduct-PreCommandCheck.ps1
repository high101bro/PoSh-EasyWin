function Conduct-PreCommandCheck {
    param(
        $script:CollectedDataTimeStampDirectory,
        $CollectionName,
        $TargetComputer,
        $IndividualHostResults
    )
    # Removes the individual results
    Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -Force -ErrorAction SilentlyContinue
    # Removes the compiled results
    Remove-Item -Path "$($script:CollectedDataTimeStampDirectory)\$($CollectionName).csv" -Force -ErrorAction SilentlyContinue
    # Creates a directory to save compiled results
    New-Item -ItemType Directory -Path "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)" -Force -ErrorAction SilentlyContinue
}

