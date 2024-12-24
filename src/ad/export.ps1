. $PSScriptRoot\path.ps1

Function Export-OUs {
    param (
        [string]$OUExportFile
    )
    DefaultOUs = @(
        "Builtin",
        "Computers",
        "Domain Controllers",
        "ForeignSecurityPrincipals",
        "Managed Service Accounts",
        "Users"
    )
    $OUs = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | Where-Object { $_.CanonicalName -notmatch "OU=($($DefaultOUs -join "|"))" }
    # Get relevant fields
    $CustomOUs = @()
    foreach ($OU in $OUs)
    {
        $CustomOUs += [PSCustomObject]@{
            "Name" = $OU.Name
            "Path" = Get-Unparsed-Path -Path $OU.DistinguishedName
            "Description" = $OU.Description
        }
    }
    $CustomOUs | Export-Csv -Path $OUExportFile -NoTypeInformation
}

Function Export-Users {
    param(
        [string]$UserExportFile
    )
    $Users = Get-ADUser -Filter * -Properties *
    $CustomUsers = @()
    foreach ($User in $Users)
    {
        $CustomUsers += [PSCustomObject]@{
            "Name" = $User.Name
            "Path" = Get-Unparsed-Path -Path $User.DistinguishedName
            "Description" = $User.Description
        }
    }
    $CustomUsers | Export-Csv -Path $UserExportFile -NoTypeInformation
}

Function Export-Groups {
    param(
        [string]$GroupExportFile
    )
    $Groups = Get-ADGroup -Filter * -Properties *
    $CustomGroups = @()
    foreach ($Group in $Groups)
    {
        $CustomGroups += [PSCustomObject]@{
            "Name" = $Group.Name
            "Path" = Get-Unparsed-Path -Path $Group.DistinguishedName
            "Description" = $Group.Description
        }
    }
    $CustomGroups | Export-Csv -Path $GroupExportFile -NoTypeInformation
}
