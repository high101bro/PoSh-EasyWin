# This function is created within a string variable as it is used with an an agrument for Invoke-Command
# It is initialized below with an Invoke-Expression
$GetChildItemDepth = @'
    Function Get-ChildItemDepth {
        Param(
            [String[]]$Path     = $PWD,
            [String]$Filter     = "*",
            [Byte]$Depth        = 255,
            [Byte]$CurrentDepth = 0
        )

        $CurrentDepth++
        Get-ChildItem $Path -Force | Foreach {
            $_ | Where-Object { $_.Name -Like $Filter }

            If ($_.PsIsContainer) {
                If ($CurrentDepth -le $Depth) {
                    # Callback to this function
                    Get-ChildItemDepth -Path $_.FullName -Filter $Filter -Depth $Depth -CurrentDepth $CurrentDepth

                }
            }
        }
    }
'@
Invoke-Expression -Command $GetChildItemDepth


