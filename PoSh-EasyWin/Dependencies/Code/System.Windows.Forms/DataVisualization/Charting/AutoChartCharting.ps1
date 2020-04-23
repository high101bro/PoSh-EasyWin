$AutoChartChartingAdd_MouseEnter = {
    $script:AutoChartsOptionsButton.Text = 'Options v'
    $script:AutoChartCharting.Controls.Remove($script:AutoChartsManipulationPanel)
}
