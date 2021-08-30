function Compare-MultipleObjects { 
    [CmdLetBinding()]
    param([System.Collections.IList] $Objects,
        [switch] $CompareSorted,
        [switch] $FormatOutput,
        [switch] $FormatDifferences,
        [switch] $Summary,
        [string] $Splitter = ', ',
        [string[]] $Property,
        [string[]] $ExcludeProperty,
        [switch] $AllProperties,
        [switch] $SkipProperties,
        [int] $First,
        [int] $Last,
        [Array] $Replace)
    if ($null -eq $Objects -or $Objects.Count -eq 1) {
        Write-Warning "Compare-MultipleObjects - Unable to compare objects. Not enough objects to compare ($($Objects.Count))."
        return
    }
    function Compare-TwoArrays {
        [CmdLetBinding()]
        param([string] $FieldName,
            [Array] $Object1,
            [Array] $Object2,
            [Array] $Replace)
        $Result = [ordered] @{Status = $false
            Same                     = [System.Collections.Generic.List[string]]::new()
            Add                      = [System.Collections.Generic.List[string]]::new()
            Remove                   = [System.Collections.Generic.List[string]]::new()
        }
        if ($Replace) {
            foreach ($R in $Replace) {
                if (($($R.Keys[0]) -eq '') -or ($($R.Keys[0]) -eq $FieldName)) {
                    if ($null -ne $Object1) { $Object1 = $Object1 -replace $($R.Values)[0], $($R.Values)[1] }
                    if ($null -ne $Object2) { $Object2 = $Object2 -replace $($R.Values)[0], $($R.Values)[1] }
                }
            }
        }
        if ($null -eq $Object1 -and $null -eq $Object2) { $Result['Status'] = $true } elseif (($null -eq $Object1) -or ($null -eq $Object2)) {
            $Result['Status'] = $false
            foreach ($O in $Object1) { $Result['Add'].Add($O) }
            foreach ($O in $Object2) { $Result['Remove'].Add($O) }
        } else {
            $ComparedObject = Compare-Object -ReferenceObject $Object1 -DifferenceObject $Object2 -IncludeEqual
            foreach ($_ in $ComparedObject) { if ($_.SideIndicator -eq '==') { $Result['Same'].Add($_.InputObject) } elseif (($_.SideIndicator -eq '<=')) { $Result['Add'].Add($_.InputObject) } elseif (($_.SideIndicator -eq '=>')) { $Result['Remove'].Add($_.InputObject) } }
            IF ($Result['Add'].Count -eq 0 -and $Result['Remove'].Count -eq 0) { $Result['Status'] = $true } else { $Result['Status'] = $false }
        }
        $Result
    }
    if ($First -or $Last) {
        [int] $TotalCount = $First + $Last
        if ($TotalCount -gt 1) { $Objects = $Objects | Select-Object -First $First -Last $Last } else {
            Write-Warning "Compare-MultipleObjects - Unable to compare objects. Not enough objects to compare ($TotalCount)."
            return
        }
    }
    $ReturnValues = @($FirstElement = [ordered] @{}
        $FirstElement['Name'] = 'Properties'
        if ($Summary) {
            $FirstElement['Same'] = $null
            $FirstElement['Different'] = $null
        }
        $FirstElement['Status'] = $false
        $FirstObjectProperties = Select-Properties -Objects $Objects -Property $Property -ExcludeProperty $ExcludeProperty -AllProperties:$AllProperties
        if (-not $SkipProperties) {
            if ($FormatOutput) { $FirstElement["Source"] = $FirstObjectProperties -join $Splitter } else { $FirstElement["Source"] = $FirstObjectProperties }
            [Array] $IsSame = for ($i = 1; $i -lt $Objects.Count; $i++) {
                if ($Objects[0] -is [System.Collections.IDictionary]) { [string[]] $CompareObjectProperties = $Objects[$i].Keys } else {
                    [string[]] $CompareObjectProperties = $Objects[$i].PSObject.Properties.Name
                    [string[]] $CompareObjectProperties = Select-Properties -Objects $Objects[$i] -Property $Property -ExcludeProperty $ExcludeProperty -AllProperties:$AllProperties
                }
                if ($FormatOutput) { $FirstElement["$i"] = $CompareObjectProperties -join $Splitter } else { $FirstElement["$i"] = $CompareObjectProperties }
                if ($CompareSorted) {
                    $Value1 = $FirstObjectProperties | Sort-Object
                    $Value2 = $CompareObjectProperties | Sort-Object
                } else {
                    $Value1 = $FirstObjectProperties
                    $Value2 = $CompareObjectProperties
                }
                $Status = Compare-TwoArrays -FieldName 'Properties' -Object1 $Value1 -Object2 $Value2 -Replace $Replace
                if ($FormatDifferences) {
                    $FirstElement["$i-Add"] = $Status['Add'] -join $Splitter
                    $FirstElement["$i-Remove"] = $Status['Remove'] -join $Splitter
                    $FirstElement["$i-Same"] = $Status['Same'] -join $Splitter
                } else {
                    $FirstElement["$i-Add"] = $Status['Add']
                    $FirstElement["$i-Remove"] = $Status['Remove']
                    $FirstElement["$i-Same"] = $Status['Same']
                }
                $Status
            }
            if ($IsSame.Status -notcontains $false) { $FirstElement['Status'] = $true } else { $FirstElement['Status'] = $false }
            if ($Summary) {
                [Array] $Collection = (0..($IsSame.Count - 1)).Where( { $IsSame[$_].Status -eq $true }, 'Split')
                if ($FormatDifferences) {
                    $FirstElement['Same'] = ($Collection[0] | ForEach-Object { $_ + 1 }) -join $Splitter
                    $FirstElement['Different'] = ($Collection[1] | ForEach-Object { $_ + 1 }) -join $Splitter
                } else {
                    $FirstElement['Same'] = $Collection[0] | ForEach-Object { $_ + 1 }
                    $FirstElement['Different'] = $Collection[1] | ForEach-Object { $_ + 1 }
                }
            }
            [PSCustomObject] $FirstElement
        }
        foreach ($_ in $FirstObjectProperties) {
            $EveryOtherElement = [ordered] @{}
            $EveryOtherElement['Name'] = $_
            if ($Summary) {
                $EveryOtherElement['Same'] = $null
                $EveryOtherElement['Different'] = $null
            }
            $EveryOtherElement.Status = $false
            if ($FormatOutput) { $EveryOtherElement['Source'] = $Objects[0].$_ -join $Splitter } else { $EveryOtherElement['Source'] = $Objects[0].$_ }
            [Array] $IsSame = for ($i = 1; $i -lt $Objects.Count; $i++) {
                if ($FormatOutput) { $EveryOtherElement["$i"] = $Objects[$i].$_ -join $Splitter } else { $EveryOtherElement["$i"] = $Objects[$i].$_ }
                if ($CompareSorted) {
                    $Value1 = $Objects[0].$_ | Sort-Object
                    $Value2 = $Objects[$i].$_ | Sort-Object
                } else {
                    $Value1 = $Objects[0].$_
                    $Value2 = $Objects[$i].$_
                }
                $Status = Compare-TwoArrays -FieldName $_ -Object1 $Value1 -Object2 $Value2 -Replace $Replace
                if ($FormatDifferences) {
                    $EveryOtherElement["$i-Add"] = $Status['Add'] -join $Splitter
                    $EveryOtherElement["$i-Remove"] = $Status['Remove'] -join $Splitter
                    $EveryOtherElement["$i-Same"] = $Status['Same'] -join $Splitter
                } else {
                    $EveryOtherElement["$i-Add"] = $Status['Add']
                    $EveryOtherElement["$i-Remove"] = $Status['Remove']
                    $EveryOtherElement["$i-Same"] = $Status['Same']
                }
                $Status
            }
            if ($IsSame.Status -notcontains $false) { $EveryOtherElement['Status'] = $true } else { $EveryOtherElement['Status'] = $false }
            if ($Summary) {
                [Array] $Collection = (0..($IsSame.Count - 1)).Where( { $IsSame[$_].Status -eq $true }, 'Split')
                if ($FormatDifferences) {
                    $EveryOtherElement['Same'] = ($Collection[0] | ForEach-Object { $_ + 1 }) -join $Splitter
                    $EveryOtherElement['Different'] = ($Collection[1] | ForEach-Object { $_ + 1 }) -join $Splitter
                } else {
                    $EveryOtherElement['Same'] = $Collection[0] | ForEach-Object { $_ + 1 }
                    $EveryOtherElement['Different'] = $Collection[1] | ForEach-Object { $_ + 1 }
                }
            }
            [PSCuStomObject] $EveryOtherElement
        })
    if ($ReturnValues.Count -eq 1) { return , $ReturnValues } else { return $ReturnValues }
}
function ConvertFrom-Color { 
    [alias('Convert-FromColor')]
    [CmdletBinding()]
    param ([ValidateScript( { if ($($_ -in $Script:RGBColors.Keys -or $_ -match "^#([A-Fa-f0-9]{6})$" -or $_ -eq "") -eq $false) { throw "The Input value is not a valid colorname nor an valid color hex code." } else { $true } })]
        [alias('Colors')][string[]] $Color,
        [switch] $AsDecimal,
        [switch] $AsDrawingColor)
    $Colors = foreach ($C in $Color) {
        $Value = $Script:RGBColors."$C"
        if ($C -match "^#([A-Fa-f0-9]{6})$") {
            $C
            continue
        }
        if ($null -eq $Value) { continue }
        $HexValue = Convert-Color -RGB $Value
        Write-Verbose "Convert-FromColor - Color Name: $C Value: $Value HexValue: $HexValue"
        if ($AsDecimal) { [Convert]::ToInt64($HexValue, 16) } elseif ($AsDrawingColor) { [System.Drawing.Color]::FromArgb("#$($HexValue)") } else { "#$($HexValue)" }
    }
    $Colors
}
function ConvertTo-JsonLiteral { 
    <#
    .SYNOPSIS
    Converts an object to a JSON-formatted string.

    .DESCRIPTION
    The ConvertTo-Json cmdlet converts any object to a string in JavaScript Object Notation (JSON) format. The properties are converted to field names, the field values are converted to property values, and the methods are removed.

    .PARAMETER Object
    Specifies the objects to convert to JSON format. Enter a variable that contains the objects, or type a command or expression that gets the objects. You can also pipe an object to ConvertTo-JsonLiteral

    .PARAMETER Depth
    Specifies how many levels of contained objects are included in the JSON representation. The default value is 0.

    .PARAMETER AsArray
    Outputs the object in array brackets, even if the input is a single object.

    .PARAMETER DateTimeFormat
    Changes DateTime string format. Default "yyyy-MM-dd HH:mm:ss"

    .PARAMETER NumberAsString
    Provides an alternative serialization option that converts all numbers to their string representation.

    .PARAMETER BoolAsString
    Provides an alternative serialization option that converts all bool to their string representation.

    .PARAMETER PropertyName
    Uses PropertyNames provided by user (only works with Force)

    .PARAMETER NewLineFormat
    Provides a way to configure how new lines are converted for property names

    .PARAMETER NewLineFormatProperty
    Provides a way to configure how new lines are converted for values

    .PARAMETER PropertyName
    Allows passing property names to be used for custom objects (hashtables and alike are unaffected)

    .PARAMETER ArrayJoin
    Forces any array to be a string regardless of depth level

    .PARAMETER ArrayJoinString
    Uses defined string or char for array join. By default it uses comma with a space when used.

    .PARAMETER Force
    Forces using property names from first object or given thru PropertyName parameter

    .EXAMPLE
    Get-Process | Select-Object -First 2 | ConvertTo-JsonLiteral

    .EXAMPLE
    Get-Process | Select-Object -First 2 | ConvertTo-JsonLiteral -Depth 3

    .EXAMPLE
    Get-Process | Select-Object -First 2 | ConvertTo-JsonLiteral -NewLineFormat $NewLineFormat = @{
        NewLineCarriage = '\r\n'
        NewLine         = "\n"
        Carriage        = "\r"
    } -NumberAsString -BoolAsString

    .EXAMPLE
    Get-Process | Select-Object -First 2 | ConvertTo-JsonLiteral -NumberAsString -BoolAsString -DateTimeFormat "yyyy-MM-dd HH:mm:ss"

    .EXAMPLE
    # Keep in mind this advanced replace will break ConvertFrom-Json, but it's sometimes useful for projects like PSWriteHTML
    Get-Process | Select-Object -First 2 | ConvertTo-JsonLiteral -NewLineFormat $NewLineFormat = @{
        NewLineCarriage = '\r\n'
        NewLine         = "\n"
        Carriage        = "\r"
    } -NumberAsString -BoolAsString -AdvancedReplace @{ '.' = '\.'; '$' = '\$' }

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param([alias('InputObject')][Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, Mandatory)][Array] $Object,
        [int] $Depth,
        [switch] $AsArray,
        [string] $DateTimeFormat = "yyyy-MM-dd HH:mm:ss",
        [switch] $NumberAsString,
        [switch] $BoolAsString,
        [System.Collections.IDictionary] $NewLineFormat = @{NewLineCarriage = '\r\n'
            NewLine                                                         = "\n"
            Carriage                                                        = "\r"
        },
        [System.Collections.IDictionary] $NewLineFormatProperty = @{NewLineCarriage = '\r\n'
            NewLine                                                                 = "\n"
            Carriage                                                                = "\r"
        },
        [System.Collections.IDictionary] $AdvancedReplace,
        [string] $ArrayJoinString,
        [switch] $ArrayJoin,
        [string[]]$PropertyName,
        [switch] $Force)
    Begin {
        $TextBuilder = [System.Text.StringBuilder]::new()
        $CountObjects = 0
        filter IsNumeric() { return $_ -is [byte] -or $_ -is [int16] -or $_ -is [int32] -or $_ -is [int64] -or $_ -is [sbyte] -or $_ -is [uint16] -or $_ -is [uint32] -or $_ -is [uint64] -or $_ -is [float] -or $_ -is [double] -or $_ -is [decimal] }
        filter IsOfType() { return $_ -is [bool] -or $_ -is [char] -or $_ -is [datetime] -or $_ -is [string] -or $_ -is [timespan] -or $_ -is [URI] -or $_ -is [byte] -or $_ -is [int16] -or $_ -is [int32] -or $_ -is [int64] -or $_ -is [sbyte] -or $_ -is [uint16] -or $_ -is [uint32] -or $_ -is [uint64] -or $_ -is [float] -or $_ -is [double] -or $_ -is [decimal] }
        [int] $MaxDepth = $Depth
        [int] $InitialDepth = 0
    }
    Process {
        for ($a = 0; $a -lt $Object.Count; $a++) {
            $CountObjects++
            if ($CountObjects -gt 1) { $null = $TextBuilder.Append(',') }
            if ($Object[$a] -is [System.Collections.IDictionary]) {
                $null = $TextBuilder.AppendLine("{")
                for ($i = 0; $i -lt ($Object[$a].Keys).Count; $i++) {
                    $Property = ([string[]]$Object[$a].Keys)[$i]
                    $DisplayProperty = $Property.Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormatProperty.NewLineCarriage).Replace("`n", $NewLineFormatProperty.NewLine).Replace("`r", $NewLineFormatProperty.Carriage)
                    $null = $TextBuilder.Append("`"$DisplayProperty`":")
                    $Value = ConvertTo-StringByType -Value $Object[$a][$Property] -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $InitialDepth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -NewLineFormat $NewLineFormat -NewLineFormatProperty $NewLineFormatProperty -Force:$Force -ArrayJoin:$ArrayJoin -ArrayJoinString $ArrayJoinString -AdvancedReplace $AdvancedReplace
                    $null = $TextBuilder.Append("$Value")
                    if ($i -ne ($Object[$a].Keys).Count - 1) { $null = $TextBuilder.AppendLine(',') }
                }
                $null = $TextBuilder.Append("}")
            } elseif ($Object[$a] | IsOfType) {
                $Value = ConvertTo-StringByType -Value $Object[$a] -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $InitialDepth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -NewLineFormat $NewLineFormat -NewLineFormatProperty $NewLineFormatProperty -Force:$Force -ArrayJoin:$ArrayJoin -ArrayJoinString $ArrayJoinString -AdvancedReplace $AdvancedReplace
                $null = $TextBuilder.Append($Value)
            } else {
                $null = $TextBuilder.AppendLine("{")
                if ($Force -and -not $PropertyName) { $PropertyName = $Object[0].PSObject.Properties.Name } elseif ($Force -and $PropertyName) {} else { $PropertyName = $Object[$a].PSObject.Properties.Name }
                $PropertyCount = 0
                foreach ($Property in $PropertyName) {
                    $PropertyCount++
                    $DisplayProperty = $Property.Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormatProperty.NewLineCarriage).Replace("`n", $NewLineFormatProperty.NewLine).Replace("`r", $NewLineFormatProperty.Carriage)
                    $null = $TextBuilder.Append("`"$DisplayProperty`":")
                    $Value = ConvertTo-StringByType -Value $Object[$a].$Property -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $InitialDepth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -NewLineFormat $NewLineFormat -NewLineFormatProperty $NewLineFormatProperty -Force:$Force -ArrayJoin:$ArrayJoin -ArrayJoinString $ArrayJoinString -AdvancedReplace $AdvancedReplace
                    $null = $TextBuilder.Append("$Value")
                    if ($PropertyCount -ne $PropertyName.Count) { $null = $TextBuilder.AppendLine(',') }
                }
                $null = $TextBuilder.Append("}")
            }
            $InitialDepth = 0
        }
    }
    End { if ($CountObjects -gt 1 -or $AsArray) { "[$($TextBuilder.ToString())]" } else { $TextBuilder.ToString() } }
}
function Copy-Dictionary { 
    [alias('Copy-Hashtable', 'Copy-OrderedHashtable')]
    [cmdletbinding()]
    param([System.Collections.IDictionary] $Dictionary)
    $ms = [System.IO.MemoryStream]::new()
    $bf = [System.Runtime.Serialization.Formatters.Binary.BinaryFormatter]::new()
    $bf.Serialize($ms, $Dictionary)
    $ms.Position = 0
    $clone = $bf.Deserialize($ms)
    $ms.Close()
    $clone
}
function Format-TransposeTable { 
    [CmdletBinding()]
    param ([Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][System.Collections.ICollection] $Object,
        [ValidateSet("ASC", "DESC", "NONE")][String] $Sort = 'NONE')
    process {
        foreach ($myObject in $Object) {
            if ($myObject -is [System.Collections.IDictionary]) { if ($Sort -eq 'ASC') { [PSCustomObject] $myObject.GetEnumerator() | Sort-Object -Property Name -Descending:$false } elseif ($Sort -eq 'DESC') { [PSCustomObject] $myObject.GetEnumerator() | Sort-Object -Property Name -Descending:$true } else { [PSCustomObject] $myObject } } else {
                $Output = [ordered] @{}
                if ($Sort -eq 'ASC') { $myObject.PSObject.Properties | Sort-Object -Property Name -Descending:$false | ForEach-Object { $Output["$($_.Name)"] = $_.Value } } elseif ($Sort -eq 'DESC') { $myObject.PSObject.Properties | Sort-Object -Property Name -Descending:$true | ForEach-Object { $Output["$($_.Name)"] = $_.Value } } else { $myObject.PSObject.Properties | ForEach-Object { $Output["$($_.Name)"] = $_.Value } }
                $Output
            }
        }
    }
}
function Get-FileName { 
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Extension
    Parameter description

    .PARAMETER Temporary
    Parameter description

    .PARAMETER TemporaryFileOnly
    Parameter description

    .EXAMPLE
    Get-FileName -Temporary
    Output: 3ymsxvav.tmp

    .EXAMPLE

    Get-FileName -Temporary
    Output: C:\Users\pklys\AppData\Local\Temp\tmpD74C.tmp

    .EXAMPLE

    Get-FileName -Temporary -Extension 'xlsx'
    Output: C:\Users\pklys\AppData\Local\Temp\tmp45B6.xlsx


    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param([string] $Extension = 'tmp',
        [switch] $Temporary,
        [switch] $TemporaryFileOnly)
    if ($Temporary) { return "$($([System.IO.Path]::GetTempFileName()).Replace('.tmp','')).$Extension" }
    if ($TemporaryFileOnly) { return "$($([System.IO.Path]::GetRandomFileName()).Split('.')[0]).$Extension" }
}
function Get-RandomStringName { 
    [cmdletbinding()]
    param([int] $Size = 31,
        [switch] $ToLower,
        [switch] $ToUpper,
        [switch] $LettersOnly)
    [string] $MyValue = @(if ($LettersOnly) { ( -join ((1..$Size) | ForEach-Object { (65..90) + (97..122) | Get-Random } | ForEach-Object { [char]$_ })) } else { ( -join ((48..57) + (97..122) | Get-Random -Count $Size | ForEach-Object { [char]$_ })) })
    if ($ToLower) { return $MyValue.ToLower() }
    if ($ToUpper) { return $MyValue.ToUpper() }
    return $MyValue
}
function Get-TemporaryDirectory { 
    param()
    $TemporaryFolder = Get-RandomStringName -Size 13 -LettersOnly -ToLower
    $TemporaryPath = [system.io.path]::GetTempPath()
    $Output = New-Item -ItemType Directory -Path $TemporaryPath -Name $TemporaryFolder -Force
    if (Test-Path -LiteralPath $Output.FullName) { $Output }
}
function Remove-EmptyValue { 
    [alias('Remove-EmptyValues')]
    [CmdletBinding()]
    param([alias('Splat', 'IDictionary')][Parameter(Mandatory)][System.Collections.IDictionary] $Hashtable,
        [string[]] $ExcludeParameter,
        [switch] $Recursive,
        [int] $Rerun)
    foreach ($Key in [string[]] $Hashtable.Keys) { if ($Key -notin $ExcludeParameter) { if ($Recursive) { if ($Hashtable[$Key] -is [System.Collections.IDictionary]) { if ($Hashtable[$Key].Count -eq 0) { $Hashtable.Remove($Key) } else { Remove-EmptyValue -Hashtable $Hashtable[$Key] -Recursive:$Recursive } } else { if ($null -eq $Hashtable[$Key] -or ($Hashtable[$Key] -is [string] -and $Hashtable[$Key] -eq '') -or ($Hashtable[$Key] -is [System.Collections.IList] -and $Hashtable[$Key].Count -eq 0)) { $Hashtable.Remove($Key) } } } else { if ($null -eq $Hashtable[$Key] -or ($Hashtable[$Key] -is [string] -and $Hashtable[$Key] -eq '') -or ($Hashtable[$Key] -is [System.Collections.IList] -and $Hashtable[$Key].Count -eq 0)) { $Hashtable.Remove($Key) } } } }
    if ($Rerun) { for ($i = 0; $i -lt $Rerun; $i++) { Remove-EmptyValue -Hashtable $Hashtable -Recursive:$Recursive } }
}
function Select-Properties { 
    <#
    .SYNOPSIS
    Allows for easy selecting property names from one or multiple objects

    .DESCRIPTION
    Allows for easy selecting property names from one or multiple objects. This is especially useful with using AllProperties parameter where we want to make sure to get all properties from all objects.

    .PARAMETER Objects
    One or more objects

    .PARAMETER Property
    Properties to include

    .PARAMETER ExcludeProperty
    Properties to exclude

    .PARAMETER AllProperties
    All unique properties from all objects

    .PARAMETER PropertyNameReplacement
    Default property name when object has no properties

    .EXAMPLE
    $Object1 = [PSCustomobject] @{
        Name1 = '1'
        Name2 = '3'
        Name3 = '5'
    }
    $Object2 = [PSCustomobject] @{
        Name4 = '2'
        Name5 = '6'
        Name6 = '7'
    }

    Select-Properties -Objects $Object1, $Object2 -AllProperties

    #OR:

    $Object1, $Object2 | Select-Properties -AllProperties -ExcludeProperty Name6 -Property Name3

    .EXAMPLE
    $Object3 = [Ordered] @{
        Name1 = '1'
        Name2 = '3'
        Name3 = '5'
    }
    $Object4 = [Ordered] @{
        Name4 = '2'
        Name5 = '6'
        Name6 = '7'
    }

    Select-Properties -Objects $Object3, $Object4 -AllProperties

    $Object3, $Object4 | Select-Properties -AllProperties

    .NOTES
    General notes
    #>
    [CmdLetBinding()]
    param([Array][Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)] $Objects,
        [string[]] $Property,
        [string[]] $ExcludeProperty,
        [switch] $AllProperties,
        [string] $PropertyNameReplacement = '*')
    Begin {
        function Select-Unique {
            [CmdLetBinding()]
            param([System.Collections.IList] $Object)
            $New = $Object.ToLower() | Select-Object -Unique
            $Selected = foreach ($_ in $New) {
                $Index = $Object.ToLower().IndexOf($_)
                if ($Index -ne -1) { $Object[$Index] }
            }
            $Selected
        }
        $ObjectsList = [System.Collections.Generic.List[Object]]::new()
    }
    Process { foreach ($Object in $Objects) { $ObjectsList.Add($Object) } }
    End {
        if ($ObjectsList.Count -eq 0) {
            Write-Warning 'Select-Properties - Unable to process. Objects count equals 0.'
            return
        }
        if ($ObjectsList[0] -is [System.Collections.IDictionary]) {
            if ($AllProperties) {
                [Array] $All = foreach ($_ in $ObjectsList) { $_.Keys }
                $FirstObjectProperties = Select-Unique -Object $All
            } else { $FirstObjectProperties = $ObjectsList[0].Keys }
            if ($Property.Count -gt 0 -and $ExcludeProperty.Count -gt 0) {
                $FirstObjectProperties = foreach ($_ in $FirstObjectProperties) {
                    if ($Property -contains $_ -and $ExcludeProperty -notcontains $_) {
                        $_
                        continue
                    }
                }
            } elseif ($Property.Count -gt 0) {
                $FirstObjectProperties = foreach ($_ in $FirstObjectProperties) {
                    if ($Property -contains $_) {
                        $_
                        continue
                    }
                }
            } elseif ($ExcludeProperty.Count -gt 0) {
                $FirstObjectProperties = foreach ($_ in $FirstObjectProperties) {
                    if ($ExcludeProperty -notcontains $_) {
                        $_
                        continue
                    }
                }
            }
        } elseif ($ObjectsList[0].GetType().Name -match 'bool|byte|char|datetime|decimal|double|ExcelHyperLink|float|int|long|sbyte|short|string|timespan|uint|ulong|URI|ushort') { $FirstObjectProperties = $PropertyNameReplacement } else {
            if ($Property.Count -gt 0 -and $ExcludeProperty.Count -gt 0) { $ObjectsList = $ObjectsList | Select-Object -Property $Property -ExcludeProperty $ExcludeProperty } elseif ($Property.Count -gt 0) { $ObjectsList = $ObjectsList | Select-Object -Property $Property } elseif ($ExcludeProperty.Count -gt 0) { $ObjectsList = $ObjectsList | Select-Object -Property '*' -ExcludeProperty $ExcludeProperty }
            if ($AllProperties) {
                [Array] $All = foreach ($_ in $ObjectsList) { $_.PSObject.Properties.Name }
                $FirstObjectProperties = Select-Unique -Object $All
            } else { $FirstObjectProperties = $ObjectsList[0].PSObject.Properties.Name }
        }
        $FirstObjectProperties
    }
}
function Send-Email { 
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ([alias('EmailParameters')][System.Collections.IDictionary] $Email,
        [string] $Body,
        [string[]] $Attachment,
        [System.Collections.IDictionary] $InlineAttachments,
        [string] $Subject,
        [string[]] $To,
        [PSCustomObject] $Logger)
    try {
        if ($Email.EmailTo) {
            $EmailParameters = $Email.Clone()
            $EmailParameters.EmailEncoding = $EmailParameters.EmailEncoding -replace "-", ''
            $EmailParameters.EmailEncodingSubject = $EmailParameters.EmailEncodingSubject -replace "-", ''
            $EmailParameters.EmailEncodingBody = $EmailParameters.EmailEncodingSubject -replace "-", ''
            $EmailParameters.EmailEncodingAlternateView = $EmailParameters.EmailEncodingAlternateView -replace "-", ''
        } else {
            $EmailParameters = @{EmailFrom  = $Email.From
                EmailTo                     = $Email.To
                EmailCC                     = $Email.CC
                EmailBCC                    = $Email.BCC
                EmailReplyTo                = $Email.ReplyTo
                EmailServer                 = $Email.Server
                EmailServerPassword         = $Email.Password
                EmailServerPasswordAsSecure = $Email.PasswordAsSecure
                EmailServerPasswordFromFile = $Email.PasswordFromFile
                EmailServerPort             = $Email.Port
                EmailServerLogin            = $Email.Login
                EmailServerEnableSSL        = $Email.EnableSsl
                EmailEncoding               = $Email.Encoding -replace "-", ''
                EmailEncodingSubject        = $Email.EncodingSubject -replace "-", ''
                EmailEncodingBody           = $Email.EncodingBody -replace "-", ''
                EmailEncodingAlternateView  = $Email.EncodingAlternateView -replace "-", ''
                EmailSubject                = $Email.Subject
                EmailPriority               = $Email.Priority
                EmailDeliveryNotifications  = $Email.DeliveryNotifications
                EmailUseDefaultCredentials  = $Email.UseDefaultCredentials
            }
        }
    } catch {
        return @{Status = $False
            Error       = $($_.Exception.Message)
            SentTo      = ''
        }
    }
    $SmtpClient = [System.Net.Mail.SmtpClient]::new()
    if ($EmailParameters.EmailServer) { $SmtpClient.Host = $EmailParameters.EmailServer } else {
        return @{Status = $False
            Error       = "Email Server Host is not set."
            SentTo      = ''
        }
    }
    if ($EmailParameters.EmailServerPort) { $SmtpClient.Port = $EmailParameters.EmailServerPort } else {
        return @{Status = $False
            Error       = "Email Server Port is not set."
            SentTo      = ''
        }
    }
    if ($EmailParameters.EmailServerLogin) {
        $Credentials = Request-Credentials -UserName $EmailParameters.EmailServerLogin -Password $EmailParameters.EmailServerPassword -AsSecure:$EmailParameters.EmailServerPasswordAsSecure -FromFile:$EmailParameters.EmailServerPasswordFromFile -NetworkCredentials
        $SmtpClient.Credentials = $Credentials
    }
    if ($EmailParameters.EmailServerEnableSSL) { $SmtpClient.EnableSsl = $EmailParameters.EmailServerEnableSSL }
    $MailMessage = [System.Net.Mail.MailMessage]::new()
    $MailMessage.From = $EmailParameters.EmailFrom
    if ($To) { foreach ($T in $To) { $MailMessage.To.add($($T)) } } else { if ($EmailParameters.Emailto) { foreach ($To in $EmailParameters.Emailto) { $MailMessage.To.add($($To)) } } }
    if ($EmailParameters.EmailCC) { foreach ($CC in $EmailParameters.EmailCC) { $MailMessage.CC.add($($CC)) } }
    if ($EmailParameters.EmailBCC) { foreach ($BCC in $EmailParameters.EmailBCC) { $MailMessage.BCC.add($($BCC)) } }
    if ($EmailParameters.EmailReplyTo) { $MailMessage.ReplyTo = $EmailParameters.EmailReplyTo }
    $MailMessage.IsBodyHtml = $true
    if ($Subject -eq '') { $MailMessage.Subject = $EmailParameters.EmailSubject } else { $MailMessage.Subject = $Subject }
    $MailMessage.Priority = [System.Net.Mail.MailPriority]::$($EmailParameters.EmailPriority)
    if ($EmailParameters.EmailEncodingSubject) { $MailMessage.SubjectEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncodingSubject) } elseif ($EmailParameters.EmailEncoding) { $MailMessage.SubjectEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding) }
    if ($EmailParameters.EmailEncodingBody) { $MailMessage.BodyEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncodingBody) } elseif ($EmailParameters.EmailEncoding) { $MailMessage.BodyEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding) }
    if ($EmailParameters.EmailUseDefaultCredentials) { $SmtpClient.UseDefaultCredentials = $EmailParameters.EmailUseDefaultCredentials }
    if ($EmailParameters.EmailDeliveryNotifications) { $MailMessage.DeliveryNotificationOptions = $EmailParameters.EmailDeliveryNotifications }
    if ($PSBoundParameters.ContainsKey('InlineAttachments')) {
        if ($EmailParameters.EmailEncodingAlternateView) { $BodyPart = [Net.Mail.AlternateView]::CreateAlternateViewFromString($Body, [System.Text.Encoding]::$($EmailParameters.EmailEncodingAlternateView) , 'text/html') } else { $BodyPart = [Net.Mail.AlternateView]::CreateAlternateViewFromString($Body, [System.Text.Encoding]::UTF8, 'text/html') }
        $MailMessage.AlternateViews.Add($BodyPart)
        foreach ($Entry in $InlineAttachments.GetEnumerator()) {
            try {
                $FilePath = $Entry.Value
                Write-Verbose $FilePath
                if ($Entry.Value.StartsWith('http', [System.StringComparison]::CurrentCultureIgnoreCase)) {
                    $FileName = $Entry.Value.Substring($Entry.Value.LastIndexOf("/") + 1)
                    $FilePath = Join-Path $env:temp $FileName
                    Invoke-WebRequest -Uri $Entry.Value -OutFile $FilePath
                }
                $ContentType = Get-MimeType -FileName $FilePath
                $InAttachment = [Net.Mail.LinkedResource]::new($FilePath, $ContentType)
                $InAttachment.ContentId = $Entry.Key
                $BodyPart.LinkedResources.Add($InAttachment)
            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                Write-Error "Error inlining attachments: $ErrorMessage"
            }
        }
    } else { $MailMessage.Body = $Body }
    if ($PSBoundParameters.ContainsKey('Attachment')) {
        foreach ($Attach in $Attachment) {
            if (Test-Path -LiteralPath $Attach) {
                try {
                    $File = [Net.Mail.Attachment]::new($Attach)
                    $MailMessage.Attachments.Add($File)
                } catch {
                    $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                    if ($Logger) { $Logger.AddErrorRecord("Error attaching file $Attach`: $ErrorMessage") } else { Write-Error "Error attaching file $Attach`: $ErrorMessage" }
                }
            }
        }
    }
    try {
        $MailSentTo = "$($MailMessage.To) $($MailMessage.CC) $($MailMessage.BCC)".Trim()
        if ($pscmdlet.ShouldProcess("$MailSentTo", "Send-Email")) {
            $SmtpClient.Send($MailMessage)
            $MailMessage.Dispose()
            return [PSCustomObject] @{Status = $True
                Error                        = ""
                SentTo                       = $MailSentTo
            }
        }
    } catch {
        $MailMessage.Dispose()
        return [PSCustomObject] @{Status = $False
            Error                        = $($_.Exception.Message)
            SentTo                       = ""
        }
    }
}
function Stop-TimeLog { 
    [CmdletBinding()]
    param ([Parameter(ValueFromPipeline = $true)][System.Diagnostics.Stopwatch] $Time,
        [ValidateSet('OneLiner', 'Array')][string] $Option = 'OneLiner',
        [switch] $Continue)
    Begin {}
    Process { if ($Option -eq 'Array') { $TimeToExecute = "$($Time.Elapsed.Days) days", "$($Time.Elapsed.Hours) hours", "$($Time.Elapsed.Minutes) minutes", "$($Time.Elapsed.Seconds) seconds", "$($Time.Elapsed.Milliseconds) milliseconds" } else { $TimeToExecute = "$($Time.Elapsed.Days) days, $($Time.Elapsed.Hours) hours, $($Time.Elapsed.Minutes) minutes, $($Time.Elapsed.Seconds) seconds, $($Time.Elapsed.Milliseconds) milliseconds" } }
    End {
        if (-not $Continue) { $Time.Stop() }
        return $TimeToExecute
    }
}
function Convert-Color { 
    <#
    .Synopsis
    This color converter gives you the hexadecimal values of your RGB colors and vice versa (RGB to HEX)
    .Description
    This color converter gives you the hexadecimal values of your RGB colors and vice versa (RGB to HEX). Use it to convert your colors and prepare your graphics and HTML web pages.
    .Parameter RBG
    Enter the Red Green Blue value comma separated. Red: 51 Green: 51 Blue: 204 for example needs to be entered as 51,51,204
    .Parameter HEX
    Enter the Hex value to be converted. Do not use the '#' symbol. (Ex: 3333CC converts to Red: 51 Green: 51 Blue: 204)
    .Example
    .\convert-color -hex FFFFFF
    Converts hex value FFFFFF to RGB

    .Example
    .\convert-color -RGB 123,200,255
    Converts Red = 123 Green = 200 Blue = 255 to Hex value

    #>
    param([Parameter(ParameterSetName = "RGB", Position = 0)]
        [ValidateScript( { $_ -match '^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$' })]
        $RGB,
        [Parameter(ParameterSetName = "HEX", Position = 0)]
        [ValidateScript( { $_ -match '[A-Fa-f0-9]{6}' })]
        [string]
        $HEX)
    switch ($PsCmdlet.ParameterSetName) {
        "RGB" {
            if ($null -eq $RGB[2]) { Write-Error "Value missing. Please enter all three values seperated by comma." }
            $red = [convert]::Tostring($RGB[0], 16)
            $green = [convert]::Tostring($RGB[1], 16)
            $blue = [convert]::Tostring($RGB[2], 16)
            if ($red.Length -eq 1) { $red = '0' + $red }
            if ($green.Length -eq 1) { $green = '0' + $green }
            if ($blue.Length -eq 1) { $blue = '0' + $blue }
            Write-Output $red$green$blue
        }
        "HEX" {
            $red = $HEX.Remove(2, 4)
            $Green = $HEX.Remove(4, 2)
            $Green = $Green.remove(0, 2)
            $Blue = $hex.Remove(0, 4)
            $Red = [convert]::ToInt32($red, 16)
            $Green = [convert]::ToInt32($green, 16)
            $Blue = [convert]::ToInt32($blue, 16)
            Write-Output $red, $Green, $blue
        }
    }
}
function ConvertTo-StringByType { 
    <#
    .SYNOPSIS
    Private function to use within ConvertTo-JsonLiteral

    .DESCRIPTION
    Private function to use within ConvertTo-JsonLiteral

    .PARAMETER Value
    Value to convert to JsonValue

     .PARAMETER Depth
    Specifies how many levels of contained objects are included in the JSON representation. The default value is 0.

    .PARAMETER AsArray
    Outputs the object in array brackets, even if the input is a single object.

    .PARAMETER DateTimeFormat
    Changes DateTime string format. Default "yyyy-MM-dd HH:mm:ss"

    .PARAMETER NumberAsString
    Provides an alternative serialization option that converts all numbers to their string representation.

    .PARAMETER BoolAsString
    Provides an alternative serialization option that converts all bool to their string representation.

    .PARAMETER PropertyName
    Uses PropertyNames provided by user (only works with Force)

    .PARAMETER ArrayJoin
    Forces any array to be a string regardless of depth level

    .PARAMETER ArrayJoinString
    Uses defined string or char for array join. By default it uses comma with a space when used.

    .PARAMETER Force
    Forces using property names from first object or given thru PropertyName parameter

    .EXAMPLE
    $Value = ConvertTo-StringByType -Value $($Object[$a][$i]) -DateTimeFormat $DateTimeFormat

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param([Object] $Value,
        [int] $Depth,
        [int] $MaxDepth,
        [string] $DateTimeFormat,
        [switch] $NumberAsString,
        [switch] $BoolAsString,
        [System.Collections.IDictionary] $NewLineFormat = @{NewLineCarriage = '\r\n'
            NewLine                                                         = "\n"
            Carriage                                                        = "\r"
        },
        [System.Collections.IDictionary] $NewLineFormatProperty = @{NewLineCarriage = '\r\n'
            NewLine                                                                 = "\n"
            Carriage                                                                = "\r"
        },
        [System.Collections.IDictionary] $AdvancedReplace,
        [System.Text.StringBuilder] $TextBuilder,
        [string[]] $PropertyName,
        [switch] $ArrayJoin,
        [string] $ArrayJoinString,
        [switch] $Force)
    Process {
        if ($null -eq $Value) { "`"`"" } elseif ($Value -is [string]) {
            $Value = $Value.Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormat.NewLineCarriage).Replace("`n", $NewLineFormat.NewLine).Replace("`r", $NewLineFormat.Carriage)
            foreach ($Key in $AdvancedReplace.Keys) { $Value = $Value.Replace($Key, $AdvancedReplace[$Key]) }
            "`"$Value`""
        } elseif ($Value -is [DateTime]) { "`"$($($Value).ToString($DateTimeFormat))`"" } elseif ($Value -is [bool]) { if ($BoolAsString) { "`"$($Value)`"" } else { $Value.ToString().ToLower() } } elseif ($Value -is [System.Collections.IDictionary]) {
            if ($MaxDepth -eq 0 -or $Depth -eq $MaxDepth) { "`"$($Value)`"" } else {
                $Depth++
                $null = $TextBuilder.AppendLine("{")
                for ($i = 0; $i -lt ($Value.Keys).Count; $i++) {
                    $Property = ([string[]]$Value.Keys)[$i]
                    $DisplayProperty = $Property.Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormatProperty.NewLineCarriage).Replace("`n", $NewLineFormatProperty.NewLine).Replace("`r", $NewLineFormatProperty.Carriage)
                    $null = $TextBuilder.Append("`"$DisplayProperty`":")
                    $OutputValue = ConvertTo-StringByType -Value $Value[$Property] -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $Depth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -Force:$Force -ArrayJoinString $ArrayJoinString
                    $null = $TextBuilder.Append("$OutputValue")
                    if ($i -ne ($Value.Keys).Count - 1) { $null = $TextBuilder.AppendLine(',') }
                }
                $null = $TextBuilder.Append("}")
            }
        } elseif ($Value -is [System.Collections.IList] -or $Value -is [System.Collections.ReadOnlyCollectionBase]) {
            if ($ArrayJoin) {
                $Value = $Value -join $ArrayJoinString
                $Value = "$Value".Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormatProperty.NewLineCarriage).Replace("`n", $NewLineFormatProperty.NewLine).Replace("`r", $NewLineFormatProperty.Carriage)
                "`"$Value`""
            } else {
                if ($MaxDepth -eq 0 -or $Depth -eq $MaxDepth) {
                    $Value = "$Value".Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormatProperty.NewLineCarriage).Replace("`n", $NewLineFormatProperty.NewLine).Replace("`r", $NewLineFormatProperty.Carriage)
                    "`"$Value`""
                } else {
                    $CountInternalObjects = 0
                    $null = $TextBuilder.Append("[")
                    foreach ($V in $Value) {
                        $CountInternalObjects++
                        if ($CountInternalObjects -gt 1) { $null = $TextBuilder.Append(',') }
                        if ($Force -and -not $PropertyName) { $PropertyName = $V.PSObject.Properties.Name } elseif ($Force -and $PropertyName) {} else { $PropertyName = $V.PSObject.Properties.Name }
                        $OutputValue = ConvertTo-StringByType -Value $V -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $Depth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -Force:$Force -PropertyName $PropertyName -ArrayJoinString $ArrayJoinString
                        $null = $TextBuilder.Append($OutputValue)
                    }
                    $null = $TextBuilder.Append("]")
                }
            }
        } elseif ($Value -is [System.Enum]) { "`"$($($Value).ToString())`"" } elseif (($Value | IsNumeric) -eq $true) { if ($NumberAsString) { "`"$($Value)`"" } else { $($Value) } } elseif ($Value -is [PSObject]) {
            if ($MaxDepth -eq 0 -or $Depth -eq $MaxDepth) { "`"$($Value)`"" } else {
                $Depth++
                $CountInternalObjects = 0
                $null = $TextBuilder.AppendLine("{")
                if ($Force -and -not $PropertyName) { $PropertyName = $Value.PSObject.Properties.Name } elseif ($Force -and $PropertyName) {} else { $PropertyName = $Value.PSObject.Properties.Name }
                foreach ($Property in $PropertyName) {
                    $CountInternalObjects++
                    if ($CountInternalObjects -gt 1) { $null = $TextBuilder.AppendLine(',') }
                    $DisplayProperty = $Property.Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormatProperty.NewLineCarriage).Replace("`n", $NewLineFormatProperty.NewLine).Replace("`r", $NewLineFormatProperty.Carriage)
                    $null = $TextBuilder.Append("`"$DisplayProperty`":")
                    $OutputValue = ConvertTo-StringByType -Value $Value.$Property -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $Depth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -Force:$Force -ArrayJoinString $ArrayJoinString
                    $null = $TextBuilder.Append("$OutputValue")
                }
                $null = $TextBuilder.Append("}")
            }
        } else {
            $Value = $Value.ToString().Replace('\', "\\").Replace('"', '\"').Replace([System.Environment]::NewLine, $NewLineFormatProperty.NewLineCarriage).Replace("`n", $NewLineFormatProperty.NewLine).Replace("`r", $NewLineFormatProperty.Carriage)
            "`"$Value`""
        }
    }
}
function Get-MimeType { 
    [CmdletBinding()]
    param ([Parameter(Mandatory = $true)]
        [string] $FileName)
    $MimeMappings = @{'.jpeg' = 'image/jpeg'
        '.jpg'                = 'image/jpeg'
        '.png'                = 'image/png'
    }
    $Extension = [System.IO.Path]::GetExtension($FileName)
    $ContentType = $MimeMappings[ $Extension ]
    if ([string]::IsNullOrEmpty($ContentType)) { return New-Object System.Net.Mime.ContentType } else { return New-Object System.Net.Mime.ContentType($ContentType) }
}
function Request-Credentials { 
    [CmdletBinding()]
    param([string] $UserName,
        [string] $Password,
        [switch] $AsSecure,
        [switch] $FromFile,
        [switch] $Output,
        [switch] $NetworkCredentials,
        [string] $Service)
    if ($FromFile) {
        if (($Password -ne '') -and (Test-Path $Password)) {
            Write-Verbose "Request-Credentials - Reading password from file $Password"
            $Password = Get-Content -Path $Password
        } else {
            if ($Output) { return @{Status = $false; Output = $Service; Extended = 'File with password unreadable.' } } else {
                Write-Warning "Request-Credentials - Secure password from file couldn't be read. File not readable. Terminating."
                return
            }
        }
    }
    if ($AsSecure) {
        try { $NewPassword = $Password | ConvertTo-SecureString -ErrorAction Stop } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            if ($ErrorMessage -like '*Key not valid for use in specified state*') {
                if ($Output) { return @{Status = $false; Output = $Service; Extended = "Couldn't use credentials provided. Most likely using credentials from other user/session/computer." } } else {
                    Write-Warning -Message "Request-Credentials - Couldn't use credentials provided. Most likely using credentials from other user/session/computer."
                    return
                }
            } else {
                if ($Output) { return @{Status = $false; Output = $Service; Extended = $ErrorMessage } } else {
                    Write-Warning -Message "Request-Credentials - $ErrorMessage"
                    return
                }
            }
        }
    } else { $NewPassword = $Password }
    if ($UserName -and $NewPassword) {
        if ($AsSecure) { $Credentials = New-Object System.Management.Automation.PSCredential($Username, $NewPassword) } else {
            Try { $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                if ($ErrorMessage -like '*Key not valid for use in specified state*') {
                    if ($Output) { return @{Status = $false; Output = $Service; Extended = "Couldn't use credentials provided. Most likely using credentials from other user/session/computer." } } else {
                        Write-Warning -Message "Request-Credentials - Couldn't use credentials provided. Most likely using credentials from other user/session/computer."
                        return
                    }
                } else {
                    if ($Output) { return @{Status = $false; Output = $Service; Extended = $ErrorMessage } } else {
                        Write-Warning -Message "Request-Credentials - $ErrorMessage"
                        return
                    }
                }
            }
            $Credentials = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)
        }
    } else {
        if ($Output) { return @{Status = $false; Output = $Service; Extended = 'Username or/and Password is empty' } } else {
            Write-Warning -Message 'Request-Credentials - UserName or Password are empty.'
            return
        }
    }
    if ($NetworkCredentials) { return $Credentials.GetNetworkCredential() } else { return $Credentials }
}
function New-ApexChart {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [Object] $Events
    )
    if ($Events) {
        $Options.chart.events = 'EventsReplaceMe'
    }

    $Script:HTMLSchema.Features.ChartsApex = $true
    [string] $ID = "ChartID-" + (Get-RandomStringName -Size 8)
    $Div = New-HTMLTag -Tag 'div' -Attributes @{ class = 'flexElement'; id = $ID; }
    $Script = New-HTMLTag -Tag 'script' -Value {
        # Convert Dictionary to JSON and return chart within SCRIPT tag
        # Make sure to return with additional empty string
        Remove-EmptyValue -Hashtable $Options -Recursive -Rerun 2
        $JSON = $Options | ConvertTo-JsonLiteral -Depth 5 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' }
        # replaces stuff for TImeLineCharts
        $JSON = $JSON.Replace('"new Date(', 'new Date(').Replace(').getTime()"', ').getTime()')

        # We replace Events on JSON because there's no other way that I can think of
        if ($Options.chart.events) {
            $JSON = $JSON -replace ('"events":"EventsReplaceMe"', $Events)
        }

        $JSON = $JSON | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }

        "var options = $JSON"
        "var chart = new ApexCharts(document.querySelector('#$ID'),
            options
        );"
        "chart.render();"
    } -NewLine
    $Div
    # we need to move it to the end of the code therefore using additional vesel
    $Script:HTMLSchema.Charts.Add($Script)
}
function New-ChartInternalArea {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,

        [Array] $Data,
        [Array] $DataNames,
        [Array] $DataLegend,

        #[bool] $DataLabelsEnabled = $true,
        #[int] $DataLabelsOffsetX = -6,
        #[string] $DataLabelsFontSize = '12px',
        #[string] $DataLabelsColor,
        [ValidateSet('datetime', 'category', 'numeric')][string] $DataCategoriesType = 'category'

        #$Type
    )
    # Chart defintion type, size
    $Options.chart = @{
        type = 'area'
    }

    $Options.series = @( New-ChartInternalDataSet -Data $Data -DataNames $DataNames )

    # X AXIS - CATEGORIES
    $Options.xaxis = [ordered] @{}
    if ($DataCategoriesType -ne '') {
        $Options.xaxis.type = $DataCategoriesType
    }
    if ($DataCategories.Count -gt 0) {
        $Options.xaxis.categories = $DataCategories
    }

}
function New-ChartInternalAxisX {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [string] $TitleText,
        [Int64] $Min,
        [Int64] $Max,
        [ValidateSet('datetime', 'category', 'numeric')][string] $Type = 'category',
        [Array] $Names
    )

    if (-not $Options.Contains('xaxis')) {
        $Options.xaxis = @{ }
    }
    if ($TitleText -ne '') {
        $Options.xaxis.title = @{ }
        $Options.xaxis.title.text = $TitleText
    }
    if ($Min -gt 0) {
        $Options.xaxis.min = $Min
    }
    if ($Max -gt 0) {
        $Options.xaxis.max = $Max
    }
    if ($Type -ne '') {
        $Options.xaxis.type = $Type
    }
    if ($Names.Count -gt 0) {
        $Options.xaxis.categories = $Names
    }
}
Function New-ChartInternalBar {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [bool] $Horizontal = $true,
        [bool] $DataLabelsEnabled = $true,
        [int] $DataLabelsOffsetX = -6,
        [string] $DataLabelsFontSize = '12px',
        [string[]] $DataLabelsColor,
        #[string] $Title,
        #[ValidateSet('center', 'left', 'right', 'default')][string] $TitleAlignment = 'default',
        [string] $Formatter,
        [ValidateSet('bar', 'barStacked', 'barStacked100Percent')] $Type = 'bar',
        #[string[]] $Colors,

        [switch] $Distributed,

        [Array] $Data,
        [Array] $DataNames,
        [Array] $DataLegend
    )

    if ($Type -eq 'bar') {
        $Options.chart = [ordered] @{
            type = 'bar'
        }
    } elseif ($Type -eq 'barStacked') {
        $Options.chart = [ordered] @{
            type    = 'bar'
            stacked = $true
        }
    } else {
        $Options.chart = [ordered] @{
            type      = 'bar'
            stacked   = $true
            stackType = '100%'
        }
    }

    $Options.plotOptions = @{
        bar = @{
            horizontal = $Horizontal
        }
    }
    if ($Distributed) {
        $Options.plotOptions.bar.distributed = $Distributed.IsPresent
    }
    $Options.dataLabels = [ordered] @{
        enabled = $DataLabelsEnabled
        offsetX = $DataLabelsOffsetX
        style   = @{
            fontSize = $DataLabelsFontSize
        }
    }
    if ($null -ne $DataLabelsColor) {
        $RGBColorLabel = ConvertFrom-Color -Color $DataLabelsColor
        $Options.dataLabels.style.colors = @($RGBColorLabel)
    }
    $Options.series = @(New-ChartInternalDataSet -Data $Data -DataNames $DataLegend)

    # X AXIS - CATEGORIES
    if (-not $Options.Contains('xaxis')) {
        $Options.xaxis = [ordered] @{ }
    }
    # if ($DataCategoriesType -ne '') {
    #    $Options.xaxis.type = $DataCategoriesType
    #}
    if ($DataNames.Count -gt 0) {
        $Options.xaxis.categories = $DataNames
        # Need to figure out how to conver to json and leave function without ""
        #if ($Formatter -ne '') {
        #$Options.xaxis.labels = @{
        #formatter = "function(val) { return val + `"$Formatter`" }"
        #}
        #}
    }
}
Register-ArgumentCompleter -CommandName New-ChartInternalBar -ParameterName DataLabelsColor -ScriptBlock $Script:ScriptBlockColors
function New-ChartInternalColors {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [string[]]$Colors
    )

    if ($Colors.Count -gt 0) {
        $RGBColor = ConvertFrom-Color -Color $Colors
        $Options.colors = @($RGBColor)
    }
}
Register-ArgumentCompleter -CommandName New-ChartInternalColors -ParameterName Colors -ScriptBlock $Script:ScriptBlockColors
function New-ChartInternalDataLabels {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [bool] $DataLabelsEnabled = $true,
        [int] $DataLabelsOffsetX = -6,
        [string] $DataLabelsFontSize = '12px',
        [string[]] $DataLabelsColor
    )

    $Options.dataLabels = [ordered] @{
        enabled = $DataLabelsEnabled
        offsetX = $DataLabelsOffsetX
        style   = @{
            fontSize = $DataLabelsFontSize
        }
    }
    if ($DataLabelsColor.Count -gt 0) {
        $Options.dataLabels.style.colors = @(ConvertFrom-Color -Color $DataLabelsColor)
    }
}
Register-ArgumentCompleter -CommandName New-ChartInternalDataLabels -ParameterName DataLabelsColors -ScriptBlock $Script:ScriptBlockColors
function New-ChartInternalDataSet {
    [CmdletBinding()]
    param(
        [Array] $Data,
        [Array] $DataNames
    )

    if ($null -ne $Data -and $null -ne $DataNames) {
        if ($Data[0] -is [System.Collections.ICollection]) {
            # If it's array of Arrays
            if ($Data[0].Count -eq $DataNames.Count) {
                for ($a = 0; $a -lt $Data.Count; $a++) {
                    [ordered] @{
                        name = $DataNames[$a]
                        data = $Data[$a]
                    }
                }
            } elseif ($Data.Count -eq $DataNames.Count) {
                for ($a = 0; $a -lt $Data.Count; $a++) {
                    [ordered] @{
                        name = $DataNames[$a]
                        data = $Data[$a]
                    }
                }
            } else {
                # rerun with just data (so it checks another if)
                New-ChartInternalDataSet -Data $Data
            }

        } else {
            if ($null -ne $DataNames) {
                # If it's just int in Array
                [ordered] @{
                    name = $DataNames
                    data = $Data
                }
            } else {
                [ordered]  @{
                    data = $Data
                }
            }
        }

    } elseif ($null -ne $Data) {
        # No names given
        if ($Data[0] -is [System.Collections.ICollection]) {
            # If it's array of Arrays
            foreach ($D in $Data) {
                [ordered] @{
                    data = $D
                }
            }
        } else {
            # If it's just int in Array
            [ordered] @{
                data = $Data
            }
        }
    } else {
        Write-Warning -Message "New-ChartInternalDataSet - No Data provided. Unabled to create dataset."
        return [ordered] @{ }
    }
}
function New-ChartInternalGradient {
    [CmdletBinding()]
    param(

    )
    $Options.fill = [ordered] @{
        type     = 'gradient'
        gradient = [ordered] @{
            shade          = 'dark'
            type           = 'horizontal'
            shadeIntensity = 0.5
            #gradientToColors = @('#ABE5A1')
            inverseColors  = $true
            opacityFrom    = 1
            opacityTo      = 1
            stops          = @(0, 100)
        }
    }
}

function New-ChartInternalGrid {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [bool] $Show,
        [string] $BorderColor,
        [int] $StrokeDash, #: 0,
        [ValidateSet('front', 'back', 'default')][string] $Position = 'default',
        [nullable[bool]] $xAxisLinesShow = $null,
        [nullable[bool]] $yAxisLinesShow = $null,
        [alias('GridColors')][string[]] $RowColors,
        [alias('GridOpacity')][double] $RowOpacity = 0.5, # valid range 0 - 1
        [string[]] $ColumnColors ,
        [double] $ColumnOpacity = 0.5, # valid range 0 - 1
        [int] $PaddingTop,
        [int] $PaddingRight,
        [int] $PaddingBottom,
        [int] $PaddingLeft
    )

    <# Build this https://apexcharts.com/docs/options/grid/
        grid: {
            show: true,
            borderColor: '#90A4AE',
            strokeDashArray: 0,
            position: 'back',
            xaxis: {
                lines: {,
                    show: false
                }
            },
            yaxis: {
                lines: {,
                    show: false
                }
            },
            row: {
                colors: undefined,
                opacity: 0.5
            },
            column: {
                colors: undefined,
                opacity: 0.5
            },
            padding: {
                top: 0,
                right: 0,
                bottom: 0,
                left: 0
            },
        }
    #>

    $Options.grid = [ordered] @{ }
    $Options.grid.Show = $Show
    if ($BorderColor) {
        $options.grid.borderColor = @(ConvertFrom-Color -Color $BorderColor)
    }
    if ($StrokeDash -gt 0) {
        $Options.grid.strokeDashArray = $StrokeDash
    }
    if ($Position -ne 'Default') {
        $Options.grid.position = $Position
    }

    if ($null -ne $xAxisLinesShow) {
        $Options.grid.xaxis = @{ }
        $Options.grid.xaxis.lines = @{ }

        $Options.grid.xaxis.lines.show = $xAxisLinesShow
    }
    if ($null -ne $yAxisLinesShow) {
        $Options.grid.yaxis = @{ }
        $Options.grid.yaxis.lines = @{ }
        $Options.grid.yaxis.lines.show = $yAxisLinesShow
    }

    if ($RowColors.Count -gt 0 -or $RowOpacity -ne 0) {
        $Options.grid.row = @{ }
        if ($RowColors.Count -gt 0) {
            $Options.grid.row.colors = @(ConvertFrom-Color -Color $RowColors)
        }
        if ($RowOpacity -ne 0) {
            $Options.grid.row.opacity = $RowOpacity
        }
    }
    if ($ColumnColors.Count -gt 0 -or $ColumnOpacity -ne 0) {
        $Options.grid.column = @{ }
        if ($ColumnColors.Count -gt 0) {
            $Options.grid.column.colors = @(ConvertFrom-Color -Color $ColumnColors)
        }
        if ($ColumnOpacity -ne 0) {
            $Options.grid.column.opacity = $ColumnOpacitys
        }
    }
    if ($PaddingTop -gt 0 -or $PaddingRight -gt 0 -or $PaddingBottom -gt 0 -or $PaddingLeft -gt 0) {
        # Padding options
        $Options.grid.padding = @{ }
        if ($PaddingTop -gt 0) {
            $Options.grid.padding.PaddingTop = $PaddingTop
        }
        if ($PaddingRight -gt 0) {
            $Options.grid.padding.PaddingRight = $PaddingRight
        }
        if ($PaddingBottom -gt 0) {
            $Options.grid.padding.PaddingBottom = $PaddingBottom
        }
        if ($PaddingLeft -gt 0) {
            $Options.grid.padding.PaddingLeft = $PaddingLeft
        }
    }
}
Register-ArgumentCompleter -CommandName New-ChartInternalGrid -ParameterName BorderColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-ChartInternalGrid -ParameterName RowColors -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-ChartInternalGrid -ParameterName ColumnColors -ScriptBlock $Script:ScriptBlockColors
function New-ChartInternalLegend {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [ValidateSet('top', 'topRight', 'left', 'right', 'bottom', 'default')][string] $LegendPosition = 'default'
    )
    # legend
    if ($LegendPosition -eq 'default' -or $LegendPosition -eq 'bottom') {
        # Do nothing
    } elseif ($LegendPosition -eq 'right') {
        $Options.legend = [ordered]@{
            position = 'right'
            offsetY  = 100
            height   = 230
        }
    } elseif ($LegendPosition -eq 'top') {
        $Options.legend = [ordered]@{
            position        = 'top'
            horizontalAlign = 'left'
            offsetX         = 40
        }
    } elseif ($LegendPosition -eq 'topRight') {
        $Options.legend = [ordered]@{
            position        = 'top'
            horizontalAlign = 'right'
            floating        = $true
            offsetY         = -25
            offsetX         = -5
        }
    }
}
function New-ChartInternalLine {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,

        [Array] $Data,
        [Array] $DataNames,
        #[Array] $DataLegend,

        # [bool] $DataLabelsEnabled = $true,
        #[int] $DataLabelsOffsetX = -6,
        #[string] $DataLabelsFontSize = '12px',
        # [string] $DataLabelsColor,
        [ValidateSet('datetime', 'category', 'numeric')][string] $DataCategoriesType = 'category'

        # $Type
    )
    # Chart defintion type, size
    $Options.chart = @{
        type = 'line'
    }

    $Options.series = @( New-ChartInternalDataSet -Data $Data -DataNames $DataNames )

    # X AXIS - CATEGORIES
    $Options.xaxis = [ordered] @{}
    if ($DataCategoriesType -ne '') {
        $Options.xaxis.type = $DataCategoriesType
    }
    if ($DataCategories.Count -gt 0) {
        $Options.xaxis.categories = $DataCategories
    }

}
function New-ChartInternalMarker {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [int] $MarkerSize
    )
    if ($MarkerSize -gt 0) {
        $Options.markers = @{
            size = $MarkerSize
        }
    }
}
function New-ChartInternalPattern {
    [CmdletBinding()]
    param(

    )
    $Options.fill = [ordered]@{
        type    = 'pattern'
        opacity = 1
        pattern = [ordered]@{
            style = @('circles', 'slantedLines', 'verticalLines', 'horizontalLines')
        }
    }
}
function New-ChartInternalPie {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [Array] $Values,
        [Array] $Names,
        [string] $Type
    )
    # Chart defintion type, size
    $Options.chart = @{
        type = $Type.ToLower()
    }
    $Options.series = @($Values)
    $Options.labels = @($Names)
}
function New-ChartInternalRadial {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [Array] $Values,
        [Array] $Names,
        $Type
    )
    # Chart defintion type, size
    $Options.chart = @{
        type = 'radialBar'
    }

    if ($Type -eq '1') {
        New-ChartInternalRadialType1 -Options $Options
    } elseif ($Type -eq '2') {
        New-ChartInternalRadialType2 -Options $Options
    }

    $Options.series = @($Values)
    $Options.labels = @($Names)


}
function New-ChartInternalRadialCircleType {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [ValidateSet('FullCircleTop', 'FullCircleBottom', 'FullCircleBottomLeft', 'FullCircleLeft', 'Speedometer', 'SemiCircleGauge')] $CircleType
    )
    if ($CircleType -eq 'SemiCircleGauge') {
        $Options.plotOptions.radialBar = [ordered] @{
            startAngle = -90
            endAngle   = 90
        }
    } elseif ($CircleType -eq 'FullCircleBottom') {
        $Options.plotOptions.radialBar = [ordered] @{
            startAngle = -180
            endAngle   = 180
        }
    } elseif ($CircleType -eq 'FullCircleLeft') {
        $Options.plotOptions.radialBar = [ordered] @{
            startAngle = -90
            endAngle   = 270
        }
    } elseif ($CircleType -eq 'FullCircleBottomLeft') {
        $Options.plotOptions.radialBar = [ordered] @{
            startAngle = -135
            endAngle   = 225
        }
    } elseif ($CircleType -eq 'Speedometer') {
        $Options.plotOptions.radialBar = [ordered] @{
            startAngle = -135
            endAngle   = 135
        }
    } else {
        #FullCircleTop
    }
}
function New-ChartInternalRadialDataLabels {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [string] $LabelAverage = 'Average'
    )
    if ($LabelAverage -ne '') {
        $Options.plotOptions.radialBar.dataLabels = @{
            showOn = 'always'

            name   = @{
                # fontSize = '16px'
                # color    = 'undefined'
                #offsetY = 120
            }
            value  = @{
                #offsetY = 76
                #  fontSize  = '22px'
                #  color     = 'undefined'
                # formatter = 'function (val) { return val + "%" }'
            }

            total  = @{
                show  = $true
                label = $LabelAverage
            }

        }
    }
}

function New-ChartInternalRadialType1 {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [Array] $Values,
        [Array] $Names
    )

    $Options.plotOptions = @{
        radialBar = [ordered] @{
            #startAngle = -135
            #endAngle   = 225

            #startAngle = -135
            #endAngle   = 135


            hollow = [ordered] @{
                margin       = 0
                size         = '70%'
                background   = '#fff'
                image        = 'undefined'
                imageOffsetX = 0
                imageOffsetY = 0
                position     = 'front'
                dropShadow   = @{
                    enabled = $true
                    top     = 3
                    left    = 0
                    blur    = 4
                    opacity = 0.24
                }
            }
            track  = [ordered] @{
                background  = '#fff'
                strokeWidth = '70%'
                margin      = 0  #// margin is in pixels
                dropShadow  = [ordered] @{
                    enabled = $true
                    top     = -3
                    left    = 0
                    blur    = 4
                    opacity = 0.35
                }
            }
            <#
            dataLabels = @{
                showOn = 'always'

                name   = @{
                    # fontSize = '16px'
                    # color    = 'undefined'
                    #offsetY = 120
                }
                value  = @{
                    #offsetY = 76
                    #  fontSize  = '22px'
                    #  color     = 'undefined'
                    # formatter = 'function (val) { return val + "%" }'
                }

                total  = @{
                    show  = $false
                    label = 'Average'
                }
            }
            #>
        }
    }

    $Options.fill = [ordered] @{
        type     = 'gradient'
        gradient = [ordered] @{
            shade          = 'dark'
            type           = 'horizontal'
            shadeIntensity = 0.5
            #gradientToColors = @('#ABE5A1')
            inverseColors  = $true
            opacityFrom    = 1
            opacityTo      = 1
            stops          = @(0, 100)
        }
    }
    <# Gradient
        $Options.stroke = @{
        lineCap = 'round'
    }
    #>
    <#
    $Options.fill = @{
        type     = 'gradient'
        gradient = @{
            shade          = 'dark'
            shadeIntensity = 0.15
            inverseColors  = $false
            opacityFrom    = 1
            opacityTo      = 1
            stops          = @(0, 50, 65, 91)
        }
    }
    #>
    $Options.stroke = [ordered] @{
        dashArray = 4
    }
}


function New-ChartInternalRadialType2 {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [Array] $Values,
        [Array] $Names
    )
    $Options.plotOptions = @{
        radialBar = [ordered] @{

            #startAngle = -135
            #endAngle   = 225

            #startAngle = -135
            #endAngle   = 135


            hollow = [ordered] @{
                margin       = 0
                size         = '70%'
                background   = '#fff'
                image        = 'undefined'
                imageOffsetX = 0
                imageOffsetY = 0
                position     = 'front'
                dropShadow   = @{
                    enabled = $true
                    top     = 3
                    left    = 0
                    blur    = 4
                    opacity = 0.24
                }
            }
            <#
            track      = @{
                background  = '#fff'
                strokeWidth = '70%'
                margin      = 0  #// margin is in pixels
                dropShadow  = @{
                    enabled = $true
                    top     = -3
                    left    = 0
                    blur    = 4
                    opacity = 0.35
                }
            }
            dataLabels = @{
                showOn = 'always'

                name   = @{
                    # fontSize = '16px'
                    # color    = 'undefined'
                    offsetY = 120
                }
                value  = @{
                    offsetY = 76
                    #  fontSize  = '22px'
                    #  color     = 'undefined'
                    # formatter = 'function (val) { return val + "%" }'
                }

                total  = @{
                    show  = $false
                    label = 'Average'
                }
            }
            #>
        }
    }
}

function New-ChartInternalSize {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [nullable[int]] $Height = 350,
        [nullable[int]] $Width
    )
    if ($null -ne $Height) {
        $Options.chart.height = $Height
    }
    if ($null -ne $Width) {
        $Options.chart.width = $Width
    }
}
function New-ChartInternalSpark {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [string[]] $Color,
        [Array] $Values
    )
    if ($Values.Count -eq 0) {
        Write-Warning 'Get-ChartSpark - Values Empty'
    }

    if ($null -ne $Color) {
        $ColorRGB = ConvertFrom-Color -Color $Color
        $Options.colors = @($ColorRGB)
    }
    $Options.chart = [ordered] @{
        type      = 'area'
        sparkline = @{
            enabled = $true
        }
    }
    $Options.stroke = @{
        curve = 'straight'
    }
    $Options.fill = @{
        opacity = 0.3
    }
    $Options.series = @(
        # Checks if it's multiple array passed or just one. If one it will draw one line, if more then one it will draw line per each array
        if ($Values[0] -is [Array]) {
            foreach ($Value in $Values) {
                @{
                    data = @($Value)
                }
            }
        } else {
            @{
                data = @($Values)
            }
        }
    )
}

Register-ArgumentCompleter -CommandName New-ChartInternalSpark -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartInternalStrokeDefinition {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [bool] $LineShow = $true,
        [ValidateSet('straight', 'smooth', 'stepline')][string[]] $LineCurve,
        [int[]] $LineWidth,
        [ValidateSet('butt', 'square', 'round')][string[]] $LineCap,
        [string[]] $LineColor,
        [int[]] $LineDash
    )
    # LINE Definition
    $Options.stroke = [ordered] @{
        show = $LineShow
    }
    if ($LineCurve.Count -gt 0) {
        $Options.stroke.curve = $LineCurve
    }
    if ($LineWidth.Count -gt 0) {
        $Options.stroke.width = $LineWidth
    }
    if ($LineColor.Count -gt 0) {
        $Options.stroke.colors = @(ConvertFrom-Color -Color $LineColor)
    }
    if ($LineCap.Count -gt 0) {
        $Options.stroke.lineCap = $LineCap
    }
    if ($LineDash.Count -gt 0) {
        $Options.stroke.dashArray = $LineDash
    }
}
Register-ArgumentCompleter -CommandName New-ChartInternalStrokeDefinition -ParameterName LineColor -ScriptBlock $Script:ScriptBlockColors
<#
  theme: {
      mode: 'light',
      palette: 'palette1',
      monochrome: {
          enabled: false,
          color: '#255aee',
          shadeTo: 'light',
          shadeIntensity: 0.65
      },
  }
#>

function New-ChartInternalTheme {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [ValidateSet('light', 'dark')][string] $Mode,
        [ValidateSet(
            'palette1',
            'palette2',
            'palette3',
            'palette4',
            'palette5',
            'palette6',
            'palette7',
            'palette8',
            'palette9',
            'palette10'
        )
        ][string] $Palette = 'palette1',
        [switch] $Monochrome,
        [string] $Color = "DodgerBlue",
        [ValidateSet('light', 'dark')][string] $ShadeTo = 'light',
        [double] $ShadeIntensity = 0.65
    )

    $RGBColor = ConvertFrom-Color -Color $Color

    $Options.theme = [ordered] @{
        mode       = $Mode
        palette    = $Palette
        monochrome = [ordered] @{
            enabled        = $Monochrome.IsPresent
            color          = $RGBColor
            shadeTo        = $ShadeTo
            shadeIntensity = $ShadeIntensity
        }
    }
}

Register-ArgumentCompleter -CommandName New-ChartInternalTheme -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartInternalTimeLine {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [string] $Color,
        [Array] $Data,
        [Int64] $Min,
        [Int64] $Max
    )

    if ($Data.Count -eq 0) {
        Write-Warning 'New-ChartInternalTimeLine - Data Empty'
    }

    if ($null -ne $Color) {
        $ColorRGB = ConvertFrom-Color -Color $Color
        $Options.colors = @($ColorRGB)
    }
    $Options.chart = [ordered] @{
        type = 'rangeBar'
    }
    $Options.plotOptions = @{
        bar = @{
            horizontal  = $true
            distributed = $true
            dataLabels  = @{
                hideOverflowingLabels = $false
            }
        }
    }
    $Options.series = @(
        @{
            data = @(
                foreach ($Value in $Data) {
                    $Value
                }
            )

        }
    )
}

Register-ArgumentCompleter -CommandName New-ChartInternalSpark -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartInternalTitle {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [string] $Title,
        [ValidateSet('center', 'left', 'right', 'default')][string] $TitleAlignment = 'default'
    )
    # title
    $Options.title = [ordered] @{ }
    if ($Title -ne '') {
        $Options.title.text = $Title
    }
    if ($TitleAlignment -ne 'default') {
        $Options.title.align = $TitleAlignment
    }
}
function New-ChartInternalToolbar {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [bool] $Show = $false,
        [bool] $Download = $false,
        [bool] $Selection = $false,
        [bool] $Zoom = $false,
        [bool] $ZoomIn = $false,
        [bool] $ZoomOut = $false,
        [bool] $Pan = $false,
        [bool] $Reset = $false,
        [ValidateSet('zoom', 'selection', 'pan')][string] $AutoSelected = 'zoom'
    )
    $Options.chart.toolbar = [ordered] @{
        show         = $show
        tools        = [ordered] @{
            download  = $Download
            selection = $Selection
            zoom      = $Zoom
            zoomin    = $ZoomIn
            zoomout   = $ZoomOut
            pan       = $Pan
            reset     = $Reset
        }
        autoSelected = $AutoSelected
    }
}
function New-ChartInternalToolTip {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [bool] $Enabled,
        [System.Collections.IDictionary] $y,
        [System.Collections.IDictionary] $x

    )

    if (-not $Options.tooltip) {
        $Options.tooltip = @{}
    }
    $Options.tooltip.enabled = $Enabled
    $Options.tooltip.x = $x
    $Options.tooltip.y = $y

}
function New-ChartInternalZoom {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Options,
        [switch] $Enabled
    )
    if ($Enabled) {
        $Options.chart.zoom = @{
            type    = 'x'
            enabled = $Enabled.IsPresent
        }
    }
}
function New-HTMLChartArea {
    [CmdletBinding()]
    param(
        [nullable[int]] $Height = 350,

        [bool] $DataLabelsEnabled = $true,
        [int] $DataLabelsOffsetX = -6,
        [string] $DataLabelsFontSize = '12px',
        [string[]] $DataLabelsColor,
        [ValidateSet('datetime', 'category', 'numeric')][string] $DataCategoriesType = 'category',

        [ValidateSet('straight', 'smooth', 'stepline')] $LineCurve = 'straight',
        [int] $LineWidth,
        [string[]] $LineColor,

        [string[]] $GridColors,
        [double] $GridOpacity,

        [ValidateSet('top', 'topRight', 'left', 'right', 'bottom', 'default')][string] $LegendPosition = 'default',

        [string] $TitleX,
        [string] $TitleY,

        [int] $MarkerSize,

        [Array] $Data,
        [Array] $DataNames,
        [Array] $DataLegend,

        [switch] $Zoom,

        [System.Collections.IDictionary] $ChartAxisY,
        [System.Collections.IDictionary] $Legend,

        [string] $Title,
        [ValidateSet('center', 'left', 'right', 'default')][string] $TitleAlignment = 'default',
        [switch] $PatternedColors,
        [switch] $GradientColors,
        [System.Collections.IDictionary] $GridOptions,
        [System.Collections.IDictionary] $Toolbar,
        [System.Collections.IDictionary] $Theme
    )

    $Options = [ordered] @{ }
    if ($ChartAxisY) {
        $Options.yaxis = $ChartAxisY
    }
    if ($Legend) {
        $Options.legend = $Legend
    }
    New-ChartInternalArea -Options $Options -Data $Data -DataNames $DataNames

    New-ChartInternalStrokeDefinition -Options $Options `
        -LineShow $true `
        -LineCurve $LineCurve `
        -LineWidth $LineWidth `
        -LineColor $LineColor

    New-ChartInternalDataLabels -Options $Options `
        -DataLabelsEnabled $DataLabelsEnabled `
        -DataLabelsOffsetX $DataLabelsOffsetX `
        -DataLabelsFontSize $DataLabelsFontSize `
        -DataLabelsColor $DataLabelsColor


    New-ChartInternalAxisX -Options $Options `
        -Title $TitleX `
        -DataCategoriesType $DataCategoriesType `
        -DataCategories $DataLegend
    <# This needs rebuilding to new method - set above - remember to remove TitleY
    New-ChartInternalAxisY -Options $Options -Title $TitleY
    #>
    New-ChartInternalMarker -Options $Options -MarkerSize $MarkerSize
    New-ChartInternalZoom -Options $Options -Enabled:$Zoom

    # Default for all charts
    if ($PatternedColors) { New-ChartInternalPattern }
    if ($GradientColors) { New-ChartInternalGradient }
    New-ChartInternalTitle -Options $Options -Title $Title -TitleAlignment $TitleAlignment
    New-ChartInternalSize -Options $Options -Height $Height -Width $Width
    if ($GridOptions) { New-ChartInternalGrid -Options $Options @GridOptions }
    if ($Theme) { New-ChartInternalTheme -Options $Options @Theme }
    if ($Toolbar) { New-ChartInternalToolbar -Options $Options @Toolbar -Show $true }
    New-ApexChart -Options $Options
}
Register-ArgumentCompleter -CommandName New-HTMLChartArea -ParameterName DataLabelsColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChartArea -ParameterName LineColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChartArea -ParameterName GridColors -ScriptBlock $Script:ScriptBlockColors
function New-HTMLChartBar {
    [CmdletBinding()]
    param(
        [nullable[int]] $Height = 350,
        [nullable[int]] $Width,
        [ValidateSet('bar', 'barStacked', 'barStacked100Percent')] $Type = 'bar',
        [string[]] $Colors,

        [bool] $Horizontal = $true,
        [bool] $DataLabelsEnabled = $true,
        [int] $DataLabelsOffsetX = -6,
        [string] $DataLabelsFontSize = '12px',
        [string] $DataLabelsColor,

        [switch] $Distributed,

        #[ValidateSet('top', 'topRight', 'left', 'right', 'bottom', 'default')][string] $LegendPosition = 'default',

        [Array] $Data,
        [Array] $DataNames,
        [Array] $DataLegend,

        [System.Collections.IDictionary] $ChartAxisX,
        [System.Collections.IDictionary] $ChartAxisY,
        [System.Collections.IDictionary] $Title,
        [System.Collections.IDictionary] $SubTitle,
        [System.Collections.IDictionary] $Legend,

        [switch] $PatternedColors,
        [switch] $GradientColors,
        [System.Collections.IDictionary] $GridOptions,
        [System.Collections.IDictionary] $Toolbar,
        [System.Collections.IDictionary] $Theme,
        [Object] $Events
    )

    $Options = [ordered] @{ }
    if ($Title) {
        $Options.title = $Title
    }
    if ($SubTitle) {
        $Options.subtitle = $SubTitle
    }
    if ($Legend) {
        $Options.legend = $Legend
    }
    if ($ChartAxisX) {
        New-ChartInternalAxisX -Options $Options @ChartAxisX
    }
    if ($ChartAxisY) {
        $Options.yaxis = $ChartAxisY
    }

    New-ChartInternalBar -Options $Options -Horizontal $Horizontal -DataLabelsEnabled $DataLabelsEnabled `
        -DataLabelsOffsetX $DataLabelsOffsetX -DataLabelsFontSize $DataLabelsFontSize -DataLabelsColor $DataLabelsColor `
        -Data $Data -DataNames $DataNames -DataLegend $DataLegend `
        -Type $Type -Distributed:$Distributed

    New-ChartInternalColors -Options $Options -Colors $Colors
    # Default for all charts
    if ($PatternedColors) { New-ChartInternalPattern }
    if ($GradientColors) { New-ChartInternalGradient }

    New-ChartInternalSize -Options $Options -Height $Height -Width $Width
    if ($GridOptions) { New-ChartInternalGrid -Options $Options @GridOptions }
    if ($Theme) { New-ChartInternalTheme -Options $Options @Theme }
    if ($Toolbar) { New-ChartInternalToolbar -Options $Options @Toolbar -Show $true }
    New-ApexChart -Options $Options -Events $Events
}

Register-ArgumentCompleter -CommandName New-HTMLChartBar -ParameterName Colors -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChartBar -ParameterName DataLabelsColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLChartLine {
    [CmdletBinding()]
    param(
        [nullable[int]] $Height = 350,
        [nullable[int]] $Width,

        [bool] $DataLabelsEnabled = $true,
        [int] $DataLabelsOffsetX = -6,
        [string] $DataLabelsFontSize = '12px',
        [string[]] $DataLabelsColor,
        # [ValidateSet('datetime', 'category', 'numeric')][string] $DataCategoriesType = 'category',

        [ValidateSet('straight', 'smooth', 'stepline')][string[]] $LineCurve,
        [int[]] $LineWidth,
        [string[]] $LineColor,
        [int[]] $LineDash,
        [ValidateSet('butt', 'square', 'round')][string[]] $LineCap,

        [int] $MarkerSize,

        [Array] $Data,
        [Array] $DataNames,
        #[Array] $DataLegend,
        [System.Collections.IDictionary] $ChartAxisX,
        [System.Collections.IDictionary] $ChartAxisY,
        [System.Collections.IDictionary] $Title,
        [System.Collections.IDictionary] $SubTitle,
        [System.Collections.IDictionary] $Legend,

        [switch] $PatternedColors,
        [switch] $GradientColors,
        [System.Collections.IDictionary] $GridOptions,
        [System.Collections.IDictionary] $Toolbar,
        [System.Collections.IDictionary] $Theme,
        [Object] $Events
    )

    $Options = [ordered] @{ }
    if ($Title) {
        $Options.title = $Title
    }
    if ($SubTitle) {
        $Options.subtitle = $SubTitle
    }
    if ($Legend) {
        $Options.legend = $Legend
    }
    if ($ChartAxisX) {
        New-ChartInternalAxisX -Options $Options @ChartAxisX
    }
    if ($ChartAxisY) {
        $Options.yaxis = $ChartAxisY
    }

    New-ChartInternalLine -Options $Options -Data $Data -DataNames $DataNames

    if ($LineCurve.Count -eq 0 -or ($LineCurve.Count -ne $DataNames.Count)) {
        $LineCurve = for ($i = $LineCurve.Count; $i -le $DataNames.Count; $i++) {
            'straight'
        }
    }

    if ($LineCap.Count -eq 0 -or ($LineCap.Count -ne $DataNames.Count)) {
        $LineCap = for ($i = $LineCap.Count; $i -le $DataNames.Count; $i++) {
            'butt'
        }
    }
    if ($LineDash.Count -eq 0) {

    }

    New-ChartInternalStrokeDefinition -Options $Options `
        -LineShow $true `
        -LineCurve $LineCurve `
        -LineWidth $LineWidth `
        -LineColor $LineColor `
        -LineCap $LineCap `
        -LineDash $LineDash
    # line colors (stroke colors ) doesn't cover legend - we need to make sure it's the same even thou lines are already colored
    New-ChartInternalColors -Options $Options -Colors $LineColor
    New-ChartInternalDataLabels -Options $Options `
        -DataLabelsEnabled $DataLabelsEnabled `
        -DataLabelsOffsetX $DataLabelsOffsetX `
        -DataLabelsFontSize $DataLabelsFontSize `
        -DataLabelsColor $DataLabelsColor
    New-ChartInternalMarker -Options $Options -MarkerSize $MarkerSize

    # Default for all charts
    if ($PatternedColors) { New-ChartInternalPattern }
    if ($GradientColors) { New-ChartInternalGradient }

    New-ChartInternalSize -Options $Options -Height $Height -Width $Width
    if ($GridOptions) { New-ChartInternalGrid -Options $Options @GridOptions }
    if ($Theme) { New-ChartInternalTheme -Options $Options @Theme }
    if ($Toolbar) { New-ChartInternalToolbar -Options $Options @Toolbar -Show $true }
    New-ApexChart -Options $Options -Events $Events
}

Register-ArgumentCompleter -CommandName New-HTMLChartLine -ParameterName DataLabelsColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChartLine -ParameterName LineColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChartLine -ParameterName GridColors -ScriptBlock $Script:ScriptBlockColors
function New-HTMLChartPie {
    [CmdletBinding()]
    param(
        [string] $Type,
        [nullable[int]] $Height = 350,
        [nullable[int]] $Width,

        [bool] $DataLabelsEnabled = $true,
        [int] $DataLabelsOffsetX = -6,
        [string] $DataLabelsFontSize = '12px',
        [string[]] $DataLabelsColor,
        [Array] $Data,
        [Array] $DataNames,

        [System.Collections.IDictionary] $Title,
        [System.Collections.IDictionary] $SubTitle,
        [System.Collections.IDictionary] $Legend,

        [string[]] $Colors,

        [switch] $PatternedColors,
        [switch] $GradientColors,
        [System.Collections.IDictionary] $GridOptions,
        [System.Collections.IDictionary] $Toolbar,
        [System.Collections.IDictionary] $Theme,
        [Object] $Events

    )
    $Options = [ordered] @{ }
    if ($Title) {
        $Options.title = $Title
    }
    if ($SubTitle) {
        $Options.subtitle = $SubTitle
    }
    if ($Legend) {
        $Options.legend = $Legend
    }
    New-ChartInternalPie -Options $Options -Names $DataNames -Values $Data -Type $Type
    New-ChartInternalColors -Options $Options -Colors $Colors
    # Default for all charts
    if ($PatternedColors) { New-ChartInternalPattern }
    if ($GradientColors) { New-ChartInternalGradient }
    New-ChartInternalSize -Options $Options -Height $Height -Width $Width
    if ($GridOptions) { New-ChartInternalGrid -Options $Options @GridOptions }
    if ($Theme) { New-ChartInternalTheme -Options $Options @Theme }
    if ($Toolbar) { New-ChartInternalToolbar -Options $Options @Toolbar -Show $true }
    New-ApexChart -Options $Options -Events $Events
}

Register-ArgumentCompleter -CommandName New-HTMLChartPie -ParameterName DataLabelsColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChartPie -ParameterName Colors -ScriptBlock $Script:ScriptBlockColors
function New-HTMLChartRadial {
    [CmdletBinding()]
    param(
        [nullable[int]] $Height = 350,
        [nullable[int]] $Width,

        [Array] $DataNames,
        [Array] $Data,
        [string] $Type,
        [ValidateSet('FullCircleTop', 'FullCircleBottom', 'FullCircleBottomLeft', 'FullCircleLeft', 'Speedometer', 'SemiCircleGauge')] $CircleType = 'FullCircleTop',
        [string] $LabelAverage,

        [System.Collections.IDictionary] $Title,
        [System.Collections.IDictionary] $SubTitle,
        [System.Collections.IDictionary] $Legend,

        [string[]] $Colors,
        [switch] $PatternedColors,
        [switch] $GradientColors,
        [System.Collections.IDictionary] $GridOptions,
        [System.Collections.IDictionary] $Toolbar,
        [System.Collections.IDictionary] $Theme,
        [Object] $Events
    )

    $Options = [ordered] @{ }
    if ($Title) {
        $Options.title = $Title
    }
    if ($SubTitle) {
        $Options.subtitle = $SubTitle
    }
    if ($Legend) {
        $Options.legend = $Legend
    }

    New-ChartInternalRadial -Options $Options -Names $DataNames -Values $Data -Type $Type
    # This controls how the circle starts / left , right and so on
    New-ChartInternalRadialCircleType -Options $Options -CircleType $CircleType
    # This added label. It's useful if there's more then one data
    New-ChartInternalRadialDataLabels -Options $Options -Label $LabelAverage


    New-ChartInternalColors -Options $Options -Colors $Colors
    # Default for all charts
    if ($PatternedColors) { New-ChartInternalPattern }
    if ($GradientColors) { New-ChartInternalGradient }
    New-ChartInternalSize -Options $Options -Height $Height -Width $Width
    if ($GridOptions) { New-ChartInternalGrid -Options $Options @GridOptions }
    if ($Theme) { New-ChartInternalTheme -Options $Options @Theme }
    if ($Toolbar) { New-ChartInternalToolbar -Options $Options @Toolbar -Show $true }
    New-ApexChart -Options $Options -Events $Events
}

Register-ArgumentCompleter -CommandName New-HTMLChartRadial -ParameterName Colors -ScriptBlock $Script:ScriptBlockColors
function New-HTMLChartSpark {
    [CmdletBinding()]
    param(
        [nullable[int]] $Height = 350,
        [nullable[int]] $Width,

        [System.Collections.IDictionary] $Title,
        [System.Collections.IDictionary] $SubTitle,
        [System.Collections.IDictionary] $Legend,

        # Data to display in Spark
        [Array] $Data,
        [Array] $DataNames,

        [string[]] $Colors,

        [switch] $PatternedColors,
        [switch] $GradientColors,
        [System.Collections.IDictionary] $GridOptions,
        [System.Collections.IDictionary] $Toolbar,
        [System.Collections.IDictionary] $Theme,
        [Object] $Events
    )

    $Options = [ordered] @{ }
    if ($Title) {
        $Options.title = $Title
    }
    if ($SubTitle) {
        $Options.subtitle = $SubTitle
    }
    if ($Legend) {
        $Options.legend = $Legend
    }

    New-ChartInternalSpark -Options $Options -Color $Colors -Values $Data


    # Default for all charts
    if ($PatternedColors) { New-ChartInternalPattern }
    if ($GradientColors) { New-ChartInternalGradient }
    New-ChartInternalSize -Options $Options -Height $Height -Width $Width
    if ($GridOptions) { New-ChartInternalGrid -Options $Options @GridOptions }
    if ($Theme) { New-ChartInternalTheme -Options $Options @Theme }
    if ($Toolbar) { New-ChartInternalToolbar -Options $Options @Toolbar -Show $true }
    New-ApexChart -Options $Options -Events $Events
}

Register-ArgumentCompleter -CommandName New-HTMLChartSpark -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-HTMLChartTimeLine {
    [CmdletBinding()]
    param(
        [nullable[int]] $Height = 350,
        [nullable[int]] $Width,


        [System.Collections.IDictionary] $Title,
        [System.Collections.IDictionary] $SubTitle,
        [System.Collections.IDictionary] $Legend,

        [Array] $Data,
        <#
        [Array] $DataNames,
        [string] $TitleText,
        [string] $SubTitleText,
        [int] $FontSizeTitle = 24,
        [int] $FontSizeSubtitle = 14,
        [string] $Color,
        #>
        [switch] $PatternedColors,
        [switch] $GradientColors,

        [System.Collections.IDictionary] $GridOptions,
        [System.Collections.IDictionary] $Toolbar,
        [System.Collections.IDictionary] $Theme,

        [System.Collections.IDictionary] $ChartAxisX,
        [System.Collections.IDictionary] $ChartAxisY,

        [System.Collections.IDictionary] $ChartToolTip,
        [System.Collections.IDictionary] $DataLabel,
        [Object] $Events
    )
    $Options = [ordered] @{}
    if ($Title) {
        $Options.title = $Title
    }
    if ($SubTitle) {
        $Options.subtitle = $SubTitle
    }
    if ($ChartAxisX) {
        $ChartAxisX.type = "datetime"
        New-ChartInternalAxisX -Options $Options @ChartAxisX
    } else {
        $ChartAxisX = @{
            Type = "datetime"
        }
        New-ChartInternalAxisX -Options $Options @ChartAxisX
    }
    if ($ChartAxisY) {
        $Options.yaxis = $ChartAxisY
    }
    if ($Legend) {
        $Options.legend = $Legend
    }
    if ($ChartToolTip) {
        New-ChartInternalToolTip -Options $Options @ChartToolTip
    }
    if ($DataLabel) {
        $Options.dataLabels = $DataLabel
    }

    New-ChartInternalTimeLine -Options $Options -Color $Color -Data $Data

    # Default for all charts
    if ($PatternedColors) { New-ChartInternalPattern }
    if ($GradientColors) { New-ChartInternalGradient }
    New-ChartInternalSize -Options $Options -Height $Height -Width $Width
    if ($GridOptions) { New-ChartInternalGrid -Options $Options @GridOptions }
    if ($Theme) { New-ChartInternalTheme -Options $Options @Theme }
    if ($Toolbar) { New-ChartInternalToolbar -Options $Options @Toolbar -Show $true }
    New-ApexChart -Options $Options -Events $Events
}

Register-ArgumentCompleter -CommandName New-HTMLChartSpark -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
$Script:RGBColors = [ordered] @{
    None                   = $null
    AirForceBlue           = 93, 138, 168
    Akaroa                 = 195, 176, 145
    AlbescentWhite         = 227, 218, 201
    AliceBlue              = 240, 248, 255
    Alizarin               = 227, 38, 54
    Allports               = 18, 97, 128
    Almond                 = 239, 222, 205
    AlmondFrost            = 159, 129, 112
    Amaranth               = 229, 43, 80
    Amazon                 = 59, 122, 87
    Amber                  = 255, 191, 0
    Amethyst               = 153, 102, 204
    AmethystSmoke          = 156, 138, 164
    AntiqueWhite           = 250, 235, 215
    Apple                  = 102, 180, 71
    AppleBlossom           = 176, 92, 82
    Apricot                = 251, 206, 177
    Aqua                   = 0, 255, 255
    Aquamarine             = 127, 255, 212
    Armygreen              = 75, 83, 32
    Arsenic                = 59, 68, 75
    Astral                 = 54, 117, 136
    Atlantis               = 164, 198, 57
    Atomic                 = 65, 74, 76
    AtomicTangerine        = 255, 153, 102
    Axolotl                = 99, 119, 91
    Azure                  = 240, 255, 255
    Bahia                  = 176, 191, 26
    BakersChocolate        = 93, 58, 26
    BaliHai                = 124, 152, 171
    BananaMania            = 250, 231, 181
    BattleshipGrey         = 85, 93, 80
    BayOfMany              = 35, 48, 103
    Beige                  = 245, 245, 220
    Bermuda                = 136, 216, 192
    Bilbao                 = 42, 128, 0
    BilobaFlower           = 181, 126, 220
    Bismark                = 83, 104, 114
    Bisque                 = 255, 228, 196
    Bistre                 = 61, 43, 31
    Bittersweet            = 254, 111, 94
    Black                  = 0, 0, 0
    BlackPearl             = 31, 38, 42
    BlackRose              = 85, 31, 47
    BlackRussian           = 23, 24, 43
    BlanchedAlmond         = 255, 235, 205
    BlizzardBlue           = 172, 229, 238
    Blue                   = 0, 0, 255
    BlueDiamond            = 77, 26, 127
    BlueMarguerite         = 115, 102, 189
    BlueSmoke              = 115, 130, 118
    BlueViolet             = 138, 43, 226
    Blush                  = 169, 92, 104
    BokaraGrey             = 22, 17, 13
    Bole                   = 121, 68, 59
    BondiBlue              = 0, 147, 175
    Bordeaux               = 88, 17, 26
    Bossanova              = 86, 60, 92
    Boulder                = 114, 116, 114
    Bouquet                = 183, 132, 167
    Bourbon                = 170, 108, 57
    Brass                  = 181, 166, 66
    BrickRed               = 199, 44, 72
    BrightGreen            = 102, 255, 0
    BrightRed              = 146, 43, 62
    BrightTurquoise        = 8, 232, 222
    BrilliantRose          = 243, 100, 162
    BrinkPink              = 250, 110, 121
    BritishRacingGreen     = 0, 66, 37
    Bronze                 = 205, 127, 50
    Brown                  = 165, 42, 42
    BrownPod               = 57, 24, 2
    BuddhaGold             = 202, 169, 6
    Buff                   = 240, 220, 130
    Burgundy               = 128, 0, 32
    BurlyWood              = 222, 184, 135
    BurntOrange            = 255, 117, 56
    BurntSienna            = 233, 116, 81
    BurntUmber             = 138, 51, 36
    ButteredRum            = 156, 124, 56
    CadetBlue              = 95, 158, 160
    California             = 224, 141, 60
    CamouflageGreen        = 120, 134, 107
    Canary                 = 255, 255, 153
    CanCan                 = 217, 134, 149
    CannonPink             = 145, 78, 117
    CaputMortuum           = 89, 39, 32
    Caramel                = 255, 213, 154
    Cararra                = 237, 230, 214
    Cardinal               = 179, 33, 52
    CardinGreen            = 18, 53, 36
    CareysPink             = 217, 152, 160
    CaribbeanGreen         = 0, 222, 164
    Carmine                = 175, 0, 42
    CarnationPink          = 255, 166, 201
    CarrotOrange           = 242, 142, 28
    Cascade                = 141, 163, 153
    CatskillWhite          = 226, 229, 222
    Cedar                  = 67, 48, 46
    Celadon                = 172, 225, 175
    Celeste                = 207, 207, 196
    Cello                  = 55, 79, 107
    Cement                 = 138, 121, 93
    Cerise                 = 222, 49, 99
    Cerulean               = 0, 123, 167
    CeruleanBlue           = 42, 82, 190
    Chantilly              = 239, 187, 204
    Chardonnay             = 255, 200, 124
    Charlotte              = 167, 216, 222
    Charm                  = 208, 116, 139
    Chartreuse             = 127, 255, 0
    ChartreuseYellow       = 223, 255, 0
    ChelseaCucumber        = 135, 169, 107
    Cherub                 = 246, 214, 222
    Chestnut               = 185, 78, 72
    ChileanFire            = 226, 88, 34
    Chinook                = 150, 200, 162
    Chocolate              = 210, 105, 30
    Christi                = 125, 183, 0
    Christine              = 181, 101, 30
    Cinnabar               = 235, 76, 66
    Citron                 = 159, 169, 31
    Citrus                 = 141, 182, 0
    Claret                 = 95, 25, 51
    ClassicRose            = 251, 204, 231
    ClayCreek              = 145, 129, 81
    Clinker                = 75, 54, 33
    Clover                 = 74, 93, 35
    Cobalt                 = 0, 71, 171
    CocoaBrown             = 44, 22, 8
    Cola                   = 60, 48, 36
    ColumbiaBlue           = 166, 231, 255
    CongoBrown             = 103, 76, 71
    Conifer                = 178, 236, 93
    Copper                 = 218, 138, 103
    CopperRose             = 153, 102, 102
    Coral                  = 255, 127, 80
    CoralRed               = 255, 64, 64
    CoralTree              = 173, 111, 105
    Coriander              = 188, 184, 138
    Corn                   = 251, 236, 93
    CornField              = 250, 240, 190
    Cornflower             = 147, 204, 234
    CornflowerBlue         = 100, 149, 237
    Cornsilk               = 255, 248, 220
    Cosmic                 = 132, 63, 91
    Cosmos                 = 255, 204, 203
    CostaDelSol            = 102, 93, 30
    CottonCandy            = 255, 188, 217
    Crail                  = 164, 90, 82
    Cranberry              = 205, 96, 126
    Cream                  = 255, 255, 204
    CreamCan               = 242, 198, 73
    Crimson                = 220, 20, 60
    Crusta                 = 232, 142, 90
    Cumulus                = 255, 255, 191
    Cupid                  = 246, 173, 198
    CuriousBlue            = 40, 135, 200
    Cyan                   = 0, 255, 255
    Cyprus                 = 6, 78, 64
    DaisyBush              = 85, 53, 146
    Dandelion              = 250, 218, 94
    Danube                 = 96, 130, 182
    DarkBlue               = 0, 0, 139
    DarkBrown              = 101, 67, 33
    DarkCerulean           = 8, 69, 126
    DarkChestnut           = 152, 105, 96
    DarkCoral              = 201, 90, 73
    DarkCyan               = 0, 139, 139
    DarkGoldenrod          = 184, 134, 11
    DarkGray               = 169, 169, 169
    DarkGreen              = 0, 100, 0
    DarkGreenCopper        = 73, 121, 107
    DarkGrey               = 169, 169, 169
    DarkKhaki              = 189, 183, 107
    DarkMagenta            = 139, 0, 139
    DarkOliveGreen         = 85, 107, 47
    DarkOrange             = 255, 140, 0
    DarkOrchid             = 153, 50, 204
    DarkPastelGreen        = 3, 192, 60
    DarkPink               = 222, 93, 131
    DarkPurple             = 150, 61, 127
    DarkRed                = 139, 0, 0
    DarkSalmon             = 233, 150, 122
    DarkSeaGreen           = 143, 188, 143
    DarkSlateBlue          = 72, 61, 139
    DarkSlateGray          = 47, 79, 79
    DarkSlateGrey          = 47, 79, 79
    DarkSpringGreen        = 23, 114, 69
    DarkTangerine          = 255, 170, 29
    DarkTurquoise          = 0, 206, 209
    DarkViolet             = 148, 0, 211
    DarkWood               = 130, 102, 68
    DeepBlush              = 245, 105, 145
    DeepCerise             = 224, 33, 138
    DeepKoamaru            = 51, 51, 102
    DeepLilac              = 153, 85, 187
    DeepMagenta            = 204, 0, 204
    DeepPink               = 255, 20, 147
    DeepSea                = 14, 124, 97
    DeepSkyBlue            = 0, 191, 255
    DeepTeal               = 24, 69, 59
    Denim                  = 36, 107, 206
    DesertSand             = 237, 201, 175
    DimGray                = 105, 105, 105
    DimGrey                = 105, 105, 105
    DodgerBlue             = 30, 144, 255
    Dolly                  = 242, 242, 122
    Downy                  = 95, 201, 191
    DutchWhite             = 239, 223, 187
    EastBay                = 76, 81, 109
    EastSide               = 178, 132, 190
    EchoBlue               = 169, 178, 195
    Ecru                   = 194, 178, 128
    Eggplant               = 162, 0, 109
    EgyptianBlue           = 16, 52, 166
    ElectricBlue           = 125, 249, 255
    ElectricIndigo         = 111, 0, 255
    ElectricLime           = 208, 255, 20
    ElectricPurple         = 191, 0, 255
    Elm                    = 47, 132, 124
    Emerald                = 80, 200, 120
    Eminence               = 108, 48, 130
    Endeavour              = 46, 88, 148
    EnergyYellow           = 245, 224, 80
    Espresso               = 74, 44, 42
    Eucalyptus             = 26, 162, 96
    Falcon                 = 126, 94, 96
    Fallow                 = 204, 153, 102
    FaluRed                = 128, 24, 24
    Feldgrau               = 77, 93, 83
    Feldspar               = 205, 149, 117
    Fern                   = 113, 188, 120
    FernGreen              = 79, 121, 66
    Festival               = 236, 213, 64
    Finn                   = 97, 64, 81
    FireBrick              = 178, 34, 34
    FireBush               = 222, 143, 78
    FireEngineRed          = 211, 33, 45
    Flamingo               = 233, 92, 75
    Flax                   = 238, 220, 130
    FloralWhite            = 255, 250, 240
    ForestGreen            = 34, 139, 34
    Frangipani             = 250, 214, 165
    FreeSpeechAquamarine   = 0, 168, 119
    FreeSpeechRed          = 204, 0, 0
    FrenchLilac            = 230, 168, 215
    FrenchRose             = 232, 83, 149
    FriarGrey              = 135, 134, 129
    Froly                  = 228, 113, 122
    Fuchsia                = 255, 0, 255
    FuchsiaPink            = 255, 119, 255
    Gainsboro              = 220, 220, 220
    Gallery                = 219, 215, 210
    Galliano               = 204, 160, 29
    Gamboge                = 204, 153, 0
    Ghost                  = 196, 195, 208
    GhostWhite             = 248, 248, 255
    Gin                    = 216, 228, 188
    GinFizz                = 247, 231, 206
    Givry                  = 230, 208, 171
    Glacier                = 115, 169, 194
    Gold                   = 255, 215, 0
    GoldDrop               = 213, 108, 43
    GoldenBrown            = 150, 113, 23
    GoldenFizz             = 240, 225, 48
    GoldenGlow             = 248, 222, 126
    GoldenPoppy            = 252, 194, 0
    Goldenrod              = 218, 165, 32
    GoldenSand             = 233, 214, 107
    GoldenYellow           = 253, 238, 0
    GoldTips               = 225, 189, 39
    GordonsGreen           = 37, 53, 41
    Gorse                  = 255, 225, 53
    Gossamer               = 49, 145, 119
    GrannySmithApple       = 168, 228, 160
    Gray                   = 128, 128, 128
    GrayAsparagus          = 70, 89, 69
    Green                  = 0, 128, 0
    GreenLeaf              = 76, 114, 29
    GreenVogue             = 38, 67, 72
    GreenYellow            = 173, 255, 47
    Grey                   = 128, 128, 128
    GreyAsparagus          = 70, 89, 69
    GuardsmanRed           = 157, 41, 51
    GumLeaf                = 178, 190, 181
    Gunmetal               = 42, 52, 57
    Hacienda               = 155, 135, 12
    HalfAndHalf            = 232, 228, 201
    HalfBaked              = 95, 138, 139
    HalfColonialWhite      = 246, 234, 190
    HalfPearlLusta         = 240, 234, 214
    HanPurple              = 63, 0, 255
    Harlequin              = 74, 255, 0
    HarleyDavidsonOrange   = 194, 59, 34
    Heather                = 174, 198, 207
    Heliotrope             = 223, 115, 255
    Hemp                   = 161, 122, 116
    Highball               = 134, 126, 54
    HippiePink             = 171, 75, 82
    Hoki                   = 110, 127, 128
    HollywoodCerise        = 244, 0, 161
    Honeydew               = 240, 255, 240
    Hopbush                = 207, 113, 175
    HorsesNeck             = 108, 84, 30
    HotPink                = 255, 105, 180
    HummingBird            = 201, 255, 229
    HunterGreen            = 53, 94, 59
    Illusion               = 244, 152, 173
    InchWorm               = 202, 224, 13
    IndianRed              = 205, 92, 92
    Indigo                 = 75, 0, 130
    InternationalKleinBlue = 0, 24, 168
    InternationalOrange    = 255, 79, 0
    IrisBlue               = 28, 169, 201
    IrishCoffee            = 102, 66, 40
    IronsideGrey           = 113, 112, 110
    IslamicGreen           = 0, 144, 0
    Ivory                  = 255, 255, 240
    Jacarta                = 61, 50, 93
    JackoBean              = 65, 54, 40
    JacksonsPurple         = 46, 45, 136
    Jade                   = 0, 171, 102
    JapaneseLaurel         = 47, 117, 50
    Jazz                   = 93, 43, 44
    JazzberryJam           = 165, 11, 94
    JellyBean              = 68, 121, 142
    JetStream              = 187, 208, 201
    Jewel                  = 0, 107, 60
    Jon                    = 79, 58, 60
    JordyBlue              = 124, 185, 232
    Jumbo                  = 132, 132, 130
    JungleGreen            = 41, 171, 135
    KaitokeGreen           = 30, 77, 43
    Karry                  = 255, 221, 202
    KellyGreen             = 70, 203, 24
    Keppel                 = 93, 164, 147
    Khaki                  = 240, 230, 140
    Killarney              = 77, 140, 87
    KingfisherDaisy        = 85, 27, 140
    Kobi                   = 230, 143, 172
    LaPalma                = 60, 141, 13
    LaserLemon             = 252, 247, 94
    Laurel                 = 103, 146, 103
    Lavender               = 230, 230, 250
    LavenderBlue           = 204, 204, 255
    LavenderBlush          = 255, 240, 245
    LavenderPink           = 251, 174, 210
    LavenderRose           = 251, 160, 227
    LawnGreen              = 124, 252, 0
    LemonChiffon           = 255, 250, 205
    LightBlue              = 173, 216, 230
    LightCoral             = 240, 128, 128
    LightCyan              = 224, 255, 255
    LightGoldenrodYellow   = 250, 250, 210
    LightGray              = 211, 211, 211
    LightGreen             = 144, 238, 144
    LightGrey              = 211, 211, 211
    LightPink              = 255, 182, 193
    LightSalmon            = 255, 160, 122
    LightSeaGreen          = 32, 178, 170
    LightSkyBlue           = 135, 206, 250
    LightSlateGray         = 119, 136, 153
    LightSlateGrey         = 119, 136, 153
    LightSteelBlue         = 176, 196, 222
    LightYellow            = 255, 255, 224
    Lilac                  = 204, 153, 204
    Lime                   = 0, 255, 0
    LimeGreen              = 50, 205, 50
    Limerick               = 139, 190, 27
    Linen                  = 250, 240, 230
    Lipstick               = 159, 43, 104
    Liver                  = 83, 75, 79
    Lochinvar              = 86, 136, 125
    Lochmara               = 38, 97, 156
    Lola                   = 179, 158, 181
    LondonHue              = 170, 152, 169
    Lotus                  = 124, 72, 72
    LuckyPoint             = 29, 41, 81
    MacaroniAndCheese      = 255, 189, 136
    Madang                 = 193, 249, 162
    Madras                 = 81, 65, 0
    Magenta                = 255, 0, 255
    MagicMint              = 170, 240, 209
    Magnolia               = 248, 244, 255
    Mahogany               = 215, 59, 62
    Maire                  = 27, 24, 17
    Maize                  = 230, 190, 138
    Malachite              = 11, 218, 81
    Malibu                 = 93, 173, 236
    Malta                  = 169, 154, 134
    Manatee                = 140, 146, 172
    Mandalay               = 176, 121, 57
    MandarianOrange        = 146, 39, 36
    Mandy                  = 191, 79, 81
    Manhattan              = 229, 170, 112
    Mantis                 = 125, 194, 66
    Manz                   = 217, 230, 80
    MardiGras              = 48, 25, 52
    Mariner                = 57, 86, 156
    Maroon                 = 128, 0, 0
    Matterhorn             = 85, 85, 85
    Mauve                  = 244, 187, 255
    Mauvelous              = 255, 145, 175
    MauveTaupe             = 143, 89, 115
    MayaBlue               = 119, 181, 254
    McKenzie               = 129, 97, 60
    MediumAquamarine       = 102, 205, 170
    MediumBlue             = 0, 0, 205
    MediumCarmine          = 175, 64, 53
    MediumOrchid           = 186, 85, 211
    MediumPurple           = 147, 112, 219
    MediumRedViolet        = 189, 51, 164
    MediumSeaGreen         = 60, 179, 113
    MediumSlateBlue        = 123, 104, 238
    MediumSpringGreen      = 0, 250, 154
    MediumTurquoise        = 72, 209, 204
    MediumVioletRed        = 199, 21, 133
    MediumWood             = 166, 123, 91
    Melon                  = 253, 188, 180
    Merlot                 = 112, 54, 66
    MetallicGold           = 211, 175, 55
    Meteor                 = 184, 115, 51
    MidnightBlue           = 25, 25, 112
    MidnightExpress        = 0, 20, 64
    Mikado                 = 60, 52, 31
    MilanoRed              = 168, 55, 49
    Ming                   = 54, 116, 125
    MintCream              = 245, 255, 250
    MintGreen              = 152, 255, 152
    Mischka                = 168, 169, 173
    MistyRose              = 255, 228, 225
    Moccasin               = 255, 228, 181
    Mojo                   = 149, 69, 53
    MonaLisa               = 255, 153, 153
    Mongoose               = 179, 139, 109
    Montana                = 53, 56, 57
    MoodyBlue              = 116, 108, 192
    MoonYellow             = 245, 199, 26
    MossGreen              = 173, 223, 173
    MountainMeadow         = 28, 172, 120
    MountainMist           = 161, 157, 148
    MountbattenPink        = 153, 122, 141
    Mulberry               = 211, 65, 157
    Mustard                = 255, 219, 88
    Myrtle                 = 25, 89, 5
    MySin                  = 255, 179, 71
    NavajoWhite            = 255, 222, 173
    Navy                   = 0, 0, 128
    NavyBlue               = 2, 71, 254
    NeonCarrot             = 255, 153, 51
    NeonPink               = 255, 92, 205
    Nepal                  = 145, 163, 176
    Nero                   = 20, 20, 20
    NewMidnightBlue        = 0, 0, 156
    Niagara                = 58, 176, 158
    NightRider             = 59, 47, 47
    Nobel                  = 152, 152, 152
    Norway                 = 169, 186, 157
    Nugget                 = 183, 135, 39
    OceanGreen             = 95, 167, 120
    Ochre                  = 202, 115, 9
    OldCopper              = 111, 78, 55
    OldGold                = 207, 181, 59
    OldLace                = 253, 245, 230
    OldLavender            = 121, 104, 120
    OldRose                = 195, 33, 72
    Olive                  = 128, 128, 0
    OliveDrab              = 107, 142, 35
    OliveGreen             = 181, 179, 92
    Olivetone              = 110, 110, 48
    Olivine                = 154, 185, 115
    Onahau                 = 196, 216, 226
    Opal                   = 168, 195, 188
    Orange                 = 255, 165, 0
    OrangePeel             = 251, 153, 2
    OrangeRed              = 255, 69, 0
    Orchid                 = 218, 112, 214
    OuterSpace             = 45, 56, 58
    OutrageousOrange       = 254, 90, 29
    Oxley                  = 95, 167, 119
    PacificBlue            = 0, 136, 220
    Padua                  = 128, 193, 151
    PalatinatePurple       = 112, 41, 99
    PaleBrown              = 160, 120, 90
    PaleChestnut           = 221, 173, 175
    PaleCornflowerBlue     = 188, 212, 230
    PaleGoldenrod          = 238, 232, 170
    PaleGreen              = 152, 251, 152
    PaleMagenta            = 249, 132, 239
    PalePink               = 250, 218, 221
    PaleSlate              = 201, 192, 187
    PaleTaupe              = 188, 152, 126
    PaleTurquoise          = 175, 238, 238
    PaleVioletRed          = 219, 112, 147
    PalmLeaf               = 53, 66, 48
    Panache                = 233, 255, 219
    PapayaWhip             = 255, 239, 213
    ParisDaisy             = 255, 244, 79
    Parsley                = 48, 96, 48
    PastelGreen            = 119, 221, 119
    PattensBlue            = 219, 233, 244
    Peach                  = 255, 203, 164
    PeachOrange            = 255, 204, 153
    PeachPuff              = 255, 218, 185
    PeachYellow            = 250, 223, 173
    Pear                   = 209, 226, 49
    PearlLusta             = 234, 224, 200
    Pelorous               = 42, 143, 189
    Perano                 = 172, 172, 230
    Periwinkle             = 197, 203, 225
    PersianBlue            = 34, 67, 182
    PersianGreen           = 0, 166, 147
    PersianIndigo          = 51, 0, 102
    PersianPink            = 247, 127, 190
    PersianRed             = 192, 54, 44
    PersianRose            = 233, 54, 167
    Persimmon              = 236, 88, 0
    Peru                   = 205, 133, 63
    Pesto                  = 128, 117, 50
    PictonBlue             = 102, 153, 204
    PigmentGreen           = 0, 173, 67
    PigPink                = 255, 218, 233
    PineGreen              = 1, 121, 111
    PineTree               = 42, 47, 35
    Pink                   = 255, 192, 203
    PinkFlare              = 191, 175, 178
    PinkLace               = 240, 211, 220
    PinkSwan               = 179, 179, 179
    Plum                   = 221, 160, 221
    Pohutukawa             = 102, 12, 33
    PoloBlue               = 119, 158, 203
    Pompadour              = 129, 20, 83
    Portage                = 146, 161, 207
    PotPourri              = 241, 221, 207
    PottersClay            = 132, 86, 60
    PowderBlue             = 176, 224, 230
    Prim                   = 228, 196, 207
    PrussianBlue           = 0, 58, 108
    PsychedelicPurple      = 223, 0, 255
    Puce                   = 204, 136, 153
    Pueblo                 = 108, 46, 31
    PuertoRico             = 67, 179, 174
    Pumpkin                = 255, 99, 28
    Purple                 = 128, 0, 128
    PurpleMountainsMajesty = 150, 123, 182
    PurpleTaupe            = 93, 57, 84
    QuarterSpanishWhite    = 230, 224, 212
    Quartz                 = 220, 208, 255
    Quincy                 = 106, 84, 69
    RacingGreen            = 26, 36, 33
    RadicalRed             = 255, 32, 82
    Rajah                  = 251, 171, 96
    RawUmber               = 123, 63, 0
    RazzleDazzleRose       = 254, 78, 218
    Razzmatazz             = 215, 10, 83
    Red                    = 255, 0, 0
    RedBerry               = 132, 22, 23
    RedDamask              = 203, 109, 81
    RedOxide               = 99, 15, 15
    RedRobin               = 128, 64, 64
    RichBlue               = 84, 90, 167
    Riptide                = 141, 217, 204
    RobinsEggBlue          = 0, 204, 204
    RobRoy                 = 225, 169, 95
    RockSpray              = 171, 56, 31
    RomanCoffee            = 131, 105, 83
    RoseBud                = 246, 164, 148
    RoseBudCherry          = 135, 50, 96
    RoseTaupe              = 144, 93, 93
    RosyBrown              = 188, 143, 143
    Rouge                  = 176, 48, 96
    RoyalBlue              = 65, 105, 225
    RoyalHeath             = 168, 81, 110
    RoyalPurple            = 102, 51, 152
    Ruby                   = 215, 24, 104
    Russet                 = 128, 70, 27
    Rust                   = 192, 64, 0
    RusticRed              = 72, 6, 7
    Saddle                 = 99, 81, 71
    SaddleBrown            = 139, 69, 19
    SafetyOrange           = 255, 102, 0
    Saffron                = 244, 196, 48
    Sage                   = 143, 151, 121
    Sail                   = 161, 202, 241
    Salem                  = 0, 133, 67
    Salmon                 = 250, 128, 114
    SandyBeach             = 253, 213, 177
    SandyBrown             = 244, 164, 96
    Sangria                = 134, 1, 17
    SanguineBrown          = 115, 54, 53
    SanMarino              = 80, 114, 167
    SanteFe                = 175, 110, 77
    Sapphire               = 6, 42, 120
    Saratoga               = 84, 90, 44
    Scampi                 = 102, 102, 153
    Scarlet                = 255, 36, 0
    ScarletGum             = 67, 28, 83
    SchoolBusYellow        = 255, 216, 0
    Schooner               = 139, 134, 128
    ScreaminGreen          = 102, 255, 102
    Scrub                  = 59, 60, 54
    SeaBuckthorn           = 249, 146, 69
    SeaGreen               = 46, 139, 87
    Seagull                = 140, 190, 214
    SealBrown              = 61, 12, 2
    Seance                 = 96, 47, 107
    SeaPink                = 215, 131, 127
    SeaShell               = 255, 245, 238
    Selago                 = 250, 230, 250
    SelectiveYellow        = 242, 180, 0
    SemiSweetChocolate     = 107, 68, 35
    Sepia                  = 150, 90, 62
    Serenade               = 255, 233, 209
    Shadow                 = 133, 109, 77
    Shakespeare            = 114, 160, 193
    Shalimar               = 252, 255, 164
    Shamrock               = 68, 215, 168
    ShamrockGreen          = 0, 153, 102
    SherpaBlue             = 0, 75, 73
    SherwoodGreen          = 27, 77, 62
    Shilo                  = 222, 165, 164
    ShipCove               = 119, 139, 165
    Shocking               = 241, 156, 187
    ShockingPink           = 255, 29, 206
    ShuttleGrey            = 84, 98, 111
    Sidecar                = 238, 224, 177
    Sienna                 = 160, 82, 45
    Silk                   = 190, 164, 147
    Silver                 = 192, 192, 192
    SilverChalice          = 175, 177, 174
    SilverTree             = 102, 201, 146
    SkyBlue                = 135, 206, 235
    SlateBlue              = 106, 90, 205
    SlateGray              = 112, 128, 144
    SlateGrey              = 112, 128, 144
    Smalt                  = 0, 48, 143
    SmaltBlue              = 74, 100, 108
    Snow                   = 255, 250, 250
    SoftAmber              = 209, 190, 168
    Solitude               = 235, 236, 240
    Sorbus                 = 233, 105, 44
    Spectra                = 53, 101, 77
    SpicyMix               = 136, 101, 78
    Spray                  = 126, 212, 230
    SpringBud              = 150, 255, 0
    SpringGreen            = 0, 255, 127
    SpringSun              = 236, 235, 189
    SpunPearl              = 170, 169, 173
    Stack                  = 130, 142, 132
    SteelBlue              = 70, 130, 180
    Stiletto               = 137, 63, 69
    Strikemaster           = 145, 92, 131
    StTropaz               = 50, 82, 123
    Studio                 = 115, 79, 150
    Sulu                   = 201, 220, 135
    SummerSky              = 33, 171, 205
    Sun                    = 237, 135, 45
    Sundance               = 197, 179, 88
    Sunflower              = 228, 208, 10
    Sunglow                = 255, 204, 51
    SunsetOrange           = 253, 82, 64
    SurfieGreen            = 0, 116, 116
    Sushi                  = 111, 153, 64
    SuvaGrey               = 140, 140, 140
    Swamp                  = 35, 43, 43
    SweetCorn              = 253, 219, 109
    SweetPink              = 243, 153, 152
    Tacao                  = 236, 177, 118
    TahitiGold             = 235, 97, 35
    Tan                    = 210, 180, 140
    Tangaroa               = 0, 28, 61
    Tangerine              = 228, 132, 0
    TangerineYellow        = 253, 204, 13
    Tapestry               = 183, 110, 121
    Taupe                  = 72, 60, 50
    TaupeGrey              = 139, 133, 137
    TawnyPort              = 102, 66, 77
    TaxBreak               = 79, 102, 106
    TeaGreen               = 208, 240, 192
    Teak                   = 176, 141, 87
    Teal                   = 0, 128, 128
    TeaRose                = 255, 133, 207
    Temptress              = 60, 20, 33
    Tenne                  = 200, 101, 0
    TerraCotta             = 226, 114, 91
    Thistle                = 216, 191, 216
    TickleMePink           = 245, 111, 161
    Tidal                  = 232, 244, 140
    TitanWhite             = 214, 202, 221
    Toast                  = 165, 113, 100
    Tomato                 = 255, 99, 71
    TorchRed               = 255, 3, 62
    ToryBlue               = 54, 81, 148
    Tradewind              = 110, 174, 161
    TrendyPink             = 133, 96, 136
    TropicalRainForest     = 0, 127, 102
    TrueV                  = 139, 114, 190
    TulipTree              = 229, 183, 59
    Tumbleweed             = 222, 170, 136
    Turbo                  = 255, 195, 36
    TurkishRose            = 152, 119, 123
    Turquoise              = 64, 224, 208
    TurquoiseBlue          = 118, 215, 234
    Tuscany                = 175, 89, 62
    TwilightBlue           = 253, 255, 245
    Twine                  = 186, 135, 89
    TyrianPurple           = 102, 2, 60
    Ultramarine            = 10, 17, 149
    UltraPink              = 255, 111, 255
    Valencia               = 222, 82, 70
    VanCleef               = 84, 61, 55
    VanillaIce             = 229, 204, 201
    VenetianRed            = 209, 0, 28
    Venus                  = 138, 127, 128
    Vermilion              = 251, 79, 20
    VeryLightGrey          = 207, 207, 207
    VidaLoca               = 94, 140, 49
    Viking                 = 71, 171, 204
    Viola                  = 180, 131, 149
    ViolentViolet          = 50, 23, 77
    Violet                 = 238, 130, 238
    VioletRed              = 255, 57, 136
    Viridian               = 64, 130, 109
    VistaBlue              = 159, 226, 191
    VividViolet            = 127, 62, 152
    WaikawaGrey            = 83, 104, 149
    Wasabi                 = 150, 165, 60
    Watercourse            = 0, 106, 78
    Wedgewood              = 67, 107, 149
    WellRead               = 147, 61, 65
    Wewak                  = 255, 152, 153
    Wheat                  = 245, 222, 179
    Whiskey                = 217, 154, 108
    WhiskeySour            = 217, 144, 88
    White                  = 255, 255, 255
    WhiteSmoke             = 245, 245, 245
    WildRice               = 228, 217, 111
    WildSand               = 229, 228, 226
    WildStrawberry         = 252, 65, 154
    WildWatermelon         = 255, 84, 112
    WildWillow             = 172, 191, 96
    Windsor                = 76, 40, 130
    Wisteria               = 191, 148, 228
    Wistful                = 162, 162, 208
    Yellow                 = 255, 255, 0
    YellowGreen            = 154, 205, 50
    YellowOrange           = 255, 174, 66
    YourPink               = 244, 194, 194
}
$Script:ScriptBlockColors = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $Script:RGBColors.Keys | Where-Object { $_ -like "*$wordToComplete*" }
}
function Add-CustomFormatForDatetimeSorting {
    <#
    .SYNOPSIS

    .DESCRIPTION
        This function adds code to make the datatable columns sortable with different datetime formats.
        Formatting:
        Day (of Month)
        D       -   1 2 ... 30 31
        Do      -   1st 2nd ... 30th 31st
        DD      -   01 02 ... 30 31

        Month
        M       -   1 2 ... 11 12
        Mo      -   1st 2nd ... 11th 12th
        MM      -   01 02 ... 11 12
        MMM     -   Jan Feb ... Nov Dec
        MMMM    -   January February ... November December

        Year
        YY      -   70 71 ... 29 30
        YYYY    -   1970 1971 ... 2029 2030

        Hour
        H       -   0 1 ... 22 23
        HH      -   00 01 ... 22 23
        h       -   1 2 ... 11 12
        hh      -   01 02 ... 11 12

        Minute
        m       -   0 1 ... 58 59
        mm      -   00 01 ... 58 59

        Second
        s       -   0 1 ... 58 59
        ss      -   00 01 ... 58 59

        More formats
        http://momentjs.com/docs/#/displaying/

    .PARAMETER CustomDateTimeFormat
        Array with strings of custom datetime format.
        The string is build from two parts. Format and locale. Locale is optional.
        format explanation: http://momentjs.com/docs/#/displaying/
        locale explanation: http://momentjs.com/docs/#/i18n/


    .LINK
        format explanation: http://momentjs.com/docs/#/displaying/
        locale explanation: http://momentjs.com/docs/#/i18n/
    .Example
        Add-CustomFormatForDatetimeSorting -CustomDateFormat 'dddd, MMMM Do, YYYY','HH:mm MMM D, YY'
    .Example
        Add-CustomFormatForDatetimeSorting -CustomDateFormat 'DD.MM.YYYY HH:mm:ss'
    #>
    [CmdletBinding()]
    param(
        [array]$DateTimeSortingFormat
    )
    if ($DateTimeSortingFormat) {
        [array]$OutputDateTimeSortingFormat = foreach ($format in $DateTimeSortingFormat) {
            "$.fn.dataTable.moment( '$format' );"
        }
    } else {
        # Default localized format
        $OutputDateTimeSortingFormat = "$.fn.dataTable.moment( 'L' );"
    }
    return $OutputDateTimeSortingFormat
}

function Add-TableContent {
    [CmdletBinding()]
    param(
        [System.Collections.Generic.List[PSCustomObject]] $ContentRows,
        [System.Collections.Generic.List[PSCUstomObject]] $ContentStyle,
        [System.Collections.Generic.List[PSCUstomObject]] $ContentTop,
        [System.Collections.Generic.List[PSCUstomObject]] $ContentFormattingInline,
        [string[]] $HeaderNames,
        [Array] $Table
    )

    # This converts inline conditonal formatting into style. It's intensive because it actually scans whole Table
    # During scan it tries to match things and when it finds a match it prepares it for ContentStyling feature
    if ($ContentFormattingInline.Count -gt 0) {
        [Array] $AddStyles = for ($RowCount = 1; $RowCount -lt $Table.Count; $RowCount++) {
            [string[]] $RowData = $Table[$RowCount] -replace '</td></tr>' -replace '<tr><td>' -split '</td><td>'
            foreach ($ConditionalFormatting in $ContentFormattingInline) {
                $Pass = $false
                if ($ConditionalFormatting.ConditionType -eq 'Condition') {
                    $ColumnIndexHeader = [array]::indexof($HeaderNames.ToUpper(), $($ConditionalFormatting.Name).ToUpper())
                    for ($ColumnCount = 0; $ColumnCount -lt $RowData.Count; $ColumnCount++) {
                        #Write-Color "1ColumnCount $ColumnCount / $RowCount"
                        if ($ColumnIndexHeader -eq $ColumnCount) {
                            $Pass = New-TableConditionalFormattingInline -HeaderNames $HeaderNames -ColumnIndexHeader $ColumnIndexHeader -RowCount $RowCount -ColumnCount $ColumnCount -RowData $RowData -ConditionalFormatting $ConditionalFormatting
                            break
                        }
                    }
                } else {
                    [Array] $IsConditionTrue = foreach ($SubCondition in $ConditionalFormatting.Conditions.Output) {
                        $ColumnIndexHeader = [array]::indexof($HeaderNames.ToUpper(), $($SubCondition.Name).ToUpper())
                        for ($ColumnCount = 0; $ColumnCount -lt $RowData.Count; $ColumnCount++) {
                            #Write-Color "2ColumnCount $ColumnCount / $RowCount"
                            if ($ColumnIndexHeader -eq $ColumnCount) {
                                New-TableConditionalFormattingInline -HeaderNames $HeaderNames -ColumnIndexHeader $ColumnIndexHeader -RowCount $RowCount -ColumnCount $ColumnCount -RowData $RowData -ConditionalFormatting $SubCondition
                            }
                        }
                    }
                    if ($ConditionalFormatting.Logic -eq 'AND') {
                        if ($IsConditionTrue -contains $true -and $IsConditionTrue -notcontains $false) {
                            $Pass = $true
                        }
                    } elseif ($ConditionalFormatting.Logic -eq 'OR') {
                        if ($IsConditionTrue -contains $true) {
                            $Pass = $true
                        }
                    } elseif ($ConditionalFormatting.Logic -eq 'NONE') {
                        if ($IsConditionTrue -contains $false -and $IsConditionTrue -notcontains $true) {
                            $Pass = $true
                        }
                    }
                }
                if ($Pass) {
                    # If we want to make conditional formatting for row it requires a bit diff approach
                    if ($ConditionalFormatting.Row) {
                        for ($i = 0; $i -lt $RowData.Count; $i++) {
                            [PSCustomObject]@{
                                RowIndex    = $RowCount
                                ColumnIndex = ($i + 1)  # Since it's 0 based index and we count from 1 we need to add 1
                                Style       = $ConditionalFormatting.Style
                            }
                        }
                    } elseif ($ConditionalFormatting.HighlightHeaders) {
                        foreach ($Name in $ConditionalFormatting.HighlightHeaders) {
                            $ColumnIndexHighlight = [array]::indexof($HeaderNames.ToUpper(), $($Name).ToUpper())
                            [PSCustomObject]@{
                                RowIndex    = $RowCount
                                ColumnIndex = ($ColumnIndexHighlight + 1) # Since it's 0 based index and we count from 1 we need to add 1
                                Style       = $ConditionalFormatting.Style
                            }
                        }
                    } else {
                        [PSCustomObject]@{
                            RowIndex    = $RowCount
                            ColumnIndex = ($ColumnIndexHeader + 1)  # Since it's 0 based index and we count from 1 we need to add 1
                            Style       = $ConditionalFormatting.Style
                        }
                    }
                } else {
                    if ($ConditionalFormatting.FailStyle.Keys.Count -gt 0) {
                        if ($ConditionalFormatting.Row) {
                            for ($i = 0; $i -lt $RowData.Count; $i++) {
                                [PSCustomObject]@{
                                    RowIndex    = $RowCount
                                    ColumnIndex = ($i + 1)  # Since it's 0 based index and we count from 1 we need to add 1
                                    Style       = $ConditionalFormatting.FailStyle
                                }
                            }
                        } elseif ($ConditionalFormatting.HighlightHeaders) {
                            foreach ($Name in $ConditionalFormatting.HighlightHeaders) {
                                $ColumnIndexHighlight = [array]::indexof($HeaderNames.ToUpper(), $($Name).ToUpper())
                                [PSCustomObject]@{
                                    RowIndex    = $RowCount
                                    ColumnIndex = ($ColumnIndexHighlight + 1) # Since it's 0 based index and we count from 1 we need to add 1
                                    Style       = $ConditionalFormatting.FailStyle
                                }
                            }
                        } else {
                            [PSCustomObject]@{
                                RowIndex    = $RowCount
                                ColumnIndex = ($ColumnIndexHeader + 1)  # Since it's 0 based index and we count from 1 we need to add 1
                                Style       = $ConditionalFormatting.FailStyle
                            }
                        }
                    }
                }
            }
        }
        # This makes conditional forwarding a ContentStyle
        foreach ($Style in $AddStyles) {
            $ContentStyle.Add($Style)
        }
    }

    # Prepopulate hashtable with rows
    $TableRows = @{ }
    if ($ContentStyle) {
        for ($RowIndex = 0; $RowIndex -lt $Table.Count; $RowIndex++) {
            $TableRows[$RowIndex] = @{ }
        }
    }

    # Find rows in hashtable and add column to it
    foreach ($Content in $ContentStyle) {
        if ($Content.RowIndex -and $Content.ColumnIndex) {

            # ROWINDEX and COLUMNINDEX - ARRAYS
            # This takes care of Content by Column Nr
            foreach ($ColumnIndex in $Content.ColumnIndex) {

                # Column Index given by user is from 1 to infinity, Column Index is counted from 0
                # We need to address this by doing - 1
                foreach ($RowIndex in $Content.RowIndex) {
                    $TableRows[$RowIndex][$ColumnIndex - 1] = @{
                        Style = $Content.Style
                    }
                    if ($Content.Text) {
                        if ($Content.Used) {
                            $TableRows[$RowIndex][$ColumnIndex - 1]['Text'] = ''
                            $TableRows[$RowIndex][$ColumnIndex - 1]['Remove'] = $true
                        } else {
                            $TableRows[$RowIndex][$ColumnIndex - 1]['Text'] = $Content.Text
                            $TableRows[$RowIndex][$ColumnIndex - 1]['Remove'] = $false
                            $TableRows[$RowIndex][$ColumnIndex - 1]['ColSpan'] = $($Content.ColumnIndex).Count
                            $TableRows[$RowIndex][$ColumnIndex - 1]['RowSpan'] = $($Content.RowIndex).Count
                            $Content.Used = $true
                        }
                    }
                }
            }
        } elseif ($Content.RowIndex -and $Content.Name) {
            # ROWINDEX AND COLUMN NAMES - ARRAYS
            # This takes care of Content by Column Names (Header Names)
            foreach ($ColumnName in $Content.Name) {
                $ColumnIndex = ([array]::indexof($HeaderNames.ToUpper(), $ColumnName.ToUpper()))
                foreach ($RowIndex in $Content.RowIndex) {
                    $TableRows[$RowIndex][$ColumnIndex] = @{
                        Style = $Content.Style
                    }
                    if ($Content.Text) {
                        if ($Content.Used) {
                            $TableRows[$RowIndex][$ColumnIndex]['Text'] = ''
                            $TableRows[$RowIndex][$ColumnIndex]['Remove'] = $true
                        } else {
                            $TableRows[$RowIndex][$ColumnIndex]['Text'] = $Content.Text
                            $TableRows[$RowIndex][$ColumnIndex]['Remove'] = $false
                            $TableRows[$RowIndex][$ColumnIndex]['ColSpan'] = $($Content.ColumnIndex).Count
                            $TableRows[$RowIndex][$ColumnIndex]['RowSpan'] = $($Content.RowIndex).Count
                            $Content.Used = $true
                        }
                    }
                }
            }
        } elseif ($Content.RowIndex -and (-not $Content.ColumnIndex -and -not $Content.Name)) {
            # Just ROW INDEX
            for ($ColumnIndex = 0; $ColumnIndex -lt $HeaderNames.Count; $ColumnIndex++) {
                foreach ($RowIndex in $Content.RowIndex) {
                    $TableRows[$RowIndex][$ColumnIndex] = @{
                        Style = $Content.Style
                    }
                }
            }
        } elseif (-not $Content.RowIndex -and ($Content.ColumnIndex -or $Content.Name)) {
            # JUST COLUMNINDEX or COLUMNNAMES
            for ($RowIndex = 1; $RowIndex -lt $($Table.Count); $RowIndex++) {
                if ($Content.ColumnIndex) {
                    # JUST COLUMN INDEX
                    foreach ($ColumnIndex in $Content.ColumnIndex) {
                        $TableRows[$RowIndex][$ColumnIndex - 1] = @{
                            Style = $Content.Style
                        }
                    }
                } else {
                    # JUST COLUMN NAMES
                    foreach ($ColumnName in $Content.Name) {
                        $ColumnIndex = [array]::indexof($HeaderNames.ToUpper(), $ColumnName.ToUpper())
                        $TableRows[$RowIndex][$ColumnIndex] = @{
                            Style = $Content.Style
                        }
                    }
                }
            }
        }
    }

    # Row 0 = Table Header
    # This builds table from scratch, skipping rows untouched by styling
    [Array] $NewTable = for ($RowCount = 0; $RowCount -lt $Table.Count; $RowCount++) {
        # No conditional formatting we can process just styling since we don't need values
        # We have column index and row index and that's enough
        # In case of conditional formatting it's different as it works on values
        if ($TableRows[$RowCount]) {
            [string[]] $RowData = $Table[$RowCount] -replace '</td></tr>' -replace '<tr><td>' -split '</td><td>'
            New-HTMLTag -Tag 'tr' {
                for ($ColumnCount = 0; $ColumnCount -lt $RowData.Count; $ColumnCount++) {
                    if ($TableRows[$RowCount][$ColumnCount]) {
                        if (-not $TableRows[$RowCount][$ColumnCount]['Remove']) {
                            if ($TableRows[$RowCount][$ColumnCount]['Text']) {
                                New-HTMLTag -Tag 'td' -Value { $TableRows[$RowCount][$ColumnCount]['Text'] } -Attributes @{
                                    style   = $TableRows[$RowCount][$ColumnCount]['Style']
                                    colspan = if ($TableRows[$RowCount][$ColumnCount]['ColSpan'] -gt 1) { $TableRows[$RowCount][$ColumnCount]['ColSpan'] } else { }
                                    rowspan = if ($TableRows[$RowCount][$ColumnCount]['RowSpan'] -gt 1) { $TableRows[$RowCount][$ColumnCount]['RowSpan'] } else { }
                                }

                                # Version 1 - Alternative version to workaround DataTables.NET
                                # New-HTMLTag -Tag 'td' -Value { $TableRows[$RowCount][$ColumnCount]['Text'] } -Attributes @{
                                #    style   = $TableRows[$RowCount][$ColumnCount]['Style']
                                # }

                            } else {
                                New-HTMLTag -Tag 'td' -Value { $RowData[$ColumnCount] } -Attributes @{
                                    style = $TableRows[$RowCount][$ColumnCount]['Style']
                                }
                            }
                        } else {
                            # RowSpan/ColSpan doesn't work in DataTables.net for content.
                            # This means that this functionality is only good for Non-JS.
                            # Normally you would just remove TD/TD and everything shopuld work
                            # And it does work but only for NON-JS solution

                            # Version 1
                            # Alternative Approach - this assumes the text will be zeroed
                            # From visibility side it will look like an empty cells
                            # However content will be stored only in first cell.
                            # requires removal of colspan/rowspan

                            # New-HTMLTag -Tag 'td' -Value { '' } -Attributes @{
                            #    style = $TableRows[$RowCount][$ColumnCount]['Style']
                            # }

                            # Version 2
                            # Below code was suggested as a workaround - it doesn't wrok
                            # New-HTMLTag -Tag 'td' -Value { }  -Attributes @{
                            #     style = "display: none;"
                            # }
                        }
                    } else {
                        New-HTMLTag -Tag 'td' -Value { $RowData[$ColumnCount] }
                    }
                }
            }
        } else {
            $Table[$RowCount]
        }
    }
    $NewTable
}
function Add-TableEvent {
    [cmdletBinding()]
    param(
        [Array] $Events,
        [string[]] $HeaderNames,
        [string] $DataStore
    )
    foreach ($Event in $Events) {
        $ID = -join ('#', $Event.TableID)
        $ColumnID = $Event.SourceColumnID
        if ($null -ne $ColumnID) {
            $ColumnName = $HeaderNames[$ColumnID]
        } else {
            $ColumnName = $Event.SourceColumnName
            $ColumnID = $HeaderNames.IndexOf($Event.SourceColumnName)
        }
        $TargetColumnID = $Event.TargetColumnID

        $Value = @"
    var dataStore = '$DataStore'
    table.on('deselect', function (e, dt, type, indexes) {
        var table1 = `$('$ID').DataTable();
        table1.columns($TargetColumnID).search('').draw();
    });

    table.on('select', function (e, dt, type, indexes) {
        if (type === 'row') {
            // var data = table.rows(indexes).data().pluck('id');
            var data = table.rows(indexes).data();
            //console.log(data)
            //alert(data[0][$ColumnID])

            if (dataStore.toLowerCase() === 'html') {
                var findValue = escapeRegExp(data[0][$ColumnID]);
            } else {
                var findValue = escapeRegExp(data[0].$ColumnName);
            }
            var table1 = `$('$ID').DataTable();
            if (findValue != '') {
                table1.columns($TargetColumnID).search("^" + findValue + "`$", true, false, true).draw();
            } else {
                table1.columns($TargetColumnID).search('').draw();
            }
            if (table1.page.info().recordsDisplay == 0) {
                table1.columns($TargetColumnID).search('').draw();
            }
        }
    });
"@
        $Value
    }
}
function Add-TableFiltering {
    [CmdletBinding()]
    param(
        [bool] $Filtering,
        [ValidateSet('Top', 'Bottom', 'Both')][string]$FilteringLocation = 'Bottom',
        [string] $DataTableName,
        [alias('RegularExpression')][switch]$SearchRegularExpression
    )

    if ($SearchRegularExpression.IsPresent) {
        [string]$JSDataTableRegEx = 'true'
        [string]$JSDataTableSmart = 'false'
    } else {
        [string]$JSDataTableRegEx = 'false'
        [string]$JSDataTableSmart = 'true'
    }
    
    $Output = @{}
    if ($Filtering) {
        # https://datatables.net/examples/api/multi_filter.html

        if ($FilteringLocation -eq 'Bottom') {

            $Output.FilteringTopCode = @"
                // Setup - add a text input to each footer cell
                `$('#$DataTableName tfoot th').each(function () {
                    var title = `$(this).text();
                    `$(this).html('<input type="text" placeholder="' + title + '" />');
                });
"@
            $Output.FilteringBottomCode = @"
                // Apply the search for footer cells
                table.columns().every(function () {
                    var that = this;

                    `$('input', this.footer()).on('keyup change', function () {
                        if (that.search() !== this.value) {
                            that.search(this.value, $JSDataTableRegEx, $JSDataTableSmart).draw();
                        }
                    });
                });
"@

        } elseif ($FilteringLocation -eq 'Both') {

            $Output.FilteringTopCode = @"
                // Setup - add a text input to each header cell
                `$('#$DataTableName thead th').each(function () {
                    var title = `$(this).text();
                    `$(this).html('<input type="text" placeholder="' + title + '" />');
                });
                // Setup - add a text input to each footer cell
                `$('#$DataTableName tfoot th').each(function () {
                    var title = `$(this).text();
                    `$(this).html('<input type="text" placeholder="' + title + '" />');
                });
"@
            $Output.FilteringBottomCode = @"
                // Apply the search for header cells
                table.columns().eq(0).each(function (colIdx) {
                    `$('input', table.column(colIdx).header()).on('keyup change', function () {
                        table
                            .column(colIdx)
                            .search(this.value)
                            .draw();
                    });

                    `$('input', table.column(colIdx).header()).on('click', function (e) {
                        e.stopPropagation();
                    });
                });
                // Apply the search for footer cells
                table.columns().every(function () {
                    var that = this;

                    `$('input', this.footer()).on('keyup change', function () {
                        if (that.search() !== this.value) {
                            that.search(this.value, $JSDataTableRegEx, $JSDataTableSmart).draw();
                        }
                    });
                });
"@

        } else {
            # top headers
            $Output.FilteringTopCode = @"
                // Setup - add a text input to each header cell
                `$('#$DataTableName thead th').each(function () {
                    var title = `$(this).text();
                    `$(this).html('<input type="text" placeholder="' + title + '" />');
                });
"@

            $Output.FilteringBottomCode = @"
                // Apply the search for header cells
                table.columns().eq(0).each(function (colIdx) {
                    `$('input', table.column(colIdx).header()).on('keyup change', function () {
                        table
                            .column(colIdx)
                            .search(this.value)
                            .draw();
                    });

                    `$('input', table.column(colIdx).header()).on('click', function (e) {
                        e.stopPropagation();
                    });
                });
"@
        }
    } else {
        $Output.FilteringTopCode = $Output.FilteringBottomCode = '' # assign multiple same values trick
    }
    return $Output
}

function Add-TableHeader {
    [CmdletBinding()]
    param(
        [System.Collections.Generic.List[PSCustomObject]] $HeaderRows,
        [System.Collections.Generic.List[PSCUstomObject]] $HeaderStyle,
        [System.Collections.Generic.List[PSCUstomObject]] $HeaderTop,
        [System.Collections.Generic.List[PSCUstomObject]] $HeaderResponsiveOperations,
        [string[]] $HeaderNames
    )
    if ($HeaderRows.Count -eq 0 -and $HeaderStyle.Count -eq 0 -and $HeaderTop.Count -eq 0 -and $HeaderResponsiveOperations.Count -eq 0) {
        return
    }

    # Prepares for styles to merged headers
    [Array] $MergeColumns = foreach ($Row in $HeaderRows) {
        $Index = foreach ($R in $Row.Names) {
            [array]::indexof($HeaderNames.ToUpper(), $R.ToUpper())
        }
        if ($Index -contains -1) {
            Write-Warning -Message "Table Header can't be processed properly. Names on the list to merge were not found in Table Header."
        } else {
            @{
                Index = $Index
                Title = $Row.Title
                Count = $Index.Count
                Style = $Row.Style
                Used  = $false
            }
        }
    }

    $ResponsiveOperations = @{ }
    foreach ($Row in $HeaderResponsiveOperations) {
        foreach ($_ in $Row.Names) {
            $Index = [array]::indexof($HeaderNames.ToUpper(), $_.ToUpper())
            $ResponsiveOperations[$Index] = @{
                Index                = $Index
                ResponsiveOperations = $Row.ResponsiveOperations
                Used                 = $false
            }
        }
    }

    # Prepares for styles to standard header rows
    $Styles = @{ }
    foreach ($Row in $HeaderStyle) {
        foreach ($_ in $Row.Names) {
            $Index = [array]::indexof($HeaderNames.ToUpper(), $_.ToUpper())
            $Styles[$Index] = @{
                Index = $Index
                Title = $Row.Title
                Count = $Index.Count
                Style = $Row.Style
                Used  = $false
            }
        }
    }


    if ($HeaderTop.Count -gt 0) {
        $UsedColumns = 0
        $ColumnsTotal = $HeaderNames.Count
        $TopHeader = New-HTMLTag -Tag 'tr' {
            foreach ($_ in $HeaderTop) {
                if ($_.ColumnCount -eq 0) {
                    $UsedColumns = $ColumnsTotal - $UsedColumns
                    New-HTMLTag -Tag 'th' -Attributes @{ colspan = $UsedColumns; style = ($_.Style) } -Value { $_.Title }
                } else {
                    if ($_.ColumnCount -le $ColumnsTotal) {
                        $UsedColumns = $UsedColumns + $_.ColumnCount
                    } else {
                        $UsedColumns = - ($ColumnsTotal - $_.ColumnCount)
                    }
                    New-HTMLTag -Tag 'th' -Attributes @{ colspan = $_.ColumnCount; style = ($_.Style) } -Value { $_.Title }
                }

            }
        }
    }


    $AddedHeader = @(
        $NewHeader = [System.Collections.Generic.List[string]]::new()
        $TopHeader
        New-HTMLTag -Tag 'tr' {
            for ($i = 0; $i -lt $HeaderNames.Count; $i++) {
                $Found = $false
                foreach ($_ in $MergeColumns) {
                    if ($_.Index -contains $i) {
                        if ($_.Used -eq $false) {
                            New-HTMLTag -Tag 'th' -Attributes @{ colspan = $_.Count; style = ($_.Style); class = $ResponsiveOperations[$i] } -Value { $_.Title }
                            $_.Used = $true
                            $Found = $true
                        } else {
                            $Found = $true
                            # Do Nothing
                        }
                    }
                }
                if (-not $Found) {
                    if ($MergeColumns.Count -eq 0) {
                        # if there are no columns that are supposed to get a Title (merged Title over 2 or more columns) we remove rowspan completly and just apply style
                        # the style will apply, however if Style will be empty it will be removed by New-HTMLTag function
                        New-HTMLTag -Tag 'th' { $HeaderNames[$i] } -Attributes @{ style = $Styles[$i].Style; class = $ResponsiveOperations[$i].ResponsiveOperations }
                    } else {
                        # Since we're adding Title we need to use Rowspan. Rowspan = 2 means spaning row over 2 rows
                        New-HTMLTag -Tag 'th' { $HeaderNames[$i] } -Attributes @{ rowspan = 2; style = $Styles[$i].Style; class = $ResponsiveOperations[$i].ResponsiveOperations }
                    }
                } else {
                    $Head = New-HTMLTag -Tag 'th' { $HeaderNames[$i] } -Attributes @{ style = $Styles[$i].Style; class = $ResponsiveOperations[$i].ResponsiveOperations }
                    $NewHeader.Add($Head)
                }
            }
        }
        if ($NewHeader.Count) {
            New-HTMLTag -Tag 'tr' {
                $NewHeader
            }
        }
    )
    return $AddedHeader
}
function Add-TableRowGrouping {
    [CmdletBinding()]
    param(
        [string] $DataTableName,
        [System.Collections.IDictionary] $Settings,
        [switch] $Top,
        [switch] $Bottom
    )
    if ($Settings.Count -gt 0) {

        if ($Top) {
            $Output = "var collapsedGroups = {};"
        }
        if ($Bottom) {
            $Output = @"
        `$('#$DataTableName tbody').on('click', 'tr.dtrg-start', function () {
            var name = `$(this).data('name');
            collapsedGroups[name] = !collapsedGroups[name];
            table.draw(false);
        });
"@
        }
        $Output
    }
}
function Add-TableState {
    [CmdletBinding()]
    param(
        [bool] $Filtering,
        [bool] $SavedState,
        [string] $DataTableName,
        [ValidateSet('Top', 'Bottom', 'Both')][string]$FilteringLocation = 'Bottom'
    )
    if ($Filtering -and $SavedState) {
        if ($FilteringLocation -eq 'Top') {
            $Output = @"
                // Setup - Looading text input from SavedState
                `$('#$DataTableName').on('stateLoaded.dt', function(e, settings, data) {
                    settings.aoPreSearchCols.forEach(function(col, index) {
                        if (col.sSearch) setTimeout(function() {
                            `$('#$DataTableName thead th:eq('+index+') input').val(col.sSearch)
                        }, 50)
                    })
                });
"@
        } elseif ($FilteringLocation -eq 'Both') {
            $Output = @"
                // Setup - Looading text input from SavedState
                `$('#$DataTableName').on('stateLoaded.dt', function(e, settings, data) {
                    settings.aoPreSearchCols.forEach(function(col, index) {
                        if (col.sSearch) setTimeout(function() {
                            `$('#$DataTableName thead th:eq('+index+') input').val(col.sSearch)
                        }, 50)
                    })
                });
                // Setup - Looading text input from SavedState
                `$('#$DataTableName').on('stateLoaded.dt', function(e, settings, data) {
                    settings.aoPreSearchCols.forEach(function(col, index) {
                        if (col.sSearch) setTimeout(function() {
                            `$('#$DataTableName tfoot th:eq('+index+') input').val(col.sSearch)
                        }, 50)
                    })
                });
"@

        } else {
            $Output = @"
                // Setup - Looading text input from SavedState
                `$('#$DataTableName').on('stateLoaded.dt', function(e, settings, data) {
                    settings.aoPreSearchCols.forEach(function(col, index) {
                        if (col.sSearch) setTimeout(function() {
                            `$('#$DataTableName tfoot th:eq('+index+') input').val(col.sSearch)
                        }, 50)
                    })
                })
"@

        }
    } else {
        $Output = ''
    }
    return $Output
}
function Convert-TableRowGrouping {
    [CmdletBinding()]
    param(
        [string] $Options,
        [int] $RowGroupingColumnID
    )
    if ($RowGroupingColumnID -gt -1) {

        $TextToReplace = @"
        rowGroup: {
            // Uses the 'row group' plugin
            dataSrc: $RowGroupingColumnID,
            startRender: function (rows, group) {
                var collapsed = !!collapsedGroups[group];

                rows.nodes().each(function (r) {
                    r.style.display = collapsed ? 'none' : '';
                });

                var toggleClass = collapsed ? 'fa-plus-square' : 'fa-minus-square';

                // Add group name to <tr>
                return `$('<tr/>')
                    .append('<td colspan="' + rows.columns()[0].length + '">' + '<span class="fa fa-fw ' + toggleClass + ' toggler"/> ' + group + ' (' + rows.count() + ')</td>')
                    .attr('data-name', group)
                    .toggleClass('collapsed', collapsed);
            },
        },
"@
    } else {
        $TextToReplace = ''
    }
    <#
    if ($PSEdition -eq 'Desktop') {
        $TextToFind = '"rowGroup":  "",'
    } else {
        $TextToFind = '"rowGroup": "",'
    }
    #>
    $TextToFind = '"rowGroup":"",'
    $Options = $Options -Replace ($TextToFind, $TextToReplace)
    $Options
}
function New-TableConditionalFormatting {
    [CmdletBinding()]
    param(
        [string] $Options,
        [Array] $ConditionalFormatting,
        [string[]] $Header,
        [string] $DataStore
    )
    if ($ConditionalFormatting.Count -gt 0) {
        $ConditionsReplacement = @(
            '"rowCallback": function (row, data) {'
            foreach ($Condition in $ConditionalFormatting) {
                if ($Condition.ConditionType -eq 'Condition') {
                    # Conditions without grouping
                    if ($Condition.Row) {
                        $HighlightHeaders = 'null'
                    } else {
                        [Array] $HighlightHeaders = New-TableConditionHeaderHighligher -Condition $Condition -Header $Header #-Row:$Row
                        if ($HighlightHeaders.Count -eq 0) {
                            continue
                        }
                    }
                    [Array] $ConditionsContainer = @(
                        [ordered]@{
                            logic      = 'AND'
                            conditions = @( New-TableConditionInternal -Condition $Condition -Header $Header -DataStore $DataStore )
                        }
                    )
                    "    var css = $($Condition.Style | ConvertTo-Json);"
                    if ($Condition.FailStyle.Keys.Count -gt 0) {
                        "    var failCss = $($Condition.FailStyle | ConvertTo-Json);"
                    } else {
                        "    var failCss = undefined;"
                    }
                    "    var conditionsContainer = $($ConditionsContainer | ConvertTo-JsonLiteral -Depth 5 -AsArray -AdvancedReplace @{ '.' = '\.'; '$' = '\$' });"
                    "    dataTablesConditionalFormatting(row, data, conditionsContainer, $HighlightHeaders, css, failCss);"

                } else {
                    if ($Condition.Row) {
                        $HighlightHeaders = 'null'
                    } else {
                        [Array] $HighlightHeaders = New-TableConditionHeaderHighligher -Condition $Condition -Header $Header
                        if ($HighlightHeaders.Count -eq 0) {
                            continue
                        }
                    }
                    [Array] $ConditionsContainer = @(
                        [ordered]@{
                            logic      = $Condition.Logic
                            conditions = @(
                                foreach ($NestedCondition in $Condition.Conditions) {
                                    if ($NestedCondition.Type -eq 'TableCondition') {
                                        New-TableConditionInternal -Condition $NestedCondition.Output -Header $Header -DataStore $DataStore
                                    }
                                }
                            )
                        }
                    )
                    "    var css = $($Condition.Style | ConvertTo-Json);"
                    if ($Condition.FailStyle.Keys.Count -gt 0) {
                        "    var failCss = $($Condition.FailStyle | ConvertTo-Json);"
                    } else {
                        "    var failCss = undefined;"
                    }
                    "    var conditionsContainer = $($ConditionsContainer | ConvertTo-JsonLiteral -Depth 5 -AsArray -AdvancedReplace @{ '.' = '\.'; '$' = '\$' });"
                    "    dataTablesConditionalFormatting(row, data, conditionsContainer, $HighlightHeaders, css, failCss);"
                }

            }

            "}"
        )
        $TextToFind = '"createdRow":""'
        $Options = $Options -Replace ($TextToFind, $ConditionsReplacement)
    }
    $Options
}

function New-TableConditionalFormattingInline {
    [CmdletBinding()]
    param(
        [string[]] $HeaderNames,
        [PSCustomObject] $ConditionalFormatting,
        [Array] $RowData,
        [int] $ColumnCount,
        [int] $RowCount,
        [int] $ColumnIndexHeader
    )
    [bool] $Pass = $false
    if ($ConditionalFormatting.Type -eq 'number') {
        if ($ConditionalFormatting.operator -in 'between', 'betweenInclusive') {
            [decimal] $returnedValueLeft = 0
            [bool] $resultLeft = [decimal]::TryParse($RowData[$ColumnCount], [ref]$returnedValueLeft)
            [bool] $resultRight = $false
            [Array] $returnedValueRight = foreach ($Value in $ConditionalFormatting.Value) {
                [decimal]$returnedValue = 0
                $resultRight = [decimal]::TryParse($Value, [ref]$returnedValue)
                if ($resultRight) {
                    $returnedValue
                } else {
                    break
                }
            }
        } else {
            [decimal] $returnedValueLeft = 0
            [bool]$resultLeft = [decimal]::TryParse($RowData[$ColumnCount], [ref]$returnedValueLeft)

            [decimal]$returnedValueRight = 0
            [bool]$resultRight = [decimal]::TryParse($ConditionalFormatting.Value, [ref]$returnedValueRight)
        }
        if ($resultLeft -and $resultRight) {
            $SideLeft = $returnedValueLeft
            $SideRight = $returnedValueRight
        } else {
            $SideLeft = $RowData[$ColumnCount]
            $SideRight = $ConditionalFormatting.Value
        }
    } elseif ($ConditionalFormatting.Type -eq 'date') {
        try {
            if ($ConditionalFormatting.DateTimeFormat) {
                $SideLeft = [DateTime]::ParseExact($RowData[$ColumnCount], $ConditionalFormatting.DateTimeFormat, $null)
            } else {
                $SideLeft = [DateTime]::Parse($RowData[$ColumnCount])
            }
        } catch {
            $SideLeft = $RowData[$ColumnCount]
            #Write-Warning "Table Condition $($RowData[$ColumnCount]) couldn't be converted to DateTime. Skipping."
        }
        $SideRight = $ConditionalFormatting.Value
    } else {
        $SideLeft = $RowData[$ColumnCount]
        $SideRight = $ConditionalFormatting.Value
    }
    if ($ConditionalFormatting.ReverseCondition) {
        $TempSide = $SideLeft
        $SideLeft = $SideRight
        $SideRight = $TempSide
    }
    if ($ConditionalFormatting.Operator -eq 'gt') {
        $Pass = $SideLeft -gt $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'lt') {
        $Pass = $SideLeft -lt $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'eq') {
        $Pass = $SideLeft -eq $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'le') {
        $Pass = $SideLeft -le $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'ge') {
        $Pass = $SideLeft -ge $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'ne') {
        $Pass = $SideLeft -ne $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'in') {
        $Pass = $SideLeft -in $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'notin') {
        $Pass = $SideLeft -notin $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'like') {
        $Pass = $SideLeft -like $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'contains') {
        $Pass = $SideLeft -contains $SideRight
    } elseif ($ConditionalFormatting.Operator -eq 'betweenInclusive') {
        $Pass = $SideLeft -ge $SideRight[0] -and $SideLeft -le $SideRight[1]
    } elseif ($ConditionalFormatting.Operator -eq 'between') {
        $Pass = $SideLeft -gt $SideRight[0] -and $SideLeft -lt $SideRight[1]
    }
    $Pass
}
function New-TableConditionHeaderHighligher {
    [CmdletBinding()]
    param(
        [PSCustomObject] $Condition,
        [string[]]$Header
    )
    [Array] $ConditionHeaderNr = @(
        if ($Condition.HighlightHeaders) {
            # if highlight headers is defined we use that
            foreach ($HeaderName in $Condition.HighlightHeaders) {
                $ColumnID = $Header.ToLower().IndexOf($($HeaderName.ToLower()))
                if ($ColumnID -ne -1) {
                    $ColumnID
                }
            }
        } else {
            # if not we use same column that we highlight
            foreach ($HeaderName in $Condition.Name) {
                $ColumnID = $Header.ToLower().IndexOf($($HeaderName.ToLower()))
                if ($ColumnID -ne -1) {
                    $ColumnID
                }
            }
        }
    )
    if ($ConditionHeaderNr.Count -gt 0) {
        $ConditionHeaderNr | ConvertTo-JsonLiteral -AsArray -AdvancedReplace @{ '.' = '\.'; '$' = '\$' }
    } else {
        $ColumnNames = @(
            if ($Condition.HighlightHeaders) {
                $Condition.HighlightHeaders
            }
            if ($Condition.Name) {
                $Condition.Name
            }
        )
        if ($ColumnNames.Count -gt 0) {
            Write-Warning "New-TableCondition - None of the column names exists $ColumnNames in condition. Skipping."
        } else {
            Write-Warning "New-TableCondition - None of the column names found to process. Please use HighlightHeaders or Row switch when using New-TableConditionGroup."
        }
    }
}
function New-TableConditionInternal {
    [CmdletBinding()]
    param(
        [PSCustomObject] $Condition,
        [string[]]$Header,
        [string] $DataStore
    )
    $Cond = [ordered] @{
        columnName       = $Condition.Name
        columnId         = $Header.ToLower().IndexOf($($Condition.Name.ToLower()))
        operator         = $Condition.Operator
        type             = $Condition.Type.ToLower()
        value            = $Condition.Value
        valueDate        = $null
        dataStore        = $DataStore
        caseSensitive    = $Condition.caseSensitive
        dateTimeFormat   = $Condition.DateTimeFormat
        reverseCondition = $Condition.ReverseCondition
    }
    if ($Cond['value'] -is [datetime]) {
        $Cond['valueDate'] = @{
            year        = $Cond['value'].Year
            month       = $Cond['value'].Month
            day         = $Cond['value'].Day
            hours       = $Cond['value'].Hour
            minutes     = $Cond['value'].Minute
            seconds     = $Cond['value'].Second
            miliseconds = $Cond['value'].Millisecond
        }
    } elseif ($Cond['value'] -is [Array] -and $Cond['value'][0] -is [datetime]) {
        [Array] $Cond['valueDate'] = foreach ($Date in $Cond['value']) {
            @{
                year        = $Date.Year
                month       = $Date.Month
                day         = $Date.Day
                hours       = $Date.Hour
                minutes     = $Date.Minute
                seconds     = $Date.Second
                miliseconds = $Date.Millisecond
            }
        }
    }
    $Cond
}
function Add-ConfigurationCSS {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $CSS,
        [string] $Name,
        [System.Collections.IDictionary] $Inject,
        [switch] $Overwrite
    )
    # Lets remove dead code
    if ($Inject) {
        Remove-EmptyValue -Hashtable $Inject
        if ($Css) {
            if ($CSS[$Name] -and (-not $Overwrite)) {
                # if exists and is not supposed to be overwritten
                # we just add or overwritte existing parts in $Inject
                foreach ($Key in $Inject.Keys) {
                    $CSS[$Name][$Key] = $Inject[$Key]
                }
            } else {
                $CSS[$Name] = $Inject
            }
        }
    }
}
function Convert-FontToBinary {
    [CmdLetBinding()]
    param(
        [string[]] $Content,
        [string] $Search,
        [string] $ReplacePath,
        [string] $FileType
    )
    if ($Content -like "*$Search*") {
        if ($PSEdition -eq 'Core') {
            $ImageContent = Get-Content -AsByteStream -LiteralPath $ReplacePath
        } else {
            $ImageContent = Get-Content -LiteralPath $ReplacePath -Encoding Byte
        }
        $Replace = "data:application/$FileType;charset=utf-8;base64," + [Convert]::ToBase64String($ImageContent)
        $Content = $Content.Replace($Search, $Replace)
    }
    $Content
}
function ConvertFrom-Rotate {
    [cmdletBinding()]
    param(
        [object] $Rotate
    )
    if ($Rotate -is [int]) {
        if ($Rotate -ne 0) {
            "rotate($($Rotate)deg)"
        }
    } elseif ($Rotate -is [string]) {
        if ($Rotate) {
            if (($Rotate -like '*deg*') -and ($Rotate -notlike '*rotate*')) {
                "rotate($Rotate)"
            } elseif (($Rotate -like '*deg*') -and ($Rotate -like '*rotate*')) {
                "$Rotate"
            } else {
                $Rotate
            }
        }
    }
}
function Convert-Image {
    [CmdletBinding()]
    param(
        [string] $Image,
        [switch] $Cache
    )

    $ImageFile = Get-ImageFile -Image $Image -Cache:$Cache
    if ($ImageFile) {
        Convert-ImageToBinary -ImageFile $ImageFile
    }
}
function Convert-ImagesToBinary {
    [CmdLetBinding()]
    param(
        [string[]] $Content,
        [string] $Search,
        [string] $ReplacePath
    )
    if ($Content -like "*$Search*") {
        if ($PSEdition -eq 'Core') {
            $ImageContent = Get-Content -AsByteStream -LiteralPath $ReplacePath
        } else {
            $ImageContent = Get-Content -LiteralPath $ReplacePath -Encoding Byte
        }
        $Replace = "data:image/$FileType;base64," + [Convert]::ToBase64String($ImageContent)
        $Content = $Content.Replace($Search, $Replace)
    }
    $Content
}
function Convert-ImageToBinary {
    [CmdletBinding()]
    param(
        [System.IO.FileInfo] $ImageFile
    )

    if ($ImageFile.Extension -eq '.jpg') {
        $FileType = 'jpeg'
    } else {
        $FileType = $ImageFile.Extension.Replace('.', '')
    }
    Write-Verbose "Converting $($ImageFile.FullName) to base64 ($FileType)"

    if ($PSEdition -eq 'Core') {
        $ImageContent = Get-Content -AsByteStream -LiteralPath $ImageFile.FullName
    } else {
        $ImageContent = Get-Content -LiteralPath $ImageFile.FullName -Encoding Byte
    }
    $Output = "data:image/$FileType;base64," + [Convert]::ToBase64String(($ImageContent))
    $Output
}
function Convert-StyleContent {
    [CmdLetBinding()]
    param(
        [string[]] $CSS,
        [string] $ImagesPath,
        [string] $SearchPath
    )

    #Get-ObjectType -Object $CSS -VerboseOnly -Verbose

    $ImageFiles = Get-ChildItem -Path (Join-Path $ImagesPath '\*') -Include *.jpg, *.png, *.bmp #-Recurse
    foreach ($Image in $ImageFiles) {
        #$Image.FullName
        #$Image.Name
        $CSS = Convert-ImagesToBinary -Content $CSS -Search "$SearchPath$($Image.Name)" -ReplacePath $Image.FullName
    }
    return $CSS
}

#

#Convert-StyleContent -ImagesPath "$PSScriptRoot\Resources\Images\DataTables" -SearchPath "DataTables-1.10.18/images/"
function Convert-StyleContent1 {
    param(
        [PSCustomObject] $Options
    )
    # Replace PNG / JPG files in Styles
    if ($null -ne $Options.StyleContent) {
        Write-Verbose "Logos: $($Options.Logos.Keys -join ',')"
        foreach ($Logo in $Options.Logos.Keys) {
            $Search = "../images/$Logo.png", "DataTables-1.10.18/images/$Logo.png"
            $Replace = $Options.Logos[$Logo]
            foreach ($S in $Search) {
                Write-Verbose "Logos - replacing $S with binary representation"
                $Options.StyleContent = ($Options.StyleContent).Replace($S, $Replace)
            }
        }
    }    
}
function ConvertFrom-Size {
    [cmdletBinding()]
    param(
        [alias('TextSize', 'FontSize')][object] $Size
    )
    if ($Size -is [int]) {
        if ($Size) {
            "$($Size)px"
        }
    } elseif ($Size -is [string]) {
        if ($Size) {
            $IntSize = 0
            $Conversion = [int]::TryParse($Size, [ref] $IntSize)
            if ($Conversion) {
                "$($Size)px"
            } else {
                $Size
            }
        }
    } else {
        $Size
    }
}
function ConvertTo-HTMLStyle {
    [CmdletBinding()]
    param(
        [string]$Color,
        [string]$BackGroundColor,
        [object] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string]  $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string]  $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string]  $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        [switch] $LineBreak,
        [ValidateSet('normal', 'break-all', 'keep-all', 'break-word')][string] $WordBreak
    )
    $Style = @{
        'color'            = ConvertFrom-Color -Color $Color
        'background-color' = ConvertFrom-Color -Color $BackGroundColor
        'font-size'        = ConvertFrom-Size -FontSize $FontSize
        'font-weight'      = $FontWeight
        'font-variant'     = $FontVariant
        'font-family'      = $FontFamily
        'font-style'       = $FontStyle
        'text-align'       = $Alignment
        'text-decoration'  = $TextDecoration
        'text-transform'   = $TextTransform
        'word-break'       = $WordBreak
    }
    # Removes empty, not needed values from hashtable. It's much easier then using if/else to verify for null/empty string
    Remove-EmptyValue -Hashtable $Style
    $Style
}
function ConvertTo-LimitedCSS {
    [CmdletBinding()]
    param(
        [string] $ID,
        [string] $ClassName,
        [System.Collections.IDictionary] $Attributes,
        [switch] $Group
    )
    if ($Attributes) {
        Remove-EmptyValue -Hashtable $Attributes
    }
    if ($Attributes.Count -eq 0) {
        # Means empty value after we removed all empty values
        return
    }
    [string] $Css = @(
        if ($Group) {
            '<style>'
        }
        if ($ID) {
            "#$ID $ClassName {"
        } else {
            if ($ClassName.StartsWith('.')) {
                "$ClassName {"
            } elseif ($ClassName.StartsWith('[')) {
                "$ClassName {"
            } else {
                ".$ClassName {"
            }
        }
        foreach ($_ in $Attributes.Keys) {
            if ($null -ne $Attributes[$_]) {
                # we remove empty chars because sometimes there cab be multiple lines similar to each other
                $Property = $_.Replace(' ', '')
                "    $Property`: $($Attributes[$_]);"
            }
        }
        '}'
        if ($Group) {
            '</style>'
        }
    ) -join "`n"
    $CSS
}
function ConvertTo-Size {
    [cmdletBinding()]
    param(
        [alias('TextSize', 'FontSize')][object] $Size
    )
    $Point = $false
    if ($Size -is [int]) {
        $Size
    } elseif ($Size -is [string]) {
        $IntSize = 0
        if ($Size -like '*px') {
            $Size = $Size -replace 'px'
        } elseif ($Size -like '*pt') {
            $Size = $Size -replace 'pt'
            $Point = $true # 1.3333333333333333
        }
        $Conversion = [int]::TryParse($Size, [ref] $IntSize)
        if ($Conversion) {
            if ($Point) {
                $IntSize * 1.3333333333333333
            } else {
                $IntSize
            }
        }
    }
}
function ConvertTo-SVG {
    [CmdLetBinding()]
    param(
        [string] $Content,
        [string] $FileType
    )
    if ($Content) {
        $Replace = "data:image/$FileType;charset=utf-8," + [uri]::EscapeDataString($Content)
        $Replace
    }
}
function Get-ConfigurationCSS {
    [cmdletBinding()]
    param(
        [string] $Feature,
        [string] $Type
    )
    return $Script:CurrentConfiguration.Features.$Feature.$Type.CssInline
}
function Get-FeaturesInUse {
    <#
    .SYNOPSIS
    Defines which features will be used within HTML and in which order

    .DESCRIPTION
    Defines which features will be used within HTML and in which order

    .PARAMETER PriorityFeatures
    Define priority features - important for ordering when CSS or JS has to be processed in certain order

    .EXAMPLE
    Get-FeaturesInUse -PriorityFeatures 'Jquery', 'DataTables', 'Tabs', 'Test'

    .EXAMPLE
    Get-FeaturesInUse -PriorityFeatures 'Jquery', 'DataTables', 'Tabs', 'Test' -Email

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param(
        [string[]] $PriorityFeatures,
        [switch] $Email
    )
    [Array] $Features = foreach ($Key in $Script:HTMLSchema.Features.Keys) {
        if ($Script:HTMLSchema.Features[$Key]) {
            $Key
        }
    }
    # This checks whether the features are for email or for normal HTML and allows or dissalows further processing
    [Array] $Features = foreach ($Key in $Features) {
        if ($Script:CurrentConfiguration['Features'][$Key]) {
            if ($Email) {
                if ($Script:CurrentConfiguration['Features'][$Key]['Email'] -ne $true) {
                    continue
                }
            } else {
                if ($Script:CurrentConfiguration['Features'][$Key]['Default'] -ne $true) {
                    continue
                }
            }
            $Key
        }
    }
    [Array] $TopFeatures = foreach ($Feature in $PriorityFeatures) {
        if ($Features -contains $Feature) {
            $Feature
        }
    }
    [Array] $RemainingFeatures = foreach ($Feature in $Features) {
        if ($TopFeatures -notcontains $Feature) {
            $Feature
        }
    }
    [Array] $AllFeatures = $TopFeatures + $RemainingFeatures
    $AllFeatures
}
Function Get-HTMLLogos {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$LeftLogoName = "Sample",
        [string]$RightLogoName = "Alternate",
        [string]$LeftLogoString,
        [string]$RightLogoString

    )
    $LogoSources = [ordered] @{ }
    $LogoPath = @(
        if ([String]::IsNullOrEmpty($RightLogoString) -eq $false -or [String]::IsNullOrEmpty($LeftLogoString) -eq $false) {
            if ([String]::IsNullOrEmpty($RightLogoString) -eq $false) {
                $LogoSources.Add($RightLogoName, $RightLogoString)
            }
            if ([String]::IsNullOrEmpty($LeftLogoString) -eq $false) {
                $LogoSources.Add($LeftLogoName, $LeftLogoString)
            }
        } else {
            "$PSScriptRoot\Resources\Images\Other"
        }
        "$PSScriptRoot\Resources\Images\DataTables"
    )
    $ImageFiles = Get-ChildItem -Path (Join-Path $LogoPath '\*') -Include *.jpg, *.png, *.bmp -Recurse
    foreach ($ImageFile in $ImageFiles) {
        <#
        if ($ImageFile.Extension -eq '.jpg') {
            $FileType = 'jpeg'
        } else {
            $FileType = $ImageFile.Extension.Replace('.', '')
        }
        Write-Verbose "Converting $($ImageFile.FullName) to base64 ($FileType)"

        if ($PSEdition -eq 'Core') {
            $ImageContent = Get-Content -AsByteStream -LiteralPath $ImageFile.FullName
        } else {
            $ImageContent = Get-Content -LiteralPath $ImageFile.FullName -Encoding Byte
        }
        #>
        $ImageBinary = Convert-ImageToBinary -ImageFile $ImageFile
        #$LogoSources.Add($ImageFile.BaseName, "data:image/$FileType;base64," + [Convert]::ToBase64String(($ImageContent)))
        $LogoSources.Add($ImageFile.BaseName, $ImageBinary)
    }
    $LogoSources
}


#$t = 'C:\Support\GitHub\PSWriteHTML\Private\Get-HTMLLogos.ps1'
#$t -as [System.IO.FileInfo]
function Get-HTMLPartContent {
    param(
        [Array] $Content,
        [string] $Start,
        [string] $End,
        [ValidateSet('Before', 'Between', 'After')] $Type = 'Between'
    )
    $NrStart = $Content.IndexOf($Start)
    $NrEnd = $Content.IndexOf($End)   
    
    #Write-Color $NrStart, $NrEnd, $Type -Color White, Yellow, Blue

    if ($Type -eq 'Between') {
        if ($NrStart -eq -1) {
            # return nothing
            return
        }
        $Content[$NrStart..$NrEnd]
    } 
    if ($Type -eq 'After') {
        if ($NrStart -eq -1) {
            # Returns untouched content
            return $Content
        }
        $Content[($NrEnd + 1)..($Content.Count - 1)]

    }
    if ($Type -eq 'Before') {
        if ($NrStart -eq -1) {
            # return nothing
            return
        }
        $Content[0..$NrStart]
    }
}
function Get-ImageFile {
    [CmdletBinding()]
    param(
        [uri] $Image,
        [switch] $Cache
    )
    if (-not $Image.IsFile) {
        if ($Cache -and -not $Script:CacheImagesHTML) {
            $Script:CacheImagesHTML = @{}
        }
        $Extension = ($Image.OriginalString).Substring(($Image.OriginalString).Length - 4)
        if ($Extension -notin @('.png', '.jpg', 'jpeg', '.svg')) {
            return
        }
        $Extension = $Extension.Replace('.', '')
        $ImageFile = Get-FileName -Extension $Extension -Temporary
        if ($Cache -and $Script:CacheImagesHTML[$Image]) {
            $Script:CacheImagesHTML[$Image]
        } else {
            try {
                Invoke-WebRequest -Uri $Image -OutFile $ImageFile
                if ($Cache) {
                    $Script:CacheImagesHTML[$Image] = $ImageFile
                }
            } catch {
                Write-Warning "Get-Image - Couldn't download image. Error: $($_.Exception.Message)"
            }
            $ImageFile
        }
    } else {
        $Image.LocalPath
    }
}
function Get-Resources {
    [CmdLetBinding()]
    param(
        [switch] $Online,
        [switch] $NoScript,
        [ValidateSet('Header', 'Footer', 'HeaderAlways', 'FooterAlways', 'Body', 'BodyAlways')][string] $Location,
        [string[]] $Features,
        [switch] $AddComment
    )
    Process {
        foreach ($Feature in $Features) {
            Write-Verbose "Get-Resources - Location: $Location - Feature: $Feature Online: $Online AddComment: $($AddComment.IsPresent)"
            if ($Online) {
                Add-HTMLStyle -Placement Inline -Link $Script:CurrentConfiguration.Features.$Feature.$Location.'CssLink' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -AddComment:$AddComment
            } else {
                $CSSOutput = Add-HTMLStyle -Placement Inline -FilePath $Script:CurrentConfiguration.Features.$Feature.$Location.'Css' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -Replace $Script:CurrentConfiguration.Features.$Feature.CustomActionsReplace -AddComment:$AddComment
                $Data = Convert-StyleContent -CSS $CSSOutput -ImagesPath "$PSScriptRoot\Resources\Images\DataTables" -SearchPath "../images/"
                if ($Data) {
                    $Data
                }
                # CssInLine is should always be processed
                # But since Get-Resources is executed in both times we only add it to Offline section
                $CSSOutput = Add-HTMLStyle -Placement Inline -CssInline $Script:CurrentConfiguration.Features.$Feature.$Location.'CssInline' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -Replace $Script:CurrentConfiguration.Features.$Feature.CustomActionsReplace -AddComment:$AddComment
                $Data = Convert-StyleContent -CSS $CSSOutput -ImagesPath "$PSScriptRoot\Resources\Images\DataTables" -SearchPath "../images/"
                if ($Data) {
                    $Data
                }
            }
            if ($Online) {
                $Data = Add-HTMLScript -Placement Inline -Link $Script:CurrentConfiguration.Features.$Feature.$Location.'JsLink' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -AddComment:$AddComment
                if ($Data) {
                    $Data
                }
            } else {
                $Data = Add-HTMLScript -Placement Inline -FilePath $Script:CurrentConfiguration.Features.$Feature.$Location.'Js' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -ReplaceData $Script:CurrentConfiguration.Features.$Feature.CustomActionsReplace -AddComment:$AddComment
                if ($Data) {
                    $Data
                }
                $Data = Add-HTMLScript -Placement Inline -Content $Script:CurrentConfiguration.Features.$Feature.$Location.'JsInLine' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -AddComment:$AddComment
                if ($Data) {
                    $Data
                }
            }

            if ($NoScript) {
                [Array] $Output = @(
                    if ($Online) {
                        Add-HTMLStyle -Placement Inline -Link $Script:CurrentConfiguration.Features.$Feature.$Location.'CssLinkNoScript' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -AddComment:$AddComment
                    } else {
                        $CSSOutput = Add-HTMLStyle -Placement Inline -FilePath $Script:CurrentConfiguration.Features.$Feature.$Location.'CssNoScript' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -ReplaceData $Script:CurrentConfiguration.Features.$Feature.CustomActionsReplace -AddComment:$AddComment
                        if ($CSSOutput) {
                            $Data = Convert-StyleContent -CSS $CSSOutput -ImagesPath "$PSScriptRoot\Resources\Images\DataTables" -SearchPath "../images/"
                            if ($Data) {
                                $Data
                            }
                        }
                        # CssInLine is should always be processed
                        $CSSOutput = Add-HTMLStyle -Placement Inline -CssInline $Script:CurrentConfiguration.Features.$Feature.$Location.'CssInlineNoScript' -ResourceComment $Script:CurrentConfiguration.Features.$Feature.Comment -Replace $Script:CurrentConfiguration.Features.$Feature.CustomActionsReplace -AddComment:$AddComment
                        if ($CSSOutput) {
                            $Data = Convert-StyleContent -CSS $CSSOutput -ImagesPath "$PSScriptRoot\Resources\Images\DataTables" -SearchPath "../images/"
                            if ($Data) {
                                $Data
                            }
                        }
                    }
                )
                if (($Output.Count -gt 0) -and ($null -ne $Output[0])) {
                    New-HTMLTag -Tag 'noscript' {
                        $Output
                    }
                }
            }
        }
    }
}

$Script:ScriptBlockConfiguration = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $Script:CurrentConfiguration.Features.Keys | Where-Object { $_ -like "*$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName Get-Resources -ParameterName Color -ScriptBlock $Script:ScriptBlockConfiguration
function New-DiagramInternalEvent {
    [CmdletBinding()]
    param(
        #[switch] $OnClick,
        [string] $ID,
        #[switch] $FadeSearch,
        [nullable[int]] $ColumnID
    )
    # not ready
    $FadeSearch = $false
    if ($FadeSearch) {
        $EventVar = @"
        var table = `$('#$ID').DataTable();
        //table.search(params.nodes).draw();
        table.rows(':visible').every(function (rowIdx, tableLoop, rowLoop) {
            var present = true;
            if (params.nodes) {
                present = table.row(rowIdx).data().some(function (v) {
                        return v.match(new RegExp(params.nodes, 'i')) != null;
                    });
            }
            `$(table.row(rowIdx).node()).toggleClass('notMatched', !present);
        });

"@

    } else {
        if ($null -ne $ColumnID) {
            $EventVar = @"
        var table = `$('#$ID').DataTable();
        if (findValue != '') {
            table.columns($ColumnID).search("^" + findValue + "$", true, false, true).draw();
        } else {
            table.columns($ColumnID).search('').draw();
        }
        if (table.page.info().recordsDisplay == 0) {
            table.columns($ColumnID).search('').draw();
        }
"@
        } else {
            $EventVar = @"
        var table = `$('#$ID').DataTable();
        if (findValue != '') {
            table.search("^" + findValue + "$", true, false, true).draw();
        } else {
            table.search('').draw();
        }
        if (table.page.info().recordsDisplay == 0) {
            table.search('').draw();
        }
"@
        }
    }
    $EventVar
}
function New-HTMLCustomCSS {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $CSS,
        [switch] $AddComment
    )

    $Output = foreach ($Key in $CSS.Keys) {
        if ($AddComment) { "<!-- CSS $Key AUTOGENERATED on DEMAND START -->" }
        if ($CSS[$Key]) {
            #if ($CSS[$Key] -notlike "*<style *") {

            $CSS[$Key]

            #} else {
            #    $CSS[$Key]
            #}
        }
        if ($AddComment) { "<!-- CSS $Key AUTOGENERATED on DEMAND END -->" }
    }
    if ($Output) {
        New-HTMLTag -Tag 'style' -Attributes @{ type = 'text/css' } {
            $Output
        } -NewLine
    }
}
function New-HTMLCustomJS {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $JS
    )
    foreach ($Key in $JS.Keys) {
        "<!-- JS $Key AUTOGENERATED on DEMAND START -->"
        if ($JS[$Key]) {
            if ($JS[$Key] -notlike "*<script*") {
                New-HTMLTag -Tag 'script' {
                    $JS[$Key]
                } -NewLine
            } else {
                $JS[$Key]
            }
        }
        "<!-- JS $Key AUTOGENERATED on DEMAND END -->"
    }
}
function New-HTMLTabHead {
    [CmdletBinding()]
    Param (
        [Array] $TabsCollection
    )
    if ($TabsCollection.Count -gt 0) {
        $Tabs = $TabsCollection
    } else {
        $Tabs = $Script:HTMLSchema.TabsHeaders
    }
    New-HTMLTag -Tag 'div' -Attributes @{ class = 'tabsWrapper' } {
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'tabsSlimmer' } {
            #New-HTMLTag -Tag 'div' -Attributes @{ 'data-tabs' = 'true'; class = 'tabsBorderStyle' } {
            New-HTMLTag -Tag 'div' -Attributes @{ 'data-tabs' = 'true' } {
                foreach ($Tab in $Tabs) {
                    if ($Tab.Active) {
                        $TabActive = 'active'
                    } else {
                        $TabActive = ''
                    }
                    New-HTMLTag -Tag 'div' -Attributes @{ id = $Tab.ID; class = $TabActive; } {
                        if ($Tab.Icon) {
                            New-HTMLTag -Tag 'span' -Attributes @{ class = $($Tab.Icon); style = $($Tab.StyleIcon) }
                            '&nbsp;' # adds an extra space when adding icon before it
                        }
                        New-HTMLTag -Tag 'span' -Attributes @{ style = $($Tab.StyleText ) } -Value { $Tab.Name }
                    }
                }
            }
        }
    }

}

function New-InternalDiagram {
    [CmdletBinding()]
    param(
        [System.Collections.IList] $Nodes,
        [System.Collections.IList] $Edges,
        [System.Collections.IList] $Events,
        [System.Collections.IDictionary] $Options,
        [object] $Height,
        [object] $Width,
        [string] $BackgroundImage,
        [string] $BackgroundSize = '100% 100%',
        [switch] $IconsAvailable,
        [switch] $DisableLoader
    )
    $Script:HTMLSchema.Features.VisNetwork = $true
    $Script:HTMLSchema.Features.VisData = $true
    $Script:HTMLSchema.Features.Moment = $true
    $Script:HTMLSchema.Features.VisNetworkLoad = $true
    $Script:HTMLSchema.Features.EscapeRegex = $true
    # We need to disable loader if physics is disabled, as it doesn't give us anything
    # and it prevents loading
    if ($Options.physics -and $Options.physics.enabled -eq $false) {
        $DisableLoader = $true
    }
    if (-not $DisableLoader) {
        $Script:HTMLSchema.Features.VisNetworkLoadingBar = $true
    }
    # Vis network clustering allows to cluster more than 1 node, there's no code to enable it yet
    #$Script:HTMLSchema.Features.VisNetworkClustering = $true


    [string] $ID = "Diagram-" + (Get-RandomStringName -Size 8)

    $Style = [ordered] @{
        position = 'relative'
        width    = ConvertFrom-Size -Size $Width
        height   = ConvertFrom-Size -Size $Height
    }
    if ($BackgroundImage) {
        $Style['background'] = "url('$BackgroundImage')"
        $Style['background-size'] = $BackgroundSize
    }

    $AttributesOutside = [ordered] @{
        class = 'diagram'
        style = $Style
    }

    $AttributesInside = [ordered] @{
        class = 'diagram diagramObject'
        style = @{
            position = 'absolute'
        }
        id    = "$ID"
    }

    if (-not $DisableLoader) {
        $Div = New-HTMLTag -Tag 'div' -Attributes @{ class = 'diagramWrapper' } -Value {
            New-HTMLTag -Tag 'div' -Attributes $AttributesOutside -Value {
                New-HTMLTag -Tag 'div' -Attributes $AttributesInside
            }
            New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramLoadingBar"; class = 'diagramLoadingBar' } {
                New-HTMLTag -Tag 'div' -Attributes @{ class = "diagramOuterBorder" } {
                    New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramText"; class = 'diagramText' } -Value { '0%' }
                    New-HTMLTag -Tag 'div' -Attributes @{ class = 'diagramBorder' } {
                        New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramBar"; class = 'diagramBar' }
                    }
                }
            }
        }

        <#
        $Div = New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramWrapper"; class = 'diagramWrapper' } -Value {
            New-HTMLTag -Tag 'div' -Attributes $AttributesOutside -Value {
                New-HTMLTag -Tag 'div' -Attributes $AttributesInside
            }
            New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramLoadingBar"; class = 'diagramLoadingBar' } {
                New-HTMLTag -Tag 'div' -Attributes @{ class = "$ID-diagramOuterBorder" } {
                    New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramText"; class = 'diagramText' } -Value { '0%' }
                    New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramBorder"; class = 'diagramBorder' } {
                        New-HTMLTag -Tag 'div' -Attributes @{ id = "$ID-diagramBar"; class = 'diagramBar' }
                    }
                }
            }
        }
        #>
    } else {
        $Div = New-HTMLTag -Tag 'div' -Attributes $AttributesOutside {
            New-HTMLTag -Tag 'div' -Attributes $AttributesInside
        }
    }
    $ConvertedNodes = $Nodes -join ', '
    $ConvertedEdges = $Edges -join ', '

    if ($Events.Count -gt 0) {
        [Array] $PreparedEvents = @(

            'network.on("click", function (params) {'
            'params.event = "[original event]";'
            'var findValue = escapeRegExp(params.nodes);'
            foreach ($_ in $Events) {
                New-DiagramInternalEvent -ID $_.ID -ColumnID $_.ColumnID
            }
            '});'
        )
    }
    if ($DisableLoader) {
        $LoadingBarEvent = ''
    } else {
        $LoadingBarEvent = @"
            network.on("stabilizationProgress", function (params) {
                var maxWidth = 496;
                var minWidth = 20;
                var widthFactor = params.iterations / params.total;
                var width = Math.max(minWidth, maxWidth * widthFactor);

                document.getElementById("$ID-diagramBar").style.width = width + "px";
                document.getElementById("$ID-diagramText").innerHTML = Math.round(widthFactor * 100) + "%";
            });
            network.once("stabilizationIterationsDone", function () {
                document.getElementById("$ID-diagramText").innerHTML = "100%";
                document.getElementById("$ID-diagramBar").style.width = "496px";
                document.getElementById("$ID-diagramLoadingBar").style.opacity = 0;
                // really clean the dom element
                setTimeout(function () {
                    document.getElementById("$ID-diagramLoadingBar").style.display = "none";
                }, 500);
            });
            //window.addEventListener("load", () => {
            //    draw();
            //});
"@
    }

    $FunctionInclude = @"
    function loadDiagram(container, data, options) {
        var network = new vis.Network(container, data, options);
        $PreparedEvents
        $LoadingBarEvent
    }
"@

    $Script = New-HTMLTag -Tag 'script' -Value {
        # Convert Dictionary to JSON and return chart within SCRIPT tag
        # Make sure to return with additional empty string

        '// create an array with nodes'
        "var nodes = new vis.DataSet([$ConvertedNodes]); "

        '// create an array with edges'
        "var edges = new vis.DataSet([$ConvertedEdges]); "

        '// create a network'
        "var container = document.getElementById('$ID'); "
        "var data = { "
        "   nodes: nodes, "
        "   edges: edges"
        " }; "

        if ($Options) {
            $ConvertedOptions = $Options | ConvertTo-Json -Depth 5 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
            "var options = $ConvertedOptions; "
        } else {
            "var options = { }; "
        }
        $DisableLoaderString = (-not $DisableLoader).ToString().ToLower()
        $IconsAvailableString = $IconsAvailable.IsPresent.ToString().ToLower()
        "var network = loadDiagramWithFonts(container, data, options, '$ID', $DisableLoaderString , $IconsAvailableString);"
        "diagramTracker['$ID'] = network;"
        "$PreparedEvents"

    } -NewLine

    $Div
    $Script:HTMLSchema.Diagrams.Add($Script)
}
function New-RequestCssConfiguration {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $Pair,
        [System.Collections.IDictionary] $CssConfiguration,
        [string] $Feature,
        [string] $Type
    )
    # This process copies existing css code into new named class names
    $Name = $(Get-RandomStringName -Size 7)
    $ExpectedStyleSheetsConfiguration = [ordered] @{}
    foreach ($Key in $Pair.Keys) {
        $ExpectedStyleSheetsConfiguration[$Key] = ".$Key-$Name"
    }
    $RenamePair = [ordered] @{}
    foreach ($Key in $Pair.Keys) {
        $ClassName = $Pair[$Key]
        $RenamePair[$ClassName] = $ExpectedStyleSheetsConfiguration[$Key]
    }
    # We want to use different configuration for section based on existing original template
    # So we copy original CSSConfiguration
    $CssConfiguration = Copy-Dictionary -Dictionary $CssConfiguration
    # We then remove everything we're not interested in leaving only X sections that we modify
    Remove-ConfigurationCSS -CSS $CssConfiguration -Not -Section $Pair.Values
    # We now need to rename existing CSS classes to their new names
    Rename-Dictionary -HashTable $CssConfiguration -Pair $RenamePair

    # Now we need to get already existing CSS code that we may have generaed for other sections
    $CssOtherConfiguration = Get-ConfigurationCss -Feature $Feature -Type $Type
    # Finally we need to inject this into CSSInline configuration so it's delivered as style to final destination
    Set-ConfigurationCSS -CSS ($CssOtherConfiguration + $CssConfiguration) -Feature $Feature -Type $Type

    # We also need to tell that we actually want this added
    $Script:HTMLSchema.Features.$Feature = $true
    # Finally we overwrite what we need to deliver to users
    @{
        StyleSheetConfiguration = $ExpectedStyleSheetsConfiguration
        CssConfiguration        = $CssConfiguration
    }
}
function New-TableJavaScript {
    [cmdletBinding()]
    param(
        [string[]] $HeaderNames,
        [System.Collections.IDictionary] $Options
    )
    $Options['data'] = "markerForDataReplacement"
    [Array] $Options['columns'] = foreach ($Property in $HeaderNames) {
        @{ data = $Property.Replace('.', '\.') }
    }
    $Options['deferRender'] = $true
}
function New-TablePercentageBarInternal {
    [cmdletbinding()]
    param(
        [int] $ColumnID,
        [string] $ColumnName,
        [ValidateSet('square', 'round')][string] $Type,
        [string] $TextColor,
        [string] $BorderColor,
        [ValidateSet('solid', 'outset', 'groove', 'ridge')][string] $BorderStyle,
        [string] $BarColor,
        [string] $BackgroundColor,
        [int] $RoundValue
    )

    [ordered]@{
        targets = $ColumnID
        render  = "`$.fn.dataTable.render.percentBar('$Type','$TextColor', '$BorderColor', '$BarColor', '$BackgroundColor', $RoundValue, '$BorderStyle')"
    }
}
function New-TableServerSide {
    [cmdletBinding()]
    param(
        [Array] $DataTable,
        [string] $DataTableID,
        [string[]] $HeaderNames,
        [System.Collections.IDictionary] $Options
    )
    if ($Script:HTMLSchema['TableOptions']['Type'] -eq 'structured') {
        $DataPath = [io.path]::Combine($Script:HTMLSchema['TableOptions']['Folder'], 'data')
        $FilePath = [io.path]::Combine($DataPath, "$DataTableID.json")
        $null = New-Item -Path $DataPath -ItemType Directory -Force
        $Data = @{
            data = $DataTable
        }

        $Data | ConvertTo-JsonLiteral -Depth 1 `
            -NumberAsString:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].NumberAsString `
            -BoolAsString:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].BoolAsString `
            -DateTimeFormat $Script:HTMLSchema['TableOptions']['DataStoreOptions'].DateTimeFormat | Out-File -FilePath $FilePath
        $Options['ajax'] = -join ('data', '\', "$DataTableID.json")
    } else {
        # there is possibility for array without column names, not sure if it's worth the time
    }
    [Array] $Options['columns'] = foreach ($Property in $HeaderNames) {
        #@{ data = $Property }
        @{ data = $Property.Replace('.', '\.') }
    }
    $Options['deferRender'] = $true
}
$Script:ConfigurationURL = 'https://cdn.jsdelivr.net/gh/evotecit/cdn@0.0.10'
$Script:Configuration = [ordered] @{
    Features = [ordered] @{
        Inject                      = @{
            HeaderAlways = @{
                CssInline = [ordered] @{}
            }
            Default      = $true
            Email        = $false
        }
        Fonts                       = @{
            Comment      = 'Default fonts'
            HeaderAlways = @{
                #CssLink = 'https://fonts.googleapis.com/css?family=Roboto|Hammersmith+One|Questrial|Oswald'
                #CssLink = 'https://fonts.googleapis.com/css?family=Roboto'
                CssLink = 'https://fonts.googleapis.com/css2?family=Roboto+Condensed&display=swap'
            }
            Default      = $true
            Email        = $false
        }
        FontsAwesome                = @{
            Comment = 'Default fonts icons'
            Header  = @{
                CssLink = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\fontsAwesome.css"
            }
            Other   = @{
                Link = 'https://use.fontawesome.com/releases/v5.15.1/svgs/'
            }
            Default = $true
            Email   = $false
        }
        Main                        = [ordered]@{
            HeaderAlways = [ordered]@{
                CssInline = [ordered]@{
                    'body'  = [ordered]@{
                        # https://fonts.google.com/analytics
                        # https://web3canvas.com/best-fonts-for-web-designers/
                        #   font-family: "Raleway", sans-serif;
                        #'font-family' = 'Roboto Condensed, Helvetica Neue, sans-serif'
                        'font-family' = "'Roboto Condensed', sans-serif"
                        'font-size'   = '8pt'
                        'margin'      = '0px'
                    }
                    'input' = @{
                        'font-size' = '8pt'
                    }
                    #'table'          = @{
                    #'font-size' = '8pt'
                    #}
                    #'.defaultHeader' = [ordered]@{
                    #    'padding'     = '5px'
                    #    'margin'      = '0px 0px 0px 0px'
                    #    'font-weight' = 'bold'
                    #}
                    #'.defaultFooter' = [ordered]@{
                    #    'padding-right' = '5em'
                    #    'text-align'    = 'right'
                    #}
                    #'.container'     = [ordered]@{
                    #    'padding' = '2px 16px'
                    #}
                    #'.header'        = [ordered]@{
                    #    'background-color' = '#616a6b'
                    #    'color'            = '#f7f9f9'
                    #}
                    #'hr'    = [ordered]@{
                    #    'height'           = '4px'
                    #    'background-color' = '#6Cf'
                    #    'border'           = '0px'
                    #    'width'            = '100%'
                    #}
                    #'.card:hover' = [ordered]@{
                    #    'box-shadow' = '0 8px 16px 0 rgba(0, 0, 0, 0.2)'
                    #}
                    #'.col'        = [ordered]@{
                    #    'padding' = '20px'
                    #    'margin'  = '1%'
                    #    'flex'    = '1'
                    #}
                }
            }
            Default      = $true
            Email        = $false
        }
        MainFlex                    = [ordered] @{
            HeaderAlways = [ordered] @{
                CssInline = [ordered]@{
                    '.overflowHidden'      = [ordered] @{
                        'overflow'   = 'hidden'
                        'overflow-x' = 'hidden'
                        'overflow-y' = 'hidden'
                    }
                    '.flexParent'          = [ordered]@{
                        'display'         = 'flex'
                        'justify-content' = 'space-between'
                        #'padding'         = '2px'
                    }
                    '.flexParentInvisible' = [ordered]@{
                        'display'         = 'flex'
                        'justify-content' = 'space-between'
                    }
                    '.flexElement'         = [ordered]@{
                        'flex-basis' = '100%'
                    }
                    '.flexPanel'           = [ordered]@{
                        'flex-basis' = '100%'
                    }
                    '.flex-grid'           = [ordered]@{
                        'display' = 'flex'
                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        <# Doesn't seem to be in use
        MainLink                = [ordered]@{
            HeaderAlways = [ordered] @{
                CssInline = [ordered]@{
                    'a.alink:link'      = [ordered]@{
                        'color'           = '#007bff'
                        'text-decoration' = 'none'
                        'font-size'       = '120%'
                    }
                    'a.alink:visited'   = [ordered]@{
                        'color'           = '#ff8400'
                        'text-decoration' = 'none'
                        'font-size'       = '120%'
                    }
                    'a.alink:hover'     = [ordered]@{
                        'text-decoration' = 'underline'
                        'font-size'       = '130%'
                    }
                    'a.paginate_button' = [ordered]@{
                        'color'     = '#000000 !important'
                        'font-size' = '10px'
                    }
                    'a.current'         = [ordered]@{
                        'color' = '#000000 !important'
                    }
                }
            }
        }
        #>
        MainImage                   = [ordered]@{
            HeaderAlways = [ordered] @{
                CssInline = [ordered]@{
                    '.legacyLogo'      = [ordered]@{
                        'display' = 'flex'
                    }
                    '.legacyLeftLogo'  = [ordered]@{
                        'flex-basis'     = '100%'
                        'border'         = '0px'
                        'padding-left'   = '0px'
                        'vertical-align' = 'middle'
                    }
                    '.legacyRightLogo' = [ordered]@{
                        'flex-basis'     = '100%'
                        'border'         = '0px'
                        'padding-right'  = '5em'
                        'text-align'     = 'right'
                        'vertical-align' = 'middle'
                    }
                    '.legacyImg'       = [ordered]@{
                        'border-radius' = '5px 5px 0 0'
                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        <#
        Default                 = @{
            Comment      = 'Always Required Default Visual Settings'
            HeaderAlways = @{
                CssInline = [ordered] @{
                    # Workaround for IE 11
                    '@media all and (-ms-high-contrast:active)' = @{
                        '.defaultSection' = @{
                            'display' = 'flex'
                        }
                    }
                    '.defaultSection'                           = [ordered] @{
                        #'display'        = 'flex' # added to allow diagram to resize properly
                        'flex-direction' = 'column' # added to allow diagram to resize properly
                        #'flex-direction' = 'default' # added to allow diagram to resize properly
                        'border'         = '1px solid #bbbbbb'
                        'padding-bottom' = '0px'
                        'margin'         = '5px'
                        'width'          = 'calc(100% - 10px)'
                        'box-shadow'     = '0 4px 8px 0 rgba(0, 0, 0, 0.2)'
                        'transition'     = '0.3s'
                        'border-radius'  = '5px'
                    }
                    '.defaultSectionHead'                       = [ordered] @{
                        'display'          = 'flex'
                        'justify-content'  = 'center'
                        'padding'          = '5px'
                        'margin'           = '0px 0px 0px 0px'
                        'font-weight'      = 'bold'
                        "background-color" = ConvertFrom-Color -Color "DeepSkyBlue"
                        'color'            = ConvertFrom-Color -Color "White"
                    }
                    '.defaultSectionText'                       = [ordered] @{
                        "text-align" = 'center'
                    }
                    #'.defaultSectionContent'                    = [ordered] @{
                    #'padding-top'   = '5px'
                    #'padding-right' = '5px'
                    #'padding-left'  = '5px'
                    #'padding' = '5px'
                    #}
                    '.defaultPanel'                             = [ordered] @{
                        'box-shadow'    = '0 4px 8px 0 rgba(0, 0, 0, 0.2)'
                        'transition'    = '0.3s'
                        'border-radius' = '5px'
                        'margin'        = '5px'
                    }
                    #'.defaultText'                              = [ordered] @{
                    #    'margin' = '5px'
                    #}
                }
                # We want email to have no margins
                # CssInlineNoScript = @{
                #     '.defaultText' = [ordered] @{
                #         'margin' = '0px !important'
                #    }
                # }
            }
        }
        #>
        DefaultImage                = @{
            Comment      = 'Image Style'
            HeaderAlways = @{
                CssInline = [ordered] @{
                    '.logo' = [ordered] @{
                        'margin' = '5px'
                    }
                }
                # We want email to have no margins
                #CssInlineNoScript = @{
                #    '.logo' = [ordered] @{
                #        'margin' = '0px !important'
                #    }
                #}
            }
            Default      = $true
            Email        = $true
        }
        DefaultPanel                = @{
            Comment      = 'Panel Style'
            HeaderAlways = @{
                CssInline = [ordered] @{
                    '.defaultPanel' = [ordered] @{
                        'box-shadow'    = '0 4px 8px 0 rgba(0, 0, 0, 0.2)'
                        'transition'    = '0.3s'
                        'border-radius' = '5px'
                        'margin'        = '5px'
                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        DefaultSection              = @{
            Comment      = 'Section Style'
            HeaderAlways = @{
                CssInline = [ordered] @{
                    # Workaround for IE 11
                    '@media all and (-ms-high-contrast:active)' = @{
                        '.defaultSection' = @{
                            'display' = 'flex'
                        }
                    }
                    '.defaultSection'                           = [ordered] @{
                        #'display'        = 'flex' # added to allow diagram to resize properly
                        'flex-direction' = 'column' # added to allow diagram to resize properly
                        #'flex-direction' = 'default' # added to allow diagram to resize properly
                        'border'         = '1px solid #bbbbbb'
                        'padding-bottom' = '0px'
                        'margin'         = '5px'
                        'width'          = 'calc(100% - 10px)'
                        'box-shadow'     = '0 4px 8px 0 rgba(0, 0, 0, 0.2)'
                        'transition'     = '0.3s'
                        'border-radius'  = '5px'
                    }
                    '.defaultSectionHead'                       = [ordered] @{
                        'display'          = 'flex'
                        'justify-content'  = 'center'
                        'padding'          = '5px'
                        'margin'           = '0px 0px 0px 0px'
                        'font-weight'      = 'bold'
                        "background-color" = ConvertFrom-Color -Color "DeepSkyBlue"
                        'color'            = ConvertFrom-Color -Color "White"
                    }
                    #'.defaultSectionContent'                    = [ordered] @{
                    #'padding-top'   = '5px'
                    #'padding-right' = '5px'
                    #'padding-left'  = '5px'
                    #'padding' = '5px'
                    #}
                }
            }
            Default      = $true
            Email        = $false
        }
        DefaultHeadings             = @{
            Comment      = 'Heading Style'
            HeaderAlways = @{
                CssInline = [ordered] @{
                    'h1' = [ordered] @{
                        'margin' = '5px'
                    }
                    'h2' = [ordered] @{
                        'margin' = '5px'
                    }
                    'h3' = [ordered] @{
                        'margin' = '5px'
                    }
                    'h4' = [ordered] @{
                        'margin' = '5px'
                    }
                    'h5' = [ordered] @{
                        'margin' = '5px'
                    }
                    'h6' = [ordered] @{
                        'margin' = '5px'
                    }
                }
                # We want email to have no margins
                # CssInlineNoScript = @{
                # 'h1' = [ordered] @{
                # 'margin' = '0px !important'
                # }
                # 'h2' = [ordered] @{
                # 'margin' = '0px !important'
                # }
                # 'h3' = [ordered] @{
                # 'margin' = '0px !important'
                # }
                # 'h4' = [ordered] @{
                # 'margin' = '0px !important'
                # }
                # 'h5' = [ordered] @{
                # 'margin' = '0px !important'
                # }
                # 'h6' = [ordered] @{
                # 'margin' = '0px !important'
                # }
                # }
            }
            Default      = $true
            Email        = $true
        }
        DefaultText                 = @{
            Comment      = 'Text Style'
            HeaderAlways = @{
                CssInline = [ordered] @{
                    '.defaultText' = [ordered] @{
                        'margin' = '5px'
                    }
                }
                # We want email to have no margins
                #CssInlineNoScript = @{
                #    '.defaultText' = [ordered] @{
                #        'margin' = '0px !important'
                #        #'background' = 'red'
                #    }
                #}
            }
            Default      = $true
            Email        = $true
        }
        Accordion                   = @{
            Comment      = 'Accordion'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\accordion-1.css"
            }
            Default      = $true
            Email        = $false
        }
        AccordionFAQ                = @{
            Comment      = 'Accordion FAQ'
            Header       = @{
                CssLink = 'https://unpkg.com/accordion-js@3.0.0/dist/accordion.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\accordion.min.css"
                JsLink  = 'https://unpkg.com/accordion-js@3.0.0/dist/accordion.min.js'
                JS      = "$PSScriptRoot\Resources\JS\accordion.min.js"
            }
            HeaderAlways = @{
                CssInline = @{
                    '.accordion-container' = @{
                        margin  = '5px'
                        padding = '0px'
                        color   = '#4d5974'

                    }
                    '.ac'                  = @{
                        # 'border-style' = 'none'
                    }
                    '.ac-header'           = @{
                        #border = 'none' # '1px solid #03b5d2'
                        #'border-style' = 'none'
                    }
                    '.ac-panel'            = @{
                        #border = 'none'
                        #'border-style' = 'none'

                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        CarouselKineto              = @{
            Comment     = 'Kineto JS Library'
            Header      = @{
                CssLinkOriginal = 'https://cdn.jsdelivr.net/gh/findawayer/kineto@main/dist/kineto.css'
                CssLink         = "$($Script:ConfigurationURL)/CSS/kineto.min.css", "$($Script:ConfigurationURL)/CSS/kinetoStyle.min.css"
                Css             = "$PSScriptRoot\Resources\CSS\kineto.min.css", "$PSScriptRoot\Resources\CSS\kinetoStyle.css"
            }
            #HeaderAlways = @{
            #    Css = "$PSScriptRoot\Resources\CSS\kinetoStyle.css"
            #}
            Body        = @{
                JSLinkOriginal = "https://cdn.jsdelivr.net/gh/findawayer/kineto@main/dist/kineto.js"
                JSLink         = "$($Script:ConfigurationURL)/JS/kineto.min.js"
                JS             = "$PSScriptRoot\Resources\JS\kineto.min.js"
            }
            LicenseLink = 'https://github.com/findawayer/kineto/blob/main/LICENSE'
            License     = 'MIT'
            SourceCodes = 'https://github.com/findawayer/kineto'
            Default     = $true
            Email       = $false
        }
        CodeBlocks                  = @{
            Comment      = 'EnlighterJS CodeBlocks'
            Header       = @{
                CssLink = 'https://cdn.jsdelivr.net/npm/enlighterjs@3.4.0/dist/enlighterjs.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\enlighterjs.min.css"
                JsLink  = 'https://cdn.jsdelivr.net/npm/enlighterjs@3.4.0/dist/enlighterjs.min.js'
                JS      = "$PSScriptRoot\Resources\JS\enlighterjs.min.js"
            }
            Footer       = @{

            }
            HeaderAlways = @{
                #Css       = "$PSScriptRoot\Resources\CSS\enlighterjs.css"
                CssInline = @{
                    'div.enlighter-default' = @{
                        'flex-basis'    = '100%'
                        'margin'        = '5px'
                        'border-radius' = '0px'
                    }
                }
            }
            FooterAlways = @{
                JS = "$PSScriptRoot\Resources\JS\enlighterjs-footer.js"
            }
            LicenseLink  = 'https://github.com/EnlighterJS/EnlighterJS/blob/master/LICENSE.txt'
            License      = 'Mozilla Public License 2.0'
            SourceCodes  = 'https://github.com/EnlighterJS/EnlighterJS'
            Default      = $true
            Email        = $false
        }
        CodeBlocksHighlight         = @{
            # future / possible use case # https://highlightjs.org/static/demo/
            Comment     = 'HighlightJS CodeBlocks'
            Header      = @{
                CssLink = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.1.2/styles/default.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\highlight.min.css"
                JsLink  = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.1.2/highlight.min.js'
                JS      = "$PSScriptRoot\Resources\JS\highlight.min.js"
            }
            License     = 'BSD 3-Clause "New" or "Revised" License'
            LicenseLink = 'https://github.com/highlightjs/highlight.js/blob/master/LICENSE'
            SourceCodes = 'https://github.com/highlightjs/highlight.js'
            Default     = $true
            Email       = $false
        }
        ChartsApex                  = @{
            Comment = 'Apex Charts'
            Header  = @{
                JsLink = @(
                    'https://cdn.jsdelivr.net/npm/promise-polyfill@8/dist/polyfill.min.js' # If you need to make it work with IE11, you need to include these polyfills before including ApexCharts
                    'https://cdn.jsdelivr.net/npm/eligrey-classlist-js-polyfill@1.2.20180112/classList.min.js' # If you need to make it work with IE11, you need to include these polyfills before including ApexCharts
                    'https://cdn.jsdelivr.net/npm/findindex_polyfill_mdn@1.0.0/findIndex.min.js' # You will need this only if you require timeline/rangebar charts
                    #'https://unpkg.com/canvg@3.0.4/lib/umd.js' # You will need this only if you require PNG download of your charts
                    'https://cdn.jsdelivr.net/npm/apexcharts@3.26.0/dist/apexcharts.min.js'
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\polyfill.min.js"
                    "$PSScriptRoot\Resources\JS\classList.min.js"
                    "$PSScriptRoot\Resources\JS\findIndex.min.js"
                    #"$PSScriptRoot\Resources\JS\umd.min.js"
                    "$PSScriptRoot\Resources\JS\apexcharts.min.js"
                )
            }
            Default = $true
            Email   = $false
        }
        ChartsEvents                = [ordered] @{
            HeaderAlways = @{
                Js        = "$PSScriptRoot\Resources\JS\apexchartsEvents.js"
                JsInLine  = "var dataTablesChartsEvents = {}; var count = 0;"
                CssInline = @{
                    'td.highlight' = @{
                        'background-color' = 'yellow';
                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        ChartsOrg                   = [ordered] @{
            Comment      = 'OrgChart'
            Header       = @{
                CssLink = 'https://cdnjs.cloudflare.com/ajax/libs/orgchart/3.1.0/css/jquery.orgchart.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\jquery.orgchart.min.css"
                JsLink  = 'https://cdnjs.cloudflare.com/ajax/libs/orgchart/3.1.0/js/jquery.orgchart.min.js'
                Js      = "$PSScriptRoot\Resources\JS\jquery.orgchart.min.js"
            }
            HeaderAlways = [ordered] @{
                CssInline = [ordered] @{

                    '.orgchartWrapper' = @{
                        'min-height'    = '420px'
                        'border'        = '1px dashed #aaa'
                        'border-radius' = '0px'
                        'text-align'    = 'center'
                        'margin'        = '5px'
                        #background      = '#fff';

                        'display'       = 'flex'
                        'flex-basis'    = '100%'
                        'overflow'      = 'hidden'
                    }

                    '.orgchart'        = @{
                        'background-image' = 'none'
                        'min-height'       = '420px'
                        'border'           = '1px dashed #aaa'
                        #'border-radius' = '0px'
                        #'text-align'    = 'center'
                        #'margin'        = '5px'
                        'flex-basis'       = '100%'
                    }
                    #".oc-export-btn"   = @{
                    #    'flex-basis' = '100%'
                    #}
                    <#
                    '.orgchart .lines .topLine'   = @{
                        'border-top-width' = '2px'
                        'border-top-style' = 'solid'
                        'border-top-color' = 'blue'
                    }
                    '.orgchart .lines .rightLine' = @{
                        'border-right-width' = '1px'
                        'border-right-style' = 'solid'
                        'border-right-color' = 'blue'
                    }
                    '.orgchart .lines .leftLine'  = @{
                        'border-left-width' = '1px'
                        'border-left-style' = 'solid'
                        'border-left-color' = 'blue'
                    }
                    '.orgchart .lines .downLine'  = @{
                        'background-color' = 'blue'
                    }
                    #>
                }
            }
            Default      = $true
            Email        = $false
            License      = 'MIT'
            LicenseLink  = 'https://github.com/dabeng/OrgChart/blob/master/LICENSE'
            SourceCodes  = 'https://github.com/dabeng/OrgChart'
            Demo         = 'https://codepen.io/collection/AWxGVb/', 'https://dabeng.github.io/OrgChart/'
        }
        ChartsOrgExportPDF          = @{
            Comment = 'OrgChartExport'
            Header  = @{
                JsLink = 'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.3.1/jspdf.umd.min.js'
                Js     = "$PSScriptRoot\Resources\JS\jspdf.min.js"
            }
            Default = $true
            Email   = $false
        }
        ChartsOrgExportPNG          = @{
            Comment = 'OrgChartExport'
            Header  = @{
                JsLink = 'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/0.5.0-beta4/html2canvas.min.js'
                Js     = "$PSScriptRoot\Resources\JS\html2canvas.min.js"
            }
            Default = $true
            Email   = $false
        }
        ChartsXkcd                  = @{
            Header      = @{
                JsLink = @(
                    'https://cdn.jsdelivr.net/npm/chart.xkcd@1.1.12/dist/chart.xkcd.min.js'
                )
                Js     = @(
                    "$PSScriptRoot\Resources\JS\chart.xkcd.min.js"
                )
            }
            LicenseLink = 'https://github.com/timqian/chart.xkcd/blob/master/LICENSE'
            License     = 'MIT'
            SourceCodes = 'https://github.com/timqian/chart.xkcd'
            Default     = $true
            Email       = $false
        }
        ES6Promise                  = @{
            Comment = 'ES6Promise'
            Header  = @{
                JSLink = "https://cdn.jsdelivr.net/npm/es6-promise@4/dist/es6-promise.auto.min.js"
                Js     = "$PSScriptRoot\Resources\JS\es6-promise.auto.min.js"

            }
            Default = $true
            Email   = $false
        }
        Jquery                      = @{
            Comment     = 'Jquery'
            Header      = @{
                JsLink = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js' # 'https://code.jquery.com/jquery-3.5.1.min.js'
                Js     = "$PSScriptRoot\Resources\JS\jquery.min.js"
            }
            LicenseLink = 'https://github.com/jquery/jquery/blob/main/LICENSE.txt'
            License     = 'MIT'
            SourceCodes = 'https://github.com/jquery/jquery'
            Default     = $true
            Email       = $false
        }
        DataTables                  = @{
            Comment      = 'DataTables'
            HeaderAlways = @{
                CssInline   = @{
                    #/* Added to make sure plus logo fits in */
                    'td'                               = @{
                        'height' = '14px'
                    }
                    #/* Button in Table - giving it some colors */
                    <#
                    'td.sorting_1::before'   = @{
                        'background-color' = '#007bff !important'
                    }
                    'td::before'             = @{
                        'background-color' = '#007bff !important'
                    }
                    #>
                    'td::before, td.sorting_1::before' = @{
                        'background-color' = '#007bff !important'
                    }
                    # /* giving some spaces between tables being to close */
                    'div.dataTables_wrapper'           = @{
                        #    'padding' = '10px 10px 10px 10px'
                        'margin' = '5px';
                    }
                    'button.dt-button'                 = @{
                        #'font-size'     = '8pt !important'
                        'color'         = 'blue !important'
                        'border-radius' = '5px'
                        'line-height'   = '1 !important'
                    }
                    #/* Filtering at the bottom */
                    'tfoot input'                      = @{
                        'width'      = '100%'
                        'padding'    = '-3px'
                        'box-sizing' = 'border-box'
                    }
                    #/* Filtering at the top */
                    'thead input'                      = @{
                        'width'      = '100%'
                        'padding'    = '-3px'
                        'box-sizing' = 'border-box'
                    }
                    #'tr:nth-of-type(odd)'  = @{
                    #'background-color' = '#F6F6F5'
                    #'background-color' = 'green'
                    #}

                    # 'tr:nth-of-type(even)' = @{
                    #    'background-color' = 'yellow'
                    #}
                    #'table'                  = @{
                    #'font-size' = '8pt'
                    #}
                    #'th'                     = @{
                    #'font-size' = '8pt'
                    #}
                    #'.dataTables_info'       = @{
                    #/* lower left */
                    #'font-size' = '8pt'
                    #}
                    #'.dataTables_filter'     = @{
                    #'font-size' = '8pt'
                    #}
                }         #= "$PSScriptRoot\Resources\CSS\datatables.css"
                CssNoscript = "$PSScriptRoot\Resources\CSS\datatables.noscript.css"
                #JsInLine    = "var dataTablesInitializationTracker = {};"
            }
            Header       = @{
                CssLink = @(
                    "https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"
                    "https://cdn.datatables.net/select/1.3.1/css/select.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.jquery.min.css"
                    "$PSScriptRoot\Resources\CSS\dataTables.select.min.css"
                )
                JsLink  = @(
                    "https://cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"
                    "https://cdn.datatables.net/select/1.3.1/js/dataTables.select.min.js"
                    "https://cdn.datatables.net/plug-ins/1.10.24/sorting/datetime-moment.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.jquery.min.js"
                    "$PSScriptRoot\Resources\JS\dataTables.select.min.js"
                    "$PSScriptRoot\Resources\JS\dataTables.datetimeMoment.js"
                )
            }
            Default      = $true
            Email        = $false
        }
        DataTablesEmail             = @{
            Comment      = 'DataTables for use in Email'
            HeaderAlways = @{
                #Css = "$PSScriptRoot\Resources\CSS\datatables.noscript.css"
                CssInline = @{
                    'table'          = @{
                        'border-collapse' = 'collapse'
                        'box-sizing'      = 'border-box'
                        'width'           = '100%'
                    }
                    'table td'       = @{
                        'border-width' = '1px'
                        'padding'      = '4px'
                        'text-align'   = 'left'
                        #'border-top'   = '1px solid #ddd'
                        'border'       = '1px solid black'
                    }
                    'table thead th' = @{
                        #'color'= 'white';
                        'text-align'       = 'center';
                        'font-weight'      = 'bold';
                        'padding'          = '4px 17px';
                        #'border-bottom'    = '1px solid #111'
                        'background-color' = 'white'
                        'color'            = 'black'
                        'border'           = '1px solid black'
                    }
                    'table tfoot th' = @{
                        #'color'= 'white'
                        'text-align'       = 'center'
                        'font-weight'      = 'bold'
                        'padding'          = '4px 17px'
                        #'border-top'       = '1px solid #111'
                        'background-color' = 'white'
                        'color'            = 'black'
                        'border'           = '1px solid black'
                    }
                    # not needed as not visible in Email anyways
                    #'table tr:nth-of-type(odd)'  = @{
                    #    'background-color' = '#F6F6F5'
                    #}
                    #'table tr:nth-of-type(even)' = @{
                    #    'background-color' = 'white'
                    #}
                    #'table td, table th'         = @{
                    #    'border' = '1px solid black'
                    #}
                }
            }
            Default      = $false
            Email        = $true
        }
        DataTablesAutoFill          = @{
            Comment = 'DataTables AutoFill Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/autofill/2.3.5/js/dataTables.autoFill.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.autoFill.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/autofill/2.3.5/css/autoFill.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.autoFill.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesButtons           = @{
            Comment = 'DataTables Buttons Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/buttons/1.6.5/js/dataTables.buttons.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.buttons.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/buttons/1.6.5/css/buttons.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\datatables.buttons.min.css"
                )
            }
            Default = $true
            Email   = $false
        }

        DataTablesButtonsHTML5      = @{
            Comment = 'DataTables ButtonsHTML5 Features'
            Header  = @{
                JsLink = @(
                    "https://cdn.datatables.net/buttons/1.6.5/js/buttons.html5.min.js"
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\datatables.buttons.html5.min.js"
                )
            }
            Default = $true
            Email   = $false
        }

        DataTablesButtonsPrint      = @{
            Comment = 'DataTables ButtonsPrint Features'
            Header  = @{
                JsLink = @(
                    "https://cdn.datatables.net/buttons/1.6.5/js/buttons.print.min.js"
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\datatables.buttons.print.min.js"
                )
            }
            Default = $true
            Email   = $false
        }

        DataTablesButtonsPDF        = @{
            Comment = 'DataTables PDF Features'
            Header  = @{
                JsLink = @(
                    'https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/pdfmake.min.js'
                    'https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/vfs_fonts.js'
                )
                Js     = @(
                    "$PSScriptRoot\Resources\JS\pdfmake.min.js"
                    "$PSScriptRoot\Resources\JS\vfs_fonts.min.js"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesButtonsExcel      = @{
            Comment = 'DataTables Excel Features'
            Header  = @{
                JsLink = @(
                    'https://cdnjs.cloudflare.com/ajax/libs/jszip/2.5.0/jszip.min.js'
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\jszip.min.js"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesConditions        = @{
            Comment      = 'DataTables Conditions'
            FooterAlways = @{
                #JsLink = @(
                #    'https://cdnjs.cloudflare.com/ajax/libs/jszip/2.5.0/jszip.min.js'
                #)
                JS = @(
                    "$PSScriptRoot\Resources\JS\dataTables.conditions.js"
                )
            }
            Default      = $true
            Email        = $false
        }
        DataTablesColReorder        = @{
            Comment = 'DataTables ColReorder Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/colreorder/1.5.3/js/dataTables.colReorder.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.colReorder.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/colreorder/1.5.3/css/colReorder.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.colReorder.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesFixedColumn       = @{
            Comment = 'DataTables Fixed Column Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/fixedcolumns/3.3.2/js/dataTables.fixedColumns.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.fixedColumns.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/fixedcolumns/3.3.2/css/fixedColumns.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.fixedColumns.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesFixedHeader       = @{
            Comment      = 'DataTables Fixed Header Features'
            HeaderAlways = @{
                JsInLine = "var dataTablesFixedTracker = {};"
            }
            Header       = @{
                JsLink  = @(
                    "https://cdn.datatables.net/fixedheader/3.1.8/js/dataTables.fixedHeader.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.fixedHeader.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/fixedheader/3.1.8/css/fixedHeader.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.fixedHeader.min.css"
                )
            }
            Default      = $true
            Email        = $false
        }
        DataTablesKeyTable          = @{
            Comment = 'DataTables KeyTable Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/keytable/2.6.0/js/dataTables.keyTable.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.keyTable.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/keytable/2.6.0/css/keyTable.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.keyTable.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesPercentageBars    = @{
            Comment = 'DataTables PercentageBars'
            Header  = @{
                JsLink = @(
                    "https://cdn.datatables.net/plug-ins/1.10.22/dataRender/percentageBars.js"
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\dataTables.percentageBars.js"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesResponsive        = @{
            Comment = 'DataTables Responsive Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/responsive/2.2.7/js/dataTables.responsive.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.responsive.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/responsive/2.2.7/css/responsive.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.responsive.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesRowGrouping       = @{
            Comment = 'DataTables RowGrouping Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/rowgroup/1.1.2/js/dataTables.rowGroup.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.rowGroup.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/rowgroup/1.1.2/css/rowGroup.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.rowGroup.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesRowReorder        = @{
            Comment = 'DataTables RowReorder Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/rowreorder/1.2.7/js/dataTables.rowReorder.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.rowReorder.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/rowreorder/1.2.7/css/rowReorder.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.rowReorder.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesScroller          = @{
            Comment = 'DataTables Scroller Features'
            Header  = @{
                JsLink  = @(
                    "https://cdn.datatables.net/scroller/2.0.3/js/dataTables.scroller.min.js"
                )
                JS      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.scroller.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/scroller/2.0.3/css/scroller.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.scroller.min.css"
                )
            }
            Default = $true
            Email   = $false
        }
        DataTablesSearchBuilder     = @{
            # https://datatables.net/blog/2020-09-01
            Comment = 'DataTables SearchBuilder'
            Header  = @{
                JSLinkOriginal  = "https://nightly.datatables.net/searchbuilder/js/dataTables.searchBuilder.js"
                JsLink          = "$($Script:ConfigurationURL)/JS/dataTables.searchBuilder.min.js" # "https://cdn.datatables.net/searchbuilder/1.0.1/js/dataTables.searchBuilder.min.js"
                JS              = "$PSScriptRoot\Resources\JS\dataTables.searchBuilder.js"
                CssLinkOriginal = 'https://nightly.datatables.net/searchbuilder/css/searchBuilder.dataTables.css' # 'https://cdn.datatables.net/searchbuilder/1.0.1/css/searchBuilder.dataTables.min.css'
                CssLink         = "$($Script:ConfigurationURL)/CSS/dataTables.searchBuilder.min.css" # 'https://cdn.datatables.net/searchbuilder/1.0.1/css/searchBuilder.dataTables.min.css'
                Css             = "$PSScriptRoot\Resources\CSS\dataTables.searchBuilder.css"
            }
            Default = $true
            Email   = $false
        }
        <#
        DataTablesSearchBuilder   = @{
            # https://datatables.net/blog/2020-09-01
            Comment = 'DataTables SearchBuilder'
            Header  = @{
                JsLink  = "https://nightly.datatables.net/searchbuilder/js/dataTables.searchBuilder.js" # "https://cdn.datatables.net/searchbuilder/1.0.1/js/dataTables.searchBuilder.min.js"
                JS      = "$PSScriptRoot\Resources\JS\dataTables.searchBuilder.min.js"
                CssLink = 'https://nightly.datatables.net/searchbuilder/css/searchBuilder.dataTables.css' # 'https://cdn.datatables.net/searchbuilder/1.0.1/css/searchBuilder.dataTables.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\dataTables.searchBuilder.min.css"
            }
            Default = $true
            Email   = $false
        }
        #>
        DataTablesSearchFade        = @{
            Comment      = 'DataTables SearchFade'
            HeaderAlways = @{
                CssInline = @{
                    '.notMatched td' = @{
                        'opacity' = 0.2
                    }
                }
            }
            Header       = @{
                JsLink = "https://cdn.datatables.net/plug-ins/preview/searchFade/dataTables.searchFade.min.js"
                JS     = "$PSScriptRoot\Resources\JS\datatables.SearchFade.min.js"
            }
            Default      = $true
            Email        = $false
        }
        DataTablesSearchHighlight   = @{
            Comment = 'DataTables SearchHighlight'
            Header  = @{
                JsLinkOriginal = "https://cdn.datatables.net/plug-ins/1.10.24/features/searchHighlight/dataTables.searchHighlight.min.js", 'https://cdn.jsdelivr.net/gh/bartaz/sandbox.js@master/jquery.highlight.js'
                JsLink         = "https://cdn.datatables.net/plug-ins/1.10.24/features/searchHighlight/dataTables.searchHighlight.min.js", "$($Script:ConfigurationURL)/JS/dataTables.searchHighlightRequire.min.js"
                JS             = "$PSScriptRoot\Resources\JS\dataTables.searchHighlight.min.js", "$PSScriptRoot\Resources\JS\dataTables.searchHighlightRequire.js"
                CSSLink        = 'https://cdn.datatables.net/plug-ins/1.10.24/features/searchHighlight/dataTables.searchHighlight.css'
                CSS            = "$PSScriptRoot\Resources\CSS\dataTables.searchHighlight.css"
            }
            Default = $true
            Email   = $false
        }
        DataTablesSearchAlphabet    = @{
            Comment = 'DataTables AlphabetSearch'
            Header  = @{
                #JsLink  = "https://cdn.datatables.net/plug-ins/1.10.22/features/alphabetSearch/dataTables.alphabetSearch.min.js"
                JsLinkOriginal  = "https://cdn.jsdelivr.net/gh/PrzemyslawKlys/Plugins@master/features/alphabetSearch/dataTables.alphabetSearch.js"
                JsLink          = "$($Script:ConfigurationURL)/JS/dataTables.alphabetSearch.min.js"
                JS              = "$PSScriptRoot\Resources\JS\dataTables.alphabetSearch.min.js"
                #CSSLink = 'https://cdn.datatables.net/plug-ins/1.10.22/features/alphabetSearch/dataTables.alphabetSearch.css'
                CSSLinkOriginal = 'https://cdn.jsdelivr.net/gh/PrzemyslawKlys/Plugins@master/features/alphabetSearch/dataTables.alphabetSearch.css'
                CSSLink         = "$($Script:ConfigurationURL)/CSS/dataTables.alphabetSearch.min.css"
                CSS             = "$PSScriptRoot\Resources\CSS\dataTables.alphabetSearch.css"
            }
            Default = $true
            Email   = $false
        }
        DataTablesSearchPanes       = @{
            Comment      = 'DataTables Search Panes Features'
            Header       = @{
                JsLink  = @(
                    "https://cdn.datatables.net/searchpanes/1.2.2/js/dataTables.searchPanes.min.js"
                )
                Js      = @(
                    "$PSScriptRoot\Resources\JS\dataTables.searchPanes.min.js"
                )
                CssLink = @(
                    "https://cdn.datatables.net/searchpanes/1.2.2/css/searchPanes.dataTables.min.css"
                )
                Css     = @(
                    "$PSScriptRoot\Resources\CSS\dataTables.searchPanes.min.css"
                )
            }
            HeaderAlways = @{
                CssInline = [ordered] @{
                    ".dtsp-panesContainer" = [ordered]@{
                        'width' = 'unset !important'
                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        DataTablesSearchPanesButton = @{
            Comment      = 'DataTables Search Panes when using button feature'
            HeaderAlways = @{
                CssInline = @{
                    'div.dt-button-collection' = @{
                        'position'      = 'relative'
                        #'position'   = 'fixed'
                        #'width'      = '900px !important'
                        'width'         = 'auto !important'
                        'margin-top'    = '10px !important'
                        'margin-bottom' = '10px !important'
                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        DataTablesSelect            = @{
            Comment = 'DataTables Select'
            Header  = @{
                JsLink  = "https://cdn.datatables.net/select/1.3.1/js/dataTables.select.min.js"
                JS      = "$PSScriptRoot\Resources\JS\dataTables.select.min.js"
                CSSLink = 'https://cdn.datatables.net/select/1.3.1/css/select.dataTables.min.css'
                CSS     = "$PSScriptRoot\Resources\CSS\select.dataTables.min.css"
            }
            Default = $true
            Email   = $false
        }
        DataTablesSimplify          = @{
            Comment      = 'DataTables (not really) - Simplified'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\datatables.simplify.css"
            }
            Default      = $true
            Email        = $true
        }
        D3Mitch                     = @{
            Comment      = 'D3Mitch Feature'
            Header       = @{
                JsLink  = @(
                    #'https://cdn.jsdelivr.net/npm/d3-mitch-tree@1.0.5/lib/d3-mitch-tree.min.js'
                    'https://cdn.jsdelivr.net/gh/deltoss/d3-mitch-tree@1.0.2/dist/js/d3-mitch-tree.min.js'
                )
                CssLink = @(
                    'https://cdn.jsdelivr.net/gh/deltoss/d3-mitch-tree@1.0.2/dist/css/d3-mitch-tree.min.css'
                    'https://cdn.jsdelivr.net/gh/deltoss/d3-mitch-tree@1.0.2/dist/css/d3-mitch-tree-theme-default.min.css'
                )
            }
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\hierarchicalTree.css"
            }
            LicenseLink  = 'https://github.com/deltoss/d3-mitch-tree/blob/master/LICENSE'
            License      = 'MIT'
            SourceCodes  = 'https://github.com/deltoss/d3-mitch-tree'
            Default      = $true
            Email        = $false
        }
        FullCalendar                = @{
            Comment      = 'FullCalendar Basic'
            HeaderAlways = @{
                CssInline = @{
                    '.calendarFullCalendar' = @{
                        'flex-basis' = '100%'
                        'margin'     = '5px'
                    }
                }
                JsInLine  = "var calendarTracker = {};"
            }
            Header       = @{
                JSLink  = 'https://cdn.jsdelivr.net/npm/fullcalendar@5.5.1/main.min.js'
                CssLink = 'https://cdn.jsdelivr.net/npm/fullcalendar@5.5.1/main.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\fullCalendar.css"
                JS      = "$PSScriptRoot\Resources\JS\fullCalendar.js"
            }
            Default      = $true
            Email        = $false
            LicenseLink  = 'https://github.com/fullcalendar/fullcalendar/blob/master/LICENSE.txt'
            License      = 'MIT'
            SourceCodes  = 'https://github.com/fullcalendar/fullcalendar'
        }
        HideSection                 = [ordered] @{
            Comment      = 'Hide Section Code'
            Internal     = $true
            Header       = @{
                JSLink = "$($Script:ConfigurationURL)/JS/hideSection.min.js"
                JS     = "$PSScriptRoot\Resources\JS\hideSection.js"
            }
            HeaderAlways = [ordered] @{
                #JS        = "$PSScriptRoot\Resources\JS\hideSection.js"
                CssInline = [ordered] @{
                    '.sectionHide' = @{ # fixes problem with hiding section that are collapsing left/right
                        'width'     = 'auto'
                        'min-width' = '1.4rem'
                    }
                    '.sectionShow' = @{
                        'width' = '100%'
                    }
                }
            }
            Default      = $true
            Email        = $false
        }
        EscapeRegex                 = @{
            Comment      = 'Allows EscapeRegex for diagrams and table events'
            FooterAlways = @{
                JS = "$PSScriptRoot\Resources\JS\escapeRegex.js"
            }
            Default      = $true
            Email        = $false
        }
        FancyTree                   = @{
            HeaderAlways = @{
                CssInline = @{
                    '.fancyTree' = @{
                        'margin' = '5px'
                    }
                }
            }
            Header       = @{
                JSLink  = @(
                    'https://cdnjs.cloudflare.com/ajax/libs/jquery.fancytree/2.38.0/jquery.fancytree-all-deps.min.js'
                )
                CSSLink = @(
                    'https://cdn.jsdelivr.net/npm/jquery.fancytree@2.38/dist/skin-win8/ui.fancytree.min.css'
                )
            }
            Default      = $true
            Email        = $false
            LicenseLink  = 'https://github.com/mar10/fancytree/blob/master/LICENSE.txt'
            License      = 'MIT'
            SourceCodes  = 'https://github.com/mar10/fancytree'
        }
        Raphael                     = @{
            Comment     = 'Raphaël: Cross-browser vector graphics the easy way'
            Demos       = 'https://dmitrybaranovskiy.github.io/raphael/'
            Header      = @{
                JSLink = @(
                    'https://cdnjs.cloudflare.com/ajax/libs/raphael/2.3.0/raphael.min.js'
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\raphael.min.js"
                )
            }
            License     = 'MIT'
            LicenseLink = 'https://dmitrybaranovskiy.github.io/raphael/license.html'
            SourceCodes = 'https://github.com/DmitryBaranovskiy/raphael/'
            Default     = $true
            Email       = $false
        }
        JustGage                    = @{
            Comment     = 'Just Gage Library'
            Demos       = 'https://toorshia.github.io/justgage'
            Header      = @{
                JSLink = @(
                    'https://cdnjs.cloudflare.com/ajax/libs/justgage/1.4.1/justgage.min.js'
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\justgage.min.js"
                )
            }
            Default     = $true
            Email       = $false
            License     = 'MIT'
            LicenseLink = 'https://github.com/toorshia/justgage/blob/master/LICENSE'
            SourceCodes = 'https://github.com/toorshia/justgage'
        }
        <#
        JsTree                  = @{
            Header = @{
                JSLink = @(
                    'https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/jstree.min.js'
                )
                CSSLink = @(
                    'https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/themes/default/style.min.css'
                )
                JS = @(
                    "$PSScriptRoot\Resources\JS\stree.min.js"
                )
                CSS = @(
                    "$PSScriptRoot\Resources\CSS\style.min.css"
                )
            }
        }
        #>
        Moment                      = @{
            Comment     = 'Momment JS Library'
            Header      = @{
                JSLink = 'https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js'
                JS     = "$PSScriptRoot\Resources\JS\moment.min.js"
            }
            Library     = 'https://momentjs.com/'
            SourceCodes = 'https://github.com/moment/moment/'
            License     = 'MIT'
            LicenseLink = 'https://github.com/moment/moment/blob/develop/LICENSE'
            Default     = $true
            Email       = $false
        }

        Navigation                  = @{
            Comment      = 'Navigation'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\nav.css"
                Js  = "$PSScriptRoot\Resources\JS\nav.js"
            }
            Default      = $true
            Email        = $false
        }
        NavigationMenu              = @{
            Comment      = 'Navigation'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\jside-menu.css", "$PSScriptRoot\Resources\CSS\jside-skins.css"
            }
            FooterAlways = @{
                Js = "$PSScriptRoot\Resources\JS\jquery.jside.menu.js"
            }
            Default      = $true
            Email        = $false
        }
        NavigationMultilevel        = @{
            Comment      = 'Navigation Multilevel'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\jquery.multilevelpushmenu_grey.css"
            }
            Header       = @{
                CssLink = 'https://cdn.jsdelivr.net/gh/adgsm/multi-level-push-menu/jquery.multilevelpushmenu.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\jquery.multilevelpushmenu.min.css"
            }
            Footer       = @{
                Js     = "$PSScriptRoot\Resources\JS\jquery.multilevelpushmenu.min.js"
                JSLink = 'https://cdn.jsdelivr.net/gh/adgsm/multi-level-push-menu/jquery.multilevelpushmenu.min.js'
            }
            SourceCodes  = 'https://github.com/adgsm/multi-level-push-menu'
            LicenseLink  = 'https://opensource.org/licenses/mit-license.php'
            License      = 'MIT'
            Default      = $true
            Email        = $false
        }
        Popper                      = @{
            Comment      = 'Popper and Tooltip for FullCalendar'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\popper.css"
            }
            Header       = @{
                JSLink = @(
                    'https://unpkg.com/popper.js/dist/umd/popper.min.js'
                    'https://unpkg.com/tooltip.js/dist/umd/tooltip.min.js'
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\popper.min.js"
                    "$PSScriptRoot\Resources\JS\tooltip.min.js"
                )
            }
            SourceCodes  = 'https://github.com/popperjs/popper-core'
            LicenseLink  = 'https://github.com/popperjs/popper-core/blob/master/LICENSE.md'
            License      = 'MIT'
            Default      = $true
            Email        = $false
        }
        RedrawObjects               = @{
            Comment  = 'Allows redrawObjects for collapsed sections and changing tabs'
            Internal = $true
            Footer   = @{
                JSLink = "$($Script:ConfigurationURL)/JS/redrawObjects.min.js"
                JS     = "$PSScriptRoot\Resources\JS\redrawObjects.js"
            }
            <#
            FooterAlways = @{
                JS = "$PSScriptRoot\Resources\JS\redrawObjects.js"
            }
            #>
            Default  = $true
            Email    = $false
        }
        Tabbis                      = @{
            Comment      = 'Elastic Tabbis'
            Internal     = $true
            HeaderAlways = @{
                #Css       = "$PSScriptRoot\Resources\CSS\tabbis.css"
                CssInline = [ordered] @{
                    ".tabsWrapper"         = [ordered]@{
                        'text-align'     = 'center'
                        #'margin'         = "10px auto"
                        'font-family'    = "'Roboto', sans-serif !important"
                        'text-transform' = 'uppercase'
                        # 'font-size'      = '15px'
                    }
                    '[data-tabs]'          = [ordered]@{
                        'display'         = 'flex'
                        #'margin-top'      = '10px'
                        'margin'          = '5px 5px 5px 5px'
                        'padding'         = '0px'
                        'box-shadow'      = '0px 5px 20px rgba(0, 0, 0, 0.1)'
                        'border-radius'   = '5px'
                        'justify-content' = 'center'
                        'flex-wrap'       = 'wrap'
                    }
                    # https://css-tricks.com/snippets/css/a-guide-to-flexbox/
                    '[data-tabs]>*'        = [ordered]@{
                        'cursor'      = 'pointer'
                        'padding'     = '10px 20px'
                        'flex-grow'   = 1
                        'flex-shrink' = 1
                        'flex-basis'  = 'auto'
                    }
                    '[data-tabs] .active'  = [ordered]@{
                        'background'    = '#1e90ff' # DodgerBlue
                        'color'         = '#fff'
                        'border-radius' = '5px'
                    }
                    '[data-panes]>*'       = [ordered]@{
                        'display' = 'none'
                    }
                    '[data-panes]>.active' = [ordered]@{
                        'display' = 'block'
                    }
                }
            }
            <#
            FooterAlways = @{
                JS = @(
                    "$PSScriptRoot\Resources\JS\tabbis.js"
                    "$PSScriptRoot\Resources\JS\tabbisAdditional.js"
                )
            }
            #>
            Footer       = @{
                JSLink = @(
                    "$($Script:ConfigurationURL)/JS/tabbis.min.js"
                    "$($Script:ConfigurationURL)/JS/tabbisAdditional.min.js"
                )
                JS     = @(
                    "$PSScriptRoot\Resources\JS\tabbis.js"
                    "$PSScriptRoot\Resources\JS\tabbisAdditional.js"
                )
            }
            Default      = $true
            Email        = $false
        }
        TabsInline                  = @{
            # http://techlaboratory.net/jquery-smarttab
            Comment     = 'Tabs Inline'
            Header      = @{
                JsLink  = 'https://cdn.jsdelivr.net/npm/jquery-smarttab@3/dist/js/jquery.smartTab.min.js'
                Js      = "$PSScriptRoot\Resources\JS\jquery.smartTab.min.js"
                CssLink = "https://cdn.jsdelivr.net/npm/jquery-smarttab@3/dist/css/smart_tab_all.min.css"
                Css     = "$PSScriptRoot\Resources\CSS\jquery.smartTab.min.css"
            }
            SourceCodes = 'https://github.com/techlab/jquery-smarttab'
            LicenseLink = 'https://github.com/techlab/jquery-smarttab/blob/master/LICENSE'
            License     = 'MIT'
            Default     = $true
            Email       = $false
        }
        TimeLine                    = @{
            Comment      = 'Timeline Simple'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\timeline-simple.css"
            }
            Default      = $true
            Email        = $false
        }
        Toasts                      = @{
            Comment      = 'Toasts Looking Messages'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\Toasts.css"
            }
            Default      = $true
            Email        = $false
        }
        StatusButtonical            = @{
            Comment      = 'Status Buttonical'
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\status.css"
            }
            Default      = $true
            Email        = $false
        }
        VisData                     = [ordered]@{
            Header  = @{
                # https://unpkg.com/vis-data@latest/peer/umd/vis-data.min.js
                JsLink = 'https://cdn.jsdelivr.net/npm/vis-data@7.1.2/peer/umd/vis-data.min.js'
                Js     = "$PSScriptRoot\Resources\JS\vis-data.min.js"
            }
            Default = $true
            Email   = $false
        }
        VisNetwork                  = [ordered]@{
            Comment      = 'VIS Network Dynamic, browser based visualization libraries'
            Demos        = @(
                'https://visjs.github.io/vis-network/examples/'
            )
            HeaderAlways = @{
                CssInline = [ordered]@{
                    '.diagram'           = [ordered]@{
                        'min-height' = '400px'
                        'width'      = '100%'
                        'height'     = '100%'
                        'border'     = '0px solid unset'
                    }
                    '.vis-network:focus' = [ordered]@{
                        'outline' = 'none'
                    }
                }
                JsInLine  = "var diagramTracker = {};"
            }
            Header       = @{
                # https://unpkg.com/vis-network@latest/peer/umd/vis-network.min.js
                # https://unpkg.com/vis-network/styles/vis-network.min.css
                JsLink  = 'https://cdn.jsdelivr.net/npm/vis-network@9.0.4/peer/umd/vis-network.min.js'
                Js      = "$PSScriptRoot\Resources\JS\vis-network.min.js"
                CssLink = 'https://cdn.jsdelivr.net/npm/vis-network@9.0.4/styles/vis-network.min.css'
                Css     = "$PSScriptRoot\Resources\CSS\vis-network.min.css"
            }
            Default      = $true
            Email        = $false
            License      = 'Apache 2.0'
            LicenseLink  = 'https://github.com/visjs/vis-network/blob/master/LICENSE-APACHE-2.0'
            SourceCodes  = 'https://github.com/visjs'
        }
        VisNetworkClustering        = [ordered] @{
            Comment  = 'VIS Network Clustering'
            Internal = $true
            <#
            FooterAlways = @{
                JS = "$PSScriptRoot\Resources\JS\vis-networkFunctions.js"
            }
            #>
            Footer   = @{
                JSLink = "$($Script:ConfigurationURL)/JS/vis-networkFunctions.min.js"
                JS     = "$PSScriptRoot\Resources\JS\vis-networkFunctions.js"
            }
            Default  = $true
            Email    = $false
        }
        VisNetworkLoadingBar        = [ordered]@{
            Comment = 'VIS Network Loading Bar'
            <#
            HeaderAlways = @{
                Css = "$PSScriptRoot\Resources\CSS\vis-network.loadingbar.css"
            }
            #>
            Header  = @{
                CssLink = "$($Script:ConfigurationURL)/CSS/vis-network.loadingbar.min.css"
                Css     = "$PSScriptRoot\Resources\CSS\vis-network.loadingbar.css"
            }
            Default = $true
            Email   = $false
        }
        VisNetworkLoad              = [ordered] @{
            Comment = 'VIS Network Load'
            <#
            HeaderAlways = @{
                JS = "$PSScriptRoot\Resources\JS\vis-networkLoadDiagram.js"
            }
            #>
            Header  = @{
                JSLink = "$($Script:ConfigurationURL)/JS/vis-networkLoadDiagram.min.js"
                JS     = "$PSScriptRoot\Resources\JS\vis-networkLoadDiagram.js"
            }
            Default = $true
            Email   = $false
        }
        <#
        VisNetworkStandalone   = [ordered]@{
            Comment      = 'VIS Network Standalone Dynamic, browser based visualization libraries'
            HeaderAlways = @{
                CssInline = [ordered]@{
                    '.diagram'           = [ordered]@{
                        'min-height' = '400px'
                        'width'      = '100%'
                        'height'     = '100%'
                        'border'     = '0px solid unset'
                    }
                    '.vis-network:focus' = [ordered]@{
                        'outline' = 'none'
                    }
                }
            }
            Header       = @{
                JsLink = 'https://unpkg.com/vis-network@8.4.1/standalone/umd/vis-network.min.js'
                Js     = "$PSScriptRoot\Resources\JS\vis-networkStandalone.min.js"
            }
            FooterAlways = @{
                JS = "$PSScriptRoot\Resources\JS\vis-networkFunctions.js"
            }
        }
        #>
        VisTimeline                 = [ordered]@{
            Comment      = 'VIS TimeLine'
            HeaderAlways = [ordered]@{
                CssInline = [ordered] @{
                    '.vis-timeline' = @{
                        'outline' = 'none'
                        'border'  = 'none !important'
                    }
                }
            }
            Header       = @{
                # https://unpkg.com/vis-timeline@latest/peer/umd/vis-timeline-graph2d.min.js
                JsLink  = 'https://cdn.jsdelivr.net/npm/vis-timeline@7.4.6/peer/umd/vis-timeline-graph2d.min.js'
                Js      = "$PSScriptRoot\Resources\JS\vis-timeline-graph2d.min.js"
                Css     = "$PSScriptRoot\Resources\CSS\vis-timeline-graph2d.min.css"
                CssLink = 'https://cdn.jsdelivr.net/npm/vis-timeline@7.4.6/styles/vis-timeline-graph2d.min.css'
            }
            LicenseLink  = 'https://github.com/visjs/vis-timeline/blob/master/LICENSE.md'
            License      = 'MIT and Apache 2.0'
            SourceCodes  = 'https://github.com/visjs/vis-timeline'
            Default      = $true
            Email        = $false
        }
        QR                          = [ordered] @{
            Comment      = 'QR Code'
            Demos        = 'https://www.easyproject.cn/easyqrcodejs/tryit.html'
            HeaderAlways = @{
                CssInline = @{
                    '.qrcode' = [ordered] @{
                        'margin' = '5px'
                    }
                }
            }
            Header       = @{
                JSLink = 'https://cdn.jsdelivr.net/npm/easyqrcodejs@4.3.2/dist/easy.qrcode.min.js'
                Js     = "$PSScriptRoot\Resources\JS\easy.qrcode.min.js"
            }
            Default      = $true
            Email        = $false
            LicenseLink  = 'https://github.com/ushelp/EasyQRCodeJS/blob/master/LICENSE'
            License      = 'MIT'
            SourceCodes  = 'https://github.com/ushelp/EasyQRCodeJS'
        }
        Wizard                      = [ordered] @{
            Comment      = 'Wizard'
            Demos        = 'http://techlaboratory.net/jquery-smartwizard'
            Header       = @{
                JsLink  = 'https://cdn.jsdelivr.net/npm/smartwizard@5.1.1/dist/js/jquery.smartWizard.min.js'
                Js      = "$PSScriptRoot\Resources\JS\jquery.smartWizard.min.js"
                CssLink = "https://cdn.jsdelivr.net/npm/smartwizard@5.1.1/dist/css/smart_wizard_all.min.css"
                Css     = "$PSScriptRoot\Resources\CSS\jquery.smartWizard.min.css"
            }
            HeaderAlways = @{
                CssInline = @{
                    '.defaultWizard' = [ordered] @{
                        'margin' = '5px'
                    }
                }
            }
            Default      = $true
            Email        = $false
            LicenseLink  = 'https://github.com/techlab/jquery-smartwizard/blob/master/LICENSE'
            License      = 'MIT'
            SourceCodes  = 'https://github.com/techlab/jquery-smartwizard'
        }
        JQueryMouseWheel            = @{
            Header      = @{
                JSLink = 'https://cdn.jsdelivr.net/npm/jquery-mousewheel@3.1.13/jquery.mousewheel.min.js'
                JS     = "$PSScriptRoot\Resources\JS\jquery.mousewheel.min.js"
            }
            SourceCodes = 'https://github.com/jquery/jquery-mousewheel'
            License     = 'MIT'
            LicenseLink = 'https://github.com/jquery/jquery-mousewheel/blob/master/LICENSE.txt'
            Default     = $true
            Email       = $false
        }
        Mapael                      = @{
            Comment     = 'Mapael JQuery'
            Header      = @{
                JSLink = 'https://cdn.jsdelivr.net/npm/jquery-mapael@2.2.0/js/jquery.mapael.min.js'
                JS     = "$PSScriptRoot\Resources\JS\jquery.mapael.min.js"
            }
            Library     = 'https://github.com/neveldo/jQuery-Mapael'
            SourceCodes = 'https://github.com/neveldo/jQuery-Mapael'
            License     = 'MIT'
            LicenseLink = 'https://github.com/neveldo/jQuery-Mapael/blob/master/LICENSE'
            Default     = $true
            Email       = $false
        }
        MapaelMaps_Poland           = @{
            Internal = $true
            Header   = @{
                JSLink = "$($Script:ConfigurationURL)/Maps/poland/poland.min.js"
                JS     = "$PSScriptRoot\Resources\Maps\poland\poland.js"
            }
            Default  = $true
            Email    = $false
        }
        MapaelMaps_usa_states       = @{
            Internal = $true
            Header   = @{
                JSLink = "$($Script:ConfigurationURL)/Maps/usa/usa_states.min.js"
                JS     = "$PSScriptRoot\Resources\Maps\usa\usa_states.js"
            }
            Default  = $true
            Email    = $false
        }
        MapaelMaps_world_countries  = @{
            Internal = $true
            Header   = @{
                JSLink = "$($Script:ConfigurationURL)/Maps/world/world_countries.min.js"
                JS     = "$PSScriptRoot\Resources\Maps\world\world_countries.js"
            }
            Default  = $true
            Email    = $false
        }
    }
}

<#
$Keys = @(
    #'Popper'
    #'Moment'
    #'Jquery'
    #'ChartsOrg', 'ChartsOrgExportPDF', 'ChartsOrgExportPNG'
    #'ChartsApex'
    #'AccordionFAQ'
    #'VisNetwork'
    #'VisTimeline'
    #'VisData'
    #'FullCalendar'
    #'DataTablesSearchAlphabet'
    #'DataTable*'
    #'FancyTree'
    #'JustGage'
    #'CarouselKineto'
    #'QR'
)

Save-HTMLResource -Configuration $Script:Configuration -Keys $Keys -PathToSave 'C:\Users\przemyslaw.klys\OneDrive - Evotec\Support\GitHub\PSWriteHTML\Resources' -Verbose
#>
# Another way to access
# https://use.fontawesome.com/releases/v5.11.2/svgs/brands/accessible-icon.svg
# https://github.com/FortAwesome/Font-Awesome/blob/master/UPGRADING.md

$Global:HTMLIcons = [ordered] @{
    FontAwesomeBrands  = [ordered] @{
        '500px'                          = 'f26e'
        'accessible-icon'                = 'f368'
        'accusoft'                       = 'f369'
        'acquisitions-incorporated'      = 'f6af'
        'adn'                            = 'f170'
        'adversal'                       = 'f36a'
        'affiliatetheme'                 = 'f36b'
        'airbnb'                         = 'f834'
        'algolia'                        = 'f36c'
        'alipay'                         = 'f642'
        'amazon'                         = 'f270'
        'amazon-pay'                     = 'f42c'
        'amilia'                         = 'f36d'
        'android'                        = 'f17b'
        'angellist'                      = 'f209'
        'angrycreative'                  = 'f36e'
        'angular'                        = 'f420'
        'app-store'                      = 'f36f'
        'app-store-ios'                  = 'f370'
        'apper'                          = 'f371'
        'apple'                          = 'f179'
        'apple-pay'                      = 'f415'
        'artstation'                     = 'f77a'
        'asymmetrik'                     = 'f372'
        'atlassian'                      = 'f77b'
        'audible'                        = 'f373'
        'autoprefixer'                   = 'f41c'
        'avianex'                        = 'f374'
        'aviato'                         = 'f421'
        'aws'                            = 'f375'
        'bandcamp'                       = 'f2d5'
        'battle-net'                     = 'f835'
        'behance'                        = 'f1b4'
        'behance-square'                 = 'f1b5'
        'bimobject'                      = 'f378'
        'bitbucket'                      = 'f171'
        'bitcoin'                        = 'f379'
        'bity'                           = 'f37a'
        'black-tie'                      = 'f27e'
        'blackberry'                     = 'f37b'
        'blogger'                        = 'f37c'
        'blogger-b'                      = 'f37d'
        'bluetooth'                      = 'f293'
        'bluetooth-b'                    = 'f294'
        'bootstrap'                      = 'f836'
        'btc'                            = 'f15a'
        'buffer'                         = 'f837'
        'buromobelexperte'               = 'f37f'
        'buy-n-large'                    = 'f8a6'
        'canadian-maple-leaf'            = 'f785'
        'cc-amazon-pay'                  = 'f42d'
        'cc-amex'                        = 'f1f3'
        'cc-apple-pay'                   = 'f416'
        'cc-diners-club'                 = 'f24c'
        'cc-discover'                    = 'f1f2'
        'cc-jcb'                         = 'f24b'
        'cc-mastercard'                  = 'f1f1'
        'cc-paypal'                      = 'f1f4'
        'cc-stripe'                      = 'f1f5'
        'cc-visa'                        = 'f1f0'
        'centercode'                     = 'f380'
        'centos'                         = 'f789'
        'chrome'                         = 'f268'
        'chromecast'                     = 'f838'
        'cloudscale'                     = 'f383'
        'cloudsmith'                     = 'f384'
        'cloudversify'                   = 'f385'
        'codepen'                        = 'f1cb'
        'codiepie'                       = 'f284'
        'confluence'                     = 'f78d'
        'connectdevelop'                 = 'f20e'
        'contao'                         = 'f26d'
        'cotton-bureau'                  = 'f89e'
        'cpanel'                         = 'f388'
        'creative-commons'               = 'f25e'
        'creative-commons-by'            = 'f4e7'
        'creative-commons-nc'            = 'f4e8'
        'creative-commons-nc-eu'         = 'f4e9'
        'creative-commons-nc-jp'         = 'f4ea'
        'creative-commons-nd'            = 'f4eb'
        'creative-commons-pd'            = 'f4ec'
        'creative-commons-pd-alt'        = 'f4ed'
        'creative-commons-remix'         = 'f4ee'
        'creative-commons-sa'            = 'f4ef'
        'creative-commons-sampling'      = 'f4f0'
        'creative-commons-sampling-plus' = 'f4f1'
        'creative-commons-share'         = 'f4f2'
        'creative-commons-zero'          = 'f4f3'
        'critical-role'                  = 'f6c9'
        'css3'                           = 'f13c'
        'css3-alt'                       = 'f38b'
        'cuttlefish'                     = 'f38c'
        'd-and-d'                        = 'f38d'
        'd-and-d-beyond'                 = 'f6ca'
        'dashcube'                       = 'f210'
        'delicious'                      = 'f1a5'
        'deploydog'                      = 'f38e'
        'deskpro'                        = 'f38f'
        'dev'                            = 'f6cc'
        'deviantart'                     = 'f1bd'
        'dhl'                            = 'f790'
        'diaspora'                       = 'f791'
        'digg'                           = 'f1a6'
        'digital-ocean'                  = 'f391'
        'discord'                        = 'f392'
        'discourse'                      = 'f393'
        'dochub'                         = 'f394'
        'docker'                         = 'f395'
        'draft2digital'                  = 'f396'
        'dribbble'                       = 'f17d'
        'dribbble-square'                = 'f397'
        'dropbox'                        = 'f16b'
        'drupal'                         = 'f1a9'
        'dyalog'                         = 'f399'
        'earlybirds'                     = 'f39a'
        'ebay'                           = 'f4f4'
        'edge'                           = 'f282'
        'elementor'                      = 'f430'
        'ello'                           = 'f5f1'
        'ember'                          = 'f423'
        'empire'                         = 'f1d1'
        'envira'                         = 'f299'
        'erlang'                         = 'f39d'
        'ethereum'                       = 'f42e'
        'etsy'                           = 'f2d7'
        'evernote'                       = 'f839'
        'expeditedssl'                   = 'f23e'
        'facebook'                       = 'f09a'
        'facebook-f'                     = 'f39e'
        'facebook-messenger'             = 'f39f'
        'facebook-square'                = 'f082'
        'fantasy-flight-games'           = 'f6dc'
        'fedex'                          = 'f797'
        'fedora'                         = 'f798'
        'figma'                          = 'f799'
        'firefox'                        = 'f269'
        'first-order'                    = 'f2b0'
        'first-order-alt'                = 'f50a'
        'firstdraft'                     = 'f3a1'
        'flickr'                         = 'f16e'
        'flipboard'                      = 'f44d'
        'fly'                            = 'f417'
        'font-awesome'                   = 'f2b4'
        'font-awesome-alt'               = 'f35c'
        'font-awesome-flag'              = 'f425'
        'fonticons'                      = 'f280'
        'fonticons-fi'                   = 'f3a2'
        'fort-awesome'                   = 'f286'
        'fort-awesome-alt'               = 'f3a3'
        'forumbee'                       = 'f211'
        'foursquare'                     = 'f180'
        'free-code-camp'                 = 'f2c5'
        'freebsd'                        = 'f3a4'
        'fulcrum'                        = 'f50b'
        'galactic-republic'              = 'f50c'
        'galactic-senate'                = 'f50d'
        'get-pocket'                     = 'f265'
        'gg'                             = 'f260'
        'gg-circle'                      = 'f261'
        'git'                            = 'f1d3'
        'git-alt'                        = 'f841'
        'git-square'                     = 'f1d2'
        'github'                         = 'f09b'
        'github-alt'                     = 'f113'
        'github-square'                  = 'f092'
        'gitkraken'                      = 'f3a6'
        'gitlab'                         = 'f296'
        'gitter'                         = 'f426'
        'glide'                          = 'f2a5'
        'glide-g'                        = 'f2a6'
        'gofore'                         = 'f3a7'
        'goodreads'                      = 'f3a8'
        'goodreads-g'                    = 'f3a9'
        'google'                         = 'f1a0'
        'google-drive'                   = 'f3aa'
        'google-play'                    = 'f3ab'
        'google-plus'                    = 'f2b3'
        'google-plus-g'                  = 'f0d5'
        'google-plus-square'             = 'f0d4'
        'google-wallet'                  = 'f1ee'
        'gratipay'                       = 'f184'
        'grav'                           = 'f2d6'
        'gripfire'                       = 'f3ac'
        'grunt'                          = 'f3ad'
        'gulp'                           = 'f3ae'
        'hacker-news'                    = 'f1d4'
        'hacker-news-square'             = 'f3af'
        'hackerrank'                     = 'f5f7'
        'hips'                           = 'f452'
        'hire-a-helper'                  = 'f3b0'
        'hooli'                          = 'f427'
        'hornbill'                       = 'f592'
        'hotjar'                         = 'f3b1'
        'houzz'                          = 'f27c'
        'html5'                          = 'f13b'
        'hubspot'                        = 'f3b2'
        'imdb'                           = 'f2d8'
        'instagram'                      = 'f16d'
        'intercom'                       = 'f7af'
        'internet-explorer'              = 'f26b'
        'invision'                       = 'f7b0'
        'ioxhost'                        = 'f208'
        'itch-io'                        = 'f83a'
        'itunes'                         = 'f3b4'
        'itunes-note'                    = 'f3b5'
        'java'                           = 'f4e4'
        'jedi-order'                     = 'f50e'
        'jenkins'                        = 'f3b6'
        'jira'                           = 'f7b1'
        'joget'                          = 'f3b7'
        'joomla'                         = 'f1aa'
        'js'                             = 'f3b8'
        'js-square'                      = 'f3b9'
        'jsfiddle'                       = 'f1cc'
        'kaggle'                         = 'f5fa'
        'keybase'                        = 'f4f5'
        'keycdn'                         = 'f3ba'
        'kickstarter'                    = 'f3bb'
        'kickstarter-k'                  = 'f3bc'
        'korvue'                         = 'f42f'
        'laravel'                        = 'f3bd'
        'lastfm'                         = 'f202'
        'lastfm-square'                  = 'f203'
        'leanpub'                        = 'f212'
        'less'                           = 'f41d'
        'line'                           = 'f3c0'
        'linkedin'                       = 'f08c'
        'linkedin-in'                    = 'f0e1'
        'linode'                         = 'f2b8'
        'linux'                          = 'f17c'
        'lyft'                           = 'f3c3'
        'magento'                        = 'f3c4'
        'mailchimp'                      = 'f59e'
        'mandalorian'                    = 'f50f'
        'markdown'                       = 'f60f'
        'mastodon'                       = 'f4f6'
        'maxcdn'                         = 'f136'
        'mdb'                            = 'f8ca'
        'medapps'                        = 'f3c6'
        'medium'                         = 'f23a'
        'medium-m'                       = 'f3c7'
        'medrt'                          = 'f3c8'
        'meetup'                         = 'f2e0'
        'megaport'                       = 'f5a3'
        'mendeley'                       = 'f7b3'
        'microsoft'                      = 'f3ca'
        'mix'                            = 'f3cb'
        'mixcloud'                       = 'f289'
        'mizuni'                         = 'f3cc'
        'modx'                           = 'f285'
        'monero'                         = 'f3d0'
        'napster'                        = 'f3d2'
        'neos'                           = 'f612'
        'nimblr'                         = 'f5a8'
        'node'                           = 'f419'
        'node-js'                        = 'f3d3'
        'npm'                            = 'f3d4'
        'ns8'                            = 'f3d5'
        'nutritionix'                    = 'f3d6'
        'odnoklassniki'                  = 'f263'
        'odnoklassniki-square'           = 'f264'
        'old-republic'                   = 'f510'
        'opencart'                       = 'f23d'
        'openid'                         = 'f19b'
        'opera'                          = 'f26a'
        'optin-monster'                  = 'f23c'
        'orcid'                          = 'f8d2'
        'osi'                            = 'f41a'
        'page4'                          = 'f3d7'
        'pagelines'                      = 'f18c'
        'palfed'                         = 'f3d8'
        'patreon'                        = 'f3d9'
        'paypal'                         = 'f1ed'
        'penny-arcade'                   = 'f704'
        'periscope'                      = 'f3da'
        'phabricator'                    = 'f3db'
        'phoenix-framework'              = 'f3dc'
        'phoenix-squadron'               = 'f511'
        'php'                            = 'f457'
        'pied-piper'                     = 'f2ae'
        'pied-piper-alt'                 = 'f1a8'
        'pied-piper-hat'                 = 'f4e5'
        'pied-piper-pp'                  = 'f1a7'
        'pinterest'                      = 'f0d2'
        'pinterest-p'                    = 'f231'
        'pinterest-square'               = 'f0d3'
        'playstation'                    = 'f3df'
        'product-hunt'                   = 'f288'
        'pushed'                         = 'f3e1'
        'python'                         = 'f3e2'
        'qq'                             = 'f1d6'
        'quinscape'                      = 'f459'
        'quora'                          = 'f2c4'
        'r-project'                      = 'f4f7'
        'raspberry-pi'                   = 'f7bb'
        'ravelry'                        = 'f2d9'
        'react'                          = 'f41b'
        'reacteurope'                    = 'f75d'
        'readme'                         = 'f4d5'
        'rebel'                          = 'f1d0'
        'red-river'                      = 'f3e3'
        'reddit'                         = 'f1a1'
        'reddit-alien'                   = 'f281'
        'reddit-square'                  = 'f1a2'
        'redhat'                         = 'f7bc'
        'renren'                         = 'f18b'
        'replyd'                         = 'f3e6'
        'researchgate'                   = 'f4f8'
        'resolving'                      = 'f3e7'
        'rev'                            = 'f5b2'
        'rocketchat'                     = 'f3e8'
        'rockrms'                        = 'f3e9'
        'safari'                         = 'f267'
        'salesforce'                     = 'f83b'
        'sass'                           = 'f41e'
        'schlix'                         = 'f3ea'
        'scribd'                         = 'f28a'
        'searchengin'                    = 'f3eb'
        'sellcast'                       = 'f2da'
        'sellsy'                         = 'f213'
        'servicestack'                   = 'f3ec'
        'shirtsinbulk'                   = 'f214'
        'shopware'                       = 'f5b5'
        'simplybuilt'                    = 'f215'
        'sistrix'                        = 'f3ee'
        'sith'                           = 'f512'
        'sketch'                         = 'f7c6'
        'skyatlas'                       = 'f216'
        'skype'                          = 'f17e'
        'slack'                          = 'f198'
        'slack-hash'                     = 'f3ef'
        'slideshare'                     = 'f1e7'
        'snapchat'                       = 'f2ab'
        'snapchat-ghost'                 = 'f2ac'
        'snapchat-square'                = 'f2ad'
        'soundcloud'                     = 'f1be'
        'sourcetree'                     = 'f7d3'
        'speakap'                        = 'f3f3'
        'speaker-deck'                   = 'f83c'
        'spotify'                        = 'f1bc'
        'squarespace'                    = 'f5be'
        'stack-exchange'                 = 'f18d'
        'stack-overflow'                 = 'f16c'
        'stackpath'                      = 'f842'
        'staylinked'                     = 'f3f5'
        'steam'                          = 'f1b6'
        'steam-square'                   = 'f1b7'
        'steam-symbol'                   = 'f3f6'
        'sticker-mule'                   = 'f3f7'
        'strava'                         = 'f428'
        'stripe'                         = 'f429'
        'stripe-s'                       = 'f42a'
        'studiovinari'                   = 'f3f8'
        'stumbleupon'                    = 'f1a4'
        'stumbleupon-circle'             = 'f1a3'
        'superpowers'                    = 'f2dd'
        'supple'                         = 'f3f9'
        'suse'                           = 'f7d6'
        'swift'                          = 'f8e1'
        'symfony'                        = 'f83d'
        'teamspeak'                      = 'f4f9'
        'telegram'                       = 'f2c6'
        'telegram-plane'                 = 'f3fe'
        'tencent-weibo'                  = 'f1d5'
        'the-red-yeti'                   = 'f69d'
        'themeco'                        = 'f5c6'
        'themeisle'                      = 'f2b2'
        'think-peaks'                    = 'f731'
        'trade-federation'               = 'f513'
        'trello'                         = 'f181'
        'tripadvisor'                    = 'f262'
        'tumblr'                         = 'f173'
        'tumblr-square'                  = 'f174'
        'twitch'                         = 'f1e8'
        'twitter'                        = 'f099'
        'twitter-square'                 = 'f081'
        'typo3'                          = 'f42b'
        'uber'                           = 'f402'
        'ubuntu'                         = 'f7df'
        'uikit'                          = 'f403'
        'umbraco'                        = 'f8e8'
        'uniregistry'                    = 'f404'
        'untappd'                        = 'f405'
        'ups'                            = 'f7e0'
        'usb'                            = 'f287'
        'usps'                           = 'f7e1'
        'ussunnah'                       = 'f407'
        'vaadin'                         = 'f408'
        'viacoin'                        = 'f237'
        'viadeo'                         = 'f2a9'
        'viadeo-square'                  = 'f2aa'
        'viber'                          = 'f409'
        'vimeo'                          = 'f40a'
        'vimeo-square'                   = 'f194'
        'vimeo-v'                        = 'f27d'
        'vine'                           = 'f1ca'
        'vk'                             = 'f189'
        'vnv'                            = 'f40b'
        'vuejs'                          = 'f41f'
        'waze'                           = 'f83f'
        'weebly'                         = 'f5cc'
        'weibo'                          = 'f18a'
        'weixin'                         = 'f1d7'
        'whatsapp'                       = 'f232'
        'whatsapp-square'                = 'f40c'
        'whmcs'                          = 'f40d'
        'wikipedia-w'                    = 'f266'
        'windows'                        = 'f17a'
        'wix'                            = 'f5cf'
        'wizards-of-the-coast'           = 'f730'
        'wolf-pack-battalion'            = 'f514'
        'wordpress'                      = 'f19a'
        'wordpress-simple'               = 'f411'
        'wpbeginner'                     = 'f297'
        'wpexplorer'                     = 'f2de'
        'wpforms'                        = 'f298'
        'wpressr'                        = 'f3e4'
        'xbox'                           = 'f412'
        'xing'                           = 'f168'
        'xing-square'                    = 'f169'
        'y-combinator'                   = 'f23b'
        'yahoo'                          = 'f19e'
        'yammer'                         = 'f840'
        'yandex'                         = 'f413'
        'yandex-international'           = 'f414'
        'yarn'                           = 'f7e3'
        'yelp'                           = 'f1e9'
        'yoast'                          = 'f2b1'
        'youtube'                        = 'f167'
        'youtube-square'                 = 'f431'
        'zhihu'                          = 'f63f'
    }
    FontAwesomeRegular = [ordered] @{
        'address-book'           = 'f2b9'
        'address-card'           = 'f2bb'
        'angry'                  = 'f556'
        'arrow-alt-circle-down'  = 'f358'
        'arrow-alt-circle-left'  = 'f359'
        'arrow-alt-circle-right' = 'f35a'
        'arrow-alt-circle-up'    = 'f35b'
        'bell'                   = 'f0f3'
        'bell-slash'             = 'f1f6'
        'bookmark'               = 'f02e'
        'building'               = 'f1ad'
        'calendar'               = 'f133'
        'calendar-alt'           = 'f073'
        'calendar-check'         = 'f274'
        'calendar-minus'         = 'f272'
        'calendar-plus'          = 'f271'
        'calendar-times'         = 'f273'
        'caret-square-down'      = 'f150'
        'caret-square-left'      = 'f191'
        'caret-square-right'     = 'f152'
        'caret-square-up'        = 'f151'
        'chart-bar'              = 'f080'
        'check-circle'           = 'f058'
        'check-square'           = 'f14a'
        'circle'                 = 'f111'
        'clipboard'              = 'f328'
        'clock'                  = 'f017'
        'clone'                  = 'f24d'
        'closed-captioning'      = 'f20a'
        'comment'                = 'f075'
        'comment-alt'            = 'f27a'
        'comment-dots'           = 'f4ad'
        'comments'               = 'f086'
        'compass'                = 'f14e'
        'copy'                   = 'f0c5'
        'copyright'              = 'f1f9'
        'credit-card'            = 'f09d'
        'dizzy'                  = 'f567'
        'dot-circle'             = 'f192'
        'edit'                   = 'f044'
        'envelope'               = 'f0e0'
        'envelope-open'          = 'f2b6'
        'eye'                    = 'f06e'
        'eye-slash'              = 'f070'
        'file'                   = 'f15b'
        'file-alt'               = 'f15c'
        'file-archive'           = 'f1c6'
        'file-audio'             = 'f1c7'
        'file-code'              = 'f1c9'
        'file-excel'             = 'f1c3'
        'file-image'             = 'f1c5'
        'file-pdf'               = 'f1c1'
        'file-powerpoint'        = 'f1c4'
        'file-video'             = 'f1c8'
        'file-word'              = 'f1c2'
        'flag'                   = 'f024'
        'flushed'                = 'f579'
        'folder'                 = 'f07b'
        'folder-open'            = 'f07c'
        'frown'                  = 'f119'
        'frown-open'             = 'f57a'
        'futbol'                 = 'f1e3'
        'gem'                    = 'f3a5'
        'grimace'                = 'f57f'
        'grin'                   = 'f580'
        'grin-alt'               = 'f581'
        'grin-beam'              = 'f582'
        'grin-beam-sweat'        = 'f583'
        'grin-hearts'            = 'f584'
        'grin-squint'            = 'f585'
        'grin-squint-tears'      = 'f586'
        'grin-stars'             = 'f587'
        'grin-tears'             = 'f588'
        'grin-tongue'            = 'f589'
        'grin-tongue-squint'     = 'f58a'
        'grin-tongue-wink'       = 'f58b'
        'grin-wink'              = 'f58c'
        'hand-lizard'            = 'f258'
        'hand-paper'             = 'f256'
        'hand-peace'             = 'f25b'
        'hand-point-down'        = 'f0a7'
        'hand-point-left'        = 'f0a5'
        'hand-point-right'       = 'f0a4'
        'hand-point-up'          = 'f0a6'
        'hand-pointer'           = 'f25a'
        'hand-rock'              = 'f255'
        'hand-scissors'          = 'f257'
        'hand-spock'             = 'f259'
        'handshake'              = 'f2b5'
        'hdd'                    = 'f0a0'
        'heart'                  = 'f004'
        'hospital'               = 'f0f8'
        'hourglass'              = 'f254'
        'id-badge'               = 'f2c1'
        'id-card'                = 'f2c2'
        'image'                  = 'f03e'
        'images'                 = 'f302'
        'keyboard'               = 'f11c'
        'kiss'                   = 'f596'
        'kiss-beam'              = 'f597'
        'kiss-wink-heart'        = 'f598'
        'laugh'                  = 'f599'
        'laugh-beam'             = 'f59a'
        'laugh-squint'           = 'f59b'
        'laugh-wink'             = 'f59c'
        'lemon'                  = 'f094'
        'life-ring'              = 'f1cd'
        'lightbulb'              = 'f0eb'
        'list-alt'               = 'f022'
        'map'                    = 'f279'
        'meh'                    = 'f11a'
        'meh-blank'              = 'f5a4'
        'meh-rolling-eyes'       = 'f5a5'
        'minus-square'           = 'f146'
        'money-bill-alt'         = 'f3d1'
        'moon'                   = 'f186'
        'newspaper'              = 'f1ea'
        'object-group'           = 'f247'
        'object-ungroup'         = 'f248'
        'paper-plane'            = 'f1d8'
        'pause-circle'           = 'f28b'
        'play-circle'            = 'f144'
        'plus-square'            = 'f0fe'
        'question-circle'        = 'f059'
        'registered'             = 'f25d'
        'sad-cry'                = 'f5b3'
        'sad-tear'               = 'f5b4'
        'save'                   = 'f0c7'
        'share-square'           = 'f14d'
        'smile'                  = 'f118'
        'smile-beam'             = 'f5b8'
        'smile-wink'             = 'f4da'
        'snowflake'              = 'f2dc'
        'square'                 = 'f0c8'
        'star'                   = 'f005'
        'star-half'              = 'f089'
        'sticky-note'            = 'f249'
        'stop-circle'            = 'f28d'
        'sun'                    = 'f185'
        'surprise'               = 'f5c2'
        'thumbs-down'            = 'f165'
        'thumbs-up'              = 'f164'
        'times-circle'           = 'f057'
        'tired'                  = 'f5c8'
        'trash-alt'              = 'f2ed'
        'user'                   = 'f007'
        'user-circle'            = 'f2bd'
        'window-close'           = 'f410'
        'window-maximize'        = 'f2d0'
        'window-minimize'        = 'f2d1'
        'window-restore'         = 'f2d2'
    }
    FontAwesomeSolid   = [ordered] @{
        'ad'                                  = 'f641'
        'address-book'                        = 'f2b9'
        'address-card'                        = 'f2bb'
        'adjust'                              = 'f042'
        'air-freshener'                       = 'f5d0'
        'align-center'                        = 'f037'
        'align-justify'                       = 'f039'
        'align-left'                          = 'f036'
        'align-right'                         = 'f038'
        'allergies'                           = 'f461'
        'ambulance'                           = 'f0f9'
        'american-sign-language-interpreting' = 'f2a3'
        'anchor'                              = 'f13d'
        'angle-double-down'                   = 'f103'
        'angle-double-left'                   = 'f100'
        'angle-double-right'                  = 'f101'
        'angle-double-up'                     = 'f102'
        'angle-down'                          = 'f107'
        'angle-left'                          = 'f104'
        'angle-right'                         = 'f105'
        'angle-up'                            = 'f106'
        'angry'                               = 'f556'
        'ankh'                                = 'f644'
        'apple-alt'                           = 'f5d1'
        'archive'                             = 'f187'
        'archway'                             = 'f557'
        'arrow-alt-circle-down'               = 'f358'
        'arrow-alt-circle-left'               = 'f359'
        'arrow-alt-circle-right'              = 'f35a'
        'arrow-alt-circle-up'                 = 'f35b'
        'arrow-circle-down'                   = 'f0ab'
        'arrow-circle-left'                   = 'f0a8'
        'arrow-circle-right'                  = 'f0a9'
        'arrow-circle-up'                     = 'f0aa'
        'arrow-down'                          = 'f063'
        'arrow-left'                          = 'f060'
        'arrow-right'                         = 'f061'
        'arrow-up'                            = 'f062'
        'arrows-alt'                          = 'f0b2'
        'arrows-alt-h'                        = 'f337'
        'arrows-alt-v'                        = 'f338'
        'assistive-listening-systems'         = 'f2a2'
        'asterisk'                            = 'f069'
        'at'                                  = 'f1fa'
        'atlas'                               = 'f558'
        'atom'                                = 'f5d2'
        'audio-description'                   = 'f29e'
        'award'                               = 'f559'
        'baby'                                = 'f77c'
        'baby-carriage'                       = 'f77d'
        'backspace'                           = 'f55a'
        'backward'                            = 'f04a'
        'bacon'                               = 'f7e5'
        'balance-scale'                       = 'f24e'
        'balance-scale-left'                  = 'f515'
        'balance-scale-right'                 = 'f516'
        'ban'                                 = 'f05e'
        'band-aid'                            = 'f462'
        'barcode'                             = 'f02a'
        'bars'                                = 'f0c9'
        'baseball-ball'                       = 'f433'
        'basketball-ball'                     = 'f434'
        'bath'                                = 'f2cd'
        'battery-empty'                       = 'f244'
        'battery-full'                        = 'f240'
        'battery-half'                        = 'f242'
        'battery-quarter'                     = 'f243'
        'battery-three-quarters'              = 'f241'
        'bed'                                 = 'f236'
        'beer'                                = 'f0fc'
        'bell'                                = 'f0f3'
        'bell-slash'                          = 'f1f6'
        'bezier-curve'                        = 'f55b'
        'bible'                               = 'f647'
        'bicycle'                             = 'f206'
        'biking'                              = 'f84a'
        'binoculars'                          = 'f1e5'
        'biohazard'                           = 'f780'
        'birthday-cake'                       = 'f1fd'
        'blender'                             = 'f517'
        'blender-phone'                       = 'f6b6'
        'blind'                               = 'f29d'
        'blog'                                = 'f781'
        'bold'                                = 'f032'
        'bolt'                                = 'f0e7'
        'bomb'                                = 'f1e2'
        'bone'                                = 'f5d7'
        'bong'                                = 'f55c'
        'book'                                = 'f02d'
        'book-dead'                           = 'f6b7'
        'book-medical'                        = 'f7e6'
        'book-open'                           = 'f518'
        'book-reader'                         = 'f5da'
        'bookmark'                            = 'f02e'
        'border-all'                          = 'f84c'
        'border-none'                         = 'f850'
        'border-style'                        = 'f853'
        'bowling-ball'                        = 'f436'
        'box'                                 = 'f466'
        'box-open'                            = 'f49e'
        'boxes'                               = 'f468'
        'braille'                             = 'f2a1'
        'brain'                               = 'f5dc'
        'bread-slice'                         = 'f7ec'
        'briefcase'                           = 'f0b1'
        'briefcase-medical'                   = 'f469'
        'broadcast-tower'                     = 'f519'
        'broom'                               = 'f51a'
        'brush'                               = 'f55d'
        'bug'                                 = 'f188'
        'building'                            = 'f1ad'
        'bullhorn'                            = 'f0a1'
        'bullseye'                            = 'f140'
        'burn'                                = 'f46a'
        'bus'                                 = 'f207'
        'bus-alt'                             = 'f55e'
        'business-time'                       = 'f64a'
        'calculator'                          = 'f1ec'
        'calendar'                            = 'f133'
        'calendar-alt'                        = 'f073'
        'calendar-check'                      = 'f274'
        'calendar-day'                        = 'f783'
        'calendar-minus'                      = 'f272'
        'calendar-plus'                       = 'f271'
        'calendar-times'                      = 'f273'
        'calendar-week'                       = 'f784'
        'camera'                              = 'f030'
        'camera-retro'                        = 'f083'
        'campground'                          = 'f6bb'
        'candy-cane'                          = 'f786'
        'cannabis'                            = 'f55f'
        'capsules'                            = 'f46b'
        'car'                                 = 'f1b9'
        'car-alt'                             = 'f5de'
        'car-battery'                         = 'f5df'
        'car-crash'                           = 'f5e1'
        'car-side'                            = 'f5e4'
        'caret-down'                          = 'f0d7'
        'caret-left'                          = 'f0d9'
        'caret-right'                         = 'f0da'
        'caret-square-down'                   = 'f150'
        'caret-square-left'                   = 'f191'
        'caret-square-right'                  = 'f152'
        'caret-square-up'                     = 'f151'
        'caret-up'                            = 'f0d8'
        'carrot'                              = 'f787'
        'cart-arrow-down'                     = 'f218'
        'cart-plus'                           = 'f217'
        'cash-register'                       = 'f788'
        'cat'                                 = 'f6be'
        'certificate'                         = 'f0a3'
        'chair'                               = 'f6c0'
        'chalkboard'                          = 'f51b'
        'chalkboard-teacher'                  = 'f51c'
        'charging-station'                    = 'f5e7'
        'chart-area'                          = 'f1fe'
        'chart-bar'                           = 'f080'
        'chart-line'                          = 'f201'
        'chart-pie'                           = 'f200'
        'check'                               = 'f00c'
        'check-circle'                        = 'f058'
        'check-double'                        = 'f560'
        'check-square'                        = 'f14a'
        'cheese'                              = 'f7ef'
        'chess'                               = 'f439'
        'chess-bishop'                        = 'f43a'
        'chess-board'                         = 'f43c'
        'chess-king'                          = 'f43f'
        'chess-knight'                        = 'f441'
        'chess-pawn'                          = 'f443'
        'chess-queen'                         = 'f445'
        'chess-rook'                          = 'f447'
        'chevron-circle-down'                 = 'f13a'
        'chevron-circle-left'                 = 'f137'
        'chevron-circle-right'                = 'f138'
        'chevron-circle-up'                   = 'f139'
        'chevron-down'                        = 'f078'
        'chevron-left'                        = 'f053'
        'chevron-right'                       = 'f054'
        'chevron-up'                          = 'f077'
        'child'                               = 'f1ae'
        'church'                              = 'f51d'
        'circle'                              = 'f111'
        'circle-notch'                        = 'f1ce'
        'city'                                = 'f64f'
        'clinic-medical'                      = 'f7f2'
        'clipboard'                           = 'f328'
        'clipboard-check'                     = 'f46c'
        'clipboard-list'                      = 'f46d'
        'clock'                               = 'f017'
        'clone'                               = 'f24d'
        'closed-captioning'                   = 'f20a'
        'cloud'                               = 'f0c2'
        'cloud-download-alt'                  = 'f381'
        'cloud-meatball'                      = 'f73b'
        'cloud-moon'                          = 'f6c3'
        'cloud-moon-rain'                     = 'f73c'
        'cloud-rain'                          = 'f73d'
        'cloud-showers-heavy'                 = 'f740'
        'cloud-sun'                           = 'f6c4'
        'cloud-sun-rain'                      = 'f743'
        'cloud-upload-alt'                    = 'f382'
        'cocktail'                            = 'f561'
        'code'                                = 'f121'
        'code-branch'                         = 'f126'
        'coffee'                              = 'f0f4'
        'cog'                                 = 'f013'
        'cogs'                                = 'f085'
        'coins'                               = 'f51e'
        'columns'                             = 'f0db'
        'comment'                             = 'f075'
        'comment-alt'                         = 'f27a'
        'comment-dollar'                      = 'f651'
        'comment-dots'                        = 'f4ad'
        'comment-medical'                     = 'f7f5'
        'comment-slash'                       = 'f4b3'
        'comments'                            = 'f086'
        'comments-dollar'                     = 'f653'
        'compact-disc'                        = 'f51f'
        'compass'                             = 'f14e'
        'compress'                            = 'f066'
        'compress-arrows-alt'                 = 'f78c'
        'concierge-bell'                      = 'f562'
        'cookie'                              = 'f563'
        'cookie-bite'                         = 'f564'
        'copy'                                = 'f0c5'
        'copyright'                           = 'f1f9'
        'couch'                               = 'f4b8'
        'credit-card'                         = 'f09d'
        'crop'                                = 'f125'
        'crop-alt'                            = 'f565'
        'cross'                               = 'f654'
        'crosshairs'                          = 'f05b'
        'crow'                                = 'f520'
        'crown'                               = 'f521'
        'crutch'                              = 'f7f7'
        'cube'                                = 'f1b2'
        'cubes'                               = 'f1b3'
        'cut'                                 = 'f0c4'
        'database'                            = 'f1c0'
        'deaf'                                = 'f2a4'
        'democrat'                            = 'f747'
        'desktop'                             = 'f108'
        'dharmachakra'                        = 'f655'
        'diagnoses'                           = 'f470'
        'dice'                                = 'f522'
        'dice-d20'                            = 'f6cf'
        'dice-d6'                             = 'f6d1'
        'dice-five'                           = 'f523'
        'dice-four'                           = 'f524'
        'dice-one'                            = 'f525'
        'dice-six'                            = 'f526'
        'dice-three'                          = 'f527'
        'dice-two'                            = 'f528'
        'digital-tachograph'                  = 'f566'
        'directions'                          = 'f5eb'
        'divide'                              = 'f529'
        'dizzy'                               = 'f567'
        'dna'                                 = 'f471'
        'dog'                                 = 'f6d3'
        'dollar-sign'                         = 'f155'
        'dolly'                               = 'f472'
        'dolly-flatbed'                       = 'f474'
        'donate'                              = 'f4b9'
        'door-closed'                         = 'f52a'
        'door-open'                           = 'f52b'
        'dot-circle'                          = 'f192'
        'dove'                                = 'f4ba'
        'download'                            = 'f019'
        'drafting-compass'                    = 'f568'
        'dragon'                              = 'f6d5'
        'draw-polygon'                        = 'f5ee'
        'drum'                                = 'f569'
        'drum-steelpan'                       = 'f56a'
        'drumstick-bite'                      = 'f6d7'
        'dumbbell'                            = 'f44b'
        'dumpster'                            = 'f793'
        'dumpster-fire'                       = 'f794'
        'dungeon'                             = 'f6d9'
        'edit'                                = 'f044'
        'egg'                                 = 'f7fb'
        'eject'                               = 'f052'
        'ellipsis-h'                          = 'f141'
        'ellipsis-v'                          = 'f142'
        'envelope'                            = 'f0e0'
        'envelope-open'                       = 'f2b6'
        'envelope-open-text'                  = 'f658'
        'envelope-square'                     = 'f199'
        'equals'                              = 'f52c'
        'eraser'                              = 'f12d'
        'ethernet'                            = 'f796'
        'euro-sign'                           = 'f153'
        'exchange-alt'                        = 'f362'
        'exclamation'                         = 'f12a'
        'exclamation-circle'                  = 'f06a'
        'exclamation-triangle'                = 'f071'
        'expand'                              = 'f065'
        'expand-arrows-alt'                   = 'f31e'
        'external-link-alt'                   = 'f35d'
        'external-link-square-alt'            = 'f360'
        'eye'                                 = 'f06e'
        'eye-dropper'                         = 'f1fb'
        'eye-slash'                           = 'f070'
        'fan'                                 = 'f863'
        'fast-backward'                       = 'f049'
        'fast-forward'                        = 'f050'
        'fax'                                 = 'f1ac'
        'feather'                             = 'f52d'
        'feather-alt'                         = 'f56b'
        'female'                              = 'f182'
        'fighter-jet'                         = 'f0fb'
        'file'                                = 'f15b'
        'file-alt'                            = 'f15c'
        'file-archive'                        = 'f1c6'
        'file-audio'                          = 'f1c7'
        'file-code'                           = 'f1c9'
        'file-contract'                       = 'f56c'
        'file-csv'                            = 'f6dd'
        'file-download'                       = 'f56d'
        'file-excel'                          = 'f1c3'
        'file-export'                         = 'f56e'
        'file-image'                          = 'f1c5'
        'file-import'                         = 'f56f'
        'file-invoice'                        = 'f570'
        'file-invoice-dollar'                 = 'f571'
        'file-medical'                        = 'f477'
        'file-medical-alt'                    = 'f478'
        'file-pdf'                            = 'f1c1'
        'file-powerpoint'                     = 'f1c4'
        'file-prescription'                   = 'f572'
        'file-signature'                      = 'f573'
        'file-upload'                         = 'f574'
        'file-video'                          = 'f1c8'
        'file-word'                           = 'f1c2'
        'fill'                                = 'f575'
        'fill-drip'                           = 'f576'
        'film'                                = 'f008'
        'filter'                              = 'f0b0'
        'fingerprint'                         = 'f577'
        'fire'                                = 'f06d'
        'fire-alt'                            = 'f7e4'
        'fire-extinguisher'                   = 'f134'
        'first-aid'                           = 'f479'
        'fish'                                = 'f578'
        'fist-raised'                         = 'f6de'
        'flag'                                = 'f024'
        'flag-checkered'                      = 'f11e'
        'flag-usa'                            = 'f74d'
        'flask'                               = 'f0c3'
        'flushed'                             = 'f579'
        'folder'                              = 'f07b'
        'folder-minus'                        = 'f65d'
        'folder-open'                         = 'f07c'
        'folder-plus'                         = 'f65e'
        'font'                                = 'f031'
        'football-ball'                       = 'f44e'
        'forward'                             = 'f04e'
        'frog'                                = 'f52e'
        'frown'                               = 'f119'
        'frown-open'                          = 'f57a'
        'funnel-dollar'                       = 'f662'
        'futbol'                              = 'f1e3'
        'gamepad'                             = 'f11b'
        'gas-pump'                            = 'f52f'
        'gavel'                               = 'f0e3'
        'gem'                                 = 'f3a5'
        'genderless'                          = 'f22d'
        'ghost'                               = 'f6e2'
        'gift'                                = 'f06b'
        'gifts'                               = 'f79c'
        'glass-cheers'                        = 'f79f'
        'glass-martini'                       = 'f000'
        'glass-martini-alt'                   = 'f57b'
        'glass-whiskey'                       = 'f7a0'
        'glasses'                             = 'f530'
        'globe'                               = 'f0ac'
        'globe-africa'                        = 'f57c'
        'globe-americas'                      = 'f57d'
        'globe-asia'                          = 'f57e'
        'globe-europe'                        = 'f7a2'
        'golf-ball'                           = 'f450'
        'gopuram'                             = 'f664'
        'graduation-cap'                      = 'f19d'
        'greater-than'                        = 'f531'
        'greater-than-equal'                  = 'f532'
        'grimace'                             = 'f57f'
        'grin'                                = 'f580'
        'grin-alt'                            = 'f581'
        'grin-beam'                           = 'f582'
        'grin-beam-sweat'                     = 'f583'
        'grin-hearts'                         = 'f584'
        'grin-squint'                         = 'f585'
        'grin-squint-tears'                   = 'f586'
        'grin-stars'                          = 'f587'
        'grin-tears'                          = 'f588'
        'grin-tongue'                         = 'f589'
        'grin-tongue-squint'                  = 'f58a'
        'grin-tongue-wink'                    = 'f58b'
        'grin-wink'                           = 'f58c'
        'grip-horizontal'                     = 'f58d'
        'grip-lines'                          = 'f7a4'
        'grip-lines-vertical'                 = 'f7a5'
        'grip-vertical'                       = 'f58e'
        'guitar'                              = 'f7a6'
        'h-square'                            = 'f0fd'
        'hamburger'                           = 'f805'
        'hammer'                              = 'f6e3'
        'hamsa'                               = 'f665'
        'hand-holding'                        = 'f4bd'
        'hand-holding-heart'                  = 'f4be'
        'hand-holding-usd'                    = 'f4c0'
        'hand-lizard'                         = 'f258'
        'hand-middle-finger'                  = 'f806'
        'hand-paper'                          = 'f256'
        'hand-peace'                          = 'f25b'
        'hand-point-down'                     = 'f0a7'
        'hand-point-left'                     = 'f0a5'
        'hand-point-right'                    = 'f0a4'
        'hand-point-up'                       = 'f0a6'
        'hand-pointer'                        = 'f25a'
        'hand-rock'                           = 'f255'
        'hand-scissors'                       = 'f257'
        'hand-spock'                          = 'f259'
        'hands'                               = 'f4c2'
        'hands-helping'                       = 'f4c4'
        'handshake'                           = 'f2b5'
        'hanukiah'                            = 'f6e6'
        'hard-hat'                            = 'f807'
        'hashtag'                             = 'f292'
        'hat-cowboy'                          = 'f8c0'
        'hat-cowboy-side'                     = 'f8c1'
        'hat-wizard'                          = 'f6e8'
        'haykal'                              = 'f666'
        'hdd'                                 = 'f0a0'
        'heading'                             = 'f1dc'
        'headphones'                          = 'f025'
        'headphones-alt'                      = 'f58f'
        'headset'                             = 'f590'
        'heart'                               = 'f004'
        'heart-broken'                        = 'f7a9'
        'heartbeat'                           = 'f21e'
        'helicopter'                          = 'f533'
        'highlighter'                         = 'f591'
        'hiking'                              = 'f6ec'
        'hippo'                               = 'f6ed'
        'history'                             = 'f1da'
        'hockey-puck'                         = 'f453'
        'holly-berry'                         = 'f7aa'
        'home'                                = 'f015'
        'horse'                               = 'f6f0'
        'horse-head'                          = 'f7ab'
        'hospital'                            = 'f0f8'
        'hospital-alt'                        = 'f47d'
        'hospital-symbol'                     = 'f47e'
        'hot-tub'                             = 'f593'
        'hotdog'                              = 'f80f'
        'hotel'                               = 'f594'
        'hourglass'                           = 'f254'
        'hourglass-end'                       = 'f253'
        'hourglass-half'                      = 'f252'
        'hourglass-start'                     = 'f251'
        'house-damage'                        = 'f6f1'
        'hryvnia'                             = 'f6f2'
        'i-cursor'                            = 'f246'
        'ice-cream'                           = 'f810'
        'icicles'                             = 'f7ad'
        'icons'                               = 'f86d'
        'id-badge'                            = 'f2c1'
        'id-card'                             = 'f2c2'
        'id-card-alt'                         = 'f47f'
        'igloo'                               = 'f7ae'
        'image'                               = 'f03e'
        'images'                              = 'f302'
        'inbox'                               = 'f01c'
        'indent'                              = 'f03c'
        'industry'                            = 'f275'
        'infinity'                            = 'f534'
        'info'                                = 'f129'
        'info-circle'                         = 'f05a'
        'italic'                              = 'f033'
        'jedi'                                = 'f669'
        'joint'                               = 'f595'
        'journal-whills'                      = 'f66a'
        'kaaba'                               = 'f66b'
        'key'                                 = 'f084'
        'keyboard'                            = 'f11c'
        'khanda'                              = 'f66d'
        'kiss'                                = 'f596'
        'kiss-beam'                           = 'f597'
        'kiss-wink-heart'                     = 'f598'
        'kiwi-bird'                           = 'f535'
        'landmark'                            = 'f66f'
        'language'                            = 'f1ab'
        'laptop'                              = 'f109'
        'laptop-code'                         = 'f5fc'
        'laptop-medical'                      = 'f812'
        'laugh'                               = 'f599'
        'laugh-beam'                          = 'f59a'
        'laugh-squint'                        = 'f59b'
        'laugh-wink'                          = 'f59c'
        'layer-group'                         = 'f5fd'
        'leaf'                                = 'f06c'
        'lemon'                               = 'f094'
        'less-than'                           = 'f536'
        'less-than-equal'                     = 'f537'
        'level-down-alt'                      = 'f3be'
        'level-up-alt'                        = 'f3bf'
        'life-ring'                           = 'f1cd'
        'lightbulb'                           = 'f0eb'
        'link'                                = 'f0c1'
        'lira-sign'                           = 'f195'
        'list'                                = 'f03a'
        'list-alt'                            = 'f022'
        'list-ol'                             = 'f0cb'
        'list-ul'                             = 'f0ca'
        'location-arrow'                      = 'f124'
        'lock'                                = 'f023'
        'lock-open'                           = 'f3c1'
        'long-arrow-alt-down'                 = 'f309'
        'long-arrow-alt-left'                 = 'f30a'
        'long-arrow-alt-right'                = 'f30b'
        'long-arrow-alt-up'                   = 'f30c'
        'low-vision'                          = 'f2a8'
        'luggage-cart'                        = 'f59d'
        'magic'                               = 'f0d0'
        'magnet'                              = 'f076'
        'mail-bulk'                           = 'f674'
        'male'                                = 'f183'
        'map'                                 = 'f279'
        'map-marked'                          = 'f59f'
        'map-marked-alt'                      = 'f5a0'
        'map-marker'                          = 'f041'
        'map-marker-alt'                      = 'f3c5'
        'map-pin'                             = 'f276'
        'map-signs'                           = 'f277'
        'marker'                              = 'f5a1'
        'mars'                                = 'f222'
        'mars-double'                         = 'f227'
        'mars-stroke'                         = 'f229'
        'mars-stroke-h'                       = 'f22b'
        'mars-stroke-v'                       = 'f22a'
        'mask'                                = 'f6fa'
        'medal'                               = 'f5a2'
        'medkit'                              = 'f0fa'
        'meh'                                 = 'f11a'
        'meh-blank'                           = 'f5a4'
        'meh-rolling-eyes'                    = 'f5a5'
        'memory'                              = 'f538'
        'menorah'                             = 'f676'
        'mercury'                             = 'f223'
        'meteor'                              = 'f753'
        'microchip'                           = 'f2db'
        'microphone'                          = 'f130'
        'microphone-alt'                      = 'f3c9'
        'microphone-alt-slash'                = 'f539'
        'microphone-slash'                    = 'f131'
        'microscope'                          = 'f610'
        'minus'                               = 'f068'
        'minus-circle'                        = 'f056'
        'minus-square'                        = 'f146'
        'mitten'                              = 'f7b5'
        'mobile'                              = 'f10b'
        'mobile-alt'                          = 'f3cd'
        'money-bill'                          = 'f0d6'
        'money-bill-alt'                      = 'f3d1'
        'money-bill-wave'                     = 'f53a'
        'money-bill-wave-alt'                 = 'f53b'
        'money-check'                         = 'f53c'
        'money-check-alt'                     = 'f53d'
        'monument'                            = 'f5a6'
        'moon'                                = 'f186'
        'mortar-pestle'                       = 'f5a7'
        'mosque'                              = 'f678'
        'motorcycle'                          = 'f21c'
        'mountain'                            = 'f6fc'
        'mouse'                               = 'f8cc'
        'mouse-pointer'                       = 'f245'
        'mug-hot'                             = 'f7b6'
        'music'                               = 'f001'
        'network-wired'                       = 'f6ff'
        'neuter'                              = 'f22c'
        'newspaper'                           = 'f1ea'
        'not-equal'                           = 'f53e'
        'notes-medical'                       = 'f481'
        'object-group'                        = 'f247'
        'object-ungroup'                      = 'f248'
        'oil-can'                             = 'f613'
        'om'                                  = 'f679'
        'otter'                               = 'f700'
        'outdent'                             = 'f03b'
        'pager'                               = 'f815'
        'paint-brush'                         = 'f1fc'
        'paint-roller'                        = 'f5aa'
        'palette'                             = 'f53f'
        'pallet'                              = 'f482'
        'paper-plane'                         = 'f1d8'
        'paperclip'                           = 'f0c6'
        'parachute-box'                       = 'f4cd'
        'paragraph'                           = 'f1dd'
        'parking'                             = 'f540'
        'passport'                            = 'f5ab'
        'pastafarianism'                      = 'f67b'
        'paste'                               = 'f0ea'
        'pause'                               = 'f04c'
        'pause-circle'                        = 'f28b'
        'paw'                                 = 'f1b0'
        'peace'                               = 'f67c'
        'pen'                                 = 'f304'
        'pen-alt'                             = 'f305'
        'pen-fancy'                           = 'f5ac'
        'pen-nib'                             = 'f5ad'
        'pen-square'                          = 'f14b'
        'pencil-alt'                          = 'f303'
        'pencil-ruler'                        = 'f5ae'
        'people-carry'                        = 'f4ce'
        'pepper-hot'                          = 'f816'
        'percent'                             = 'f295'
        'percentage'                          = 'f541'
        'person-booth'                        = 'f756'
        'phone'                               = 'f095'
        'phone-alt'                           = 'f879'
        'phone-slash'                         = 'f3dd'
        'phone-square'                        = 'f098'
        'phone-square-alt'                    = 'f87b'
        'phone-volume'                        = 'f2a0'
        'photo-video'                         = 'f87c'
        'piggy-bank'                          = 'f4d3'
        'pills'                               = 'f484'
        'pizza-slice'                         = 'f818'
        'place-of-worship'                    = 'f67f'
        'plane'                               = 'f072'
        'plane-arrival'                       = 'f5af'
        'plane-departure'                     = 'f5b0'
        'play'                                = 'f04b'
        'play-circle'                         = 'f144'
        'plug'                                = 'f1e6'
        'plus'                                = 'f067'
        'plus-circle'                         = 'f055'
        'plus-square'                         = 'f0fe'
        'podcast'                             = 'f2ce'
        'poll'                                = 'f681'
        'poll-h'                              = 'f682'
        'poo'                                 = 'f2fe'
        'poo-storm'                           = 'f75a'
        'poop'                                = 'f619'
        'portrait'                            = 'f3e0'
        'pound-sign'                          = 'f154'
        'power-off'                           = 'f011'
        'pray'                                = 'f683'
        'praying-hands'                       = 'f684'
        'prescription'                        = 'f5b1'
        'prescription-bottle'                 = 'f485'
        'prescription-bottle-alt'             = 'f486'
        'print'                               = 'f02f'
        'procedures'                          = 'f487'
        'project-diagram'                     = 'f542'
        'puzzle-piece'                        = 'f12e'
        'qrcode'                              = 'f029'
        'question'                            = 'f128'
        'question-circle'                     = 'f059'
        'quidditch'                           = 'f458'
        'quote-left'                          = 'f10d'
        'quote-right'                         = 'f10e'
        'quran'                               = 'f687'
        'radiation'                           = 'f7b9'
        'radiation-alt'                       = 'f7ba'
        'rainbow'                             = 'f75b'
        'random'                              = 'f074'
        'receipt'                             = 'f543'
        'record-vinyl'                        = 'f8d9'
        'recycle'                             = 'f1b8'
        'redo'                                = 'f01e'
        'redo-alt'                            = 'f2f9'
        'registered'                          = 'f25d'
        'remove-format'                       = 'f87d'
        'reply'                               = 'f3e5'
        'reply-all'                           = 'f122'
        'republican'                          = 'f75e'
        'restroom'                            = 'f7bd'
        'retweet'                             = 'f079'
        'ribbon'                              = 'f4d6'
        'ring'                                = 'f70b'
        'road'                                = 'f018'
        'robot'                               = 'f544'
        'rocket'                              = 'f135'
        'route'                               = 'f4d7'
        'rss'                                 = 'f09e'
        'rss-square'                          = 'f143'
        'ruble-sign'                          = 'f158'
        'ruler'                               = 'f545'
        'ruler-combined'                      = 'f546'
        'ruler-horizontal'                    = 'f547'
        'ruler-vertical'                      = 'f548'
        'running'                             = 'f70c'
        'rupee-sign'                          = 'f156'
        'sad-cry'                             = 'f5b3'
        'sad-tear'                            = 'f5b4'
        'satellite'                           = 'f7bf'
        'satellite-dish'                      = 'f7c0'
        'save'                                = 'f0c7'
        'school'                              = 'f549'
        'screwdriver'                         = 'f54a'
        'scroll'                              = 'f70e'
        'sd-card'                             = 'f7c2'
        'search'                              = 'f002'
        'search-dollar'                       = 'f688'
        'search-location'                     = 'f689'
        'search-minus'                        = 'f010'
        'search-plus'                         = 'f00e'
        'seedling'                            = 'f4d8'
        'server'                              = 'f233'
        'shapes'                              = 'f61f'
        'share'                               = 'f064'
        'share-alt'                           = 'f1e0'
        'share-alt-square'                    = 'f1e1'
        'share-square'                        = 'f14d'
        'shekel-sign'                         = 'f20b'
        'shield-alt'                          = 'f3ed'
        'ship'                                = 'f21a'
        'shipping-fast'                       = 'f48b'
        'shoe-prints'                         = 'f54b'
        'shopping-bag'                        = 'f290'
        'shopping-basket'                     = 'f291'
        'shopping-cart'                       = 'f07a'
        'shower'                              = 'f2cc'
        'shuttle-van'                         = 'f5b6'
        'sign'                                = 'f4d9'
        'sign-in-alt'                         = 'f2f6'
        'sign-language'                       = 'f2a7'
        'sign-out-alt'                        = 'f2f5'
        'signal'                              = 'f012'
        'signature'                           = 'f5b7'
        'sim-card'                            = 'f7c4'
        'sitemap'                             = 'f0e8'
        'skating'                             = 'f7c5'
        'skiing'                              = 'f7c9'
        'skiing-nordic'                       = 'f7ca'
        'skull'                               = 'f54c'
        'skull-crossbones'                    = 'f714'
        'slash'                               = 'f715'
        'sleigh'                              = 'f7cc'
        'sliders-h'                           = 'f1de'
        'smile'                               = 'f118'
        'smile-beam'                          = 'f5b8'
        'smile-wink'                          = 'f4da'
        'smog'                                = 'f75f'
        'smoking'                             = 'f48d'
        'smoking-ban'                         = 'f54d'
        'sms'                                 = 'f7cd'
        'snowboarding'                        = 'f7ce'
        'snowflake'                           = 'f2dc'
        'snowman'                             = 'f7d0'
        'snowplow'                            = 'f7d2'
        'socks'                               = 'f696'
        'solar-panel'                         = 'f5ba'
        'sort'                                = 'f0dc'
        'sort-alpha-down'                     = 'f15d'
        'sort-alpha-down-alt'                 = 'f881'
        'sort-alpha-up'                       = 'f15e'
        'sort-alpha-up-alt'                   = 'f882'
        'sort-amount-down'                    = 'f160'
        'sort-amount-down-alt'                = 'f884'
        'sort-amount-up'                      = 'f161'
        'sort-amount-up-alt'                  = 'f885'
        'sort-down'                           = 'f0dd'
        'sort-numeric-down'                   = 'f162'
        'sort-numeric-down-alt'               = 'f886'
        'sort-numeric-up'                     = 'f163'
        'sort-numeric-up-alt'                 = 'f887'
        'sort-up'                             = 'f0de'
        'spa'                                 = 'f5bb'
        'space-shuttle'                       = 'f197'
        'spell-check'                         = 'f891'
        'spider'                              = 'f717'
        'spinner'                             = 'f110'
        'splotch'                             = 'f5bc'
        'spray-can'                           = 'f5bd'
        'square'                              = 'f0c8'
        'square-full'                         = 'f45c'
        'square-root-alt'                     = 'f698'
        'stamp'                               = 'f5bf'
        'star'                                = 'f005'
        'star-and-crescent'                   = 'f699'
        'star-half'                           = 'f089'
        'star-half-alt'                       = 'f5c0'
        'star-of-david'                       = 'f69a'
        'star-of-life'                        = 'f621'
        'step-backward'                       = 'f048'
        'step-forward'                        = 'f051'
        'stethoscope'                         = 'f0f1'
        'sticky-note'                         = 'f249'
        'stop'                                = 'f04d'
        'stop-circle'                         = 'f28d'
        'stopwatch'                           = 'f2f2'
        'store'                               = 'f54e'
        'store-alt'                           = 'f54f'
        'stream'                              = 'f550'
        'street-view'                         = 'f21d'
        'strikethrough'                       = 'f0cc'
        'stroopwafel'                         = 'f551'
        'subscript'                           = 'f12c'
        'subway'                              = 'f239'
        'suitcase'                            = 'f0f2'
        'suitcase-rolling'                    = 'f5c1'
        'sun'                                 = 'f185'
        'superscript'                         = 'f12b'
        'surprise'                            = 'f5c2'
        'swatchbook'                          = 'f5c3'
        'swimmer'                             = 'f5c4'
        'swimming-pool'                       = 'f5c5'
        'synagogue'                           = 'f69b'
        'sync'                                = 'f021'
        'sync-alt'                            = 'f2f1'
        'syringe'                             = 'f48e'
        'table'                               = 'f0ce'
        'table-tennis'                        = 'f45d'
        'tablet'                              = 'f10a'
        'tablet-alt'                          = 'f3fa'
        'tablets'                             = 'f490'
        'tachometer-alt'                      = 'f3fd'
        'tag'                                 = 'f02b'
        'tags'                                = 'f02c'
        'tape'                                = 'f4db'
        'tasks'                               = 'f0ae'
        'taxi'                                = 'f1ba'
        'teeth'                               = 'f62e'
        'teeth-open'                          = 'f62f'
        'temperature-high'                    = 'f769'
        'temperature-low'                     = 'f76b'
        'tenge'                               = 'f7d7'
        'terminal'                            = 'f120'
        'text-height'                         = 'f034'
        'text-width'                          = 'f035'
        'th'                                  = 'f00a'
        'th-large'                            = 'f009'
        'th-list'                             = 'f00b'
        'theater-masks'                       = 'f630'
        'thermometer'                         = 'f491'
        'thermometer-empty'                   = 'f2cb'
        'thermometer-full'                    = 'f2c7'
        'thermometer-half'                    = 'f2c9'
        'thermometer-quarter'                 = 'f2ca'
        'thermometer-three-quarters'          = 'f2c8'
        'thumbs-down'                         = 'f165'
        'thumbs-up'                           = 'f164'
        'thumbtack'                           = 'f08d'
        'ticket-alt'                          = 'f3ff'
        'times'                               = 'f00d'
        'times-circle'                        = 'f057'
        'tint'                                = 'f043'
        'tint-slash'                          = 'f5c7'
        'tired'                               = 'f5c8'
        'toggle-off'                          = 'f204'
        'toggle-on'                           = 'f205'
        'toilet'                              = 'f7d8'
        'toilet-paper'                        = 'f71e'
        'toolbox'                             = 'f552'
        'tools'                               = 'f7d9'
        'tooth'                               = 'f5c9'
        'torah'                               = 'f6a0'
        'torii-gate'                          = 'f6a1'
        'tractor'                             = 'f722'
        'trademark'                           = 'f25c'
        'traffic-light'                       = 'f637'
        'train'                               = 'f238'
        'tram'                                = 'f7da'
        'transgender'                         = 'f224'
        'transgender-alt'                     = 'f225'
        'trash'                               = 'f1f8'
        'trash-alt'                           = 'f2ed'
        'trash-restore'                       = 'f829'
        'trash-restore-alt'                   = 'f82a'
        'tree'                                = 'f1bb'
        'trophy'                              = 'f091'
        'truck'                               = 'f0d1'
        'truck-loading'                       = 'f4de'
        'truck-monster'                       = 'f63b'
        'truck-moving'                        = 'f4df'
        'truck-pickup'                        = 'f63c'
        'tshirt'                              = 'f553'
        'tty'                                 = 'f1e4'
        'tv'                                  = 'f26c'
        'umbrella'                            = 'f0e9'
        'umbrella-beach'                      = 'f5ca'
        'underline'                           = 'f0cd'
        'undo'                                = 'f0e2'
        'undo-alt'                            = 'f2ea'
        'universal-access'                    = 'f29a'
        'university'                          = 'f19c'
        'unlink'                              = 'f127'
        'unlock'                              = 'f09c'
        'unlock-alt'                          = 'f13e'
        'upload'                              = 'f093'
        'user'                                = 'f007'
        'user-alt'                            = 'f406'
        'user-alt-slash'                      = 'f4fa'
        'user-astronaut'                      = 'f4fb'
        'user-check'                          = 'f4fc'
        'user-circle'                         = 'f2bd'
        'user-clock'                          = 'f4fd'
        'user-cog'                            = 'f4fe'
        'user-edit'                           = 'f4ff'
        'user-friends'                        = 'f500'
        'user-graduate'                       = 'f501'
        'user-injured'                        = 'f728'
        'user-lock'                           = 'f502'
        'user-md'                             = 'f0f0'
        'user-minus'                          = 'f503'
        'user-ninja'                          = 'f504'
        'user-nurse'                          = 'f82f'
        'user-plus'                           = 'f234'
        'user-secret'                         = 'f21b'
        'user-shield'                         = 'f505'
        'user-slash'                          = 'f506'
        'user-tag'                            = 'f507'
        'user-tie'                            = 'f508'
        'user-times'                          = 'f235'
        'users'                               = 'f0c0'
        'users-cog'                           = 'f509'
        'utensil-spoon'                       = 'f2e5'
        'utensils'                            = 'f2e7'
        'vector-square'                       = 'f5cb'
        'venus'                               = 'f221'
        'venus-double'                        = 'f226'
        'venus-mars'                          = 'f228'
        'vial'                                = 'f492'
        'vials'                               = 'f493'
        'video'                               = 'f03d'
        'video-slash'                         = 'f4e2'
        'vihara'                              = 'f6a7'
        'voicemail'                           = 'f897'
        'volleyball-ball'                     = 'f45f'
        'volume-down'                         = 'f027'
        'volume-mute'                         = 'f6a9'
        'volume-off'                          = 'f026'
        'volume-up'                           = 'f028'
        'vote-yea'                            = 'f772'
        'vr-cardboard'                        = 'f729'
        'walking'                             = 'f554'
        'wallet'                              = 'f555'
        'warehouse'                           = 'f494'
        'water'                               = 'f773'
        'wave-square'                         = 'f83e'
        'weight'                              = 'f496'
        'weight-hanging'                      = 'f5cd'
        'wheelchair'                          = 'f193'
        'wifi'                                = 'f1eb'
        'wind'                                = 'f72e'
        'window-close'                        = 'f410'
        'window-maximize'                     = 'f2d0'
        'window-minimize'                     = 'f2d1'
        'window-restore'                      = 'f2d2'
        'wine-bottle'                         = 'f72f'
        'wine-glass'                          = 'f4e3'
        'wine-glass-alt'                      = 'f5ce'
        'won-sign'                            = 'f159'
        'wrench'                              = 'f0ad'
        'x-ray'                               = 'f497'
        'yen-sign'                            = 'f157'
        'yin-yang'                            = 'f6ad'
    }
}
function Remove-ConfigurationCSS {
    [cmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Section')]
        [System.Collections.IDictionary] $CSS,

        [Parameter(ParameterSetName = 'Default')][string] $Name,

        [Parameter(ParameterSetName = 'Default')][string] $Property,

        [Parameter(ParameterSetName = 'Section')][string[]] $Section,

        [Parameter(ParameterSetName = 'Section')][switch] $Not
    )

    if ($CSS -and $Name -and $Property) {
        # remove single property
        if ($CSS[$Name]) {
            if ($Property) {
                if ($CSS[$Name][$Property]) {
                    $CSS[$Name].Remove($Property)
                }
            }
        }
    }
    if ($Section -and -not $Not) {
        # Remove requested sections
        foreach ($S in $Section) {
            if ($CSS[$S]) {
                $CSS.Remove($S)
            }
        }
    } elseif ($Section) {
        # Remove all sections not defined in requested Sections
        foreach ($S in [string[]] $CSS.Keys) {
            if ($S -notin $Section) {
                $CSS.Remove($S)
            }
        }
    }
}
function Remove-DotsFromCssClass {
    <#
    .SYNOPSIS
    Remove dot from .class

    .DESCRIPTION
    Long description

    .PARAMETER Css
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $Css
    )
    foreach ($Key in [string[]] $Css.Keys) {
        $Css[$Key] = $Css[$Key].TrimStart('.')
    }
}
function Rename-Dictionary {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $HashTable,
        [System.Collections.IDictionary[]] $Pair
    )
    foreach ($P in $Pair) {
        foreach ($Key in [string[]] $P.Keys) {
            $HashTable[$($P[$Key])] = $HashTable[$Key]
            $HashTable.Remove($Key)
        }
    }
}
<#
$ExistingDictionary = @{
    Test     = 'SomeValue'
    OtherKey = 'SomeOtherValue'
}

$ExpectedSheetsConfiguration = [ordered] @{
    Test     = "defaultSection-$(Get-RandomStringName -Size 7)"
    OtherKey = "defaultSectionText-$(Get-RandomStringName -Size 7)"
}


Rename-Dictionary -HashTable $ExistingDictionary -Pair $ExpectedSheetsConfiguration
#>
function Set-ConfigurationCSS {
    [cmdletBinding()]
    param(
        [string] $Feature,
        [string] $Type,
        [System.Collections.IDictionary] $CSS
    )
    $Script:CurrentConfiguration.Features.$Feature.$Type.CssInline = $CSS
}
function Set-Tag {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $HtmlObject,
        [switch] $NewLine # This is needed if code requires new lines such as JavaScript
    )
    $HTML = [System.Text.StringBuilder]::new()
    [void] $HTML.Append("<$($HtmlObject.Tag)")
    foreach ($Property in $HtmlObject.Attributes.Keys) {
        $PropertyValue = $HtmlObject.Attributes[$Property]
        # This checks if property has any subproperties  such as style having multiple options
        if ($PropertyValue -is [System.Collections.IDictionary]) {
            $OutputSubProperties = foreach ($SubAttributes in $PropertyValue.Keys) {
                $SubPropertyValue = $PropertyValue[$SubAttributes]
                # skip adding properties that are empty
                if ($null -ne $SubPropertyValue -and $SubPropertyValue -ne '') {
                    "$($SubAttributes):$($SubPropertyValue)"
                }
            }
            $MyValue = $OutputSubProperties -join ';'
            if ($MyValue.Trim() -ne '') {
                [void] $HTML.Append(" $Property=`"$MyValue`"")
            }
        } else {
            # skip adding properties that are empty
            if ($null -ne $PropertyValue -and $PropertyValue -ne '') {
                [void] $HTML.Append(" $Property=`"$PropertyValue`"")
            }
        }
    }
    if (($null -ne $HtmlObject.Value) -and ($HtmlObject.Value -ne '')) {
        [void] $HTML.Append(">")

        if ($HtmlObject.Value.Count -eq 1) {
            if ($HtmlObject.Value -is [System.Collections.IDictionary]) {
                [string] $NewObject = Set-Tag -HtmlObject ($HtmlObject.Value)
                [void] $HTML.Append($NewObject)
            } else {
                [void] $HTML.Append([string] $HtmlObject.Value)
            }
        } else {
            foreach ($Entry in $HtmlObject.Value) {
                if ($Entry -is [System.Collections.IDictionary]) {
                    [string] $NewObject = Set-Tag -HtmlObject ($Entry)
                    [void] $HTML.Append($NewObject)
                } else {
                    # This is needed if code requires new lines such as JavaScript
                    if ($NewLine) {
                        [void] $HTML.AppendLine([string] $Entry)
                    } else {
                        [void] $HTML.Append([string] $Entry)
                    }
                }
            }
        }
        [void] $HTML.Append("</$($HtmlObject.Tag)>")
    } else {
        if ($HtmlObject.SelfClosing) {
            [void] $HTML.Append("/>")
        } elseif ($HtmlObject.NoClosing) {
            [void] $HTML.Append(">")
        } else {
            [void] $HTML.Append("></$($HtmlObject.Tag)>")
        }
    }
    $HTML.ToString()
}
function Add-HTML {
    [alias('EmailHTML')]
    [CmdletBinding()]
    param(
        [ScriptBlock] $HTML
    )
    Invoke-Command -ScriptBlock $HTML
}
function Add-HTMLScript {
    [alias('Add-JavaScript', 'New-JavaScript', 'Add-JS')]
    [CmdletBinding()]
    param(
        [ValidateSet('Inline', 'Header', 'Footer')][string] $Placement = 'Header',
        [string] $ResourceComment,
        [string[]] $Link,
        [string[]] $Content,
        [string[]] $FilePath,
        [Parameter(DontShow)][System.Collections.IDictionary] $ReplaceData,
        [switch] $AddComments,
        [switch] $SkipTags
    )
    if (-not $ResourceComment) {
        $ResourceComment = "ResourceJS-$(Get-RandomStringName -Size 8 -LettersOnly)"
    }
    $Output = @(
        # Content from File(s)
        foreach ($File in $FilePath) {
            if ($File -ne '') {
                if (Test-Path -LiteralPath $File) {
                    # Replaces stuff based on $Script:CurrentConfiguration CustomActionReplace Entry
                    # Not really used anymore
                    $FileContent = Get-Content -LiteralPath $File -Raw
                    if ($null -ne $ReplaceData) {
                        foreach ($_ in $ReplaceData.Keys) {
                            $FileContent = $FileContent -replace $_, $ReplaceData[$_]
                        }
                    }
                    if ($SkipTags) {
                        $FileContent
                    } else {
                        New-HTMLTag -Tag 'script' -Attributes @{ type = 'text/javascript' } {
                            $FileContent
                        } -NewLine
                    }
                }
            }
        }
        # Content from string
        if ($Content) {
            if ($SkipTags) {
                $Content
            } else {
                New-HTMLTag -Tag 'script' -Attributes @{ type = 'text/javascript' } {
                    $Content
                } -NewLine
            }
        }
        # Content from link
        foreach ($L in $Link) {
            if ($L -ne '') {
                New-HTMLTag -Tag 'script' -Attributes @{ type = "text/javascript"; src = $L } -NewLine
            } else {
                return
            }
        }
    )
    if ($Output) {
        if ($AddComment) {
            $Output = @(
                "<!-- JS $ResourceComment START -->"
                $Output
                "<!-- JS $ResourceComment END -->"
            )
        }
        # Outputs only if more than comments
        if ($Placement -eq 'Footer') {
            $Script:HTMLSchema.CustomFooterJS[$ResourceComment] = $Output
        } elseif ($Placement -eq 'Header') {
            $Script:HTMLSchema.CustomHeaderJS[$ResourceComment] = $Output
        } else {
            $Output
        }
    }
}
function Add-HTMLStyle {
    [alias('Add-CSS')]
    [CmdletBinding()]
    param(
        [ValidateSet('Inline', 'Header', 'Footer')][string] $Placement = 'Header',
        [string] $ResourceComment,
        [string[]] $Link,
        [string[]] $Content,
        [string[]] $FilePath,
        [alias('CssInline')][System.Collections.IDictionary] $Css,
        [Parameter(DontShow)][System.Collections.IDictionary] $ReplaceData,
        [switch] $AddComment,
        [ValidateSet('dns-prefetch', 'preconnect', 'preload')][string] $RelType = 'preload',
        [switch] $SkipTags
    )
    if (-not $ResourceComment) {
        $ResourceComment = "ResourceCSS-$(Get-RandomStringName -Size 8 -LettersOnly)"
    }
    $Output = @(
        # Content from files
        foreach ($File in $FilePath) {
            if ($File -ne '') {
                if (Test-Path -LiteralPath $File) {
                    Write-Verbose "Add-HTMLStyle - Reading file from $File"
                    # Replaces stuff based on $Script:CurrentConfiguration CustomActionReplace Entry
                    $FileContent = Get-Content -LiteralPath $File -Raw
                    if ($null -ne $ReplaceData) {
                        foreach ($_ in $ReplaceData.Keys) {
                            $FileContent = $FileContent -replace $_, $ReplaceData[$_]
                        }
                    }
                    $FileContent = $FileContent -replace '@charset "UTF-8";'
                    # Put with tags or without them
                    if ($SkipTags) {
                        $FileContent
                    } else {
                        New-HTMLTag -Tag 'style' -Attributes @{ type = 'text/css' } {
                            $FileContent
                        } -NewLine
                    }
                }
            }
        }
        # Content from string
        if ($Content) {
            Write-Verbose "Add-HTMLStyle - Adding style from Content"
            if ($SkipTags) {
                $Content
            } else {
                New-HTMLTag -Tag 'style' -Attributes @{ type = 'text/css' } {
                    $Content
                } -NewLine
            }
        }
        # Content from Link
        foreach ($L in $Link) {
            if ($L -ne '') {
                Write-Verbose "Add-HTMLStyle - Adding link $L"
                New-HTMLTag -Tag 'link' -Attributes @{ rel = "stylesheet preload prefetch"; type = "text/css"; href = $L; as = 'style' } -SelfClosing -NewLine
            }
        }
        # Content from Hashtable
        if ($Css) {
            ConvertTo-CascadingStyleSheets -Css $Css -WithTags:(-not $SkipTags.IsPresent) #:$false
        }
    )
    if ($Output) {
        if ($AddComment) {
            $Output = @(
                "<!-- CSS $ResourceComment START -->"
                $Output
                "<!-- CSS $ResourceComment END -->"
            )
        }
        # Outputs only if more than comments
        if ($Placement -eq 'Footer') {
            $Script:HTMLSchema.CustomFooterCSS[$ResourceComment] = $Output
        } elseif ($Placement -eq 'Header') {
            $Script:HTMLSchema.CustomHeaderCSS[$ResourceComment] = $Output
        } else {
            $Output
        }
    }
}
function ConvertTo-CascadingStyleSheets {
    [cmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)][System.Collections.IDictionary] $Css,
        [switch] $WithTags
    )
    Process {
        if ($Css) {
            Remove-EmptyValue -Hashtable $Css -Recursive
        }
        if ($Css.Count -eq 0) {
            # Means empty value after we removed all empty values
            return
        }

        $Output = foreach ($Key in $Css.Keys) {

            if ($Css[$Key] -is [System.Collections.IDictionary]) {
                "$Key {"
                foreach ($_ in $Css[$Key].Keys) {
                    if ($null -ne $Css[$Key][$_]) {
                        # we remove empty chars because sometimes there can be multiple lines similar to each other

                        if ($Css[$Key][$_] -is [System.Collections.IDictionary]) {
                            "$_ {"
                            $Deep = ConvertTo-CascadingStyleSheets -Css $Css[$Key][$_]
                            $Deep
                            "}"
                        } else {
                            $Property = $_.Replace(' ', '')
                            "    $Property`: $($Css[$Key][$_]);"
                        }
                    } else {
                        Write-Verbose ""
                    }
                }
                "}"
                ''
            } else {
                $Property = $Key.Replace(' ', '')
                "    $Property`: $($Css[$Key]);"
            }

        }
        if ($WithTags) {
            New-HTMLTag -Tag 'style' {
                $Output
            }
        } else {
            $Output
        }
    }
}
<#

$Test = @{
    '@media all and (-ms-high-contrast:active)' = @{
        '.defaultSection' = @{
            'display'        = 'flex'
            'flex-direction' = 'column'
        }
    }
}

$Test2 = @{
    '.defaultSection'                           = [ordered] @{
        #'display'        = 'flex';
        #'flex-direction' = 'column'
        #'display'        = 'flex' # added to allow diagram to resize properly
        #'flex-direction' = 'default' # added to allow diagram to resize properly
        'border'         = '1px solid #bbbbbb'
        'padding-bottom' = '0px'
        'margin'         = '5px'
        'width'          = 'calc(100% - 10px)'
        'box-shadow'     = '0 4px 8px 0 rgba(0, 0, 0, 0.2)'
        'transition'     = '0.3s'
        'border-radius'  = '5px'
    }
}

ConvertTo-CascadingStyleSheets -Css $Test
#>
function Email {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $Email,
        [string[]] $To,
        [string[]] $CC,
        [string[]] $BCC,
        [string] $ReplyTo,
        [string] $From,
        [string] $Subject,
        [alias('SelfAttach')][switch] $AttachSelf,
        [string] $AttachSelfName,
        [string] $Server,
        [string] $Username,
        [int] $Port = 587,
        [string] $Password,
        [switch] $PasswordFromFile,
        [switch] $PasswordAsSecure,
        [switch] $SSL,
        [ValidateSet('Low', 'Normal', 'High')] [string] $Priority = 'Normal',
        [ValidateSet('None', 'OnSuccess', 'OnFailure', 'Delay', 'Never')] $DeliveryNotifications = 'None',
        [Obsolete("Encoding is depracated. We're setting encoding to UTF8 always to prevent errors")]
        [Parameter(DontShow)][string] $Encoding,
        [string] $FilePath,
        [alias('Supress')][bool] $Suppress = $true,
        [switch] $Online,
        [switch] $OutputHTML,
        [switch] $WhatIf
    )
    $Script:EmailSchema = [ordered]@{}
    $Script:EmailSchema['AttachSelf'] = $AttachSelf.IsPresent
    $Script:EmailSchema['Online'] = $Online.IsPresent

    $StartTime = [System.Diagnostics.Stopwatch]::StartNew()
    $ServerParameters = [ordered] @{
        From                  = $From
        To                    = $To
        CC                    = $CC
        BCC                   = $BCC
        ReplyTo               = $ReplyTo
        Server                = $Server
        Login                 = $Username
        Password              = $Password
        PasswordAsSecure      = $PasswordAsSecure
        PasswordFromFile      = $PasswordFromFile
        Port                  = $Port
        EnableSSL             = $SSL
        # Overwrite whatever user set, from tests it seems UTF8 is the best way to go, always, especially that HTML created is UTF8
        # When it's left alone Send-Email will autodetect content and set it to utf8
        #
        #Encoding              = 'utf8'
        #Encoding              = $Encoding
        Subject               = $Subject
        Priority              = $Priority
        DeliveryNotifications = $DeliveryNotifications
    }
    $Attachments = [System.Collections.Generic.List[string]]::new()

    [Array] $EmailParameters = Invoke-Command -ScriptBlock $Email

    foreach ($Parameter in $EmailParameters) {
        switch ( $Parameter.Type ) {
            HeaderTo {
                $ServerParameters.To = $Parameter.Addresses
            }
            HeaderCC {
                $ServerParameters.CC = $Parameter.Addresses
            }
            HeaderBCC {
                $ServerParameters.BCC = $Parameter.Addresses
            }
            HeaderFrom {
                $ServerParameters.From = $Parameter.Address
            }
            HeaderReplyTo {
                $ServerParameters.ReplyTo = $Parameter.Address
            }
            HeaderSubject {
                $ServerParameters.Subject = $Parameter.Subject
            }
            HeaderServer {
                $ServerParameters.Server = $Parameter.Server
                $ServerParameters.Port = $Parameter.Port
                $ServerParameters.Login = $Parameter.UserName
                $ServerParameters.Password = $Parameter.Password
                $ServerParameters.PasswordFromFile = $Parameter.PasswordFromFile
                $ServerParameters.PasswordAsSecure = $Parameter.PasswordAsSecure
                $ServerParameters.EnableSSL = $Parameter.SSL
                $ServerParameters.UseDefaultCredentials = $Parameter.UseDefaultCredentials
            }
            HeaderAttachment {
                foreach ($Attachment in  $Parameter.FilePath) {
                    $Attachments.Add($Attachment)
                }
            }
            HeaderOptions {
                $ServerParameters.DeliveryNotifications = $Parameter.DeliveryNotifications
                # From tests it seems UTF8 is the best way to go, always, especially that HTML created is UTF8, no need to set it
                #$ServerParameters.Encoding = $Parameter.Encoding
                $ServerParameters.Priority = $Parameter.Priority
            }
            Default {
                $OutputBody = $Parameter
            }
        }
    }
    if ($OutputBody -is [System.Collections.IDictionary]) {
        $Body = $OutputBody.Body
        $AttachSelfBody = $OutputBody.AttachSelfBody
    } else {
        $Body = $OutputBody
    }

    if ($FilePath) {
        # Saving HTML to file
        $SavedPath = Save-HTML -FilePath $FilePath -HTML $Body -Suppress $false
    }
    if ($OutputHTML) {
        # If outputhtml is set it allows to return Body of HTML for using it in different scenarios
        $Body
    }
    if ($AttachSelf) {
        if ($AttachSelfName) {
            $TempFilePath = [System.IO.Path]::Combine($(Get-TemporaryDirectory), "$($AttachSelfName).html")
        } else {
            $TempFilePath = ''
        }
        if ($FilePath -and -not $AttachSelfName) {
            # we don't want to save body again if we already saved it above
            $Saved = $SavedPath
        } else {
            # we save it to temp file or attachselfname
            $Saved = Save-HTML -FilePath $TempFilePath -HTML $AttachSelfBody -Suppress $false
        }
        if ($Saved) {
            $Attachments.Add($Saved)
        }
    }

    #$MailSentTo = "To: $($ServerParameters.To -join ', '); CC: $($ServerParameters.CC -join ', '); BCC: $($ServerParameters.BCC -join ', ')".Trim()
    $EmailOutput = Send-Email -EmailParameters $ServerParameters -Body $Body -Attachment $Attachments -WhatIf:$WhatIf
    if (-not $Suppress) {
        $EmailOutput
    }

    $EndTime = Stop-TimeLog -Time $StartTime -Option OneLiner
    Write-Verbose "Email - Time to send: $EndTime"
    $Script:EmailSchema = $null
}

function EmailAttachment {
    [CmdletBinding()]
    param(
        [string[]] $FilePath
    )
    [PSCustomObject] @{
        Type     = 'HeaderAttachment'
        FilePath = $FilePath
    }
}
function EmailBCC {
    [CmdletBinding()]
    param(
        [string[]] $Addresses
    )

    [PsCustomObject] @{
        Type      = 'HeaderBCC'
        Addresses = $Addresses
    }
}
function EmailBody {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $EmailBody,
        [string] $Color,
        [string] $BackGroundColor,
        [string] $LineHeight,
        [alias('Size')][object] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily ,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        [switch] $Online,
        [switch] $Format,
        [switch] $Minify
    )

    $newHTMLSplat = @{}
    $newTableSplat = @{}
    if ($Alignment) {
        $newHTMLSplat.Alignment = $Alignment
        $newTableSplat.'text-align' = $Alignment
    }
    if ($FontSize) {
        $newHTMLSplat.FontSize = $FontSize
        $newTableSplat.'font-size' = ConvertFrom-Size -FontSize $FontSize
    }
    if ($TextTransform) {
        $newHTMLSplat.TextTransform = $TextTransform
        $newTableSplat.'text-transform' = $TextTransform
    }
    if ($Color) {
        $newHTMLSplat.Color = $Color
        $newTableSplat.'text-color' = ConvertFrom-Color -Color $Color
    }
    if ($FontFamily) {
        $newHTMLSplat.FontFamily = $FontFamily
        $newTableSplat.'font-family' = $FontFamily
    }
    if ($Direction) {
        $newHTMLSplat.Direction = $Direction
        $newTableSplat.'direction' = $Direction
    }
    if ($FontStyle) {
        $newHTMLSplat.FontStyle = $FontStyle
        $newTableSplat.'font-style' = $FontStyle
    }
    if ($TextDecoration) {
        $newHTMLSplat.TextDecoration = $TextDecoration
        $newTableSplat.'text-decoration' = $TextDecoration
    }
    if ($BackGroundColor) {
        $newHTMLSplat.BackGroundColor = $BackGroundColor
        $newTableSplat.'background-color' = ConvertFrom-Color -Color $BackGroundColor
    }
    if ($FontVariant) {
        $newHTMLSplat.FontVariant = $FontVariant
        $newTableSplat.'font-variant' = $FontVariant
    }
    if ($FontWeight) {
        $newHTMLSplat.FontWeight = $FontWeight
        $newTableSplat.'font-weight' = $FontWeight
    }
    if ($LineHeight) {
        $newHTMLSplat.LineHeight = $LineHeight
        $newTableSplat.'line-height' = $LineHeight
    }
    if ($newHTMLSplat.Count -gt 0) {
        $SpanRequired = $true
    } else {
        $SpanRequired = $false
    }
    # This is used if Email is used and someone would set Online switch there.
    # Since we moved New-HTML here - we need to do some workaround
    if (-not $Online) {
        if ($Script:EmailSchema -and $Script:EmailSchema['Online']) {
            $HTMLOnline = $true
        } else {
            $HTMLOnline = $false
        }
    } else {
        $HTMLOnline = $true
    }


    $Body = New-HTML -Online:$HTMLOnline {
        # Email is special and we want margins to be 0px
        $Script:HTMLSchema['Email'] = $true
        #$Script:CurrentConfiguration['Features']['Main']['HeaderAlways']['CssInLine']['body']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultImage']['HeaderAlways']['CssInLine']['.logo']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h1']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h2']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h3']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h4']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h5']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultHeadings']['HeaderAlways']['CssInLine']['h6']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DefaultText']['HeaderAlways']['CssInLine']['.defaultText']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DataTables']['HeaderAlways']['CssInLine']['div.dataTables_wrapper']['margin'] = '0px'
        $Script:CurrentConfiguration['Features']['DataTables']['HeaderAlways']['CssInLine']['div.dataTables_wrapper']['margin'] = '0px'

        # Since settings for table via span doesn't apply to tables we need to use direct method of changing CSS
        if ($newTableSplat) {
            foreach ($Key in $newTableSplat.Keys) {
                $Script:CurrentConfiguration['Features']['DataTablesEmail']['HeaderAlways']['CssInLine']['table'][$Key] = $newTableSplat[$Key]
            }
        }
        if ($SpanRequired) {
            New-HTMLSpanStyle @newHTMLSplat {
                Invoke-Command -ScriptBlock $EmailBody
            }
        } else {
            Invoke-Command -ScriptBlock $EmailBody
        }
    } -Format:$Format -Minify:$Minify
    # This section makes sure that if any script is present in HTML it will be removed.
    # Our goal here is to make HTML in EMAIL as small as possible without added junk which won't be read anyways
    # https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-5.0
    $options = [Text.RegularExpressions.RegexOptions] 'Singleline,IgnoreCase' #, CultureInvariant'
    $OutputToCheck = [Regex]::Matches($Body, '(?<=<script)(.*?)(?=<\/script>)', $options) | Select-Object -ExpandProperty Value
    foreach ($Script in $OutputToCheck) {
        $Body = $Body.Replace("<script$Script</script>", '')
    }

    if ($Script:EmailSchema -and $Script:EmailSchema['AttachSelf']) {
        # if attach self is used we will generate better version with JS present, proper margins and so on
        $AttachSelfBody = New-HTML -Online:$HTMLOnline {
            if ($SpanRequired) {
                New-HTMLSpanStyle @newHTMLSplat {
                    Invoke-Command -ScriptBlock $EmailBody
                }
            } else {
                Invoke-Command -ScriptBlock $EmailBody
            }
        } -Format:$Format -Minify:$Minify

        @{
            Body           = $Body
            AttachSelfBody = $AttachSelfBody
        }
    } else {
        # if attach self is not used we need only one version of code
        $Body
    }

}

Register-ArgumentCompleter -CommandName EmailBody -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName EmailBody -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function EmailCC {
    [CmdletBinding()]
    param(
        [string[]] $Addresses
    )

    [PsCustomObject] @{
        Type      = 'HeaderCC'
        Addresses = $Addresses
    }
}
function EmailFrom {
    [CmdletBinding()]
    param(
        [string] $Address
    )

    [PsCustomObject] @{
        Type    = 'HeaderFrom'
        Address = $Address
    }
}
function EmailHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $EmailHeader
    )
    $EmailHeaders = Invoke-Command -ScriptBlock $EmailHeader
    $EmailHeaders
}
function EmailListItem {
    [CmdletBinding()]
    param(
        [string[]] $Text,
        [string[]] $Color = @(),
        [string[]] $BackGroundColor = @(),
        [int[]] $FontSize = @(),
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string[]] $FontWeight = @(),
        [ValidateSet('normal', 'italic', 'oblique')][string[]] $FontStyle = @(),
        [ValidateSet('normal', 'small-caps')][string[]] $FontVariant = @(),
        [string[]] $FontFamily = @(),
        [ValidateSet('left', 'center', 'right', 'justify')][string[]] $Alignment = @(),
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string[]] $TextDecoration = @(),
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string[]] $TextTransform = @(),
        [ValidateSet('rtl')][string[]] $Direction = @(),
        [switch] $LineBreak
    )

    $newHTMLTextSplat = @{
        Alignment       = $Alignment
        FontSize        = $FontSize
        TextTransform   = $TextTransform
        Text            = $Text
        Color           = $Color
        FontFamily      = $FontFamily
        Direction       = $Direction
        FontStyle       = $FontStyle
        TextDecoration  = $TextDecoration
        BackGroundColor = $BackGroundColor
        FontVariant     = $FontVariant
        FontWeight      = $FontWeight
        LineBreak       = $LineBreak
    }

    New-HTMLListItem @newHTMLTextSplat
}
Register-ArgumentCompleter -CommandName EmailListItem -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName EmailListItem -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function EmailOptions {
    [CmdletBinding()]
    param(
        [ValidateSet('Low', 'Normal', 'High')] [string] $Priority = 'Normal',
        [ValidateSet('None', 'OnSuccess', 'OnFailure', 'Delay', 'Never')] $DeliveryNotifications = 'None',
        [Obsolete("Encoding is depracated. We're setting encoding to UTF8 always to prevent errors")]
        [Parameter(DontShow)][string] $Encoding
    )

    [PsCustomObject] @{
        Type                  = 'HeaderOptions'
        # From tests it seems UTF8 is the best way to go, always, especially that HTML created is UTF8, no need to set it
        #Encoding              = $Encoding
        DeliveryNotifications = $DeliveryNotifications
        Priority              = $Priority
    }
}
function EmailReplyTo {
    [CmdletBinding()]
    param(
        [string] $Address
    )

    [PsCustomObject] @{
        Type    = 'HeaderReplyTo'
        Address = $Address
    }
}
function EmailServer {
    [CmdletBinding()]
    param(
        [string] $Server,
        [int] $Port = 587,
        [string] $UserName,
        [string] $Password,
        [switch] $PasswordAsSecure,
        [switch] $PasswordFromFile,
        [switch] $SSL,
        [alias('UseDefaultCredentials')][switch] $UseDefaultCredential
    )

    [PsCustomObject] @{
        Type                  = 'HeaderServer'
        Server                = $Server
        Port                  = $Port
        UserName              = $UserName
        Password              = $Password
        PasswordAsSecure      = $PasswordAsSecure
        PasswordFromFile      = $PasswordFromFile
        SSL                   = $SSL
        UseDefaultCredentials = $UseDefaultCredential
    }
}
function EmailSubject {
    [CmdletBinding()]
    param(
        [string] $Subject
    )

    [PsCustomObject] @{
        Type    = 'HeaderSubject'
        Subject = $Subject
    }
}

function EmailTo {
    [CmdletBinding()]
    param(
        [string[]] $Addresses
    )

    [PsCustomObject] @{
        Type      = 'HeaderTo'
        Addresses = $Addresses
    }
}
function Enable-HTMLFeature {
    <#
    .SYNOPSIS
    Provides a way to enable existing feature or extending PSWriteHTML

    .DESCRIPTION
    Provides a way to enable existing feature or extending PSWriteHTML

    .PARAMETER Feature
    Choose one of the existing features or define them via extension

    .PARAMETER Configuration
    Provide hashtable with configuration of libraries

    .EXAMPLE
    Enable-HTMLFeature -Feature Raphael, Mapael, Jquery, JQueryMouseWheel, "MapaelMaps_$Map" -Configuration $Script:Configuration

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [string[]] $Feature,
        [System.Collections.IDictionary] $Configuration
    )
    foreach ($F in $Feature) {
        $Script:HTMLSchema.Features.$F = $true
    }
    if ($Configuration) {
        # Allows for extending PSWriteHTML with other modules
        foreach ($Library in $Configuration.Keys) {
            $Script:CurrentConfiguration['Features'][$Library] = $Configuration[$Library]
        }
    }
}

Register-ArgumentCompleter -CommandName Enable-HTMLFeature -ParameterName Feature -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $Script:CurrentConfiguration.Features.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}
function New-AccordionItem {
    [cmdletBinding()]
    param(
        [string] $HeaderText,
        [string] $HeaderAlign,
        [string] $PanelText
    )

    New-HTMLTag -Tag 'div' -Attributes @{ class = 'ac' } {
        New-HTMLTag -Tag 'h2' -Attributes @{ class = 'ac-header'; } {
            # text-align: left;
            # font: bold 16px Arial,sans-serif;
            New-HTMLTag -Tag 'button' -Attributes @{ class = 'ac-trigger' } {
                $HeaderText
            }
        }
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'ac-panel' } {
            New-HTMLTag -Tag 'p' -Attributes @{ class = 'ac-text' } {
                # font: 15px/24px Arial, sans-serif;
                # color: #111;
                $PanelText
            }
        }
    }
}
function New-CalendarEvent {
    [alias('CalendarEvent')]
    [CmdletBinding()]
    param(
        [string] $Title,
        [string] $Description,
        [DateTime] $StartDate,
        [nullable[DateTime]] $EndDate,
        [string] $Constraint,
        [string] $Color
    )

    $Object = [PSCustomObject] @{
        Type     = 'CalendarEvent'
        Settings = [ordered] @{
            title       = $Title
            description = $Description
            constraint  = $Constraint
            #      url: 'http://google.com/',
            color       = ConvertFrom-Color -Color $Color
        }
    }
    if ($StartDate) {
        $Object.Settings.start = Get-Date -Date ($StartDate) -Format "yyyy-MM-ddTHH:mm:ss"
    }
    if ($EndDate) {
        $Object.Settings.end = Get-Date -Date ($EndDate) -Format "yyyy-MM-ddTHH:mm:ss"
    }

    Remove-EmptyValue -Hashtable $Object.Settings -Recursive #-Rerun 2
    $Object
}
Register-ArgumentCompleter -CommandName New-CalendarEvent -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
<#
    events: [
    {
        title: 'rrule event',
        rrule: {
        dtstart: '2019-08-09T13:00:00',
        // until: '2019-08-01',
        freq: 'weekly'
        },
        duration: '02:00'
    }
    ],
events: [{
        title: 'Business Lunch',
        start: '2019-08-03T13:00:00',
        constraint: 'businessHours'
    },
    {
        title: 'Meeting',
        start: '2019-08-13T11:00:00',
        constraint: 'availableForMeeting', // defined below
        color: '#257e4a'
    },
    {
        title: 'Conference',
        start: '2019-08-18',
        end: '2019-08-20'
    },
    {
        title: 'Party',
        start: '2019-08-29T20:00:00'
    },

    // areas where "Meeting" must be dropped
    {
        groupId: 'availableForMeeting',
        start: '2019-08-11T10:00:00',
        end: '2019-08-11T16:00:00',
        rendering: 'background'
    },
    {
        groupId: 'availableForMeeting',
        start: '2019-08-13T10:00:00',
        end: '2019-08-13T16:00:00',
        rendering: 'background'
    },

    // red areas where no events can be dropped
    {
        start: '2019-08-24',
        end: '2019-08-28',
        overlap: false,
        rendering: 'background',
        color: '#ff9f89'
    },
    {
        start: '2019-08-06',
        end: '2019-08-08',
        overlap: false,
        rendering: 'background',
        color: '#ff9f89'
    }
]
#>

function New-CarouselSlide {
    [cmdletBinding()]
    param(
        [scriptblock] $SlideContent
    )
    New-HTMLTag -Tag 'div' -Attributes @{ class = 'slide' } {
        if ($SlideContent) {
            & $SlideContent
        }
    }
}
function New-ChartAxisX {
    [alias('ChartCategory', 'ChartAxisX', 'New-ChartCategory')]
    [CmdletBinding()]
    param(
        [alias('Name')][Array] $Names,
        [alias('Title')][string] $TitleText,
        [ValidateSet('datetime', 'category', 'numeric')][string] $Type = 'category',
        [object] $MinValue,
        [object] $MaxValue,

        [string] $TimeZoneOffset
        #[ValidateSet('top', 'topRight', 'left', 'right', 'bottom', '')][string] $LegendPosition = '',
        # [string[]] $Color
    )

    $offsetMilliseconds = 0
    if ($TimeZoneOffset) {
        $offsetMilliseconds = ([System.TimeSpan]::Parse($TimeZoneOffset)).TotalMilliseconds
    }
    # if Dates are given, lets auto change type to DateTime
    if ($MinValue -is [DateTime] -or $MaxValue -is [DateTime]) {
        $Type = 'datetime'
    }
    switch ($Type) {
        'datetime' {
            if ($MinValue -is [System.DateTime]) {
                $MinValue = [int64]([System.DateTimeOffset]$MinValue).ToUnixTimeMilliseconds() + $offsetMilliseconds
            }

            if ($MaxValue -is [System.DateTime]) {
                $MaxValue = [int64]([System.DateTimeOffset]$MaxValue).ToUnixTimeMilliseconds() + $offsetMilliseconds
            }
        }
        Default {
            $MinValue = [int]$MinValue
            $MaxValue = [int]$MaxValue
        }
    }
    [PSCustomObject] @{
        ObjectType = 'ChartAxisX'
        ChartAxisX = @{
            Names     = $Names
            Type      = $Type
            TitleText = $TitleText
            Min       = $MinValue
            Max       = $MaxValue
        }

        #   LegendPosition = $LegendPosition
        #   Color          = $Color
    }

    # https://apexcharts.com/docs/options/xaxis/
}

<# We can build this:
   xaxis: {
        type: 'category',
        categories: [],
        labels: {
            show: true,
            rotate: -45,
            rotateAlways: false,
            hideOverlappingLabels: true,
            showDuplicates: false,
            trim: true,
            minHeight: undefined,
            maxHeight: 120,
            style: {
                colors: [],
                fontSize: '12px',
                fontFamily: 'Helvetica, Arial, sans-serif',
                cssClass: 'apexcharts-xaxis-label',
            },
            offsetX: 0,
            offsetY: 0,
            format: undefined,
            formatter: undefined,
            datetimeFormatter: {
                year: 'yyyy',
                month: "MMM 'yy",
                day: 'dd MMM',
                hour: 'HH:mm',
            },
        },
        axisBorder: {
            show: true,
            color: '#78909C',
            height: 1,
            width: '100%',
            offsetX: 0,
            offsetY: 0
        },
        axisTicks: {
            show: true,
            borderType: 'solid',
            color: '#78909C',
            height: 6,
            offsetX: 0,
            offsetY: 0
        },
        tickAmount: undefined,
        tickPlacement: 'between',
        min: undefined,
        max: undefined,
        range: undefined,
        floating: false,
        position: 'bottom',
        title: {
            text: undefined,
            offsetX: 0,
            offsetY: 0,
            style: {
                color: undefined,
                fontSize: '12px',
                fontFamily: 'Helvetica, Arial, sans-serif',
                cssClass: 'apexcharts-xaxis-title',
            },
        },
        crosshairs: {
            show: true,
            width: 1,
            position: 'back',
            opacity: 0.9,
            stroke: {
                color: '#b6b6b6',
                width: 0,
                dashArray: 0,
            },
            fill: {
                type: 'solid',
                color: '#B1B9C4',
                gradient: {
                    colorFrom: '#D8E3F0',
                    colorTo: '#BED1E6',
                    stops: [0, 100],
                    opacityFrom: 0.4,
                    opacityTo: 0.5,
                },
            },
            dropShadow: {
                enabled: false,
                top: 0,
                left: 0,
                blur: 1,
                opacity: 0.4,
            },
        },
        tooltip: {
            enabled: true,
            formatter: undefined,
            offsetY: 0,
        },
    }

#>
function New-ChartAxisY {
    [alias('ChartAxisY')]
    [CmdletBinding()]
    param(
        [switch] $Show,
        [switch] $ShowAlways,
        [string] $TitleText,
        [ValidateSet('90', '270')][string] $TitleRotate,
        [int] $TitleOffsetX = 0,
        [int] $TitleOffsetY = 0,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $TitleFontWeight,
        [alias('TitleStyleColor')][string] $TitleColor,
        [alias('TitleStyleFontSize')][int] $TitleFontSize, # = 12,
        [alias('TitleStyleFontFamily')][string] $TitleFontFamily, # = 'Helvetica, Arial, sans-serif',
        [int] $MinValue,
        [int] $MaxValue,
        [int] $LabelMinWidth = -1,
        [int] $LabelMaxWidth,
        [ValidateSet('left', 'center', 'right')][string] $LabelAlign,
        [object] $LabelFontSize,
        [string] $LabelFontFamily,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $LabelFontWeight,
        [string[]] $LabelFontColor,
        [switch] $Reversed,
        [switch] $Opposite,
        [switch] $Logarithmic,
        [switch] $ForceNiceScale,
        [switch] $Floating
    )
    $Object = [PSCustomObject] @{
        ObjectType = 'ChartAxisY'
        ChartAxisY = @{
            show       = $Show.IsPresent
            showAlways = $ShowAlways.IsPresent
        }
    }
    if ($Reversed) {
        $Object.ChartAxisY.reversed = $true
    }
    if ($Opposite) {
        $Object.ChartAxisY.opposite = $true
    }
    if ($Logarithmic) {
        $Object.ChartAxisY.logarithmic = $true
    }
    if ($ForceNiceScale) {
        $Object.ChartAxisY.forceNiceScale = $true
    }
    if ($Floating) {
        $Object.ChartAxisY.floating = $true
    }
    if ($MinValue) {
        $Object.ChartAxisY.min = $MinValue
    }
    if ($MaxValue) {
        $Object.ChartAxisY.max = $MaxValue
    }

    $Object.ChartAxisY.title = @{}
    if ($TitleText) {
        $Object.ChartAxisY.title.text = $TitleText
    }
    if ($TitleRotate) {
        $Object.ChartAxisY.title.rotate = [int] $TitleRotate
    }
    if ($TitleOffsetX) {
        $Object.ChartAxisY.title.offsetX = $TitleOffsetX
    }
    if ($TitleOffsetY) {
        $Object.ChartAxisY.title.offsetY = $TitleOffsetY
    }
    if ($TitleColor -or $TitleFontSize -or $TitleFontFamily) {
        $Object.ChartAxisY.title.style = @{}
        if ($TitleColor) {
            $Object.ChartAxisY.title.style.color = ConvertFrom-Color -Color $TitleColor
        }
        if ($TitleFontSize) {
            $Object.ChartAxisY.title.style.fontSize = ConvertFrom-Size -Size $TitleFontSize
        }
        if ($TitleFontFamily) {
            $Object.ChartAxisY.title.style.fontFamily = $TitleFontFamily
        }
        if ($TitleFontWeight) {
            $Object.ChartAxisY.title.style.fontWeight = $TitleFontWeight
        }
    }

    $Object.ChartAxisY.labels = @{}
    if ($LabelAlign) {
        $Object.ChartAxisY.labels.align = $LabelAlign
    }
    if ($LabelMinWidth -ne -1) {
        $Object.ChartAxisY.labels.minWidth = $LabelMinWidth
    }
    if ($LabelMaxWidth) {
        $Object.ChartAxisY.labels.maxWidth = $LabelMaxWidth
    }
    if ($LabelFontSize -or $LabelFontFamily -or $LabelFontWeight -or $LabelFontColor) {
        $Object.ChartAxisY.labels.style = @{}

        if ($LabelFontSize) {
            $Object.ChartAxisY.labels.style.fontSize = ConvertFrom-Size -Size $LabelFontSize
        }
        if ($LabelFontFamily) {
            $Object.ChartAxisY.labels.style.fontFamily = $LabelFontFamily
        }
        if ($LabelFontWeight) {
            $Object.ChartAxisY.labels.style.fontWeight = $LabelFontWeight
        }
        if ($LabelFontColor) {
            $Object.ChartAxisY.labels.style.colors = @($LabelFontColor)
        }
    }
    Remove-EmptyValue -Hashtable $Object.ChartAxisY -Recursive -Rerun 2
    $Object

    # https://apexcharts.com/docs/options/yaxis/
}
Register-ArgumentCompleter -CommandName New-ChartAxisY -ParameterName TitleColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-ChartAxisY -ParameterName LabelFontColor -ScriptBlock $Script:ScriptBlockColors
<# We can build this
    yaxis: {
        show: true,
        showAlways: true,
        seriesName: undefined,
        opposite: false,
        reversed: false,
        logarithmic: false,
        tickAmount: 6,
        min: 6,
        max: 6,
        forceNiceScale: false,
        floating: false,
        decimalsInFloat: undefined,
        labels: {
            show: true,
            align: 'right',
            minWidth: 0,
            maxWidth: 160,
            style: {
                color: undefined,
                fontSize: '12px',
                fontFamily: 'Helvetica, Arial, sans-serif',
                cssClass: 'apexcharts-yaxis-label',
            },
            offsetX: 0,
            offsetY: 0,
            rotate: 0,
            formatter: (value) => { return val },
        },
        axisBorder: {
            show: true,
            color: '#78909C',
            offsetX: 0,
            offsetY: 0
        },
        axisTicks: {
            show: true,
            borderType: 'solid',
            color: '#78909C',
            width: 6,
            offsetX: 0,
            offsetY: 0
        },
        title: {
            text: undefined,
            rotate: -90,
            offsetX: 0,
            offsetY: 0,
            style: {
                color: undefined,
                fontSize: '12px',
                fontFamily: 'Helvetica, Arial, sans-serif',
                cssClass: 'apexcharts-yaxis-title',
            },
        },
        crosshairs: {
            show: true,
            position: 'back',
            stroke: {
                color: '#b6b6b6',
                width: 1,
                dashArray: 0,
            },
        },
        tooltip: {
            enabled: true,
            offsetX: 0,
        },

    }

#>
function New-ChartBar {
    [alias('ChartBar')]
    [CmdletBinding()]
    param(
        [string] $Name,
        [object] $Value
    )
    if ($null -eq $Value -or $Value -eq '') {
        $Value = 0
    }
    [PSCustomObject] @{
        ObjectType = 'Bar'
        Name       = $Name
        Value      = $Value
    }
}
function New-ChartBarOptions {
    [alias('ChartBarOptions')]
    [CmdletBinding()]
    param(
        [ValidateSet('bar', 'barStacked', 'barStacked100Percent')] $Type = 'bar',
        [bool] $DataLabelsEnabled = $true,
        [int] $DataLabelsOffsetX = -6,
        [string] $DataLabelsFontSize = '12px',
        [string] $DataLabelsColor,
        [alias('PatternedColors')][switch] $Patterned,
        [alias('GradientColors')][switch] $Gradient,
        [switch] $Distributed,
        [switch] $Vertical

    )

    if ($null -ne $PSBoundParameters.Patterned) {
        $PatternedColors = $Patterned.IsPresent
    } else {
        $PatternedColors = $null
    }
    if ($null -ne $PSBoundParameters.Gradient) {
        $GradientColors = $Gradient.IsPresent
    } else {
        $GradientColors = $null
    }

    [PSCustomObject] @{
        ObjectType         = 'BarOptions'
        Type               = $Type
        Horizontal         = -not $Vertical.IsPresent
        DataLabelsEnabled  = $DataLabelsEnabled
        DataLabelsOffsetX  = $DataLabelsOffsetX
        DataLabelsFontSize = $DataLabelsFontSize
        DataLabelsColor    = $DataLabelsColor
        PatternedColors    = $PatternedColors
        GradientColors     = $GradientColors
        Distributed        = $Distributed.IsPresent
    }
}

Register-ArgumentCompleter -CommandName New-ChartBarOptions -ParameterName LineColor -ScriptBlock $Script:ScriptBlockColors
function New-ChartDataLabel {
    [cmdletBinding()]
    param(
        [switch] $Enabled,
        [int] $DataLabelsOffsetX,
        [string] $DataLabelsFontSize,
        [string[]] $DataLabelsColor
    )

    $Object = [PSCustomObject] @{
        ObjectType = 'DataLabel'
        DataLabel  = [ordered] @{
            enabled = $Enabled.IsPresent
        }
    }
    if ($DataLabelsOffsetX) {
        $Object['DataLabel']['offsetX'] = $DataLabelsOffsetX
    }
    $Object.DataLabel.style = [ordered]@{}
    if ($DataLabelsFontSize) {
        $Object.DataLabel.style['fontSize'] = $DataLabelsFontSize
    }
    if ($DataLabelsColor.Count -gt 0) {
        $Object.DataLabel.style['colors'] = @(ConvertFrom-Color -Color $DataLabelsColor)
    }
    Remove-EmptyValue -Hashtable $Object.DataLabel -Recursive
    $Object
}

Register-ArgumentCompleter -CommandName New-ChartDataLabel -ParameterName DataLabelsColor -ScriptBlock $Script:ScriptBlockColors
function New-ChartDonut {
    [alias('ChartDonut')]
    [CmdletBinding()]
    param(
        [string] $Name,
        [object] $Value,
        [string] $Color
    )

    [PSCustomObject] @{
        ObjectType = 'Donut'
        Name       = $Name
        Value      = $Value
        Color      = $Color
    }
}
Register-ArgumentCompleter -CommandName New-ChartDonut -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartEvent {
    [cmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $DataTableID,
        [Parameter(Mandatory)][int] $ColumnID,
        [switch] $EscapeRegex
    )
    if ($EscapeRegex) {
        $Script:HTMLSchema.Features.EscapeRegex = $true
        $Escape = 'true'
    } else {
        $Escape = 'false'
    }
    $Script:HTMLSchema.Features.ChartsEvents = $true


    $Output = @"
            events: {
                click: function (event, chartContext, config) {
                    chartEventClick('$DataTableID', $ColumnID, config.config, config.dataPointIndex, config.seriesIndex, $Escape);
                },
                dataPointSelection: function (event, chartContext, config) {
                    chartEventDataPointClick('$DataTableID', $ColumnID, config.w.config, config.dataPointIndex, $Escape);
                },
                markerClick: function (event, chartContext, { seriesIndex, dataPointIndex, config }) {
                    chartEventMarkerClick('$DataTableID', $ColumnID, chartContext.opts, dataPointIndex, seriesIndex, $Escape);
                }
            }
"@
    $DataTablesOutput = @"
    `$.fn.dataTable.ext.search.push(
        function (settings, searchData, index, rowData, counter) {
            return dataTablesSearchExtension('$DataTableID', settings, searchData, index, rowData, counter, true);
        }
    );
"@

    Add-HTMLScript -Placement Footer -Content $DataTablesOutput

    [PSCustomObject] @{
        ObjectType = 'ChartEvents'
        Event      = $Output
    }
}
function New-ChartGrid {
    [alias('ChartGrid')]
    [CmdletBinding()]
    param(
        [switch] $Show,
        [string] $BorderColor,
        [int] $StrokeDash, #: 0,
        [ValidateSet('front', 'back', 'default')][string] $Position = 'default',
        [switch] $xAxisLinesShow,
        [switch] $yAxisLinesShow,
        [string[]] $RowColors,
        [double] $RowOpacity = 0.5, # valid range 0 - 1
        [string[]] $ColumnColors,
        [double] $ColumnOpacity = 0.5, # valid range 0 - 1
        [int] $PaddingTop,
        [int] $PaddingRight,
        [int] $PaddingBottom,
        [int] $PaddingLeft
    )
    [PSCustomObject] @{
        ObjectType = 'ChartGrid'
        Grid       = @{
            Show           = $Show.IsPresent
            BorderColor    = $BorderColor
            StrokeDash     = $StrokeDash
            Position       = $Position
            xAxisLinesShow = $xAxisLinesShow.IsPresent
            yAxisLinesShow = $yAxisLinesShow.IsPresent
            RowColors      = $RowColors
            RowOpacity     = $RowOpacity
            ColumnColors   = $ColumnColors
            ColumnOpacity  = $ColumnOpacity
            PaddingTop     = $PaddingTop
            PaddingRight   = $PaddingRight
            PaddingBottom  = $PaddingBottom
            PaddingLeft    = $PaddingLeft
        }
    }
    # https://apexcharts.com/docs/options/xaxis/
}
Register-ArgumentCompleter -CommandName New-ChartGrid -ParameterName BorderColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-ChartGrid -ParameterName RowColors -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-ChartGrid -ParameterName ColumnColors -ScriptBlock $Script:ScriptBlockColors
function New-ChartLegend {
    [alias('ChartLegend')]
    [CmdletBinding()]
    param(
        [Array] $Names,
        [string[]] $Color,

        # real legend
        [switch] $HideLegend,
        [ValidateSet('top', 'left', 'right', 'bottom')][string] $LegendPosition,
        [ValidateSet('left', 'center', 'right')][string] $HorizontalAlign,
        [switch] $Floating,
        [switch] $InverseOrder,
        [nullable[int]] $OffsetX,
        [nullable[int]] $OffsetY,
        [nullable[int]] $ItemMarginHorizontal,
        [nullable[int]] $ItemMarginVertical,
        [object] $FontSize,
        [string] $FontFamily,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [switch] $DisableOnItemClickToggleDataSeries,
        [switch] $DisableOnItemHoverHighlightDataSeries
    )
    $Object = [PSCustomObject] @{
        ObjectType = 'Legend'
        Names      = $Names
        Color      = $Color

        legend     = [ordered] @{
            show            = -not $HideLegend.IsPresent
            position        = $LegendPosition
            horizontalAlign = $HorizontalAlign
        }
    }
    if ($Floating) {
        $Object.legend.floating = $true
    }
    if ($InverseOrder) {
        $Object.legend.inverseOrder = $true
    }
    if ($OffsetX -ne $null) {
        $Object.legend.offsetX = $OffsetX
    }
    if ($OffsetY -ne $null) {
        $Object.legend.offsetY = $OffsetY
    }
    if ($ItemMarginHorizontal -ne $null -or $ItemMarginHorizontal -ne $null) {
        $Object.legend.itemMargin = @{}
        if ($ItemMarginHorizontal -ne $null) {
            $Object.legend.itemMargin.horizontal = $ItemMarginHorizontal
        }
        if ($ItemMarginVertical -ne $null) {
            $Object.legend.itemMargin.vertical = $ItemMarginVertical
        }
    }
    if ($DisableOnItemClickToggleDataSeries) {
        $Object.legend.onItemClick = @{
            toggleDataSeries = $false
        }
    }
    if ($DisableOnItemHoverHighlightDataSeries) {
        $Object.legend.onItemHover = @{
            highlightDataSeries = $false
        }
    }

    if ($LabelFontSize) {
        $Object.legend.fontSize = ConvertFrom-Size -Size $FontSize
    }
    if ($LabelFontFamily) {
        $Object.legend.fontFamily = $FontFamily
    }
    if ($LabelFontWeight) {
        $Object.legend.fontWeight = $FontWeight
    }

    Remove-EmptyValue -Hashtable $Object.legend -Recursive -Rerun 2
    $Object
}
Register-ArgumentCompleter -CommandName New-ChartLegend -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartLine {
    [alias('ChartLine')]
    [CmdletBinding()]
    param(
        [string] $Name,
        [object] $Value,
        [string] $Color,
        [ValidateSet('straight', 'smooth', 'stepline')] $Curve = 'straight',
        [int] $Width = 6,
        [ValidateSet('butt', 'square', 'round')][string] $Cap = 'butt',
        [int] $Dash = 0
    )
    if ($null -eq $Value -or $Value -eq '') {
        $Value = 0
    }
    [PSCustomObject] @{
        ObjectType = 'Line'
        Name       = $Name
        Value      = $Value
        LineColor  = $Color
        LineCurve  = $Curve
        LineWidth  = $Width
        LineCap    = $Cap
        LineDash   = $Dash
    }
}

Register-ArgumentCompleter -CommandName New-ChartLine -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartPie {
    [alias('ChartPie')]
    [CmdletBinding()]
    param(
        [string] $Name,
        [object] $Value,
        [string] $Color
    )

    if ($null -eq $Value -or $Value -eq '') {
        $Value = 0
    }
    [PSCustomObject] @{
        ObjectType = 'Pie'
        Name       = $Name
        Value      = $Value
        Color      = $Color
    }
}

Register-ArgumentCompleter -CommandName New-ChartPie -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartRadial {
    [alias('ChartRadial')]
    [CmdletBinding()]
    param(
        [string] $Name,
        [object] $Value,
        [string] $Color
    )
    if ($null -eq $Value -or $Value -eq '') {
        $Value = 0
    }
    [PSCustomObject] @{
        ObjectType = 'Radial'
        Name       = $Name
        Value      = $Value
        Color      = $Color
    }
}

Register-ArgumentCompleter -CommandName New-ChartRadial -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartSpark {
    [alias('ChartSpark')]
    [CmdletBinding()]
    param(
        [string] $Name,
        [object] $Value,
        [string] $Color
    )

    [PSCustomObject] @{
        ObjectType = 'Spark'
        Name       = $Name
        Value      = $Value
        Color      = $Color
    }
}

Register-ArgumentCompleter -CommandName New-ChartSpark -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartTheme {
    [alias('ChartTheme')]
    [CmdletBinding()]
    param(
        [ValidateSet('light', 'dark')][string] $Mode = 'light',
        [ValidateSet(
            'palette1',
            'palette2',
            'palette3',
            'palette4',
            'palette5',
            'palette6',
            'palette7',
            'palette8',
            'palette9',
            'palette10'
        )
        ][string] $Palette = 'palette1',
        [switch] $Monochrome,
        [string] $Color = "DodgerBlue",
        [ValidateSet('light', 'dark')][string] $ShadeTo = 'light',
        [double] $ShadeIntensity = 0.65
    )

    [PSCustomObject] @{
        ObjectType = 'Theme'
        Theme      = @{
            Mode           = $Mode
            Palette        = $Palette
            Monochrome     = $Monochrome.IsPresent
            Color          = $Color
            ShadeTo        = $ShadeTo
            ShadeIntensity = $ShadeIntensity
        }
    }
}

Register-ArgumentCompleter -CommandName New-ChartTheme -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartTimeLine {
    [alias('ChartTimeLine')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][string] $Name,
        [DateTime] $DateFrom,
        [DateTime] $DateTo,
        [string] $Color,
        [string] $TimeZoneOffset,
        [string] $DateFormatPattern = "yyyy-MM-dd HH:mm:ss"
        #[ValidateSet('straight', 'smooth', 'stepline')] $Curve = 'straight',
        #[int] $Width = 6,
        #[ValidateSet('butt', 'square', 'round')][string] $Cap = 'butt',
        #[int] $Dash = 0
    )

    $timezoneString = ""
    if ($TimeZoneOffset) {
        if ($TimeZoneOffset -Notlike "-*" -and $TimeZoneOffset -Notlike "+*") {
            $TimeZoneOffset = "+$TimeZoneOffset"
        }
        $timezoneString = " GMT$TimeZoneOffset"
    }

    $FormattedDateFrom = Get-Date -Date $DateFrom -Format $DateFormatPattern
    $FormattedDateTo = Get-Date -Date $DateTo -Format $DateFormatPattern

    $TimeLine = [ordered] @{
        x         = $Name
        y         = @(
            "new Date('$FormattedDateFrom$timezoneString').getTime()"
            "new Date('$FormattedDateTo$timezoneString').getTime()"
        )
        fillColor = ConvertFrom-Color -Color $Color
    }
    Remove-EmptyValue -Hashtable $TimeLine

    [PSCustomObject] @{
        ObjectType = 'TimeLine'
        TimeLine   = $TimeLine

        #LineCurve  = $Curve
        #LineWidth  = $Width
        #LineCap    = $Cap
        #LineDash   = $Dash
    }
}

Register-ArgumentCompleter -CommandName New-ChartTimeLine -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-ChartToolbar {
    [alias('ChartToolbar')]
    [CmdletBinding()]
    param(
        [switch] $Download,
        [switch] $Selection,
        [switch] $Zoom,
        [switch] $ZoomIn,
        [switch] $ZoomOut,
        [switch] $Pan,
        [switch] $Reset,
        [ValidateSet('zoom', 'selection', 'pan')][string] $AutoSelected = 'zoom'
    )

    [PSCustomObject] @{
        ObjectType = 'Toolbar'
        Toolbar    = @{
            #Show         = $Show.IsPresent
            #tools        = [ordered] @{
            download     = $Download.IsPresent
            selection    = $Selection.IsPresent
            zoom         = $Zoom.IsPresent
            zoomin       = $ZoomIn.IsPresent
            zoomout      = $ZoomOut.IsPresent
            pan          = $Pan.IsPresent
            reset        = $Reset.IsPresent
            #}
            autoSelected = $AutoSelected
        }
    }
}
function New-ChartToolTip {
    [CmdletBinding()]
    param(
        [alias('Name')][Array] $Names,
        [alias('Title')][string] $TitleText,
        [ValidateSet('datetime', 'category', 'numeric')][string] $Type = 'category',
        [object] $MinValue,
        [object] $MaxValue,
        [string] $XAxisFormatPattern, #"HH:mm:ss"
        [string] $YAxisFormatPattern = "function (seriesName) { return ''; }"

        #[ValidateSet('top', 'topRight', 'left', 'right', 'bottom', '')][string] $LegendPosition = '',
        # [string[]] $Color
    )

    [PSCustomObject] @{
        ObjectType   = 'ChartToolTip'
        ChartToolTip = @{
            enabled = $true
            y       = @{ title = @{ formatter = "$YAxisFormatPattern" } }
            x       = @{ format = "$XAxisFormatPattern" }
        }
    }
}
function New-DiagramEvent {
    [CmdletBinding()]
    param(
        #[switch] $FadeSearch,
        [string] $ID,
        [nullable[int]] $ColumnID
    )

    $Object = [PSCustomObject] @{
        Type     = 'DiagramEvent'
        Settings = @{
            # OnClick = $OnClick.IsPresent
            ID       = $ID
            # FadeSearch = $FadeSearch.IsPresent
            ColumnID = $ColumnID
        }
    }
    $Object
}
function New-DiagramLink {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER From
    Parameter description

    .PARAMETER To
    Parameter description

    .PARAMETER Label
    Parameter description

    .PARAMETER ArrowsToEnabled
    Parameter description

    .PARAMETER ArrowsToScaleFacto
    Parameter description

    .PARAMETER ArrowsToType
    Parameter description

    .PARAMETER ArrowsMiddleEnabled
    Parameter description

    .PARAMETER ArrowsMiddleScaleFactor
    Parameter description

    .PARAMETER ArrowsMiddleType
    Parameter description

    .PARAMETER ArrowsFromEnabled
    Parameter description

    .PARAMETER ArrowsFromScaleFactor
    Parameter description

    .PARAMETER ArrowsFromType
    Parameter description

    .PARAMETER ArrowStrikethrough
    Parameter description

    .PARAMETER Chosen
    Parameter description

    .PARAMETER Color
    Parameter description

    .PARAMETER ColorHighlight
    Parameter description

    .PARAMETER ColorHover
    Parameter description

    .PARAMETER ColorInherit
    Parameter description

    .PARAMETER ColorOpacity
    Parameter description

    .PARAMETER Dashes
    Parameter description

    .PARAMETER Length
    Parameter description

    .PARAMETER FontColor
    Parameter description

    .PARAMETER FontSize
    Parameter description

    .PARAMETER FontName
    Parameter description

    .PARAMETER FontBackground
    Parameter description

    .PARAMETER FontStrokeWidth
    Parameter description

    .PARAMETER FontStrokeColor
    Parameter description

    .PARAMETER FontAlign
    Possible options: 'horizontal','top','middle','bottom'.
    The alignment determines how the label is aligned over the edge.
    The default value horizontal aligns the label horizontally, regardless of the orientation of the edge.
    When an option other than horizontal is chosen, the label will align itself according to the edge.

    .PARAMETER FontMulti
    Parameter description

    .PARAMETER FontVAdjust
    Parameter description

    .PARAMETER WidthConstraint
    Parameter description

    .PARAMETER SmoothType
    Possible options: 'dynamic', 'continuous', 'discrete', 'diagonalCross', 'straightCross', 'horizontal', 'vertical', 'curvedCW', 'curvedCCW', 'cubicBezier'.
    Take a look at this example to see what these look like and pick the one that you like best! When using dynamic, the edges will have an invisible support node guiding the shape.
    This node is part of the physics simulation.

    .PARAMETER SmoothForceDirection
    Accepted options: ['horizontal', 'vertical', 'none'].
    This options is only used with the cubicBezier curves.
    When true, horizontal is chosen, when false, the direction that is larger (x distance between nodes vs y distance between nodes) is used.
    If the x distance is larger, horizontal. This is ment to be used with hierarchical layouts.

    .PARAMETER SmoothRoundness
    Accepted range: 0 .. 1.0. This parameter tweaks the roundness of the smooth curves for all types EXCEPT dynamic.

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [alias('DiagramEdge', 'DiagramEdges', 'New-DiagramEdge', 'DiagramLink')]
    [CmdletBinding()]
    param(
        [string[]] $From,
        [string[]] $To,
        [string] $Label,
        [switch] $ArrowsToEnabled,
        [nullable[int]] $ArrowsToScaleFacto,
        [ValidateSet('arrow', 'bar', 'circle')][string] $ArrowsToType,
        [switch] $ArrowsMiddleEnabled,
        [nullable[int]]$ArrowsMiddleScaleFactor,
        [ValidateSet('arrow', 'bar', 'circle')][string] $ArrowsMiddleType,
        [switch] $ArrowsFromEnabled,
        [nullable[int]] $ArrowsFromScaleFactor,
        [ValidateSet('arrow', 'bar', 'circle')][string] $ArrowsFromType,
        [switch] $ArrowStrikethrough,
        [switch] $Chosen,
        [string] $Color,
        [string] $ColorHighlight,
        [string] $ColorHover,
        [ValidateSet('true', 'false', 'from', 'to', 'both')][string]$ColorInherit,
        [nullable[double]] $ColorOpacity, # range between 0 and 1
        [switch] $Dashes,
        [string] $Length,
        [string] $FontColor,
        [object] $FontSize,
        [string] $FontName,
        [string] $FontBackground,
        [object] $FontStrokeWidth, #// px
        [string] $FontStrokeColor,
        [ValidateSet('horizontal', 'top', 'middle', 'bottom')][string] $FontAlign,
        [ValidateSet('false', 'true', 'markdown', 'html')][string]$FontMulti,
        [nullable[int]] $FontVAdjust,
        [nullable[int]] $WidthConstraint,

        [ValidateSet('dynamic', 'continuous', 'discrete', 'diagonalCross', 'straightCross', 'horizontal', 'vertical', 'curvedCW', 'curvedCCW', 'cubicBezier')][string] $SmoothType,
        [ValidateSet('horizontal', 'vertical', 'none')][string] $SmoothForceDirection,
        [string] $SmoothRoundness
    )
    $Object = [PSCustomObject] @{
        Type     = 'DiagramLink'
        Settings = @{
            from = $From
            to   = $To
        }
        Edges    = @{
            label              = $Label
            length             = $Length
            arrows             = [ordered]@{
                to     = [ordered]@{
                    enabled     = if ($ArrowsToEnabled) { $ArrowsToEnabled.IsPresent } else { $null }
                    scaleFactor = $ArrowsToScaleFactor
                    type        = $ArrowsToType
                }
                middle = [ordered]@{
                    enabled     = if ($ArrowsMiddleEnabled) { $ArrowsMiddleEnabled.IsPresent } else { $null }
                    scaleFactor = $ArrowsMiddleScaleFactor
                    type        = $ArrowsMiddleType
                }
                from   = [ordered]@{
                    enabled     = if ($ArrowsFromEnabled) { $ArrowsFromEnabled.IsPresent } else { $null }
                    scaleFactor = $ArrowsFromScaleFactor
                    type        = $ArrowsFromType
                }
            }
            arrowStrikethrough = if ($ArrowStrikethrough) { $ArrowStrikethrough.IsPresent } else { $null }
            chosen             = if ($Chosen) { $Chosen.IsPresent } else { $null }
            color              = [ordered]@{
                color     = ConvertFrom-Color -Color $Color
                highlight = ConvertFrom-Color -Color $ColorHighlight
                hover     = ConvertFrom-Color -Color $ColorHover
                inherit   = $ColorInherit
                opacity   = $ColorOpacity
            }
            font               = [ordered]@{
                color       = ConvertFrom-Color -Color $FontColor
                size        = ConvertFrom-Size -Size $FontSize
                face        = $FontName
                background  = ConvertFrom-Color -Color $FontBackground
                strokeWidth = ConvertFrom-Size -Size $FontStrokeWidth
                strokeColor = ConvertFrom-Color -Color $FontStrokeColor
                align       = $FontAlign
                multi       = $FontMulti
                vadjust     = $FontVAdjust
            }
            dashes             = if ($Dashes) { $Dashes.IsPresent } else { $null }
            widthConstraint    = $WidthConstraint
        }
    }
    if ($SmoothType -or $SmoothRoundness -or $SmoothForceDirection) {
        $Object.Edges['smooth'] = @{
            'enabled' = $true
        }
        if ($SmoothType) {
            $Object.Edges['smooth']['type'] = $SmoothType
        }
        if ($SmoothRoundness -ne '') {
            $Object.Edges['smooth']['roundness'] = $SmoothRoundness
        }
        if ($SmoothForceDirection) {
            $Object.Edges['smooth']['forceDirection'] = $SmoothForceDirection
        }
    }

    Remove-EmptyValue -Hashtable $Object.Settings -Recursive
    Remove-EmptyValue -Hashtable $Object.Edges -Recursive -Rerun 2
    $Object
}
Register-ArgumentCompleter -CommandName New-DiagramLink -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramLink -ParameterName ColorHighlight -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramLink -ParameterName ColorHover -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramLink -ParameterName FontColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramLink -ParameterName FontBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramLink -ParameterName FontStrokeColor -ScriptBlock $Script:ScriptBlockColors

<#
  // these are all options in full.
  var options = {
    edges:{
      arrows: {
        to:     {enabled: false, scaleFactor:1, type:'arrow'},
        middle: {enabled: false, scaleFactor:1, type:'arrow'},
        from:   {enabled: false, scaleFactor:1, type:'arrow'}
      },
      arrowStrikethrough: true,
      chosen: true,
      color: {
        color:'#848484',
        highlight:'#848484',
        hover: '#848484',
        inherit: 'from',
        opacity:1.0
      },
      dashes: false,
      font: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        background: 'none',
        strokeWidth: 2, // px
        strokeColor: '#ffffff',
        align: 'horizontal',
        multi: false,
        vadjust: 0,
        bold: {
          color: '#343434',
          size: 14, // px
          face: 'arial',
          vadjust: 0,
          mod: 'bold'
        },
        ital: {
          color: '#343434',
          size: 14, // px
          face: 'arial',
          vadjust: 0,
          mod: 'italic',
        },
        boldital: {
          color: '#343434',
          size: 14, // px
          face: 'arial',
          vadjust: 0,
          mod: 'bold italic'
        },
        mono: {
          color: '#343434',
          size: 15, // px
          face: 'courier new',
          vadjust: 2,
          mod: ''
        }
      },
      hidden: false,
      hoverWidth: 1.5,
      label: undefined,
      labelHighlightBold: true,
      length: undefined,
      physics: true,
      scaling:{
        min: 1,
        max: 15,
        label: {
          enabled: true,
          min: 14,
          max: 30,
          maxVisible: 30,
          drawThreshold: 5
        },
        customScalingFunction: function (min,max,total,value) {
          if (max === min) {
            return 0.5;
          }
          else {
            var scale = 1 / (max - min);
            return Math.max(0,(value - min)*scale);
          }
        }
      },
      selectionWidth: 1,
      selfReferenceSize:20,
      shadow:{
        enabled: false,
        color: 'rgba(0,0,0,0.5)',
        size:10,
        x:5,
        y:5
      },
      smooth: {
        enabled: true,
        type: "dynamic",
        roundness: 0.5
      },
      title:undefined,
      value: undefined,
      width: 1,
      widthConstraint: false
    }
  }

  network.setOptions(options);
  #>
function New-DiagramNode {
    <#
    .SYNOPSIS
    Creates nodes on a diagram

    .DESCRIPTION
    Creates nodes on a diagram

    .PARAMETER HtmlTextBox
    Experimental TextBox to put HTML instead of Image using SVG

    .PARAMETER Id
    Id of a node. If not set, label will be used as Id.

    .PARAMETER Label
    Label for a diagram

    .PARAMETER Title
    Label that shows up when hovering over node

    .PARAMETER To
    Parameter description

    .PARAMETER ArrowsToEnabled
    Parameter description

    .PARAMETER ArrowsMiddleEnabled
    Parameter description

    .PARAMETER ArrowsFromEnabled
    Parameter description

    .PARAMETER LinkColor
    Parameter description

    .PARAMETER Shape
    Parameter description

    .PARAMETER ImageType
    Parameter description

    .PARAMETER Image
    Parameter description

    .PARAMETER BorderWidth
    Parameter description

    .PARAMETER BorderWidthSelected
    Parameter description

    .PARAMETER BrokenImages
    Parameter description

    .PARAMETER Chosen
    Parameter description

    .PARAMETER ColorBorder
    Parameter description

    .PARAMETER ColorBackground
    Parameter description

    .PARAMETER ColorHighlightBorder
    Parameter description

    .PARAMETER ColorHighlightBackground
    Parameter description

    .PARAMETER ColorHoverBorder
    Parameter description

    .PARAMETER ColorHoverBackground
    Parameter description

    .PARAMETER FixedX
    Parameter description

    .PARAMETER FixedY
    Parameter description

    .PARAMETER FontColor
    Color of the label text.

    .PARAMETER FontSize
    Size of the label text.

    .PARAMETER FontName
    Font face (or font family) of the label text.

    .PARAMETER FontBackground
    When not undefined but a color string, a background rectangle will be drawn behind the label in the supplied color.

    .PARAMETER FontStrokeWidth
    As an alternative to the background rectangle, a stroke can be drawn around the text. When a value higher than 0 is supplied, the stroke will be draw

    .PARAMETER FontStrokeColor
    This is the color of the stroke assuming the value for stroke is higher than 0.

    .PARAMETER FontAlign
    This can be set to 'left' to make the label left-aligned. Otherwise, defaults to 'center'.

    .PARAMETER FontMulti
    If false, the label is treated as pure text drawn with the base font.
    If true or 'html' the label may be multifonted, with bold, italic and code markup, interpreted as html.
    If the value is 'markdown' or 'md' the label may be multifonted, with bold, italic and code markup, interpreted as markdown.
    The bold, italic, bold-italic and monospaced fonts may be set up under in the font.bold, font.ital, font.boldital and font.mono properties, respectively.

    .PARAMETER FontVAdjust
    Parameter description

    .PARAMETER Size
    The size is used to determine the size of node shapes that do not have the label inside of them.
    These shapes are: image, circularImage, diamond, dot, star, triangle, triangleDown, hexagon, square and icon

    .PARAMETER X
    Parameter description

    .PARAMETER Y
    Parameter description

    .PARAMETER IconAsImage
    Parameter description

    .PARAMETER IconColor
    Parameter description

    .PARAMETER IconBrands
    Parameter description

    .PARAMETER IconRegular
    Parameter description

    .PARAMETER IconSolid
    Parameter description

    .PARAMETER Level
    Parameter description

    .PARAMETER HeightConstraintMinimum
    Parameter description

    .PARAMETER HeightConstraintVAlign
    Parameter description

    .PARAMETER WidthConstraintMinimum
    Parameter description

    .PARAMETER WidthConstraintMaximum
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [alias('DiagramNode')]
    [CmdLetBinding(DefaultParameterSetName = 'Shape')]
    param(
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][ScriptBlock] $HtmlTextBox,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $Id,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")] [string] $Label,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")] [string] $Title,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string[]] $To,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")]
        [switch] $ArrowsToEnabled,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")]
        [switch] $ArrowsMiddleEnabled,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")]
        [switch] $ArrowsFromEnabled,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")]
        [alias('EdgeColor')][string] $LinkColor,
        [parameter(ParameterSetName = "Shape")][string][ValidateSet(
            'circle', 'dot', 'diamond', 'ellipse', 'database', 'box', 'square', 'triangle', 'triangleDown', 'text', 'star', 'hexagon')] $Shape,
        [parameter(ParameterSetName = "Image")][ValidateSet('squareImage', 'circularImage')][string] $ImageType,
        [parameter(ParameterSetName = "Image")][uri] $Image,
        #[string] $BrokenImage,
        #[string] $ImagePadding,
        #[string] $ImagePaddingLeft,
        #[string] $ImagePaddingRight,
        #[string] $ImagePaddingTop,
        #[string] $ImagePaddingBottom,
        #[string] $UseImageSize,
        #[alias('BackgroundColor')][string] $Color,
        #[string] $Border,
        #[string] $HighlightBackground,
        #[string] $HighlightBorder,
        #[string] $HoverBackground,
        #[string] $HoverBorder,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $BorderWidth,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $BorderWidthSelected,
        [parameter(ParameterSetName = "Image")][string] $BrokenImages,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[bool]] $Chosen,
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $ColorBorder,
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $ColorBackground,
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $ColorHighlightBorder,
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $ColorHighlightBackground,
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $ColorHoverBorder,
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $ColorHoverBackground,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[bool]]$FixedX,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[bool]]$FixedY,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $FontColor,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $FontSize, #// px
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $FontName,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $FontBackground,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $FontStrokeWidth, #// px
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][string] $FontStrokeColor,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][ValidateSet('center', 'left')][string] $FontAlign,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][ValidateSet('false', 'true', 'markdown', 'html')][string]$FontMulti,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $FontVAdjust,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $Size,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $X,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $Y,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][switch] $IconAsImage,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $IconColor,
        # ICON BRANDS
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeBrands.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeBrands.Keys))
            }
        )]
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [string] $IconBrands,

        # ICON REGULAR
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeRegular.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeRegular.Keys))
            }
        )]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [string] $IconRegular,

        # ICON SOLID
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeSolid.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeSolid.Keys))
            }
        )]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [string] $IconSolid,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $Level,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $HeightConstraintMinimum,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][ValidateSet('top', 'middle', 'bottom')][string] $HeightConstraintVAlign,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $WidthConstraintMinimum,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [parameter(ParameterSetName = "Image")]
        [parameter(ParameterSetName = "Shape")][nullable[int]] $WidthConstraintMaximum
    )

    if (-not $Label) {
        Write-Warning 'New-DiagramNode - Label is required. Skipping node.'
        return
    }

    $Object = [PSCustomObject] @{
        Type     = 'DiagramNode'
        Settings = @{ }
        Edges    = @{ }
    }
    $Icon = @{ } # Reset value, just in case

    # If ID is not defined use label
    if (-not $ID) {
        $ID = $Label
    }

    if ($IconBrands -or $IconRegular -or $IconSolid) {
        $Script:HTMLSchema.Features.FontsAwesome = $true
        if ($IconBrands) {
            if (-not $IconAsImage) {
                # Workaround using image for Fonts
                # https://use.fontawesome.com/releases/v5.11.2/svgs/brands/accessible-icon.svg
                <# Until all Icons work, using images instead. Currently only Brands work fine / Solid/Regular is weird #>
                $NodeShape = 'icon'
                $icon = @{
                    face   = '"Font Awesome 5 Brands"'
                    code   = -join ('\u', $Global:HTMLIcons.FontAwesomeBrands[$IconBrands])    # "\uf007"
                    color  = ConvertFrom-Color -Color $IconColor
                    weight = 'bold'
                }
            } else {
                $NodeShape = 'image'
                $Image = -join ($Script:CurrentConfiguration.Features.FontsAwesome.Other.Link, 'brands/', $IconBrands, '.svg')
            }
        } elseif ($IconRegular) {
            if (-not $IconAsImage) {
                $NodeShape = 'icon'
                $icon = @{
                    face   = '"Font Awesome 5 Free"'
                    code   = -join ('\u', $Global:HTMLIcons.FontAwesomeRegular[$IconRegular])    # "\uf007"
                    color  = ConvertFrom-Color -Color $IconColor
                    weight = 'bold'
                }
            } else {
                $NodeShape = 'image'
                $Image = -join ($Script:CurrentConfiguration.Features.FontsAwesome.Other.Link, 'regular/', $IconRegular, '.svg')
            }
        } else {
            if (-not $IconAsImage) {
                $NodeShape = 'icon'
                $icon = @{
                    face   = '"Font Awesome 5 Free"'
                    code   = -join ('\u', $Global:HTMLIcons.FontAwesomeSolid[$IconSolid])    # "\uf007"
                    color  = ConvertFrom-Color -Color $IconColor
                    weight = 'bold'
                }
            } else {
                $NodeShape = 'image'
                $Image = -join ($Script:CurrentConfiguration.Features.FontsAwesome.Other.Link, 'solid/', $IconSolid, '.svg')
            }
        }
    } elseif ($Image) {
        if ($ImageType -eq 'squareImage') {
            $NodeShape = 'image'
        } else {
            $NodeShape = 'circularImage'
        }
    } elseif ($HtmlTextBox) {
        $OutputSVG = New-HTMLTag -Tag 'svg' -Attributes @{ xmlns = 'http://www.w3.org/2000/svg'; width = '390' ; height = '70' } {
            #New-HTMLTag -Tag 'rect' -Attributes @{ x = "0"; y = "0"; width = "100%"; height = "100%"; fill = "#7890A7"; 'stroke-width' = "20"; stroke = "#ffffff"; }
            New-HTMLTag -Tag 'foreignObject' -Attributes @{x = "15"; y = "10"; width = "100%"; height = "100%"; } {
                New-HTMLTag -Tag 'div' -Attributes @{ xmlns = 'http://www.w3.org/1999/xhtml' } {
                    & $HtmlTextBox
                }
            }
        }
        $Image = ConvertTo-SVG -FileType 'svg+xml' -Content $OutputSVG
        $NodeShape = 'image'
    } else {
        $NodeShape = $Shape
    }

    if ($To) {
        $Object.Edges = [ordered] @{
            arrows = [ordered]@{
                to     = [ordered]@{
                    enabled = if ($ArrowsToEnabled) { $ArrowsToEnabled.IsPresent } else { $null }
                }
                middle = [ordered]@{
                    enabled = if ($ArrowsMiddleEnabled) { $ArrowsMiddleEnabled.IsPresent } else { $null }
                }
                from   = [ordered]@{
                    enabled = if ($ArrowsFromEnabled) { $ArrowsFromEnabled.IsPresent } else { $null }
                }
            }
            color  = [ordered]@{
                color = ConvertFrom-Color -Color $LinkColor
            }
            from   = if ($To) { $Id } else { '' }
            to     = if ($To) { $To } else { '' }
        }
    }
    $Object.Settings = [ordered] @{
        id                  = $Id
        label               = $Label
        title               = $Title
        shape               = $NodeShape

        image               = $Image
        icon                = $icon

        level               = $Level


        borderWidth         = $BorderWidth
        borderWidthSelected = $BorderWidthSelected
        brokenImage         = $BrokenImage

        chosen              = $Chosen
        color               = [ordered]@{
            border     = ConvertFrom-Color -Color $ColorBorder
            background = ConvertFrom-Color -Color $ColorBackground
            highlight  = [ordered]@{
                border     = ConvertFrom-Color -Color $ColorHighlightBorder
                background = ConvertFrom-Color -Color $ColorHighlightBackground
            }
            hover      = [ordered]@{
                border     = ConvertFrom-Color -Color $ColorHoverBorder
                background = ConvertFrom-Color -Color $ColorHoverBackground
            }
        }
        fixed               = [ordered]@{
            x = $FixedX
            y = $FixedY
        }
        font                = [ordered]@{
            color       = ConvertFrom-Color -Color $FontColor
            size        = $FontSize
            face        = $FontName
            background  = ConvertFrom-Color -Color $FontBackground
            strokeWidth = $FontStrokeWidth
            strokeColor = ConvertFrom-Color -Color $FontStrokeColor
            align       = $FontAlign
            multi       = $FontMulti
            vadjust     = $FontVAdjust
        }
        size                = $Size
        heightConstraint    = @{
            minimum = $HeightConstraintMinimum
            valign  = $HeightConstraintVAlign
        }
        widthConstraint     = @{
            minimum = $WidthConstraintMinimum
            maximum = $WidthConstraintMaximum
        }
        x                   = $X
        y                   = $Y
    }

    Remove-EmptyValue -Hashtable $Object.Settings -Recursive -Rerun 2
    Remove-EmptyValue -Hashtable $Object.Edges -Recursive -Rerun 2
    $Object
}
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName ColorBorder -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName ColorBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName ColorHighlightBorder -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName ColorHighlightBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName ColorHoverBorder -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName ColorHoverBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName FontColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName FontBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName FontStrokeColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName IconColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramNode -ParameterName LinkColor -ScriptBlock $Script:ScriptBlockColors
<#
// these are all options in full.
var options = {
  nodes:{
    borderWidth: 1,
    borderWidthSelected: 2,
    brokenImage:undefined,
    chosen: true,
    color: {
      border: '#2B7CE9',
      background: '#97C2FC',
      highlight: {
        border: '#2B7CE9',
        background: '#D2E5FF'
      },
      hover: {
        border: '#2B7CE9',
        background: '#D2E5FF'
      }
    },
    fixed: {
      x:false,
      y:false
    },
    font: {
      color: '#343434',
      size: 14, // px
      face: 'arial',
      background: 'none',
      strokeWidth: 0, // px
      strokeColor: '#ffffff',
      align: 'center',
      multi: false,
      vadjust: 0,
      bold: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'bold'
      },
      ital: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'italic',
      },
      boldital: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'bold italic'
      },
      mono: {
        color: '#343434',
        size: 15, // px
        face: 'courier new',
        vadjust: 2,
        mod: ''
      }
    },
    group: undefined,
    heightConstraint: false,
    hidden: false,
    icon: {
      face: 'FontAwesome',
      code: undefined,
      size: 50,  //50,
      color:'#2B7CE9'
    },
    image: undefined,
    imagePadding: {
      left: 0,
      top: 0,
      bottom: 0,
      right: 0
    },
    label: undefined,
    labelHighlightBold: true,
    level: undefined,
    mass: 1,
    physics: true,
    scaling: {
      min: 10,
      max: 30,
      label: {
        enabled: false,
        min: 14,
        max: 30,
        maxVisible: 30,
        drawThreshold: 5
      },
      customScalingFunction: function (min,max,total,value) {
        if (max === min) {
          return 0.5;
        }
        else {
          let scale = 1 / (max - min);
          return Math.max(0,(value - min)*scale);
        }
      }
    },
    shadow:{
      enabled: false,
      color: 'rgba(0,0,0,0.5)',
      size:10,
      x:5,
      y:5
    },
    shape: 'ellipse',
    shapeProperties: {
      borderDashes: false, // only for borders
      borderRadius: 6,     // only for box shape
      interpolation: false,  // only for image and circularImage shapes
      useImageSize: false,  // only for image and circularImage shapes
      useBorderWithImage: false  // only for image shape
    }
    size: 25,
    title: undefined,
    value: undefined,
    widthConstraint: false,
    x: undefined,
    y: undefined
  }
}

network.setOptions(options)
#>
function New-DiagramOptionsInteraction {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER DragNodes
    Parameter description

    .PARAMETER DragView
    Parameter description

    .PARAMETER HideEdgesOnDrag
    Parameter description

    .PARAMETER HideEdgesOnZoom
    Parameter description

    .PARAMETER HideNodesOnDrag
    Parameter description

    .PARAMETER Hover
    Parameter description

    .PARAMETER HoverConnectedEdges
    Parameter description

    .PARAMETER KeyboardEnabled
    Parameter description

    .PARAMETER KeyboardSpeedX
    Parameter description

    .PARAMETER KeyboardSpeedY
    Parameter description

    .PARAMETER KeyboardSpeedZoom
    Parameter description

    .PARAMETER KeyboardBindToWindow
    Parameter description

    .PARAMETER Multiselect
    Parameter description

    .PARAMETER NavigationButtons
    Parameter description

    .PARAMETER Selectable
    Parameter description

    .PARAMETER SelectConnectedEdges
    Parameter description

    .PARAMETER TooltipDelay
    Parameter description

    .PARAMETER ZoomView
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    Based on options https://visjs.github.io/vis-network/docs/network/interaction.html#

    #>
    [alias('DiagramOptionsInteraction')]
    [CmdletBinding()]
    param(
        [nullable[bool]] $DragNodes,
        [nullable[bool]] $DragView,
        [nullable[bool]] $HideEdgesOnDrag,
        [nullable[bool]] $HideEdgesOnZoom,
        [nullable[bool]] $HideNodesOnDrag,
        [nullable[bool]] $Hover,
        [nullable[bool]] $HoverConnectedEdges,
        [nullable[bool]] $KeyboardEnabled,
        [nullable[int]] $KeyboardSpeedX,
        [nullable[int]] $KeyboardSpeedY,
        [nullable[decimal]] $KeyboardSpeedZoom,
        [nullable[bool]] $KeyboardBindToWindow,
        [nullable[bool]] $Multiselect,
        [nullable[bool]] $NavigationButtons,
        [nullable[bool]] $Selectable,
        [nullable[bool]] $SelectConnectedEdges,
        [nullable[int]] $TooltipDelay,
        [nullable[bool]] $ZoomView
    )

    $Object = [PSCustomObject] @{
        Type     = 'DiagramOptionsInteraction'
        Settings = @{
            interaction = [ordered] @{
                dragNodes            = $DragNodes
                dragView             = $DragView
                hideEdgesOnDrag      = $HideEdgesOnDrag
                hideEdgesOnZoom      = $HideEdgesOnZoom
                hideNodesOnDrag      = $HideNodesOnDrag
                hover                = $Hover
                hoverConnectedEdges  = $HoverConnectedEdges
                keyboard             = @{
                    enabled      = $KeyboardEnabled
                    speed        = @{
                        x    = $KeyboardSpeedX
                        y    = $KeyboardSpeedY
                        zoom = $KeyboardSpeedZoom
                    }
                    bindToWindow = $KeyboardBindToWindow
                }
                multiselect          = $Multiselect
                navigationButtons    = $NavigationButtons
                selectable           = $Selectable
                selectConnectedEdges = $SelectConnectedEdges
                tooltipDelay         = $TooltipDelay
                zoomView             = $ZoomView
            }
        }
    }
    Remove-EmptyValue -Hashtable $Object.Settings -Recursive -Rerun 2
    $Object
}
<#
    var options = {
        nodes: {
          borderWidth:2,
          borderWidthSelected: 8,
          size:24,
          color: {
            border: 'white',
            background: 'black',
            highlight: {
              border: 'black',
              background: 'white'
            },
            hover: {
              border: 'orange',
              background: 'grey'
            }
          },
          font:{color:'#eeeeee'},
          shapeProperties: {
            useBorderWithImage:true
          }
        },
        edges: {
          color: 'lightgray'
        }
      };
    #>


# https://visjs.github.io/vis-network/docs/network/edges.html#
function New-DiagramOptionsLayout {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    When enabling the hierarchical layout, it overrules some of the other options.
    The physics is set to the hierarchical repulsion solver and dynamic smooth edges are converted to static smooth edges.

    .PARAMETER RandomSeed
    When NOT using the hierarchical layout, the nodes are randomly positioned initially. This means that the settled result is different every time. If you provide a random seed manually, the layout will be the same every time. Ideally you try with an undefined seed, reload until you are happy with the layout and use the getSeed() method to ascertain the seed.

    .PARAMETER ImprovedLayout
    When enabled, the network will use the Kamada Kawai algorithm for initial layout. For networks larger than 100 nodes, clustering will be performed automatically to reduce the amount of nodes. This can greatly improve the stabilization times. If the network is very interconnected (no or few leaf nodes), this may not work and it will revert back to the old method. Performance will be improved in the future.

    .PARAMETER ClusterThreshold
    Cluster threshold to which improvedLayout applies.

    .PARAMETER HierarchicalEnabled
    When true, the layout engine positions the nodes in a hierarchical fashion using default settings.
    Toggle the usage of the hierarchical layout system. If this option is not defined, it is set to true if any of the properties in this object are defined.

    .PARAMETER HierarchicalLevelSeparation
    The distance between the different levels.

    .PARAMETER HierarchicalNodeSpacing
    Minimum distance between nodes on the free axis. This is only for the initial layout. If you enable physics, the node distance there will be the effective node distance.

    .PARAMETER HierarchicalTreeSpacing
    Distance between different trees (independent networks). This is only for the initial layout. If you enable physics, the repulsion model will denote the distance between the trees.

    .PARAMETER HierarchicalBlockShifting
    Method for reducing whitespace. Can be used alone or together with edge minimization. Each node will check for whitespace and will shift it's branch along with it for as far as it can, respecting the nodeSpacing on any level. This is mainly for the initial layout. If you enable physics, the layout will be determined by the physics. This will greatly speed up the stabilization time though!

    .PARAMETER HierarchicalEdgeMinimization
    Method for reducing whitespace. Can be used alone or together with block shifting. Enabling block shifting will usually speed up the layout process. Each node will try to move along its free axis to reduce the total length of it's edges. This is mainly for the initial layout. If you enable physics, the layout will be determined by the physics. This will greatly speed up the stabilization time though!

    .PARAMETER HierarchicalParentCentralization
    When true, the parents nodes will be centered again after the layout algorithm has been finished.

    .PARAMETER HierarchicalDirection
    The direction of the hierarchical layout. The available options are: UD, DU, LR, RL. To simplify: up-down, down-up, left-right, right-left.

    .PARAMETER HierarchicalSortMethod
    The algorithm used to ascertain the levels of the nodes based on the data. The possible options are: hubsize, directed.
    Hubsize takes the nodes with the most edges and puts them at the top. From that the rest of the hierarchy is evaluated.
    Directed adheres to the to and from data of the edges. A --> B so B is a level lower than A.

    .PARAMETER HierarchicalShakeTowards
    Controls whether in directed layout should all the roots be lined up at the top and their child nodes as close to their roots as possible (roots) or all the leaves lined up at the bottom and their parents as close to their children as possible (leaves, default).

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [alias('DiagramOptionsLayout')]
    [CmdletBinding()]
    param(
        [nullable[int]] $RandomSeed,
        [nullable[bool]] $ImprovedLayout,
        [nullable[int]] $ClusterThreshold ,
        [nullable[bool]] $HierarchicalEnabled,
        [nullable[int]] $HierarchicalLevelSeparation,
        [nullable[int]] $HierarchicalNodeSpacing,
        [nullable[int]] $HierarchicalTreeSpacing,
        [nullable[bool]] $HierarchicalBlockShifting,
        [nullable[bool]] $HierarchicalEdgeMinimization,
        [nullable[bool]] $HierarchicalParentCentralization,
        [ValidateSet('FromUpToDown', 'FromDownToUp', 'FromLeftToRight', 'FromRigthToLeft')][string] $HierarchicalDirection,
        [ValidateSet('hubsize', 'directed')][string] $HierarchicalSortMethod,
        [ValidateSet('roots', 'leaves')][string] $HierarchicalShakeTowards
    )
    $Direction = @{
        FromUpToDown    = 'UD'
        FromDownToUp    = 'DU'
        FromLeftToRight = 'LR'
        FromRigthToLeft = 'RL'
    }

    $Object = [PSCustomObject] @{
        Type     = 'DiagramOptionsLayout'
        Settings = [ordered] @{
            layout = [ordered] @{
                randomSeed       = $RandomSeed
                improvedLayout   = $ImprovedLayout
                clusterThreshold = $ClusterThreshold
                hierarchical     = [ordered]@{
                    enabled              = $HierarchicalEnabled
                    levelSeparation      = $HierarchicalLevelSeparation
                    nodeSpacing          = $HierarchicalNodeSpacing
                    treeSpacing          = $HierarchicalTreeSpacing
                    blockShifting        = $HierarchicalBlockShifting
                    edgeMinimization     = $HierarchicalEdgeMinimization
                    parentCentralization = $HierarchicalParentCentralization
                    direction            = $Direction[$HierarchicalDirection] # // UD, DU, LR, RL
                    sortMethod           = $HierarchicalSortMethod #// hubsize, directed
                    shakeTowards         = $HierarchicalShakeTowards
                }
            }
        }
    }
    Remove-EmptyValue -Hashtable $Object.Settings -Recursive -Rerun 2
    $Object
}

<#
// these are all options in full.
var options = {
  layout =  {
    randomSeed =  undefined,
    improvedLayout = true,
    clusterThreshold =  150,
    hierarchical =  {
      enabled = false,
      levelSeparation =  150,
      nodeSpacing =  100,
      treeSpacing =  200,
      blockShifting =  true,
      edgeMinimization =  true,
      parentCentralization =  true,
      direction =  'UD',        // UD, DU, LR, RL
      sortMethod =  'hubsize'   // hubsize, directed
    }
  }
}

network.setOptions(options);
#>
function New-DiagramOptionsLinks {
    [alias('DiagramOptionsEdges', 'New-DiagramOptionsEdges', 'DiagramOptionsLinks')]
    [CmdletBinding()]
    param(
        [nullable[bool]] $ArrowsToEnabled,
        [nullable[int]] $ArrowsToScaleFactor,
        [ValidateSet('arrow', 'bar', 'circle')][string] $ArrowsToType,
        [nullable[bool]] $ArrowsMiddleEnabled,
        [nullable[int]] $ArrowsMiddleScaleFactor,
        [ValidateSet('arrow', 'bar', 'circle')][string] $ArrowsMiddleType,
        [nullable[bool]] $ArrowsFromEnabled,
        [nullable[int]] $ArrowsFromScaleFactor,
        [ValidateSet('arrow', 'bar', 'circle')][string] $ArrowsFromType,
        [nullable[bool]] $ArrowStrikethrough,
        [nullable[bool]] $Chosen,
        [string] $Color,
        [string] $ColorHighlight,
        [string] $ColorHover,
        [ValidateSet('true', 'false', 'from', 'to', 'both')][string]$ColorInherit,
        [nullable[double]] $ColorOpacity, # range between 0 and 1
        [nullable[bool]]  $Dashes,
        [string] $Length,
        [string] $FontColor,
        [nullable[int]] $FontSize, #// px
        [string] $FontName,
        [string] $FontBackground,
        [nullable[int]] $FontStrokeWidth, #// px
        [string] $FontStrokeColor,
        [ValidateSet('center', 'left')][string] $FontAlign,
        [ValidateSet('false', 'true', 'markdown', 'html')][string]$FontMulti,
        [nullable[int]] $FontVAdjust,
        [nullable[int]] $WidthConstraint
    )
    $Object = [PSCustomObject] @{
        Type     = 'DiagramOptionsEdges'
        Settings = @{
            edges = [ordered] @{
                #length             = $Length
                arrows             = [ordered]@{
                    to     = [ordered]@{
                        enabled     = $ArrowsToEnabled
                        scaleFactor = $ArrowsToScaleFactor
                        type        = $ArrowsToType
                    }
                    middle = [ordered]@{
                        enabled     = $ArrowsMiddleEnabled
                        scaleFactor = $ArrowsMiddleScaleFactor
                        type        = $ArrowsMiddleType
                    }
                    from   = [ordered]@{
                        enabled     = $ArrowsFromEnabled
                        scaleFactor = $ArrowsFromScaleFactor
                        type        = $ArrowsFromType
                    }
                }
                arrowStrikethrough = $ArrowStrikethrough
                chosen             = $Chosen
                color              = [ordered]@{
                    color     = ConvertFrom-Color -Color $Color
                    highlight = ConvertFrom-Color -Color $ColorHighlight
                    hover     = ConvertFrom-Color -Color $ColorHover
                    inherit   = $ColorInherit
                    opacity   = $ColorOpacity
                }
                font               = [ordered]@{
                    color       = ConvertFrom-Color -Color $FontColor
                    size        = $FontSize
                    face        = $FontName
                    background  = ConvertFrom-Color -Color $FontBackground
                    strokeWidth = $FontStrokeWidth
                    strokeColor = ConvertFrom-Color -Color $FontStrokeColor
                    align       = $FontAlign
                    multi       = $FontMulti
                    vadjust     = $FontVAdjust
                }
                dashes             = $Dashes
                widthConstraint    = $WidthConstraint
            }
        }
    }
    Remove-EmptyValue -Hashtable $Object.Settings -Recursive -Rerun 2
    $Object
}
Register-ArgumentCompleter -CommandName New-DiagramOptionsLinks -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsLinks -ParameterName ColorHighlight -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsLinks -ParameterName ColorHover -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsLinks -ParameterName FontColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsLinks -ParameterName FontBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsLinks -ParameterName FontStrokeColor -ScriptBlock $Script:ScriptBlockColors
<#
// these are all options in full.
var options = {
  edges:{
    arrows: {
      to:     {enabled: false, scaleFactor:1, type:'arrow'},
      middle: {enabled: false, scaleFactor:1, type:'arrow'},
      from:   {enabled: false, scaleFactor:1, type:'arrow'}
    },
    arrowStrikethrough: true,
    chosen: true,
    color: {
      color:'#848484',
      highlight:'#848484',
      hover: '#848484',
      inherit: 'from',
      opacity:1.0
    },
    dashes: false,
    font: {
      color: '#343434',
      size: 14, // px
      face: 'arial',
      background: 'none',
      strokeWidth: 2, // px
      strokeColor: '#ffffff',
      align: 'horizontal',
      multi: false,
      vadjust: 0,
      bold: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'bold'
      },
      ital: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'italic',
      },
      boldital: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'bold italic'
      },
      mono: {
        color: '#343434',
        size: 15, // px
        face: 'courier new',
        vadjust: 2,
        mod: ''
      }
    },
    hidden: false,
    hoverWidth: 1.5,
    label: undefined,
    labelHighlightBold: true,
    length: undefined,
    physics: true,
    scaling:{
      min: 1,
      max: 15,
      label: {
        enabled: true,
        min: 14,
        max: 30,
        maxVisible: 30,
        drawThreshold: 5
      },
      customScalingFunction: function (min,max,total,value) {
        if (max === min) {
          return 0.5;
        }
        else {
          var scale = 1 / (max - min);
          return Math.max(0,(value - min)*scale);
        }
      }
    },
    selectionWidth: 1,
    selfReferenceSize:20,
    shadow:{
      enabled: false,
      color: 'rgba(0,0,0,0.5)',
      size:10,
      x:5,
      y:5
    },
    smooth: {
      enabled: true,
      type: "dynamic",
      roundness: 0.5
    },
    title:undefined,
    value: undefined,
    width: 1,
    widthConstraint: false
  }
}

network.setOptions(options);
#>
function New-DiagramOptionsManipulation {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER InitiallyActive
    Parameter description

    .PARAMETER AddNode
    Parameter description

    .PARAMETER AddEdge
    Parameter description

    .PARAMETER EditNode
    Parameter description

    .PARAMETER EditEdge
    Parameter description

    .PARAMETER DeleteNode
    Parameter description

    .PARAMETER DeleteEdge
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    Based on https://visjs.github.io/vis-network/docs/network/manipulation.html#
    It's incomplete

    #>

    [alias('DiagramOptionsManipulation')]
    [CmdletBinding()]
    param(
        [nullable[bool]] $InitiallyActive,
        [nullable[bool]] $AddNode,
        [nullable[bool]] $AddEdge,
        [nullable[bool]] $EditNode,
        [nullable[bool]] $EditEdge,
        [nullable[bool]] $DeleteNode,
        [nullable[bool]] $DeleteEdge
    )

    $Object = [PSCustomObject] @{
        Type     = 'DiagramOptionsManipulation'
        Settings = @{
            manipulation = [ordered] @{
                enabled         = $true
                initiallyActive = $InitiallyActive
                addNode         = $AddNode
                addEdge         = $AddEdge
                editNode        = $EditNode
                editEdge        = $EditEdge
                deleteNode      = $DeleteNode
                deleteEdge      = $DeleteEdge
            }
        }
    }
    Remove-EmptyValue -Hashtable $Object.Settings -Recursive
    $Object
}
function New-DiagramOptionsNodes {
    [alias('DiagramOptionsNodes')]
    [CmdletBinding()]
    param(
        [nullable[int]] $BorderWidth,
        [nullable[int]] $BorderWidthSelected,
        [string] $BrokenImage,
        [nullable[bool]] $Chosen,
        [string] $ColorBorder,
        [string] $ColorBackground,
        [string] $ColorHighlightBorder,
        [string] $ColorHighlightBackground,
        [string] $ColorHoverBorder,
        [string] $ColorHoverBackground,
        [nullable[bool]] $FixedX,
        [nullable[bool]] $FixedY,
        [string] $FontColor,
        [nullable[int]] $FontSize, #// px
        [string] $FontName,
        [string] $FontBackground,
        [nullable[int]] $FontStrokeWidth, #// px
        [string] $FontStrokeColor,
        [ValidateSet('center', 'left')][string] $FontAlign,
        [ValidateSet('false', 'true', 'markdown', 'html')][string]$FontMulti,
        [nullable[int]] $FontVAdjust,
        [nullable[int]] $Size,
        [parameter(ParameterSetName = "Shape")][string][ValidateSet(
            'circle', 'dot', 'diamond', 'ellipse', 'database', 'box', 'square', 'triangle', 'triangleDown', 'text', 'star', 'hexagon')] $Shape,
        [nullable[int]] $HeightConstraintMinimum,
        [ValidateSet('top', 'middle', 'bottom')][string] $HeightConstraintVAlign,
        [nullable[int]] $WidthConstraintMinimum,
        [nullable[int]] $WidthConstraintMaximum,
        [nullable[int]] $Margin,
        [nullable[int]] $MarginTop,
        [nullable[int]] $MarginRight,
        [nullable[int]] $MarginBottom,
        [nullable[int]] $MarginLeft
    )
    $Object = [PSCustomObject] @{
        Type     = 'DiagramOptionsNodes'
        Settings = @{
            nodes = [ordered] @{
                borderWidth         = $BorderWidth
                borderWidthSelected = $BorderWidthSelected
                brokenImage         = $BrokenImage
                chosen              = $Chosen
                color               = [ordered]@{
                    border     = ConvertFrom-Color -Color $ColorBorder
                    background = ConvertFrom-Color -Color $ColorBackground
                    highlight  = [ordered]@{
                        border     = ConvertFrom-Color -Color $ColorHighlightBorder
                        background = ConvertFrom-Color -Color $ColorHighlightBackground
                    }
                    hover      = [ordered]@{
                        border     = ConvertFrom-Color -Color $ColorHoverBorder
                        background = ConvertFrom-Color -Color $ColorHoverBackground
                    }
                }
                fixed               = [ordered]@{
                    x = $FixedX
                    y = $FixedY
                }
                font                = [ordered]@{
                    color       = ConvertFrom-Color -Color $FontColor
                    size        = $FontSize #// px
                    face        = $FontName
                    background  = ConvertFrom-Color -Color $FontBackground
                    strokeWidth = $FontStrokeWidth #// px
                    strokeColor = ConvertFrom-Color -Color $FontStrokeColor
                    align       = $FontAlign
                    multi       = $FontMulti
                    vadjust     = $FontVAdjust
                }
                heightConstraint    = @{
                    minimum = $HeightConstraintMinimum
                    valign  = $HeightConstraintVAlign
                }
                size                = $Size
                shape               = $Shape
                widthConstraint     = @{
                    minimum = $WidthConstraintMinimum
                    maximum = $WidthConstraintMaximum
                }
            }
        }
    }

    if ($Margin) {
        $Object.Settings.nodes.margin = $Margin
    } else {
        $Object.Settings.nodes.margin = @{
            top    = $MarginTop
            right  = $MarginRight
            bottom = $MarginBottom
            left   = $MarginLeft
        }
    }


    Remove-EmptyValue -Hashtable $Object.Settings -Recursive -Rerun 2
    $Object
}

Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName ColorBorder -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName ColorBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName ColorHighlightBorder -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName ColorHighlightBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName ColorHoverBorder -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName ColorHoverBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName FontColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName FontBackground -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-DiagramOptionsNodes -ParameterName FontStrokeColor -ScriptBlock $Script:ScriptBlockColors

<#
// these are all options in full.
var options = {
  nodes:{
    borderWidth: 1,
    borderWidthSelected: 2,
    brokenImage:undefined,
    chosen: true,
    color: {
      border: '#2B7CE9',
      background: '#97C2FC',
      highlight: {
        border: '#2B7CE9',
        background: '#D2E5FF'
      },
      hover: {
        border: '#2B7CE9',
        background: '#D2E5FF'
      }
    },
    fixed: {
      x:false,
      y:false
    },
    font: {
      color: '#343434',
      size: 14, // px
      face: 'arial',
      background: 'none',
      strokeWidth: 0, // px
      strokeColor: '#ffffff',
      align: 'center',
      multi: false,
      vadjust: 0,
      bold: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'bold'
      },
      ital: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'italic',
      },
      boldital: {
        color: '#343434',
        size: 14, // px
        face: 'arial',
        vadjust: 0,
        mod: 'bold italic'
      },
      mono: {
        color: '#343434',
        size: 15, // px
        face: 'courier new',
        vadjust: 2,
        mod: ''
      }
    },
    group: undefined,
    heightConstraint: false,
    hidden: false,
    icon: {
      face: 'FontAwesome',
      code: undefined,
      size: 50,  //50,
      color:'#2B7CE9'
    },
    image: undefined,
    imagePadding: {
      left: 0,
      top: 0,
      bottom: 0,
      right: 0
    },
    label: undefined,
    labelHighlightBold: true,
    level: undefined,
    mass: 1,
    physics: true,
    scaling: {
      min: 10,
      max: 30,
      label: {
        enabled: false,
        min: 14,
        max: 30,
        maxVisible: 30,
        drawThreshold: 5
      },
      customScalingFunction: function (min,max,total,value) {
        if (max === min) {
          return 0.5;
        }
        else {
          let scale = 1 / (max - min);
          return Math.max(0,(value - min)*scale);
        }
      }
    },
    shadow:{
      enabled: false,
      color: 'rgba(0,0,0,0.5)',
      size:10,
      x:5,
      y:5
    },
    shape: 'ellipse',
    shapeProperties: {
      borderDashes: false, // only for borders
      borderRadius: 6,     // only for box shape
      interpolation: false,  // only for image and circularImage shapes
      useImageSize: false,  // only for image and circularImage shapes
      useBorderWithImage: false  // only for image shape
    }
    size: 25,
    title: undefined,
    value: undefined,
    widthConstraint: false,
    x: undefined,
    y: undefined
  }
}

network.setOptions(options)
#>
function New-DiagramOptionsPhysics {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Enabled
    Toggle the physics system on or off. This property is optional. If you define any of the options below and enabled is undefined, this will be set to true.

    .PARAMETER Solver
    You can select your own solver. Possible options: 'barnesHut', 'repulsion', 'hierarchicalRepulsion', 'forceAtlas2Based'. When setting the hierarchical layout, the hierarchical repulsion solver is automatically selected, regardless of what you fill in here.

    .PARAMETER StabilizationEnabled
    Toggle the stabilization. This is an optional property. If undefined, it is automatically set to true when any of the properties of this object are defined.

    .PARAMETER Stabilizationiterations
    The physics module tries to stabilize the network on load up til a maximum number of iterations defined here. If the network stabilized with less, you are finished before the maximum number.

    .PARAMETER StabilizationupdateInterval
    When stabilizing, the DOM can freeze. You can chop the stabilization up into pieces to show a loading bar for instance. The interval determines after how many iterations the stabilizationProgress event is triggered.

    .PARAMETER StabilizationonlyDynamicEdges
    If you have predefined the position of all nodes and only want to stabilize the dynamic smooth edges, set this to true. It freezes all nodes except the invisible dynamic smooth curve support nodes. If you want the visible nodes to move and stabilize, do not use this.

    .PARAMETER Stabilizationfit
    Toggle whether or not you want the view to zoom to fit all nodes when the stabilization is finished.

    .PARAMETER MaxVelocity
    The physics module limits the maximum velocity of the nodes to increase the time to stabilization. This is the maximum value.

    .PARAMETER MinVelocity
    Once the minimum velocity is reached for all nodes, we assume the network has been stabilized and the simulation stops.

    .PARAMETER Timestep
    The physics simulation is discrete. This means we take a step in time, calculate the forces, move the nodes and take another step. If you increase this number the steps will be too large and the network can get unstable. If you see a lot of jittery movement in the network, you may want to reduce this value a little.

    .PARAMETER AdaptiveTimestep
    If this is enabled, the timestep will intelligently be adapted (only during the stabilization stage if stabilization is enabled!) to greatly decrease stabilization times. The timestep configured above is taken as the minimum timestep. This can be further improved by using the improvedLayout algorithm.
    Layout: https://visjs.github.io/vis-network/docs/network/layout.html#layout

    .PARAMETER BarnesHutTheta
    This parameter determines the boundary between consolidated long range forces and individual short range forces. To oversimplify higher values are faster but generate more errors, lower values are slower but with less errors.

    .PARAMETER BarnesHutGravitationalConstant
    Gravity attracts. We like repulsion. So the value is negative. If you want the repulsion to be stronger, decrease the value (so -10000, -50000).

    .PARAMETER BarnesHutCentralGravity
    There is a central gravity attractor to pull the entire network back to the center.

    .PARAMETER BarnesHutSpringLength
    The edges are modelled as springs. This springLength here is the rest length of the spring.

    .PARAMETER BarnesHutSpringConstant
    This is how 'sturdy' the springs are. Higher values mean stronger springs.

    .PARAMETER BarnesHutDamping
    Accepted range: [0 .. 1]. The damping factor is how much of the velocity from the previous physics simulation iteration carries over to the next iteration.

    .PARAMETER BarnesHutAvoidOverlap
    Accepted range: [0 .. 1]. When larger than 0, the size of the node is taken into account. The distance will be calculated from the radius of the encompassing circle of the node for both the gravity model. Value 1 is maximum overlap avoidance.

    .PARAMETER ForceAtlas2BasedTheta
    This parameter determines the boundary between consolidated long range forces and individual short range forces. To oversimplify higher values are faster but generate more errors, lower values are slower but with less errors.

    .PARAMETER ForceAtlas2BasedGravitationalConstant
    This is similar to the barnesHut method except that the falloff is linear instead of quadratic. The connectivity is also taken into account as a factor of the mass. If you want the repulsion to be stronger, decrease the value (so -1000, -2000).

    .PARAMETER ForceAtlas2BasedCentralGravity
    There is a central gravity attractor to pull the entire network back to the center. This is not dependent on distance.

    .PARAMETER ForceAtlas2BasedSpringLength
    The edges are modelled as springs. This springLength here is the rest length of the spring.

    .PARAMETER ForceAtlas2BasedSpringConstant
    This is how 'sturdy' the springs are. Higher values mean stronger springs.

    .PARAMETER ForceAtlas2BasedDamping
    Accepted range: [0 .. 1]. The damping factor is how much of the velocity from the previous physics simulation iteration carries over to the next iteration.

    .PARAMETER ForceAtlas2BasedAvoidOverlap
    	Accepted range: [0 .. 1]. When larger than 0, the size of the node is taken into account. The distance will be calculated from the radius of the encompassing circle of the node for both the gravity model. Value 1 is maximum overlap avoidance.

    .PARAMETER RepulsionNodeDistance
    This is the range of influence for the repulsion.

    .PARAMETER RepulsionCentralGravity
    There is a central gravity attractor to pull the entire network back to the center.

    .PARAMETER RepulsionSpringLength
    The edges are modelled as springs. This springLength here is the rest length of the spring.

    .PARAMETER RepulsionSpringConstant
    This is how 'sturdy' the springs are. Higher values mean stronger springs.

    .PARAMETER RepulsionDamping
    Accepted range: [0 .. 1]. The damping factor is how much of the velocity from the previous physics simulation iteration carries over to the next iteration.

    .PARAMETER HierarchicalRepulsionNodeDistance
    This is the range of influence for the repulsion. Default (Number) Default 120

    .PARAMETER HierarchicalRepulsionCentralGravity
    There is a central gravity attractor to pull the entire network back to the center. Default (Number) 0.0

    .PARAMETER HierarchicalRepulsionSpringLength
    The edges are modelled as springs. This springLength here is the rest length of the spring.

    .PARAMETER HierarchicalRepulsionSpringConstant
    This is how 'sturdy' the springs are. Higher values mean stronger springs.

    .PARAMETER HierarchicalRepulsionDamping
    Accepted range: [0 .. 1]. The damping factor is how much of the velocity from the previous physics simulation iteration carries over to the next iteration.

    .PARAMETER HierarchicalRepulsionAvoidOverlap
    Accepted range: [0 .. 1]. When larger than 0, the size of the node is taken into account. The distance will be calculated from the radius of the encompassing circle of the node for both the gravity model. Value 1 is maximum overlap avoidance.

    .PARAMETER WindX
    The amount of force to be applied pushing non-fixed nodes to the right (positive value) or to the left (negative value).

    .PARAMETER WindY
    The amount of force to be applied pushing non-fixed nodes downwards (positive value) or upwards (negative value).

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [alias('DiagramOptionsPhysics')]
    [CmdletBinding(DefaultParameterSetName = 'BarnesHut')]
    param(
        [nullable[bool]] $Enabled,
        [validateSet('barnesHut', 'repulsion', 'hierarchicalRepulsion', 'forceAtlas2Based')][string] $Solver,

        [nullable[bool]] $StabilizationEnabled,
        [nullable[int]] $Stabilizationiterations,
        [nullable[int]] $StabilizationupdateInterval,
        [nullable[bool]] $StabilizationonlyDynamicEdges,
        [nullable[bool]] $Stabilizationfit,

        [nullable[int]] $MaxVelocity,
        [nullable[int]] $MinVelocity,
        [nullable[int]] $Timestep,
        [nullable[bool]] $AdaptiveTimestep,
        [Parameter(ParameterSetName = 'BarnesHut')][nullable[double]]$BarnesHutTheta,
        [Parameter(ParameterSetName = 'BarnesHut')][nullable[int]] $BarnesHutGravitationalConstant,
        [Parameter(ParameterSetName = 'BarnesHut')][nullable[double]] $BarnesHutCentralGravity,
        [Parameter(ParameterSetName = 'BarnesHut')][nullable[int]] $BarnesHutSpringLength,
        [Parameter(ParameterSetName = 'BarnesHut')][nullable[double]]$BarnesHutSpringConstant,
        [Parameter(ParameterSetName = 'BarnesHut')][nullable[double]] $BarnesHutDamping,
        [Parameter(ParameterSetName = 'BarnesHut')][nullable[int]] $BarnesHutAvoidOverlap,
        # Force2Atlas https://visjs.github.io/vis-network/docs/network/physics.html
        [Parameter(ParameterSetName = 'ForceAtlas2Based')][nullable[double]]$ForceAtlas2BasedTheta,
        [Parameter(ParameterSetName = 'ForceAtlas2Based')][nullable[int]] $ForceAtlas2BasedGravitationalConstant,
        [Parameter(ParameterSetName = 'ForceAtlas2Based')][nullable[double]] $ForceAtlas2BasedCentralGravity,
        [Parameter(ParameterSetName = 'ForceAtlas2Based')][nullable[int]] $ForceAtlas2BasedSpringLength,
        [Parameter(ParameterSetName = 'ForceAtlas2Based')][nullable[double]]$ForceAtlas2BasedSpringConstant,
        [Parameter(ParameterSetName = 'ForceAtlas2Based')][nullable[double]] $ForceAtlas2BasedDamping,
        [Parameter(ParameterSetName = 'ForceAtlas2Based')][nullable[int]] $ForceAtlas2BasedAvoidOverlap,
        # Repulsion https://visjs.github.io/vis-network/docs/network/physics.html
        [Parameter(ParameterSetName = 'Repulsion')][nullable[int]] $RepulsionNodeDistance,
        [Parameter(ParameterSetName = 'Repulsion')][nullable[double]]$RepulsionCentralGravity,
        [Parameter(ParameterSetName = 'Repulsion')][nullable[int]] $RepulsionSpringLength  ,
        [Parameter(ParameterSetName = 'Repulsion')][nullable[double]] $RepulsionSpringConstant,
        [Parameter(ParameterSetName = 'Repulsion')][nullable[double]] $RepulsionDamping,
        # Hierarchical Repulsion https://visjs.github.io/vis-network/docs/network/physics.html
        [Parameter(ParameterSetName = 'HierarchicalRepulsion')][nullable[int]] $HierarchicalRepulsionNodeDistance,
        [Parameter(ParameterSetName = 'HierarchicalRepulsion')][nullable[double]]$HierarchicalRepulsionCentralGravity,
        [Parameter(ParameterSetName = 'HierarchicalRepulsion')][nullable[int]] $HierarchicalRepulsionSpringLength  ,
        [Parameter(ParameterSetName = 'HierarchicalRepulsion')][nullable[double]] $HierarchicalRepulsionSpringConstant,
        [Parameter(ParameterSetName = 'HierarchicalRepulsion')][nullable[double]] $HierarchicalRepulsionDamping,
        [Parameter(ParameterSetName = 'HierarchicalRepulsion')][nullable[double]] $HierarchicalRepulsionAvoidOverlap,
        [nullable[int]] $WindX,
        [nullable[int]] $WindY
    )

    if (-not $Solver) {
        if ($PSCmdlet.ParameterSetName -eq 'Repulsion') {
            $Solver = 'repulsion'
        } elseif ($PSCmdlet.ParameterSetName -eq 'HierarchicalRepulsion') {
            $Solver = 'hierarchicalRepulsion'
        } elseif ($PSCmdlet.ParameterSetName -eq 'ForceAtlas2Based') {
            $Solver = 'forceAtlas2Based'
        } elseif ($PSCmdlet.ParameterSetName -eq 'BarnesHut') {
            $Solver = 'barnesHut'
        }
    }

    $Object = [PSCustomObject] @{
        Type     = 'DiagramOptionsPhysics'
        Settings = [ordered] @{
            physics = [ordered] @{
                enabled               = $Enabled
                solver                = $Solver
                barnesHut             = [ordered] @{
                    theta                 = $BarnesHutTheta
                    gravitationalConstant = $BarnesHutGravitationalConstant
                    centralGravity        = $BarnesHutCentralGravity
                    springLength          = $BarnesHutSpringLength
                    springConstant        = $BarnesHutSpringConstant
                    damping               = $BarnesHutDamping
                    avoidOverlap          = $BarnesHutAvoidOverlap
                }
                forceAtlas2Based      = [ordered] @{
                    theta                 = $ForceAtlas2BasedTheta	                # Number	0.5	This parameter determines the boundary between consolidated long range forces and individual short range forces. To oversimplify higher values are faster but generate more errors, lower values are slower but with less errors.
                    gravitationalConstant = $ForceAtlas2BasedGravitationalConstant	# Number	-50	This is similar to the barnesHut method except that the falloff is linear instead of quadratic. The connectivity is also taken into account as a factor of the mass. If you want the repulsion to be stronger, decrease the value (so -1000, -2000).
                    centralGravity        = $ForceAtlas2BasedCentralGravity	        # Number	0.01	There is a central gravity attractor to pull the entire network back to the center. This is not dependent on distance.
                    springLength          = $ForceAtlas2BasedSpringLength	        # Number	100	The edges are modelled as springs. This springLength here is the rest length of the spring.
                    springConstant        = $ForceAtlas2BasedSpringConstant	        # Number	0.08	This is how 'sturdy' the springs are. Higher values mean stronger springs.
                    damping               = $ForceAtlas2BasedDamping	            # Number	0.4	Accepted range: [0 .. 1]. The damping factor is how much of the velocity from the previous physics simulation iteration carries over to the next iteration.
                    avoidOverlap          = $ForceAtlas2BasedAvoidOverlap	        # Number	0	Accepted range: [0 .. 1]. When larger than 0, the size of the node is taken into account. The distance will be calculated from the radius of the encompassing circle of the node for both the gravity model. Value 1 is maximum overlap avoidance.
                }
                repulsion             = [ordered] @{
                    nodeDistance   = $RepulsionNodeDistance	#Number	120	This is the range of influence for the repulsion.
                    centralGravity = $RepulsionCentralGravity	#Number	0.0'	There is a central gravity attractor to pull the entire network back to the center.
                    springLength   = $RepulsionSpringLength   #	Number	100	The edges are modelled as springs. This springLength here is the rest length of the spring.
                    springConstant = $RepulsionSpringConstant	#Number	0.01	This is how 'sturdy' the springs are. Higher values mean stronger springs.
                    damping        = $RepulsionDamping      #Number	0.09	Accepted range: [0 .. 1]. The damping factor is how much of the velocity from the previous physics simulation iteration carries over to the next iteration.
                }
                hierarchicalRepulsion = [ordered] @{
                    nodeDistance   = $HierarchicalRepulsionNodeDistance	#Number	120	This is the range of influence for the repulsion.
                    centralGravity = $HierarchicalRepulsionCentralGravity	#Number	0.0'	There is a central gravity attractor to pull the entire network back to the center.
                    springLength   = $HierarchicalRepulsionSpringLength   #	Number	100	The edges are modelled as springs. This springLength here is the rest length of the spring.
                    springConstant = $HierarchicalRepulsionSpringConstant	#Number	0.01	This is how 'sturdy' the springs are. Higher values mean stronger springs.
                    damping        = $HierarchicalRepulsionDamping      #Number	0.09	Accepted range: [0 .. 1]. The damping factor is how much of the velocity from the previous physics simulation iteration carries over to the next iteration.
                    avoidOverlap   = $HierarchicalRepulsionAvoidOverlap  #	Number	0	Accepted range: [0 .. 1]. When larger than 0, the size of the node is taken into account. The distance will be calculated from the radius of the encompassing circle of the node for both the gravity model. Value 1 is maximum overlap avoidance.
                }
                stabilization         = [ordered] @{
                    enabled          = $StabilizationEnabled
                    iterations       = $Stabilizationiterations
                    updateInterval   = $StabilizationupdateInterval
                    onlyDynamicEdges = $StabilizationonlyDynamicEdges
                    fit              = $Stabilizationfit
                }
                maxVelocity           = $MaxVelocity
                minVelocity           = $MinVelocity
                timestep              = $Timestep
                adaptiveTimestep      = $AdaptiveTimestep
                wind                  = [ordered] @{
                    x = $WindX
                    y = $WindY
                }
            }
        }
    }
    Remove-EmptyValue -Hashtable $Object.Settings -Recursive -Rerun 2
    $Object
}

<#
// these are all options in full.
var options = {
  physics:{
    enabled: true,
    barnesHut: {
      gravitationalConstant: -2000,
      centralGravity: 0.3,
      springLength: 95,
      springConstant: 0.04,
      damping: 0.09,
      avoidOverlap: 0
    },
    forceAtlas2Based: {
      gravitationalConstant: -50,
      centralGravity: 0.01,
      springConstant: 0.08,
      springLength: 100,
      damping: 0.4,
      avoidOverlap: 0
    },
    repulsion: {
      centralGravity: 0.2,
      springLength: 200,
      springConstant: 0.05,
      nodeDistance: 100,
      damping: 0.09
    },
    hierarchicalRepulsion: {
      centralGravity: 0.0,
      springLength: 100,
      springConstant: 0.01,
      nodeDistance: 120,
      damping: 0.09
    },
    maxVelocity: 50,
    minVelocity: 0.1,
    solver: 'barnesHut',
    stabilization: {
      enabled: true,
      iterations: 1000,
      updateInterval: 100,
      onlyDynamicEdges: false,
      fit: true
    },
    timestep: 0.5,
    adaptiveTimestep: true
  }
}

network.setOptions(options);
#>
function New-GageSector {
    [CmdletBinding()]
    param(
        [string] $Color,
        [int] $Min,
        [int] $Max
    )

    [ordered] @{
        color = ConvertFrom-Color -Color $Color
        lo    = $Min
        hi    = $Max
    }
}
Register-ArgumentCompleter -CommandName New-GageSection -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-HierarchicalTreeNode {
    [alias('HierarchicalTreeNode')]
    [CmdletBinding()]
    param(
        [string] $ID,
        [alias('Name')][string] $Label,
        [string] $Type = "Organism",
        [string] $Description,
        [string] $To
    )

    if (-not $ID) {
        $ID = $Label
    }

    $Object = [PSCustomObject] @{
        Type     = 'TreeNode'
        Settings = [ordered] @{
            "id"          = $ID
            "parentId"    = $To
            "name"        = $Label
            #"type"        = $Type
            "description" = $Description
        }
    }
    Remove-EmptyValue -Hashtable $Object.Settings -Recursive
    $Object
}


Function New-HTML {
    [alias('Dashboard')]
    [CmdletBinding()]
    param(
        [alias('Content')][Parameter(Position = 0)][ValidateNotNull()][ScriptBlock] $HtmlData = $(Throw "Have you put the open curly brace on the next line?"),
        [switch] $Online,
        [alias('Name', 'Title')][String] $TitleText,
        [string] $Author,
        [string] $DateFormat = 'yyyy-MM-dd HH:mm:ss',
        [int] $AutoRefresh,
        # save HTML options
        [Parameter(Mandatory = $false)][string]$FilePath,
        [alias('Show', 'Open')][Parameter(Mandatory = $false)][switch]$ShowHTML,
        [ValidateSet('Unknown', 'String', 'Unicode', 'Byte', 'BigEndianUnicode', 'UTF8', 'UTF7', 'UTF32', 'Ascii', 'Default', 'Oem', 'BigEndianUTF32')] $Encoding = 'UTF8',
        [Uri] $FavIcon,
        # Deprecated - will be removed
        [Parameter(DontShow)][switch] $UseCssLinks,
        [Parameter(DontShow)][switch] $UseJavaScriptLinks,
        [switch] $Temporary,
        [switch] $AddComment,
        [switch] $Format,
        [switch] $Minify
    )
    if ($UseCssLinks -or $UseJavaScriptLinks) {
        Write-Warning "New-HTML - UseCssLinks and UseJavaScriptLinks is depreciated. Use Online switch instead. Those switches will be removed in near future."
        $Online = $true
    }

    [string] $CurrentDate = (Get-Date).ToString($DateFormat)

    # This makes sure we use always fresh copy
    $Script:CurrentConfiguration = Copy-Dictionary -Dictionary $Script:Configuration

    $Script:HTMLSchema = @{
        Email             = $false
        Features          = [ordered] @{ } # tracks features for CSS/JS implementation
        Charts            = [System.Collections.Generic.List[string]]::new()
        Diagrams          = [System.Collections.Generic.List[string]]::new()

        Logos             = ""

        # Tabs Tracking/Options (Top Level Ones)
        TabsHeaders       = [System.Collections.Generic.List[System.Collections.IDictionary]]::new() # tracks / stores headers
        TabsHeadersNested = [System.Collections.Generic.List[System.Collections.IDictionary]]::new() # tracks / stores headers
        TabOptions        = @{
            SlimTabs = $false
        }

        # TabPanels Tracking
        TabPanelsList     = [System.Collections.Generic.List[string]]::new()

        # Table Related Tracking
        Table             = [ordered] @{}
        TableSimplify     = $false # Tracks current table only
        TableOptions      = [ordered] @{
            DataStore        = ''
            # Applies to only JavaScript and AjaxJSON store
            DataStoreOptions = [ordered] @{
                BoolAsString   = $false
                NumberAsString = $false
                DateTimeFormat = '' #"yyyy-MM-dd HH:mm:ss"
                NewLineFormat  = @{
                    NewLineCarriage = '<br>'
                    NewLine         = "\n"
                    Carriage        = "\r"
                }
            }
            Type             = 'Structured'
            Folder           = if ($FilePath) { Split-Path -Path $FilePath } else { '' }
        }
        CustomHeaderCSS   = [ordered] @{}
        CustomFooterCSS   = [ordered] @{}
        CustomHeaderJS    = [ordered] @{}
        CustomFooterJS    = [ordered] @{}

        # WizardList Tracking
        WizardList        = [System.Collections.Generic.List[string]]::new()
    }

    # If hosted is chosen that means we will be running things server side
    # This also means we requrie filepath, and rest will be autogenerated according to that
    # Especially we need Folder Path



    [Array] $TempOutputHTML = Invoke-Command -ScriptBlock $HtmlData

    $HeaderHTML = @()
    #$MainHTML = @()
    $FooterHTML = @()


    $MainHTML = foreach ($ObjectTemp in $TempOutputHTML) {
        if ($ObjectTemp -is [PSCustomObject]) {
            if ($ObjectTemp.Type -eq 'Footer') {
                $FooterHTML = foreach ($_ in $ObjectTemp.Output) {
                    # this gets rid of any non-strings
                    # it's added here to track nested tabs
                    if ($_ -isnot [System.Collections.IDictionary]) { $_ }
                }
            } elseif ($ObjectTemp.Type -eq 'Header') {
                $HeaderHTML = foreach ($_ in $ObjectTemp.Output) {
                    # this gets rid of any non-strings
                    # it's added here to track nested tabs
                    if ($_ -isnot [System.Collections.IDictionary]) { $_ }
                }
            } else {
                if ($ObjectTemp.Output) {
                    # this gets rid of any non-strings
                    # it's added here to track nested tabs
                    foreach ($SubObject in $ObjectTemp.Output) {
                        if ($SubObject -isnot [System.Collections.IDictionary]) {
                            $SubObject
                        }
                    }
                }
            }
        } else {
            # this gets rid of any non-strings
            # it's added here to track nested tabs
            if ($ObjectTemp -isnot [System.Collections.IDictionary]) {
                $ObjectTemp
            }
        }
    }

    $Script:HTMLSchema.Features.Main = $true

    $Features = Get-FeaturesInUse -PriorityFeatures 'Main', 'FontsAwesome', 'JQuery', 'Moment', 'DataTables', 'Tabs' -Email:$Script:HTMLSchema['Email']

    # This removes Nested Tabs from primary Tabs
    foreach ($_ in $Script:HTMLSchema.TabsHeadersNested) {
        $null = $Script:HTMLSchema.TabsHeaders.Remove($_)
    }
    [string] $HTML = @(
        #"<!-- saved from url=(0016)http://localhost -->" + "`r`n"
        '<!-- saved from url=(0014)about:internet -->' + [System.Environment]::NewLine
        '<!DOCTYPE html>' + [System.Environment]::NewLine
        New-HTMLTag -Tag 'html' {
            if ($AddComment) { '<!-- HEAD -->' }
            New-HTMLTag -Tag 'head' {
                New-HTMLTag -Tag 'meta' -Attributes @{ 'http-equiv' = "Content-Type"; content = "text/html; charset=utf-8" } -NoClosing
                #New-HTMLTag -Tag 'meta' -Attributes @{ charset = "utf-8" } -NoClosing
                #New-HTMLTag -Tag 'meta' -Attributes @{ 'http-equiv' = 'X-UA-Compatible'; content = 'IE=8' } -SelfClosing
                New-HTMLTag -Tag 'meta' -Attributes @{ name = 'viewport'; content = 'width=device-width, initial-scale=1' } -NoClosing
                if ($Author) {
                    New-HTMLTag -Tag 'meta' -Attributes @{ name = 'author'; content = $Author } -NoClosing
                }
                New-HTMLTag -Tag 'meta' -Attributes @{ name = 'revised'; content = $CurrentDate } -NoClosing
                New-HTMLTag -Tag 'title' { $TitleText }

                if ($null -ne $FavIcon) {
                    $Extension = [System.IO.Path]::GetExtension($FavIcon)
                    if ($Extension -in @('.png', '.jpg', 'jpeg', '.svg', '.ico')) {
                        switch ($FavIcon.Scheme) {
                            "file" {
                                if (Test-Path -Path $FavIcon.OriginalString) {
                                    $FavIcon = Get-Item -Path $FavIcon.OriginalString
                                    $FavIconImageBinary = Convert-ImageToBinary -ImageFile $FavIcon
                                    New-HTMLTag -Tag 'link' -Attributes @{rel = 'icon'; href = "$FavIconImageBinary"; type = 'image/x-icon' }
                                } else {
                                    Write-Warning -Message "The path to the FavIcon image could not be resolved."
                                }
                            }
                            "https" {
                                $FavIcon = $FavIcon.OriginalString
                                New-HTMLTag -Tag 'link' -Attributes @{rel = 'icon'; href = "$FavIcon"; type = 'image/x-icon' }
                            }
                            default {
                                Write-Warning -Message "The path to the FavIcon image could not be resolved."
                            }
                        }
                    } else {
                        Write-Warning -Message "File extension `'$Extension`' is not supported as a FavIcon image.`nPlease use images with these extensions: '.png', '.jpg', 'jpeg', '.svg', '.ico'"
                    }
                }

                if ($Autorefresh -gt 0) {
                    New-HTMLTag -Tag 'meta' -Attributes @{ 'http-equiv' = 'refresh'; content = $Autorefresh } -SelfClosing
                }
                # Those are CSS we always add
                #Get-Resources -Online:$true -Location 'HeaderAlways' -Features Fonts, FontsAwesome -NoScript
                #Get-Resources -Online:$false -Location 'HeaderAlways' -Features DefaultHeadings -NoScript
                Get-Resources -Online:$Online.IsPresent -Location 'HeaderAlways' -Features Fonts #-NoScript

                # we dont need all the scripts/styles in emails, we limit it to approved few
                #if ($Script:HTMLSchema['Email'] -eq $true) {
                #  $EmailFeatures = 'DefaultHeadings', 'DefaultText', 'DefaultImage', 'Main' #, 'Fonts', 'FontsAwesome'
                #[string[]] $Features = foreach ($Feature in $Features) {
                #    if ($Feature -in $EmailFeatures) {
                #        $Feature
                #    }
                #}
                #}

                # Those are CSS we only add if user selected proper data
                if ($null -ne $Features) {
                    # additionally we want to have different rules when Email is being built and not
                    Get-Resources -Online:$Online.IsPresent -Location 'Header' -Features $Features -NoScript
                    Get-Resources -Online:$true -Location 'HeaderAlways' -Features $Features -NoScript
                    Get-Resources -Online:$false -Location 'HeaderAlways' -Features $Features -NoScript
                }
                if ($Script:HTMLSchema['Email'] -ne $true -and $Script:HTMLSchema.CustomHeaderJS) {
                    New-HTMLCustomJS -JS $Script:HTMLSchema.CustomHeaderJS
                }
                if ($Script:HTMLSchema.CustomHeaderCSS) {
                    New-HTMLCustomCSS -Css $Script:HTMLSchema.CustomHeaderCSS -AddComment:$AddComment
                }
            }
            if ($AddComment) {
                '<!-- END HEAD -->'
                '<!-- BODY -->'
            }
            New-HTMLTag -Tag 'body' {
                if ($null -ne $Features) {
                    Get-Resources -Online:$Online.IsPresent -Location 'Body' -Features $Features -NoScript
                    Get-Resources -Online:$true -Location 'BodyAlways' -Features $Features -NoScript
                    Get-Resources -Online:$false -Location 'BodyAlways' -Features $Features -NoScript
                }
                if ($HeaderHTML) {
                    if ($AddComment) { '<!-- HEADER -->' }
                    New-HTMLTag -Tag 'header' {
                        $HeaderHTML
                    }
                    if ($AddComment) { '<!-- END HEADER -->' }
                }
                New-HTMLTag -Tag 'div' -Attributes @{ class = 'main-section' } {
                    # Add logo if there is one
                    $Script:HTMLSchema.Logos
                    # Add tabs header if there is one
                    if ($Script:HTMLSchema.TabsHeaders) {
                        New-HTMLTabHead
                        New-HTMLTag -Tag 'div' -Attributes @{ 'data-panes' = 'true' } {
                            # Add remaining data
                            #$OutputHTML
                            $MainHTML
                        }
                    } else {
                        # Add remaining data
                        $MainHTML
                        #$OutputHTML
                    }
                    # Add charts scripts if those are there
                    foreach ($Chart in $Script:HTMLSchema.Charts) {
                        $Chart
                    }
                    foreach ($Diagram in $Script:HTMLSchema.Diagrams) {
                        $Diagram
                    }
                }
                if ($AddComment) { '<!-- FOOTER -->' }

                [string] $Footer = @(
                    if ($FooterHTML) {
                        $FooterHTML
                    }
                    #New-HTMLTag -Tag 'footer' {
                    if ($null -ne $Features) {
                        # FooterAlways means we're not able to provide consistent output with and without links and we prefer those to be included
                        # either as links or from file per required features
                        Get-Resources -Online:$true -Location 'FooterAlways' -Features $Features -NoScript
                        Get-Resources -Online:$false -Location 'FooterAlways' -Features $Features -NoScript
                        # standard footer features
                        Get-Resources -Online:$Online.IsPresent -Location 'Footer' -Features $Features -NoScript

                    }
                    if ($Script:HTMLSchema.CustomFooterCSS) {
                        New-HTMLCustomCSS -Css $Script:HTMLSchema.CustomFooterCSS -AddComment:$AddComment
                    }
                    if ($Script:HTMLSchema['Email'] -ne $true -and $Script:HTMLSchema.CustomFooterJS) {
                        New-HTMLCustomJS -JS $Script:HTMLSchema.CustomFooterJS
                    }
                )
                if ($Footer) {
                    New-HTMLTag -Tag 'footer' {
                        $Footer
                    }
                }
                if ($AddComment) {
                    '<!-- END FOOTER -->'
                    '<!-- END BODY -->'
                }
            }
        }
    )
    if ($FilePath -ne '') {
        Save-HTML -HTML $HTML -FilePath $FilePath -ShowHTML:$ShowHTML -Encoding $Encoding -Format:$Format -Minify:$Minify
    } else {
        if ($ShowHTML -or $Temporary) {
            # if we have not chosen filepath but we used ShowHTML user wants to show it right? Or we have chosen temporary
            # We want to make sure we don't return useless HTML to the user
            $FilePath = Get-FileName -Extension 'html' -Temporary
            Save-HTML -HTML $HTML -FilePath $FilePath -ShowHTML:$ShowHTML -Encoding $Encoding -Format:$Format -Minify:$Minify
        } else {
            # User opted to return all data in form of html
            $HTML
        }
    }
}

function New-HTMLAccordion {
    [cmdletBinding()]
    param(
        [scriptBlock] $AccordionItem,
        [int] $Duration,
        [switch] $CollapseOnClick
    )
    # Implementation based on https://github.com/michu2k/Accordion
    # Make sure AccordionFAQ is added to source
    $Script:HTMLSchema.Features.AccordionFAQ = $true

    [string] $ID = "Accordion" + (Get-RandomStringName -Size 8)

    $Options = @{}
    if ($Duration) {
        $Options['duration'] = $Duration
    }
    if ($CollapseOnClick) {
        $Options['collapse'] = $true
    }
    $OptionsJSON = $Options | ConvertTo-Json

    if ($AccordionItem) {
        New-HTMLTag -Tag 'div' -Attributes @{ id = $Id ; class = "accordion-container flexElement" } {
            & $AccordionItem
        }
        New-HTMLTag -Tag 'script' {
            "new Accordion('#$Id', $OptionsJSON);"
        }
    }
}
function New-HTMLAnchor {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Name
    Parameter description

    .PARAMETER Id
    Parameter description

    .PARAMETER Target
    Parameter description

    .PARAMETER Class
    Parameter description

    .PARAMETER HrefLink
    Parameter description

    .PARAMETER OnClick
    Parameter description

    .PARAMETER Style
    Parameter description

    .PARAMETER Text
    Parameter description

    .EXAMPLE
    New-HTMLAnchor -Target _parent

    New-HTMLAnchor -Id "show_$RandomNumber" -Href '#' -OnClick "show('$RandomNumber');" -Style "color: #ffffff; display:none;" -Text 'Show'

    Output:
    <a target = "_parent" />

    .NOTES
    General notes
    #>
    [alias('New-HTMLLink')]
    [cmdletBinding()]
    param(
        [alias('AnchorName')][string] $Name,
        [string] $Id,
        [string] $Target, # "_blank|_self|_parent|_top|framename"
        [string] $Class,
        [alias('Url', 'Link', 'UrlLink', 'Href')][string] $HrefLink,
        [string] $OnClick,
        [System.Collections.IDictionary] $Style,
        [alias('AnchorText', 'Value')][string] $Text
    )
    $Attributes = [ordered]@{
        'id'      = $Id
        'name'    = $Name
        'class'   = $Class
        'target'  = $Target
        'href'    = $HrefLink
        'onclick' = $OnClick
        'style'   = $Style
    }
    New-HTMLTag -Tag 'a' -Attributes $Attributes {
        $Text
    }
}
function New-HTMLCalendar {
    [alias('Calendar')]
    [CmdletBinding()]
    param(
        [ScriptBlock] $CalendarSettings,
        [ValidateSet(
            'prev', 'next', 'today', 'prevYear', 'nextYear', 'dayGridDay', 'dayGridWeek', 'dayGridMonth',
            'timeGridWeek', 'timeGridDay', 'listDay', 'listWeek', 'listMonth', 'title'
        )][string[]] $HeaderLeft = @('prev', 'next', 'today'),
        [ValidateSet(
            'prev', 'next', 'today', 'prevYear', 'nextYear', 'dayGridDay', 'dayGridWeek', 'dayGridMonth',
            'timeGridWeek', 'timeGridDay', 'listDay', 'listWeek', 'listMonth', 'title'
        )][string[]]$HeaderCenter = 'title',
        [ValidateSet(
            'prev', 'next', 'today', 'prevYear', 'nextYear', 'dayGridDay', 'dayGridWeek', 'dayGridMonth',
            'timeGridWeek', 'timeGridDay', 'listDay', 'listWeek', 'listMonth', 'title'
        )][string[]] $HeaderRight = @('dayGridMonth', 'timeGridWeek', 'timeGridDay', 'listMonth'),
        [DateTime] $DefaultDate = (Get-Date),
        [bool] $NavigationLinks = $true,
        [bool] $NowIndicator = $true,
        [bool] $EventLimit = $true,
        [bool] $WeekNumbers = $true,
        #[bool] $WeekNumbersWithinDays = $true,
        [bool] $Selectable = $true,
        [bool] $SelectMirror = $true,
        [switch] $BusinessHours,
        [switch] $Editable,
        [ValidateSet(
            'dayGridDay', 'dayGridWeek', 'dayGridMonth', 'timeGridDay', 'timeGridWeek', 'listDay', 'listWeek', 'listMonth'
        )][string] $InitialView
    )
    if (-not $Script:HTMLSchema.Features) {
        Write-Warning 'New-HTMLCalendar - Creation of HTML aborted. Most likely New-HTML is missing.'
        Exit
    }
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.FullCalendar = $true
    $Script:HTMLSchema.Features.Popper = $true

    $CalendarEvents = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()

    [Array] $Settings = & $CalendarSettings
    foreach ($Object in $Settings) {
        if ($Object.Type -eq 'CalendarEvent') {
            $CalendarEvents.Add($Object.Settings)
        }
    }

    # Define HTML/Script
    [string] $ID = "Calendar-" + (Get-RandomStringName -Size 8)

    $Calendar = [ordered] @{
        headerToolbar         = @{
            left   = $HeaderLeft -join ','
            center = $HeaderCenter -join ','
            right  = $HeaderRight -join ','
        }

        initialView           = $InitialView
        initialDate           = '{0:yyyy-MM-dd}' -f ($DefaultDate)
        eventDidMount         = 'ReplaceMe'
        nowIndicator          = $NowIndicator
        #now: '2018-02-13T09:25:00' // just for demo
        navLinks              = $NavigationLinks #// can click day/week names to navigate views
        businessHours         = $BusinessHours.IsPresent #// display business hours
        editable              = $Editable.IsPresent
        events                = $CalendarEvents
        dayMaxEventRows       = $EventLimit
        weekNumbers           = $WeekNumbers
        weekNumberCalculation = 'ISO'
        selectable            = $Selectable
        selectMirror          = $SelectMirror
        buttonIcons           = $false # // show the prev/next text
        #// customize the button names,
        #// otherwise they'd all just say "list"
        views                 = @{
            listDay   = @{ buttonText = 'list day' }
            listWeek  = @{ buttonText = 'list week' }
            listMonth = @{ buttonText = 'list month' }
        }
    }
    Remove-EmptyValue -Hashtable $Calendar -Recursive
    $CalendarJSON = $Calendar | ConvertTo-Json -Depth 7

    # Adding function for ToolTips / need cleaner way
    $eventDidMount = @"
    eventDidMount: function(info) {
        var tooltip = new Tooltip(info.el, {
            title: info.event.extendedProps.description,
            placement: 'top',
            trigger: 'hover',
            container: 'body'
        });
    }
"@
    if ($PSEdition -eq 'Desktop') {
        $TextToFind = '"eventDidMount":  "ReplaceMe"'
    } else {
        $TextToFind = '"eventDidMount": "ReplaceMe"'
    }
    $CalendarJSON = $CalendarJSON.Replace($TextToFind, $eventDidMount)

    $Div = New-HTMLTag -Tag 'div' -Attributes @{ id = $ID; class = 'calendarFullCalendar'; style = $Style }
    $Script = New-HTMLTag -Tag 'script' -Value {
        "document.addEventListener('DOMContentLoaded', function () {"
        "var calendarEl = document.getElementById('$ID');"
        'var calendar = new FullCalendar.Calendar(calendarEl,'
        $CalendarJSON
        ');'
        'calendar.render();'
        "calendarTracker['$ID'] = calendar;"
        '}); '
    } -NewLine

    # return HTML
    $Div
    $Script
}
function New-HTMLCarousel {
    [cmdletBinding()]
    param(
        [scriptblock] $Slide
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.CarouselKineto = $true
    $Script:HTMLSchema.Features.jquery = $true
    if (-not $CarouselID) {
        $CarouselID = "Carousel-$(Get-RandomStringName -Size 8 -LettersOnly)"
    }

    $Options = [ordered] @{
        pagination = $true
        mode       = 'horizontal'
    }
    $Carousel = $Options | ConvertTo-JsonLiteral -Depth 0 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' }

    New-HTMLTag -Tag 'div' -Attributes @{ ID = $CarouselID; class = "carousel" } {
        if ($Slide) {
            & $Slide
        }
    }
    New-HTMLTag -Tag 'script' {
        "Kineto.create('#$CarouselID', $Carousel);"
    }
}
function New-HTMLChart {
    [alias('Chart')]
    [CmdletBinding()]
    param(
        [ScriptBlock] $ChartSettings,
        [string] $Title,
        [ValidateSet('center', 'left', 'right')][string] $TitleAlignment,
        [nullable[int]] $TitleMargin,
        [nullable[int]] $TitleOffsetX,
        [nullable[int]] $TitleOffsetY,
        [nullable[int]] $TitleFloating,
        [object] $TitleFontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $TitleFontWeight,
        [string] $TitleFontFamily,
        [string] $TitleColor,

        [string] $SubTitle,
        [ValidateSet('center', 'left', 'right')][string] $SubTitleAlignment,
        [nullable[int]] $SubTitleMargin,
        [nullable[int]] $SubTitleOffsetX,
        [nullable[int]] $SubTitleOffsetY,
        [nullable[int]] $SubTitleFloating,
        [object] $SubTitleFontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $SubTitleFontWeight,
        [string] $SubTitleFontFamily,
        [string] $SubTitleColor,

        [nullable[int]] $Height = 350,
        [nullable[int]] $Width,
        [alias('GradientColors')][switch] $Gradient,
        [alias('PatternedColors')][switch] $Patterned
    )
    $Script:HTMLSchema.Features.MainFlex = $true

    # Lets build Title Block
    $TitleBlock = @{
        text     = $Title
        align    = $TitleAlignment
        margin   = $TitleMargin
        offsetX  = $TitleOffsetX
        offsetY  = $TitleOffsetY
        floating = $TitleFloating
        style    = @{
            fontSize   = ConvertFrom-Size -Size $TitleFontSize
            fontWeight = $TitleFontWeight
            fontFamily = $TitleFontFamily
            color      = ConvertFrom-Color -Color $TitleColor
        }
    }
    Remove-EmptyValue -Hashtable $TitleBlock -Recursive -Rerun 2

    # Lets build SubTitle Block
    $SubTitleBlock = @{
        text     = $SubTitle
        align    = $SubTitleAlignment
        margin   = $SubTitleMargin
        offsetX  = $SubTitleOffsetX
        offsetY  = $SubTitleOffsetY
        floating = $SubTitleFloating
        style    = @{
            fontSize   = ConvertFrom-Size -Size $SubTitleFontSize
            fontWeight = $SubTitleFontWeight
            fontFamily = $SubTitleFontFamily
            color      = ConvertFrom-Color -Color $SubTitleColor
        }
    }
    Remove-EmptyValue -Hashtable $SubTitleBlock -Recursive -Rerun 2

    # Datasets Bar/Line
    $DataSet = [System.Collections.Generic.List[object]]::new()
    $DataName = [System.Collections.Generic.List[object]]::new()

    $DataSetChartTimeLine = [System.Collections.Generic.List[PSCustomObject]]::new()

    # Legend Variables
    $Colors = [System.Collections.Generic.List[string]]::new()

    # Line Variables
    # $LineColors = [System.Collections.Generic.List[string]]::new()
    $LineCurves = [System.Collections.Generic.List[string]]::new()
    $LineWidths = [System.Collections.Generic.List[int]]::new()
    $LineDashes = [System.Collections.Generic.List[int]]::new()
    $LineCaps = [System.Collections.Generic.List[string]]::new()

    #$RadialColors = [System.Collections.Generic.List[string]]::new()
    #$SparkColors = [System.Collections.Generic.List[string]]::new()

    # Bar default definitions
    [bool] $BarHorizontal = $true
    [bool] $BarDataLabelsEnabled = $true
    [int] $BarDataLabelsOffsetX = -6
    [string] $BarDataLabelsFontSize = '12px'
    [bool] $BarDistributed = $false

    [string] $Type = ''

    # Reading all charts definitions and converting them to proper entries
    [Array] $Settings = & $ChartSettings
    foreach ($Setting in $Settings) {
        if ($Setting.ObjectType -eq 'Bar') {
            # For Bar Charts
            if (-not $Type) {
                # this makes sure type is not set if BarOptions is used which already set type to BarStacked or similar
                $Type = $Setting.ObjectType
            }
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)

        } elseif ($Setting.ObjectType -eq 'Pie' -or $Setting.ObjectType -eq 'Donut') {
            # For Pie Charts
            $Type = $Setting.ObjectType
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)

            if ($Setting.Color) {
                $Colors.Add($Setting.Color)
            }
        } elseif ($Setting.ObjectType -eq 'Spark') {
            # For Spark Charts
            $Type = $Setting.ObjectType
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)

            if ($Setting.Color) {
                $Colors.Add($Setting.Color)
            }
        } elseif ($Setting.ObjectType -eq 'Radial') {
            $Type = $Setting.ObjectType
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)

            if ($Setting.Color) {
                $Colors.Add($Setting.Color)
            }
        } elseif ($Setting.ObjectType -eq 'Legend') {
            # For Bar Charts
            $DataLegend = $Setting.Names
            if ($null -ne $Setting.Color) {
                $Colors = $Setting.Color
            }
            $Legend = $Setting.Legend
        } elseif ($Setting.ObjectType -eq 'BarOptions') {
            # For Bar Charts
            $Type = $Setting.Type
            $BarHorizontal = $Setting.Horizontal
            $BarDataLabelsEnabled = $Setting.DataLabelsEnabled
            $BarDataLabelsOffsetX = $Setting.DataLabelsOffsetX
            $BarDataLabelsFontSize = $Setting.DataLabelsFontSize
            $BarDataLabelsColor = $Setting.DataLabelsColor
            $BarDistributed = $Setting.Distributed

            # This is required to support legacy ChartBarOptions - Gradient -Patterned
            if ($null -ne $Setting.PatternedColors) {
                $Patterned = $Setting.PatternedColors
            }
            if ($null -ne $Setting.GradientColors) {
                $Gradient = $Setting.GradientColors
            }
        } elseif ($Setting.ObjectType -eq 'Toolbar') {
            # For All Charts
            $Toolbar = $Setting.Toolbar
        } elseif ($Setting.ObjectType -eq 'Theme') {
            # For All Charts
            $Theme = $Setting.Theme
        } elseif ($Setting.ObjectType -eq 'Line') {
            # For Line Charts
            $Type = $Setting.ObjectType
            $DataSet.Add($Setting.Value)
            $DataName.Add($Setting.Name)
            if ($Setting.LineColor) {
                $Colors.Add($Setting.LineColor)
            }
            if ($Setting.LineCurve) {
                $LineCurves.Add($Setting.LineCurve)
            }
            if ($Setting.LineWidth) {
                $LineWidths.Add($Setting.LineWidth)
            }
            if ($Setting.LineDash) {
                $LineDashes.Add($Setting.LineDash)
            }
            if ($Setting.LineCap) {
                $LineCaps.Add($Setting.LineCap)
            }
        } elseif ($Setting.ObjectType -eq 'ChartAxisX') {
            $ChartAxisX = $Setting.ChartAxisX
        } elseif ($Setting.ObjectType -eq 'ChartGrid') {
            $GridOptions = $Setting.Grid
        } elseif ($Setting.ObjectType -eq 'ChartAxisY') {
            $ChartAxisY = $Setting.ChartAxisY
        } elseif ($Setting.ObjectType -eq 'TimeLine') {
            $Type = 'rangeBar'
            $DataSetChartTimeLine.Add($Setting.TimeLine)
        } elseif ($Setting.ObjectType -eq 'ChartToolTip') {
            $ChartToolTip = $Setting.ChartToolTip
        } elseif ($Setting.ObjectType -eq 'DataLabel') {
            $DataLabel = $Setting.DataLabel
        } elseif ($Setting.ObjectType -eq 'ChartEvents') {
            $Events = $Setting.Event
        }
    }

    if ($Type -in @('bar', 'barStacked', 'barStacked100Percent')) {
        #if ($DataLegend.Count -lt $DataSet[0].Count) {
        #    Write-Warning -Message "Chart Legend count doesn't match values count. Skipping."
        #}
        # Fixes dataset/dataname to format expected by New-HTMLChartBar
        $HashTable = [ordered] @{ }
        $ArrayCount = $DataSet[0].Count
        if ($ArrayCount -eq 1) {
            $HashTable.1 = $DataSet
        } else {
            for ($i = 0; $i -lt $ArrayCount; $i++) {
                $HashTable.$i = [System.Collections.Generic.List[object]]::new()
            }
            foreach ($Value in $DataSet) {
                for ($h = 0; $h -lt $Value.Count; $h++) {
                    $HashTable[$h].Add($Value[$h])
                }
            }
        }

        New-HTMLChartBar `
            -Data $($HashTable.Values) `
            -DataNames $DataName `
            -DataLegend $DataLegend `
            -Legend $Legend `
            -Type $Type `
            -Horizontal:$BarHorizontal `
            -DataLabelsEnabled $BarDataLabelsEnabled `
            -DataLabelsOffsetX $BarDataLabelsOffsetX `
            -DataLabelsFontSize $BarDataLabelsFontSize `
            -Distributed:$BarDistributed `
            -DataLabelsColor $BarDataLabelsColor `
            -Height $Height `
            -Width $Width `
            -Colors $Colors `
            -ChartAxisX $ChartAxisX `
            -ChartAxisY $ChartAxisY `
            -Theme $Theme -Toolbar $Toolbar -GridOptions $GridOptions -PatternedColors:$Patterned -GradientColors:$Gradient -Events $Events -Title $TitleBlock -SubTitle $SubTitleBlock
    } elseif ($Type -eq 'Line') {
        if (-not $ChartAxisX) {
            Write-Warning -Message 'Chart Category (Chart Axis X) is missing.'
            return
        }
        New-HTMLChartLine -Data $DataSet `
            -Legend $Legend `
            -DataNames $DataName `
            -DataLabelsEnabled $BarDataLabelsEnabled `
            -DataLabelsOffsetX $BarDataLabelsOffsetX `
            -DataLabelsFontSize $BarDataLabelsFontSize `
            -DataLabelsColor $BarDataLabelsColor `
            -LineColor $Colors `
            -LineCurve $LineCurves `
            -LineWidth $LineWidths `
            -LineDash $LineDashes `
            -LineCap $LineCaps `
            -ChartAxisX $ChartAxisX `
            -ChartAxisY $ChartAxisY `
            -Height $Height -Width $Width `
            -Theme $Theme -Toolbar $Toolbar -GridOptions $GridOptions -PatternedColors:$Patterned -GradientColors:$Gradient -Events $Events -Title $TitleBlock -SubTitle $SubTitleBlock

    } elseif ($Type -eq 'Pie' -or $Type -eq 'Donut') {
        New-HTMLChartPie `
            -Legend $Legend `
            -Type $Type `
            -Data $DataSet `
            -DataNames $DataName `
            -Colors $Colors `
            -Height $Height -Width $Width `
            -Theme $Theme -Toolbar $Toolbar -GridOptions $GridOptions -PatternedColors:$Patterned -GradientColors:$Gradient -Events $Events -Title $TitleBlock -SubTitle $SubTitleBlock
    } elseif ($Type -eq 'Spark') {
        New-HTMLChartSpark `
            -Legend $Legend `
            -Data $DataSet `
            -DataNames $DataName `
            -Colors $Colors `
            -Height $Height -Width $Width `
            -Theme $Theme -Toolbar $Toolbar -GridOptions $GridOptions -PatternedColors:$Patterned -GradientColors:$Gradient -Events $Events -Title $TitleBlock -SubTitle $SubTitleBlock
    } elseif ($Type -eq 'Radial') {
        New-HTMLChartRadial `
            -Legend $Legend `
            -Data $DataSet `
            -DataNames $DataName `
            -Colors $Colors `
            -Height $Height -Width $Width `
            -Theme $Theme -Toolbar $Toolbar -GridOptions $GridOptions -PatternedColors:$Patterned -GradientColors:$Gradient -Events $Events -Title $TitleBlock -SubTitle $SubTitleBlock
    } elseif ($Type -eq 'rangeBar') {
        New-HTMLChartTimeLine `
            -Legend $Legend `
            -Data $DataSetChartTimeLine `
            -Height $Height -Width $Width `
            -Theme $Theme -Toolbar $Toolbar `
            -ChartAxisX $ChartAxisX `
            -ChartAxisY $ChartAxisY `
            -ChartToolTip $ChartToolTip `
            -GridOptions $GridOptions -PatternedColors:$Patterned -GradientColors:$Gradient `
            -DataLabel $DataLabel -Events $Events -Title $TitleBlock -SubTitle $SubTitleBlock
    }
}

Register-ArgumentCompleter -CommandName New-HTMLChart -ParameterName TitleColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLChart -ParameterName SubTitleColor -ScriptBlock $Script:ScriptBlockColors
Function New-HTMLCodeBlock {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)][String] $Code,
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'assembly', 'asm', 'avrassembly', 'avrasm', 'c', 'cpp', 'c++', 'csharp',
            'css', 'cython', 'cordpro', 'diff', 'docker', 'dockerfile', 'generic', 'standard', 'groovy', 'go',
            'golang', 'html', 'ini', 'conf', 'java', 'js', 'javascript', 'jquery', 'mootools', 'ext.js', 'json',
            'kotlin', 'less', 'lua', 'gfm', 'md', 'markdown', 'octave', 'matlab', 'nsis', 'php', 'powershell', 'prolog',
            'py', 'python', 'raw', 'ruby', 'rust', 'scss', 'sass', 'shell', 'bash', 'sql',
            'squirrel', 'swift', 'typescript', 'vhdl', 'visualbasic', 'vb', 'xml', 'yaml'
        )][String] $Style = 'powershell',
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'enlighter', 'beyond', 'classic', 'godzilla', 'atomic', 'droide',
            'minimal', 'eclipse', 'mowtwo', 'rowhammer', 'bootstrap4', 'dracula', 'monokai'
        )][String] $Theme,
        [Parameter(Mandatory = $false)][String] $Group,
        [Parameter(Mandatory = $false)][String] $Title,
        [Parameter(Mandatory = $false)][String[]] $Highlight,
        [Parameter(Mandatory = $false)][nullable[bool]] $ShowLineNumbers,
        [Parameter(Mandatory = $false)][String] $LineOffset
    )
    $Script:HTMLSchema.Features.Main = $true
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.CodeBlocks = $true
    <# Explanation to fields:
        data-enlighter-language (string) - The language of the codeblock - overrides the global default setting | Block+Inline Content option
        data-enlighter-theme (string) - The theme of the codeblock - overrides the global default setting | Block+Inline Content option
        data-enlighter-group (string) - The identifier of the codegroup where the codeblock belongs to | Block Content option
        data-enlighter-title (string) - The title/name of the tab | Block Content option
        data-enlighter-linenumbers (boolean) - Show/Hide the linenumbers of a codeblock (Values: "true", "false") | Block Content option
        data-enlighter-highlight (string) - A List of lines to point out, comma seperated (ranges are supported) e.g. "2,3,6-10" | Block Content option
        data-enlighter-lineoffset (number) - Start value of line-numbering e.g. "5" to start with line 5 - attribute start of the ol tag is set | Block Content option
    #>

    if ($null -eq $ShowLineNumbers -and $Highlight) {
        $ShowLineNumbers = $true
    }

    $Attributes = [ordered]@{
        'data-enlighter-language'    = "$Style".ToLower()
        'data-enlighter-theme'       = "$Theme".ToLower()
        'data-enlighter-group'       = "$Group".ToLower()
        'data-enlighter-title'       = "$Title"
        'data-enlighter-linenumbers' = "$ShowLineNumbers"
        'data-enlighter-highlight'   = "$Highlight"
        'data-enlighter-lineoffset'  = "$LineOffset".ToLower()
    }

    # Cleanup code (if there are spaces before code it fixes that)
    $ExtraCode = $Code.Split([System.Environment]::NewLine)
    [int] $Length = 5000
    $NewCode = foreach ($Line in $ExtraCode) {
        if ($Line.Trim() -ne '') {
            [int] $TempLength = $Line.Length - (($Line -replace '^(\s+)').Length)
            #$TempLength = ($line -replace '^(\s+).+$', '$1').Length
            if ($TempLength -le $Length) {
                $Length = $TempLength
            }
            $Line
        }
    }
    $FixedCode = foreach ($Line in $NewCode) {
        $Line.Substring($Length)
    }
    $FinalCode = $FixedCode -join [System.Environment]::NewLine
    # Prepare HTML
    New-HTMLTag -Tag 'pre' -Attributes $Attributes {
        $FinalCode
    }
}

function New-HTMLContainer {
    [alias('Container')]
    [CmdletBinding()]
    param(
        [alias('Content')][Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $HTML,
        [object] $Width = '100%',
        [string] $Margin,
        [string] $AnchorName
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    if (-not $AnchorName) {
        $AnchorName = "anchor-$(Get-RandomStringName -Size 7)"
    }
    if ($Width -or $Margin) {
        [string] $ClassName = "flexElement$(Get-RandomStringName -Size 8 -LettersOnly)"
        $Attributes = @{
            'flex-basis' = ConvertFrom-Size -Size $Width
            'margin'     = if ($Margin) { $Margin }
        }
        $Css = ConvertTo-LimitedCSS -ClassName $ClassName -Attributes $Attributes

        # $Script:HTMLSchema.CustomHeaderCSS.Add($Css)
        $Script:HTMLSchema.CustomHeaderCSS[$AnchorName] = $Css
        [string] $Class = "$ClassName overflowHidden"
    } else {
        [string] $Class = 'flexElement overflowHidden'
    }
    New-HTMLTag -Tag 'div' -Attributes @{ class = $Class } {
        if ($HTML) {
            Invoke-Command -ScriptBlock $HTML
        }
    }
}
function New-HTMLDiagram {
    [alias('Diagram', 'New-Diagram')]
    [CmdletBinding()]
    param(
        [ScriptBlock] $Diagram,
        [object] $Height,
        [object] $Width,
        [switch] $BundleImages,
        [uri] $BackGroundImage,
        [string] $BackgroundSize = '100% 100%',
        [switch] $NoAutoResize, # Doesn't seem to do anything
        [switch] $DisableLoader
    )
    if (-not $Script:HTMLSchema.Features) {
        Write-Warning 'New-HTMLDiagram - Creation of HTML aborted. Most likely New-HTML is missing.'
        Exit
    }
    $Script:HTMLSchema.Features.MainFlex = $true

    $DataEdges = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $DataNodes = [ordered] @{ }
    $DataEvents = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()

    [Array] $Settings = & $Diagram
    foreach ($Node in $Settings) {
        if ($Node.Type -eq 'DiagramNode') {
            $ID = $Node.Settings['id']
            $DataNodes[$ID] = $Node.Settings
            #$DataEdges.Add($Node.Edges)
            foreach ($From in $Node.Edges.From) {
                foreach ($To in $Node.Edges.To) {
                    $Edge = Copy-Dictionary -Dictionary $Node.Edges  #$Node.Edges.Clone()
                    $Edge['from'] = $From
                    $Edge['to'] = $To
                    $DataEdges.Add($Edge)
                }
            }
        } elseif ($Node.Type -eq 'DiagramOptionsInteraction') {
            $DiagramOptionsInteraction = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsManipulation') {
            $DiagramOptionsManipulation = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsPhysics') {
            $DiagramOptionsPhysics = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsLayout') {
            $DiagramOptionsLayout = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsNodes') {
            $DiagramOptionsNodes = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramOptionsEdges') {
            $DiagramOptionsEdges = $Node.Settings
        } elseif ($Node.Type -eq 'DiagramLink') {
            if ($Node.Settings.From -and $Node.Settings.To) {
                foreach ($From in $Node.Settings.From) {
                    foreach ($To in $Node.Settings.To) {
                        $Edge = $Node.Edges.Clone()
                        $Edge['from'] = $From
                        $Edge['to'] = $To
                        $DataEdges.Add($Edge)
                    }
                }
            }
            $DataEdges.Add($Node.Edges)
        } elseif ($Node.Type -eq 'DiagramEvent') {
            $DataEvents.Add($Node.Settings)
        }
    }
    <#
    {id: 14, shape: 'circularImage', image: DIR + '14.png'},
    {id: 15, shape: 'circularImage', image: DIR + 'missing.png', brokenImage: DIR + 'missingBrokenImage.png', label:"when images\nfail\nto load"},
    {id: 16, shape: 'circularImage', image: DIR + 'anotherMissing.png', brokenImage: DIR + '9.png', label:"fallback image in action"}
    {id: 5, label:'colorObject', color: {background:'pink', border:'purple'}},
    {id: 6, label:'colorObject + highlight', color: {background:'#F03967', border:'#713E7F',highlight:{background:'red',border:'black'}}},
    {id: 7, label:'colorObject + highlight + hover', color: {background:'cyan', border:'blue',highlight:{background:'red',border:'blue'},hover:{background:'white',border:'red'}}}
    {id: 1,label: 'User 1',group: 'users'},
    {id: 2,label: 'User 2',group: 'users'},
    {id: 3,label: 'Usergroup 1',group: 'usergroups'}
    nodes.push({id: 1, label: 'Main', image: DIR + 'Network-Pipe-icon.png', shape: 'image'});
    nodes.push({id: 2, label: 'Office', image: DIR + 'Network-Pipe-icon.png', shape: 'image'});
    nodes.push({id: 3, label: 'Wireless', image: DIR + 'Network-Pipe-icon.png', shape: 'image'});
    {id: 3,  shape: 'image', image: DIR + '3.png', label: "imagePadding{2,10,8,20}+size", imagePadding: { left: 2, top: 10, right: 8, bottom: 20}, size: 40, color: { border: 'green', background: 'yellow', highlight: { border: 'yellow', background: 'green' }, hover: { border: 'orange', background: 'grey' } } },
    {id: 9,  shape: 'image', image: DIR + '9.png', label: "useImageSize + imagePadding:15", shapeProperties: { useImageSize: true }, imagePadding: 30, color: { border: 'blue', background: 'orange', highlight: { border: 'orange', background: 'blue' }, hover: { border: 'orange', background: 'grey' } } },
    var url = "data:image/svg+xml;charset=utf-8,"+ encodeURIComponent(svg);
    {id: 2, label: 'Using SVG', image: url, shape: 'image'}

    #>

    $IconsAvailable = $false
    [Array] $Nodes = foreach ($_ in $DataNodes.Keys) {
        if ($DataNodes[$_]['image']) {
            if ($BundleImages) {
                $DataNodes[$_]['image'] = Convert-Image -Image $DataNodes[$_]['image']
            }
        }
        $NodeJson = $DataNodes[$_] | ConvertTo-JsonLiteral -Depth 5 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' } #| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
        if ($DataNodes[$_].icon) {
            $IconsAvailable = $true
        }
        # We need to fix wrong escaped chars, Unescape breaks other parts
        $Replace = @{
            '"\"Font Awesome 5 Solid\""'        = "'`"Font Awesome 5 Solid`"'"
            '"\"Font Awesome 5 Brands\""'       = "'`"Font Awesome 5 Brands`"'"
            '"\"Font Awesome 5 Regular\""'      = "'`"Font Awesome 5 Regular`"'"
            '"\"Font Awesome 5 Free\""'         = "'`"Font Awesome 5 Free`"'"
            '"\"Font Awesome 5 Free Regular\""' = "'`"Font Awesome 5 Free Regular`"'"
            '"\"Font Awesome 5 Free Solid\""'   = "'`"Font Awesome 5 Free Solid`"'"
            '"\"Font Awesome 5 Free Brands\""'  = "'`"Font Awesome 5 Free Brands`"'"
            '"\\u'                              = '"\u'
        }
        foreach ($R in $Replace.Keys) {
            $NodeJson = $NodeJson.Replace($R, $Replace[$R])
        }
        $NodeJson
    }
    [Array] $Edges = foreach ($_ in $DataEdges) {
        $_ | ConvertTo-JsonLiteral -Depth 5 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' } #| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
    }

    $Options = @{
        autoResize = -not $NoAutoResize.IsPresent # Doesn't seem to do anything
    }
    if ($DiagramOptionsInteraction) {
        if ($DiagramOptionsInteraction['interaction']) {
            $Options['interaction'] = $DiagramOptionsInteraction['interaction']
        }
    }
    if ($DiagramOptionsManipulation) {
        if ($DiagramOptionsManipulation['manipulation']) {
            $Options['manipulation'] = $DiagramOptionsManipulation['manipulation']
        }
    }
    if ($DiagramOptionsPhysics) {
        if ($DiagramOptionsPhysics['physics']) {
            $Options['physics'] = $DiagramOptionsPhysics['physics']
        }
    }
    if ($DiagramOptionsLayout) {
        if ($DiagramOptionsLayout['layout']) {
            $Options['layout'] = $DiagramOptionsLayout['layout']
        }
    }
    if ($DiagramOptionsEdges) {
        if ($DiagramOptionsEdges['edges']) {
            $Options['edges'] = $DiagramOptionsEdges['edges']
        }
    }
    if ($DiagramOptionsNodes) {
        if ($DiagramOptionsNodes['nodes']) {
            $Options['nodes'] = $DiagramOptionsNodes['nodes']
        }
    }

    if ($BundleImages -and $BackGroundImage) {
        $Image = Convert-Image -Image $BackGroundImage
    } else {
        $Image = $BackGroundImage
    }

    New-InternalDiagram -Nodes $Nodes -Edges $Edges -Options $Options -Width $Width -Height $Height -BackgroundImage $Image -Events $DataEvents -IconsAvailable:$IconsAvailable -DisableLoader:$DisableLoader
}

function New-HTMLFooter {
    [alias('Footer')]
    [CmdletBinding()]
    param(
        [scriptblock] $HTMLContent
    )
    if ($HTMLContent) {
        [PSCustomObject] @{
            Type   = 'Footer'
            Output = & $HTMLContent
        }
    }
}
function New-HTMLGage {
    [CmdletBinding()]
    param (
        [scriptblock] $GageContent,
        [validateSet('Gage', 'Donut')][string] $Type = 'Gage',
        [string] $BackgroundGaugageColor,
        [parameter(Mandatory)][decimal] $Value,
        [string] $ValueSymbol,
        [string] $ValueColor,
        [string] $ValueFont,
        [nullable[int]] $MinValue,
        [string] $MinText,
        [nullable[int]] $MaxValue,
        [string] $MaxText,
        [switch] $Reverse,
        [int] $DecimalNumbers,
        [decimal] $GaugageWidth,
        [string] $Title,
        [string] $Label,
        [string] $LabelColor,
        [switch] $Counter,
        [switch] $ShowInnerShadow,
        [switch] $NoGradient,
        [nullable[decimal]] $ShadowOpacity,
        [nullable[int]] $ShadowSize,
        [nullable[int]] $ShadowVerticalOffset,
        [switch] $Pointer,
        [nullable[int]]  $PointerTopLength,
        [nullable[int]] $PointerBottomLength,
        [nullable[int]] $PointerBottomWidth,
        [string] $StrokeColor,
        #[validateSet('none')][string] $PointerStroke,
        [nullable[int]] $PointerStrokeWidth,
        [validateSet('none', 'square', 'round')] $PointerStrokeLinecap,
        [string] $PointerColor,
        [switch] $HideValue,
        [switch] $HideMinMax,
        [switch] $FormatNumber,
        [switch] $DisplayRemaining,
        [switch] $HumanFriendly,
        [int] $HumanFriendlyDecimal,
        [string[]] $SectorColors
    )
    # Make sure JustGage JS is added to source
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.Raphael = $true
    $Script:HTMLSchema.Features.JustGage = $true

    # Build Options
    [string] $ID = "Gage" + (Get-RandomStringName -Size 8)
    $Gage = [ordered] @{
        id    = $ID
        value = $Value
    }

    # When null it will be removed as part of cleanup Remove-EmptyValue
    $Gage.shadowSize = $ShadowSize
    $Gage.shadowOpacity = $ShadowOpacity
    $Gage.shadowVerticalOffset = $ShadowVerticalOffset

    if ($DecimalNumbers) {
        $Gage.decimals = $DecimalNumbers
    }
    if ($Title) {
        $Gage.title = $Title
    }
    if ($ValueColor) {
        $Gage.valueFontColor = $ValueColor
    }
    if ($ValueColor) {
        $Gage.valueFontFamily = $ValueFont
    }
    if ($MinText) {
        $Gage.minText = $MinText
    }
    if ($MaxText) {
        $Gage.maxText = $MaxText
    }

    $Gage.min = $MinValue
    $Gage.max = $MaxValue

    if ($Label) {
        $Gage.label = $Label
    }
    if ($LabelColor) {
        $Gage.labelFontColor = ConvertFrom-Color -Color $LabelColor
    }
    if ($Reverse) {
        $Gage.reverse = $Reverse.IsPresent
    }
    if ($Type -eq 'Donut') {
        $Gage.donut = $true
    }
    if ($GaugageWidth) {
        $Gage.gaugageWidthScale = $GaugageWidthScale
    }
    if ($Counter) {
        $Gage.counter = $Counter.IsPresent
    }
    if ($showInnerShadow) {
        $Gage.showInnerShadow = $ShowInnerShadow.IsPresent
    }
    if ($BackgroundGaugageColor) {
        $Gage.gaugeColor = ConvertFrom-Color -Color $BackgroundGaugageColor
    }
    if ($NoGradient) {
        $Gage.noGradient = $NoGradient.IsPresent
    }

    if ($HideMinMax) {
        $Gage.hideMinMax = $HideMinMax.IsPresent
    }
    if ($HideValue) {
        $Gage.hideValue = $HideValue.IsPresent
    }
    if ($FormatNumber) {
        $Gage.formatNumber = $FormatNumber.IsPresent
    }
    if ($DisplayRemaining) {
        $Gage.displayRemaining = $DisplayRemaining.IsPresent
    }
    if ($HumanFriendly) {
        $Gage.humanFriendly = $HumanFriendly.IsPresent
        if ($HumanFriendlyDecimal) {
            $Gage.humanFriendlyDecimal = $HumanFriendlyDecimal
        }
    }
    if ($ValueSymbol) {
        $Gage.symbol = $ValueSymbol
    }

    if ($GageContent) {
        [Array] $GageOutput = & $GageContent
        if ($GageOutput.Count -gt 0) {
            $Gage.customSectors = @{
                percents = $true
                ranges   = $GageOutput
            }
        }
    }



    if ($Pointer) {
        $Gage.pointer = $Pointer.IsPresent

        $Gage.pointerOptions = @{ }
        #if ($PointerToplength) {
        $Gage.pointerOptions.toplength = $PointerTopLength
        #}
        #if ($PointerBottomLength) {
        $Gage.pointerOptions.bottomlength = $PointerBottomLength
        #}
        #if ($PointerBottomWidth) {
        $Gage.pointerOptions.bottomwidth = $PointerBottomWidth
        #}
        #if ($PointerStroke) {

        #}
        #if ($PointerStrokeWidth) {
        $Gage.pointerOptions.stroke_width = $PointerStrokeWidth
        #}
        #if ($PointerStrokeLinecap) {
        $Gage.pointerOptions.stroke_linecap = $PointerStrokeLinecap
        #}
        #if ($PointerColor) {
        $Gage.pointerOptions.color = ConvertFrom-Color -Color $PointerColor
        #}
        #if ($StrokeColor) {
        $Gage.pointerOptions.stroke = ConvertFrom-Color -Color $StrokeColor
        #}
    }
    $gage.relativeGaugeSize = $true
    Remove-EmptyValue -Hashtable $Gage -Rerun 1 -Recursive

    # Build HTML
    $Div = New-HTMLTag -Tag 'div' -Attributes @{ id = $Gage.id; }

    $Script = New-HTMLTag -Tag 'script' -Value {
        # Convert Dictionary to JSON and return chart within SCRIPT tag
        # Make sure to return with additional empty string
        $JSON = $Gage | ConvertTo-Json -Depth 5 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
        "document.addEventListener(`"DOMContentLoaded`", function (event) {"
        "var g1 = new JustGage( $JSON );"
        "});"
    } -NewLine

    # Return Data
    $Div
    $Script
}
Register-ArgumentCompleter -CommandName New-HTMLGage -ParameterName GaugageColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLGage -ParameterName LabelColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLGage -ParameterName ValueColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLGage -ParameterName PointerColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLGage -ParameterName StrokeColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLGage -ParameterName SectorColors -ScriptBlock $Script:ScriptBlockColors

<#
| | Name                 | Default                           | Description                                                                         |
|-| -------------------- | --------------------------------- | ----------------------------------------------------------------------------------- |
|+| id                   | (required)                        | The HTML container element id                                                       |
|+| value                | 0                                 | Value Gauge is showing                                                              |
| | parentNode           | null                              | The HTML container element object. Used if id is not present                        |
| | defaults             | false                             | Defaults parameters to use globally for gauge objects                               |
| | width                | null                              | The Gauge width in pixels (Integer)                                                 |
| | height               | null                              | The Gauge height in pixels                                                          |
|+| valueFontColor       | #010101                           | Color of label showing current value                                                |
|+| valueFontFamily      | Arial                             | Font of label showing current value                                                 |
|+| symbol               | ''                                | Special symbol to show next to value                                                |
|+| min                  | 0                                 | Min value                                                                           |
|+| minTxt               | false                             | Min value text, overrides min if specified                                          |
|+| max                  | 100                               | Max value                                                                           |
|+| maxTxt               | false                             | Max value text, overrides max if specified                                          |
|+| reverse              | false                             | Reverse min and max                                                                 |
|+| humanFriendlyDecimal | 0                                 | Number of decimal places for our human friendly number to contain                   |
| | textRenderer         | null                              | Function applied before redering text (value) => value                              |
| | onAnimationEnd       | null                              | Function applied after animation is done                                            |
|+| gaugeWidthScale      | 1.0                               | Width of the gauge element                                                          |
|+| gaugeColor           | #edebeb                           | Background color of gauge element                                                   |
|+| label                | ''                                | Text to show below value                                                            |
|+| labelFontColor       | #b3b3b3                           | Color of label showing label under value                                            |
|+| shadowOpacity        | 0.2                               | Shadow opacity 0 ~ 1                                                                |
|+| shadowSize           | 5                                 | Inner shadow size                                                                   |
|+| shadowVerticalOffset | 3                                 | How much shadow is offset from top                                                  |
|+| levelColors          | ["#a9d70b", "#f9c802", "#ff0000"] | Colors of indicator, from lower to upper, in RGB format                             |
| | startAnimationTime   | 700                               | Length of initial animation in milliseconds                                         |
| | startAnimationType   | >                                 | Type of initial animation (linear, >, <, <>, bounce)                                |
| | refreshAnimationTime | 700                               | Length of refresh animation in milliseconds                                         |
| | refreshAnimationType | >                                 | Type of refresh animation (linear, >, <, <>, bounce)                                |
| | donutStartAngle      | 90                                | Angle to start from when in donut mode                                              |
| | valueMinFontSize     | 16                                | Absolute minimum font size for the value label                                      |
| | labelMinFontSize     | 10                                | Absolute minimum font size for the label                                            |
| | minLabelMinFontSize  | 10                                | Absolute minimum font size for the min label                                        |
| | maxLabelMinFontSize  | 10                                | Absolute minimum font size for the man label                                        |
|+| hideValue            | false                             | Hide value text                                                                     |
|+| hideMinMax           | false                             | Hide min/max text                                                                   |
|+| showInnerShadow      | false                             | Show inner shadow                                                                   |
|+| humanFriendly        | false                             | convert large numbers for min, max, value to human friendly (e.g. 1234567 -> 1.23M) |
|+| noGradient           | false                             | Whether to use gradual color change for value, or sector-based                      |
|+| donut                | false                             | Show donut gauge                                                                    |
|*| relativeGaugeSize    | false                             | Whether gauge size should follow changes in container element size                  |
|+| counter              | false                             | Animate text value number change                                                    |
|+| decimals             | 0                                 | Number of digits after floating point                                               |
| | customSectors        | {}                                | Custom sectors colors. Expects an object                                            |
|+| formatNumber         | false                             | Formats numbers with commas where appropriate                                       |
|x| pointer              | false                             | Show value pointer                                                                  |
|x| pointerOptions       | {}                                | Pointer options. Expects an object                                                  |
|+| displayRemaining     | false                             | Replace display number with the value remaining to reach max value                  |
#>

<#
pointerOptions: {
  toplength: null,
  bottomlength: null,
  bottomwidth: null,
  stroke: 'none',
  stroke_width: 0,
  stroke_linecap: 'square',
  color: '#000000'
}
#>
<#
customSectors: {
  percents: true, // lo and hi values are in %
  ranges: [{
    color : "#43bf58",
    lo : 0,
    hi : 50
  },
  {
    color : "#ff3b30",
    lo : 51,
    hi : 100
  }]
}
#>
function New-HTMLHeader {
    [alias('Header')]
    [CmdletBinding()]
    param(
        [scriptblock] $HTMLContent
    )

    if ($HTMLContent) {
        [PSCustomObject] @{
            Type   = 'Header'
            Output = & $HTMLContent
        }
    }
}
Function New-HTMLHeading {
    [CmdletBinding()]
    Param (
        [validateset('h1', 'h2', 'h3', 'h4', 'h5', 'h6')][string] $Heading,
        [string] $HeadingText,
        [switch] $Underline,
        [string] $Color
    )
    $Script:HTMLSchema.Features.DefaultHeadings = $true
    if ($null -ne $Color) {
        $RGBcolor = ConvertFrom-Color -Color $Color
        $Attributes = @{
            style = @{ color = $RGBcolor }
        }
    } else {
        $Attributes = @{ }
    }
    if ($Underline) {
        $Attributes.Class = "$($Attributes.Class) underline"
    }
    New-HTMLTag -Tag $Heading -Attributes $Attributes {
        $HeadingText
    }
}
Register-ArgumentCompleter -CommandName New-HTMLHeading -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-HTMLHierarchicalTree {
    [cmdletBinding()]
    param(
        [ScriptBlock] $TreeView
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.D3Mitch = $true

    [string] $ID = "HierarchicalTree-" + (Get-RandomStringName -Size 8)

    $TreeNodes = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()

    [Array] $Settings = & $TreeView
    foreach ($Object in $Settings) {
        if ($Object.Type -eq 'TreeNode') {
            $TreeNodes.Add($Object.Settings)
        }
    }

    # Prepare NODES
    $Data = $TreeNodes | ConvertTo-Json -Depth 5

    # Prepare HTML
    $Section = New-HTMLTag -Tag 'section' -Attributes @{ id = $ID; class = 'hierarchicalTree' }
    $Script = New-HTMLTag -Tag 'script' -Value { @"
        var data = $Data;
        var treePlugin = new d3.mitchTree.boxedTree()
        .setIsFlatData(true)
        .setData(data)
        .setElement(document.getElementById("$ID"))
        .setIdAccessor(function (data) {
            return data.id;
        })
        .setParentIdAccessor(function (data) {
            return data.parentId;
        })
        .setBodyDisplayTextAccessor(function (data) {
            return data.description;
        })
        .setTitleDisplayTextAccessor(function (data) {
            return data.name;
        })
        .initialize();
"@
    } -NewLine

    # Send HTML
    $Section
    $Script
}
function New-HTMLHorizontalLine {
    [CmdletBinding()]
    param()
    New-HTMLTag -Tag 'hr' -SelfClosing
}
function New-HTMLImage {
    <#
    .SYNOPSIS
    Creates IMG tag with image link or image bundled inline

    .DESCRIPTION
    Creates IMG tag with image link or image bundled inline

    .PARAMETER Source
    Link to an image or file path to an image

    .PARAMETER UrlLink
    Specifies the URL of the page the link goes to when user clicks an image

    .PARAMETER AlternativeText
    Specifies an alternate text for the image, if the image for some reason cannot be displayed

    .PARAMETER Class
    Overwrites default CSS settings for links

    .PARAMETER Target
    The target attribute specifies where to open the linked document.

    - _blank	Opens the linked document in a new window or tab
    - _self	Opens the linked document in the same frame as it was clicked (this is default)
    - _parent	Opens the linked document in the parent frame
    - _top	Opens the linked document in the full body of the window

    Additionally framename can be given. Default is _blank

    .PARAMETER Width
    Width of an image (optional)

    .PARAMETER Height
    Height of an image (optional)

    .PARAMETER Inline
    Inserts given Image URL/File directly into HTML

    .EXAMPLE
    New-HTMLImage -Source 'https://evotec.pl/image.png' -UrlLink 'https://evotec.pl/' -AlternativeText 'My other text' -Class 'otehr' -Width '100%'

    .NOTES
    General notes
    #>
    [alias('Image', 'EmailImage')]
    [CmdletBinding()]
    param(
        [string] $Source,
        [Uri] $UrlLink = '',
        [string] $AlternativeText = '',
        [string] $Class = 'logo',
        [string] $Target = '_blank',
        [object] $Width,
        [object] $Height,
        [switch] $Inline,
        [Parameter(DontShow)][switch] $DisableCache
    )
    $Script:HTMLSchema.Features.DefaultImage = $true

    if ($Inline) {
        # Cache makes sure that file is downloaded once and can be reused over and over until cache is reset
        # Resetting of cache is done automatically on module reload
        # This can be very useful when sending 3000 emails with same logo
        $BinaryImage = Convert-Image -Image $Source -Cache:(-not $DisableCache)
    }

    New-HTMLTag -Tag 'div' -Attributes @{ class = $Class.ToLower() } {
        $AAttributes = [ordered]@{
            'target' = $Target
            'href'   = $UrlLink
        }
        New-HTMLTag -Tag 'a' -Attributes $AAttributes {
            if ($Inline) {
                $ImgAttributes = [ordered]@{
                    'src'    = "$BinaryImage"
                    'alt'    = "$AlternativeText"
                    'width'  = ConvertFrom-Size -Size $Width
                    'height' = ConvertFrom-Size -Size $Height
                }
            } else {
                $ImgAttributes = [ordered]@{
                    'src'    = "$Source"
                    'alt'    = "$AlternativeText"
                    'width'  = ConvertFrom-Size -Size $Width
                    'height' = ConvertFrom-Size -Size $Height
                }
            }
            New-HTMLTag -Tag 'img' -Attributes $ImgAttributes
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLImage -ParameterName Target -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    @('_blank', '_self', '_parent', '_top') | Where-Object { $_ -like "*$wordToComplete*" }
}
function New-HTMLList {
    [alias('EmailList')]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][ScriptBlock]$ListItems,
        [ValidateSet('Unordered', 'Ordered')] [string] $Type = 'Unordered',
        [string] $Color,
        [string] $BackGroundColor,
        [object] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        [switch] $LineBreak,
        [switch] $Reversed
    )

    $newHTMLSplat = @{ }
    if ($Alignment) {
        $newHTMLSplat.Alignment = $Alignment
    }
    if ($FontSize) {
        $newHTMLSplat.FontSize = $FontSize
    }
    if ($TextTransform) {
        $newHTMLSplat.TextTransform = $TextTransform
    }
    if ($Color) {
        $newHTMLSplat.Color = $Color
    }
    if ($FontFamily) {
        $newHTMLSplat.FontFamily = $FontFamily
    }
    if ($Direction) {
        $newHTMLSplat.Direction = $Direction
    }
    if ($FontStyle) {
        $newHTMLSplat.FontStyle = $FontStyle
    }
    if ($TextDecoration) {
        $newHTMLSplat.TextDecoration = $TextDecoration
    }
    if ($BackGroundColor) {
        $newHTMLSplat.BackGroundColor = $BackGroundColor
    }
    if ($FontVariant) {
        $newHTMLSplat.FontVariant = $FontVariant
    }
    if ($FontWeight) {
        $newHTMLSplat.FontWeight = $FontWeight
    }
    if ($LineBreak) {
        $newHTMLSplat.LineBreak = $LineBreak
    }

    [bool] $SpanRequired = $false
    foreach ($Entry in $newHTMLSplat.GetEnumerator()) {
        if (($Entry.Value | Measure-Object).Count -gt 0) {
            $SpanRequired = $true
            break
        }
    }

    $ListAttributes = [ordered] @{}
    if ($Reversed) {
        $ListAttributes['reversed'] = 'reversed'
    }
    if ($ListItems) {
        [string] $List = @(
            if ($Type -eq 'Unordered') {
                New-HTMLTag -Tag 'ul' -Attributes $ListAttributes {
                    Invoke-Command -ScriptBlock $ListItems
                }
            } else {
                New-HTMLTag -Tag 'ol' -Attributes $ListAttributes {
                    Invoke-Command -ScriptBlock $ListItems
                }
            }
        )
        if ($SpanRequired) {
            New-HTMLSpanStyle @newHTMLSplat {
                $List
            }
        } else {
            $List
        }
    } else {
        Write-Warning "New-HTMLList - No content provided. Please use New-HTMLListItem inside New-HTMLList."
    }
}

Register-ArgumentCompleter -CommandName New-HTMLList -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLList -ParameterName BackGroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLListItem {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][scriptblock] $NestedListItems,
        [Parameter(Position = 1)][string[]] $Text,
        [Parameter(Position = 2)][string[]] $Color = @(),
        [Parameter(Position = 3)][string[]] $BackGroundColor = @(),
        [object[]] $FontSize = @(),
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string[]] $FontWeight = @(),
        [ValidateSet('normal', 'italic', 'oblique')][string[]] $FontStyle = @(),
        [ValidateSet('normal', 'small-caps')][string[]] $FontVariant = @(),
        [string[]] $FontFamily = @(),
        [ValidateSet('left', 'center', 'right', 'justify')][string[]] $Alignment = @(),
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string[]] $TextDecoration = @(),
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string[]] $TextTransform = @(),
        [ValidateSet('rtl')][string[]] $Direction = @(),
        [switch] $LineBreak
    )

    $newHTMLTextSplat = @{
        Alignment       = $Alignment
        FontSize        = $FontSize
        TextTransform   = $TextTransform
        Text            = $Text
        Color           = $Color
        FontFamily      = $FontFamily
        Direction       = $Direction
        FontStyle       = $FontStyle
        TextDecoration  = $TextDecoration
        BackGroundColor = $BackGroundColor
        FontVariant     = $FontVariant
        FontWeight      = $FontWeight
        LineBreak       = $LineBreak
    }
    <#
    $Style = @{
        style = @{
            'color'            = ConvertFrom-Color -Color $Color
            'background-color' = ConvertFrom-Color -Color $BackGroundColor
            'font-size'        = ConvertFrom-Size -FontSize $FontSize
            'font-weight'      = $FontWeight
            'font-variant'     = $FontVariant
            'font-family'      = $FontFamily
            'font-style'       = $FontStyle
            'text-align'       = $Alignment


            'text-decoration'  = $TextDecoration
            'text-transform'   = $TextTransform
            'direction'        = $Direction
        }
    }
    #>

    New-HTMLTag -Tag 'li' -Attributes $Style -Value {
        New-HTMLText @newHTMLTextSplat -SkipParagraph
        if ($NestedListItems) {
            & $NestedListItems
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLListItem -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLListItem -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLLogo {
    [CmdletBinding()]
    param(
        [String] $LogoPath,
        [string] $LeftLogoName = "Sample",
        [string] $RightLogoName = "Alternate",
        [string] $LeftLogoString,
        [string] $RightLogoString,
        [switch] $HideLogos
    )
    $Script:HTMLSchema.Features.MainImage = $true

    Write-Warning "New-HTMLLogo - This function is deprecated. If you're using it consider letting me know on https://github.com/evotecit/PSWriteHTML"
    Write-Warning "New-HTMLLogo - There will be replacement for this sooner or later."

    $LogoSources = Get-HTMLLogos `
        -RightLogoName $RightLogoName `
        -LeftLogoName $LeftLogoName  `
        -LeftLogoString $LeftLogoString `
        -RightLogoString $RightLogoString

    #Convert-StyleContent1 -Options $Options

    $Options = [PSCustomObject] @{
        Logos        = $LogoSources
        ColorSchemes = $ColorSchemes
    }

    if ($HideLogos -eq $false) {
        $Leftlogo = $Options.Logos[$LeftLogoName]
        $Rightlogo = $Options.Logos[$RightLogoName]
        $Script:HTMLSchema.Logos = @(
            '<!-- START LOGO -->'
            New-HTMLTag -Tag 'div' -Attributes @{ class = 'legacyLogo' } {
                New-HTMLTag -Tag 'div' -Attributes @{ class = 'legacyLeftLogo' } {
                    New-HTMLTag -Tag 'img' -Attributes @{ src = "$LeftLogo"; class = 'legacyImg' } -SelfClosing
                }
                New-HTMLTag -Tag 'div' -Attributes @{ class = 'legacyRightLogo' } {
                    New-HTMLTag -Tag 'img' -Attributes @{ src = "$RightLogo"; class = 'legacyImg' } -SelfClosing
                }
            }
            '<!-- END LOGO -->'
        ) -join ''
    }
}
function New-HTMLMain {
    [alias('Main')]
    [CmdletBinding()]
    param(
        [scriptblock] $HTMLContent,
        [string] $BackgroundColor,
        [string] $Color,
        [string] $FontFamily,
        [object] $FontSize
    )
    # gets current configuration for Main.CSS
    $CssConfiguration = Get-ConfigurationCss -Feature 'Main' -Type 'HeaderAlways'

    # Sets body style to new values
    $BodyStyle = @{
        'background-color' = ConvertFrom-Color -Color $BackgroundColor
        'color'            = ConvertFrom-Color -Color $Color
        'font-family'      = $FontFamily
        'font-size'        = ConvertFrom-Size -TextSize $FontSize
    }
    Add-ConfigurationCSS -CSS $CssConfiguration -Name 'body' -Inject $BodyStyle
    # We set the same size for input as for body to keep them in sync.
    # You can still overwrite this values on tables or inputs if required
    $InputStyle = @{
        'font-size' = ConvertFrom-Size -TextSize $FontSize
    }
    Add-ConfigurationCSS -CSS $CssConfiguration -Name 'input' -Inject $InputStyle

    #$TableStyle = @{
    #'font-size' = ConvertFrom-Size -TextSize $FontSize
    #}
    #Add-ConfigurationCSS -CSS $CssConfiguration -Name 'table' -Inject $TableStyle

    # if HTML Content is given send it further down
    if ($HTMLContent) {
        # push this to New-HTML
        [PSCustomObject] @{
            Type   = 'Main'
            Output = & $HTMLContent
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLMain -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLMain -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-HTMLMap {
    [cmdletBinding()]
    param(
        [parameter(Mandatory)][ValidateSet('poland', 'usa_states', 'world_countries')][string] $Map,
        [string] $AnchorName
    )
    Enable-HTMLFeature -Feature Raphael, Mapael, Jquery, JQueryMouseWheel, "MapaelMaps_$Map" -Configuration $Script:Configuration.Features
    if (-not $AnchorName) {
        $AnchorName = "MapContainer$(Get-RandomStringName -Size 8)"
    }
    $Options = @{
        map = @{
            name = $Map.ToLower()
        }
    }
    $OptionsJSON = $Options | ConvertTo-JsonLiteral -Depth 2 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' }

    New-HTMLTag -Tag 'script' {
        "`$(function () { `$(`".$AnchorName`").mapael($OptionsJSON); });"
    }

    New-HTMLTag -Tag 'div' -Attributes @{ class = $AnchorName } {
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'map' } {
            $AlternateHTML
        }
    }
}
function New-HTMLNav {
    [cmdletBinding()]
    param(
        [ScriptBlock] $NavigationLinks
    )
    $Script:HTMLSchema.Features.Navigation = $true

    New-HTMLTag -Tag 'div' -Attributes @{ class = 'primary-nav' } {
        New-HTMLTag -Tag 'button' -Attributes @{ href = '#'; class = 'hamburger open-panel nav-toggle' } {
            New-HTMLTag -Tag 'span' -Attributes @{ class = 'screen-reader-text' } { 'Menu' }
        }
        New-HTMLTag -Tag 'nav' -Attributes @{ role = 'navigation'; class = 'menu' } {
            New-HTMLTag -Tag 'a' -Attributes @{ href = '#'; class = 'logotype' } {
                New-HTMLText -Text 'LOGO TYPE'
            }
            New-HTMLTag -Tag 'div' -Attributes @{ class = 'overflow-container' } {
                New-HTMLTag -Tag 'ul' -Attributes @{ class = 'menu-dropdown' } {
                    if ($NavigationLinks) {
                        & $NavigationLinks
                    }
                }
            }
        }
    }
}
function New-HTMLNavHam {
    param(

    )
    #$Script:HTMLSchema.Features.NavigationMenu = $true
    $Script:HTMLSchema.Features.NavigationMultilevel = $true
    $Script:HTMLSchema.Features.FontsAwesome = $true
    $Script:HTMLSchema.Features.Jquery = $true

    @"
<div id="menu">
            <nav>
                <h2><i class="fas fa-bars text-danger"></i>All Categories</h2>
                <ul>
                    <li>
                        <a href="#"><i class="fa fa-laptop"></i>Devices</a>
                        <h2><i class="fa fa-laptop"></i>Devices</h2>
                        <ul>
                            <li>
                                <a href="#"><i class="fa fa-phone"></i>Mobile Phones</a>
                                <h2><i class="fa fa-phone"></i>Mobile Phones</h2>
                                <ul>
                                    <li>
                                        <a href="#">Super Smart Phone</a>
                                    </li>
                                    <li>
                                        <a href="#">Thin Magic Mobile</a>
                                    </li>
                                    <li>
                                        <a href="#">Performance Crusher</a>
                                    </li>
                                    <li>
                                        <a href="#">Futuristic Experience</a>
                                    </li>
                                </ul>
                            </li>
                            <li>
                                <a href="#"><i class="fa fa-desktop"></i>Televisions</a>
                                <h2><i class="fa fa-desktop"></i>Televisions</h2>
                                <ul>
                                    <li>
                                        <a href="#">Flat Super Screen</a>
                                    </li>
                                    <li>
                                        <a href="#">Gigantic LED</a>
                                    </li>
                                    <li>
                                        <a href="#">Power Eater</a>
                                    </li>
                                    <li>
                                        <a href="#">3D Experience</a>
                                    </li>
                                    <li>
                                        <a href="#">Classic Comfort</a>
                                    </li>
                                </ul>
                            </li>
                            <li>
                                <a href="#"><i class="fa fa-camera-retro"></i>Cameras</a>
                                <h2><i class="fa fa-camera-retro"></i>Cameras</h2>
                                <ul>
                                    <li>
                                        <a href="#">Smart Shot</a>
                                    </li>
                                    <li>
                                        <a href="#">Power Shooter</a>
                                    </li>
                                    <li>
                                        <a href="#">Easy Photo Maker</a>
                                    </li>
                                    <li>
                                        <a href="#">Super Pixel</a>
                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </li>
                    <li>
                        <a href="#"><i class="fa fa-book"></i>Magazines</a>
                        <h2><i class="fa fa-book"></i>Magazines</h2>
                        <ul>
                            <li>
                                <a href="#">National Geographics</a>
                            </li>
                            <li>
                                <a href="#">The Spectator</a>
                            </li>
                            <li>
                                <a href="#">Rambler</a>
                            </li>
                            <li>
                                <a href="#">Physics World</a>
                            </li>
                            <li>
                                <a href="#">The New Scientist</a>
                            </li>
                        </ul>
                    </li>
                    <li>
                        <a href="#"><i class="fa fa-shopping-cart"></i>Store</a>
                        <h2><i class="fa fa-shopping-cart"></i>Store</h2>
                        <ul>
                            <li>
                                <a href="#"><i class="fa fa-tags"></i>Clothes</a>
                                <h2><i class="fa fa-tags"></i>Clothes</h2>
                                <ul>
                                    <li>
                                        <a href="#"><i class="fa fa-female"></i>Women's Clothing</a>
                                        <h2><i class="fa fa-female"></i>Women's Clothing</h2>
                                        <ul>
                                            <li>
                                                <a href="#">Tops</a>
                                            </li>
                                            <li>
                                                <a href="#">Dresses</a>
                                            </li>
                                            <li>
                                                <a href="#">Trousers</a>
                                            </li>
                                            <li>
                                                <a href="#">Shoes</a>
                                            </li>
                                            <li>
                                                <a href="#">Sale</a>
                                            </li>
                                        </ul>
                                    </li>
                                    <li>
                                        <a href="#"><i class="fa fa-male"></i>Men's Clothing</a>
                                        <h2><i class="fa fa-male"></i>Men's Clothing</h2>
                                        <ul>
                                            <li>
                                                <a href="#">Shirts</a>
                                            </li>
                                            <li>
                                                <a href="#">Trousers</a>
                                            </li>
                                            <li>
                                                <a href="#">Shoes</a>
                                            </li>
                                            <li>
                                                <a href="#">Sale</a>
                                            </li>
                                        </ul>
                                    </li>
                                </ul>
                            </li>
                            <li>
                                <a href="#">Jewelry</a>
                            </li>
                            <li>
                                <a href="#">Music</a>
                            </li>
                            <li>
                                <a href="#">Grocery</a>
                            </li>
                        </ul>
                    </li>
                    <li>
                        <a href="#">Collections</a>
                    </li>
                    <li>
                        <a href="#">Credits</a>
                    </li>
                </ul>
            </nav>
        </div>

"@


    New-HTMLTag -Tag 'script' {
        @"
        // HTML markup implementation, overlap mode, initilaize collapsed
        `$('#menu').multilevelpushmenu({
            containersToPush: [`$('#pushobj')],
            menuWidth: '200px',
            menuHeight: '100%',
            collapsed: true,
            mode: 'cover',
            // Just for fun also changing the look of the menu
            wrapperClass: 'mlpm_w',
            menuInactiveClass: 'mlpm_inactive'
        });
        `$(window).resize(function () {
            `$('#menu').multilevelpushmenu('redraw');
        });
"@
    }
}

<#
function Test-Me {
    param(
        [scriptblock] $Test
    )
    & $Test
}

Test-Me {
    Test-Me {
        Write-Host '5'
        Test-Me {
            Write-Host '7'
        }
    }

    Test-Me {
        Write-Host '6'
    }
}
#>
function New-HTMLNavLink {
    [cmdletBinding()]
    param(
        [scriptblock] $SubMenu,
        [string] $Name = 'Menu',
        [string] $Icon = 'fa-dashboard'
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    if ($SubMenu) {
        $Attributes = @{ class = 'menu-hasdropdown' }
    } else {
        $Attributes = @{}
    }
    $ID = "$(Get-RandomStringName -Size 8 -LettersOnly)"
    New-HTMLTag -Tag 'li' -Attributes $Attributes {
        New-HTMLTag -Tag 'a' -Attributes @{ href = '#' } { $Name }
        New-HTMLTag -Tag 'span' -Attributes @{ class = 'icon' } {
            New-HTMLTag -Tag 'i' -Attributes @{ class = "fa $Icon" } {
            }
        }
        if ($SubMenu) {
            New-HTMLTag -Tag 'label' -Attributes @{ title = 'toggle menu'; for = $ID } {
                New-HTMLTag -Tag 'span' -Attributes @{ class = 'downarrow' } {
                    New-HTMLTag -Tag 'i' -Attributes @{ class = 'fa fa-caret-down' }
                }
            }
            New-HTMLTag -Tag 'input' -Attributes @{ type = 'checkbox'; class = 'sub-menu-checkbox'; id = $ID } -SelfClosing
            New-HTMLTag -Tag 'ul' -Attributes @{ class = "sub-menu-dropdown" } {
                & $SubMenu
            }

        }
    }
}
function New-HTMLOrgChart {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ChartNodes
    Define nodes to be shown on the chart

    .PARAMETER Direction
    The available values are "top to bottom" (default value), "bottom to top", "left to right" and "right to left"

    .PARAMETER VisileLevel
    It indicates the level that at the very beginning orgchart is expanded to.

    .PARAMETER VerticalLevel
    Users can make use of this option to align the nodes vertically from the specified level.

    .PARAMETER ToggleSiblings
    Once enable this option, users can show/hide left/right sibling nodes respectively by clicking left/right arrow.

    .PARAMETER NodeTitle
    It sets one property of datasource as text content of title section of orgchart node. In fact, users can create a simple orghcart with only nodeTitle option.

    .PARAMETER Pan
    Users could pan the orgchart by mouse drag&drop if they enable this option.

    .PARAMETER Zoom
    Users could zoomin/zoomout the orgchart by mouse wheel if they enable this option.

    .PARAMETER ZoomInLimit
    Users are allowed to set a zoom-in limit.

    .PARAMETER ZoomOutLimit
    Users are allowed to set a zoom-out limit.

    .PARAMETER Draggable
    Users can drag & drop the nodes of orgchart if they enable this option. **Note**: this feature doesn't work on IE due to its poor support for HTML5 drag & drop API.

    .PARAMETER AllowExport
    It enable the export button for orgchart.

    .PARAMETER ExportFileName
    It's filename when you export current orgchart as a picture.

    .PARAMETER ExportExtension
    Available values are png and pdf.

    .PARAMETER ChartID
    Forces ChartID to be set to known value rather than having it autogenerated

    .EXAMPLE
    New-HTML {
        New-HTMLOrgChart {
            New-OrgChartNode -Name 'Test' -Title 'Test2' {
                New-OrgChartNode -Name 'Test' -Title 'Test2'
                New-OrgChartNode -Name 'Test' -Title 'Test2'
                New-OrgChartNode -Name 'Test' -Title 'Test2' {
                    New-OrgChartNode -Name 'Test' -Title 'Test2'
                }
            }
        } -AllowExport -ExportExtension pdf -Draggable
    } -FilePath $PSScriptRoot\Example-OrgChart01.html -ShowHTML -Online

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [ScriptBlock] $ChartNodes,
        [ValidateSet("TopToBottom", "BottomToTop", "LeftToRight", "RightToLeft")][string] $Direction,
        [int] $VisileLevel,
        [int] $VerticalLevel,
        [string] $NodeTitle,
        [switch] $ToggleSiblings,
        [switch] $Pan,
        [switch] $Zoom,
        [double] $ZoomInLimit,
        [double] $ZoomOutLimit,
        [switch] $Draggable,
        [switch] $AllowExport,
        [string] $ExportFileName = 'PSWriteHTML-OrgChart',
        [ValidateSet('png', 'pdf')] $ExportExtension = 'png',
        [string] $ChartID
    )

    $DirectionDictionary = @{
        "TopToBottom" = 't2b'
        "BottomToTop" = 'b2t'
        "LeftToRight" = 'l2r'
        "RightToLeft" = 'r2l'
    }
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.Jquery = $true
    $Script:HTMLSchema.Features.ChartsOrg = $true
    if ($ExportExtension -eq 'png' -and $AllowExport) {
        $Script:HTMLSchema.Features.ES6Promise = $true
        $Script:HTMLSchema.Features.ChartsOrgExportPNG = $true
    }
    if ($ExportExtension -eq 'pdf' -and $AllowExport) {
        $Script:HTMLSchema.Features.ES6Promise = $true
        $Script:HTMLSchema.Features.ChartsOrgExportPDF = $true
        $Script:HTMLSchema.Features.ChartsOrgExportPNG = $true
    }

    if (-not $ChartID) {
        $ChartID = "OrgChart-$(Get-RandomStringName -Size 8 -LettersOnly)"
    }

    if ($ChartNodes) {
        $DataSource = & $ChartNodes
    }

    $OrgChart = [ordered] @{
        data                = $DataSource
        nodeContent         = 'title'
        exportButton        = $AllowExport.IsPresent
        exportFileName      = $ExportFileName
        exportFileextension = $ExportExtension
    }
    if ($NodeTitle) {
        $OrgChart['nodeTitle'] = $NodeTitle
    }
    if ($Direction) {
        $OrgChart['direction'] = $DirectionDictionary[$Direction]
    }
    if ($Draggable) {
        $OrgChart['draggable'] = $Draggable.IsPresent
    }
    if ($VisileLevel) {
        # It indicates the level that at the very beginning orgchart is expanded to.
        $OrgChart['visibleLevel'] = $VisileLevel
    }
    if ($VerticalLevel) {
        # Users can make use of this option to align the nodes vertically from the specified level.
        $OrgChart['verticalLevel'] = $VerticalLevel
    }
    if ($ToggleSiblings) {
        # Once enable this option, users can show/hide left/right sibling nodes respectively by clicking left/right arrow.
        $OrgChart['toggleSiblingsResp'] = $ToggleSiblings.IsPresent
    }
    if ($Pan) {
        # Users could pan the orgchart by mouse drag&drop if they enable this option.
        $OrgChart['pan'] = $Pan.IsPresent
    }
    if ($Zoom) {
        # Users could zoomin/zoomout the orgchart by mouse wheel if they enable this option.
        $OrgChart['zoom'] = $Zoom.IsPresent
        if ($ZoomInLimit) {
            $OrgChart['zoominLimit'] = $ZoomInLimit
        }
        if ($ZoomOutLimit) {
            $OrgChart['zoomoutLimit'] = $ZoomOutLimit
        }
    }
    $JsonOrgChart = $OrgChart | ConvertTo-Json -Depth 100

    New-HTMLTag -Tag 'script' {
        "`$(function () {"
        "`$(`"#$ChartID`").orgchart($JsonOrgChart);"
        "});"
    }
    New-HTMLTag -Tag 'div' -Attributes @{ id = $ChartID; class = 'orgchartWrapper flexElement' }
}
Function New-HTMLPanel {
    [alias('New-HTMLColumn', 'Panel')]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)][ValidateNotNull()][ScriptBlock] $Content,
        [alias('BackgroundShade')][string]$BackgroundColor,
        [switch] $Invisible,
        [alias('flex-basis')][string] $Width,
        [string] $Margin,

        [string][ValidateSet('center', 'left', 'right', 'justify')] $AlignContentText,
        [ValidateSet('0px', '5px', '10px', '15px', '20px', '25px')][string] $BorderRadius,
        [string] $AnchorName,
        [System.Collections.IDictionary] $StyleSheetsConfiguration
    )
    $Script:HTMLSchema.Features.Main = $true
    $Script:HTMLSchema.Features.MainFlex = $true
    # This is so we can support external CSS configuration
    if (-not $StyleSheetsConfiguration) {
        $Script:HTMLSchema.Features.DefaultPanel = $true
        $StyleSheetsConfiguration = [ordered] @{
            Panel = "defaultPanel"
        }
    }
    # This takes care of starting dots in $StyleSheetsConfiguration
    Remove-DotsFromCssClass -Css $StyleSheetsConfiguration
    if (-not $AnchorName) {
        $AnchorName = "anchor-$(Get-RandomStringName -Size 7)"
    }

    # This controls general panel style that overwrittes whatever is set globally
    $PanelStyle = [ordered] @{
        "background-color" = ConvertFrom-Color -Color $BackgroundColor
        'border-radius'    = $BorderRadius
        'text-align'       = $AlignContentText # This controls content within panel if it's not 100% width such as text
    }
    if ($Invisible) {
        #$PanelStyle['box-shadow'] = 'unset !important;'
        $StyleSheetsConfiguration.Panel = ''
        [string] $Class = "flexPanel overflowHidden $($StyleSheetsConfiguration.Panel)"
    } elseif ($Width -or $Margin) {
        $Attributes = @{
            'flex-basis' = if ($Width) { $Width } else { '100%' }
            'margin'     = if ($Margin) { $Margin }
        }
        [string] $ClassName = "defaultPanel$(Get-RandomStringName -Size 8 -LettersOnly)"
        $Css = ConvertTo-LimitedCSS -ClassName $ClassName -Attributes $Attributes
        $Script:HTMLSchema.CustomHeaderCSS[$AnchorName] = $Css
        [string] $Class = "flexPanel overflowHidden $ClassName"
    } else {
        [string] $Class = "flexPanel overflowHidden $($StyleSheetsConfiguration.Panel)"
    }
    # New-HTMLTag -Tag 'div' -Attributes @{ class = 'flexParent' } {
    New-HTMLTag -Tag 'div' -Attributes @{ id = $AnchorName; class = $Class; style = $PanelStyle } {
        if ($Content) {
            Invoke-Command -ScriptBlock $Content
        }
    }
    # }
}

Register-ArgumentCompleter -CommandName New-HTMLPanel -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLPanelStyle {
    [alias('New-HTMLPanelOption', 'New-PanelOption', "PanelOption", 'New-PanelStyle', 'PanelStyle')]
    [cmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('0px', '5px', '10px', '15px', '20px', '25px')][string] $BorderRadius,
        [Parameter(ParameterSetName = 'Manual')][switch] $RemoveShadow,
        [Parameter(ParameterSetName = 'Manual')][switch] $RequestConfiguration
    )
    # lets get original CSS configuration
    $CssConfiguration = Get-ConfigurationCss -Feature 'DefaultPanel' -Type 'HeaderAlways'

    $StyleSheetsConfiguration = [ordered] @{
        Panel = ".defaultPanel"
    }

    # This is only if we want to have multiple styles
    if ($RequestConfiguration) {
        $RequestedConfiguration = New-RequestCssConfiguration -Pair $StyleSheetsConfiguration -CSSConfiguration $CssConfiguration -Feature 'Inject' -Type 'HeaderAlways'
        $StyleSheetsConfiguration = $RequestedConfiguration.StyleSheetConfiguration
        $CssConfiguration = $RequestedConfiguration.CSSConfiguration
    }

    # Here's the real overwrite of panel configuration
    if ($RemoveShadow) {
        Remove-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.Panel -Property 'box-shadow'
    }
    Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.Panel -Inject @{ 'border-radius' = $BorderRadius }

    if ($RequestConfiguration) {
        # We only return this when requesting configuration
        # otherwise this overwrites global section settings
        return $StyleSheetsConfiguration
    }
}
function New-HTMLQRCode {
    [cmdletBinding()]
    param(
        [string] $Link,
        [object] $Width,
        [object] $Height,
        [string] $Title,
        [string] $TitleColor,
        [string] $Logo,
        [object] $LogoWidth,
        [object] $LogoHeight,
        [switch] $LogoInline
    )
    $Script:HTMLSchema.Features.QR = $true

    if (-not $AnchorName) {
        $AnchorName = "QrCode$(Get-RandomStringName -Size 8)"
    }
    if ($LogoInline) {
        # Cache makes sure that file is downloaded once and can be reused over and over until cache is reset
        # Resetting of cache is done automatically on module reload
        # This can be very useful when sending 3000 emails with same logo
        $LogoImage = Convert-Image -Image $Logo -Cache:(-not $DisableCache)
    } else {
        $LogoImage = $Logo
    }

    New-HTMLTag -Tag 'div' -Attributes @{ Id = $AnchorName; class = 'qrcode flexElement' }

    $Options = @{
        text       = $Link
        width      = ConvertTo-Size -Size $Width
        height     = ConvertTo-Size -Size $Height
        title      = $Title
        logo       = $LogoImage
        logoWidth  = ConvertTo-Size -Size $LogoWidth
        logoHeight = ConvertTo-Size -Size $LogoHeight
        titleColor = ConvertFrom-Color -Color $TitleColor
    }
    Remove-EmptyValue -Hashtable $Options -Recursive
    $OptionsJson = $Options | ConvertTo-Json

    # Since we want to allow use of QR code in tables or other places we push it to footer instead of inline
    $ScriptBottom = New-HTMLTag -Tag 'script' -Value {
        "var options = $OptionsJson;"
        "new QRCode(document.getElementById(`"$AnchorName`"), options);"
    }
    Add-HTMLScript -Placement Footer -Content $ScriptBottom -SkipTags
}

Register-ArgumentCompleter -CommandName New-HTMLQRCode -ParameterName TitleColor -ScriptBlock $Script:ScriptBlockColors
Function New-HTMLSection {
    [alias('New-HTMLContent', 'Section')]
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)][ValidateNotNull()][ScriptBlock] $Content = $(Throw "Open curly brace"),
        [alias('Name', 'Title')][Parameter(Mandatory = $false)][string]$HeaderText,
        [alias('TextColor')][string]$HeaderTextColor,
        [alias('TextSize')][string] $HeaderTextSize,
        [alias('TextAlignment')][string][ValidateSet('center', 'left', 'right', 'justify')] $HeaderTextAlignment,
        [alias('TextBackGroundColor')][string]$HeaderBackGroundColor,
        [alias('BackgroundShade')][string]$BackgroundColor,
        [alias('Collapsable')][Parameter(Mandatory = $false)][switch] $CanCollapse,
        [switch] $IsHidden,
        [switch] $Collapsed,
        [object] $Height,
        [object] $Width = '100%',
        [switch] $Invisible,
        # Following are based on https://css-tricks.com/snippets/css/a-guide-to-flexbox/
        [string][ValidateSet('wrap', 'nowrap', 'wrap-reverse')] $Wrap,
        [string][ValidateSet('row', 'row-reverse', 'column', 'column-reverse')] $Direction,
        [string][ValidateSet('flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'stretch')] $AlignContent,
        [string][ValidateSet('stretch', 'flex-start', 'flex-end', 'center', 'baseline')] $AlignItems,
        [string][ValidateSet('flex-start', 'flex-end', 'center')] $JustifyContent,

        [ValidateSet('0px', '5px', '10px', '15px', '20px', '25px')][string] $BorderRadius,

        [string] $AnchorName,
        [System.Collections.IDictionary] $StyleSheetsConfiguration
    )
    $Script:HTMLSchema.Features.Main = $true
    $Script:HTMLSchema.Features.MainFlex = $true
    # This is so we can support external CSS configuration
    if (-not $StyleSheetsConfiguration) {
        $StyleSheetsConfiguration = [ordered] @{
            Section                 = 'defaultSection'
            SectionText             = 'defaultSectionText'
            SectionHead             = "defaultSectionHead"
            SectionContent          = 'defaultSectionContent'
            SectionContentInvisible = 'defaultSectionContentInvisible'
        }
    }
    # This takes care of starting dots in $StyleSheetsConfiguration
    Remove-DotsFromCssClass -Css $StyleSheetsConfiguration
    if (-not $AnchorName) {
        $AnchorName = "anchor-$(Get-RandomStringName -Size 7)"
    }

    if ($HeaderTextAlignment) {
        # We need to translate it to Justify-Alignement - because Text-Aligment doesn't work with flex
        if ($HeaderTextAlignment -eq 'justify' -or $HeaderTextAlignment -eq 'center') {
            $HeaderAlignment = 'center'
        } elseif ($HeaderTextAlignment -eq 'left') {
            $HeaderAlignment = 'flex-start'
        } elseif ($HeaderTextAlignment -eq 'right') {
            $HeaderAlignment = 'flex-end'
        } else {

        }
    }
    $TextHeaderColorFromRGB = ConvertFrom-Color -Color $HeaderTextColor
    $TextSize = ConvertFrom-Size -Size $HeaderTextSize
    $HiddenDivStyle = [ordered] @{ }
    $AttributesTop = [ordered] @{}

    # depending on flex-direction for section collapsing works a bit differently
    # we need to find out what is required flex direction and applky rules accordingly
    # same thing happens on JS level in hideSection.js
    if ($StyleSheetsConfiguration.Section -eq 'defaultSection') {
        $Script:HTMLSchema.Features.DefaultSection = $true
        $CurrentFlexDirection = $Script:CurrentConfiguration['Features']['DefaultSection']['HeaderAlways']['CssInline'][".$($StyleSheetsConfiguration.Section)"]['flex-direction']
    } else {
        $CurrentFlexDirection = $Script:CurrentConfiguration['Features']['Inject']['HeaderAlways']['CssInline'][".$($StyleSheetsConfiguration.Section)"]['flex-direction']
    }

    if ($CanCollapse) {
        $Script:HTMLSchema.Features.HideSection = $true
        $Script:HTMLSchema.Features.RedrawObjects = $true
        if ($Collapsed) {
            # hides Show button
            $HideStyle = @{
                "color"   = $TextHeaderColorFromRGB;
                'display' = 'none'
            }
            # shows Hide button
            $ShowStyle = @{
                "color" = $TextHeaderColorFromRGB
            }
            $HiddenDivStyle['display'] = 'none'

            if ($CurrentFlexDirection -eq 'Row') {
                $ClassTop = "sectionHide"
            }
        } else {
            # hides Show button
            $ShowStyle = @{
                "color"   = $TextHeaderColorFromRGB;
                'display' = 'none'
            }
            # shows Hide button
            $HideStyle = @{
                "color" = $TextHeaderColorFromRGB
            }
            if ($CurrentFlexDirection -eq 'Row') {
                $ClassTop = "sectionShow"
            }
        }
    } else {
        # hides Show button
        $ShowStyle = @{
            "color"   = $TextHeaderColorFromRGB;
            'display' = 'none'
        }
        # hides Show button
        $HideStyle = @{
            "color"   = $TextHeaderColorFromRGB;
            'display' = 'none'
        }
        $ClassTop = ''
    }

    $AttributesTop['class'] = "$($StyleSheetsConfiguration.Section) overflowHidden $ClassTop"
    $AttributesTop['style'] = [ordered] @{
        "background-color" = ConvertFrom-Color -Color $BackgroundColor
        'border-radius'    = $BorderRadius
        'flex-basis'       = $Width
    }
    if ($IsHidden) {
        $AttributesTop['style']["display"] = 'none'
    }


    $HiddenDivStyle['height'] = ConvertFrom-Size -Size $Height

    if ($Wrap -or $Direction) {
        [string] $ClassName = "flexParent$(Get-RandomStringName -Size 8 -LettersOnly)"
        $Attributes = @{
            'display'        = 'flex'
            'flex-wrap'      = if ($Wrap) { $Wrap } else { }
            'flex-direction' = if ($Direction) { $Direction } else { }
            'align-content'  = if ($AlignContent) { $AlignContent } else { }
            'align-items'    = if ($AlignItems) { $AlignItems } else { }
        }
        $Css = ConvertTo-LimitedCSS -ClassName $ClassName -Attributes $Attributes

        #$Script:HTMLSchema.CustomHeaderCSS.Add($Css)
        $Script:HTMLSchema.CustomHeaderCSS[$AnchorName] = $Css
    } else {
        if ($Invisible) {
            [string] $ClassName = "flexParentInvisible flexElement overflowHidden $($StyleSheetsConfiguration.SectionContentInvisible)"
        } else {
            [string] $ClassName = "flexParent flexElement overflowHidden $($StyleSheetsConfiguration.SectionContent)"
        }
    }

    $ContentStyle = @{
        'justify-content' = $JustifyContent
    }

    $DivHeaderStyle = @{
        #"text-align"       = $HeaderTextAlignment
        'justify-content'  = $HeaderAlignment
        'font-size'        = $TextSize
        "background-color" = ConvertFrom-Color -Color $HeaderBackGroundColor
    }
    $HeaderStyle = @{ "color" = $TextHeaderColorFromRGB }
    if ($Invisible) {
        New-HTMLTag -Tag 'div' -Attributes @{ class = $ClassName; style = $AttributesTop['style'] } -Value {
            New-HTMLTag -Tag 'div' -Attributes @{ class = $ClassName; Style = $ContentStyle } -Value {
                $Object = Invoke-Command -ScriptBlock $Content
                if ($null -ne $Object) {
                    $Object
                }
            }
        }
    } else {
        New-HTMLTag -Tag 'div' -Attributes $AttributesTop -Value {
            New-HTMLTag -Tag 'div' -Attributes @{ class = $StyleSheetsConfiguration.SectionHead; style = $DivHeaderStyle } -Value {
                New-HTMLTag -Tag 'div' -Attributes @{ class = $StyleSheetsConfiguration.SectionText } {
                    New-HTMLAnchor -Name $HeaderText -Text "$HeaderText " -Style $HeaderStyle
                    "&nbsp;" # this adds hard space
                    New-HTMLAnchor -Id "show_$AnchorName" -Href 'javascript:void(0)' -OnClick "show('$AnchorName'); " -Style $ShowStyle -Text '(Show)'
                    New-HTMLAnchor -Id "hide_$AnchorName" -Href 'javascript:void(0)' -OnClick "hide('$AnchorName'); " -Style $HideStyle -Text '(Hide)'
                }
            }
            New-HTMLTag -Tag 'div' -Attributes @{ name = $AnchorName; class = $ClassName; id = $AnchorName; style = $HiddenDivStyle } -Value {
                New-HTMLTag -Tag 'div' -Attributes @{ class = "$ClassName collapsable"; id = $AnchorName; style = $ContentStyle } -Value {
                    $Object = Invoke-Command -ScriptBlock $Content
                    if ($null -ne $Object) {
                        $Object
                    }
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLSection -ParameterName HeaderTextColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLSection -ParameterName HeaderBackGroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLSection -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLSectionStyle {
    [alias("New-HTMLSectionOptions", 'SectionOption', 'New-HTMLSectionOption')]
    [cmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('0px', '5px', '10px', '15px', '20px', '25px')][string] $BorderRadius,

        [Parameter(ParameterSetName = 'Manual')][switch] $RemoveShadow,

        [Parameter(ParameterSetName = 'Manual')][alias('TextColor')][string]$HeaderTextColor,
        [Parameter(ParameterSetName = 'Manual')][alias('TextAlignment')][string][ValidateSet('center', 'left', 'right', 'justify')] $HeaderTextAlignment,
        [Parameter(ParameterSetName = 'Manual')][alias('TextBackGroundColor')][string]$HeaderBackGroundColor,
        [Parameter(ParameterSetName = 'Manual')][switch] $HeaderRemovePadding,


        [Parameter(ParameterSetName = 'Manual')][string][ValidateSet('wrap', 'nowrap', 'wrap-reverse')] $Wrap,
        [Parameter(ParameterSetName = 'Manual')][string][ValidateSet('row', 'row-reverse', 'column', 'column-reverse')] $Direction,
        [Parameter(ParameterSetName = 'Manual')][string][ValidateSet('flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'stretch')] $Align,
        [Parameter(ParameterSetName = 'Manual')][string][ValidateSet('stretch', 'flex-start', 'flex-end', 'center', 'baseline')] $AlignItems,
        [Parameter(ParameterSetName = 'Manual')][string][ValidateSet('flex-start', 'flex-end', 'center')] $Justify,
        [Parameter(ParameterSetName = 'Manual')][string][ValidateSet('-180deg', '-90deg', '90deg', '180deg')] $Rotate,

        [Parameter(ParameterSetName = 'Manual')][alias('BackgroundShade')][string]$BackgroundColorContent,
        [string][ValidateSet('wrap', 'nowrap', 'wrap-reverse')] $WrapContent,
        [string][ValidateSet('row', 'row-reverse', 'column', 'column-reverse')] $DirectionContent,
        [string][ValidateSet('flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'stretch')] $AlignContent,
        [string][ValidateSet('stretch', 'flex-start', 'flex-end', 'center', 'baseline')] $AlignItemsContent,
        [string][ValidateSet('flex-start', 'flex-end', 'center')] $JustifyContent,

        [Parameter(ParameterSetName = 'Manual')][ValidateSet('vertical-rl', 'vertical-lr', 'horizontal-tb')][string] $WritingMode,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('mixed', 'upright')][string] $TextOrientation,

        [Parameter(ParameterSetName = 'Manual')][switch] $RequestConfiguration
    )
    # lets get original CSS configuration
    # this is read from $Script:Configuration (or more precise $Script:CurrentConfiguration which is a copy on New-HTML start)
    $CssConfiguration = Get-ConfigurationCss -Feature 'DefaultSection' -Type 'HeaderAlways'
    $StyleSheetsConfiguration = [ordered] @{
        Section                 = ".defaultSection"
        SectionText             = ".defaultSectionText"
        SectionHead             = ".defaultSectionHead"
        SectionContent          = '.defaultSectionContent'
        SectionContentInvisible = '.defaultSectionContentInvisible'
    }

    if ($RequestConfiguration) {
        # This copies current CSS that we need (in this case defaultSection,defaultSectionText, defaultSectionHead)
        # Inserts it into $Script:CurrentConfiguration
        # Which then will be inserted into HTML
        # finally it returns new names for sections above
        $RequestedConfiguration = New-RequestCssConfiguration -Pair $StyleSheetsConfiguration -CSSConfiguration $CssConfiguration -Feature 'Inject' -Type 'HeaderAlways'
        $StyleSheetsConfiguration = $RequestedConfiguration.StyleSheetConfiguration
        $CssConfiguration = $RequestedConfiguration.CSSConfiguration
        <#
        # We define how our CSS classes will be called - this can be per Section so we need to have it random
        $Name = $(Get-RandomStringName -Size 7)
        $ExpectedStyleSheetsConfiguration = [ordered] @{
            Section     = "defaultSection-$Name"
            SectionText = "defaultSectionText-$Name"
            SectionHead = "defaultSectionHead-$Name"
        }
        # We want to use different configuration for section based on existing original template
        # So we copy original CSSConfiguration
        $CssConfiguration = Copy-Dictionary -Dictionary $CssConfiguration
        # We then remove everything we're not interested in leaving only 2 sections that we modify
        Remove-ConfigurationCSS -CSS $CssConfiguration -Not -Section $StyleSheetsConfiguration.Values # 'defaultSection', 'defaultSectionText', 'defaultSectionHead'
        # We now need to rename existing CSS classes to their new names
        Rename-Dictionary -HashTable $CssConfiguration -Pair @{
            $StyleSheetsConfiguration.Section     = $ExpectedStyleSheetsConfiguration.Section
            $StyleSheetsConfiguration.SectionText = $ExpectedStyleSheetsConfiguration.SectionText
            $StyleSheetsConfiguration.SectionHead = $ExpectedStyleSheetsConfiguration.SectionHead
        }

        # Now we need to get already existing CSS code that we may have generaed for other sections
        $CssOtherConfiguration = Get-ConfigurationCss -Feature 'Inject' -Type 'HeaderAlways'
        # Finally we need to inject this into CSSInline configuration so it's delivered as style to final destination
        Set-ConfigurationCSS -CSS ($CssOtherConfiguration + $CssConfiguration) -Feature 'Inject' -Type 'HeaderAlways'

        # We also need to tell that we actually want this added
        $Script:HTMLSchema.Features.Inject = $true
        # Finally we overwrite what we need to deliver to users
        $StyleSheetsConfiguration = [ordered] @{
            Section     = $ExpectedStyleSheetsConfiguration.Section
            SectionText = $ExpectedStyleSheetsConfiguration.SectionText
            SectionHead = $ExpectedStyleSheetsConfiguration.SectionHead
        }
        #>
    }

    # Manage SECTION
    if ($Wrap -or $Direction -or $Align -or $AlignItems) {
        # This makes sure we can control placement of HEAD within SECTION
        Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.Section -Inject @{
            'display'        = 'flex'
            'flex-direction' = $Direction
        }
    }

    # keep in mind that also empty elements will be removed from this
    # so if background color is empty it will be removed from "overwritting"
    $SectionStyle = @{
        "background-color" = ConvertFrom-Color -Color $BackgroundColorContent
        'border-radius'    = $BorderRadius
    }
    Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.Section -Inject $SectionStyle

    # Removing elements needs to be defined separatly
    if ($BackgroundColorContent -eq 'none') {
        Remove-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.Section -Property 'background-color'
    }
    if ($RemoveShadow) {
        Remove-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.Section -Property 'box-shadow'
    }

    # Manage SECTION HEAD behaviour
    <#
    $SectionHeadStyle = @{
        "text-align"       = $HeaderTextAlignment
        "background-color" = ConvertFrom-Color -Color $HeaderBackGroundColor
        'align-content'    = $AlignContent
    }
    #>

    $SectionHeadStyle = @{
        'flex-wrap'        = $Wrap
        'flex-direction'   = $Direction
        'align-content'    = $Align
        'align-items'      = $AlignItems
        'justify-content'  = $Justify
        "background-color" = ConvertFrom-Color -Color $HeaderBackGroundColor
        'border-radius'    = $BorderRadius
        "text-align"       = $HeaderTextAlignment
        "transform"        = ConvertFrom-Rotate -Rotate $Rotate
    }

    Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionHead -Inject $SectionHeadStyle

    # colors are a bit special, since ConvertFrom-Color when given nothing or none will simply return empty string
    # this means it would be removed by Add-ConfigurationCSS
    # so if user requests removal of background color we need to remove it
    if ($HeaderBackGroundColor -eq 'none') {
        Remove-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionHead -Property 'background-color'
    }
    if ($HeaderRemovePadding) {
        Remove-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionHead -Property 'padding'
    }

    # Manage SECTION TEXT behavior
    $SectionHeadTextStyle = @{
        'writing-mode'     = $WritingMode
        'text-orientation' = $TextOrientation
        'color'            = ConvertFrom-Color -Color $HeaderTextColor
    }
    Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionText -Inject $SectionHeadTextStyle

    if ($HeaderTextColor -eq 'none') {
        Remove-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionText -Property 'color'
    }


    if ($WrapContent -or $DirectionContent -or $AlignContent -or $AlignItemsContent -or $JustifyContent) {
        # This makes sure we can control placement of HEAD within SECTION
        Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionContent -Inject @{ display = 'flex' }
    }

    $SectionContentStyle = @{
        'flex-wrap'       = $WrapContent
        'flex-direction'  = $DirectionContent
        'align-content'   = $AlignContent
        'align-items'     = $AlignItemsContent
        'justify-content' = $JustifyContent
    }
    Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionContent -Inject $SectionContentStyle
    Add-ConfigurationCSS -CSS $CssConfiguration -Name $StyleSheetsConfiguration.SectionContentInvisible -Inject $SectionContentStyle

    if ($RequestConfiguration) {
        # We only return this when requesting configuration
        # otherwise this overwrites global section settings
        return $StyleSheetsConfiguration
    }
}
function New-HTMLSpanStyle {
    [CmdletBinding()]
    param(
        [ScriptBlock] $Content,
        [string] $Color,
        [string] $BackGroundColor,
        [object] $FontSize,
        [string] $LineHeight,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string]  $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string]  $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string]  $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        [switch] $LineBreak
    )
    $Style = @{
        style = @{
            'color'            = ConvertFrom-Color -Color $Color
            'background-color' = ConvertFrom-Color -Color $BackGroundColor
            'font-size'        = ConvertFrom-Size -FontSize $FontSize
            'font-weight'      = $FontWeight
            'font-variant'     = $FontVariant
            'font-family'      = $FontFamily
            'font-style'       = $FontStyle
            'text-align'       = $Alignment
            'line-height'      = $LineHeight
            'text-decoration'  = $TextDecoration
            'text-transform'   = $TextTransform
            'direction'        = $Direction
        }
    }

    if ($Alignment) {
        $StyleDiv = @{ }
        $StyleDiv.Align = $Alignment

        New-HTMLTag -Tag 'div' -Attributes $StyleDiv {
            New-HTMLTag -Tag 'span' -Attributes $Style {
                if ($Content) {
                    Invoke-Command -ScriptBlock $Content
                }
            }
        }
    } else {
        New-HTMLTag -Tag 'span' -Attributes $Style {
            if ($Content) {
                Invoke-Command -ScriptBlock $Content
            }
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLSpanStyle -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLSpanStyle -ParameterName BackGroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][alias('')][ScriptBlock] $Content
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.StatusButtonical = $true
    New-HTMLTag -Tag 'div' -Attributes @{ class = 'buttonicalService' } {
        #New-HTMLTag -Tag 'div' -Attributes @{ class = 'buttonical-align' } {
        Invoke-Command -ScriptBlock $Content
        # }
    }

}
function New-HTMLStatusItem {
    [CmdletBinding(DefaultParameterSetName = 'Statusimo')]
    param(
        [alias('ServiceName')][string] $Name,
        [alias('ServiceStatus')][string] $Status,

        [ValidateSet('Dead', 'Bad', 'Good')]
        [Parameter(ParameterSetName = 'Statusimo')]
        $Icon = 'Good',

        [ValidateSet('0%', '10%', '30%', '70%', '100%')]
        [Parameter(ParameterSetName = 'Statusimo')]
        [string] $Percentage = '100%',

        [string]$FontColor = '#5f6982',

        [parameter(ParameterSetName = 'FontAwesomeBrands')]
        [parameter(ParameterSetName = 'FontAwesomeRegular')]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [Parameter(ParameterSetName = 'Hex')]
        [string]$BackgroundColor = '#0ef49b',

        # ICON BRANDS
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeBrands.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeBrands.Keys))
            }
        )]
        [parameter(ParameterSetName = 'FontAwesomeBrands')]
        [string] $IconBrands,

        # ICON REGULAR
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeRegular.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeRegular.Keys))
            }
        )]
        [parameter(ParameterSetName = 'FontAwesomeRegular')]
        [string] $IconRegular,

        # ICON SOLID
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeSolid.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeSolid.Keys))
            }
        )]
        [parameter(ParameterSetName = 'FontAwesomeSolid')]
        [string] $IconSolid,

        [Parameter(ParameterSetName = 'Hex')]
        [ValidatePattern('^&#x[A-Fa-f0-9]{4,5}$')]
        [string]$IconHex
    )
    #$Script:HTMLSchema.Features.StatusButtonical = $true
    if ($PSCmdlet.ParameterSetName -eq 'Statusimo') {
        Write-Warning 'This parameter set has been deprecated. It will be removed in a future release. Look to move to the other parameter sets with customization options.'

        if ($Percentage -eq '100%') {
            $BackgroundColor = '#0ef49b'
        } elseif ($Percentage -eq '70%') {
            $BackgroundColor = '#d2dc69'
        } elseif ($Percentage -eq '30%') {
            $BackgroundColor = '#faa04b'
        } elseif ($Percentage -eq '10%') {
            $BackgroundColor = '#ff9035'
        } elseif ($Percentage -eq '0%') {
            $BackgroundColor = '#ff5a64'
        }

        if ($Icon -eq 'Dead') {
            $IconType = '&#x2620'
        } elseif ($Icon -eq 'Bad') {
            $IconType = '&#x2639'
        } elseif ($Icon -eq 'Good') {
            $IconType = '&#x2714'
        }
    } elseif ($PSCmdlet.ParameterSetName -like 'FontAwesome*') {
        $Script:HTMLSchema.Features.FontsAwesome = $true
        $BackgroundColor = ConvertFrom-Color -Color $BackgroundColor

        if ($IconBrands) {
            $IconClass = "fab fa-$IconBrands"
        } elseif ($IconRegular) {
            $IconClass = "far fa-$IconRegular"
        } elseif ($IconSolid) {
            $IconClass = "fas fa-$IconSolid"
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'Hex') {
        $IconType = $IconHex
    }
    $FontColor = ConvertFrom-Color -Color $FontColor

    New-HTMLTag -Tag 'div' -Attributes @{ class = 'buttonical'; style = @{ "background-color" = $BackgroundColor } } -Value {
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'label' } {
            New-HTMLTag -Tag 'span' -Attributes @{ class = 'performance'; style = @{ color = $FontColor } } {
                $Name
            }
        }
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'middle' }
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'status' } {
            New-HTMLTag -Tag 'input' -Attributes @{ name = Get-Random; type = 'radio'; value = 'other-item'; checked = 'true' } -SelfClosing
            New-HTMLTag -Tag 'span' -Attributes @{ class = "performance"; style = @{ color = $FontColor } } {
                $Status
                New-HTMLTag -Tag 'span' -Attributes @{ class = "icon $IconClass" } {
                    $IconType
                }
            }
        }
    }
}
Register-ArgumentCompleter -CommandName New-HTMLStatusItem -ParameterName FontColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLStatusItem -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLTab {
    [alias('Tab')]
    [CmdLetBinding(DefaultParameterSetName = 'FontAwesomeBrands')]
    param(
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [Parameter(Mandatory = $false, Position = 0)][ValidateNotNull()][ScriptBlock] $HtmlData = $(Throw "No curly brace?)"),
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [alias('TabHeading')][Parameter(Mandatory = $false, Position = 1)][String]$Heading,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [alias('TabName')][string] $Name = 'Tab',

        # ICON BRANDS
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeBrands.Keys)
            }
        )]
        [ValidateScript( { $_ -in (($Global:HTMLIcons.FontAwesomeBrands.Keys)) })]
        [string] $IconBrands,

        # ICON REGULAR
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeRegular.Keys)
            }
        )]
        [ValidateScript( { $_ -in (($Global:HTMLIcons.FontAwesomeRegular.Keys)) })]
        [string] $IconRegular,

        # ICON SOLID
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeSolid.Keys)
            }
        )]
        [ValidateScript( { $_ -in (($Global:HTMLIcons.FontAwesomeSolid.Keys)) })]
        [string] $IconSolid,

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][object] $TextSize,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $TextColor,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][object] $IconSize,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $IconColor,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform, # New-HTMLTab - Add text-transform
        [string] $AnchorName
    )
    if (-not $Script:HTMLSchema.Features) {
        Write-Warning 'New-HTMLTab - Creation of HTML aborted. Most likely New-HTML is missing.'
        Exit
    }
    if ($IconBrands -or $IconRegular -or $IconSolid) {
        $Script:HTMLSchema.Features.FontsAwesome = $true
    }
    $Script:HTMLSchema.Features.MainFlex = $true
    if (-not $AnchorName) {
        $AnchorName = "Tab-$(Get-RandomStringName -Size 8)"
    }
    [string] $Icon = ''
    if ($IconBrands) {
        $Icon = "fab fa-$IconBrands" # fa-$($FontSize)x"
    } elseif ($IconRegular) {
        $Icon = "far fa-$IconRegular" # fa-$($FontSize)x"
    } elseif ($IconSolid) {
        $Icon = "fas fa-$IconSolid" # fa-$($FontSize)x"
    }

    $StyleText = @{ }
    #if ($TextSize -ne 0) {
    $StyleText['font-size'] = ConvertFrom-Size -Size $TextSize  #"$($TextSize)px"
    #}
    if ($TextColor) {
        $StyleText.'color' = ConvertFrom-Color -Color $TextColor
    }
    # New-HTMLTab - Add text-transform
    $StyleText.'text-transform' = "$TextTransform"
    # end

    $StyleIcon = @{ }
    #if ($IconSize -ne 0) {
    $StyleIcon.'font-size' = ConvertFrom-Size -Size $IconSize #"$($IconSize)px"
    #}
    if ($IconColor) {
        $StyleIcon.'color' = ConvertFrom-Color -Color $IconColor
    }

    if ($Script:HTMLSchema['TabPanelsList'].Count -eq 0) {
        #$Script:HTMLSchema['TabPanelsList'][-1]
        #}


        #if ($Script:HTMLSchema['TabPanels'] -eq $false) {
        #if ($Script:HTMLSchema.TabPanel -eq $false) {
        # Reset all Tabs Headers to make sure there are no Current Tab Set
        # This is required for New-HTMLTable
        foreach ($Tab in $Script:HTMLSchema.TabsHeaders) {
            $Tab.Current = $false
        }
        # Start Tab Tracking
        $Tab = [ordered] @{ }
        $Tab.ID = $AnchorName
        $Tab.Name = $Name
        $Tab.StyleIcon = $StyleIcon
        $Tab.StyleText = $StyleText
        $Tab.Current = $true

        if ($Script:HTMLSchema.TabsHeaders | Where-Object { $_.Active -eq $true }) {
            $Tab.Active = $false
        } else {
            $Tab.Active = $true
        }
        $Tab.Icon = $Icon
        # End Tab Tracking

        # This is building HTML

        if ($Tab.Active) {
            $Class = 'active'
        } else {
            $Class = ''
        }


        $Script:HTMLSchema.Features.Tabbis = $true
        $Script:HTMLSchema.Features.RedrawObjects = $true
        #New-HTMLTag -Tag 'div' -Attributes @{ id = $Tab.ID; class = $Class } {
        New-HTMLTag -Tag 'div' -Attributes @{ id = "$($Tab.ID)-Content"; class = $Class } {
            if (-not [string]::IsNullOrWhiteSpace($Heading)) {
                New-HTMLTag -Tag 'h7' {
                    $Heading
                }
            }
            $OutputHTML = Invoke-Command -ScriptBlock $HtmlData
            [Array] $TabsCollection = foreach ($_ in $OutputHTML) {
                if ($_ -is [System.Collections.IDictionary]) {
                    $_
                    $Script:HTMLSchema.TabsHeadersNested.Add($_)
                }
            }
            [Array] $HTML = foreach ($_ in $OutputHTML) {
                if ($_ -isnot [System.Collections.IDictionary]) {
                    $_
                }
            }
            if ($TabsCollection.Count -gt 0) {
                New-HTMLTabHead -TabsCollection $TabsCollection
                New-HTMLTag -Tag 'div' -Attributes @{ 'data-panes' = 'true' } {
                    # Add remaining data
                    $HTML
                }

            } else {
                $HTML
            }
        }
        $Script:HTMLSchema.TabsHeaders.Add($Tab)
        $Tab
    } else {
        # Tabs related to tab panel (New-HTMLTabPanel)
        if ($HtmlData) {
            $TabExecutedCode = & $HtmlData
        } else {
            $TabExecutedCode = ''
        }
        [PSCustomObject] @{
            Name      = $Name
            ID        = $AnchorName #"TabPanelID-$(Get-RandomStringName -Size 8 -LettersOnly)"
            Icon      = $Icon
            StyleIcon = $StyleIcon
            StyleText = $StyleText
            Content   = $TabExecutedCode
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLTab -ParameterName IconColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTab -ParameterName TextColor -ScriptBlock $Script:ScriptBlockColors

function New-HTMLTable {
    [alias('Table', 'EmailTable')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $HTML,
        [Parameter(Mandatory = $false, Position = 1)][ScriptBlock] $PreContent,
        [Parameter(Mandatory = $false, Position = 2)][ScriptBlock] $PostContent,
        [alias('ArrayOfObjects', 'Object', 'Table')][Array] $DataTable,
        [string] $Title,
        [string[]][ValidateSet('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'print', 'searchPanes')] $Buttons = @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength'),
        [string[]][ValidateSet('numbers', 'simple', 'simple_numbers', 'full', 'full_numbers', 'first_last_numbers')] $PagingStyle = 'full_numbers',
        [int[]]$PagingOptions = @(15, 25, 50, 100),
        [int] $PagingLength,
        [switch]$DisablePaging,
        [switch]$DisableOrdering,
        [switch]$DisableInfo,
        [switch]$HideFooter,
        [alias('DisableButtons')][switch]$HideButtons,
        [switch]$DisableProcessing,
        [switch]$DisableResponsiveTable,
        [switch]$DisableSelect,
        [switch]$DisableStateSave,
        [switch]$DisableSearch,
        [switch]$OrderMulti,
        [switch]$Filtering,
        [ValidateSet('Top', 'Bottom', 'Both')][string]$FilteringLocation = 'Bottom',
        [string[]][ValidateSet('display', 'cell-border', 'compact', 'hover', 'nowrap', 'order-column', 'row-border', 'stripe')] $Style = @('display', 'compact'),
        [switch]$Simplify,
        [string]$TextWhenNoData = 'No data available to display.',
        [int] $ScreenSizePercent = 0,
        [string[]] $DefaultSortColumn,
        [int[]] $DefaultSortIndex,
        [ValidateSet('Ascending', 'Descending')][string] $DefaultSortOrder = 'Ascending',
        [string[]] $DateTimeSortingFormat,
        [alias('Search')][string]$Find,
        [switch] $InvokeHTMLTags,
        [switch] $DisableNewLine,
        [switch] $EnableKeys,
        [switch] $EnableColumnReorder,
        [switch] $EnableRowReorder,
        [switch] $EnableAutoFill,
        [switch] $EnableScroller,
        [switch] $ScrollX,
        [switch] $ScrollY,
        [int] $ScrollSizeY = 500,
        [switch]$ScrollCollapse,
        [int] $FreezeColumnsLeft,
        [int] $FreezeColumnsRight,
        [switch] $FixedHeader,
        [switch] $FixedFooter,
        [string[]] $ResponsivePriorityOrder,
        [int[]] $ResponsivePriorityOrderIndex,
        [string[]] $PriorityProperties,
        [string[]] $IncludeProperty,
        [string[]] $ExcludeProperty,
        [switch] $ImmediatelyShowHiddenDetails,
        [alias('RemoveShowButton')][switch] $HideShowButton,
        [switch] $AllProperties,
        [switch] $SkipProperties,
        [switch] $Compare,
        [alias('CompareWithColors')][switch] $HighlightDifferences,
        [int] $First,
        [int] $Last,
        [alias('Replace')][Array] $CompareReplace,
        [alias('RegularExpression')][switch]$SearchRegularExpression,
        [ValidateSet('normal', 'break-all', 'keep-all', 'break-word')][string] $WordBreak = 'normal',
        [switch] $AutoSize,
        [switch] $DisableAutoWidthOptimization,
        [switch] $SearchPane,
        [ValidateSet('top', 'bottom')][string] $SearchPaneLocation = 'top',
        [switch] $SearchBuilder,
        [ValidateSet('top', 'bottom')][string] $SearchBuilderLocation = 'top',
        [ValidateSet('HTML', 'JavaScript', 'AjaxJSON')][string] $DataStore,
        [alias('DataTableName')][string] $DataTableID,
        [string] $DataStoreID,
        [switch] $Transpose,
        [string] $OverwriteDOM,
        [switch] $SearchHighlight,
        [switch] $AlphabetSearch
    )
    if (-not $Script:HTMLSchema.Features) {
        Write-Warning 'New-HTMLTable - Creation of HTML aborted. Most likely New-HTML is missing.'
        Exit
    }
    $Script:HTMLSchema.Features.MainFlex = $true
    # Building HTML Table / Script
    if (-not $DataTableID) {
        # Only define this if user failed to deliver as per https://github.com/EvotecIT/PSWriteHTML/issues/29
        $DataTableID = "DT-$(Get-RandomStringName -Size 8 -LettersOnly)" # this builds table ID
    }
    # This makes sure we only load proper JS/CSS code when simplify is used
    if ($Simplify) {
        $Script:HTMLSchema['TableSimplify'] = $true
    } else {
        $Script:HTMLSchema['TableSimplify'] = $false
    }

    if ($HideFooter -and $Filtering -and $FilteringLocation -notin @('Both', 'Top')) {
        Write-Warning 'New-HTMLTable - Hiding footer while filtering is requested without specifying FilteringLocation to Top or Both.'
    }
    # There are 3 types of storage: HTML, JavaScript, File
    if ($DataStore -eq '') {
        if ($Script:HTMLSchema.TableOptions.DataStore) {
            # If DataStore is not picked locally, we use global value (assuming it's set)
            $DataStore = $Script:HTMLSchema.TableOptions.DataStore
        } else {
            # No global value, no local value, we set it default
            $DataStore = 'HTML'
        }
    }
    if ($DataStore -eq 'AjaxJSON') {
        if (-not $Script:HTMLSchema['TableOptions']['Folder']) {
            Write-Warning "New-HTMLTable - FilePath wasn't used in New-HTML. It's required for Hosted Solution."
            return
        }
    }
    if ($DataStoreID -and $DataStore -ne 'JavaScript') {
        Write-Warning "New-HTMLTable - Using DataStoreID is only supported if DataStore is JavaScript. It doesn't do anything without it"
    }

    # Theme creator  https://datatables.net/manual/styling/theme-creator
    $ConditionalFormatting = [System.Collections.Generic.List[PSCustomObject]]::new()
    $ConditionalFormattingInline = [System.Collections.Generic.List[PSCustomObject]]::new()
    $CustomButtons = [System.Collections.Generic.List[PSCustomObject]]::new()
    $HeaderRows = [System.Collections.Generic.List[PSCustomObject]]::new()
    $HeaderStyle = [System.Collections.Generic.List[PSCustomObject]]::new()
    $HeaderTop = [System.Collections.Generic.List[PSCustomObject]]::new()
    $HeaderResponsiveOperations = [System.Collections.Generic.List[PSCustomObject]]::new()
    $ContentRows = [System.Collections.Generic.List[PSCustomObject]]::new()
    $ContentStyle = [System.Collections.Generic.List[PSCustomObject]]::new()
    $ContentTop = [System.Collections.Generic.List[PSCustomObject]]::new()
    $ReplaceCompare = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $TableColumnOptions = [System.Collections.Generic.List[PSCustomObject]]::new()
    $TableEvents = [System.Collections.Generic.List[PSCustomObject]]::new()
    $TablePercentageBar = [System.Collections.Generic.List[PSCustomObject]]::new()
    $TableAlphabetSearch = [ordered]@{}

    # This will be used to store the colulmnDef option for the datatable
    $ColumnDefinitionList = [System.Collections.Generic.List[PSCustomObject]]::New()
    $RowGrouping = @{ }

    if ($Transpose) {
        # Allows easy conversion from PSCustomObject to Hashtable and vice versa
        $DataTable = Format-TransposeTable -Object $DataTable
    }

    if ($HTML) {
        [Array] $Output = & $HTML

        if ($Output.Count -gt 0) {
            foreach ($Parameters in $Output) {
                if ($Parameters.Type -eq 'TableButtonPDF') {
                    $CustomButtons.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableButtonCSV') {
                    $CustomButtons.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableButtonPageLength') {
                    $CustomButtons.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableButtonExcel') {
                    $CustomButtons.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableButtonPDF') {
                    $CustomButtons.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableButtonPrint') {
                    $CustomButtons.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableButtonCopy') {
                    $CustomButtons.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableCondition') {
                    $ConditionalFormatting.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableConditionGroup') {
                    $ConditionalFormatting.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableHeaderMerge') {
                    $HeaderRows.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableHeaderStyle') {
                    $HeaderStyle.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableHeaderFullRow') {
                    $HeaderTop.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableContentMerge') {
                    $ContentRows.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableContentStyle') {
                    $ContentStyle.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableContentFullRow') {
                    $ContentTop.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableConditionInline') {
                    $ConditionalFormattingInline.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableConditionGroupInline') {
                    $ConditionalFormattingInline.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableHeaderResponsiveOperations') {
                    $HeaderResponsiveOperations.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableReplaceCompare') {
                    $ReplaceCompare.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableRowGrouping') {
                    $RowGrouping = $Parameters.Output
                } elseif ($Parameters.Type -eq 'TableColumnOption') {
                    $TableColumnOptions.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableEvent') {
                    $TableEvents.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TablePercentageBar') {
                    $TablePercentageBar.Add($Parameters.Output)
                } elseif ($Parameters.Type -eq 'TableAlphabetSearch') {
                    $TableAlphabetSearch = $Parameters.Output
                }
            }
        }
    }
    # Autosize removes $Width of 100%, which means it will fit the content rather then trying to fill the screen
    if (-not $AutoSize) {
        [string] $Width = '100%'
    }

    # Limit objects count First or Last
    if ($First -or $Last) {
        $DataTable = $DataTable | Select-Object -First $First -Last $Last
    }

    if ($Compare) {
        $Splitter = "`r`n"

        if ($ReplaceCompare) {
            foreach ($R in $CompareReplace) {
                $ReplaceCompare.Add($R)
            }
        }

        $DataTable = Compare-MultipleObjects -Objects $DataTable -Summary -Splitter $Splitter -FormatOutput -AllProperties:$AllProperties -SkipProperties:$SkipProperties -Replace $ReplaceCompare

        if ($HighlightDifferences) {
            $Highlight = for ($i = 0; $i -lt $DataTable.Count; $i++) {
                if ($DataTable[$i].Status -eq $false) {
                    # Different row
                    foreach ($DifferenceColumn in $DataTable[$i].Different) {
                        $DataSame = $DataTable[$i]."$DifferenceColumn-Same" -join $Splitter
                        $DataAdd = $DataTable[$i]."$DifferenceColumn-Add" -join $Splitter
                        $DataRemove = $DataTable[$i]."$DifferenceColumn-Remove" -join $Splitter

                        if ($DataSame -ne '') {
                            $DataSame = "$DataSame$Splitter"
                        }
                        if ($DataAdd -ne '') {
                            $DataAdd = "$DataAdd$Splitter"
                        }
                        if ($DataRemove -ne '') {
                            $DataRemove = "$DataRemove$Splitter"
                        }
                        $Text = New-HTMLText -Text $DataSame, $DataRemove, $DataAdd -Color Black, Red, Blue -TextDecoration none, line-through, none -FontWeight normal, bold, bold
                        New-TableContent -ColumnName "$DifferenceColumn" -RowIndex ($i + 1) -Text "$Text"
                    }
                } else {
                    # Same row
                    # New-TableContent -RowIndex ($i + 1) -BackGroundColor Green -Color White
                }
            }
        }
        $Properties = Select-Properties -Objects $DataTable -ExcludeProperty '*-*', 'Same', 'Different'
        $DataTable = $DataTable | Select-Object -Property $Properties

        if ($HighlightDifferences) {
            foreach ($Parameter in $Highlight.Output) {
                $ContentStyle.Add($Parameter)
            }
        }
    }

    # this handles no data in Table - we want table to be minimalistic then with just 1 element
    # this also handles situation if first element is null, if that happens it assumes whole array is null and sets no data
    if ($null -eq $DataTable -or $DataTable.Count -eq 0 -or $null -eq $DataTable[0]) {
        if ($DataTable.Count -gt 0) {
            Write-Warning "New-HTMLTable - First element of array is null, but there are more elements in array that were ignored. Please verify your DataTable input."
        }
        $Filtering = $false # setting it to false because it's not nessecary
        $HideFooter = $true
        [Array] $DataTable = $TextWhenNoData
    }

    # we don't do anything for dictionaries, as dictionaries are displayed in two columns approach
    if ($DataTable[0] -isnot [System.Collections.IDictionary]) {
        if ($AllProperties) {
            $Properties = Select-Properties -Objects $DataTable -AllProperties:$AllProperties -Property $IncludeProperty -ExcludeProperty $ExcludeProperty
            if ($Properties -ne '*') {
                $DataTable = $DataTable | Select-Object -Property $Properties
            }
        } else {
            # JavaScript datastore is very picky for the inserted data so columns need to match for each object in array
            # SO if 1st object has 3 columns called X,Y,Z and 2nd object has X,Y,G we need to make sure we force 2nd object to have X,Y,Z (Z will be empty) and skip G
            # If you need need G as well you need to use AllProperties switch
            if ($DataStore -in 'JavaScript', 'AjaxJSON') {
                $Properties = Select-Properties -Objects $DataTable -Property $IncludeProperty -ExcludeProperty $ExcludeProperty
                if ($Properties -ne '*') {
                    $DataTable = $DataTable | Select-Object -Property $Properties
                }
            } else {
                if ($IncludeProperty -or $ExcludeProperty) {
                    $Properties = Select-Properties -Objects $DataTable -Property $IncludeProperty -ExcludeProperty $ExcludeProperty
                    if ($Properties -ne '*') {
                        $DataTable = $DataTable | Select-Object -Property $Properties
                    }
                }
            }
        }
    }
    # This is more direct way of PriorityProperties that will work also on Scroll and in other circumstances
    if ($PriorityProperties) {
        if ($DataTable.Count -gt 0) {
            $Properties = $DataTable[0].PSObject.Properties.Name
            # $Properties = Select-Properties -Objects $DataTable -AllProperties:$AllProperties
            $RemainingProperties = foreach ($Property in $Properties) {
                if ($PriorityProperties -notcontains $Property) {
                    $Property
                }
            }
            $BoundedProperties = $PriorityProperties + $RemainingProperties
            $DataTable = $DataTable | Select-Object -Property $BoundedProperties
        }
    }

    # This option disable paging if number of elements is less or equal count of elements in DataTable
    $PagingOptions = $PagingOptions | Sort-Object -Unique

    $Options = [ordered] @{
        'dom'            = $null
        "searchFade"     = $false
        # https://datatables.net/examples/basic_init/scroll_y_dynamic.html
        "scrollCollapse" = $ScrollCollapse.IsPresent
        "ordering"       = -not $DisableOrdering.IsPresent
        "order"          = @() # this makes sure there's no default ordering upon start (usually it would be 1st column)
        "rowGroup"       = ''
        "info"           = -not $DisableInfo.IsPresent
        "procesing"      = -not $DisableProcessing.IsPresent
        "select"         = -not $DisableSelect.IsPresent
        "searching"      = -not $DisableSearch.IsPresent
        "stateSave"      = -not $DisableStateSave.IsPresent
        "paging"         = -not $DisablePaging
        <# Paging Type
            numbers - Page number buttons only
            simple - 'Previous' and 'Next' buttons only
            simple_numbers - 'Previous' and 'Next' buttons, plus page numbers
            full - 'First', 'Previous', 'Next' and 'Last' buttons
            full_numbers - 'First', 'Previous', 'Next' and 'Last' buttons, plus page numbers
            first_last_numbers - 'First' and 'Last' buttons, plus page numbers
        #>
        "pagingType"     = $PagingStyle
        "lengthMenu"     = @(
            , @($PagingOptions + (-1))
            , @($PagingOptions + "All")
        )
    }
    if ($PagingLength) {
        # User made a choice for page length
        $Options['pageLength'] = $PagingLength
    } elseif ($PagingOptions[0] -ne 15) {
        # User didn't made a choice for page length, but user made a choice for paging options (default set by us is different)
        $Options['pageLength'] = $PagingOptions[0]
    }
    # Set DOM
    <# DOM Definition: https://datatables.net/reference/option/dom
        l - length changing input control
        f - filtering input
        t - The table!
        i - Table information summary
        p - pagination control
        r - processing display element
        B - Buttons
        S - Select
        F - FadeSeaerch
        P - SearchPanes
        H - jQueryUI theme "header" classes (fg-toolbar ui-widget-header ui-corner-tl ui-corner-tr ui-helper-clearfix)
        F - jQueryUI theme "footer" classes (fg-toolbar ui-widget-header ui-corner-bl ui-corner-br ui-helper-clearfix)
        Q - SearchBuilder
    #>
    if ($AlphabetSearch -or $TableAlphabetSearch.Count -gt 0) {
        $Script:HTMLSchema.Features.DataTablesSearchAlphabet = $true
    }
    if ($SearchBuilder) {
        $Script:HTMLSchema.Features.DataTablesSearchBuilder = $true
    }
    if ($SearchPane) {
        $Script:HTMLSchema.Features.DataTablesSearchPanes = $true
    }
    if ($OverwriteDOM) {
        # We allow user to decide how DOM looks like
        $Options['dom'] = $OverwriteDOM
    } else {
        $DOM = 'Bfrtip'
        if ($AlphabetSearch) {
            $DOM = "A$($Dom)"
        }
        if ($SearchBuilder -and $SearchPane) {
            if ($SearchPaneLocation -eq 'top' -and $SearchBuilderLocation -eq 'top') {
                $Options['dom'] = "QP$($DOM)"
            } elseif ($SearchPaneLocation -eq 'top' -and $SearchBuilderLocation -eq 'bottom') {
                $Options['dom'] = "P$($DOM)Q"
            } elseif ($SearchPaneLocation -eq 'bottom' -and $SearchBuilderLocation -eq 'top') {
                $Options['dom'] = "Q$($DOM)P"
            } elseif ($SearchPaneLocation -eq 'bottom' -and $SearchBuilderLocation -eq 'bottom') {
                $Options['dom'] = "$($DOM)QP"
            }
        } elseif ($SearchBuilder) {
            if ($SearchBuilderLocation -eq 'top') {
                $Options['dom'] = "Q$($DOM)"
            } else {
                $Options['dom'] = "$($DOM)Q"
            }
        } elseif ($SearchPane) {
            # it seems DataTablesSearchPanes is conflicting with Diagrams in IE 11, so we only enable it on demand
            if ($SearchPaneLocation -eq 'top') {
                $Options['dom'] = "P$($DOM)"
            } else {
                $Options['dom'] = "$($DOM)P"
            }
        } else {
            $Options['dom'] = "$($DOM)"
        }
    }
    if ($Buttons -contains 'searchPanes') {
        # it seems DataTablesSearchPanes is conflicting with Diagrams in IE 11, so we only enable it on demand
        $Script:HTMLSchema.Features.DataTablesSearchPanes = $true
        $Script:HTMLSchema.Features.DataTablesSearchPanesButton = $true
    }
    if ($EnableKeys) {
        $Script:HTMLSchema.Features.DataTablesKeyTable = $true
        $Options['keys'] = $true
        # More options to check # https://datatables.net/extensions/keytable/examples/
        #$Options['keys'] = @{
        #    blurable = $false
        #}
    }
    if ($EnableAutoFill) {
        $Script:HTMLSchema.Features.DataTablesAutoFill = $true
        $Options['autoFill'] = $true
    }
    if ($SearchHighlight) {
        $Script:HTMLSchema.Features.DataTablesSearchHighlight = $true
        $Options['searchHighlight'] = $true
    }
    # Prepare data for preprocessing. Convert Hashtable/Ordered Dictionary to their visual representation
    $Table = $null
    if ($DataTable[0] -is [System.Collections.IDictionary]) {
        [Array] $Table = foreach ($_ in $DataTable) {
            $_.GetEnumerator() | Select-Object Name, Value
        }
        $ObjectProperties = 'Name', 'Value'
    } elseif ($DataTable[0].GetType().Name -match 'bool|byte|char|datetime|decimal|double|ExcelHyperLink|float|int|long|sbyte|short|string|timespan|uint|ulong|URI|ushort') {
        [Array] $Table = $DataTable | ForEach-Object { [PSCustomObject]@{ 'Name' = $_ } }
        $ObjectProperties = 'Name'
    } else {
        [Array] $Table = $DataTable
        $ObjectProperties = $DataTable[0].PSObject.Properties.Name
    }

    if ($DataStore -eq 'HTML') {
        #  Standard way to build inline table

        # Since converting object with array inside with ConvertTo-HTML is useless we let the user ability to tell and fix that by joining it
        # it also deals with dates conversion
        if ($Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoin -or $Script:HTMLSchema['TableOptions']['DataStoreOptions'].DateTimeFormat) {
            foreach ($Row in $Table) {
                foreach ($Name in $Row.PSObject.Properties.Name) {
                    if ($Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoin -and $Row.$Name -is [Array]) {
                        $Row.$Name = $Row.$Name -join $Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoinString
                    } elseif ($Script:HTMLSchema['TableOptions']['DataStoreOptions'].DateTimeFormat -and $Row.$Name -is [DateTime]) {
                        $Row.$Name = $($Row.$Name).ToString($Script:HTMLSchema['TableOptions']['DataStoreOptions'].DateTimeFormat)
                    }
                }
            }
        }
        $Table = $Table | ConvertTo-Html -Fragment | Select-Object -SkipLast 1 | Select-Object -Skip 2 # This removes table tags (open/closing)
        [string] $Header = $Table | Select-Object -First 1 # this gets header
        [string[]] $HeaderNames = $Header -replace '</th></tr>' -replace '<tr><th>' -split '</th><th>'
        if ($HeaderNames -eq '*') {
            # HeaderNames normally contain proper header names, however ConvertTo-HTML -Fragment in PowerShell 5.1 incorrectly sets it to *
            # PowerShell 7 works without issues. This is reproducible with [PSCustomObject]@{ 'Name' = 'Test' } | ConvertTo-Html -Fragment
            $Header = $Header.Replace('*', $ObjectProperties)
            $HeaderNames = $ObjectProperties
        }
        # This modifies Table content.
        # It basically goes thru every single row and checks if values to add styles or inline conditional formatting
        # It's heavier then JS, so use when nessecary
        if ($ContentRows.Capacity -gt 0 -or $ContentStyle.Count -gt 0 -or $ContentTop.Count -gt 0 -or $ConditionalFormattingInline.Count -gt 0) {
            $Table = Add-TableContent -ContentRows $ContentRows -ContentStyle $ContentStyle -ContentTop $ContentTop -ContentFormattingInline $ConditionalFormattingInline -Table $Table -HeaderNames $HeaderNames
        }
        $Table = $Table | Select-Object -Skip 1 # this gets actuall table content
    } elseif ($DataStore -eq 'AjaxJSON') {
        # this is hosted solution that only works on servers
        # this is a bit different so there's no full html building
        [string] $Header = $Table | ConvertTo-Html -Fragment | Select-Object -Skip 2 -First 1
        [string[]] $HeaderNames = $Header -replace '</th></tr>' -replace '<tr><th>' -split '</th><th>'
        if ($HeaderNames -eq '*') {
            # HeaderNames normally contain proper header names, however ConvertTo-HTML -Fragment in PowerShell 5.1 incorrectly sets it to *
            # PowerShell 7 works without issues. This is reproducible with [PSCustomObject]@{ 'Name' = 'Test' } | ConvertTo-Html -Fragment
            $Header = $Header.Replace('*', $ObjectProperties)
            $HeaderNames = $ObjectProperties
        }
        New-TableServerSide -DataTable $Table -DataTableID $DataTableID -Options $Options -HeaderNames $HeaderNames
        $Table = $null
    } elseif ($DataStore -eq 'JavaScript') {
        # This puts data as JavaScript Data field inline in html
        [string] $Header = $Table | ConvertTo-Html -Fragment | Select-Object -Skip 2 -First 1
        [string[]] $HeaderNames = $Header -replace '</th></tr>' -replace '<tr><th>' -split '</th><th>'
        if ($HeaderNames -eq '*') {
            # HeaderNames normally contain proper header names, however ConvertTo-HTML -Fragment in PowerShell 5.1 incorrectly sets it to *
            # PowerShell 7 works without issues. This is reproducible with [PSCustomObject]@{ 'Name' = 'Test' } | ConvertTo-Html -Fragment
            $Header = $Header.Replace('*', $ObjectProperties)
            $HeaderNames = $ObjectProperties
        }
        New-TableJavaScript -HeaderNames $HeaderNames -Options $Options
        # Due to ConvertTo-Json depth we can't insert data from Table to $Options here.
        # We need to wait and insert it after it's converted to JSON
    }

    # This modifies header adding styles, header rows, or doing some fancy stuff
    $AddedHeader = Add-TableHeader -HeaderRows $HeaderRows -HeaderNames $HeaderNames -HeaderStyle $HeaderStyle -HeaderTop $HeaderTop -HeaderResponsiveOperations $HeaderResponsiveOperations


    if ($TableAlphabetSearch.Count -gt 0) {
        $Options['alphabet'] = @{}
        if ($TableAlphabetSearch.caseSensitive) {
            $Options['alphabet']['caseSensitive'] = $true
        }
        if ($TableAlphabetSearch.numbers) {
            $Options['alphabet']['numbers'] = $true
        }
        if ($null -ne $TableAlphabetSearch.ColumnName) {
            $TableAlphabetSearch.ColumnID = ($HeaderNames).ToLower().IndexOf($TableAlphabetSearch.ColumnName.ToLower())
        }
        if ($null -ne $TableAlphabetSearch.ColumnID) {
            $Options['alphabet']['column'] = $TableAlphabetSearch.ColumnID
        }
    }

    if (-not $Script:HTMLSchema['TableSimplify'] -and -not $HideButtons) {
        $Script:HTMLSchema.Features.DataTablesButtons = $true
        $Options['buttons'] = @(
            if ($CustomButtons) {
                $CustomButtons
            } else {
                foreach ($button in $Buttons) {
                    if ($button -eq 'pdfHtml5') {
                        $ButtonOutput = [ordered] @{
                            extend      = 'pdfHtml5'
                            pageSize    = 'A3'
                            orientation = 'landscape'
                            title       = $Title
                        }
                        $Script:HTMLSchema.Features.DataTablesButtonsPDF = $true
                    } elseif ($button -eq 'pageLength') {
                        if (-not $DisablePaging -and -not $ScrollY) {
                            $ButtonOutput = @{
                                extend = $button
                            }
                        } else {
                            $ButtonOutput = $null
                        }
                    } elseif ($button -eq 'excelHtml5') {
                        $Script:HTMLSchema.Features.DataTablesButtonsHTML5 = $true
                        $Script:HTMLSchema.Features.DataTablesButtonsExcel = $true
                        $ButtonOutput = [ordered] @{
                            extend        = $button
                            title         = $Title
                            exportOptions = @{
                                #columns = 'visible'
                                format = "findExportOptions"
                            }
                        }
                    } elseif ($button -eq 'copyHtml5') {
                        $Script:HTMLSchema.Features.DataTablesButtonsHTML5 = $true
                        $ButtonOutput = [ordered] @{
                            extend = $button
                            title  = $Title
                        }
                    } elseif ($button -eq 'csvHtml5') {
                        $Script:HTMLSchema.Features.DataTablesButtonsHTML5 = $true
                        $ButtonOutput = [ordered] @{
                            extend = $button
                            title  = $Title
                        }
                    } elseif ($button -eq 'searchPanes') {
                        $Script:HTMLSchema.Features.DataTablesSearchPanes = $true
                        $ButtonOutput = [ordered] @{
                            extend = $button
                            title  = $Title
                        }
                    } elseif ($button -eq 'print') {
                        $Script:HTMLSchema.Features.DataTablesButtonsPrint = $true
                        $ButtonOutput = [ordered] @{
                            extend = $button
                            title  = $Title
                        }
                    } else {
                        $ButtonOutput = [ordered] @{
                            extend = $button
                            title  = $Title
                        }
                    }
                    if ($ButtonOutput) {
                        Remove-EmptyValue -Hashtable $ButtonOutput
                        $ButtonOutput
                    }
                }
            }
        )
    } else {
        $Options['buttons'] = @()
    }
    if ($ScrollX) {
        $Options.'scrollX' = $true
        # disabling responsive table because it won't work with ScrollX
        $DisableResponsiveTable = $true
    }
    if ($ScrollY -or $EnableScroller) {
        # Scroller only works if ScrollY is set
        $Options.'scrollY' = "$($ScrollSizeY)px"
    }
    if (-not $Script:HTMLSchema['TableSimplify'] -and $EnableScroller) {
        $Script:HTMLSchema.Features.DataTablesScroller = $true
        $Options['scroller'] = @{
            loadingIndicator = $true
        }
        #$Options['scroller'] = $true
    }
    if (-not $Script:HTMLSchema['TableSimplify'] -and $EnableRowReorder) {
        $Script:HTMLSchema.Features.DataTablesRowReorder = $true
        $Options['rowReorder'] = $true
    }

    if (-not $Script:HTMLSchema['TableSimplify'] -and ($FreezeColumnsLeft -or $FreezeColumnsRight)) {
        $Script:HTMLSchema.Features.DataTablesFixedColumn = $true
        $Options['fixedColumns'] = [ordered] @{ }
        if ($FreezeColumnsLeft) {
            $Options.fixedColumns.leftColumns = $FreezeColumnsLeft
        }
        if ($FreezeColumnsRight) {
            $Options.fixedColumns.rightColumns = $FreezeColumnsRight
        }
    }
    if (-not $Script:HTMLSchema['TableSimplify'] -and ($FixedHeader -or $FixedFooter)) {
        $Script:HTMLSchema.Features.DataTablesFixedHeader = $true
        # Using FixedHeader/FixedFooter won't work with ScrollY.
        # Setting any of those requires to set both of them to prevent one being enabled even if we only requested one
        $Options['fixedHeader'] = [ordered] @{
            header = $FixedHeader.IsPresent
            footer = $FixedFooter.IsPresent
        }
    }

    # this was due to: https://github.com/DataTables/DataTablesSrc/issues/143
    if (-not $Script:HTMLSchema['TableSimplify'] -and -not $DisableResponsiveTable) {
        $Script:HTMLSchema.Features.DataTablesResponsive = $true
        $Options["responsive"] = @{ }
        $Options["responsive"]['details'] = @{ }
        if ($ImmediatelyShowHiddenDetails) {
            $Options["responsive"]['details']['display'] = '$.fn.dataTable.Responsive.display.childRowImmediate'
        }
        if ($HideShowButton) {
            $Options["responsive"]['details']['type'] = 'none' # this makes button invisible
        } else {
            $Options["responsive"]['details']['type'] = 'inline' # this adds a button
        }
    } else {
        # HideSHowButton doesn't work
        # ImmediatelyShowHiddenDetails doesn't work
        # Maybe I should communicate this??
        # Better would be with parametersets but don't want to play now
    }


    if ($OrderMulti) {
        $Options.orderMulti = $OrderMulti.IsPresent
    }
    if ($Find -ne '') {
        $Options.search = @{
            search = $Find
        }
    }

    [int] $RowGroupingColumnID = -1
    if ($RowGrouping.Count -gt 0) {
        if ($RowGrouping.Name) {
            $RowGroupingColumnID = ($HeaderNames).ToLower().IndexOf($RowGrouping.Name.ToLower())
        } else {
            $RowGroupingColumnID = $RowGrouping.ColumnID
        }
        if ($RowGroupingColumnID -ne -1) {
            $ColumnsOrder = , @($RowGroupingColumnID, $RowGrouping.Sorting)
            if ($DefaultSortColumn.Count -gt 0 -or $DefaultSortIndex.Count -gt 0) {
                Write-Warning 'New-HTMLTable - Row grouping sorting overwrites default sorting.'
            }
        } else {
            Write-Warning 'New-HTMLTable - Row grouping disabled. Column name/id not found.'
        }
    } else {
        # Sorting
        if ($DefaultSortOrder -eq 'Ascending') {
            $Sort = 'asc'
        } else {
            $Sort = 'desc'
        }
        if ($DefaultSortColumn.Count -gt 0) {
            $ColumnsOrder = foreach ($Column in $DefaultSortColumn) {
                $DefaultSortingNumber = ($HeaderNames).ToLower().IndexOf($Column.ToLower())
                if ($DefaultSortingNumber -ne - 1) {
                    , @($DefaultSortingNumber, $Sort)
                }
            }

        }
        if ($DefaultSortIndex.Count -gt 0 -and $DefaultSortColumn.Count -eq 0) {
            $ColumnsOrder = foreach ($Column in $DefaultSortIndex) {
                if ($Column -ne - 1) {
                    , @($Column, $Sort)
                }
            }
        }
    }
    if ($ColumnsOrder.Count -gt 0) {
        $Options."order" = @($ColumnsOrder)
        # there seems to be a bug in ordering and colReorder plugin
        # Disabling colReorder
        #$Options.colReorder = $false
    }
    if (-not $Script:HTMLSchema['TableSimplify'] -and $EnableColumnReorder -and $ColumnsOrder.Count -eq 0) {
        $Script:HTMLSchema.Features.DataTablesColReorder = $true
        $Options["colReorder"] = $true
    }

    # Overwriting table size - screen size in percent. With added Section/Panels it shouldn't be more than 90%
    if ($ScreenSizePercent -gt 0) {
        $Options."scrollY" = "$($ScreenSizePercent)vh"
    }
    if ($null -ne $ConditionalFormatting -and $ConditionalFormatting.Count -gt 0) {
        $Options.createdRow = ''
    }

    if ($ResponsivePriorityOrderIndex -or $ResponsivePriorityOrder) {

        $PriorityOrder = 0

        [Array] $PriorityOrderBinding = @(
            foreach ($_ in $ResponsivePriorityOrder) {
                $Index = [array]::indexof($HeaderNames.ToUpper(), $_.ToUpper())
                if ($Index -ne -1) {
                    [pscustomobject]@{ responsivePriority = 0; targets = $Index }
                }
            }
            foreach ($_ in $ResponsivePriorityOrderIndex) {
                [pscustomobject]@{ responsivePriority = 0; targets = $_ }
            }
        )

        foreach ($_ in $PriorityOrderBinding) {
            $PriorityOrder++
            $_.responsivePriority = $PriorityOrder
            $ColumnDefinitionList.Add($_)
        }
    }

    # The table column options also adds to the columnDefs parameter
    If ($TableColumnOptions.Count -gt 0) {
        foreach ($_ in $TableColumnOptions) {
            $ColumnDefinitionList.Add($_)
        }
    }

    if ($TablePercentageBar.Count -gt 0) {
        $Script:HTMLSchema.Features.DataTablesPercentageBars = $true
        foreach ($Bar in $TablePercentageBar) {
            $ColumnDefinitionList.Add($(New-TablePercentageBarInternal @Bar))
        }
    }

    # If we have a column definition list defined, then set the columnDefs option
    If ($ColumnDefinitionList.Count -gt 0) {
        $Options.columnDefs = $ColumnDefinitionList.ToArray()
    }

    If ($DisableAutoWidthOptimization) {
        $Options.autoWidth = $false
    }

    $Options = $Options | ConvertTo-JsonLiteral -Depth 6 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' }

    # cleans up $Options for ImmediatelyShowHiddenDetails
    # Since it's JavaScript inside we're basically removing double quotes from JSON in favor of no quotes at all
    # Before: "display": "$.fn.dataTable.Responsive.display.childRowImmediate"
    # After: "display": $.fn.dataTable.Responsive.display.childRowImmediate
    $Options = $Options -replace '"(\$\.fn\.dataTable\.Responsive\.display\.childRowImmediate)"', '$1'
    $Options = $Options -replace '"(\$\.fn\.dataTable\.render\.percentBar\(.+\))"', '$1'

    #
    $ExportExcelOptions = @'
    {
        body: function (data, row, column, node) {
            data = $('<p>' + data + '</p>').text(); return $.isNumeric(data.replace(',', '.')) ? data.replace(',', '.') : data;
        }
    }
'@
    $Options = $Options.Replace('"findExportOptions"', $ExportExcelOptions)

    if ($DataStore -eq 'JavaScript') {
        # Since we only want first level of data from DataTable we need to do it via string replacement.
        # ConvertTo-Json -Depth 6 from Options above would copy nested objects
        if ($DataStoreID) {
            # We decided we want to separate JS data from the table. This is useful for 2 reason
            # Data is pushed to footer and doesn't take place inside Body
            # Data can be reused in multiple tables for display purposes of same thing but in different table
            $Options = $Options.Replace('"markerForDataReplacement"', $DataStoreID)
            # We only add data if it isn't added yet
            if (-not $Script:HTMLSchema.CustomFooterJS[$DataStoreID]) {
                $DataToInsert = $Table | ConvertTo-JsonLiteral -Depth 0 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' } `
                    -NumberAsString:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].NumberAsString `
                    -BoolAsString:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].BoolAsString `
                    -DateTimeFormat $Script:HTMLSchema['TableOptions']['DataStoreOptions'].DateTimeFormat `
                    -NewLineFormat $Script:HTMLSchema['TableOptions']['DataStoreOptions'].NewLineFormat -Force `
                    -ArrayJoin:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoin `
                    -ArrayJoinString $Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoinString
                if ($DataToInsert.StartsWith('[')) {
                    $Script:HTMLSchema.CustomFooterJS[$DataStoreID] = "var $DataStoreID = $DataToInsert;"
                } else {
                    $Script:HTMLSchema.CustomFooterJS[$DataStoreID] = "var $DataStoreID = [$DataToInsert];"
                }
            }

        } else {
            $DataToInsert = $Table | ConvertTo-JsonLiteral -Depth 0 -AdvancedReplace @{ '.' = '\.'; '$' = '\$' }`
                -NumberAsString:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].NumberAsString `
                -BoolAsString:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].BoolAsString `
                -DateTimeFormat $Script:HTMLSchema['TableOptions']['DataStoreOptions'].DateTimeFormat `
                -NewLineFormat $Script:HTMLSchema['TableOptions']['DataStoreOptions'].NewLineFormat -Force `
                -ArrayJoin:$Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoin `
                -ArrayJoinString $Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoinString
            if ($DataToInsert.StartsWith('[')) {
                $Options = $Options.Replace('"markerForDataReplacement"', $DataToInsert)
            } else {
                $Options = $Options.Replace('"markerForDataReplacement"', "[$DataToInsert]")
            }
        }
        # we need to reset table to $Null to make sure it's not added as HTML as well
        $Table = $null
    }

    # Process Conditional Formatting. Ugly JS building
    $Options = New-TableConditionalFormatting -Options $Options -ConditionalFormatting $ConditionalFormatting -Header $HeaderNames -DataStore $DataStore
    # Process Row Grouping. Ugly JS building
    if ($RowGroupingColumnID -ne -1) {
        $Options = Convert-TableRowGrouping -Options $Options -RowGroupingColumnID $RowGroupingColumnID
        $RowGroupingTop = Add-TableRowGrouping -DataTableName $DataTableID -Top -Settings $RowGrouping
        $RowGroupingBottom = Add-TableRowGrouping -DataTableName $DataTableID -Bottom -Settings $RowGrouping
    }

    [Array] $Tabs = ($Script:HTMLSchema.TabsHeaders | Where-Object { $_.Current -eq $true })
    if ($Tabs.Count -eq 0) {
        # There are no tabs in use, pretend there is only one Active Tab
        $Tab = @{ Active = $true }
    } else {
        # Get First Tab
        $Tab = $Tabs[0]
    }

    # return data
    if (-not $Script:HTMLSchema['TableSimplify']) {
        $Script:HTMLSchema.Features.Jquery = $true
        $Script:HTMLSchema.Features.DataTables = $true
        $Script:HTMLSchema.Features.DataTablesEmail = $true
        $Script:HTMLSchema.Features.Moment = $true
        if (-not $HideButtons) {
            #$Script:HTMLSchema.Features.DataTablesButtonsPDF = $true
            #$Script:HTMLSchema.Features.DataTablesButtonsExcel = $true
        }
        #$Script:HTMLSchema.Features.DataTablesSearchFade = $true

        #if ($ScrollX) {
        #    $TableAttributes = @{ id = $DataTableID; class = "$($Style -join ' ')"; width = $Width }
        #} else {
        $TableAttributes = @{ id = $DataTableID; class = "dataTables $($Style -join ' ')"; width = $Width }
        #}

        # Enable Custom Date fromat sorting
        $SortingFormatDateTime = Add-CustomFormatForDatetimeSorting -DateTimeSortingFormat $DateTimeSortingFormat
        $FilteringOutput = Add-TableFiltering -Filtering $Filtering -FilteringLocation $FilteringLocation -DataTableName $DataTableID -SearchRegularExpression:$SearchRegularExpression
        $FilteringTopCode = $FilteringOutput.FilteringTopCode
        $FilteringBottomCode = $FilteringOutput.FilteringBottomCode
        $LoadSavedState = Add-TableState -DataTableName $DataTableID -Filtering $Filtering -FilteringLocation $FilteringLocation -SavedState (-not $DisableStateSave)
        if ($TableEvents.Count -gt 0) {
            $TableEventsCode = Add-TableEvent -Events $TableEvents -HeaderNames $HeaderNames -DataStore $DataStore
            # this adds required JS script to escape regex when needed
            $Script:HTMLSchema.Features.EscapeRegex = $true
        }

        if ($Tab.Active -eq $true) {
            New-HTMLTag -Tag 'script' {
                @"
                `$(document).ready(function() {
                    $SortingFormatDateTime
                    $RowGroupingTop
                    $LoadSavedState
                    $FilteringTopCode
                    //  Table code
                    var table = `$('#$DataTableID').DataTable(
                        $($Options)
                    );
                    $FilteringBottomCode
                    $RowGroupingBottom
                    $TableEventsCode
                });
"@
                if ($FixedHeader -or $FixedFooter) {
                    "dataTablesFixedTracker['$DataTableID'] = true;"
                }
            }
        } else {
            [string] $TabName = $Tab.Id
            New-HTMLTag -Tag 'script' {
                @"
                    `$(document).ready(function() {
                        $SortingFormatDateTime
                        $RowGroupingTop
                        `$('.tabs').on('click', 'a', function (event) {
                            if (`$(event.currentTarget).attr("data-id") == "$TabName" && !$.fn.dataTable.isDataTable("#$DataTableID")) {
                                $LoadSavedState
                                $FilteringTopCode
                                //  Table code
                                var table = `$('#$DataTableID').DataTable(
                                    $($Options)
                                );
                                $FilteringBottomCode
                            };
                        });
                        $RowGroupingBottom
                    });
"@
                if ($FixedHeader -or $FixedFooter) {
                    "dataTablesFixedTracker['$DataTableID'] = true;"
                }
            }
        }
    } else {
        $TableAttributes = @{ class = 'simplify' }
        $Script:HTMLSchema.Features.DataTablesSimplify = $true
    }

    if ($InvokeHTMLTags) {
        # By default HTML tags are displayed, in this case we're converting tags into real tags
        $Table = $Table -replace '&lt;', '<' -replace '&gt;', '>' -replace '&amp;', '&' -replace '&nbsp;', ' ' -replace '&quot;', '"' -replace '&#39;', "'"
    }
    if (-not $DisableNewLine) {
        # Finds new lines and adds HTML TAG BR
        #$Table = $Table -replace '(?m)\s+$', "`r`n<BR>"
        $Table = $Table -replace '(?m)\s+$', "<BR>"
    }

    if ($OtherHTML) {
        $BeforeTableCode = Invoke-Command -ScriptBlock $OtherHTML
    } else {
        $BeforeTableCode = ''
    }

    if ($PreContent) {
        $BeforeTable = Invoke-Command -ScriptBlock $PreContent
    } else {
        $BeforeTable = ''
    }
    if ($PostContent) {
        $AfterTable = Invoke-Command -ScriptBlock $PostContent
    } else {
        $AfterTable = ''
    }

    if ($RowGrouping.Attributes.Count -gt 0) {
        $RowGroupingCSS = ConvertTo-LimitedCSS -ID $DataTableID -ClassName 'tr.dtrg-group td' -Attributes $RowGrouping.Attributes -Group
    } else {
        $RowGroupingCSS = ''
    }

    if ($Simplify) {
        $AttributeDiv = @{ class = 'flexElement overflowHidden' ; style = @{ display = 'flex' } }
    } else {
        $AttributeDiv = @{ class = 'flexElement overflowHidden' }
    }

    New-HTMLTag -Tag 'div' -Attributes $AttributeDiv -Value {
        $RowGroupingCSS
        $BeforeTableCode
        $BeforeTable
        # Build HTML TABLE

        if ($WordBreak -ne 'normal') {
            New-HTMLTag -Tag 'style' {
                ConvertTo-LimitedCSS -ClassName 'td' -ID $TableAttributes.id -Attributes @{ 'word-break' = $WordBreak }
            }
        }

        New-HTMLTag -Tag 'table' -Attributes $TableAttributes {
            New-HTMLTag -Tag 'thead' {
                if ($AddedHeader) {
                    $AddedHeader
                } else {
                    $Header
                }
            }
            if ($Table) {
                New-HTMLTag -Tag 'tbody' {
                    $Table
                }
            }
            if (-not $HideFooter) {
                New-HTMLTag -Tag 'tfoot' {
                    $Header
                }
            }
        }
        $AfterTable
    }
}

function New-HTMLTableOption {
    <#
    .SYNOPSIS
    Configures New-HTMLTable options

    .DESCRIPTION
    Configures New-HTMLTable options

    .PARAMETER DataStore
    Choose how Data is stored for all tables HTML, JavaScript or AjaxJSON (external file)

    .PARAMETER BoolAsString
    When JavaScript or AjaxJSON is used, forces bool to string

    .PARAMETER NumberAsString
    When JavaScript or AjaxJSON is used, forces number to string

    .PARAMETER DateTimeFormat
    When JavaScript or AjaxJSON is used, one can configure DateTimeFormat (in PowerShell way)

    .PARAMETER NewLineCarriage
    When JavaScript or AjaxJSON is used, one can configure NewLineCarriage. Default NewLineCarriage = '<br>'

    .PARAMETER NewLine
    When JavaScript or AjaxJSON is used, one can configure NewLine. Default value for NewLine = "\n"

    .PARAMETER Carriage
    When JavaScript or AjaxJSON is used, one can configure Carriage. Default value for Carriage = "\r"

    .PARAMETER ArrayJoin
    When JavaScript or AjaxJSON is used, forces any array to be a string regardless of depth level

    .PARAMETER ArrayJoinString
    Uses defined string or char for array join. By default it uses comma with a space when used.

    .EXAMPLE
    New-HTML {
        New-HTMLTableOption -DateTimeFormat "yyyy-MM-dd HH:mm:ss" -BoolAsString
        New-HTMLSection -Invisible {
            New-HTMLSection -HeaderText 'Standard Table with PSCustomObjects' {
                New-HTMLTable -DataTable $DataTable1
            }
            New-HTMLSection -HeaderText 'Standard Table with PSCustomObjects' {
                New-HTMLTable -DataTable $DataTable1 -DataStore JavaScript
            }
        }
    } -ShowHTML

    .NOTES
    General notes
    #>
    [alias('New-TableOption', 'TableOption', 'EmailTableOption')]
    [cmdletBinding()]
    param(
        [ValidateSet('HTML', 'JavaScript', 'AjaxJSON')][string] $DataStore,
        [switch] $BoolAsString,
        [switch] $NumberAsString,
        [string] $DateTimeFormat,
        [string] $NewLineCarriage,
        [string] $NewLine,
        [string] $Carriage,
        [switch] $ArrayJoin,
        [string] $ArrayJoinString = ', '
    )
    if ($Script:HTMLSchema) {
        if ($DataStore ) {
            $Script:HTMLSchema['TableOptions']['DataStore'] = $DataStore
        }
        if ($BoolAsString.IsPresent) {
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].BoolAsString = $BoolAsString.IsPresent
        }
        if ($NumberAsString.IsPresent) {
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].NumberAsString = $NumberAsString.IsPresent
        }
        if ($DateTimeFormat) {
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].DateTimeFormat = $DateTimeFormat
        }
        if ($NewLineCarriage) {
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].NewLineFormat.NewLineCarriage = $NewLineCarriage
        }
        if ($NewLine) {
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].NewLineFormat.NewLine = $NewLine
        }
        if ($Carriage) {
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].NewLineFormat.Carriage = $Carriage
        }
        if ($ArrayJoin) {
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoin = $true
            $Script:HTMLSchema['TableOptions']['DataStoreOptions'].ArrayJoinString = $ArrayJoinString
        }
    }
}
function New-HTMLTableStyle {
    <#
    .SYNOPSIS
    Apply new style for HTML Table

    .DESCRIPTION
    Apply new style for HTML Table. Currently only works with DataTables.

    .PARAMETER Type
    Choose type to apply style on. You can choose from: 'Content', 'Table', 'Header', 'Row', 'Footer', 'RowOdd', 'RowEven', 'RowSelected', 'RowSelectedEven', 'RowSelectedOdd', 'RowHover', 'RowHoverSelected', 'Button'. Content is duplicate to Row.

    .PARAMETER FontSize
    Choose FontSize

    .PARAMETER FontWeight
    Parameter description

    .PARAMETER FontStyle
    Parameter description

    .PARAMETER FontVariant
    Parameter description

    .PARAMETER FontFamily
    Parameter description

    .PARAMETER BackgroundColor
    Parameter description

    .PARAMETER TextColor
    Parameter description

    .PARAMETER TextDecoration
    Parameter description

    .PARAMETER TextTransform
    Parameter description

    .PARAMETER TextAlign
    Parameter description

    .PARAMETER BorderTopStyle
    Parameter description

    .PARAMETER BorderTopColor
    Parameter description

    .PARAMETER BorderTopWidthSize
    Parameter description

    .PARAMETER BorderBottomStyle
    Parameter description

    .PARAMETER BorderBottomColor
    Parameter description

    .PARAMETER BorderBottomWidthSize
    Parameter description

    .PARAMETER BorderLeftStyle
    Parameter description

    .PARAMETER BorderLeftColor
    Parameter description

    .PARAMETER BorderLeftWidthSize
    Parameter description

    .PARAMETER BorderRightStyle
    Parameter description

    .PARAMETER BorderRightColor
    Parameter description

    .PARAMETER BorderRightWidthSize
    Parameter description

    .EXAMPLE
    $Table = Get-Process | Select-Object -First 3
    New-HTML -ShowHTML -HtmlData {
        New-HTMLTable -DataTable $table -HideButtons {
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor Yellow -TextColor Aquamarine -TextAlign center -Type RowOdd
            New-HTMLTableStyle -BackgroundColor Red -TextColor Aquamarine -Type Button
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor DarkSlateGray -TextColor Aquamarine -TextAlign center -Type RowEven
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor DarkSlateGray -TextColor Aquamarine -TextAlign center -Type Row
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor DarkSlateGray -TextColor Aquamarine -TextAlign center -Type Header
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor Orange -TextColor Aquamarine -TextAlign center -Type Footer
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor Orange -TextColor Aquamarine -TextAlign center -Type RowSelectedEven
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor Green -TextColor Aquamarine -TextAlign center -Type RowSelectedOdd
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor Yellow -TextColor Aquamarine -TextAlign center -Type RowHover
            New-HTMLTableStyle -FontFamily 'Calibri' -BackgroundColor Red -TextColor Aquamarine -TextAlign center -Type RowHoverSelected
            New-HTMLTableStyle -Type Header -BorderLeftStyle dashed -BorderLeftColor Red -BorderLeftWidthSize 1px
            New-HTMLTableStyle -Type Footer -BorderLeftStyle dotted -BorderLeftColor Red -BorderleftWidthSize 1px
            New-HTMLTableStyle -Type Footer -BorderTopStyle none -BorderTopColor Red -BorderTopWidthSize 5px -BorderBottomColor Yellow -BorderBottomStyle solid
            New-HTMLTableStyle -Type Footer -BorderTopStyle none -BorderTopColor Red -BorderTopWidthSize 5px -BorderBottomColor Yellow -BorderBottomStyle solid
            New-HTMLTableStyle -Type Footer -BorderTopStyle none -BorderTopColor Red -BorderTopWidthSize 5px -BorderBottomColor Yellow -BorderBottomStyle none
        } -DisablePaging
    } -FilePath $PSScriptRoot\Example7_TableStyle.html -Online

    .NOTES
    General notes
    #>
    [alias('EmailTableStyle', 'TableStyle', 'New-TableStyle')]
    [cmdletBinding(DefaultParameterSetName = 'Manual')]
    param(
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('Content', 'Table', 'Header', 'Row', 'Footer', 'RowOdd', 'RowEven', 'RowSelected', 'RowSelectedEven', 'RowSelectedOdd', 'RowHover', 'RowHoverSelected', 'Button')][string] $Type = 'Table',
        [Parameter(ParameterSetName = 'Manual')][alias('TextSize')][string] $FontSize,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [Parameter(ParameterSetName = 'Manual')][string] $FontFamily,
        [Parameter(ParameterSetName = 'Manual')][string] $BackgroundColor,
        [Parameter(ParameterSetName = 'Manual')][string] $TextColor,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [Parameter(ParameterSetName = 'Manual')][alias('FontAlign', 'Align')][ValidateSet('left', 'right', 'center', 'justify')][string] $TextAlign,

        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset', 'outset')] $BorderTopStyle,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderTopColor,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderTopWidthSize,

        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset', 'outset')] $BorderBottomStyle,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderBottomColor,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderBottomWidthSize,

        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset', 'outset')] $BorderLeftStyle,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderLeftColor,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderLeftWidthSize,

        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset', 'outset')] $BorderRightStyle,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderRightColor,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderRightWidthSize
    )
    $CssConfiguration = Get-ConfigurationCss -Feature 'DataTables' -Type 'HeaderAlways'
    #$Row = @(
    #    'table.dataTable tbody tr'
    #)
    $RowOdd = @(
        'table.dataTable.stripe tbody tr.odd, table.dataTable.display tbody tr.odd'
        'table.dataTable.display tbody tr.odd>.sorting_1, table.dataTable.order-column.stripe tbody tr.odd>.sorting_1'
        'table.dataTable.display tbody tr.odd>.sorting_2, table.dataTable.order-column.stripe tbody tr.odd>.sorting_2'
        'table.dataTable.display tbody tr.odd>.sorting_3, table.dataTable.order-column.stripe tbody tr.odd>.sorting_3'
    )
    $RowEven = @(
        'table.dataTable.stripe tbody tr.even, table.dataTable.display tbody tr.even'
        'table.dataTable.display tbody tr.even>.sorting_1, table.dataTable.order-column.stripe tbody tr.even>.sorting_1'
        'table.dataTable.display tbody tr.even>.sorting_2, table.dataTable.order-column.stripe tbody tr.even>.sorting_2'
        'table.dataTable.display tbody tr.even>.sorting_3, table.dataTable.order-column.stripe tbody tr.even>.sorting_3'
    )
    #$RowSelected = @(
    #    'table.dataTable tbody tr.selected'
    #)
    $RowSelectedOdd = @(
        'table.dataTable.stripe tbody tr.odd.selected, table.dataTable.display tbody tr.odd.selected'
        'table.dataTable.display tbody tr.odd.selected>.sorting_1, table.dataTable.order-column.stripe tbody tr.odd.selected>.sorting_1'
        'table.dataTable.display tbody tr.odd.selected>.sorting_2, table.dataTable.order-column.stripe tbody tr.odd.selected>.sorting_2'
        'table.dataTable.display tbody tr.odd.selected>.sorting_3, table.dataTable.order-column.stripe tbody tr.odd.selected>.sorting_3'
    )
    $RowSelectedEven = @(
        'table.dataTable.stripe tbody tr.even.selected, table.dataTable.display tbody tr.even.selected'
        'table.dataTable.order-column tbody tr.selected>.sorting_1, table.dataTable.order-column tbody tr.selected>.sorting_2, table.dataTable.order-column tbody tr.selected>.sorting_3, table.dataTable.display tbody tr.selected>.sorting_1, table.dataTable.display tbody tr.selected>.sorting_2, table.dataTable.display tbody tr.selected>.sorting_3'
        'table.dataTable.display tbody tr.even.selected>.sorting_1, table.dataTable.order-column.stripe tbody tr.even.selected>.sorting_1'
        'table.dataTable.display tbody tr.even.selected>.sorting_2, table.dataTable.order-column.stripe tbody tr.even.selected>.sorting_2'
        'table.dataTable.display tbody tr.even.selected>.sorting_3, table.dataTable.order-column.stripe tbody tr.even.selected>.sorting_3'
    )
    $RowHover = @(
        'table.dataTable.hover tbody tr:hover, table.dataTable.display tbody tr:hover'
        'table.dataTable.display tbody tr:hover>.sorting_1, table.dataTable.order-column.hover tbody tr:hover>.sorting_1'
        'table.dataTable.display tbody tr:hover>.sorting_2, table.dataTable.order-column.hover tbody tr:hover>.sorting_2'
        'table.dataTable.display tbody tr:hover>.sorting_3, table.dataTable.order-column.hover tbody tr:hover>.sorting_3'
    )
    $RowHoverSelected = @(
        'table.dataTable.hover tbody tr.odd:hover.selected, table.dataTable.display tbody tr.odd:hover.selected'
        'table.dataTable.hover tbody tr:hover.selected, table.dataTable.display tbody tr:hover.selected'
        'table.dataTable.display tbody tr:hover.selected>.sorting_1, table.dataTable.order-column.hover tbody tr:hover.selected>.sorting_1'
        'table.dataTable.display tbody tr:hover.selected>.sorting_2, table.dataTable.order-column.hover tbody tr:hover.selected>.sorting_2'
        'table.dataTable.display tbody tr:hover.selected>.sorting_3, table.dataTable.order-column.hover tbody tr:hover.selected>.sorting_3'
    )

    $TableStyle = [ordered] @{
        'text-align'          = $TextAlign
        'text-transform'      = $TextTransform
        'color'               = ConvertFrom-Color -Color $TextColor
        'background-color'    = ConvertFrom-Color -Color $BackgroundColor
        'font-size'           = ConvertFrom-Size -TextSize $FontSize
        'font-weight'         = $FontWeight
        'font-style'          = $FontStyle
        'font-variant'        = $FontVariant
        'font-family'         = $FontFamily
        'text-decoration'     = $TextDecoration

        'border-top-width'    = ConvertFrom-Size -TextSize $BorderTopWidth
        'border-top-style'    = $BorderTopStyle
        'border-top-color'    = ConvertFrom-Color -Color $BorderTopColor

        'border-bottom-width' = ConvertFrom-Size -TextSize $BorderBottomWidth
        'border-bottom-style' = $BorderBottomStyle
        'border-bottom-color' = "$(ConvertFrom-Color -Color $BorderBottomColor) !important"

        'border-left-width'   = ConvertFrom-Size -TextSize $BorderLeftWidth
        'border-left-style'   = $BorderLeftStyle
        'border-left-color'   = ConvertFrom-Color -Color $BorderLeftColor

        'border-right-width'  = ConvertFrom-Size -TextSize $BorderRightWidth
        'border-right-style'  = $BorderRightStyle
        'border-right-color'  = ConvertFrom-Color -Color $BorderRightColor
    }

    # this will add configuration for all Tables as it already exists
    # any new elements will be added, any existing elements will be overwritten
    # any existing elements that are not defined will not be touched
    if ($Type -in 'Button') {
        $ButtonStyle = [ordered] @{}
        if ($TextColor) {
            $ButtonStyle['color'] = "$(ConvertFrom-Color -Color $TextColor) !important"
        }
        if ($BackgroundColor) {
            $ButtonStyle['background-color'] = "$(ConvertFrom-Color -Color $BackgroundColor) !important"
        }
        $ButtonCss = @(
            'td::before, td.sorting_1::before'
        )
        foreach ($Name in $ButtonCss) {
            Add-ConfigurationCSS -CSS $CssConfiguration -Name $Name -Inject $ButtonStyle
        }
    }
    if ($Type -in 'Header', 'Table') {
        Add-ConfigurationCSS -CSS $CssConfiguration -Name 'table.dataTable thead th, table.dataTable thead td' -Inject $TableStyle
    }
    if ($Type -in 'Footer', 'Table') {
        Add-ConfigurationCSS -CSS $CssConfiguration -Name 'table.dataTable tfoot th, table.dataTable tfoot td' -Inject $TableStyle
    }
    if ($Type -in 'RowOdd', 'Row', 'Table', 'Content') {
        foreach ($Name in $RowOdd) {
            Add-ConfigurationCSS -CSS $CssConfiguration -Name $Name -Inject $TableStyle
        }
    }
    if ($Type -in 'RowEven', 'Row', 'Table', 'Content') {
        foreach ($Name in $RowEven) {
            Add-ConfigurationCSS -CSS $CssConfiguration -Name $Name -Inject $TableStyle
        }
    }
    # Configures selected rows
    if ($Type -in 'RowSelected', 'RowSelectedOdd') {
        foreach ($Name in $RowSelectedOdd) {
            Add-ConfigurationCSS -CSS $CssConfiguration -Name $Name -Inject $TableStyle
        }
    }
    if ($Type -in 'RowSelected', 'RowSelectedEven') {
        foreach ($Name in $RowSelectedEven) {
            Add-ConfigurationCSS -CSS $CssConfiguration -Name $Name -Inject $TableStyle
        }
    }
    # Configure Rows on Hover
    if ($Type -in 'RowHover') {
        foreach ($Name in $RowHover) {
            Add-ConfigurationCSS -CSS $CssConfiguration -Name $Name -Inject $TableStyle
        }
    }
    # Configure Rows tha are Selected and hovered
    if ($Type -in 'RowHoverSelected') {
        foreach ($Name in $RowHoverSelected) {
            Add-ConfigurationCSS -CSS $CssConfiguration -Name $Name -Inject $TableStyle
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLTableStyle -ParameterName BorderBottomColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTableStyle -ParameterName BorderTopColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTableStyle -ParameterName BorderRightColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTableStyle -ParameterName BorderLeftColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTableStyle -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTableStyle -ParameterName TextColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLTabPanel {
    <#
    .SYNOPSIS
    Flexible and easy to implement Tab Panel with a lot of features, cool animation effects, event support, easy to customize.

    .DESCRIPTION
    Flexible and easy to implement Tab Panel with a lot of features, cool animation effects, event support, easy to customize.

    .PARAMETER Orientation
    Nav menu orientation. Default value is 'horizontal'.

    .PARAMETER DisableJustification
    Disable navigation menu justification

    .PARAMETER DisableBackButtonSupport
    Disable the back button support

    .PARAMETER DisableURLhash
    Disable selection of the tab based on url hash

    .PARAMETER TransitionAnimation
    Effect on navigation, none/fade/slide-horizontal/slide-vertical/slide-swing

    .PARAMETER TransitionSpeed
    Transion animation speed. Default 400

    .PARAMETER AutoProgress
    Enables auto navigation

    .PARAMETER AutoProgressInterval
    Auto navigate Interval (used only if "autoProgress" is enabled). Default 3500

    .PARAMETER DisableAutoProgressStopOnFocus
    Disable stop auto navigation on focus and resume on outfocus (used only if "autoProgress" is enabled)

    .EXAMPLE
    An example

    .NOTES
    Implementation based on: http://techlaboratory.net/jquery-smarttab
    License: MIT

    #>
    [cmdletBinding()]
    param(
        [ScriptBlock] $Tabs,
        [ValidateSet('horizontal', 'vertical')][string] $Orientation,
        [switch] $DisableJustification,
        [switch] $DisableBackButtonSupport,
        [switch] $DisableURLhash,
        [ValidateSet('none', 'fade', 'slide-horizontal', 'slide-vertical', 'slide-swing')][string] $TransitionAnimation, # 'none', // Effect on navigation, none/fade/slide-horizontal/slide-vertical/slide-swing
        [int] $TransitionSpeed,
        [switch] $AutoProgress,
        [int] $AutoProgressInterval,
        [switch] $DisableAutoProgressStopOnFocus
    )
    $Script:HTMLSchema.Features.JQuery = $true
    $Script:HTMLSchema.Features.TabsInline = $true
    $Script:HTMLSchema.Features.RedrawObjects = $true

    $TabID = "TabPanel-$(Get-RandomStringName -Size 8 -LettersOnly)"
    if ($Tabs) {
        $Script:HTMLSchema['TabPanelsList'].Add($TabID)
        $TabContent = & $Tabs
        if ($TabContent) {
            New-HTMLTag -Tag 'div' -Attributes @{ id = $TabID; class = 'flexElement'; style = @{margin = '5px' } } {
                New-HTMLTag -Tag 'ul' -Attributes @{ class = 'nav' } {
                    foreach ($Tab in $TabContent) {
                        New-HTMLTag -Tag 'li' {
                            New-HTMLTag -Tag 'a' -Attributes @{ class = 'nav-link'; href = "#$($Tab.ID)" } {
                                if ($Tab.Icon) {
                                    New-HTMLTag -Tag 'span' -Attributes @{ class = $($Tab.Icon); style = $($Tab.StyleIcon) }
                                    '&nbsp;' # adds an extra space
                                }
                                New-HTMLTag -Tag 'span' -Attributes @{ style = $($Tab.StyleText ) } -Value { $Tab.Name }
                            }
                        }
                    }
                }
                New-HTMLTag -Tag 'div' -Attributes @{ class = 'tab-content flexElement' } {
                    foreach ($Tab in $TabContent) {
                        New-HTMLTag -Tag 'div' -Attributes @{ class = 'tab-pane flexElement'; id = $Tab.ID; role = 'tabpanel'; style = @{ padding = '0px' } } {
                            $Tab.Content
                        }
                    }
                }
            }
            $SmartTab = [ordered] @{
                orientation      = $Orientation
                autoAdjustHeight = $false # this fights with Flex
            }
            if ($TransitionAnimation) {
                $SmartTab['transition'] = [ordered] @{}
                $SmartTab['transition']['animation'] = $TransitionAnimation
                if ($TransitionSpeed) {
                    $SmartTab['transition']['speed'] = $TransitionSpeed
                }
            }
            if ($DisableJustification) {
                $SmartTab['justified'] = $false
            }
            if ($DisableBackButtonSupport) {
                $SmartTab['backButtonSupport'] = $false
            }
            if ($DisableURLhash) {
                $SmartTab['enableURLhash'] = $false
            }
            if ($AutoProgress) {
                $SmartTab['autoProgress'] = [ordered] @{}
                $SmartTab['autoProgress']['enabled'] = $true
                if ($AutoProgressInterval) {
                    $SmartTab['autoProgress']['interval'] = $AutoProgressInterval
                }
                if ($DisableAutoProgressStopOnFocus) {
                    $SmartTab['autoProgress']['stopOnFocus'] = $false
                }
            }
            Remove-EmptyValue -Hashtable $SmartTab
            $SmartTabConfiguration = $SmartTab | ConvertTo-Json -Depth 2

            New-HTMLTag -Tag 'script' {
                @"
            `$(document).ready(function(){
                // SmartTab initialize
                `$('#$TabID').smartTab($SmartTabConfiguration);
                `$("#$TabID").on("showTab", function(e, anchorObject, tabIndex) {
                    //alert("You are on tab "+tabIndex+" now");
                    if (anchorObject[0].hash) {
                        var id = anchorObject[0].hash.replace('#', '');
                        findObjectsToRedraw(id);
                    };
                });
            });
"@
            }
        }
        $null = $Script:HTMLSchema['TabPanelsList'].Remove($TabID)
    }
}
function New-HTMLTabStyle {
    [alias('TabOptions', 'New-TabOption', 'New-HTMLTabOptions', 'TabOption', 'New-HTMLTabOption', 'TabStyle')]
    [CmdletBinding(DefaultParameterSetName = 'Manual')]
    param(
        [Parameter(ParameterSetName = 'Manual')][alias('TextSize')][string] $FontSize,
        [Parameter(ParameterSetName = 'Manual')][alias('TextSizeActive')][string] $FontSizeActive,
        [Parameter(ParameterSetName = 'Manual')][string] $TextColor,
        [Parameter(ParameterSetName = 'Manual')][string] $TextColorActive,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeightActive,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'italic', 'oblique')][string] $FontStyleActive,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('normal', 'small-caps')][string] $FontVariantActive,
        [Parameter(ParameterSetName = 'Manual')][string] $FontFamily,
        [Parameter(ParameterSetName = 'Manual')][string] $FontFamilyActive,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecorationActive,
        [Parameter(ParameterSetName = 'Manual')][string] $BackgroundColor,
        [Parameter(ParameterSetName = 'Manual')][alias('SelectorColor')][string] $BackgroundColorActive,
        [Parameter(ParameterSetName = 'Manual')][alias('SelectorColorTarget')][string] $BackgroundColorActiveTarget,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('0px', '5px', '10px', '15px', '20px', '25px')][string] $BorderRadius,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderBackgroundColor,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransformActive,

        [Parameter(ParameterSetName = 'Manual')][switch] $SlimTabs,
        [Parameter(ParameterSetName = 'Manual')][switch] $Transition,
        [Parameter(ParameterSetName = 'Manual')][switch] $LinearGradient,
        [Parameter(ParameterSetName = 'Manual')][switch] $RemoveShadow,

        [Parameter(ParameterSetName = 'Manual')][ValidateSet('medium', 'thin', 'thick')][string] $BorderBottomWidth,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset', 'outset')][string] $BorderBottomStyle,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderBottomColor,

        [Parameter(ParameterSetName = 'Manual')][ValidateSet('medium', 'thin', 'thick')][string] $BorderBottomWidthActive,
        [Parameter(ParameterSetName = 'Manual')][ValidateSet('none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset', 'outset')][string] $BorderBottomStyleActive,
        [Parameter(ParameterSetName = 'Manual')][string] $BorderBottomColorActive,

        [Parameter(ParameterSetName = 'Styled')][string] $Style,

        [Parameter(ParameterSetName = 'Styled')]
        [Parameter(ParameterSetName = 'Manual')]
        [alias('AlignTabs')][ValidateSet('left', 'right', 'center', 'justify')][string] $Align,

        [string][ValidateSet('wrap', 'nowrap', 'wrap-reverse')] $Wrap,
        [string][ValidateSet('row', 'row-reverse', 'column', 'column-reverse')] $Direction,
        [string][ValidateSet('flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'stretch')] $AlignContent,
        [string][ValidateSet('stretch', 'flex-start', 'flex-end', 'center', 'baseline')] $AlignItems,
        [string][ValidateSet('flex-start', 'flex-end', 'center')] $JustifyContent,
        [int] $RowElements

    )
    if (-not $Script:HTMLSchema) {
        Write-Warning 'New-HTMLTabStyle - Creation of HTML aborted. Most likely New-HTML is missing.'
        Exit
    }
    if ($BackgroundColorActive -and $BackgroundColorActiveTarget -and (-not $LinearGradient)) {
        Write-Warning "New-HTMLTabStyle - Using BackgroundColorActiveTarget without LinearGradient switch doesn't apply any changes."
    }

    # $Script:CurrentConfiguration.Features.Tabbis.HeaderAlways.CssInline
    # lets get original CSS configuration
    $TabbisCss = Get-ConfigurationCss -Feature 'Tabbis' -Type 'HeaderAlways'

    # We need to set defaults if it's not set
    if (-not $BackgroundColorActive) {
        $BackgroundColorActive = "DodgerBlue"
    }
    if (-not $BackgroundColorActiveTarget) {
        $BackgroundColorActiveTarget = "MediumSlateBlue"
    }

    # Converting colors to their HEX equivalent
    $BackGroundColorActiveSelector = ConvertFrom-Color -Color $BackgroundColorActive
    $BackGroundColorActiveSelectorTarget = ConvertFrom-Color -Color $BackgroundColorActiveTarget

    # This enables slimTabs
    if ($SlimTabs.IsPresent) {
        $CssSlimTabs = @{
            'display' = 'inline-block'
        }
        # Lets inject additional configuration into CSS
        Add-ConfigurationCSS -CSS $TabbisCss -Name '.tabsSlimmer' -Inject $CssSlimTabs
    }

    # This controls All Tabs
    $CssTabsWrapper = [ordered] @{
        'text-align'       = $Align
        'text-transform'   = $TextTransform
        'font-size'        = ConvertFrom-Size -TextSize $FontSize
        'color'            = ConvertFrom-Color -Color $TextColor
        'background-color' = ConvertFrom-Color -Color $BackgroundColor
        'font-weight'      = $FontWeight
        'font-style'       = $FontStyle
        'font-variant'     = $FontVariant
        'font-family'      = $FontFamily
        'text-decoration'  = $TextDecoration
    }

    # this will add configuration for tabsWrapper as it already exists
    # any new elements will be added, any existing elements will be overwritten
    # any existing elements that are not defined will not be touched
    Add-ConfigurationCSS -CSS $TabbisCss -Name '.tabsWrapper' -Inject $CssTabsWrapper

    # This controls All Tabs in [Data-Tabs] class
    $CssTabsData = @{
        'border-radius'    = $BorderRadius
        'background-color' = ConvertFrom-Color -Color $BorderBackgroundColor
        'justify-content'  = $JustifyContent
        'flex-wrap'        = $Wrap
        'flex-direction'   = $Direction
        'align-content'    = $AlignContent
        'align-items'      = $AlignItems
    }
    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs]' -Inject $CssTabsData


    # This controls Active tab
    $CssTabsActive = [ordered] @{
        'background'     = $BackGroundColorActiveSelector
        'color'          = '#fff'
        'border-radius'  = $BorderRadius
        'text-transform' = $TextTransformActive
    }

    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject $CssTabsActive

    <#
    $CssTabsBorderStyle = @{
        'border-radius'    = "$BorderRadius";
        'background-color' = ConvertFrom-Color -Color $BorderBackgroundColor
    }
    Add-ConfigurationCSS -CSS $TabbisCss -Name 'tabsBorderStyle' -Inject $CssTabsBorderStyle
    #>

    #$CssBorderStyleRadius = @{
    #    'border-radius' = "$BorderRadius";
    #}
    #Add-ConfigurationCSS -CSS $TabbisCss -Name 'tabsBorderStyleRadius' -Inject $CssBorderStyleRadius

    # This adds Gradient
    if ($LinearGradient.IsPresent) {
        $CssTabbisGradient = [ordered] @{
            'background'   = "-moz-linear-gradient(45deg, $BackGroundColorActiveSelector 0%, $BackGroundColorActiveSelectorTarget 100%)"
            'background '  = "-webkit-linear-gradient(45deg, $BackGroundColorActiveSelector 0%, $BackGroundColorActiveSelectorTarget 100%)"
            'background  ' = "linear-gradient(45deg, $BackGroundColorActiveSelector 0%, $BackGroundColorActiveSelectorTarget 100%)"
            'filter'       = "progid:DXImageTransform.Microsoft.gradient(startColorstr='$BackGroundColorActiveSelector', endColorstr='$BackGroundColorActiveSelectorTarget', GradientType=1)"
        }
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject $CssTabbisGradient
    }

    # This adds Transition
    if ($Transition.IsPresent) {
        $CssTabbisTransition = [ordered] @{
            'transition-duration'        = '0.6s'
            'transition-timing-function' = 'cubic-bezier(0.68, -0.55, 0.265, 1.55)'
        }
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject $CssTabbisTransition
    }

    if ($BackgroundColorActive -eq 'none') {
        Remove-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Property 'background'
    }
    if ($RemoveShadow.IsPresent) {
        Remove-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs]' -Property 'box-shadow'
    }
    if ($PSBoundParameters.ContainsKey('TextSizeActive')) {
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'font-size' = ConvertFrom-Size -TextSize $FontSizeActive }
    }
    if ($PSBoundParameters.ContainsKey('TextColorActive')) {
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'color' = ConvertFrom-Color -Color $TextColorActive }
    }



    #Add-ConfigurationCSS -CSS $TabbisCss -Name '.tabsWrapper' -Inject @{ 'font-weight' = $FontWeight }
    #Add-ConfigurationCSS -CSS $TabbisCss -Name '.tabsWrapper' -Inject @{ 'font-style' = $FontStyle }
    #Add-ConfigurationCSS -CSS $TabbisCss -Name '.tabsWrapper' -Inject @{ 'font-variant' = $FontVariant }
    #Add-ConfigurationCSS -CSS $TabbisCss -Name '.tabsWrapper' -Inject @{ 'font-family' = $FontFamily }
    #Add-ConfigurationCSS -CSS $TabbisCss -Name '.tabsWrapper' -Inject @{ 'text-decoration' = $TextDecoration }

    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'font-weight' = $FontWeightActive }
    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'font-style' = $FontStyleActive }
    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'font-variant' = $FontVariantActive }
    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'font-family' = $FontFamilyActive }
    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'text-decoration' = $TextDecorationActive }

    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'border-bottom-style' = $BorderBottomStyleActive }
    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'border-bottom-width' = $BorderBottomWidthActive }
    Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs] .active' -Inject @{ 'border-bottom-color' = ConvertFrom-Color -Color $BorderBottomColorActive }

    if ($BorderBottomStyle) {
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs]>*' -Inject @{ 'border-bottom-style' = $BorderBottomStyle }
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs]>*' -Inject @{ 'border-bottom-width' = $BorderBottomWidth }
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs]>*' -Inject @{ 'border-bottom-color' = ConvertFrom-Color -Color $BorderBottomColor }
    } elseif ($BorderBottomColor -or $BorderBottomWidth) {
        Write-Warning "New-HTMLTabStyle - You can't use BorderBottomColor or BorderBottomWidth without BorderBottomStyle."
    }

    if ($RowElements) {
        Add-ConfigurationCSS -CSS $TabbisCss -Name '[data-tabs]>*' -Inject @{ 'flex-basis' = "calc(80%/$RowElements)" }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName TextColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName TextColorActive -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName BackgroundColorActive -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName BackgroundColorActiveTarget -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName BorderBackgroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName BorderBottomColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTabStyle -ParameterName BorderBottomColorActive -ScriptBlock $Script:ScriptBlockColors
function New-HTMLTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][alias('Content')][ScriptBlock] $Value,
        [Parameter(Mandatory = $true, Position = 1)][string] $Tag,
        [System.Collections.IDictionary] $Attributes,
        [switch] $SelfClosing,
        [switch] $NoClosing,
        [switch] $NewLine
    )
    $HTMLTag = [Ordered] @{
        Tag         = $Tag
        Value       = if ($null -eq $Value) { '' } else { Invoke-Command -ScriptBlock $Value }
        Attributes  = $Attributes
        SelfClosing = $SelfClosing
        NoClosing   = $NoClosing
    }
    Set-Tag -HtmlObject $HTMLTag -NewLine:$NewLine
}
function New-HTMLText {
    [alias('HTMLText', 'Text', 'EmailText')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $TextBlock,
        [string[]] $Text,
        [string[]] $Color = @(),
        [string[]] $BackGroundColor = @(),
        [alias('Size')][object[]] $FontSize = @(),
        [string[]] $LineHeight = @(),
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string[]] $FontWeight = @(),
        [ValidateSet('normal', 'italic', 'oblique')][string[]] $FontStyle = @(),
        [ValidateSet('normal', 'small-caps')][string[]] $FontVariant = @(),
        [string[]] $FontFamily = @(),
        [ValidateSet('left', 'center', 'right', 'justify')][string[]] $Alignment = @(),
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string[]] $TextDecoration = @(),
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string[]] $TextTransform = @(),
        [ValidateSet('rtl')][string[]] $Direction = @(),
        [switch] $LineBreak,
        [switch] $SkipParagraph #,
        #[string] $Margin = '5px'
    )
    $Script:HTMLSchema.Features.DefaultText = $true

    if ($TextBlock) {
        $Text = (Invoke-Command -ScriptBlock $TextBlock)
    }

    $DefaultColor = $Color[0]
    $DefaultFontSize = $FontSize[0]
    $DefaultFontWeight = if ($null -eq $FontWeight[0] ) { '' } else { $FontWeight[0] }
    $DefaultBackGroundColor = $BackGroundColor[0]
    $DefaultFontFamily = if ($null -eq $FontFamily[0] ) { '' } else { $FontFamily[0] }
    $DefaultFontStyle = if ($null -eq $FontStyle[0] ) { '' } else { $FontStyle[0] }
    $DefaultTextDecoration = if ($null -eq $TextDecoration[0]) { '' } else { $TextDecoration[0] }
    $DefaultTextTransform = if ($null -eq $TextTransform[0]) { '' } else { $TextTransform[0] }
    $DefaultFontVariant = if ($null -eq $FontVariant[0]) { '' } else { $FontVariant }
    $DefaultDirection = if ($null -eq $Direction[0]) { '' } else { $Direction[0] }
    $DefaultAlignment = if ($null -eq $Alignment[0]) { '' } else { $Alignment[0] }
    $DefaultLineHeight = if ($null -eq $LineHeight[0]) { '' } else { $LineHeight[0] }

    $Output = for ($i = 0; $i -lt $Text.Count; $i++) {
        if ($null -eq $FontWeight[$i]) {
            $ParamFontWeight = $DefaultFontWeight
        } else {
            $ParamFontWeight = $FontWeight[$i]
        }
        if ($null -eq $FontSize[$i]) {
            $ParamFontSize = $DefaultFontSize
        } else {
            $ParamFontSize = $FontSize[$i]
        }
        if ($null -eq $Color[$i]) {
            $ParamColor = $DefaultColor
        } else {
            $ParamColor = $Color[$i]
        }
        if ($null -eq $BackGroundColor[$i]) {
            $ParamBackGroundColor = $DefaultBackGroundColor
        } else {
            $ParamBackGroundColor = $BackGroundColor[$i]
        }
        if ($null -eq $FontFamily[$i]) {
            $ParamFontFamily = $DefaultFontFamily
        } else {
            $ParamFontFamily = $FontFamily[$i]
        }
        if ($null -eq $FontStyle[$i]) {
            $ParamFontStyle = $DefaultFontStyle
        } else {
            $ParamFontStyle = $FontStyle[$i]
        }

        if ($null -eq $TextDecoration[$i]) {
            $ParamTextDecoration = $DefaultTextDecoration
        } else {
            $ParamTextDecoration = $TextDecoration[$i]
        }

        if ($null -eq $TextTransform[$i]) {
            $ParamTextTransform = $DefaultTextTransform
        } else {
            $ParamTextTransform = $TextTransform[$i]
        }

        if ($null -eq $FontVariant[$i]) {
            $ParamFontVariant = $DefaultFontVariant
        } else {
            $ParamFontVariant = $FontVariant[$i]
        }
        if ($null -eq $Direction[$i]) {
            $ParamDirection = $DefaultDirection
        } else {
            $ParamDirection = $Direction[$i]
        }
        if ($null -eq $Alignment[$i]) {
            $ParamAlignment = $DefaultAlignment
        } else {
            $ParamAlignment = $Alignment[$i]
        }
        if ($null -eq $LineHeight[$i]) {
            $ParamLineHeight = $DefaultLineHeight
        } else {
            $ParamLineHeight = $LineHeight[$i]
        }

        $newSpanTextSplat = @{ }
        $newSpanTextSplat.Color = $ParamColor
        $newSpanTextSplat.BackGroundColor = $ParamBackGroundColor

        $newSpanTextSplat.FontSize = $ParamFontSize
        if ($ParamFontWeight -ne '') {
            $newSpanTextSplat.FontWeight = $ParamFontWeight
        }
        $newSpanTextSplat.FontFamily = $ParamFontFamily
        if ($ParamFontStyle -ne '') {
            $newSpanTextSplat.FontStyle = $ParamFontStyle
        }
        if ($ParamFontVariant -ne '') {
            $newSpanTextSplat.FontVariant = $ParamFontVariant
        }
        if ($ParamTextDecoration -ne '') {
            $newSpanTextSplat.TextDecoration = $ParamTextDecoration
        }
        if ($ParamTextTransform -ne '') {
            $newSpanTextSplat.TextTransform = $ParamTextTransform
        }
        if ($ParamDirection -ne '') {
            $newSpanTextSplat.Direction = $ParamDirection
        }
        if ($ParamAlignment -ne '') {
            $newSpanTextSplat.Alignment = $ParamAlignment
        }
        if ($ParamLineHeight -ne '') {
            $newSpanTextSplat.LineHeight = $ParamLineHeight
        }

        $newSpanTextSplat.LineBreak = $LineBreak
        New-HTMLSpanStyle @newSpanTextSplat {
            $FindMe = [regex]::Matches($Text[$i], "\[[^\]]+\]\(\S+\)")
            if ($FindMe) {
                foreach ($find in $FindMe) {
                    $LinkName = ([regex]::Match($Find.value, "[^\[]+(?=\])")).Value
                    $LinkURL = ([regex]::Match($Find.value, "(?<=\().+(?=\))")).Value
                    $Link = New-HTMLAnchor -HrefLink $LinkURL -Text $LinkName
                    $Text[$i] = $Text[$i].Replace($find.value, $Link)
                }
                $Text[$i]
            } else {
                # Default
                $Text[$i]
            }
            # Replaces code above -> JustinWGrote made it -> complains go to him
            #$markdownRegex = '\[(?<title>[^\]]+)\]\((?<uri>https?.+?)\)[\s\r\n$]'
            #$Text[$i] -replace $markdownRegex, '<a href="$2">$1</a>'

            <#
            if ($Text[$i] -match "\[[^\]]+\]\([^)]+\)") {
                # Covers markdown LINK  "[somestring](https://evotec.xyz)"

                $RegexBrackets1 = [regex] '\[[^\]]+\]\([^)]+\)'

                $RegexBrackets1 = [regex] "\[([^\[]*)\]" # catch 'sometstring'
                $RegexBrackets2 = [regex] "\(([^\[]*)\)" # catch link
                $RegexBrackets3 = [regex] "\[([^\[]*)\)" # catch both somestring and link
                $Text1 = $RegexBrackets1.match($Text[$i]).Groups[1].value
                #$Text2 = $RegexBrackets2.match($Text[$i]).Groups[1].value
                $Text3 = $RegexBrackets3.match($Text[$i]).Groups[0].value
                if ($Text1 -ne '' -and $Text2 -ne '') {
                    $Link = New-HTMLAnchor -HrefLink $Text2 -Text $Text1
                    $Text[$i].Replace($Text3, $Link)
                }
            } else {
                # Default
                $Text[$i]
                # if ($NewLine[$i]) {
                #    '<br>'
                #}
            }
            #>
        }
    }

    if ($SkipParagraph) {
        $Output -join ''
    } else {
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'defaultText' } {
            #    New-HTMLTag -Tag 'div' -Attributes @{ style = @{ 'margin' = ConvertFrom-Size -Size $Margin } } {
            $Output
        }
    }
    if ($LineBreak) {
        New-HTMLTag -Tag 'br' -SelfClosing
    }
}

Register-ArgumentCompleter -CommandName New-HTMLText -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLText -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLTextBox {
    <#
    .SYNOPSIS
    Adds text to HTML where each line in TextBlock is treated as next line (adds BR to each line)

    .DESCRIPTION
    Adds text to HTML where each line in TextBlock is treated as next line (adds BR to each line).
    Automatic line breaks are main feature that differentiate New-HTMLTextBox from New-HTMLText
    where TextBlock is treated as single line of text unless LineBreak switch is used.

    .PARAMETER TextBlock
    ScriptBlock of one or more strings

    .PARAMETER Color
    Color of Text to set. Choose one or more colors from up to 800 defined colors. Alternatively provide your own Hex value

    .PARAMETER BackGroundColor
    Color of Background for a Text to set. Choose one or more colors from up to 800 defined colors. Alternatively provide your own Hex value

    .PARAMETER FontSize
    Choose FontSize. You can provide just int value which will assume pixels or string value with any other size value.

    .PARAMETER FontWeight
    Parameter description

    .PARAMETER FontStyle
    Parameter description

    .PARAMETER TextDecoration
    Parameter description

    .PARAMETER FontVariant
    Parameter description

    .PARAMETER FontFamily
    Parameter description

    .PARAMETER Alignment
    Chhoose Alignment

    .PARAMETER TextTransform
    Parameter description

    .PARAMETER Direction
    Parameter description

    .PARAMETER LineBreak
    Parameter description

    .EXAMPLE
    New-HTMLTextBox {
        "Hello $UserNotify,"
        ""
        "Your password is due to expire in $PasswordExpiryDays days."
        ""
        'To change your password: '
        '- press CTRL+ALT+DEL -> Change a password...'
        ''
        'If you have forgotten your password and need to reset it, you can do this by clicking here. '
        "In case of problems please contact the HelpDesk by visiting [Evotec Website](https://evotec.xyz) or by sending an email to Help Desk."
        ''
        'Alternatively you can always call Help Desk at +48 22 00 00 00'
        ''
        'Kind regards,'
        'Evotec IT'
    }

    .NOTES
    General notes
    #>
    [alias('EmailTextBox')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $TextBlock,
        [string[]] $Color = @(),
        [string[]] $BackGroundColor = @(),
        [alias('Size')][int[]] $FontSize = @(),
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string[]] $FontWeight = @(),
        [ValidateSet('normal', 'italic', 'oblique')][string[]] $FontStyle = @(),
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string[]] $TextDecoration = @(),
        [ValidateSet('normal', 'small-caps')][string[]] $FontVariant = @(),
        [string[]] $FontFamily = @(),
        [ValidateSet('left', 'center', 'right', 'justify')][string[]] $Alignment = @(),
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string[]] $TextTransform = @(),
        [ValidateSet('rtl')][string[]] $Direction = @(),
        [switch] $LineBreak
    )
    if ($TextBlock) {
        $Text = (Invoke-Command -ScriptBlock $TextBlock)
        if ($Text.Count) {
            $LineBreak = $true
        }
    }
    $Span = foreach ($T in $Text) {
        $newHTMLTextSplat = @{
            Alignment       = $Alignment
            FontSize        = $FontSize
            TextTransform   = $TextTransform
            Text            = $T
            Color           = $Color
            FontFamily      = $FontFamily
            Direction       = $Direction
            FontStyle       = $FontStyle
            TextDecoration  = $TextDecoration
            BackGroundColor = $BackGroundColor
            FontVariant     = $FontVariant
            FontWeight      = $FontWeight
            LineBreak       = $LineBreak
        }
        New-HTMLText @newHTMLTextSplat -SkipParagraph
    }
    New-HTMLTag -Tag 'div' -Attributes @{ class = 'defaultText' } {
        $Span
    }
}
Register-ArgumentCompleter -CommandName New-HTMLTextBox -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLTextBox -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-HTMLTimeline {
    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][alias('TimeLineItems')][ScriptBlock] $Content
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.TimeLine = $true
    New-HTMLTag -Tag 'div' -Attributes @{ class = 'timelineSimpleContainer' } {
        if ($null -eq $Value) { '' } else { Invoke-Command -ScriptBlock $Content }
    }
}
function New-HTMLTimelineItem {
    [CmdletBinding()]
    param(
        [DateTime] $Date = (Get-Date),
        [string] $HeadingText,
        [string] $Text,
        [string] $Color
    )
    $Attributes = @{
        class     = 'timelineSimple-item'
        "date-is" = $Date
    }

    if ($null -ne $Color) {
        $RGBcolor = ConvertFrom-Color -Color $Color
        $Style = @{
            color = $RGBcolor
        }
    } else {
        $Style = @{}
    }
    # $Script:HTMLSchema.Features.TimeLine = $true
    New-HTMLTag -Tag 'div' -Attributes $Attributes -Value {
        New-HTMLTag -Tag 'h1' -Attributes @{ class = 'timelineSimple'; style = $style } {
            $HeadingText
        }
        New-HTMLTag -Tag 'p' -Attributes @{ class = 'timelineSimple' } {
            $Text -Replace [Environment]::NewLine, '<br>' -replace '\n', '<br>'
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLTimelineItem -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
function New-HTMLToast {
    [CmdletBinding()]
    param(
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $TextHeader,

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $TextHeaderColor,

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $Text,

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $TextColor,

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][int] $IconSize = 30,

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $IconColor = "Blue",

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $BarColorLeft = "Blue",

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $BarColorRight,

        # ICON BRANDS
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeBrands.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeBrands.Keys))
            }
        )]
        [parameter(ParameterSetName = "FontAwesomeBrands")][string] $IconBrands,

        # ICON REGULAR
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeRegular.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeRegular.Keys))
            }
        )]
        [parameter(ParameterSetName = "FontAwesomeRegular")][string] $IconRegular,

        # ICON SOLID
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeSolid.Keys)
            }
        )]
        [ValidateScript(
            {
                $_ -in (($Global:HTMLIcons.FontAwesomeSolid.Keys))
            }
        )]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $IconSolid
    )

    [string] $Icon = ''
    if ($IconBrands) {
        $Icon = "fab fa-$IconBrands" # fa-$($FontSize)x"
    } elseif ($IconRegular) {
        $Icon = "far fa-$IconRegular" # fa-$($FontSize)x"
    } elseif ($IconSolid) {
        $Icon = "fas fa-$IconSolid" # fa-$($FontSize)x"
    }
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.Toasts = $true
    $Script:HTMLSchema.Features.FontsAwesome = $true

    [string] $DivClass = "toast"

    $StyleText = @{ }
    if ($TextColor) {
        $StyleText.'color' = ConvertFrom-Color -Color $TextColor
    }

    $StyleTextHeader = @{ }
    if ($TextHeaderColor) {
        $StyleTextHeader.'color' = ConvertFrom-Color -Color $TextHeaderColor
    }

    $StyleIcon = @{ }
    if ($IconSize -ne 0) {
        $StyleIcon.'font-size' = "$($IconSize)px"
    }

    if ($IconColor) {
        $StyleIcon.'color' = ConvertFrom-Color -Color $IconColor
    }

    $StyleBarLeft = @{ }
    if ($BarColorLeft) {
        $StyleBarLeft.'background-color' = ConvertFrom-Color -Color $BarColorLeft
    }

    $StyleBarRight = @{ }
    if ($BarColorRight) {
        $StyleBarRight.'background-color' = ConvertFrom-Color -Color $BarColorRight
    }

    New-HTMLTag -Tag 'div' -Attributes @{ class = $DivClass } {
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'toastBorderLeft'; style = $StyleBarLeft }
        New-HTMLTag -Tag 'div' -Attributes @{ class = "toastIcon $Icon"; style = $StyleIcon }
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'toastContent' } {
            New-HTMLTag -Tag 'p' -Attributes @{ class = 'toastTextHeader'; style = $StyleTextHeader } {
                $TextHeader
            }
            New-HTMLTag -Tag 'p' -Attributes @{ class = 'toastText'; style = $StyleText } {
                $Text
            }
        }
        New-HTMLTag -Tag 'div' -Attributes @{ class = 'toastBorderRight'; style = $StyleBarRight }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLToast -ParameterName TextHeaderColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLToast -ParameterName TextColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLToast -ParameterName IconColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLToast -ParameterName BarColorLeft -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLToast -ParameterName BarColorRight -ScriptBlock $Script:ScriptBlockColors
function New-HTMLTree {
    [CmdletBinding()]
    param(
        [scriptblock] $Nodes,
        [ValidateSet('none', 'checkbox', 'radio')][string] $Checkbox = 'none',
        [ValidateSet('none', '1', '2', '3')] $SelectMode = '2'
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.Jquery = $true
    $Script:HTMLSchema.Features.FancyTree = $true

    [string] $ID = "FancyTree" + (Get-RandomStringName -Size 8)

    $FancyTree = @{

    }

    $FancyTree['extensions'] = @("edit", "filter")

    if ($Checkbox -eq 'none') {
        #$FancyTree['checkbox'] = $Checkbox # true/false/radio
    } elseif ($Checkbox -eq 'radio') {
        $FancyTree['checkbox'] = 'radio'
    } else {
        $FancyTree['checkbox'] = $true
    }
    <#
    Fancytree supports three modes:

    selectMode: 1: single selection, Only one node is selected at any time.
    selectMode: 2: multiple selection (default), Every node may be selected independently.
    selectMode: 3: hierarchical selection, (De)selecting a node will propagate to all descendants. Mixed states will be displayed as partially selected using a tri-state checkbox.
    #>
    if ($SelectMode -ne 'none') {
        $FancyTree['selectMode'] = $SelectMode # 3, // 1, 2, 3
    }

    [Array] $Source = & $Nodes
    if ($Source.Count -gt 0) {
        $FancyTree['source'] = $Source
    }
    Remove-EmptyValue -Hashtable $FancyTree -Rerun 1 -Recursive

    # Build HTML
    $Div = New-HTMLTag -Tag 'div' -Attributes @{ id = $ID; class = 'fancyTree' }

    $Script = New-HTMLTag -Tag 'script' -Value {
        $DivID = -join ('#', $ID)
        # Convert Dictionary to JSON and return chart within SCRIPT tag
        # Make sure to return with additional empty string
        $FancyTreeJSON = $FancyTree | ConvertTo-Json -Depth 100 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }

        '$(function(){  // on page load'
        "`$(`"$DivID`").fancytree("
        $FancyTreeJSON
        ');'
        '});'
    } -NewLine

    # Return Data
    $Div
    $Script
}
function New-HTMLWizard {
    <#
    .SYNOPSIS
    Provides a simple way to build wizard

    .DESCRIPTION
    Provides a simple way to build wizard

    .PARAMETER Theme
    Choose a theme to display wizard in

    .PARAMETER DisableCycleSteps
    Disables the navigation cycle through

    .PARAMETER ToolbarPosition
    Position of the toolbar (none, top, bottom, both)

    .PARAMETER ToolbarButtonPosition
    Button alignment of the toolbar (left, right, center)

    .PARAMETER HideNextButton
    Hide next button

    .PARAMETER HidePreviousButton
    Hide previous button

    .PARAMETER DiableAnchorClickable
    Disable anchor navigation

    .PARAMETER EnableAllAnchors
    Activates all anchors clickable all times

    .PARAMETER DisableMarkDoneStep
    Disable done state on navigation

    .PARAMETER DisableMarkAllPreviousStepsAsDone
    Disable when a step selected by url hash, all previous steps are marked done

    .PARAMETER RemoveDoneStepOnNavigateBack
    While navigate back done step after active step will be cleared

    .PARAMETER DisableAnchorOnDoneStep
    Disable the done steps navigation

    .PARAMETER DisableJustification
    Disable navigation menu justification

    .PARAMETER DisableBackButtonSupport
    Disable the back button support

    .PARAMETER DisableURLhash
    Disable selection of the tab based on url hash

    .PARAMETER TransitionAnimation
    Effect on navigation, none/fade/slide-horizontal/slide-vertical/slide-swing

    .PARAMETER TransitionSpeed
    Transion animation speed. Default 400

    .EXAMPLE
    An example

    .NOTES
    Implementation based on: http://techlaboratory.net/jquery-smartwizard
    License: MIT
    #>
    [cmdletBinding()]
    param(
        [scriptblock] $WizardSteps,
        [ValidateSet('default', 'arrows', 'dots', 'progress')][string] $Theme,
        [switch] $DisableCycleSteps,

        [ValidateSet('bottom', 'top', 'both', 'none')][string] $ToolbarPosition,
        [ValidateSet('right', 'left', 'center')][string] $ToolbarButtonPosition,
        [switch] $HideNextButton,
        [switch] $HidePreviousButton,

        [switch] $DiableAnchorClickable, #: true, // Enable/Disable anchor navigation
        [switch] $EnableAllAnchors, #: false, // Activates all anchors clickable all times
        [switch] $DisableMarkDoneStep, #: true, // Add done state on navigation
        [switch] $DisableMarkAllPreviousStepsAsDone, #: true, // When a step selected by url hash, all previous steps are marked done
        [switch] $RemoveDoneStepOnNavigateBack, #: false, // While navigate back done step after active step will be cleared
        [switch] $DisableAnchorOnDoneStep, #: true // Enable/Disable the done steps navigation

        [switch] $DisableJustification,
        [switch] $DisableBackButtonSupport,
        [switch] $DisableURLhash,
        [ValidateSet('none', 'fade', 'slide-horizontal', 'slide-vertical', 'slide-swing')][string] $TransitionAnimation, # 'none', // Effect on navigation, none/fade/slide-horizontal/slide-vertical/slide-swing
        [int] $TransitionSpeed
    )
    $Script:HTMLSchema.Features.MainFlex = $true
    $Script:HTMLSchema.Features.JQuery = $true
    $Script:HTMLSchema.Features.Wizard = $true
    $Script:HTMLSchema.Features.RedrawObjects = $true

    $WizardID = "TabPanel-$(Get-RandomStringName -Size 8 -LettersOnly)"
    if ($WizardSteps) {
        $Script:HTMLSchema['WizardList'].Add($WizardID)
        $WizardContent = & $WizardSteps
        if ($WizardContent) {
            New-HTMLTag -Tag 'div' -Attributes @{ id = $WizardID; class = 'flexElement defaultWizard' } {
                New-HTMLTag -Tag 'ul' -Attributes @{ class = 'nav' } {
                    foreach ($Step in $WizardContent) {
                        New-HTMLTag -Tag 'li' {
                            New-HTMLTag -Tag 'a' -Attributes @{ class = 'nav-link'; href = "#$($Step.ID)" } {
                                if ($Tab.Icon) {
                                    New-HTMLTag -Tag 'span' -Attributes @{ class = $($Step.Icon); style = $($Step.StyleIcon) }
                                    '&nbsp;' # adds an extra space
                                }
                                New-HTMLTag -Tag 'span' -Attributes @{ style = $($Step.StyleText ) } -Value { $Step.Name }
                            }
                        }
                    }
                }
                New-HTMLTag -Tag 'div' -Attributes @{ class = 'tab-content flexElement' } {
                    foreach ($Step in $WizardContent) {
                        New-HTMLTag -Tag 'div' -Attributes @{ class = 'tab-pane flexElement'; id = $Step.ID; role = 'tabpanel'; style = @{ padding = '0px' } } {
                            $Step.Content
                        }
                    }
                }
                $SmartWizard = [ordered] @{
                    orientation      = $Orientation
                    autoAdjustHeight = $false # this fights with Flex
                }
                if ($Theme) {
                    $SmartWizard['theme'] = $Theme
                }
                if ($TransitionAnimation) {
                    $SmartWizard['transition'] = [ordered] @{}
                    $SmartWizard['transition']['animation'] = $TransitionAnimation
                    if ($TransitionSpeed) {
                        $SmartWizard['transition']['speed'] = $TransitionSpeed
                    }
                }
                if ($ToolbarPosition -or $ToolbarButtonPosition -or $HideNextButton -or $HidePreviousButton) {
                    $SmartWizard['toolbarSettings'] = [ordered]@{}
                    if ($ToolbarPosition) {
                        $SmartWizard['toolbarSettings']['toolbarPosition'] = $ToolbarPosition
                    }
                    if ($ToolbarButtonPosition) {
                        $SmartWizard['toolbarSettings']['toolbarButtonPosition'] = $ToolbarButtonPosition
                    }
                    if ($HideNextButton) {
                        $SmartWizard['toolbarSettings']['showNextButton'] = $false
                    }
                    if ($HidePreviousButton) {
                        $SmartWizard['toolbarSettings']['showPreviousButton'] = $false
                    }
                }

                if ($DiableAnchorClickable -or $EnableAllAnchors -or $DisableMarkDoneStep -or $DisableMarkAllPreviousStepsAsDone -or $RemoveDoneStepOnNavigateBack -or $DisableAnchorOnDoneStep) {
                    $SmartWizard['anchorSettings'] = [ordered]@{}
                    if ($DiableAnchorClickable) {
                        $SmartWizard['anchorSettings']['anchorClickable'] = $false
                    }
                    if ($EnableAllAnchors) {
                        $SmartWizard['anchorSettings']['enableAllAnchors'] = $true
                    }
                    if ($DisableMarkDoneStep) {
                        $SmartWizard['anchorSettings']['markDoneStep'] = $false
                    }
                    if ($DisableMarkAllPreviousStepsAsDone) {
                        $SmartWizard['anchorSettings']['markAllPreviousStepsAsDone'] = $false
                    }
                    if ($RemoveDoneStepOnNavigateBack) {
                        $SmartWizard['anchorSettings']['removeDoneStepOnNavigateBack'] = $true
                    }
                    if ($DisableAnchorOnDoneStep) {
                        $SmartWizard['anchorSettings']['enableAnchorOnDoneStep'] = $false
                    }
                }

                if ($DisableCycleSteps) {
                    $SmartWizard['cycleSteps'] = $false
                }
                if ($DisableJustification) {
                    $SmartWizard['justified'] = $false
                }
                if ($DisableBackButtonSupport) {
                    $SmartWizard['backButtonSupport'] = $false
                }
                if ($DisableURLhash) {
                    $SmartWizard['enableURLhash'] = $false
                }

                Remove-EmptyValue -Hashtable $SmartWizard
                $SmartWizardConfiguration = $SmartWizard | ConvertTo-Json -Depth 2

                New-HTMLTag -Tag 'script' {
                    @"
                `$(document).ready(function(){
                    // SmartWizard initialize
                    `$('#$WizardID').smartWizard($SmartWizardConfiguration);
                });
                // Initialize the stepContent event
                `$("#$WizardID").on("showStep", function (e, anchorObject, stepIndex, stepDirection) {
                    if (anchorObject[0].hash) {
                        var id = anchorObject[0].hash.replace('#', '');
                        findObjectsToRedraw(id);
                    };
                });
"@
                }
            }
            $null = $Script:HTMLSchema['WizardList'].Remove($TabID)
        }
    }
}
function New-HTMLWizardStep {
    [CmdLetBinding(DefaultParameterSetName = 'FontAwesomeBrands')]
    param(
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [Parameter(Mandatory = $false, Position = 0)][ValidateNotNull()][ScriptBlock] $HtmlData = $(Throw "No curly brace?)"),
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [alias('TabHeading')][Parameter(Mandatory = $false, Position = 1)][String]$Heading,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [alias('TabName')][string] $Name = 'Tab',

        # ICON BRANDS
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeBrands.Keys)
            }
        )]
        [ValidateScript( { $_ -in (($Global:HTMLIcons.FontAwesomeBrands.Keys)) })]
        [string] $IconBrands,

        # ICON REGULAR
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeRegular.Keys)
            }
        )]
        [ValidateScript( { $_ -in (($Global:HTMLIcons.FontAwesomeRegular.Keys)) })]
        [string] $IconRegular,

        # ICON SOLID
        [parameter(ParameterSetName = "FontAwesomeSolid")]
        [ArgumentCompleter(
            {
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                ($Global:HTMLIcons.FontAwesomeSolid.Keys)
            }
        )]
        [ValidateScript( { $_ -in (($Global:HTMLIcons.FontAwesomeSolid.Keys)) })]
        [string] $IconSolid,

        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][object] $TextSize,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $TextColor,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][object] $IconSize,
        [parameter(ParameterSetName = "FontAwesomeBrands")]
        [parameter(ParameterSetName = "FontAwesomeRegular")]
        [parameter(ParameterSetName = "FontAwesomeSolid")][string] $IconColor,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [string] $AnchorName
    )
    if (-not $Script:HTMLSchema.Features) {
        Write-Warning 'New-HTMLWizardStep - Creation of HTML aborted. Most likely New-HTML is missing.'
        Exit
    }
    if (-not $AnchorName) {
        $AnchorName = "WizardStep-$(Get-RandomStringName -Size 8)"
    }
    [string] $Icon = ''
    if ($IconBrands) {
        $Icon = "fab fa-$IconBrands" # fa-$($FontSize)x"
    } elseif ($IconRegular) {
        $Icon = "far fa-$IconRegular" # fa-$($FontSize)x"
    } elseif ($IconSolid) {
        $Icon = "fas fa-$IconSolid" # fa-$($FontSize)x"
    }

    $StyleText = @{ }
    #if ($TextSize -ne 0) {
    $StyleText['font-size'] = ConvertFrom-Size -Size $TextSize  #"$($TextSize)px"
    #}
    if ($TextColor) {
        $StyleText.'color' = ConvertFrom-Color -Color $TextColor
    }

    $StyleText.'text-transform' = "$TextTransform"

    $StyleIcon = @{ }
    #if ($IconSize -ne 0) {
    $StyleIcon.'font-size' = ConvertFrom-Size -Size $IconSize #"$($IconSize)px"
    #}
    if ($IconColor) {
        $StyleIcon.'color' = ConvertFrom-Color -Color $IconColor
    }

    # Tabs related to tab panel (New-HTMLTabPanel)
    if ($HtmlData) {
        $WizardExecutedCode = & $HtmlData
    } else {
        $WizardExecutedCode = ''
    }
    [PSCustomObject] @{
        Name      = $Name
        ID        = $AnchorName
        Icon      = $Icon
        StyleIcon = $StyleIcon
        StyleText = $StyleText
        Content   = $WizardExecutedCode
    }
}
function New-OrgChartNode {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Children
    Define children of the node by specifying nested nodes (self-nesting)

    .PARAMETER Name
    Name of the node

    .PARAMETER Title
    Title of the node

    .PARAMETER ClassName
    Parameter description

    .EXAMPLE
    New-HTML {
        New-HTMLOrgChart {
            New-OrgChartNode -Name 'Test' -Title 'Test2' {
                New-OrgChartNode -Name 'Test' -Title 'Test2'
                New-OrgChartNode -Name 'Test' -Title 'Test2'
                New-OrgChartNode -Name 'Test' -Title 'Test2' {
                    New-OrgChartNode -Name 'Test' -Title 'Test2'
                }
            }
        } -AllowExport -ExportExtension pdf -Draggable
    } -FilePath $PSScriptRoot\Example-OrgChart01.html -ShowHTML -Online

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [scriptblock] $Children,
        [string] $Name,
        [string] $Title,
        # [string] $ClassName,
        [string] $TitleBackgroundColor,
        [string] $TitleBorderColor,
        [string] $TitleColor,
        [string] $ContentBackgroundColor,
        [string] $ContentBorderColor,
        [string] $ContentColor
    )

    $ClassName = "orgchartColoring$(Get-RandomStringName -Size 8 -LettersOnly)"
    $StyleNodeInformation = @{
        ".orgchart .$ClassName .title"   = @{
            'color'            = ConvertFrom-Color -Color $TitleColor
            'border-color'     = ConvertFrom-Color -Color $TitleBorderColor
            'background-color' = ConvertFrom-Color -Color $TitleBackgroundColor
        }
        ".orgchart .$ClassName .content" = @{
            'color'            = ConvertFrom-Color -Color $ContentColor
            'border-color'     = ConvertFrom-Color -Color $ContentBorderColor
            'background-color' = ConvertFrom-Color -Color $ContentBackgroundColor
        }
    }
    Remove-EmptyValue -Hashtable $StyleNodeInformation -Recursive -Rerun 2
    if ($StyleNodeInformation) {
        Add-HTMLStyle -Placement Header -Css $StyleNodeInformation -SkipTags
    }
    $ChartNode = [ordered] @{
        name      = $Name
        title     = $Title
        className = $ClassName
        nodeId    = $Name
    }
    if ($Children) {
        $ChildrenOutput = & $Children
        $ChartNode['children'] = @($ChildrenOutput)
    }
    Remove-EmptyValue -Hashtable $ChartNode
    $ChartNode
}

Register-ArgumentCompleter -CommandName New-OrgChartNode -ParameterName TitleBackgroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-OrgChartNode -ParameterName TitleColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-OrgChartNode -ParameterName BorderColor -ScriptBlock $Script:ScriptBlockColors
function New-TableAlphabetSearch {
    [alias('TableAlphabetSearch', 'New-HTMLTableAlphabetSearch')]
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ID')][int] $ColumnID,
        [Parameter(Mandatory, ParameterSetName = 'Name')][string] $ColumnName,
        [switch] $AddNumbers,
        [switch] $CaseSensitive
    )
    $Output = [PSCustomObject]@{
        Type   = 'TableAlphabetSearch'
        Output = @{
            ColumnID   = $ColumnID
            ColumnName = $ColumnName
        }
    }
    if ($CaseSensitive) {
        $Output.Output['caseSensitive'] = $true
    }
    if ($AddNumbers) {
        $Output.Output['numbers'] = $true
    }
    Remove-EmptyValue -Hashtable $Output.Output
    $Output
}
function New-TableButtonCopy {
    [alias('TableButtonCopy', 'EmailTableButtonCopy', 'New-HTMLTableButtonCopy')]
    [CmdletBinding()]
    param(
        [string] $Title
    )
    if (-not $Script:HTMLSchema['TableSimplify']) {
        $Script:HTMLSchema.Features.DataTablesButtons = $true
        $Script:HTMLSchema.Features.DataTablesButtonsHTML5 = $true
    }
    $Output = [ordered]@{}
    $Output['extend'] = 'copyHtml5'
    if ($Title) {
        $Output['title'] = $title
    }
    [PSCustomObject] @{
        Type   = 'TableButtonCopy'
        Output = $Output
    }
}
function New-TableButtonCSV {
    [alias('TableButtonCSV', 'EmailTableButtonCSV', 'New-HTMLTableButtonCSV')]
    [CmdletBinding()]
    param(
        [string] $Title
    )
    if (-not $Script:HTMLSchema['TableSimplify']) {
        $Script:HTMLSchema.Features.DataTablesButtons = $true
        $Script:HTMLSchema.Features.DataTablesButtonsHTML5 = $true
    }
    $Output = [ordered]@{}
    $Output['extend'] = 'csvHtml5'
    if ($Title) {
        $Output['title'] = $title
    }
    [PSCustomObject] @{
        Type   = 'TableButtonCSV'
        Output = $Output
    }
}
function New-TableButtonExcel {
    [alias('TableButtonExcel', 'EmailTableButtonExcel', 'New-HTMLTableButtonExcel')]
    [CmdletBinding()]
    param(
        [string] $Title
    )
    if (-not $Script:HTMLSchema['TableSimplify']) {
        $Script:HTMLSchema.Features.DataTablesButtons = $true
        $Script:HTMLSchema.Features.DataTablesButtonsHTML5 = $true
        $Script:HTMLSchema.Features.DataTablesButtonsExcel = $true
    }
    $Output = @{}
    $Output['extend'] = 'excelHtml5'
    if ($Title) {
        $Output['title'] = $title
    }
    [PSCustomObject] @{
        Type   = 'TableButtonExcel'
        Output = $Output
    }
}
function New-TableButtonPageLength {
    [alias('TableButtonPageLength', 'EmailTableButtonPageLength', 'New-HTMLTableButtonPageLength')]
    [CmdletBinding()]
    param(
        [string] $Title
    )
    if (-not $Script:HTMLSchema['TableSimplify']) {
        $Script:HTMLSchema.Features.DataTablesButtons = $true
    }
    $Output = @{}
    $Output['extend'] = 'pageLength'
    if ($Title) {
        $Output['title'] = $title
    }
    [PSCustomObject] @{
        Type   = 'TableButtonPageLength'
        Output = $Output
    }
}
function New-TableButtonPDF {
    <#
    .SYNOPSIS
    Allows more control when adding buttons to Table

    .DESCRIPTION
    Allows more control when adding buttons to Table. Works only within Table or New-HTMLTable scriptblock.

    .PARAMETER Title
    Document title (appears above the table in the generated PDF). The special character * is automatically replaced with the value read from the host document's title tag.

    .PARAMETER DisplayName
    The button's display text. The text can be configured using this option

    .PARAMETER MessageBottom
    Message to be shown at the bottom of the table, or the caption tag if displayed at the bottom of the table.

    .PARAMETER MessageTop
    Message to be shown at the top of the table, or the caption tag if displayed at the top of the table.

    .PARAMETER FileName
    File name to give the created file (plus the extension defined by the extension option). The special character * is automatically replaced with the value read from the host document's title tag.

    .PARAMETER Extension
    The extension to give the created file name. (default .pdf)

    .PARAMETER PageSize
    Paper size for the created PDF. This can be A3, A4, A5, LEGAL, LETTER or TABLOID. Other options are available.

    .PARAMETER Orientation
    Paper orientation for the created PDF. This can be portrait or landscape

    .PARAMETER Header
    Indicate if the table header should be included in the exported data or not.

    .PARAMETER Footer
    Indicate if the table footer should be included in the exported data or not.

    .EXAMPLE
    Dashboard -Name 'Dashimo Test' -FilePath $PSScriptRoot\DashboardEasy05.html -Show {
        Section -Name 'Test' -Collapsable {
            Container {
                Panel {
                    Table -DataTable $Process {
                        TableButtonPDF
                        TableButtonCopy
                        TableButtonExcel
                    } -Buttons @() -DisableSearch -DisablePaging -HideFooter
                }
                Panel {
                    Table -DataTable $Process -Buttons @() -DisableSearch -DisablePaging -HideFooter
                }
                Panel {
                    Table -DataTable $Process {
                        TableButtonPDF -PageSize A10 -Orientation landscape
                        TableButtonCopy
                        TableButtonExcel
                    } -Buttons @() -DisableSearch -DisablePaging -HideFooter
                }
            }
        }
    }

    .NOTES
    Options are based on this URL: https://datatables.net/reference/button/pdfHtml5

    #>

    [alias('TableButtonPDF', 'EmailTableButtonPDF', 'New-HTMLTableButtonPDF')]
    [CmdletBinding()]
    param(
        [string] $Title,
        [string] $DisplayName,
        [string] $MessageBottom,
        [string] $MessageTop,
        [string] $FileName,
        [string] $Extension,
        [string][ValidateSet('4A0', '2A0', 'A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10',
            'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10',
            'C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10',
            'RA0', 'RA1', 'RA2', 'RA3', 'RA4',
            'SRA0', 'SRA1', 'SRA2', 'SRA3', 'SRA4',
            'EXECUTIVE', 'FOLIO', 'LEGAL', 'LETTER', 'TABLOID')] $PageSize = 'A3',
        [string][ValidateSet('portrait', 'landscape')] $Orientation = 'landscape',
        [switch] $Header,
        [switch] $Footer
    )
    if (-not $Script:HTMLSchema['TableSimplify']) {
        $Script:HTMLSchema.Features.DataTablesButtons = $true
        $Script:HTMLSchema.Features.DataTablesButtonsPDF = $true
        $Script:HTMLSchema.Features.DataTablesButtonsHTML5 = $true
    }
    $Button = @{ }
    $Button.extend = 'pdfHtml5'
    $Button.pageSize = $PageSize
    $Button.orientation = $Orientation
    if ($MessageBottom) {
        $Button.messageBottom = $MessageBottom
    }
    if ($MessageTop) {
        $Button.messageTop = $MessageTop
    }
    if ($DisplayName) {
        $Button.text = $DisplayName
    }
    if ($Title) {
        $Button.title = $Title
    }
    if ($FileName) {
        $Button.filename = $FileName
    }
    if ($Extension) {
        $Button.extension = $Extension
    }
    if ($Header) {
        $Button.header = $Header.IsPresent
    }
    if ($Footer) {
        $Button.footer = $Footer.IsPresent
    }

    [PSCustomObject] @{
        Type   = 'TableButtonPDF'
        Output = $Button
    }
}







function New-TableButtonPrint {
    [alias('TableButtonPrint', 'EmailTableButtonPrint', 'New-HTMLTableButtonPrint')]
    [CmdletBinding()]
    param(
        [string] $Title
    )
    if (-not $Script:HTMLSchema['TableSimplify']) {
        $Script:HTMLSchema.Features.DataTablesButtons = $true
    }
    $Output = @{}
    $Output['extend'] = 'print'
    if ($Title) {
        $Output['title'] = $title
    }
    [PSCustomObject] @{
        Type   = 'TableButtonPrint'
        Output = $Button
    }
}
function New-TableColumnOption {
    <#
    .SYNOPSIS
        Allows for certain modification of options within DataTable's columnDefs parameter. You can set visibility, searchability, sortability, and width for specific columns
    .DESCRIPTION
        Allows for certain modification of options within DataTable's columnDefs parameter.
        See: https://datatables.net/reference/option/columnDefs

        New-HTMLTable has parameters for -ResponsivePriorityOrder and -ResponsivePriorityOrderIndex and these are set at a higher precedent than options specified here.
        See the DataTable reference section for conflict resolution.

        The New-TableColumnOption cmdlet will add entries to the columnDefs parameter in the order in which the cmdlets are ordered.
        If you use 2 or more New-TableColumnOption, the first cmdlet takes priority over the second cmdlet if they specify the same targets or overriding property values
        With this in mind, you should almost always specify -AllColumns last, since that will take priority over any commands issued later

    .EXAMPLE
        New-TableColumnOption -ColumnIndex (0..4) -Width 50
        The first 5 columns with have a width defined as 50, this may not be exact.
        See: https://datatables.net/reference/option/columns.width
    .EXAMPLE
        New-TableColumnOption -ColumnIndex 0,1,2 -Hidden $false
        New-TableColumnOption -ColumnIndex 1 -Sortable $true
        New-TableColumnOption -AllColumns -Hidden $true -Searchable $false -Sortable $false
        All columns will be hidden, not searchable, and not sortable
        However, since there is a option specified higher up, the first 3 columns will be visible
        Additionally the 2nd column will be sortable
    .INPUTS
        None. You cannot pipe objects to New-TableColumnOption
    .OUTPUTS
        PSCustomObject
    .NOTES
        The New-HTMLTable cmdlet has -ResponsivePriorityOrder and -ResponsivePriorityOrderIndex that also modifes the columnDefs option in DataTable
    #>
    [CmdletBinding(DefaultParameterSetName = 'ColumnIndex', SupportsShouldProcess = $false, PositionalBinding = $false, HelpUri = '', ConfirmImpact = 'Medium')]
    [Alias('EmailTableColumnOption', 'TableColumnOption', 'New-HTMLTableColumnOption')]
    [OutputType([PSCustomObject])]
    param(
        # Identifies specific columns that the properties should apply to
        [Parameter(ParameterSetName = "ColumnIndex", Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [alias('Targets')]
        [int[]]
        $ColumnIndex,

        # Uses the columnDef Target "_ALL" to indicate all columns / remaining columns
        [Parameter(ParameterSetName = "AllColumns", Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [alias('AllTargets', 'TargetAll')]
        [switch]
        $AllColumns,

        # Width for the column as a string
        [Parameter(ParameterSetName = "ColumnIndex")]
        [Parameter(ParameterSetName = "AllColumns")]
        [string]
        $Width,

        # Defines if a column is hidden. A hidden column can still be used by Conditional Formatting and can still be searchable
        [Parameter(ParameterSetName = "ColumnIndex")]
        [Parameter(ParameterSetName = "AllColumns")]
        [boolean]$Hidden,

        # Defines if a column is able to be searched
        [Parameter(ParameterSetName = "ColumnIndex")]
        [Parameter(ParameterSetName = "AllColumns")]
        [boolean]$Searchable,

        # Defines if a column can be sorted
        [Parameter(ParameterSetName = "ColumnIndex")]
        [Parameter(ParameterSetName = "AllColumns")]
        [boolean]$Sortable
    )

    # Create a hashtable property
    $TableColumnOptionProperty = @{
        targets = if ($AllColumns) { "_all" } else { $ColumnIndex };
    }

    # Check for the existence of parameters, if they are not null then we will set them in the properties
    # IF they are null, we don't want to include any values by default
    If ($null -ne $PSBoundParameters['Width']) { $TableColumnOptionProperty.width = $Width }
    If ($null -ne $PSBoundParameters['Hidden']) { $TableColumnOptionProperty.visible = !$Hidden }
    If ($null -ne $PSBoundParameters['Searchable']) { $TableColumnOptionProperty.searchable = $Searchable }
    If ($null -ne $PSBoundParameters['Sortable']) { $TableColumnOptionProperty.orderable = $Sortable }


    # Check that we just don't have the 'targets' set, if so, then we have properties and return a custom object
    If ($TableColumnOptionProperty.Keys.Count -gt 1) {
        [PSCustomObject] @{
            Type   = 'TableColumnOption'
            Output = [PSCustomObject]$TableColumnOptionProperty
        }
    } Else {
        Write-Warning "New-TableColumnOption did not have any additional arguments listed"
    }

}

function New-TableCondition {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Name
    Parameter description

    .PARAMETER HighlightHeaders
    By default Name parameter is used as column to be highlighted. In case you want to specify different header(s) to be highlighted you can use this parameter.

    .PARAMETER ComparisonType
    Parameter description

    .PARAMETER Operator
    Parameter description

    .PARAMETER Value
    Parameter description

    .PARAMETER Row
    Parameter description

    .PARAMETER Inline
    Parameter description

    .PARAMETER CaseSensitive
    Parameter description

    .PARAMETER DateTimeFormat
    Parameter description

    .PARAMETER ReverseCondition
    By default ColumnValue (left side) is being compared to Condition Value (right side). This switch reverses the comparison

    .PARAMETER Color
    Parameter description

    .PARAMETER BackgroundColor
    Parameter description

    .PARAMETER FontSize
    Parameter description

    .PARAMETER FontWeight
    Parameter description

    .PARAMETER FontStyle
    Parameter description

    .PARAMETER FontVariant
    Parameter description

    .PARAMETER FontFamily
    Parameter description

    .PARAMETER Alignment
    Parameter description

    .PARAMETER TextDecoration
    Parameter description

    .PARAMETER TextTransform
    Parameter description

    .PARAMETER Direction
    Parameter description

    .PARAMETER FailColor
    Parameter description

    .PARAMETER FailBackgroundColor
    Parameter description

    .PARAMETER FailFontSize
    Parameter description

    .PARAMETER FailFontWeight
    Parameter description

    .PARAMETER FailFontStyle
    Parameter description

    .PARAMETER FailFontVariant
    Parameter description

    .PARAMETER FailFontFamily
    Parameter description

    .PARAMETER FailAlignment
    Parameter description

    .PARAMETER FailTextDecoration
    Parameter description

    .PARAMETER FailTextTransform
    Parameter description

    .PARAMETER FailDirection
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [alias('EmailTableCondition', 'TableConditionalFormatting', 'New-HTMLTableCondition', 'TableCondition')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][alias('ColumnName')][string] $Name,
        [string[]] $HighlightHeaders,
        [alias('Type')][ValidateSet('number', 'string', 'bool', 'date')][string] $ComparisonType = 'string',
        [ValidateSet('lt', 'le', 'eq', 'ge', 'gt', 'ne', 'contains', 'like', 'notlike', 'notcontains', 'between', 'betweenInclusive', 'in', 'notin')][string] $Operator = 'eq',
        [parameter(Mandatory)][Object] $Value,
        [switch] $Row,
        [switch] $Inline,
        [switch] $CaseSensitive,
        [string] $DateTimeFormat,
        [switch] $ReverseCondition,
        # Style for PASS
        [string]$Color,
        [string]$BackgroundColor,
        [object] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        # Style for FAIL
        [string]$FailColor,
        [string]$FailBackgroundColor,
        [object] $FailFontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FailFontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FailFontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FailFontVariant,
        [string] $FailFontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $FailAlignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $FailTextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $FailTextTransform,
        [ValidateSet('rtl')][string] $FailDirection
    )

    $Script:HTMLSchema.Features.DataTablesConditions = $true

    $Style = @{
        Color           = $Color
        BackGroundColor = $BackGroundColor
        FontSize        = $FontSize
        FontWeight      = $FontWeight
        FontStyle       = $FontStyle
        FontVariant     = $FontVariant
        FontFamily      = $FontFamily
        Alignment       = $Alignment
        TextDecoration  = $TextDecoration
        TextTransform   = $TextTransform
        Direction       = $Direction
    }
    Remove-EmptyValue -Hashtable $Style

    $FailStyle = @{
        Color           = $FailColor
        BackGroundColor = $FailBackGroundColor
        FontSize        = $FailFontSize
        FontWeight      = $FailFontWeight
        FontStyle       = $FailFontStyle
        FontVariant     = $FailFontVariant
        FontFamily      = $FailFontFamily
        Alignment       = $FailAlignment
        TextDecoration  = $FailTextDecoration
        TextTransform   = $FailTextTransform
        Direction       = $FailDirection
    }
    Remove-EmptyValue -Hashtable $FailStyle

    $TableCondition = [PSCustomObject] @{
        ConditionType    = 'Condition'
        Row              = $Row
        Type             = $ComparisonType
        Name             = $Name
        Operator         = $Operator
        Value            = $Value
        Style            = ConvertTo-HTMLStyle @Style
        FailStyle        = ConvertTo-HTMLStyle @FailStyle
        HighlightHeaders = $HighlightHeaders
        CaseSensitive    = $CaseSensitive.IsPresent
        DateTimeFormat   = $DateTimeFormat
        ReverseCondition = $ReverseCondition.IsPresent
    }
    [PSCustomObject] @{
        Type   = if ($Inline) { 'TableConditionInline' } else { 'TableCondition' }
        Output = $TableCondition
    }
}

Register-ArgumentCompleter -CommandName New-TableCondition -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableCondition -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableCondition -ParameterName FailColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableCondition -ParameterName FailBackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-TableConditionGroup {
    [alias('EmailTableConditionGroup', 'TableConditionGroup', 'New-HTMLTableConditionGroup')]
    [CmdletBinding()]
    param(
        [scriptblock] $Conditions,
        [ValidateSet('AND', 'OR', 'NONE')][string] $Logic = 'AND',
        [string[]] $HighlightHeaders,
        [switch] $Row,
        [switch] $Inline,
        # Style for PASS
        [string]$Color,
        [string]$BackgroundColor,
        [int] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        # Style for FAIL
        [string]$FailColor,
        [string]$FailBackgroundColor,
        [object] $FailFontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FailFontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FailFontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FailFontVariant,
        [string] $FailFontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $FailAlignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $FailTextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $FailTextTransform,
        [ValidateSet('rtl')][string] $FailDirection
    )
    if ($Conditions) {
        $Script:HTMLSchema.Features.DataTablesConditions = $true

        $Style = @{
            Color           = $Color
            BackGroundColor = $BackGroundColor
            FontSize        = $FontSize
            FontWeight      = $FontWeight
            FontStyle       = $FontStyle
            FontVariant     = $FontVariant
            FontFamily      = $FontFamily
            Alignment       = $Alignment
            TextDecoration  = $TextDecoration
            TextTransform   = $TextTransform
            Direction       = $Direction
        }
        Remove-EmptyValue -Hashtable $Style

        $FailStyle = @{
            Color           = $FailColor
            BackGroundColor = $FailBackGroundColor
            FontSize        = $FailFontSize
            FontWeight      = $FailFontWeight
            FontStyle       = $FailFontStyle
            FontVariant     = $FailFontVariant
            FontFamily      = $FailFontFamily
            Alignment       = $FailAlignment
            TextDecoration  = $FailTextDecoration
            TextTransform   = $FailTextTransform
            Direction       = $FailDirection
        }
        Remove-EmptyValue -Hashtable $FailStyle

        $TableConditionGroup = [PSCustomObject] @{
            ConditionType    = 'ConditionGroup'
            Style            = ConvertTo-HTMLStyle @Style
            FailStyle        = ConvertTo-HTMLStyle @FailStyle
            Conditions       = & $Conditions
            Row              = $Row
            Logic            = $Logic
            HighlightHeaders = $HighlightHeaders
            DateTimeFormat   = $DateTimeFormat
        }
        [PSCustomObject] @{
            Type   = if ($Inline) { 'TableConditionGroupInline' } else { 'TableConditionGroup' }
            Output = $TableConditionGroup
        }
    }
}

Register-ArgumentCompleter -CommandName New-TableConditionGroup -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableConditionGroup -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableConditionGroup -ParameterName FailColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableConditionGroup -ParameterName FailBackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-TableContent {
    [alias('TableContent', 'EmailTableContent', 'New-HTMLTableContent')]
    [CmdletBinding()]
    param(
        [alias('ColumnNames', 'Names', 'Name')][string[]] $ColumnName,
        [int[]] $ColumnIndex,
        [int[]] $RowIndex,
        [string[]] $Text,
        [string] $Color,
        [string] $BackGroundColor,
        [int] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        [ValidateSet('normal', 'break-all', 'keep-all', 'break-word')][string] $WordBreak
    )
    if ($WordBreak -eq '' -or $WordBreak -eq 'normal') {
        $WordBreakStyle = ''
    } else {
        $WordBreakStyle = $WordBreak
    }

    $Style = @{
        Color           = $Color
        BackGroundColor = $BackGroundColor
        FontSize        = $FontSize
        FontWeight      = $FontWeight
        FontStyle       = $FontStyle
        FontVariant     = $FontVariant
        FontFamily      = $FontFamily
        Alignment       = $Alignment
        TextDecoration  = $TextDecoration
        TextTransform   = $TextTransform
        Direction       = $Direction
        WordBreak       = $WordBreakStyle
    }
    Remove-EmptyValue -Hashtable $Style

    [PSCustomObject]@{
        Type   = 'TableContentStyle'
        Output = @{
            Name        = $ColumnName
            Text        = $Text
            RowIndex    = $RowIndex | Sort-Object
            ColumnIndex = $ColumnIndex | Sort-Object
            Style       = ConvertTo-HTMLStyle @Style
            Used        = $false
        }
    }
}

Register-ArgumentCompleter -CommandName New-TableContent -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableContent -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-TableEvent {
    [cmdletBinding()]
    param(
        [alias('ID')][string] $TableID,
        [string] $SourceColumnName,
        [nullable[int]] $TargetColumnID,
        [nullable[int]] $SourceColumnID
    )
    if (($null -ne $SourceColumnID -or $SourceColumnName) -and $null -ne $TargetColumnID) {
        $Object = [PSCustomObject] @{
            Type   = 'TableEvent'
            Output = @{
                TableID          = $TableID
                SourceColumnID   = $SourceColumnID
                SourceColumnName = $SourceColumnName
                TargetColumnID   = $TargetColumnID
            }
        }
        $Object
    } else {
        Write-Warning "New-TableEvent - SourceColumnId or SourceColumnName and TargetColumnID are required for events to work."
    }
}
function New-TableHeader {
    [alias('TableHeader', 'EmailTableHeader', 'New-HTMLTableHeader')]
    [CmdletBinding()]
    param(
        [string[]] $Names,
        [string] $Title,
        [string] $Color,
        [string] $BackGroundColor,
        [int] $FontSize,
        [ValidateSet('normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500', '600', '700', '800', '900')][string] $FontWeight,
        [ValidateSet('normal', 'italic', 'oblique')][string] $FontStyle,
        [ValidateSet('normal', 'small-caps')][string] $FontVariant,
        [string] $FontFamily,
        [ValidateSet('left', 'center', 'right', 'justify')][string] $Alignment,
        [ValidateSet('none', 'line-through', 'overline', 'underline')][string] $TextDecoration,
        [ValidateSet('uppercase', 'lowercase', 'capitalize')][string] $TextTransform,
        [ValidateSet('rtl')][string] $Direction,
        [switch] $AddRow,
        [int] $ColumnCount,
        [ValidateSet(
            'all',
            'none',
            'never',
            'desktop',
            'not-desktop',
            'tablet-l',
            'tablet-p',
            'mobile-l',
            'mobile-p',
            'min-desktop',
            'max-desktop',
            'tablet',
            'not-tablet',
            'min-tablet',
            'max-tablet',
            'not-tablet-l',
            'min-tablet-l',
            'max-tablet-l',
            'not-tablet-p',
            'min-tablet-p',
            'max-tablet-p',
            'mobile',
            'not-mobile',
            'min-mobile',
            'max-mobile',
            'not-mobile-l',
            'min-mobile-l',
            'max-mobile-l',
            'not-mobile-p',
            'min-mobile-p',
            'max-mobile-p'
        )][string] $ResponsiveOperations

    )
    if ($AddRow) {
        Write-Warning "New-HTMLTableHeader - Using AddRow switch is deprecated. It's not nessecary anymore. Just use Title alone. It will be removed later on."
    }

    $Style = @{
        Color           = $Color
        BackGroundColor = $BackGroundColor
        FontSize        = $FontSize
        FontWeight      = $FontWeight
        FontStyle       = $FontStyle
        FontVariant     = $FontVariant
        FontFamily      = $FontFamily
        Alignment       = $Alignment
        TextDecoration  = $TextDecoration
        TextTransform   = $TextTransform
        Direction       = $Direction
    }
    Remove-EmptyValue -Hashtable $Style

    if (($AddRow -and $Title) -or ($Title -and -not $Names)) {
        $Type = 'TableHeaderFullRow'
    } elseif ((-not $AddRow -and $Title) -or ($Title -and $Names)) {
        $Type = 'TableHeaderMerge'
    } elseif ($Names -and $ResponsiveOperations) {
        $Type = 'TableHeaderResponsiveOperations'
    } elseif ($ResponsiveOperations) {
        Write-Warning 'New-HTMLTableHeader - ResponsiveOperations require Names (ColumnNames) to apply operation to.'
        return
    } else {
        $Type = 'TableHeaderStyle'
    }

    [PSCustomObject]@{
        Type   = $Type
        Output = @{
            Names                = $Names
            ResponsiveOperations = $ResponsiveOperations
            Title                = $Title
            Style                = ConvertTo-HTMLStyle @Style
            ColumnCount          = $ColumnCount
        }
    }
}

Register-ArgumentCompleter -CommandName New-TableHeader -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableHeader -ParameterName BackGroundColor -ScriptBlock $Script:ScriptBlockColors
function New-TablePercentageBar {
    [alias('TablePercentageBar', 'New-HTMLTablePercentageBar')]
    [CmdletBinding()]
    param(
        [int] $ColumnID,
        [string] $ColumnName,
        [ValidateSet('square', 'round')][string] $Type,
        [string] $TextColor,
        [string] $BorderColor,
        [ValidateSet('solid', 'outset', 'groove', 'ridge')][string] $BorderStyle,
        [string] $BarColor,
        [string] $BackgroundColor,
        [int] $RoundValue
    )
    $Output = [PSCustomObject]@{
        Type   = 'TablePercentageBar'
        Output = @{
            ColumnID        = $ColumnID
            ColumnName      = $ColumnName
            Type            = $Type
            TextColor       = ConvertFrom-Color -Color $TextColor
            BorderColor     = ConvertFrom-Color -Color $BorderColor
            BarColor        = ConvertFrom-Color -Color $BarColor
            BackgroundColor = ConvertFrom-Color -Color $BackgroundColor
            RoundValue      = $RoundValue
            BorderStyle     = $BorderStyle
        }
    }
    Remove-EmptyValue -Hashtable $Output.Output
    $Output
}

Register-ArgumentCompleter -CommandName New-TablePercentageBar -ParameterName TextColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TablePercentageBar -ParameterName BorderColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TablePercentageBar -ParameterName BarColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TablePercentageBar -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-TableReplace {
    [alias('TableReplace', 'EmailTableReplace', 'New-HTMLTableReplace')]
    [CmdletBinding()]
    param(
        [string] $FieldName,
        [string[]] $Replacements

    )
    [PSCustomObject]@{
        Type   = 'TableReplaceCompare'
        Output = @{
            $FieldName = $Replacements
        }
    }
}
function New-TableRowGrouping {
    [alias('TableRowGrouping', 'EmailTableRowGrouping', 'New-HTMLTableRowGrouping')]
    [CmdletBinding()]
    param(
        [alias('ColumnName')][string] $Name,
        [int] $ColumnID = -1,
        [ValidateSet('Ascending', 'Descending')][string] $SortOrder = 'Ascending',
        [string] $Color,
        [string] $BackgroundColor
    )
    $Script:HTMLSchema.Features.DataTablesRowGrouping = $true

    $Object = [PSCustomObject] @{
        Type   = 'TableRowGrouping'
        Output = [ordered] @{
            Name       = $Name
            ColumnID   = $ColumnID
            Sorting    = if ('Ascending') { 'asc' } else { 'desc' }
            Attributes = @{
                'color'            = ConvertFrom-Color -Color $Color
                'background-color' = ConvertFrom-Color -Color $BackgroundColor
            }
        }
    }
    Remove-EmptyValue -Hashtable $Object.Output
    $Object
}

Register-ArgumentCompleter -CommandName New-TableRowGrouping -ParameterName Color -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-TableRowGrouping -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
function New-TreeNode {
    [CmdletBinding()]
    param(
        [scriptblock] $Children,
        [string] $Title,
        [string] $Id,
        [switch] $Folder
    )

    if ($Children) {
        [Array] $SourceChildren = & $Children
    }

    $Node = [ordered] @{
        title  = $Title
        key    = $Id
        folder = $Folder.IsPresent
    }
    if ($SourceChildren.Count) {
        $Node['children'] = $SourceChildren
    }
    $Node
}
function Out-HtmlView {
    <#
    .SYNOPSIS
    Small function that allows to send output to HTML

    .DESCRIPTION
    Small function that allows to send output to HTML. When displaying in HTML it allows data to output to EXCEL, CSV and PDF. It allows sorting, searching and so on.

    .PARAMETER Table
    Data you want to display

    .PARAMETER Title
    Title of HTML Window

    .PARAMETER DefaultSortColumn
    Sort by Column Name

    .PARAMETER DefaultSortIndex
    Sort by Column Index

    .EXAMPLE
    Get-Process | Select-Object -First 5 | Out-HtmlView

    .NOTES
    General notes
    #>
    [alias('Out-GridHtml', 'ohv')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)][ScriptBlock] $HTML,
        [Parameter(Mandatory = $false, Position = 1)][ScriptBlock] $PreContent,
        [Parameter(Mandatory = $false, Position = 2)][ScriptBlock] $PostContent,
        [alias('ArrayOfObjects', 'Object', 'DataTable')][Parameter(ValueFromPipeline = $true, Mandatory = $false)] $Table,
        [string] $FilePath,
        [string] $Title = 'Out-HTMLView',
        [switch] $PassThru,
        [string[]][ValidateSet('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'print', 'searchPanes')] $Buttons = @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength'),
        [string[]][ValidateSet('numbers', 'simple', 'simple_numbers', 'full', 'full_numbers', 'first_last_numbers')] $PagingStyle = 'full_numbers',
        [int[]]$PagingOptions = @(15, 25, 50, 100),
        [int] $PagingLength,
        [switch]$DisablePaging,
        [switch]$DisableOrdering,
        [switch]$DisableInfo,
        [switch]$HideFooter,
        [alias('DisableButtons')][switch]$HideButtons,
        [switch]$DisableProcessing,
        [switch]$DisableResponsiveTable,
        [switch]$DisableSelect,
        [switch]$DisableStateSave,
        [switch]$DisableSearch,
        [switch]$OrderMulti,
        [switch]$Filtering,
        [ValidateSet('Top', 'Bottom', 'Both')][string]$FilteringLocation = 'Bottom',
        [string[]][ValidateSet('display', 'cell-border', 'compact', 'hover', 'nowrap', 'order-column', 'row-border', 'stripe')] $Style = @('display', 'compact'),
        [switch]$Simplify,
        [string]$TextWhenNoData = 'No data available to display.',
        [int] $ScreenSizePercent = 0,
        [string[]] $DefaultSortColumn,
        [int[]] $DefaultSortIndex,
        [ValidateSet('Ascending', 'Descending')][string] $DefaultSortOrder = 'Ascending',
        [string[]] $DateTimeSortingFormat,
        [alias('Search')][string]$Find,
        [switch] $InvokeHTMLTags,
        [switch] $DisableNewLine,
        [switch] $EnableKeys,
        [switch] $EnableColumnReorder,
        [switch] $EnableRowReorder,
        [switch] $EnableAutoFill,
        [switch] $EnableScroller,
        [switch] $ScrollX,
        [switch] $ScrollY,
        [int] $ScrollSizeY = 500,
        [switch]$ScrollCollapse,
        [int] $FreezeColumnsLeft,
        [int] $FreezeColumnsRight,
        [switch] $FixedHeader,
        [switch] $FixedFooter,
        [string[]] $ResponsivePriorityOrder,
        [int[]] $ResponsivePriorityOrderIndex,
        [string[]] $PriorityProperties,
        [string[]] $IncludeProperty,
        [string[]] $ExcludeProperty,
        [switch] $ImmediatelyShowHiddenDetails,
        [alias('RemoveShowButton')][switch] $HideShowButton,
        [switch] $AllProperties,
        [switch] $SkipProperties,
        [switch] $Compare,
        [alias('CompareWithColors')][switch] $HighlightDifferences,
        [int] $First,
        [int] $Last,
        [alias('Replace')][Array] $CompareReplace,
        [alias('RegularExpression')][switch]$SearchRegularExpression,
        [ValidateSet('normal', 'break-all', 'keep-all', 'break-word')][string] $WordBreak = 'normal',
        [switch] $AutoSize,
        [switch] $DisableAutoWidthOptimization,
        [switch] $SearchPane,
        [ValidateSet('top', 'bottom')][string] $SearchPaneLocation = 'top',
        [switch] $SearchBuilder,
        [ValidateSet('top', 'bottom')][string] $SearchBuilderLocation = 'top',
        [ValidateSet('HTML', 'JavaScript', 'AjaxJSON')][string] $DataStore,
        [switch] $Transpose,
        [switch] $PreventShowHTML,
        [switch] $Online,
        [string] $OverwriteDOM,
        [switch] $SearchHighlight,
        [switch] $AlphabetSearch
    )
    Begin {
        $DataTable = [System.Collections.Generic.List[Object]]::new()
        if ($FilePath -eq '') {
            $FilePath = Get-FileName -Extension 'html' -Temporary
        }
    }
    Process {
        if ($null -ne $Table) {
            foreach ($T in $Table) {
                $DataTable.Add($T)
            }
        }
    }
    End {
        if ($null -ne $Table) {
            # HTML generation part
            New-HTML -FilePath $FilePath -Online:($Online.IsPresent) -TitleText $Title -ShowHTML:(-not $PreventShowHTML) {
                $newHTMLTableSplat = @{
                    DataTable                    = $DataTable
                    HideFooter                   = $HideFooter
                    Buttons                      = $Buttons
                    PagingStyle                  = $PagingStyle
                    PagingOptions                = $PagingOptions
                    DisablePaging                = $DisablePaging
                    DisableOrdering              = $DisableOrdering
                    DisableInfo                  = $DisableInfo
                    DisableProcessing            = $DisableProcessing
                    DisableResponsiveTable       = $DisableResponsiveTable
                    DisableSelect                = $DisableSelect
                    DisableStateSave             = $DisableStateSave
                    DisableSearch                = $DisableSearch
                    ScrollCollapse               = $ScrollCollapse
                    Style                        = $Style
                    TextWhenNoData               = $TextWhenNoData
                    ScreenSizePercent            = $ScreenSizePercent
                    HTML                         = $HTML
                    PreContent                   = $PreContent
                    PostContent                  = $PostContent
                    DefaultSortColumn            = $DefaultSortColumn
                    DefaultSortIndex             = $DefaultSortIndex
                    DefaultSortOrder             = $DefaultSortOrder
                    DateTimeSortingFormat        = $DateTimeSortingFormat
                    Find                         = $Find
                    OrderMulti                   = $OrderMulti
                    Filtering                    = $Filtering
                    FilteringLocation            = $FilteringLocation
                    InvokeHTMLTags               = $InvokeHTMLTags
                    DisableNewLine               = $DisableNewLine
                    ScrollX                      = $ScrollX
                    ScrollY                      = $ScrollY
                    ScrollSizeY                  = $ScrollSizeY
                    FreezeColumnsLeft            = $FreezeColumnsLeft
                    FreezeColumnsRight           = $FreezeColumnsRight
                    FixedHeader                  = $FixedHeader
                    FixedFooter                  = $FixedFooter
                    ResponsivePriorityOrder      = $ResponsivePriorityOrder
                    ResponsivePriorityOrderIndex = $ResponsivePriorityOrderIndex
                    PriorityProperties           = $PriorityProperties
                    AllProperties                = $AllProperties
                    SkipProperties               = $SkipProperties
                    Compare                      = $Compare
                    HighlightDifferences         = $HighlightDifferences
                    First                        = $First
                    Last                         = $Last
                    ImmediatelyShowHiddenDetails = $ImmediatelyShowHiddenDetails
                    Simplify                     = $Simplify
                    HideShowButton               = $HideShowButton
                    CompareReplace               = $CompareReplace
                    Transpose                    = $Transpose
                    SearchRegularExpression      = $SearchRegularExpression
                    WordBreak                    = $WordBreak
                    AutoSize                     = $AutoSize
                    DisableAutoWidthOptimization = $DisableAutoWidthOptimization
                    Title                        = $Title
                    SearchPane                   = $SearchPane
                    SearchPaneLocation           = $SearchPaneLocation
                    EnableScroller               = $EnableScroller
                    EnableKeys                   = $EnableKeys
                    EnableAutoFill               = $EnableAutoFill
                    EnableRowReorder             = $EnableRowReorder
                    EnableColumnReorder          = $EnableColumnReorder
                    HideButtons                  = $HideButtons
                    PagingLength                 = $PagingLength
                    DataStore                    = $DataStore
                    DisableColumnReorder         = $DisableColumnReorder
                    AlphabetSearch               = $AlphabetSearch
                    SearchBuilder                = $SearchBuilder
                    SearchBuilderLocation        = $SearchBuilderLocation
                    OverwriteDOM                 = $OverwriteDOM
                    IncludeProperty              = $IncludeProperty
                    ExcludeProperty              = $ExcludeProperty
                }
                Remove-EmptyValue -Hashtable $newHTMLTableSplat
                New-HTMLTable @newHTMLTableSplat

            }
            if ($PassThru) {
                # This isn't really real PassThru but just passing final object further down the pipe when needed
                # real PassThru requires significant work - if you're up to it, let me know.
                $DataTable
            }
        } else {
            Write-Warning 'Out-HtmlView - No data available.'
        }
    }
}

Function Save-HTML {
    <#
    .SYNOPSIS
    #

    .DESCRIPTION
    Long description

    .PARAMETER FilePath
    Parameter description

    .PARAMETER HTML
    Parameter description

    .PARAMETER ShowHTML
    Parameter description

    .PARAMETER Encoding
    Parameter description

    .PARAMETER Supress
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false)][string]$FilePath,
        [Parameter(Mandatory = $true)][string] $HTML,
        [alias('Show', 'Open')][Parameter(Mandatory = $false)][switch]$ShowHTML,
        [ValidateSet('Unknown', 'String', 'Unicode', 'Byte', 'BigEndianUnicode', 'UTF8', 'UTF7', 'UTF32', 'Ascii', 'Default', 'Oem', 'BigEndianUTF32')] $Encoding = 'UTF8',
        [alias('Supress')][bool] $Suppress = $true,
        [switch] $Format,
        [switch] $Minify
    )
    if ([string]::IsNullOrEmpty($FilePath)) {
        $FilePath = Get-FileName -Temporary -Extension 'html'
        Write-Verbose "Save-HTML - FilePath parameter is empty, using Temporary $FilePath"
    } else {
        if (Test-Path -LiteralPath $FilePath) {
            Write-Verbose "Save-HTML - Path $FilePath already exists. Report will be overwritten."
        }
    }
    Write-Verbose "Save-HTML - Saving HTML to file $FilePath"

    if ($Format -or $Minify) {
        $Commands = Get-Command -Name 'Format-HTML' -ErrorAction SilentlyContinue
        if ($Commands -and $Commands.Source -eq 'PSParseHTML') {
            if ($Format) {
                $HTML = Format-HTML -Content $HTML
            }
            if ($Minify) {
                $HTML = Optimize-HTML -Content $HTML
            }
        } else {
            Write-Warning "Save-HTML - Minify or Format functionality requires PSParseHTML module. Please install it using Install-Module PSParseHTML -Force."
        }
    }
    try {
        $HTML | Set-Content -LiteralPath $FilePath -Force -Encoding $Encoding -ErrorAction Stop
        if (-not $Suppress) {
            $FilePath
        }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        $FilePath = Get-FileName -Temporary -Extension 'html'
        Write-Warning "Save-HTML - Failed with error: $ErrorMessage"
        Write-Warning "Save-HTML - Saving HTML to file $FilePath"
        try {
            $HTML | Set-Content -LiteralPath $FilePath -Force -Encoding $Encoding -ErrorAction Stop
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            Write-Warning "Save-HTML - Failed with error: $ErrorMessage`nPlease define a different path for the `'-FilePath`' parameter."
        }
    }
    if ($ShowHTML) {
        try {
            Invoke-Item -LiteralPath $FilePath -ErrorAction Stop
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            Write-Verbose "Save-HTML - couldn't open file $FilePath in a browser. Error: $ErrorMessage"
        }
    }
}



Export-ModuleMember -Function @('Add-HTML', 'Add-HTMLScript', 'Add-HTMLStyle', 'ConvertTo-CascadingStyleSheets', 'Email', 'EmailAttachment', 'EmailBCC', 'EmailBody', 'EmailCC', 'EmailFrom', 'EmailHeader', 'EmailListItem', 'EmailOptions', 'EmailReplyTo', 'EmailServer', 'EmailSubject', 'EmailTo', 'Enable-HTMLFeature', 'New-AccordionItem', 'New-CalendarEvent', 'New-CarouselSlide', 'New-ChartAxisX', 'New-ChartAxisY', 'New-ChartBar', 'New-ChartBarOptions', 'New-ChartDataLabel', 'New-ChartDonut', 'New-ChartEvent', 'New-ChartGrid', 'New-ChartLegend', 'New-ChartLine', 'New-ChartPie', 'New-ChartRadial', 'New-ChartSpark', 'New-ChartTheme', 'New-ChartTimeLine', 'New-ChartToolbar', 'New-ChartToolTip', 'New-DiagramEvent', 'New-DiagramLink', 'New-DiagramNode', 'New-DiagramOptionsInteraction', 'New-DiagramOptionsLayout', 'New-DiagramOptionsLinks', 'New-DiagramOptionsManipulation', 'New-DiagramOptionsNodes', 'New-DiagramOptionsPhysics', 'New-GageSector', 'New-HierarchicalTreeNode', 'New-HTML', 'New-HTMLAccordion', 'New-HTMLAnchor', 'New-HTMLCalendar', 'New-HTMLCarousel', 'New-HTMLChart', 'New-HTMLCodeBlock', 'New-HTMLContainer', 'New-HTMLDiagram', 'New-HTMLFooter', 'New-HTMLGage', 'New-HTMLHeader', 'New-HTMLHeading', 'New-HTMLHierarchicalTree', 'New-HTMLHorizontalLine', 'New-HTMLImage', 'New-HTMLList', 'New-HTMLListItem', 'New-HTMLLogo', 'New-HTMLMain', 'New-HTMLMap', 'New-HTMLNav', 'New-HTMLNavHam', 'New-HTMLNavLink', 'New-HTMLOrgChart', 'New-HTMLPanel', 'New-HTMLPanelStyle', 'New-HTMLQRCode', 'New-HTMLSection', 'New-HTMLSectionStyle', 'New-HTMLSpanStyle', 'New-HTMLStatus', 'New-HTMLStatusItem', 'New-HTMLTab', 'New-HTMLTable', 'New-HTMLTableOption', 'New-HTMLTableStyle', 'New-HTMLTabPanel', 'New-HTMLTabStyle', 'New-HTMLTag', 'New-HTMLText', 'New-HTMLTextBox', 'New-HTMLTimeline', 'New-HTMLTimelineItem', 'New-HTMLToast', 'New-HTMLTree', 'New-HTMLWizard', 'New-HTMLWizardStep', 'New-OrgChartNode', 'New-TableAlphabetSearch', 'New-TableButtonCopy', 'New-TableButtonCSV', 'New-TableButtonExcel', 'New-TableButtonPageLength', 'New-TableButtonPDF', 'New-TableButtonPrint', 'New-TableColumnOption', 'New-TableCondition', 'New-TableConditionGroup', 'New-TableContent', 'New-TableEvent', 'New-TableHeader', 'New-TablePercentageBar', 'New-TableReplace', 'New-TableRowGrouping', 'New-TreeNode', 'Out-HtmlView', 'Save-HTML') -Alias @('Add-CSS', 'Add-JavaScript', 'Add-JS', 'Calendar', 'CalendarEvent', 'Chart', 'ChartAxisX', 'ChartAxisY', 'ChartBar', 'ChartBarOptions', 'ChartCategory', 'ChartDonut', 'ChartGrid', 'ChartLegend', 'ChartLine', 'ChartPie', 'ChartRadial', 'ChartSpark', 'ChartTheme', 'ChartTimeLine', 'ChartToolbar', 'Container', 'Dashboard', 'Diagram', 'DiagramEdge', 'DiagramEdges', 'DiagramLink', 'DiagramNode', 'DiagramOptionsEdges', 'DiagramOptionsInteraction', 'DiagramOptionsLayout', 'DiagramOptionsLinks', 'DiagramOptionsManipulation', 'DiagramOptionsNodes', 'DiagramOptionsPhysics', 'EmailHTML', 'EmailImage', 'EmailList', 'EmailTable', 'EmailTableButtonCopy', 'EmailTableButtonCSV', 'EmailTableButtonExcel', 'EmailTableButtonPageLength', 'EmailTableButtonPDF', 'EmailTableButtonPrint', 'EmailTableColumnOption', 'EmailTableCondition', 'EmailTableConditionGroup', 'EmailTableContent', 'EmailTableHeader', 'EmailTableOption', 'EmailTableReplace', 'EmailTableRowGrouping', 'EmailTableStyle', 'EmailText', 'EmailTextBox', 'Footer', 'Header', 'HierarchicalTreeNode', 'HTMLText', 'Image', 'Main', 'New-ChartCategory', 'New-Diagram', 'New-DiagramEdge', 'New-DiagramOptionsEdges', 'New-HTMLColumn', 'New-HTMLContent', 'New-HTMLLink', 'New-HTMLPanelOption', 'New-HTMLSectionOption', 'New-HTMLSectionOptions', 'New-HTMLTableAlphabetSearch', 'New-HTMLTableButtonCopy', 'New-HTMLTableButtonCSV', 'New-HTMLTableButtonExcel', 'New-HTMLTableButtonPageLength', 'New-HTMLTableButtonPDF', 'New-HTMLTableButtonPrint', 'New-HTMLTableColumnOption', 'New-HTMLTableCondition', 'New-HTMLTableConditionGroup', 'New-HTMLTableContent', 'New-HTMLTableHeader', 'New-HTMLTablePercentageBar', 'New-HTMLTableReplace', 'New-HTMLTableRowGrouping', 'New-HTMLTabOption', 'New-HTMLTabOptions', 'New-JavaScript', 'New-PanelOption', 'New-PanelStyle', 'New-TableOption', 'New-TableStyle', 'New-TabOption', 'ohv', 'Out-GridHtml', 'Panel', 'PanelOption', 'PanelStyle', 'Section', 'SectionOption', 'Tab', 'Table', 'TableAlphabetSearch', 'TableButtonCopy', 'TableButtonCSV', 'TableButtonExcel', 'TableButtonPageLength', 'TableButtonPDF', 'TableButtonPrint', 'TableColumnOption', 'TableCondition', 'TableConditionalFormatting', 'TableConditionGroup', 'TableContent', 'TableHeader', 'TableOption', 'TablePercentageBar', 'TableReplace', 'TableRowGrouping', 'TableStyle', 'TabOption', 'TabOptions', 'TabStyle', 'Text')
# SIG # Begin signature block
# MIIdWQYJKoZIhvcNAQcCoIIdSjCCHUYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEBtHHL8RANmfvmFrDcPP8z/J
# 4SygghhnMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMzExMTEwMDAwMDAwWjBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtDhXO5EOAXLGH87dg
# +XESpa7cJpSIqvTO9SA5KFhgDPiA2qkVlTJhPLWxKISKityfCgyDF3qPkKyK53lT
# XDGEKvYPmDI2dsze3Tyoou9q+yHyUmHfnyDXH+Kx2f4YZNISW1/5WBg1vEfNoTb5
# a3/UsDg+wRvDjDPZ2C8Y/igPs6eD1sNuRMBhNZYW/lmci3Zt1/GiSw0r/wty2p5g
# 0I6QNcZ4VYcgoc/lbQrISXwxmDNsIumH0DJaoroTghHtORedmTpyoeb6pNnVFzF1
# roV9Iq4/AUaG9ih5yLHa5FcXxH4cDrC0kqZWs72yl+2qp/C3xag/lRbQ/6GW6whf
# GHdPAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBRF66Kv9JLLgjEtUYunpyGd823IDzAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAog683+Lt8ONyc3pklL/3
# cmbYMuRCdWKuh+vy1dneVrOfzM4UKLkNl2BcEkxY5NM9g0lFWJc1aRqoR+pWxnmr
# EthngYTffwk8lOa4JiwgvT2zKIn3X/8i4peEH+ll74fg38FnSbNd67IJKusm7Xi+
# fT8r87cmNW1fiQG2SVufAQWbqz0lwcy2f8Lxb4bG+mRo64EtlOtCt/qMHt1i8b5Q
# Z7dsvfPxH2sMNgcWfzd8qVttevESRmCD1ycEvkvOl77DZypoEd+A5wwzZr8TDRRu
# 838fYxAe+o0bJW1sj6W3YQGx0qMmoRBxna3iw/nDmVG3KwcIzi7mULKn+gpFL6Lw
# 8jCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA8N0wDQYJKoZIhvcNAQELBQAw
# cjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVk
# IElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEwMDAwMDBaFw0zMTAxMDYwMDAw
# MDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEgMB4G
# A1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR1zoRQr0KdXVNlLQMULUmEP4d
# yG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZqgfop+N0rcIXeAhjzeG28ffnH
# bQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj4S8bOrdh1nPsTm0zinxdRS1L
# sVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s1SPa9E14RuMDgzEpSlwMMYpK
# jIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDCm2mCtNv8VlS8H6GHq756Wwog
# L0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0BAgMBAAGjggG4MIIBtDAOBgNV
# HQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcGCCsGAQUFBwIBFhtodHRwOi8v
# d3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgwFoAU9LbhIB3+Ka7S5GGlsqIl
# ssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1ENt3janq8MHEGA1UdHwRqMGgw
# MqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtdHMu
# Y3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVk
# LXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURUaW1lc3RhbXBpbmdDQS5jcnQw
# DQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrnIA6OZ0b9QnJRdAojR6OrktIl
# xHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3taaQP9rhwz2Lo9VFKeHk2eie3
# 8+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2NfI1Jpg4L6GlPtkMyNoRdzDfTz
# ZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDhXM/EEXLnG2RJ2CKadRVC9S0y
# OIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9bm/cuG08THfdKDXF+l7f0P4Tr
# weOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5NpjhyyjaW4emii8wggUwMIIEGKADAgEC
# AhAECRgbX9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEw
# MjIxMjAwMDBaFw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNV
# BAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7
# RZmxOttE9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p
# 0WfTxvspJ8fTeyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj
# 6YgsIJWuHEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grk
# V7tKtel05iv+bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHy
# DxL0xY4PwaLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMB
# AAGjggHNMIIByTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjAT
# BgNVHSUEDDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCB
# gQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgG
# CmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQu
# Y29tL0NQUzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1
# DlgwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQEL
# BQADggEBAD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q
# 3yBVN7Dh9tGSdQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/
# kLEbBw6RFfu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dc
# IFzZcbEMj7uo+MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6
# dGRrsutmQ9qzsIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT
# +hKUGIUukpHqaGxEMrJmoecYpJpkUe8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHk
# Bdo2l8IVMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMT
# G0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0z
# MTAxMDcxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0
# IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQC90DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5
# fU1ofue2oPSNs4jkl79jIZCYvxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb
# 6+NGRwYaVX4LJ37AovWg4N4iPw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU
# 46gJcWvgzyIQD3XPcXJOCq3fQDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mI
# UF79Zm5WYScpiYRR5oLnRlD9lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfx
# FwbvPc3WTe8GQv2iUypPhR3EHTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAd
# BgNVHQ4EFgQU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SS
# y4IxLVGLp6chnfNtyA8wEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMC
# AYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5j
# cnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkw
# RzA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2lj
# ZXJ0LmNvbS9DUFMwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLp
# UYdWac3v3dp8qmN6s3jPBjdAhO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQd
# aq6Z+CeiZr8JqmDfdqQ6kw/4stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC
# 4HLHmNY8ZOUfSBAYX4k4YU1iRiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+
# tpJn+1Nhiaj1a5bA9FhpDXzIAbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6H
# USHkWGCbugwtK22ixH67xCUrRwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIv
# IjayS6JKldj1po5SMIIFPTCCBCWgAwIBAgIQBNXcH0jqydhSALrNmpsqpzANBgkq
# hkiG9w0BAQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBT
# SEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTIwMDYyNjAwMDAwMFoX
# DTIzMDcwNzEyMDAwMFowejELMAkGA1UEBhMCUEwxEjAQBgNVBAgMCcWabMSFc2tp
# ZTERMA8GA1UEBxMIS2F0b3dpY2UxITAfBgNVBAoMGFByemVteXPFgmF3IEvFgnlz
# IEVWT1RFQzEhMB8GA1UEAwwYUHJ6ZW15c8WCYXcgS8WCeXMgRVZPVEVDMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv7KB3iyBrhkLUbbFe9qxhKKPBYqD
# Bqlnr3AtpZplkiVjpi9dMZCchSeT5ODsShPuZCIxJp5I86uf8ibo3vi2S9F9AlfF
# jVye3dTz/9TmCuGH8JQt13ozf9niHecwKrstDVhVprgxi5v0XxY51c7zgMA2g1Ub
# +3tii0vi/OpmKXdL2keNqJ2neQ5cYly/GsI8CREUEq9SZijbdA8VrRF3SoDdsWGf
# 3tZZzO6nWn3TLYKQ5/bw5U445u/V80QSoykszHRivTj+H4s8ABiforhi0i76beA6
# Ea41zcH4zJuAp48B4UhjgRDNuq8IzLWK4dlvqrqCBHKqsnrF6BmBrv+BXQIDAQAB
# o4IBxTCCAcEwHwYDVR0jBBgwFoAUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHQYDVR0O
# BBYEFBixNSfoHFAgJk4JkDQLFLRNlJRmMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUE
# DDAKBggrBgEFBQcDAzB3BgNVHR8EcDBuMDWgM6Axhi9odHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcxLmNybDA1oDOgMYYvaHR0cDovL2Ny
# bDQuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwTAYDVR0gBEUw
# QzA3BglghkgBhv1sAwEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNl
# cnQuY29tL0NQUzAIBgZngQwBBAEwgYQGCCsGAQUFBwEBBHgwdjAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsGAQUFBzAChkJodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElEQ29kZVNp
# Z25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAQEAmr1s
# z4lsLARi4wG1eg0B8fVJFowtect7SnJUrp6XRnUG0/GI1wXiLIeow1UPiI6uDMsR
# XPHUF/+xjJw8SfIbwava2eXu7UoZKNh6dfgshcJmo0QNAJ5PIyy02/3fXjbUREHI
# NrTCvPVbPmV6kx4Kpd7KJrCo7ED18H/XTqWJHXa8va3MYLrbJetXpaEPpb6zk+l8
# Rj9yG4jBVRhenUBUUj3CLaWDSBpOA/+sx8/XB9W9opYfYGb+1TmbCkhUg7TB3gD6
# o6ESJre+fcnZnPVAPESmstwsT17caZ0bn7zETKlNHbc1q+Em9kyBjaQRcEQoQQNp
# ezQug9ufqExx6lHYDjGCBFwwggRYAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAv
# BgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EC
# EATV3B9I6snYUgC6zZqbKqcwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFOqihy4AlIegyleCk+zB
# Etm18uZ1MA0GCSqGSIb3DQEBAQUABIIBAG54bz+HTMF2ijpP6mLGpxEMAjw7yvik
# ukQ1SZD++8/tbNkEe6QCUErHY3MVmUXn+ePuerDfgMLT0pg+nxt2LE0M/PKJiruK
# +L60/jbS1SP81A9RZ6zj5sOUshKvycQO/CVOBX2eNQ4gQC2aDi6DqAs3dsOay33M
# YeG3QuIzX/6gKX23TwLTViPfVTMzIgybTZny8pvwhXgpqIwkXy8BJ2j2GQyjtXoJ
# b1yfONILLRb8AE8+0Yu042cp9I0ZAa2neV+TJ/dl5ivLLaNYsGWs2r3bPMgVRpeo
# VC+aFVN2P/1lAH4C/caY2kJqiJCvdPHxaW97xr+zT2a8t7HhbV4+m9qhggIwMIIC
# LAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8G
# A1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQ
# DUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzEL
# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDQwMjA3MDQxNFowLwYJKoZI
# hvcNAQkEMSIEIM/FA42QFgzxlZhHii3dVfdecZMJwydb0/IrZLY4pdlzMA0GCSqG
# SIb3DQEBAQUABIIBAEWB37quaiK1qhMg9ir+efnuJK4KE/x4+cvxxjiGAwbaez5h
# h5Z9ST+5e1N92z7iZQ41hgVpdQAoHYp6kRHwX+/XRe5U3dALuatmJA6ugug3FXxO
# qtnQSlyiKpe+7r6iSTUUagKA3c+GDeks+HyVPM9p2tIyfpBxxG72i+1lDMjLbCZs
# ErvpLBU7ztAq+op4Jyyy0l1V81Z5D8iNAENrLHsKVxn3MTplWoFypgYAwrCGGF5c
# kzS5uek5fZa68m9zxpCw9qzOADNyb++tbeo8F/GCfOlZjn5UqoRRsVFYG+zhKK+e
# 5Bf5adTU/7MQIXfX0k/kqyTMiDYaBPFa4cTiAss=
# SIG # End signature block
