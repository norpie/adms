. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\..\actionlog.ps1
. $PSScriptRoot\util.ps1
. $PSScriptRoot\path.ps1

# Create a temporary OU
Function Get-Temp-OU
{
    $Name = [System.Guid]::NewGuid().ToString()
    $OU = New-ADOrganizationalUnit -Name $Name -ProtectedFromAccidentalDeletion $false -PassThru
    return $OU
}

# Verify all required fields are set
Function Read-OU-Fields
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $OU,
        [switch]
        $Remove
    )
    $OU.Path = Read-Field -Field $OU.Path -FieldName "Path" -Default ''
    $OU.Path = Get-Parsed-Path -Path $OU.Path
    if ($Remove)
    {
        return $OU
    }
    $OU.Name = Read-Field -Field $OU.Name -FieldName "Name"
    $OU.Protect = Read-Field -Field $OU.Protect -Default $false -FieldName "Protect"
    $OU.Protect = [bool]::Parse($OU.Protect)
    $OU.Description = Read-Field -Field $OU.Description -Default '' -FieldName "Description"
    return $OU
}

# Move all children of an OU up to a temporary OU
Function Move-Children-Up
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $OU,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Temp
    )
    $Children = Get-ADObject -Filter * -SearchBase $OU -SearchScope OneLevel
    $NewChildren = @()
    foreach ($Child in $Children)
    {
        Write-Log-Abstract -Category 'INF' -MessageName 'MovingObject' -AdditionalMessage $Child.Name
        Set-ADObject -Identity $Child.DistinguishedName -ProtectedFromAccidentalDeletion:$false
        $NewChild = Move-ADObject -Identity $Child.DistinguishedName -TargetPath $Temp -PassThru
        $NewChildren += $NewChild
        Write-Log-Abstract -Category 'INF' -MessageName 'MovedObject' -AdditionalMessage $Child.Name
    }
    return $NewChildren
}

# Function to move children back to their original OU
Function Move-Children-Back
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $OU,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Children
    )
    foreach ($Child in $Children)
    {
        Write-Log-Abstract -Category 'INF' -MessageName 'MovingObject' -AdditionalMessage $Child.Name
        Move-ADObject -Identity $Child.DistinguishedName -TargetPath $OU.DistinguishedName
        Write-Log-Abstract -Category 'INF' -MessageName 'MovedObject' -AdditionalMessage $Child.Name
    }
}

# Function to write over existing OU
Function Write-Over-Existing
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $OU,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Existing
    )
    $Temp = Get-Temp-OU
    $Children = Move-Children-Up -OU $Existing.DistinguishedName -Temp $Temp.DistinguishedName
    Set-ADObject -Identity $Existing.DistinguishedName -ProtectedFromAccidentalDeletion:$false
    Remove-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Confirm:$false
    $New = New-ADOrganizationalUnit -Name $OU.Name -ProtectedFromAccidentalDeletion $OU.Protect -Path $OU.Path -Description $OU.Description -PassThru
    Move-Children-Back -OU $New -Children $Children
    Remove-ADOrganizationalUnit -Identity $Temp.DistinguishedName -Confirm:$false
}

Function New-OU
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
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
    New-ADOrganizationalUnit -Name $OU.Name -ProtectedFromAccidentalDeletion $OU.Protect -Path $OU.Path -Description $OU.Description
    Write-Log-Abstract -Category 'INF' -MessageName 'CreatedOU' -AdditionalMessage $OU.Name
}

Function Invoke-OU-Actions
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Actions
    )
    foreach ($Action in $Actions)
    {
        try
        {
            Invoke-OU-Action -Action $Action
            Write-Action-To-Action-Log -Entity 'OU' -Action $Action.Action -Id "$($Action.Name):$($Action.Path)" -Result 'Success'
        } catch
        {
            Write-Action-To-Action-Log -Entity 'OU' -Action $Action.Action -Id "$($Action.Name):$($Action.Path)" -Result 'Failed'
            if ($global:ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -Category 'WAR' -MessageName 'OUActionFailed' -AdditionalMessage $_.Exception.Message
                continue
            } elseif ($global:ADOptions.ErrorHandling -eq 3)
            {
                Write-Log-Abstract -Category 'ERR' -MessageName 'OUActionFailed' -AdditionalMessage $_.Exception.Message
                break
            }
        }
    }
}

Function Invoke-OU-Action
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Action
    )
    $Action.Action = Read-Field -Field $Action.Action -FieldName "Action"
    if ($Action.Action -eq 'Add')
    {
        New-OU -OU $Action
    } elseif ($Action.Action -eq 'Remove')
    {
        Remove-OU -OU $Action
    } elseif ($Action.Action -eq 'Modify')
    {
        Set-OU -OU $Action
    } else
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'InvalidOUAction' -AdditionalMessage $Action.Action -Throw
    }
}

Function Set-OU
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $OU
    )
    $OU = Read-OU-Fields -OU $OU
    $Path = $OU.Path
    $Existing = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $Path}
    if (-not $Existing)
    {
        throw "OUNotFound"
    }
    Write-Log-Abstract -Category 'INF' -MessageName 'ModifyingOU' -AdditionalMessage $OU.Name
    Set-ADOrganizationalUnit -Identity $Existing.DistinguishedName -ProtectedFromAccidentalDeletion:$false
    Set-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Description $OU.Description
    if ($OU.Name -ne $Existing.Name)
    {
        Rename-ADObject -Identity $Existing.DistinguishedName -NewName $OU.Name
    }
    Write-Log-Abstract -Category 'INF' -MessageName 'ModifyingOUComplete' -AdditionalMessage $OU.Name
}

Function Remove-OU
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $OU
    )
    $OU = Read-OU-Fields -OU $OU -Remove
    $Path = $OU.Path
    $Existing = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $Path}
    if (-not $Existing)
    {
        throw "OUNotFound"
    }
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovingOU' -AdditionalMessage $OU.Name
    Set-ADObject -Identity $Existing.DistinguishedName -ProtectedFromAccidentalDeletion:$false
    if ($global:ADOptions.RecursiveDelete)
    {
        Remove-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Recursive -Confirm:$false
    } else
    {
        Remove-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Confirm:$false
    }
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovedOU' -AdditionalMessage $OU.Name
}
