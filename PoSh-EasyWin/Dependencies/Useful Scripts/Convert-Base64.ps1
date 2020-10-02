<#
    .Description
    Converts the input to base64
#>

param(
    $Encode,
    $Decode
)

if ($Encode -and $Decode) {
    Write-Output "Input Error: Use either -Encode or -Decode, but not both. "
}
elseif ($Encode) {
    [convert]::ToBase64String([system.text.encoding]::Unicode.GetBytes($Encode))
}
elseif ($Decode) {
    [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Decode))
}