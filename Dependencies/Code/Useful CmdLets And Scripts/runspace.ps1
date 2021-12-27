param(
    $Param1,
    $Param2
)
$ParamList = @{
    Param1 = $Param1
    Param2 = $Param2
}

$PowerShell = [powershell]::Create()

[void]$PowerShell.AddScript({
    Param ($Param1, $Param2)
    [pscustomobject]@{
        Param1 = $Param1
        Param2 = $Param2
    }
}).AddParameters($ParamList)

#Invoke the command
$PowerShell.Invoke()