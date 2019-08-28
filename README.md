# PoSh-ACME
#### PowerShell-Analyst's Collection Made Easy (ACME) for Security Professionals.
#### ACME: The point at which something is the Best, Perfect, or Most Successful! 

|                |                                                                 |
|:---------------|:----------------------------------------------------------------|
|  File Name     |  PoSh-ACME.ps1                                                  |
|  Version       |  v.3.5 Beta                                                     |
|  Author        |  high101bro                                                     |
|  Email         |  high101bro@gmail.com                                           |
|  Website       |  https://github.com/high101bro/PoSH-ACME                        |
|  Requirements  |  PowerShell v3 or Higher                                        |
|                |  WinRM and/or DCOM/RPC                                          |
|  Optional      |  PSExec.exe, Procmon.exe, Autoruns.exe                          |
|                |  Can run standalone, but works best with the Resources folder!  |
|  Updated       |  25 Aug 19                                                      |
|  Created       |  21 Aug 18                                                      |

***
***
### Executing Queries

![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot001.jpg)
PoSh-ACME is a tool that allows you to run any number of queries against any number of hosts. The queries primarily consist of one liner commands, but several are made of scripts that allows for more comprehensive results. PoSh-ACME consists of queries speicific for endpoiint hosts and servers in an Active Directory domain. It allows you to easily query event logs from multiple sources within specified date ranges; query for filenames, parts of filenames, file hashes in any number of specified directores at any recursion depth; query for network connections by IP addresses, ports, and connetions started by specified process names. 

***
***
### Query Selection Features

|![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot002.jpg)  |  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot016.jpg)|
|:-----------------:|:--------------------:|
|  Command Preview  |  Query Highlighting  |

Queries are organized and displayed by Method and Commands. The Method view displays queries nested within RPC or WinRM categories followed by they type of command. The Commands view displays queries by they type of commands, with the RPC/WinRM command types nested within. For ease of viewing, commands and their category are highlighted blue when selected, and also maintain selection when changing between views. Selecting commands and endpoints by way of a simple checkbox clicks has the benefit of preventing errors on commandline and increase the speed of querying for data. A preview of the command is provided as queries are hovered over to provide the user with a basic understanding of what is being executed. Category checkboxes allows for all sub-checkboxes to automatiicaly be checked. You can use the search feature to find commands by full or partial name, and even by tags.

***
***
### Resource Files

|  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot027.jpg)  |  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot006.jpg)  |
|:-----------------------------:|:-----------------------------:|
|  Suports VariosLookup Tables  |  Sysinternals Tools Provided  |

If the Resource folder is present, it adds additional functionality. Such as the ability to select ports/protocols or Event IDs from a GUI rather than memorizing them all or looking them up externally. It also allows you to now push various Sysinternals tools to remote hosts and pull back data for analysis (procmon & autoruns); moreover, you can install sysmon to selected endpoints with XML configurations. Other items of interest in the Resource folder is the PoSh-ACME Icon; the Checklist, Processes, adn About tabs, and tags.

***
***
### Query Results
##### Easy to view with no external dependencies
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot021.jpg)
Queries are returned in a csv format for easy review and can be viewed with PowerShell's native Out-GridView - no need for 3rd party software like Microsoft Excel. Query results are saved in datetime folders by each query name, and are both stored individually by hosts as well as compiled all together. 

***
***
### PowerShell Charts
|  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot019.jpg)  |  ![Alt text]('https://github.com/high101bro/PoSH-ACME/blob/master/Images/Processes Donut.PNG')  |  ![Alt text]('https://github.com/high101bro/PoSH-ACME/blob/master/Images/Processes WorkingSet Size.PNG')  |
|:-------------------------:|:---------------------------:|:--------------------------------:|
| Example of an AutoChart  |  Build Your Own Donut   |  Build Your Own Graph  |

Certain common queres, like processes, can have their results viewed with PowerShell charts automatically. You can also explore data and build your own charts manually. Both features allow you simple save the chart as an image with a simple push of a button, or if you go to the Options tab you can select where they are saved automatically. These charts can provide easy view of baseline, previous, and most recent query results.  

***
***
### Multi-Threaded
##### Faster! Don't be hindered with unresponsive hosts.
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot018.jpg)
Unlike many other scripts that execute serially, PoSh-ACME executes its queries multi-threaded as Jobs (up to 32 at a time by default). This prevents the script from hanging if one query or host is unresponsive. Additionly, there are two progress bars provided: 
1. The <b>Section</b> progress bar shows the status of the number of endpoints that have completed a given query while 
2. The <b>Overall</b> progress bar shows the status how many queries have been completed altogether. It is recommended that you don't run excessive queries against excessive number of endpoints. Aside from poor tradecraft, excessive queries can take a long time to process.

***
***
### Execute Queries Separately or Compiled Together
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot026.jpg)
Queries can be executed as separate commands or compiled together. When executed separately the progress bars function as normal and provide an easy to view indicate of the PoSh-ACME's status. Since these commands are threaded as jobs which requires the host to spin up multiple PowerShell's (more memory intensive) to execute each command to each host (more individual network connections). Results are returned immedately for each host and endpoint though, and if an error occurs you don't lose all the data. Lastly, queries executed individual take longer to collect data, as new instances of PowerShell are spun up for each query and endpoint.  If the the commands are compiled together and executed, only one query is sent per endpoint (one PowerShell instance per host). This is substantially faster, but if for some reason if an error occurs during the remote collection, all data is lost; Lastly, the progress bars are not as effective as there is no way to monitor each queries completion, so you wont' konw when a larger compiled query is finished until it's finished.

***
***
### Computer TreeView

|  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot010.jpg)  |  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot011.jpg)  |  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot017.jpg)  |
|:-------------------------:|:---------------------------:|:--------------------------------:|
| View by Operating System  |  View by Organization Unit  |  Ability to Checkbox Categories  |

The computers tree view displays the computers either by Operating Systems (OS) or Organizational Units/Cononical Names (OU/CN). You can import these computers from Active Directory, from a list in a text file, from the Enumerations section, or just manually add them. 
1. When importing from Active Directory, use the following command (Get-ADComputer -Filter * -Properties "Name","OperatingSystem","CanonicalName","IPv4Address","MACAddress" | Export-Csv .\AD_Computers.csv -NoTypeInformation). If you get too few/many properties, PoSh-ACME will automatically adjust when it formats its 'Computer List TreeView (Saved).csv' file. This file not only saves this basic data about each host, but also all notes manually entered per host wihtin PoSh-ACME. 
2.) When importing list from a text file, format the file so that there is one hostname per line. If you include IP address, you're mileage will vary and queries may not work as expected (the reason why is beyond the scope of this document). It is recommended to use hostname's within the domain when making queries. When data is imported from a text file, the hostnames will show up with Unknown OS's and OU/CN's, to which you can manually edit if desired. 
3. Importing from the Enumeration tab functions similarly as the importing from text file, but hostnames are obtainsed from either pinging or port scanning the network for hosts, then resolving their names to hostnames. 
4. Lastly, you can manually add endpoints with the Add button in the Manage List tab. This allows you to initially enter a name, Operating System, and Organizational Unit/Canonical Name. 

***
***
### Managing Computer Treeview
![Alt Text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot015.jpg)
The computer treeview can be managed via the Manage List tab, where you can conduct the following actions: Deselect All, Collapse/Exapnd the treeview, Import .csv, Import .txt, Add, Delete, Move, Rename, and Save.
1) <b>Deselect All</b> - This butt
2) <b>Collapse/Expand</b> - 
3) <b>Import .csv</b> - This button allows you to import endpoint names from a csv file. The file's needs to have one endpoint name per line under a 'Name" header field to be read in properly. Supported fields are: "Name", "OperatingSystem", "CanonicalName", "IPv4Address", "MACAddress", and "Notes" - any addtional fields will be automatically purged. PoSh-ACME prevents you from entering duplicate endpoint names, and notifies you of the existing endpoints OS and OU/CN.
4) <b>Import .txt</b> - This button allows you to import endpoint names from a txt file. The file's needs to have one endpoint name per line to be read in properly. The endpoints ingested will not contain OS or OU/CN metadata and will be placed within Unknown categories. They can be moved afterwareds to their proper categories with the move button. PoSh-ACME prevents you from entering duplicate endpoint names, and notifies you of the existing endpoints OS and OU/CN.
5) <b>Add</b> - This button allows you to manually ad an enpoint to the computer treeview. You can either select existing OS or OU/CN categories, which auto-populte, or enter new names. PoSh-ACME prevents you from entering duplicate endpoint names, and notifies you of the existing endpoints OS and OU/CN.
6) <b>Delete</b> - This button will delete one ore more endpoints. If a category no longer contains an endpoint after deletion, it will be automatically removed.
7) <b>Move</b> - This button will move one or more endpoints between categories. Depending on the treeview, OS or OU/CN, it will move endpoints under a different Operating System or Organizational Unit/Canonical Name categories. You can select a category checkbox to move all endpoints contained within. If a category no longer contains an endpoint after they're moved, it will be automatically removed. If you move an endpoint to a non-existing category, it will be automatically moved to an Unknown category.
8) <b>Rename</b> - This button renames a single endpoint name. Currently, there is no way to rename a category as it automatically selects all endoints within, thus it would attempt to rename all of them which is not permitted. There are two work arounds for this: 9) Close PoSh-ACME and modify the CSV file namually, or 2) Add a new endpoint, and enter a custom/New OS or OU/CN name, then move the endpoint over.
10) <b>Save</b> - This button saves the Computer TreeView, allowing it to be loaded automatically upon the next time PoSh-ACME is started. The save button within the Host Data tab will both save the contents of the notes and the treeview state.
    - <b>Note:</b> Any modification to the treeview is not saved automatically, this way you can revert if you make a mistake by just closing out PoSh-ACME without clicking the Save button. Conversely, if you hypothetically made a lot of changes but PoSh-ACME is closed untintentionally, you can recover as an auto-saved file is generated whenever you make any changes even if you don't save. Just manually delete/rename "Computer List TreeView (Saved).csv", then launch PoSh-ACME and import the "Computer List TreeView (Auto-Save).csv" version... (To Do: Add feature to create loading of separate files) 

***
***
### Operator Notes (OpNotes) and Logs
##### Efficiently take notes and track your actions on endpoints.

|  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot008.jpg)  |  ![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/Log File.jpg)  |
|:-----------------------------:|:-----------------------------:|
|  OpNotes  |  Log File  |

An <b>OpNote</b> is information that the operator considers to be of particular interest to note. They can be typed in manually, selectively imported from query results when viewed or from the Results panel. OpNotes that are entered are automaticlly prepended with a timestamp. The notes field auto-magically expands and shirts when hovered over to make quick review simple, though you can open the OpNotes file directly if desired with external applications. OpNotes are automatically saved to 'OpNotes.txt' when entered, moved, or deleted. The 'OpNotes (Write Only).txt' file contains all notes added in the order they were entered; this is useful if you accidentally remove/delete entries. The following are buttons used to assist with OpNotes.
1) <b>Add</b> - This button manally adds messages and are prepended with a datetime group that you type into the OpNotes input field at the top. Alternatively you can press the enter key to add notes which is arguably faster. Note that you cannot enter blank entries, if you do want to though, you will have to at least enter a space bar entry. 
2) <b>Remove</b> - This button removes/deletes one or more selected notes. The notes can be selected in any order and/or be within a selected range. Though automatically removed from the 'OpNotes.txt ', they will remain in the 'OpNotes (Write Only).txt' file.
3) <b>Select All</b> - This button selects all lines of the OpNotes.
4) <b>Create Report</b> - This button creates a report from selected lines of notes. This is useful if you want to extact and save only certain information for easy note management or passing along to another individual. The file is saved to the Reports directory where PoSh-ACME is located.
5) <b>Open Reports</b> - This button opens the directory where the Reports are saved. You can then open the text file with any external applications such as notepad, wordpad, or MicrSoft Docs.
6) <b>Open OpNotes</b> - This button directly opens the 'OpNotes.txt' file with the systems default application, which is most often notepad.
7) <b>Move up</b> - This button moves up on or more selected lines of OpNotes. The notes can be selected in any order and/or be within a selected range. When notes are moved, the datetimes remain. When notes are moved, the datetimes remain unchanged.
8) <b>Move Down</b> - This button moves down on or more selected lines of OpNotes. The notes can be selected in any order and/or be within a selected range. When notes are moved, the datetimes remain unchanged.

The <b>Log File</b> differ from OpNotes by automatically logging actions conducted with PoSh-ACME. This is useful to help determine what action were or were not conducted though PoSh-ACME. Actions logged include such things as the lauching PoSh-ACME, each query conducted against each endpoint, Job execution/completion, the use of Sysinternals tools within PoSh-ACME, and activity conducted with endpoint enumeration scans. This section will continue to develop as more relavant data is identified to log.

***
***
### Host Data Management and Notes
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot012.jpg)
You can view individual endpoint data and notes by selecting the Host Data tab. ....



Reference Material

Checklists


As the name indicates, PoSh-ACME is writen in PowerShell. The GUI utilizes the .net 
frame work to access Windows built using Windows Presentation Framework (WPF).

![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot003.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot004.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot005.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot007.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot009.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot013.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot014.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot020.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot022.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot023.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot024.jpg)
![Alt text](https://github.com/high101bro/PoSH-ACME/blob/master/Images/ScreenShot025.jpg)
