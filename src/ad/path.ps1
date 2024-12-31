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
    $Path = $Path -replace 'ROOT/', ''
    $Path = $Path -replace 'ROOT', ''
    $Path = $Path -replace '\\', '/'
    $Path = $Path -split '/'
    $Path = $Path | ForEach-Object { "OU=$_" }
    $Path = $Path -join ','
    if ($Path -eq 'OU=')
    {
        $Path = "$(Get-Top-Level)"
    } else
    {
        $Path = "$Path,$(Get-Top-Level)"
    }
    return $Path
}

# Takes a string like "OU=OU,DC=To,DC=Path,DC=Example,DC=com" and returns a string like "Example/Path/To"
Function Get-Unparsed-Path
{
    param(
        $Path
    )
    $Path = $Path -replace ",$(Get-Top-Level)", ''
    while ($Path -match '^CN=')
    {
        $Path = $Path -replace '^CN=',''
        $Path = $Path -replace '^[^,]*', ''
        $Path = $Path -replace '^,',''
    }
    $Path = $Path -replace 'OU=', ''
    $Path = $Path -replace 'DC=', ','
    $Path = $Path -replace ',', '/'
    if ($Path -eq '')
    {
        $Path = 'ROOT'
    } else
    {
        $Path = "$Path/ROOT"
    }
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
    $Path = $Reversed
    return $Path
}
