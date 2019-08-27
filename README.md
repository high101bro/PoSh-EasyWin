PowerShell-Analyst's Collection Made Easy (ACME) for Security Professionals. 
ACME: The point at which something is the Best, Perfect, or Most Successful! 

File Name      : PoSh-ACME.ps1
Version        : v.3.5 Beta

Author         : high101bro
Email          : high101bro@gmail.com
Website        : https://github.com/high101bro/PoSH-ACME

Requirements   : PowerShell v3 or Higher
               : WinRM and/or DCOM/RPC
Optional       : PSExec.exe, Procmon.exe, Autoruns.exe 
               : Can run standalone, but works best with the Resources folder!
Updated        : 25 Aug 19
Created        : 21 Aug 18

![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot001.jpg)
PoSh-ACME is a tool that allows you to run any number of queries against any number of hosts. The queries primarily consist of one liner commands, but several are made of scripts that allows for more comprehensive results. PoSh-ACME consists of queries speicific for endpoiint hosts and servers in an Active Directory domain. It allows you to easily query event logs from multiple sources within specified date ranges; query for filenames, parts of filenames, file hashes in any number of specified directores at any recursion depth; query for network connections by IP addresses, ports, and connetions started by specified process names. 


Solarized dark             |  Solarized Ocean
:-------------------------:|:-------------------------:
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot002.jpg)  |  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot016.jpg)
Queries are organized and displayed by Method and Commands. The Method view displays queries nested within RPC or WinRM categories followed by they type of command. The Commands view displays queries by they type of commands, with the RPC/WinRM command types nested within. For ease of viewing, commands and their category are highlighted blue when selected, and also maintain selection when changing between views. Selecting commands and endpoints by way of a simple checkbox clicks has the benefit of preventing errors on commandline and increase the speed of querying for data. A preview of the command is provided as queries are hovered over to provide the user with a basic understanding of what is being executed. Category checkboxes allows for all sub-checkboxes to automatiicaly be checked. You can use the search feature to find commands by full or partial name, and even by tags.

If the Resource folder is present, it adds additional functionality. Such as the ability to select ports/protocols or Event IDs from a GUI rather than memorizing them all or looking them up externally. It also allows you to now push various Sysinternals tools to remote hosts and pull back data for analysis (procmon & autoruns); moreover, you can install sysmon to selected endpoints with XML configurations. 

Queries are returned in a csv format for easy review and can be viewed with PowerShell's native Out-GridView - no need for 3rd party software like Microsoft Excel. Query results are saved in datetime folders by each query name, and are both stored individually by hosts as well as compiled all together. Certain common queres, like processes, can have their results viewed with PowerShell charts automatically. You can also explore data and build your own charts manually. Both features allow you simple save the chart as an image with a simple push of a button, or if you go to the Options tab you can select where they are saved automatically. These charts can provide easy view of baseline, previous, and most recent query results.  

Unlike many other scripts that execute serially, PoSh-ACME executes its queries multi-threaded as Jobs (up to 32 at a time by default). This prevents the script from hanging if one query or host is unresponsive. Additionly, there are two progress bars provided: 1) The Section progress bar shows the status of the number of endpoints that have completed a given query while 2) the Overall progress bar shows the status how many queries have been completed altogether. It is recommended that you don't run excessive queries against excessive number of endpoints. Aside from poor tradecraft, excessive queries can take a long time to process.

Queries can be executed as separate commands or compiled together. When executed separately the progress bars function as normal and provide an easy to view indicate of the PoSh-ACME's status. Remember that these commands are threaded as jobs which requires the host to spin up multiple PowerShell's (more memory intensive) to execute each command to each host (more individual network connections). Results are returned immedately for each host and endpoint though, and if an error occurs you don't lose all the data. Lastly, queries executed individual take longer to collect data, as new instances of PowerShell are spun up for each query and endpoint.  If the the commands are compiled together and executed, only one query is sent per endpoint (one PowerShell instance per host). This is substantially faster, but if for some reason if an error occurs during the remote collection, all data is lost; Lastly, the progress bars are not as effective as there is no way to monitor each queries completion, so you wont' konw when a larger compiled query is finished until it's finished.

The computers tree view displays the computers either by Operating Systems (OS) or Organizational Units/Cononical Names (OU/CN). You can import these computers from Active Directory, from a list in a text file, from the Enumerations section, or just manually add them. 1) When importing from Active Directory, use the following command (Get-ADComputer -Filter * -Properties "Name","OperatingSystem","CanonicalName","IPv4Address","MACAddress" | Export-Csv .\AD_Computers.csv -NoTypeInformation). If you get too few/many properties, PoSh-ACME will automatically adjust when it formats its 'Computer List TreeView (Saved).csv' file. This file not only saves this basic data about each host, but also all notes manually entered per host wihtin PoSh-ACME. 2) When importing list from a text file, format the file so that there is one hostname per line. If you include IP address, you're mileage will vary and queries may not work as expected (the reason why is beyond the scope of this document). It is recommended to use hostname's within the domain when making queries. When data is imported from a text file, the hostnames will show up with Unknown OS's and OU/CN's, to which you can manually edit if desired. 3) Importing from the Enumeration tab functions similarly as the importing from text file, but hostnames are obtainsed from either pinging or port scanning the network for hosts, then resolving their names to hostnames. 4) Lastly, you can manually add endpoints with the Add button in the Manage List tab. This allows you to initially enter a name, Operating System, and Organizational Unit/Canonical Name. -- The computer tree view can be managed via the Manage List tab, where you can Deselect All, Collapse/Exapnd the treeview, Import .csv, Import .txt, Add, Delete, Move, Rename, and Save. Note: Any modification to the treeview is not saved automatically, this way you can revert if you make a mistake by just closing out PoSh-ACME without clicking the Save button. Conversely, if you hypothetically made a lot of changes but PoSh-ACME is closed untintentionally, you can recover as an auto-saved file is generated whenever you make any changes even if you don't save. Just manually delete/rename "Computer List TreeView (Saved).csv", then launch PoSh-ACME and import the "Computer List TreeView (Auto-Save).csv" version... [To Do: Add feature to create loading of separate files....]

You can view individual endpoint data and notes by selecting the Host Data tab. ....

Other add-on features includes a spread
of external applications like various Sysinternals tools, and basic reference info
for quick use when not on the web.

As the name indicates, PoSh-ACME is writen in PowerShell. The GUI utilizes the .net 
frame work to access Windows built using Windows Presentation Framework (WPF).





![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot003.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot004.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot005.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot006.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot007.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot008.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot009.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot010.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot011.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot012.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot013.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot014.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot015.jpg)




![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot017.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot018.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot019.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot020.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot021.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot022.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot023.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot024.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot025.jpg)


![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot026.jpg)



















