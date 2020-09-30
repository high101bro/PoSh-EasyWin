<#
    .Synopsis
    This is an example script of what you can send to accompany an executable
    You can installed sofware, conduct tasks
    This script is not actually copied to the endpoint(s), rather is being executed by:
        Invoke-Command -FilePath 'C:\Path\Selected\To\Script.ps1' -ComputerName <FromComputerTreeview>
    Note that if you use this method to launch an interactive executable... PoSh-EasyWin will hang as you can not interact with it
#>

# Example code, you can include variables, functions, aliases... pretty much anything normally allowed
$Directory = 'c:\windows\temp'
cd $Directory

function ExampleFunction {
    param($Dir)
    systeminfo | out-file "$Dir\systeminfo.txt"
}
ExampleFunction -Dir $Directory

# Results are saved at the endpoint(s), you can use the 'Retreive Files' button to pull back files if desired
# Files copied or producted on the endpoint(s) have to be manually cleaned up or scripted
get-process | export-csv c:\windows\temp\processes.csv -notype

# You can use cmd.exe's command switch ('/c')
cmd /c netstat > .\netstat.txt

# You can use the call operator ('&')
& c:\windows\system32\notepad.exe

# The -FilePath specified needs to match that of the 'Destination Directory' field
# Keep in mind that if you transfer a whole directory, you need to account for the folder name... in this example: 'User Specified Executable And Script'
if (Test-Path 'c:\windows\temp\User Specified Executable And Script\procmon.exe') {
    # Used if a whole directory was sent over
    Start-Process -Filepath 'c:\windows\temp\User Specified Executable And Script\procmon.exe' -ArgumentList @("/AcceptEULA /BackingFile c:\windows\temp\procmon /RunTime 5 /Quiet")
}
if (Test-Path 'c:\windows\temp\procmon.exe') {
    # Used if just an executable file was sent over
    Start-Process -Filepath 'c:\windows\temp\procmon.exe' -ArgumentList @("/AcceptEULA /BackingFile c:\windows\temp\procmon /RunTime 5 /Quiet")

}




