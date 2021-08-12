<#
MRU is the abbreviation for most-recently-used.

This key maintains a list of recently opened or saved files via Windows Explorer-style dialog boxes (Open/Save dialog box).
For instance, files (e.g. .txt, .pdf, htm, .jpg) that are recently opened or saved files from within a web browser are maintained.

Documents that are opened or saved via Microsoft Office programs are not maintained.
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU

<#
Whenever a new entry is added to OpenSaveMRU key, registry value is created or updated in
This key correlates to the previous OpenSaveMRU key to provide extra information: each binary registry value under this key contains
a recently used program executable filename, and the folder path of a file to which the program has been used to open or save it.
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedMRU

<#
The list of files recently opened directly from Windows Explorer are stored into
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

<#
This key corresponds to %USERPROFILE%Recent (My Recent Documents) and contains local or network files that are recently opened and only the filename in binary form is stored.
Start>Run
The list of entries executed using the Start>Run command in mantained in this key:
If a file is executed via Run command, it will leaves traces in the previous two keys OpenSaveMRU and RecentDocs.
Deleting the subkeys in RunMRU does not remove the history list in Run command box immediately.
Content of RunMRU Key
By using Windows “Recent Opened Documents" Clear List feature via Control Panel>Taskbar and Start Menu, an attacker can remove the Run command history list.
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU

<#
Pagefile
This key maintains the configuration of Windows virtual memory: the paging file (usually C:pagefile.sys) may contain evidential information that could be
removed once the suspect computer is shutdown.
This key contains a registry value called ClearPagefileAtShutdown which specify whether Windows should clear off the paging file when the computer shutdowns
(by default, windows will not clear the paging file).
During a forensic analysis you should check this value before shutting down a suspect computer!
#>

Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management

<#
This key contains recent search terms using Windows default search.
There may be up to four subkeys:
    5001: Contains list of terms used for the Internet Search Assistant
    5603: Contains the list of terms used for the Windows files and folders search
    5604: Contains list of terms used in the “word or phrase in a file" search
    5647: Contains list of terms used in the “for computers or people" search
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Search Assistant\ACMru


<#
Mounted drives
The list of mounted devices, with associated persistent volume name and unique internal identifier for respective devices is contained into

This key lists any volume that is mounted and assigned a drive letter, including USB storage devices and external DVD/CDROM drives.
From the listed registry values, value’s name that starts with “DosDevices" and ends with the associated drive letter, contains information
regarding that particular mounted device.

#>
Get-ItemProperty -Path HKLM:\SYSTEM\MountedDevices



<#
Similar informations on mounted devices are contained also in

which is located under the respective device GUID subkey and in the binary registry value named Data.
This key is a point of interest during a forensic analysis: the key records shares on remote systems such C$, Temp$, etc.
The existence of ProcDump indicates the dumping of credentials within lsass.exe address space. Sc.exe indicates the adding
of persistence such as Run keys or services. The presence of .rar files may indicate data exfiltration.
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\CPCVolume

<#
The history of recent mapped network drives is store into
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU


<#
In addition, permanent subkey (unless manually removed from registry) regarding mapped network drive is also created in
and the subkey is named in the form of ##servername#sharedfolder.
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Current\VersionExplorer\MountPoints2


<#
Debugging
This key allows administrator to map an executable filename to a different debugger source, allowing user to debug a program using a different program:
Modification to this key requires administrative privilege.
This feature could be exploited to launch a completely different program under the cover of the initial program.
#>
Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options

<#
File extensions
This key contains instruction to execute any .exe extension file:


Normally, this key contains one default value with data “%1" %*, but if the value’s data is changed to something similar to somefilename.exe “%1" %* , investigator should suspect some other hidden program is invoked automatically when the actual .exe file is executed.

Malware normally modify this value to load itself covertly

This technique apply to other similar keys, including:

HKEY_CLASSES_ROOT\batfile\shell\open\command
HKEY_CLASSES_ROOT\comfile\shell\open\command
#>
Get-ItemProperty -Path HKCR:\exe\fileshell\opencommand


<#
Windows Protect Storage
Protected Storage is a service used by Microsoft products to provide a secure area to store private information.
Information that could be stored in Protected Storage includes for example Internet Explorer AutoComplete strings and passwords, Microsoft Outlook and Outlook Express accounts’ passwords.
Windows Protected Storage is maintained under this key:

Registry Editor hides these registry keys from users viewing, including administrator.
There are tools that allow examiner to view the decrypted Protected Storage on a live system, such as Protected Storage PassView and PStoreView.
#>
Get-ItemProperty -Path HKCU:\Software\Microsoft\Protected Storage System Provider

<#

#>
Get-ItemProperty -Path

<#

#>
Get-ItemProperty -Path

<#

#>
Get-ItemProperty -Path

<#

#>
Get-ItemProperty -Path





