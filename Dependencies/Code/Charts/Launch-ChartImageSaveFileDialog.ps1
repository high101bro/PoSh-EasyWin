Function Launch-ChartImageSaveFileDialog {
    #$FileTypes = [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')| ForEach { $_.Insert(0,'*.') }
    $SaveFileDlg = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDlg.FileName   =  "{0:yyyy-MM-dd @ HHmm.ss} - {1}" -f (Get-Date),"PoSh-EasyWin Chart"
    $SaveFileDlg.DefaultExt = 'PNG'
    #$SaveFileDlg.Filter = "Image Files ($($FileTypes)) | All Files (*.*)|*.*"
    $SaveFileDlg.filter = "PNG (*.png)|*.png|JPEG (*.jpeg)|*.jpeg|BMP (*.bmp)|*.bmp|GIF (*.gif)|*.gif|TIFF (*.tiff)|*.tiff|All files (*.*)|*.*"
    $return = $SaveFileDlg.ShowDialog()
    If ($Return -eq 'OK') {
        [pscustomobject]@{
            FileName  = $SaveFileDlg.FileName
            Extension = $SaveFileDlg.FileName -replace '.*\.(.*)','$1'
        }
    }
}


