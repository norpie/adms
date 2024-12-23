. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\util.ps1
. $PSScriptRoot\path.ps1

Function Get-Temp-OU
{
    $Name = [System.Guid]::NewGuid().ToString()
    $OU = New-ADOrganizationalUnit -Name $Name -ProtectedFromAccidentalDeletion $false -PassThru
    return $OU
}

Function Read-OU-Fields
{
    param(
        $OU
    )
    $OU.Path = Read-Field -Field $OU.Path -Default ''
    $OU.Name = Read-Field -Field $OU.Name
    $OU.Protect = Read-Field -Field $OU.Protect -Default $false
    $OU.Protect = [bool]::Parse($OU.Protect)
    $OU.Description = Read-Field -Field $OU.Description -Default ''
    return $OU
}

Function Move-Children-Up
{
    param(
        $OU,
        $Temp
    )
    $Children = Get-ADObject -Filter * -SearchBase $OU -SearchScope OneLevel
    $NewChildren = @()
    foreach ($Child in $Children)
    {
        Write-Log-Abstract -Category 'INF' -MessageName 'MovingObject' -AdditionalMessage $Child.Name
        $NewChild = Move-ADObject -Identity $Child.DistinguishedName -TargetPath $Temp -PassThru
        $NewChildren += $NewChild
        Write-Log-Abstract -Category 'INF' -MessageName 'MovedObject' -AdditionalMessage $Child.Name
    }
    return $NewChildren
}

Function Move-Children-Back
{
    param(
        $OU,
        $Children
    )
    foreach ($Child in $Children)
    {
        Write-Log-Abstract -Category 'INF' -MessageName 'MovingObject' -AdditionalMessage $Child.Name
        Move-ADObject -Identity $Child.DistinguishedName -TargetPath $OU.DistinguishedName
        Write-Log-Abstract -Category 'INF' -MessageName 'MovedObject' -AdditionalMessage $Child.Name
    }
}

Function Write-Over-Existing
{
    param(
        $OU,
        $Existing
    )
    $Temp = Get-Temp-OU
    $Children = Move-Children-Up -OU $Existing.DistinguishedName -Temp $Temp.DistinguishedName
    Set-ADObject -Identity $Existing.DistinguishedName -ProtectedFromAccidentalDeletion:$false
    Remove-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Confirm:$false
    $New = New-ADOrganizationalUnit -Name $OU.Name -ProtectedFromAccidentalDeletion $OU.Protect -Description $OU.Description -PassThru
    Move-Children-Back -OU $New -Children $Children
    Remove-ADOrganizationalUnit -Identity $Temp.DistinguishedName -Confirm:$false
}

Function New-OU
{
    param(
        $OU
    )
    $OU = Read-OU-Fields -OU $OU
    Write-Log-Abstract -Category 'INF' -MessageName 'CreatingOU' -AdditionalMessage $OU.Name
    $Name = $OU.Name
    $Existing = Get-ADOrganizationalUnit -Filter {Name -eq $Name}
    if ($Existing)
    {
        if ($global:ADOptions.OverwriteExisting)
        {
            Write-Over-Existing -OU $OU -Existing $Existing
            return
        } elseif
            ($global:ADOptions.ErrorHandling -eq 3)
        {
            Write-Log-Abstract -Category 'ERR' -MessageName 'ExistingOU' -AdditionalMessage $OU.Name -Throw
        } elseif ($global:ADOptions.ErrorHandling -eq 2)
        {
            Write-Log-Abstract -Category 'WAR' -MessageName 'ExistingOU' -AdditionalMessage $OU.Name
            return
        }
    }
    New-ADOrganizationalUnit -Name $OU.Name -ProtectedFromAccidentalDeletion $OU.Protect -Description $OU.Description
    Write-Log-Abstract -Category 'INF' -MessageName 'CreatedOU' -AdditionalMessage $OU.Name
}

Function New-OUs
{
    param (
        [string] $OUInputFile
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'StartCreateOUs'
    $OUs = Import-Csv -Path $OUInputFile
    for ($i = 0; $i -lt $OUs.Length; $i++)
    {
        try
        {
            $OU = $OUs[$i]
            New-OU -OU $OU
        } catch
        {
            if ($global:ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -Category 'WAR' -MessageName 'CreatingOUFailed' -AdditionalMessage $OU.Name
                continue
            } elseif ($global:ADOptions.ErrorHandling -eq 3)
            {
                Write-Log-Abstract -Category 'ERR' -MessageName 'CreatingOUFailed' -AdditionalMessage $OU.Name -Throw
            }
        }
    }
    Write-Log-Abstract -Category 'INF' -MessageName 'EndCreateOUs'
}

Function Remove-OUs
{
    param (
        [string] $OUInputFile
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'StartRemoveOUs'
    $OUs = Import-Csv -Path $OUInputFile
    for ($i = 0; $i -lt $OUs.Length; $i++)
    {
        try
        {
            $OU = $OUs[$i]
            $Name = $OU.Name
            $Existing = Get-ADOrganizationalUnit -Filter {Name -eq $Name}
            if (!$Existing)
            {
                if ($global:ADOptions.ErrorHandling -eq 2)
                {
                    Write-Log-Abstract -Category 'WAR' -MessageName 'RemovingOUFailed' -AdditionalMessage $OU.Name
                    continue
                } elseif ($global:ADOptions.ErrorHandling -eq 3)
                {
                    Write-Host $_.Exception.Message
                    Write-Log-Abstract -Category 'ERR' -MessageName 'RemovingOUFailed' -AdditionalMessage $OU.Name -Throw
                }
            }
            Set-ADObject -Identity $Existing.DistinguishedName -ProtectedFromAccidentalDeletion:$false
            if ($global:ADOptions.RecursiveDelete)
            {
                Remove-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Recursive -Confirm:$false
            } else
            {
                Remove-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Confirm:$false
            }
            Write-Log-Abstract -Category 'INF' -MessageName 'RemovedOU' -AdditionalMessage $OU.Name
        } catch
        {
            if ($global:ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -Category 'WAR' -MessageName 'RemovingOUFailed' -AdditionalMessage $OU.Name
                continue
            } elseif ($global:ADOptions.ErrorHandling -eq 3)
            {
                Write-Host $_.Exception.Message
                Write-Log-Abstract -Category 'ERR' -MessageName 'RemovingOUFailed' -AdditionalMessage $OU.Name -Throw
            }
        }
    }
}

Function Edit-OUs {
    param (
        [string] $OUInputFile
    )
    # TODO: Implement this function
}
