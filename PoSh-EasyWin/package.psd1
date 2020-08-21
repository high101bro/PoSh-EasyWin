@{
        Root = 'c:\Users\Dan\Documents\GitHub\PoSh-EasyWin\PoSh-EasyWin\PoSh-EasyWin(WPF).ps1'
        OutputPath = 'c:\Users\Dan\Documents\GitHub\PoSh-EasyWin\PoSh-EasyWin\out'
        Package = @{
            Enabled = $true
            Obfuscate = $false
            HideConsoleWindow = $false
            DotNetVersion = 'v4.6.2'
            FileVersion = '1.0.0'
            FileDescription = ''
            ProductName = ''
            ProductVersion = ''
            Copyright = ''
            RequireElevation = $false
            ApplicationIconPath = ''
            PackageType = 'Console'
        }
        Bundle = @{
            Enabled = $true
            Modules = $true
            # IgnoredModules = @()
        }
    }
    