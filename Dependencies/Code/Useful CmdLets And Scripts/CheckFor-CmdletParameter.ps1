# This was originally writen because there are older cmdlets don't have support for new parameters like:
# Get-ChildItem -Depth 2
#
# This was used to check if the parameter exists and would run different code if it didn't

param(
    $Cmdlet,
    $Parameter
)
if ([bool]((Get-Command $Cmdlet).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match $Parameter)) {
    Write-Host -f Green 'Parameter Exists'
}
else {
    Write-Host -f Red 'Parameter does not Exists'
}

