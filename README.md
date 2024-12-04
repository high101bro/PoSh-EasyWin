# PoSh-EasyWin
#### **P**ower**S**hell - **E**ndpoint **A**nalysis **S**olution **Y**our **W**indows **I**ntranet **N**eeds
<table>
  <thead>
    <tr>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td valign="top"><strong>File Name</strong></td>
      <td valign="top">PoSh-EasyWin.ps1</td>
    </tr>
    <tr>
      <td valign="top"><strong>Created</strong></td>
      <td valign="top">21 Aug 2018</td>
    </tr>
    <tr>
      <td valign="top"><strong>Author</strong></td>
      <td valign="top">Daniel Komnick (high101bro)</td>
    </tr>
    <tr>
      <td valign="top"><strong>Email</strong></td>
      <td valign="top">high101bro@gmail.com</td>
    </tr>
    <tr>
      <td valign="top"><strong>LinkedIn</strong></td>
      <td valign="top"><a href="https://www.linkedin.com/in/daniel-komnick">https://www.linkedin.com/in/daniel-komnick</a></td>
    </tr>
    <tr>
      <td valign="top"><strong>Website</strong></td>
      <td valign="top"><a href="https://github.com/high101bro/PoSh-EasyWin">https://github.com/high101bro/PoSh-EasyWin</a></td>
    </tr>
    <tr>
      <td valign="top"><strong>PowerShell Requirements</strong></td>
      <td valign="top">
        <ul>
          v6.0+
            <ul>
              <li>PowerShell Core on Linux is NOT supported</li>
              <li>GUI requires Windows.System.Forms</li>
            </ul>
          v5.1
            <ul>
              <li>PSWriteHTML Module support</li>
              <li>Fully tested</li>
            </ul>
          v4.0
            <ul>
              <li>The use of Copy-Item -Session</li>
              <li>Partially Tested</li>
            </ul>
          v3.0
            <ul>
              <li>Splatting Arguments</li>
              <li>PowerShell Charts support</li>
              <li>Limited testing</li>
            </ul>
          v2.0
            <ul>
              <li>Not supported, requires splatting</li>
            </ul>
        </ul>
      </td>
    </tr>
    <tr>
      <td valign="top"><strong>Optional</strong></td>
      <td valign="top">
        PsExec.exe, Procmon.exe, Sysmon.exe,<br>
        etl2pcapng.exe, kitty.exe, plink.exe,<br>
        chainsaw.exe, WxTCmd.exe
      </td>
    </tr>
    <tr>
      <td valign="top"><strong>Tutorials & Demos</strong></td>
      <td valign="top">
        <a href="https://www.youtube.com/results?search_query=PoSh-EasyWin">https://www.youtube.com/results?search_query=PoSh-EasyWin</a><br>
        Many thanks to Cole Van Landingham for creating these!
      </td>
    </tr>
  </tbody>
</table>


***
***

![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PoSh-EasyWin_GUI.png)

### Scope
PoSh-EasyWin is a Graphical User Interface (GUI) that uses PowerShell with the .Net Framework to primarily query for various information from remote computers. It obtains data that is on the system 'now' without the need to install agents on remote systems. It provides an interface to easily make any number of queries to any number of hosts, and maintains a local log to track when they were conducted and to which systems. Little to no PowerShell knowledge is needed, just click on the desired queries and endpoints, then start collecting data. Note: Queries to numerous endpoints equates to more processing power and time needed.

### The goals of PoSh-EasyWin are to provide:
1. A graphical interface allowing users to easily interact with endpoints.
2. Easily view collected data locally via charts, spreadsheats, and by terminal.
3. An efficient method to obtain various data from remote endpoints over various protocols.
4. Visiblity into many common commands for endpoints and active directory servers.
5. The ability to effortlessly connect to an endpoint via a Remote Desktop, PSSession, PSExec, or explore Event Logs. 
6. A method to analyze data/results from numerous systems natively without external 3rd party applications.

### YouTube Tutorial and Demo Videos
Many thanks to Cole VanLandingham for creating these videos: 

***
***
## How to Run PoSh-EasyWin.ps1
Microsoft included some security features to protect the average user from unknowingly running PowerShell (.ps1) scripts. This is accomplished through blocking .ps1 scripts that are downloaded from the internet as well as having a default script execution policy of restricted. Oftentimes, users just Unblock-File ".\PoSh-EasyWin" and Set-ExecutionPolicy ByPass. While this works, it isn't best practice. Rather, all PoSh-EasyWin scripts have been signed, thus it is preferrable to do the following:
```
# The script will normally be blocked from execution. 
PS C:\PoSh-EasyWin> .\PoSh-EasyWin.ps1

# How to check the execution policy.
PS C:\PoSh-EasyWin> Get-ExecutionPolicy

# How to import the certificate to allow for exection of signed scripts
PS C:\PoSh-EasyWin> Import-Certificate -FilePath ".\PoSh-EasyWin_Public_Certificate.cer" -CertStoreLocation Cert:\CurrentUser\Root

# How to check the authenticode signature.
PS C:\PoSh-EasyWin> Get-AuthenticodeSignature .\PoSh-EasyWin.ps1

# How to set the execution policy to either RemoteSigned or AllSigned. Either method will work, though AllSigned will prompt you with info.
PS C:\PoSh-EasyWin> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
PS C:\PoSh-EasyWin> Set-ExecutionPolicy -ExecutionPolicy AllSigned

# The script should run now. 
PS C:\PoSh-EasyWin> .\PoSh-EasyWin.ps1
```
### Example Screenshot:
![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/HowToRunPoSh-EasyWin.png)
            

***
***
### Browser View - Searching, Tables, Panels, Charts, and Graphs

| ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Graph02.jpg)  | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Graph04.jpg) | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Graph03-ProcessTree.jpg) | 
|:----------------------:|:-----------------:|:---------------------:|
|  Graph Node Views  |  Zoomed-in Desciptions  |  Graph & Table Combo  |
| ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Sheet01.jpg)  | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Panel01.jpg) | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Chart01.jpg) | 
|  Table Search w/ Details  |  Panel Breakout Filtering  |  Pies & Bar Charts   |

Relatively new feature, undergoing regular updates - Currently refining code to best display data. Also, looking into other data that is useful to visualize in graphs. You're able to view data collected from endpoints or from Active Directory and their relationships as well as investigate more details by looking at the accompanying data within the spreadsheets in the browser. This features uses the PSWriteHTML module which can be installed separately, but a specific version has been packaged with PoSh-EasyWin that has been vetted for compatibliity.

***
***
### Monitor Jobs Tab

| ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/MonitorJobs01.jpg)  | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/MonitorJobs02.jpg) | ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/PSWriteHTML-Notify02.jpg) | 
|:----------------------:|:-----------------:|:---------------------:|
|  Monitor Jobs Compact View  |  Monitor Jobs Maximized View  |  Optional Query Notification   |

There is a new monitor jobs tab that tracks jobs with individual progress bars, while allowing you the freedom to continue using the GUI to conduct other tasks. Each progress bar also has it's own timer to see how long each task has been running or took to compelte. Queries can be cancelled and removed. You're able to click on each to view the data in progress to see what's collected as it's going and afterward completion. After completion, you're able to view the results in a PowerShell terminal, allowing you to easily manipulate the data as you see fit. Data is saved by default, but you're able to choose to not save it before removing. There is an option to select to be notified per each query, which will show a popup while your don't other tasks. There's an option to maximize the panel view to easily see more jobs - plus an auto-max feature.

***
***
### Executing Queries

PoSh-EasyWin is a tool that allows you to run any number of queries against any number of hosts. The queries primarily consist of one liner commands, but several are made of scripts that allows for more comprehensive results. PoSh-EasyWin consists of queries speicific for endpoiint hosts and servers in an Active Directory domain. It allows you to easily query event logs from multiple sources within specified date ranges; query for filenames, parts of filenames, file hashes in any number of specified directores at any recursion depth; query for network connections by IP addresses, ports, and connections started by specified process names. 


***
***
### Resource Files

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/LookupTables.png)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/Sysinternals.png)  |
|:-----------------------------:|:-----------------------------:|
|  Suports VariosLookup Tables  |  Sysinternals Tools Provided  |

If the Resource folder is present, it adds additional functionality. Such as the ability to select ports/protocols or Event IDs from a GUI rather than memorizing them all or looking them up externally. It also allows you to now push various Sysinternals tools to remote hosts and pull back data for analysis (procmon data); moreover, you can install sysmon to selected endpoints with XML configurations. Other items of interest in the Resource folder is the PoSh-EasyWin Icon; the Checklist, Processes, adn About tabs, and tags.

***
***
### PowerShell Charts

|  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartDashboard.png)  |  ![Alt text](https://github.com/high101bro/PoSh-EasyWin/blob/master/Images/ChartDashboardWithOptions.png)  |
|:------------------------------:|:---------------------------------:|
| Example of a Process Dashboard | Supports Options to Modify Charts | 

Dashboards are a collection of charts generated from a single collection, such as processes. The intent is to create as many useful charts with the given dataset to provide as much visibility in to the data. This allows analysts to compare results visually and easily determine any outliers. The charts have options that can modify the chart type and well as allow you to change the amount of data displayed. You can also pivot each dashboard chart to a multi-series chart to compare baseline, previous, and most recent collections.


