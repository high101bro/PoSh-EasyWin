if     ($RegistryKeyNameCheckbox.checked)   { 
    Query-Registry -CollectionName "Registry Search - Key Name" 
}
elseif ($RegistryValueNameCheckbox.checked) { 
    Query-Registry -CollectionName "Registry Search - Value Name" 
}
elseif ($RegistryValueDataCheckbox.checked) { 
    Query-Registry -CollectionName "Registry Search - Value Data" 
}
