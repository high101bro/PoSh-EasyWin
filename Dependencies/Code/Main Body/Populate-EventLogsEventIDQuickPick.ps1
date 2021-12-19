#============================================================================================================================================================
# Event Logs - Event ID Quick Pick Selection
#============================================================================================================================================================
$script:EventLogQueries = @()
#$EventLogReference = "https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor"
#$EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference -Value "$EventLogReference" -Force

$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Application Event Logs"
    Filter   = "(logfile='Application')"
    Message  = "Gets all Aplication Event Logs"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Application Event Logs.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Security Event Logs"
    Filter   = "(logfile='Security')"
    Message  = "Gets all Security Event Logs"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Security Event Logs.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "System Event Logs"
    Filter   = "(logfile='System')"
    Message  = "Gets all System Event Logs"
    FilePath = "$CommandsEventLogsDirectory\By Topic\System Event Logs.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Application Event Logs Errors"
    Filter   = "(logfile='Application') AND (type='error')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Application Event Logs Errors.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "System Event Logs Errors"
    Filter   = "(logfile='System') AND (type='error')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\System Event Logs Errors.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Splunk Sexy Six"
    Filter   = "((EventCode='4688') OR (EventCode='592') OR (EventCode='4624') OR (EventCode='528') OR (EventCode='540') OR (EventCode='5140') OR (EventCode='560') OR (EventCode='5156') OR (EventCode='7045') OR (EventCode='601') OR (EventCode='4663') OR (EventCode='576'))"
    Message  = "Splunk Sexy Six"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Splunk Sexy Six.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Incident Response - root9b"
    Filter   = "((EventCode='1100') OR (EventCode='1102') OR (EventCode='4608') OR (EventCode='4609') OR (EventCode='4616') OR (EventCode='4624') OR (EventCode='4625') OR (EventCode='4634') OR (EventCode='4647') OR (EventCode='4663') OR (EventCode='4688') OR (EventCode='4697') OR (EventCode='4720') OR (EventCode='4722') OR (EventCode='4723') OR (EventCode='4724') OR (EventCode='4725') OR (EventCode='4726') OR (EventCode='4732') OR (EventCode='4738') OR (EventCode='4769') OR (EventCode='4771') OR (EventCode='4772') OR (EventCode='2773') OR (EventCode='4820') OR (EventCode='4821') OR (EventCode='4825') OR (EventCode='4965') OR (EventCode='5140') OR (EventCode='5156') OR (EventCode='6006') OR (EventCode='7030') OR (EventCode='7040') OR (EventCode='7045') OR (EventCode='1056') OR (EventCode='10000') OR (EventCode='10001') OR (EventCode='10100') OR (EventCode='20001') OR (EventCode='20002') OR (EventCode='20003') OR (EventCode='24576') OR (EventCode='24577') OR (EventCode='24579') OR (EventCode='40961') OR (EventCode='4100') OR (EventCode='4104'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Incident Response - root9b.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Account Lockout"
    Filter   = "(logfile='Security') AND (EventCode='4625')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Account Lockout.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Account Management"
    Filter   = "(logfile='Security') AND ((EventCode='4720') OR (EventCode='4722') OR (EventCode='4723') OR (EventCode='4724') OR (EventCode='4725') OR (EventCode='4726') OR (EventCode='4738') OR (EventCode='4740') OR (EventCode='4765') OR (EventCode='4766') OR (EventCode='4767') OR (EventCode='4780') OR (EventCode='4781') OR (EventCode='4781') OR (EventCode='4794') OR (EventCode='4798') OR (EventCode='5376') OR (EventCode='5377'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Account Management.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Account Management Events - Other"
    Filter   = "(logfile='Security') AND ((EventCode='4782') OR (EventCode='4793'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Account Management Events - Other.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Application Event Logs Generated"
    Filter   = "(logfile='Security') AND ((EventCode='4665') OR (EventCode='4666') OR (EventCode='4667') OR (EventCode='4668'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Application Generated.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Application Event Logs Group Management"
    Filter   = "(logfile='Security') AND ((EventCode='4783') OR (EventCode='4784') OR (EventCode='4785') OR (EventCode='4786') OR (EventCode='4787') OR (EventCode='4788') OR (EventCode='4789') OR (EventCode='4790') OR (EventCode='4791') OR (EventCode='4792'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Application Group Management.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Authentication Policy Change"
    Filter   = "(logfile='Security') AND ((EventCode='4670') OR (EventCode='4706') OR (EventCode='4707') OR (EventCode='4716') OR (EventCode='4713') OR (EventCode='4717') OR (EventCode='4718') OR (EventCode='4739') OR (EventCode='4864') OR (EventCode='4865') OR (EventCode='4866') OR (EventCode='4867'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Authentication Policy Change.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Authorization Policy Change"
    Filter   = "(logfile='Security') AND ((EventCode='4703') OR (EventCode='4704') OR (EventCode='4705') OR (EventCode='4670') OR (EventCode='4911') OR (EventCode='4913'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Authorization Policy Change.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Audit Policy Change"
    Filter   = "(logfile='Security') AND ((EventCode='4902') OR (EventCode='4907') OR (EventCode='4904') OR (EventCode='4905') OR (EventCode='4715') OR (EventCode='4719') OR (EventCode='4817') OR (EventCode='4902') OR (EventCode='4906') OR (EventCode='4907') OR (EventCode='4908') OR (EventCode='4912') OR (EventCode='4904') OR (EventCode='4905'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Audit Policy Change.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Central Access Policy Staging"
    Filter   = "(logfile='Security') AND (EventCode='4818')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Central Access Policy Staging.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Certification Services"
    Filter   = "(logfile='Security') AND ((EventCode='4868') OR (EventCode='4869') OR (EventCode='4870') OR (EventCode='4871') OR (EventCode='4872') OR (EventCode='4873') OR (EventCode='4874') OR (EventCode='4875') OR (EventCode='4876') OR (EventCode='4877') OR (EventCode='4878') OR (EventCode='4879') OR (EventCode='4880') OR (EventCode='4881') OR (EventCode='4882') OR (EventCode='4883') OR (EventCode='4884') OR (EventCode='4885') OR (EventCode='4886') OR (EventCode='4887') OR (EventCode='4888') OR (EventCode='4889') OR (EventCode='4890') OR (EventCode='4891') OR (EventCode='4892') OR (EventCode='4893') OR (EventCode='4894') OR (EventCode='4895') OR (EventCode='4896') OR (EventCode='4897') OR (EventCode='4898'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Certification Services.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Computer Account Management"
    Filter   = "(logfile='Security') AND ((EventCode='4741') OR (EventCode='4742') OR (EventCode='4743'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Computer Account Management.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Detailed Directory Service Replication"
    Filter   = "(logfile='Security') AND ((EventCode='4928') OR (EventCode='4929') OR (EventCode='4930') OR (EventCode='4931') OR (EventCode='4934') OR (EventCode='4935') OR (EventCode='4936') OR (EventCode='4937'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Detailed Directory Service Replication.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Detailed File Share"
    Filter   = "(logfile='Security') AND (EventCode='5145')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Detailed File Share.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Directory Service Access"
    Filter   = "(logfile='Security') AND ((EventCode='4662') OR (EventCode='4661'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Directory Service Access.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Directory Service Changes"
    Filter   = "(logfile='Security') AND ((EventCode='5136') OR (EventCode='5137') OR (EventCode='5138') OR (EventCode='5139') OR (EventCode='5141'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Directory Service Changes.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Directory Service Replication"
    Filter   = "(logfile='Security') AND ((EventCode='4932') OR (EventCode='4933'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Directory Service Replication.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Distribution Group Management"
    Filter   = "(logfile='Security') AND ((EventCode='4749') OR (EventCode='4750') OR (EventCode='4751') OR (EventCode='4752') OR (EventCode='4753') OR (EventCode='4759') OR (EventCode='4760') OR (EventCode='4761') OR (EventCode='4762') OR (EventCode='4763') OR (EventCode='4744') OR (EventCode='4745') OR (EventCode='4746') OR (EventCode='4747') OR (EventCode='4748'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Distribution Group Management.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "DPAPI Activity"
    Filter   = "(logfile='Security') AND ((EventCode='4692') OR (EventCode='4693') OR (EventCode='4694') OR (EventCode='4695'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\DPAPI Activity.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "File Share"
    Filter   = "(logfile='Security') AND ((EventCode='5140') OR (EventCode='5142') OR (EventCode='5143') OR (EventCode='5144') OR (EventCode='5168'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\File Share.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "File System"
    Filter   = "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4663') OR (EventCode='4664') OR (EventCode='4985') OR (EventCode='5051') OR (EventCode='4670'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\File System.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Filtering Platform Connection"
    Filter   = "(logfile='Security') AND ((EventCode='5031') OR (EventCode='5150') OR (EventCode='5151') OR (EventCode='5154') OR (EventCode='5155') OR (EventCode='5156') OR (EventCode='5157') OR (EventCode='5158') OR (EventCode='5159'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Filtering Platform Connection.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Filtering Platform Packet Drop"
    Filter   = "(logfile='Security') AND ((EventCode='5152') OR (EventCode='5153'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Filtering Platform Packet Drop.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Filtering Platform Policy Change"
    Filter   = "(logfile='Security') AND ((EventCode='4709') OR (EventCode='4710') OR (EventCode='4711') OR (EventCode='4712') OR (EventCode='5040') OR (EventCode='5041') OR (EventCode='5042') OR (EventCode='5043') OR (EventCode='5044') OR (EventCode='5045') OR (EventCode='5046') OR (EventCode='5047') OR (EventCode='5048') OR (EventCode='5440') OR (EventCode='5441') OR (EventCode='5442') OR (EventCode='5443') OR (EventCode='5444') OR (EventCode='5446') OR (EventCode='5448') OR (EventCode='5449') OR (EventCode='5450') OR (EventCode='5456') OR (EventCode='5457') OR (EventCode='5458') OR (EventCode='5459') OR (EventCode='5460') OR (EventCode='5461') OR (EventCode='5462') OR (EventCode='5463') OR (EventCode='5464') OR (EventCode='5465') OR (EventCode='5466') OR (EventCode='5467') OR (EventCode='5468') OR (EventCode='5471') OR (EventCode='5472') OR (EventCode='5473') OR (EventCode='5474') OR (EventCode='5477'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Filtering Platform Policy Change.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Group Membership"
    Filter   = "(logfile='Security') AND (EventCode='4627')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Group Membership.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Handle Manipulation"
    Filter   = "(logfile='Security') AND ((EventCode='4658') OR (EventCode='4690'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Handle Manipulation.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "IPSec Driver"
    Filter   = "(logfile='Security') AND ((EventCode='4960') OR (EventCode='4961') OR (EventCode='4962') OR (EventCode='4963') OR (EventCode='4965') OR (EventCode='5478') OR (EventCode='5479') OR (EventCode='5480') OR (EventCode='5483') OR (EventCode='5484') OR (EventCode='5485'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Driver.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "IPSec Extended Mode"
    Filter   = "(logfile='Security') AND ((EventCode='4978') OR (EventCode='4979') OR (EventCode='4980') OR (EventCode='4981') OR (EventCode='4982') OR (EventCode='4983') OR (EventCode='4984'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Extended Mode.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "IPSec Main Mode"
    Filter   = "(logfile='Security') AND ((EventCode='4646') OR (EventCode='4650') OR (EventCode='4651') OR (EventCode='4652') OR (EventCode='4653') OR (EventCode='4655') OR (EventCode='4976') OR (EventCode='5049') OR (EventCode='5453'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Main Mode.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "IPSec Quick Mode"
    Filter   = "(logfile='Security') AND ((EventCode='4977') OR (EventCode='5451') OR (EventCode='5452'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Quick Mode.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Kerberos Authentication Service"
    Filter   = "(logfile='Security') AND ((EventCode='4768') OR (EventCode='4771') OR (EventCode='4772'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Kerberos Authentication Service.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Kerberos Service Ticket Operations"
    Filter   = "(logfile='Security') AND ((EventCode='4769') OR (EventCode='4770') OR (EventCode='4773'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Kerberos Service Ticket Operations.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Kernel Object"
    Filter   = "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4663'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Kernel Object.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Logon and Logoff Events"
    Filter   = "(logfile='Security') AND ((EventCode='4624') OR (EventCode='4625') OR (EventCode='4648') OR (EventCode='4675') OR (EventCode='4634') OR (EventCode='4647'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Logon and Logoff Events.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Logon and Logoff Events - Other"
    Filter   = "(logfile='Security') AND ((EventCode='4649') OR (EventCode='4778') OR (EventCode='4779') OR (EventCode='4800') OR (EventCode='4801') OR (EventCode='4802') OR (EventCode='4803') OR (EventCode='5378') OR (EventCode='5632') OR (EventCode='5633'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Logon and Logoff Events - Other.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "MPSSVC Rule-Level Policy Change"
    Filter   = "(logfile='Security') AND ((EventCode='4944') OR (EventCode='4945') OR (EventCode='4946') OR (EventCode='4947') OR (EventCode='4948') OR (EventCode='4949') OR (EventCode='4950') OR (EventCode='4951') OR (EventCode='4952') OR (EventCode='4953') OR (EventCode='4954') OR (EventCode='4956') OR (EventCode='4957') OR (EventCode='4958'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\MPSSVC Rule Level Policy Change.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Network Policy Server"
    Filter   = "(logfile='Security') AND ((EventCode='6272') OR (EventCode='6273') OR (EventCode='6274') OR (EventCode='6275') OR (EventCode='6276') OR (EventCode='6277') OR (EventCode='6278') OR (EventCode='6279') OR (EventCode='6280'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Network Policy Server.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Other Events"
    Filter   = "(logfile='Security') AND ((EventCode='1100') OR (EventCode='1102') OR (EventCode='1104') OR (EventCode='1105') OR (EventCode='1108'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Other Events.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Other Object Access Events"
    Filter   = "(logfile='Security') AND ((EventCode='4671') OR (EventCode='4691') OR (EventCode='5148') OR (EventCode='5149') OR (EventCode='4698') OR (EventCode='4699') OR (EventCode='4700') OR (EventCode='4701') OR (EventCode='4702') OR (EventCode='5888') OR (EventCode='5889') OR (EventCode='5890'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Other Object Access Events.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Other Policy Change Events"
    Filter   = "(logfile='Security') AND ((EventCode='4714') OR (EventCode='4819') OR (EventCode='4826') OR (EventCode='4909') OR (EventCode='4910') OR (EventCode='5063') OR (EventCode='5064') OR (EventCode='5065') OR (EventCode='5066') OR (EventCode='5067') OR (EventCode='5068') OR (EventCode='5069') OR (EventCode='5070') OR (EventCode='5447') OR (EventCode='6144') OR (EventCode='6145'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Other Policy Change Events.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Other System Events"
    Filter   = "(logfile='Security') AND ((EventCode='5024') OR (EventCode='5025') OR (EventCode='5027') OR (EventCode='5028') OR (EventCode='5029') OR (EventCode='5030') OR (EventCode='5032') OR (EventCode='5033') OR (EventCode='5034') OR (EventCode='5035') OR (EventCode='5037') OR (EventCode='5058') OR (EventCode='5059') OR (EventCode='6400') OR (EventCode='6401') OR (EventCode='6402') OR (EventCode='6403') OR (EventCode='6404') OR (EventCode='6405') OR (EventCode='6406') OR (EventCode='6407') OR (EventCode='6408') OR (EventCode='6409'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Other System Events.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "PNP Activity"
    Filter   = "(logfile='Security') AND ((EventCode='6416') OR (EventCode='6419') OR (EventCode='6420') OR (EventCode='6421') OR (EventCode='6422') OR (EventCode='6423') OR (EventCode='6424'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\PNP Activity.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Process Creation and Termination"
    Filter   = "(logfile='Security') AND ((EventCode='4688') OR (EventCode='4696') OR (EventCode='4689'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Process Creation and Termination.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Registry"
    Filter   = "(logfile='Security') AND ((EventCode='4663') OR (EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4657') OR (EventCode='5039') OR (EventCode='4670'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Registry.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Removeable Storage"
    Filter   = "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4663'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Removeable Storage.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "RPC Events"
    Filter   = "(logfile='Security') AND (EventCode='5712')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\RPC Events.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "SAM"
    Filter   = "(logfile='Security') AND (EventCode='4661')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\SAM.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Security Event Logs Group Management"
    Filter   = "(logfile='Security') AND ((EventCode='4731') OR (EventCode='4732') OR (EventCode='4733') OR (EventCode='4734') OR (EventCode='4735') OR (EventCode='4764') OR (EventCode='4799') OR (EventCode='4727') OR (EventCode='4737') OR (EventCode='4728') OR (EventCode='4729') OR (EventCode='4730') OR (EventCode='4754') OR (EventCode='4755') OR (EventCode='4756') OR (EventCode='4757') OR (EventCode='4758'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Security Group Management.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Security State Change"
    Filter   = "(logfile='Security') AND ((EventCode='4608') OR (EventCode='4609') OR (EventCode='4616') OR (EventCode='4621'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Security State Change.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Security System Extension"
    Filter   = "(logfile='Security') AND ((EventCode='4610') OR (EventCode='4611') OR (EventCode='4614') OR (EventCode='4622') OR (EventCode='4697'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Security System Extension.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Sensitive and Non-Sensitive Privilege Use"
    Filter   = "(logfile='Security') AND ((EventCode='4673') OR (EventCode='4674') OR (EventCode='4985'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Sensitive and NonSensitive Privilege Use.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "Special Logon"
    Filter   = "(logfile='Security') AND ((EventCode='4964') OR (EventCode='4672'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\Special Logon.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "System Integrity"
    Filter   = "(logfile='Security') AND ((EventCode='4612') OR (EventCode='4615') OR (EventCode='4616') OR (EventCode='5038') OR (EventCode='5056') OR (EventCode='5062') OR (EventCode='5057') OR (EventCode='5060') OR (EventCode='5061') OR (EventCode='6281') OR (EventCode='6410'))"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\System Integrity.txt"
}
$script:EventLogQueries += [PSCustomObject]@{
    Name     = "User and Device Claims"
    Filter   = "(logfile='Security') AND (EventCode='4626')"
    Message  = "_____"
    FilePath = "$CommandsEventLogsDirectory\By Topic\User and Device Claims.txt"
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtwL6v9rrGBw4oUzuy12DGmhD
# WnigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqKbJPjlQftAEeucHhwirVXSMIhMwDQYJKoZI
# hvcNAQEBBQAEggEAW0C3BhlLjfxLQdhqpQI7OOkZXgItkdhmBhGzBOigT9Wf32X2
# h7w/205skT6UiUx9fA18iyYwcnOyL7nyEBN9Rm3L16pt2GLnBFL6k8Gdno9PIfJX
# aB4kaD5gv5cfVtx1cxbvRdJwAWK/N6CicyHx9Vj2PtVwCn8LCli15W4O8O6o5uCb
# KvM14T1L2mYpim3N+hA3dz8NRtkIQxVrHU3FmEIGlda0sDMTUsLbbmhb+S+qEwbv
# 2ifvpUtZCpyrweXwgWY61yX4+xYwCn50BK1XH7HrScg8px5Z3mDHjngkf6QYMnpr
# dH+bL+OwPhFErUXN4ONnTtGDlg6GkzNN5V4Kow==
# SIG # End signature block
