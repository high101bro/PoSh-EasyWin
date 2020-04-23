$SysinternalsAutorunsCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "Sysinternals - Autoruns" -Icon "Info" -Message @"
+  This utility, which has the most comprehensive knowledge of auto-starting locations of any startup monitor, shows you what 
     programs are configured to run during system bootup or login, and when you start various built-in Windows applications 
     like Internet Explorer, Explorer and media players. These programs and drivers include ones in your startup folder, Run, 
     RunOnce, and other Registry keys. Autoruns reports Explorer shell extensions, toolbars, browser helper objects, Winlogon 
     notifications, auto-start services, and much more. Autoruns goes way beyond other autostart utilities.

+  Autoruns' Hide Signed Microsoft Entries option helps you to zoom in on third-party auto-starting images that have been added 
     to your system and it has support for looking at the auto-starting images configured for other accounts configured on a 
     system. Also included in the download package is a command-line equivalent that can output in CSV format, Autorunsc.

+  Usage
     - Simply run Autoruns and it shows you the currently configured auto-start applications as well as the full list of Registry 
     and file system locations available for auto-start configuration. Autostart locations displayed by Autoruns include logon 
     entries, Explorer add-ons, Internet Explorer add-ons including Browser Helper Objects (BHOs), Appinit DLLs, image hijacks, 
     boot execute images, Winlogon notification DLLs, Windows Services and Winsock Layered Service Providers, media codecs, and 
     more. Switch tabs to view autostarts from different categories.

     - To view the properties of an executable configured to run automatically, select it and use the Properties menu item or 
     toolbar button. If Process Explorer is running and there is an active process executing the selected executable then the 
     Process Explorer menu item in the Entry menu will open the process properties dialog box for the process executing the 
     selected image.

     - Navigate to the Registry or file system location displayed or the configuration of an auto-start item by selecting the item 
     and using the Jump to Entry menu item or toolbar button, and navigate to the location of an autostart image.

     - To disable an auto-start entry uncheck its check box. To delete an auto-start configuration entry use the Delete menu item 
     or toolbar button.

     - The Options menu includes several display filtering options, such as only showing non-Windows entries, as well as access 
     to a scan options dialog from where you can enable signature verification and Virus Total hash and file submission.

     - Select entries in the User menu to view auto-starting images for different user accounts.

+  https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns
"@  
}
