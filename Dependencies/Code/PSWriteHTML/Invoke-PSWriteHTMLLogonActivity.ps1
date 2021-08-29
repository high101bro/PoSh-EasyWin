function script:Invoke-PSWriteHTMLLogonActivity {
    param(
        $InputData = $null
    )

    $LogonActivityTimeStampDaySortDay   = $InputData | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}} | Group-Object TimeStampDay | Sort-Object Name, Count
    $LogonActivityTimeStampDaySortCount = $InputData | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}} | Group-Object TimeStampDay | Sort-Object Count, Name
    $LogonActivityLogonType             = $InputData | Select-Object LogonType | Group-Object LogonType | Sort-Object Count, Name
    $LogonActivityWorkstationName       = $InputData | Select-Object WorkstationName | Where-Object {$_.WorkStationName -ne '' -and $_.WorkStationName -ne '-'} | Group-Object WorkstationName | Sort-Object Count, Name
    $LogonActivitySourceNetworkAddress  = $InputData | Select-Object SourceNetworkAddress | Where-Object {$_.SourceNetworkAddress -ne '' -and $_.SourceNetworkAddress -ne '-'} | Group-Object SourceNetworkAddress | Sort-Object Count, Name
    $LogonActivityTimeStampLogonLocalSystem   = $InputData | Where-Object LogonType -eq LocalSystem | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonInteractive   = $InputData | Where-Object LogonType -eq Interactive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonNetwork       = $InputData | Where-Object LogonType -eq Network | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
        #very noisy
    $LogonActivityTimeStampLogonBatch         = $InputData | Where-Object LogonType -eq Batch | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonService       = $InputData | Where-Object LogonType -eq Service | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonUnlock        = $InputData | Where-Object LogonType -eq Unlock | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonNetworkClearText    = $InputData | Where-Object LogonType -eq NetworkClearText | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonNewCredentials      = $InputData | Where-Object LogonType -eq NewCredentials | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonRemoteInteractive   = $InputData | Where-Object LogonType -eq RemoteInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonCachedInteractive   = $InputData | Where-Object LogonType -eq CachedInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonCachedRemoteInteractive   = $InputData | Where-Object LogonType -eq CachedRemoteInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonCachedUnlock              = $InputData | Where-Object LogonType -eq CachedUnlock | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count

    New-HTMLTab -Name 'Logon Activity' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Logon Type 3 (Network) have been excluded due to excessive logs. (i.e. remote connection to shared folder)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Pane Search' -IconSolid th {
            New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Logon Type 3 (Network) have been excluded due to excessive logs. (i.e. remote connection to shared folder)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
            New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Logon Activity' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression                       
                New-HTMLCalendar {
                    foreach ($_ in $InputData) {
                        New-CalendarEvent -StartDate $_.TimeStamp `
                        -Title "$($_.PSComputerName) [$($_.UserAccount)] $($_.LogonType)" `
                        -Description "$($_.PSComputerName) || Account: $($_.UserAccount) || $($_.LogonType) || $($_.WorkStationName) || $($_.SourceNetworkAddress)"
                    }
                } -InitialView dayGridMonth #timeGridDay
            }
        }
        ###########
        New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
            script:Generate-TablePieBarCharts -Title "Logon Activity (Day Sort Day)" -Data $LogonActivityTimeStampDaySortDay
            script:Generate-TablePieBarCharts -Title "Logon Activity (Day Sort Count)" -Data $LogonActivityTimeStampDaySortCount
            script:Generate-TablePieBarCharts -Title "Workstation Name" -Data $LogonActivityWorkstationName
            script:Generate-TablePieBarCharts -Title "Source Network Address" -Data $LogonActivitySourceNetworkAddress
            script:Generate-TablePieBarCharts -Title "Logon Type" -Data $LogonActivityLogonType
            script:Generate-TablePieBarCharts -Title "Logon Local System" -Data $LogonActivityTimeStampLogonLocalSystem
            script:Generate-TablePieBarCharts -Title "Logon Interactive" -Data $LogonActivityTimeStampLogonInteractive
            script:Generate-TablePieBarCharts -Title "Logon Network" -Data $LogonActivityTimeStampLogonNetwork
            script:Generate-TablePieBarCharts -Title "Logon Batch" -Data $LogonActivityTimeStampLogonBatch
            script:Generate-TablePieBarCharts -Title "Logon Service" -Data $LogonActivityTimeStampLogonService
            script:Generate-TablePieBarCharts -Title "Logon Unlock" -Data $LogonActivityTimeStampLogonUnlock
            script:Generate-TablePieBarCharts -Title "Logon Network Clear Text" -Data $LogonActivityTimeStampLogonNetworkClearText
            script:Generate-TablePieBarCharts -Title "Logon New Credentials" -Data $LogonActivityTimeStampLogonNewCredentials
            script:Generate-TablePieBarCharts -Title "Logon Remote Interactive" -Data $LogonActivityTimeStampLogonRemoteInteractive
            script:Generate-TablePieBarCharts -Title "Logon Cached Interactive" -Data $LogonActivityTimeStampLogonCachedInteractive
            script:Generate-TablePieBarCharts -Title "Logon Cached Remote Interactive" -Data $LogonActivityTimeStampLogonCachedRemoteInteractive
            script:Generate-TablePieBarCharts -Title "Logon Cached Unlock" -Data $LogonActivityTimeStampLogonCachedUnlock
        }
    }
}