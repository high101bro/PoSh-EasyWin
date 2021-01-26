function Encode-Base64 {
    param($FileName)
    $Data = get-content $FileName
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Data)
    $EncodedData = [Convert]::ToBase64String($Bytes)
    return $EncodedData
}

#Encode-Base64 -FileName 'C:\image.png'


