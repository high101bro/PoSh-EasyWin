Function Save-ChartImage {
    param($Chart,$Title)
    $MessageBox = [System.Windows.Forms.MessageBox]::Show("Do you want scale up (x2) the chart?`nThe chart will auto-optimize.","Save Chart",[System.Windows.Forms.MessageBoxButtons]::YesNo)	
     switch ($MessageBox){
        "Yes" {
            $Result = Launch-ChartImageSaveFileDialog

            If ($Result) { 
                $OriginalWidth  = $Chart.Size.Width
                $OriginalHeight = $Chart.Size.Height
                $Chart.Width  = $OriginalWidth * 2
                $Chart.Height = $OriginalHeight * 2
                $Title.Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','22', [System.Drawing.FontStyle]::Bold)

                $Chart.SaveImage($Result.FileName, $Result.Extension)
        
                $Chart.Width  = $OriginalWidth
                $Chart.Height = $OriginalHeight    
                $Title.Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)

            }        
        } 
        "No" { 
            $Result = Launch-ChartImageSaveFileDialog

            If ($Result) { 
                $Chart.SaveImage($Result.FileName, $Result.Extension)
            }
        } 
    }
}
