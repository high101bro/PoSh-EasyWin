        if ($OptionTextToSpeachCheckBox.Checked -eq $true) {
            Add-Type -AssemblyName System.speech
            $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
            Start-Sleep -Seconds 1

            # TTS for Query Count
            if ($CountCommandQueries -eq 1) {$TTSQuerySingularPlural = "query"}
            else {$TTSQuerySingularPlural = "queries"}

            # TTS for TargetComputer Count
            if ($ComputerList.Count -eq 1) {$TTSTargetComputerSingularPlural = "host"}
            else {$TTSTargetComputerSingularPlural = "hosts"}
        
            # Say Message
            if (($CountCommandQueries -eq 0) -and ($CountComputerListCheckedBoxesSelected -eq 0)) {$speak.Speak("You need to select at least one query and target host.")}
            else {
                if ($CountCommandQueries -eq 0) {$speak.Speak("You need to select at least one query.")}
                if ($CountComputerListCheckedBoxesSelected -eq 0) {$speak.Speak("You need to select at least one target host.")}
                else {$speak.Speak("PoSh-ACME has completed $($CountCommandQueries) $($TTSQuerySingularPlural) against $($CountComputerListCheckedBoxesSelected) $($TTSTargetComputerSingularPlural).")}
            }        
        }