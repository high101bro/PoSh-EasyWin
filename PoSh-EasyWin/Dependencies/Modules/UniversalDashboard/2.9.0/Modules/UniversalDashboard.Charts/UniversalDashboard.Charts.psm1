
if ($Env:DebugCharts -eq $true) {
    $AssetId = [UniversalDashboard.Services.AssetService]::Instance.RegisterAsset("http://localhost:10000/udcharts.bundle.js")
    [UniversalDashboard.Enterprise.NewNivoChartCommand]::AssetId = $AssetId
} else {
    $JsFile = Get-ChildItem "$PSScriptRoot\udcharts.*.bundle.js"
    $AssetId = [UniversalDashboard.Services.AssetService]::Instance.RegisterAsset($JsFile.FullName)
    [UniversalDashboard.Enterprise.NewNivoChartCommand]::AssetId = $AssetId
}

function New-UDNivoTheme {
    param(
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$TickLineColor,
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$TickTextColor,
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$GridLineStrokeColor,
        [Parameter()]
        [int]$GridStrokeWidth
    )

    @{
        axis = @{
            ticks = @{
                line = @{
                    stoke = $TickLineColor.HtmlColor
                }
                text = @{
                    fill = $TickTextColor.HtmlColor
                }
            }
        }
        grid = @{
            line = @{
                stroke = $GridLineStrokeColor.HtmlColor
                strokeWidth = $GridStrokeWidth
            }
        }
    }
}

function New-UDSparklines {
    param(
        [Parameter()]
        [string]$Id = (New-Guid).ToString(),
        [Parameter(Mandatory)]
        [float[]]$Data,
        [Parameter()]
        [ValidateSet('lines', 'bars', 'both')]
        [string]$Type = 'lines',
        [Parameter()]
        [int]$Width = 500,
        [Parameter()]
        [int]$Height = 100,
        [Parameter()]
        [int]$Margin = 10,
        [Parameter()]
        [float]$Minimum,
        [Parameter()]
        [float]$Maximum,
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$Color,
        [Parameter()]
        [Hashtable]$Style
    )

    Process {
        @{
            isPlugin = $true
            assetId = $AssetId
            data = $Data
            type = "sparklines"
            sparkType = $Type
            id = $Id
            width = $Width
            height = $Height
            margin = $Margin
            min = $Minimum
            max = $Maximum
            color = $Color
            style = $Style
        }
    }
}