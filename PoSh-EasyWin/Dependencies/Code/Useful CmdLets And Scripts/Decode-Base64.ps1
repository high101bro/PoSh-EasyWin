function Decode-Base64 {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'FileName')]
        $Filename,
        [Parameter(Mandatory = $true, ParameterSetName = 'String')]
        $String
    )

    if ($FileName){
        $Data = get-content $FileName
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
        $EncodedData = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Bytes))

        return $EncodedData
    }
    if ($String) {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
        $EncodedData = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Bytes))

        return $EncodedData
    }
}
# Decode-Base64 -String

