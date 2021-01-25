function Search-DirectoryTreeView {
    param($Input)
    Add-Type -AssemblyName System.Windows.Forms

    #function GetPaths {
    #    param($root)
    #    Get-ChildItem $root -Recurse -Directory -Force `
    #    | ForEach-Object {
    #        $_.FullName.Replace($root, "").Trim("\")
    #    }
    #}

    function FilterPaths {
        param($paths, $like)
        $paths | Where-Object {$_ -like "*$like*"} `
        | ForEach-Object {
            $i = $_.LastIndexOf("$like", [System.Globalization.CompareOptions]::IgnoreCase)
            if($i -gt -1) {
                $j = $_.IndexOf("\", $i, [System.Globalization.CompareOptions]::IgnoreCase)
                if($j -gt -1) { $_.SubString(0,$j) }
                else { $_ }
            }
        }
    }

    function GetNodes {
        param($nodes)
         foreach ($n in $nodes) {
            $n
            GetNodes($n.Nodes)
         }
    }

    function HighlightNodes {
        param($nodes, $like)
        if(!$like){ return }
        $nodes | ? {$_ -like "*$like*"} `
        | ForEach-Object {
            $_.BackColor = "Yellow"
        }
    }

    function PopulateTree {
        param($treeView, $paths)
        $treeView.Nodes.Clear()
        foreach ($path in $paths){
            $lastNode = $null
            $subPathAgg = ""
            foreach ($subPath in ($path -split '\\')) {
                $subPathAgg += ($subPath + '\')
                $nodes = $treeView.Nodes.Find($subPathAgg, $true)
                if ($nodes.Length -eq 0) {
                    if ($lastNode -eq $null) { $lastNode = $treeView.Nodes.Add($subPathAgg, $subPath) }
                    else { $lastNode = $lastNode.Nodes.Add($subPathAgg, $subPath) }
                }
                else { $lastNode = $nodes[0] }
            }
        }
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Add_Closing = { $This.dispose() }

    $form.Text ="Show-Directory"
    $form.Controls.AddRange(@(
        ($txt = [System.Windows.Forms.TextBox] @{
            Location = [System.Drawing.Point]::new(8, 8);
            Width    = $form.ClientSize.Width - 16;
            Anchor   = [System.Windows.Forms.AnchorStyles]13
        }),
        ($tree = [System.Windows.Forms.TreeView] @{
            Location = [System.Drawing.Point]::new(8, 40);
            Width    = $form.ClientSize.Width - 16;
            Anchor   = [System.Windows.Forms.AnchorStyles]15
            Height   = 200;
            HideSelection = $false
        })
    ))
    $form.AcceptButton= $btn
    #$root  = "C:\windows\system32"
    #$paths = GetPaths $root
    $paths = $Input

    PopulateTree $tree $paths
    $tree.ExpandAll()

    $txt.Add_TextChanged({param($sender,$e)
        $tree.BeginUpdate()
        $like     = $txt.Text
        $filtered = FilterPaths $paths $like
        PopulateTree $tree $filtered
        HighlightNodes (GetNodes $tree.Nodes) $like
        $tree.ExpandAll()
        $tree.TopNode = $tree.Nodes[0]
        $tree.EndUpdate()
    })
    $form.ShowDialog() | Out-Null
    $form.Dispose()}

