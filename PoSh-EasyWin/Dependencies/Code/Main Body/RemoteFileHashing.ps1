$Files = Get-ChildItem C:\WINDOWS\system32 -force
$HashList = @('975B45B669930B0CC773EAF2B414206F','B3A17BF375F35123F3CDAD743D59FEDC','F97C0041886519CEAE336B06AEBFC9E1')

$HashAlgorithms = @('MACTripleDES','MD5','RIPEMD160','SHA1','SHA256','SHA384','SHA512')
$Algorithm = 'MD5'

$HashesFound = @()

foreach ($File in $Files) {
    $FileHash = Get-FileHash -Algorithm $Algorithm -Path $File.fullname -ErrorAction SilentlyContinue
    if ($HashList -contains $FileHash.hash -and $FileHash.Algorithm -eq 'MD5'){
        $HashesFound += $File
    }
}
$HashesFound


 
