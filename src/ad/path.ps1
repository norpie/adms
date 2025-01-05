# Gets the Top Level Domain for the current domain. e.g. "DC=example,DC=com"
Function Get-Top-Level
{
    $Top = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
    $Top = $Top -replace '\.', ',DC='
    $Top = "DC=$Top"
    return $Top
}

# Converts a string like "Example/Path/To/OU" into a distinguished name format
# e.g., "OU=OU,DC=To,DC=Path,DC=Example,$(Get-Top-Level)"
Function Get-Parsed-Path
{
    param(
        [string] $Path,                     # Input path to be parsed
        [switch] $LastCN,                   # If set, replaces the first OU with CN
        $TopLevel = $(Get-Top-Level)        # Default top-level domain from a function
    )

    # Normalize the path
    $Path = $Path -replace 'ROOT/', ''     # Remove "ROOT/" prefix
    $Path = $Path -replace 'ROOT', ''      # Remove standalone "ROOT"
    $Path = $Path -replace '\\', '/'       # Replace backslashes with forward slashes

    # Split the path and reverse the segments
    $PathSegments = $Path -split '/'
    [array]::Reverse($PathSegments)

    # Convert segments into "OU=" format
    $Path = $PathSegments | ForEach-Object { "OU=$_" }
    $Path = $Path -replace ' ',','

    # Handle cases where the path is empty
    if ($Path -eq 'OU=')
    {
        $Path = $TopLevel
    } else
    {
        $Path = "$Path,$TopLevel"
    }

    # Optionally replace the first "OU=" with "CN="
    if ($LastCN)
    {
        $Path = $Path -replace '^OU=', 'CN='
    }

    return $Path
}


# Converts a string like "OU=OU,DC=To,DC=Path,DC=Example,DC=com"
# to a string like "Example/Path/To/ROOT".
function Get-AD-Compatible-Path
{
    param(
        [string]$Path,
        [string]$TopLevel = $(Get-Top-Level),
        [switch]$AllowCN
    )

    # Remove the top-level domain and its prefix
    $Path = $Path -replace ",$TopLevel", ''
    $Path = $Path -replace "$TopLevel", ''

    # Remove CN components if $AllowCN is not set
    if (-not $AllowCN)
    {
        while ($Path -match '^CN=')
        {
            $Path = $Path -replace '^CN=[^,]*,?', ''
        }
    } else
    {
        $Path = $Path -replace '^CN=', ''
    }

    # Replace OU= and DC= components
    $Path = $Path -replace 'OU=', ''
    $Path = $Path -replace 'DC=', ','
    $Path = $Path -replace ',', '/'

    # Handle empty paths
    if ([string]::IsNullOrEmpty($Path))
    {
        return 'ROOT'
    }

    # Append ROOT to the path
    $Path = "$Path/ROOT"

    # Reverse the path components
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

    return $Reversed
}
