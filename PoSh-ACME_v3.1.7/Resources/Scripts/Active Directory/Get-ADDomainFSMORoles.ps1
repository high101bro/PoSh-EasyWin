[PSCustomObject]@{ 
    Name                 = 'FSMORoles'
    InfrastructureMaster = $(Get-ADDomain | Select-Object -ExpandProperty InfrastructureMaster)
    PDCEmulator          = $(Get-ADDomain | Select-Object -ExpandProperty PDCEmulator)
    RIDMaster            = $(Get-ADDomain | Select-Object -ExpandProperty RIDMaster)
    SchemaMaster         = $(Get-ADForest | Select-Object -ExpandProperty SchemaMaster)
    DomainNamingMaster   = $(Get-ADForest | Select-Object -ExpandProperty DomainNamingMaster)
} | Select-Object @{name="PSComputerName";expression={$env:COMPUTERNAME}}, Name, InfrastructureMaster, PDCEmulator, RIDMaster, SchemaMaster, DomainNamingMaster