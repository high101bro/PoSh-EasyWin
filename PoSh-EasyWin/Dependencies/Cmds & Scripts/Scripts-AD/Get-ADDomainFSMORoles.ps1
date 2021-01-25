<#
.Description
	Active Directory has five FSMO roles, two of which are enterprise-level (ie, one per forest) and three of which are domain-level (ie, one per domain). The enterpriese-level FSMO roles are called the Schema Master and the Domain Naming Master. The Domain-level FSMO roles are called the Primary Domain Controller Emulator, the Relative Identifier Master, and the Infrastructure Master.

	In a new Active Directory forest, all five FSMO roles are assigned to the initial domain controller in the newly created forest root domain. When a new domain is added to an existing forest, only the three domain-level FSMO roles are assigned to the initial domain controller in the newly created domain; the two enterprise-level FSMO roles already exist in the forest root domain.

	FSMO roles often remain assigned to their original domain controllers, but they can be transferred if necessary.

	Schema Master
		This is an enterprise-level FSMO role, there is only one Schema Master in an Active Directory forest.

	Domain Naming Master
		This is an enterprise-level FSMO role, there is only one Domain Naming Master in an Active Directory forest.

	RID Master
		This is a domain-level FSMO role, there is one RID Master in each domain in an Active Directory Forest.

	Infrastructure Master
		This is a domain-level FSMO role, there is one Infrastructure Master in each domain in an Active Directory Forest.

	PDCEmulator
		This is a domain-level FSMO role, there is one PDCE in each domain in an Active Directory Forest.

	https://blog.stealthbits.com/what-are-fsmo-roles-active-directory/
#>
[PSCustomObject]@{
    Name                 = 'FSMORoles'
    InfrastructureMaster = $(Get-ADDomain | Select-Object -ExpandProperty InfrastructureMaster)
    PDCEmulator          = $(Get-ADDomain | Select-Object -ExpandProperty PDCEmulator)
    RIDMaster            = $(Get-ADDomain | Select-Object -ExpandProperty RIDMaster)
    SchemaMaster         = $(Get-ADForest | Select-Object -ExpandProperty SchemaMaster)
    DomainNamingMaster   = $(Get-ADForest | Select-Object -ExpandProperty DomainNamingMaster)
} | Select-Object @{name="PSComputerName";expression={$env:COMPUTERNAME}}, Name, InfrastructureMaster, PDCEmulator, RIDMaster, SchemaMaster, DomainNamingMaster

