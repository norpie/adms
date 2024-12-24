. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\util.ps1
. $PSScriptRoot\path.ps1

Function Read-User-Fields
{
    param (
        $User
    )
    $User.Path = Read-Field -Field $User.Path -Default ''
    $User.Name = Read-Field -Field $User.Name
    $User.DisplayName = Read-Field -Field $User.DisplayName
    $User.Password = Read-Field -Field $User.Password
    return $User
}

Function New-User
{
    param(
        $User
    )
    $User = Read-User-Fields -User $User
    $User.Path = Get-Parsed-Path -Path $User.Path
    New-ADUser -Name $User.Name -DisplayName $User.DisplayName -Password $User.Password -Path $User.Path
}

Function New-Users
{
    param(
        $Users
    )
    foreach ($User in $Users)
    {
        New-User -User $User
    }
}

Function Edit-Users
{
    param (
        $Users
    )
    foreach ($User in $Users)
    {
        $User = Read-User-Fields -User $User
        $Name = Read-Field -Field $User.Name
        $FoundUser = Get-ADUser -Filter {Name -eq $Name}
        if (!$FoundUser)
        {
            continue
        }
        Set-ADUser -Identity $FoundUser -DisplayName $User.DisplayName -Password $User.Password
    }
}

Function Remove-Users
{
    param (
        $Users
    )
    foreach ($User in $Users)
    {
        $Name = Read-Field -Field $User.Name
        Remove-ADUser -Name $Name
    }
}
