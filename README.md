# PoSh-EasyWin
#### PowerShell - Endpoint Analysis Solution Your Windows Intranet Needs
#### Formerly known as: PoSh-ACME (Anayst Collection Made Easy)
|                |                                                                 |
|:---------------|:----------------------------------------------------------------|
|  File Name     |  PoSh-EasyWin.ps1                                               |
|  Version       |  v.5.1.7 Beta                                                   |
|  Author        |  Daniel Komnick (high101bro)                                    |
|  Email         |  high101bro@gmail.com                                           |
|  Website       |  https://github.com/high101bro/PoSh-EasyWin                     |
|  Requirements  |  PowerShell v3 (Ideally v5)                                     |
|                |  WinRM and/or DCOM/RPC                                          |
|  Optional      |  PSExec.exe, Procmon.exe, Autoruns.exe, Sysmon.exe              |
|                |  etl2pcapng.exe, WinPmem.exe                                    |
|                |                                                                 |
|  Updated       |  28 Nov 2020                                                    |
|  Created       |  21 Aug 2018                                                    |

***
***
### The Scope of this Tool
PoSh-EasyWin is a Graphical User Interface (GUI) that uses PowerShell with the .Net Framework to primarily query for various information from remote computers. It obtains data that is on the system 'now' without the need to install agents on remote systems. It provides a method to easily make any number of queries to any number of hosts, and maintains a local log to track when they were conducted and  to which systems. Little to no PowerShell knowledge is needed, just click on the desired queries and endpoints, then start collecting data. That said, individuals can learn PowerShell by way of viewing the automatiicaly displayed tool tips that appear over commands or by compiling and review queries before submission. 

### The goals of PoSh-EasyWin are to provide:
1. a user interface that is easy to use and intuitive.
2. easily view collected data locally via charts, spreadsheats, and by terminal.
3. an efficient method to obtain various data from remote endpoints over various protocols.
4. visiblity into many common commands for endpoints and active directory servers.
5. the ability to effortlessly connect to an endpoint via a Remote Desktop, PSSession, PSExec, or explore Event Logs. 
6. a method to analyze data/results from numerous systems natively without external 3rd party applications.

***
***
### Browser View - Searching, Tables, Panels, Charts, and Graphs (Beta Release)

| ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Graph02.jpg)  | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Graph04.jpg) | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Graph03-ProcessTree.jpg) | 
|:----------------------:|:-----------------:|:---------------------:|
|  Graph Node Views  |  Zoomed-in Desciptions  |  Graph & Table Combo  |
| ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Sheet01.jpg)  | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Panel01.jpg) | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Chart01.jpg) | 
|  Table Search w/ Details  |  Panel Breakout Filtering  |  Pies & Bar Charts   |

New Beta Feature (Work in Progress) - Currently refining code to best display data. Also, looking into other data that is useful to visualize in graphs. You're able to view data collected from endpoints or from Active Directory and their relationships as well as investigate more details by looking at the accompanying data within the spreadsheets in the browser. This features uses the PSWriteHTML module which can be installed separately, but a specific version has been packaged with PoSh-EasyWin that has been vetted for compatibliity.

***
***
### Monitor Jobs Tab (Beta Release)

| ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/MonitorJobs01.jpg)  | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/MonitorJobs02.jpg) | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Notify02.jpg) | 
|:----------------------:|:-----------------:|:---------------------:|
|  Monitor Jobs Compact View  |  Monitor Jobs Maximized View  |  Optional Query Notification   |

There is a new monitor jobs tab that tracks jobs with individual progress bars, while allowing you the freedom to continue using the GUI to conduct other tasks. Each progress bar also has it's own timer to see how long each task has been running or took to compelte. Queries can be cancelled and removed. You're able to click on each to view the data in progress to see what's collected as it's going and afterward completion. After completion, you're able to view the results in a PowerShell terminal, allowing you to easily manipulate the data as you see fit. Data is saved by default, but you're able to choose to not save it before removing. There is an option to select to be notified per each query, which will show a popup while your don't other tasks. There's an option to maximize the panel view to easily see more jobs - plus an auto-max feature.

***
***
### Executing Queries

![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PoSh-EasyWin_GUI.png)

PoSh-EasyWin is a tool that allows you to run any number of queries against any number of hosts. The queries primarily consist of one liner commands, but several are made of scripts that allows for more comprehensive results. PoSh-EasyWin consists of queries speicific for endpoiint hosts and servers in an Active Directory domain. It allows you to easily query event logs from multiple sources within specified date ranges; query for filenames, parts of filenames, file hashes in any number of specified directores at any recursion depth; query for network connections by IP addresses, ports, and connections started by specified process names. 

***
***
### Query Selection Features

| ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/CommandToolTip.png)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/CommandHighLighting.png) | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/CommandQueryHistory.png) |
|:-----------------:|:-------------------:|:---------------:|
|  Command Preview  |  Tree Highlighting  |  Query History  |

Queries are organized and displayed by Method and Commands. The Method view displays queries nested within RPC or WinRM categories followed by they type of command. The Commands view displays queries by they type of commands, with the RPC/WinRM command types nested within. For ease of viewing, commands and their category are highlighted blue when selected, and also maintain selection when changing between views. Selecting commands and endpoints by way of a simple checkbox clicks has the benefit of preventing errors on commandline and increase the speed of querying for data. A preview of the command is provided as queries are hovered over to provide the user with a basic understanding of what is being executed. Category checkboxes allows for all sub-checkboxes to automatiicaly be checked. You can use the search feature to find commands by full or partial name, and even by tags.

***
***
### Resource Files

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/LookupTables.png)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Sysinternals.png)  |
|:-----------------------------:|:-----------------------------:|
|  Suports VariosLookup Tables  |  Sysinternals Tools Provided  |

If the Resource folder is present, it adds additional functionality. Such as the ability to select ports/protocols or Event IDs from a GUI rather than memorizing them all or looking them up externally. It also allows you to now push various Sysinternals tools to remote hosts and pull back data for analysis (procmon & autoruns); moreover, you can install sysmon to selected endpoints with XML configurations. Other items of interest in the Resource folder is the PoSh-EasyWin Icon; the Checklist, Processes, adn About tabs, and tags.

***
***
### PowerShell Charts

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartDashboard.png)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartDashboardWithOptions.png)  |
|:------------------------------:|:---------------------------------:|
| Example of a Process Dashboard | Supports Options to Modify Charts | 

Dashboards are a collection of charts generated from a single collection, such as processes. The intent is to create as many useful charts with the given dataset to provide as much visibility in to the data. This allows analysts to compare results visually and easily determine any outliers. The charts have options that can modify the chart type and well as allow you to change the amount of data displayed. You can also pivot each dashboard chart to a multi-series chart to compare baseline, previous, and most recent collections.

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartMulti-Series.png)           |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartMulti-SeriesAlterateChartBar.png)  |
|:--------------------------------:|:--------------------------------:|
|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartMulti-SeriesWithTools.png)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartMulti-SeriesAlterateChartPie.png)  |
| Comapre with Multi-Series Chart  |  Supports Alternate Chart Types  |

Charts can be built to represent the data visually rather than just filterable lists. There are two ways to use charts, 1) Auto Create Charts and 2) Build Chart. Both options allow you simple save the chart as an image with a simple push of a button, but only the Auto Create Charts supports the feature to automatically save charts generated. To do this,  go to the Options tab you can select where they are saved automatically. 
1. <b>Auto Create Charts</b> - There are several preselect charts that can be automatically created. This are created as bar charts, and provide you the option to view the Baseline (the very first of that query type), Previous, and Most Recent query results. You can create a chart with multiple series, otherwise stated as showing up to all tree at the save time. This is useful useful to compare results from different collections and automaticially only shows endpoints that are common between each query. Note that the more endpoints within a query, the longer it takes to generate the chart; especially if doing more than one series.
2. <b>Build Chart</b> - You can also explore data and build your own charts manually. This supports picking any of the query csv results, and chosing any property as the X and Y axes. Additionally, you can chose between numerous types of ways to display the data, such as horizontal or vertical bars, line or area graphs, pie or donut charts, and much more. Note that you can easily make charts where the data doesn't make sense or is even misleading if you're not sure what you're doing when selecting which properties as X and Y axes. 

***
***
### Query Results
##### Easy to view with no external dependencies

![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot021.jpg)

Queries are returned in a csv format for easy review and can be viewed with PowerShell's native Out-GridView - no need for 3rd party software like Microsoft Excel. Query results are saved in datetime folders by each query name, and are both stored individually by hosts as well as compiled all together. 

***
***
### Session Based
##### Much faster than most traditional scripts!

Queries by default are session based, as opposed to individually executed. A session is established to each host and all selected queries are tunneled through them. Endpoints that don't get an established session are removed from being queried, eliminating queries that hang due to unresponsive/non-existing hosts until they timeout.

### Individual Execution via PowerShell Jobs
##### Queries are multi-threaded, providing another faster method.

![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot018.jpg)

Unlike many other scripts that execute serially, PoSh-EasyWin can execute its queries multi-threaded with PowerShell Jobs (up to 32 at a time by default). This prevents the script from hanging if one query or host is unresponsive. Additionly, there are two progress bars provided: 
1. The <b>Section</b> progress bar shows the status of the number of endpoints that have completed a given query while 
2. The <b>Overall</b> progress bar shows the status how many queries have been completed altogether. It is recommended that you don't run excessive queries against excessive number of endpoints. Aside from poor tradecraft, excessive queries can take a long time to process.


***
***
### Execute Queries Separately or Compiled Together

![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot026.jpg)

Queries can be executed as separate commands or compiled together. When executed separately the progress bars function as normal and provide an easy to view indicate of the PoSh-EasyWin's status. Since these commands are threaded as jobs which requires the host to spin up multiple PowerShell's (more memory intensive) to execute each command to each host (more individual network connections). Results are returned immedately for each host and endpoint though, and if an error occurs you don't lose all the data. Lastly, queries executed individual take longer to collect data, as new instances of PowerShell are spun up for each query and endpoint.  If the the commands are compiled together and executed, only one query is sent per endpoint (one PowerShell instance per host). This is substantially faster, but if for some reason if an error occurs during the remote collection, all data is lost; Lastly, the progress bars are not as effective as there is no way to monitor each queries completion, so you wont' konw when a larger compiled query is finished until it's finished.

***
***
### Computer TreeView
##### Intuitively view, select, and add new endpoints to query. 

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot010.jpg)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot011.jpg)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot017.jpg)  |
|:------------------------------:|:-----------------------------------:|:--------------------------------:|
| View by Operating System (OS)  |  View by Organization Unit (OU/CN)  |  Ability to Checkbox Categories  |

The computers tree view displays the computers either by Operating Systems (OS) or Organizational Units/Cononical Names (OU/CN). You can import these computers from Active Directory, from a list in a text file, from the Enumerations section, or just manually add them. 
1. When importing from Active Directory, use the following command (Get-ADComputer -Filter * -Properties "Name","OperatingSystem","CanonicalName","IPv4Address","MACAddress" | Export-Csv .\AD_Computers.csv -NoTypeInformation). If you get too few/many properties, PoSh-EasyWin will automatically adjust when it formats its 'Computer List TreeView (Saved).csv' file. This file not only saves this basic data about each host, but also all notes manually entered per host wihtin PoSh-EasyWin. 
2. When importing list from a text file, format the file so that there is one hostname per line. If you include IP address, you're mileage will vary and queries may not work as expected (the reason why is beyond the scope of this document). It is recommended to use hostname's within the domain when making queries. When data is imported from a text file, the hostnames will show up with Unknown OS's and OU/CN's, to which you can manually edit if desired. 
3. Importing from the Enumeration tab functions similarly as the importing from text file, but hostnames are obtainsed from either pinging or port scanning the network for hosts, then resolving their names to hostnames. 
4. Lastly, you can manually add endpoints with the Add button in the Manage List tab. This allows you to initially enter a name, Operating System, and Organizational Unit/Canonical Name. 

***
***
### Manage the Computer Treeview via the Context Menu and Manage List Tab

| ![Alt Text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ContextMenu.png) | ![Alt Text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabManageList.png) |
|:------------------------------:|:---------------------------------:|
|          Context Menu          |     Import Endpoints/Hostnames    |

The computer treeview can be managed via Context Menues, where you can conduct the following actions: Deselect All, Collapse/Exapnd the treeview, Import .csv, Import .txt, Add, Delete, Move, Rename, and Save.
Endpoint Specific:
1) <b>Collapse/Expand</b> - Shows all endpoints within a category. Once clicked, it will become an Expand button that will show all endpoints within each category and then once again become an Expand button.
2) <b>Tag</b> - Quickly tag a single endpoint with a pre-generated/manually entered tag or comment. This is added to the Host Data for later reference and is also searchable to find the endpoint.
3) <b>Add Endpoint</b> - Manually add a single enpoint to the computer treeview. You can either select existing OS or OU/CN categories, which auto-populte, or enter new names. PoSh-EasyWin prevents you from entering duplicate endpoint names, and notifies you of the existing endpoints OS and OU/CN.
4) <b>Rename</b> - Rename a single endpoint; the previous is added to the host data notes section for later reference. Currently, there is no way to rename a category as it automatically selects all endoints within, thus it would attempt to rename all of them which is not permitted. There are two work arounds for this: 1) Close PoSh-EasyWin and modify the CSV file namually, or 2) Add a new endpoint, and enter a custom/New OS or OU/CN name, then move the endpoint over.
5) <b>Move</b> - Move a single endpoint between categories. Depending on the treeview, OS or OU/CN, it will move endpoints under a different Operating System or Organizational Unit/Canonical Name categories. You can select a category checkbox to move all endpoints contained within. If a category no longer contains an endpoint after they're moved, it will be automatically removed. If you move an endpoint to a non-existing category, it will be automatically moved to an Unknown category.
6) <b>Delete</b> - Delete a single endpoint. All metadata and notes on the endpoint will be lost, but any previously collected data will remain. If a category no longer contains an endpoint after deletion, it will be automatically removed.

Checked Endpoints:
1) <b>Uncheck All</b> - This button unchecks all categories and endpoints.
2) <b>Tag All</b> - Quickly tag an endpoint with a single pre-generated/manually entered tag or comment. This is added to the Host Data for later reference and is also searchable to find the endpoint.
3) <b>Move All</b> - This button will move one or more endpoints between categories. Depending on the treeview, OS or OU/CN, it will move endpoints under a different Operating System or Organizational Unit/Canonical Name categories. You can select a category checkbox to move all endpoints contained within. If a category no longer contains an endpoint after they're moved, it will be automatically removed. If you move an endpoint to a non-existing category, it will be automatically moved to an Unknown category.
4) <b>Delete All</b> - This button will delete one ore more endpoints. If a category no longer contains an endpoint after deletion, it will be automatically removed.

Manage List Tab has support for the following:
1) <b>Import from AD</b> - Import endpoints and various metadata directly from Active Directory. The metadata it pulls in addition to the hostname are the Operating System, Organizational Unit/Container Name, IPv4 address, and MAC Address. You can either select an existing node that is a domain controller or enter a single hostname or ip to the left of the computer treeview.
2) <b>Import from .csv</b> - Import endpoint names from a csv file. The file's needs to have one endpoint name per line under a 'Name" header field to be read in properly. Supported fields are: "Name", "OperatingSystem", "CanonicalName", "IPv4Address", "MACAddress", and "Notes" - any addtional fields will be automatically purged. PoSh-EasyWin prevents you from entering duplicate endpoint names, and notifies you of the existing endpoints OS and OU/CN.
3) <b>Import from .txt</b> - Import endpoint names from a txt file. The file's needs to have one endpoint name per line to be read in properly. The endpoints ingested will not contain OS or OU/CN metadata and will be placed within Unknown categories. They can be moved afterwareds to their proper categories with the move button. PoSh-EasyWin prevents you from entering duplicate endpoint names, and notifies you of the existing endpoints OS and OU/CN.
4) <b>Save TreeView</b> - Saves the Computer TreeView, allowing it to be loaded automatically upon the next time PoSh-EasyWin is started. The save button within the Host Data tab will both save the contents of the notes and the treeview state.

***
***
### Connecting to Endpoints
##### Connect to an endpoint for an interactive experience.

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot022.jpg)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot023.jpg)  |
|:----------------:|:--------------:|
|  Remote Desktop  |  Event Viewer  |
|   ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot024.jpg)   |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot025.jpg)  |
|   PSSession   |     PSEXEC     |


***
***
### Operator Notes (OpNotes)
##### Efficiently take notes with timestamps.

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot008.jpg)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot009.jpg)  |
|:-------------:|:--------------:|
|  OpNotes Tab  |  OpNotes File  |

An <b>OpNote</b> is information that the operator considers to be of particular interest to note. They can be typed in manually, selectively imported from query results when viewed or from the Results panel. OpNotes that are entered are automaticlly prepended with a timestamp. The notes field auto-magically expands and shirts when hovered over to make quick review simple, though you can open the OpNotes file directly if desired with external applications. OpNotes are automatically saved to 'OpNotes.txt' when entered, moved, or deleted. The 'OpNotes (Write Only).txt' file contains all notes added in the order they were entered; this is useful if you accidentally remove/delete entries. The following are buttons used to assist with OpNotes.
1) <b>Add</b> - This button manally adds messages and are prepended with a datetime group that you type into the OpNotes input field at the top. Alternatively you can press the enter key to add notes which is arguably faster. Note that you cannot enter blank entries, if you do want to though, you will have to at least enter a space bar entry. 
2) <b>Remove</b> - This button removes/deletes one or more selected notes. The notes can be selected in any order and/or be within a selected range. Though automatically removed from the 'OpNotes.txt ', they will remain in the 'OpNotes (Write Only).txt' file.
3) <b>Select All</b> - This button selects all lines of the OpNotes.
4) <b>Create Report</b> - This button creates a report from selected lines of notes. This is useful if you want to extact and save only certain information for easy note management or passing along to another individual. The file is saved to the Reports directory where PoSh-EasyWin is located.
5) <b>Open Reports</b> - This button opens the directory where the Reports are saved. You can then open the text file with any external applications such as notepad, wordpad, or MicrSoft Docs.
6) <b>Open OpNotes</b> - This button directly opens the 'OpNotes.txt' file with the systems default application, which is most often notepad.
7) <b>Move up</b> - This button moves up on or more selected lines of OpNotes. The notes can be selected in any order and/or be within a selected range. When notes are moved, the datetimes remain. When notes are moved, the datetimes remain unchanged.
8) <b>Move Down</b> - This button moves down on or more selected lines of OpNotes. The notes can be selected in any order and/or be within a selected range. When notes are moved, the datetimes remain unchanged.

***
***
### Log File
##### Efficiently track your actions on endpoints with timestamps.
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/LogFile.JPG)

The <b>Log File</b> automatically logs actions conducted with PoSh-EasyWin. This is useful to help determine what action were or were not conducted though PoSh-EasyWin. Actions logged include such things as the lauching PoSh-EasyWin, each query conducted against each endpoint, Job execution/completion, the use of Sysinternals tools within PoSh-EasyWin, and activity conducted with endpoint enumeration scans. This section will continue to develop as more relavant data is identified to log.

***
***
### Host Data Management and Notes

![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot012.jpg)

You can view individual endpoint data and notes by selecting and highlighting, not checkboxing, the endpoint name in the computer treeview. This will automatically change the lower Results tab to the Host Data tab. Here you will be to view the hostname, Operating System, Organizational Unit/Canonical Name, IP Address, MAC Address, Tags, detected previous query results of speicific queries, and Host Notes. The majority of these fields are used to populate search results for the computer treeview to help locate a computer.
1. <b>Hostname</b> - This field dispays the name of the endpoint. Though this field cannot be renamed withing this view, you can use the Rename button within the Manage List tab.
2. <b>Operating System</b> - This field dispays the Operating System of the endpoint, and is only as accurate as the information PoSh-EasyWin is provided; be it improted from AD or manually entered. Though this field cannot be renamed withing this view, you can use the Move button within the Manage List tab to move the endpoint to a new category.
3. <b>Organizational Unit/Canonical Name</b> - This field dispays the OU/CN of the endpoint, and is only as accurate as the information PoSh-EasyWin is provided; be it improted from AD or manually entered. Though this field cannot be renamed withing this view, you can use the Move button within the Manage List tab to move the endpoint to a new category.
4. <b>IP Address</b> - This field is used to track and display the IP address of endpoint and also populates the tool tip when you hover over the endpoint name in the computer treeview.
5. <b>MAC Address</b> - This field is used to tract and display the MAC address of the endpoint.
6. <b>Tags</b> - This field along with the Add button allows you to utilize a standardize tag system to label endpoints with tags. If used consistently, this helps aide in the searching of endpoints, especially if there are a lot of them.
7. <b>Previously detected query results</b> - This two fields works together with the Get Data button to search for data that the endpoint is found within a particular query type. The query selected will yield date times of when the endpoint was queried.
8. <b>Host Notes</b> - This field is populated is data by the operator; be it manually entered or with Tags. Additionally, the Add Host Data To OpNotes button adds all text within the Host Notes to the OpNotes.
9. <b>Save</b> - After makeing any edits to the Host Data, be sure to save immediately... otherwise you will lose your data.

***
***
### Basic Command Line support
##### Currently under development. The overall commandline GUI is created, with overall flow to streamline querying... as the GUI provides much, much more.


### This following Images are place holders for more information... and is under construction.
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot003.jpg)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot004.jpg)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot005.jpg)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot007.jpg)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot013.jpg)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ScreenShot014.jpg)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabAction.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabChecklist.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabEnumeration.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabEventLogs.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabFileSearch.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabHostData.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabManageList.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabManageListOld.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabNetworkConnections.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabNetworkConnections-SelectPorts.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabOpNotes-SelectObjects.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabOpNotes.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabOptions.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabProcesses.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabQueryExploration.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabRegistry.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/TabResults.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/CommandLineNoGUI01.png)
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/CommandLineNoGUI02.png)



