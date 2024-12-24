Function Get-Top-Level
{
    $Top = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
    $Top = $Top -replace '\.', ',DC='
    $Top = "DC=$Top"
    return $Top
}

# Takes a string like "Example/Path/To/OU" and returns an array of strings like "OU=OU,DC=To,DC=Path,DC=Example,$(Get-Top-Level)"
Function Get-Parsed-Path
{
    param(
        $Path
    )
    # Support both Windows and Unix paths
    $Path = $Path -replace '\\', '/'
    $Path = $Path -split '/'
    $Path = $Path | ForEach-Object { "DC=$_" }
    $Path = $Path -join ','
    $Path = "OU=$Path,$(Get-Top-Level)"
}

# Takes a string like "OU=OU,DC=To,DC=Path,DC=Example,DC=com" and returns a string like "Example/Path/To/OU"
Function Get-Unparsed-Path
{
    param(
        $Path
    )
    $Path = $Path -replace 'DC=', ''
    $Path = $Path -replace 'OU=', ''
    $Path = $Path -replace ',', '/'
    $Path = $Path -replace '^/', ''
    $Split = $Path -split '/'
    $Reversed = ""
    for ($i = $Split.Length - 1; $i -ge 0; $i--)
    {
        $Reversed += $Split[$i]
        if ($i -gt 0)
        {
            $Reversed += "/"
        }
    }
    return $Path
}
