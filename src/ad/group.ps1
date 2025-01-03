. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\..\actionlog.ps1
. $PSScriptRoot\util.ps1
. $PSScriptRoot\path.ps1

Function Read-Group-Fields
{
    param (
        $Group,
        [switch]
        $Remove
    )
    $Group.Path = Read-Field -Field $Group.Path -Default '' -FieldName 'Path'
    $Group.Path = Get-Parsed-Path -Path $Group.Path
    $Group.Name = Read-Field -Field $Group.Name -FieldName 'Name'
    if ($Remove)
    {
        return $Group
    }
    $Group.Description = Read-Field -Field $Group.Description -Default '' -FieldName 'Description'
    $Group.Scope = Read-Field -Field $Group.Scope -Default 'DomainLocal' -FieldName 'Scope'
    $Group.Type = Read-Field -Field $Group.Type -Default 'Security' -FieldName 'Type'
    return $Group
}

Function Invoke-Group-Actions
{
    param (
        $Actions
    )
    foreach ($Action in $Actions)
    {
        try
        {
            Invoke-Group-Action -Action $Action
        } catch
        {
            Write-Action-To-Action-Log -Entity 'Group' -Action $Action.Action -Id $Action.Name -Result 'Failed'
            if ($global:ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -Category 'WAR' -MessageName 'GroupActionFailed' -AdditionalMessage $_.Exception.Message
                continue
            } elseif ($global:ADOptions.ErrorHandling -eq 3)
            {
                Write-Log-Abstract -Category 'ERR' -MessageName 'GroupActionFailed' -AdditionalMessage $_.Exception.Message
                break
            }
        }
        Write-Action-To-Action-Log -Entity 'Group' -Action $Action.Action -Id $Action.Name -Result 'Success'
    }
}

Function Invoke-Group-Action
{
    param (
        $Action
    )
    $Action.Action = Read-Field -Field $Action.Action -FieldName "Action"
    if ($Action.Action -eq 'Add')
    {
        New-Group -Group $Action
    } elseif ($Action.Action -eq 'Remove')
    {
        Remove-Group -Group $Action
    } else
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'InvalidGroupAction' -AdditionalMessage $Action.Action -Throw
    }
}

Function New-Group
{
    param (
        $Group
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'AddingGroup' -AdditionalMessage $Group.Name
    $Group = Read-Group-Fields -Group $Group
    $Name = $Group.Name
    $Existing = Get-ADGroup -Filter {Name -eq $Name}
    if ($Existing)
    {
        Write-Log-Abstract -Category 'WAR' -MessageName 'ExistingGroup' -AdditionalMessage $Group.Name
        if ($global:ADOptions.OverwriteExisting)
        {
            Remove-ADGroup -Confirm:$false -Identity $Existing
            Write-Log-Abstract -Category 'INF' -MessageName 'RemovedGroup' -AdditionalMessage $Name
        } elseif
            ($global:ADOptions.ErrorHandling -eq 3)
        {
            Write-Log-Abstract -Category 'ERR' -MessageName 'ExistingGroup' -AdditionalMessage $Group.Name -Throw
        } elseif ($global:ADOptions.ErrorHandling -eq 2)
        {
            Write-Log-Abstract -Category 'WAR' -MessageName 'ExistingGroup' -AdditionalMessage $Group.Name
            return
        }
    }
    New-ADGroup -Name $Group.Name -Path $Group.Path -GroupScope $Group.Scope -GroupCategory $Group.Type -Description $Group.Description
    Write-Log-Abstract -Category 'INF' -MessageName 'AddedGroup' -AdditionalMessage $Name
}

Function Remove-Group
{
    param (
        $Group
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovingGroup' -AdditionalMessage $Group.Name
    $Group = Read-Group-Fields -Group $Group -Remove
    $Name = $Group.Name
    $Existing = Get-ADGroup -Filter {Name -eq $Name}
    if ($Existing)
    {
        Remove-ADGroup -Confirm:$false -Identity $Existing
        Write-Log-Abstract -Category 'INF' -MessageName 'RemovedGroup' -AdditionalMessage $Name
    } elseif ($global:ADOptions.ErrorHandling -eq 3)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingGroup' -AdditionalMessage $Group.Name -Throw
    } elseif ($global:ADOptions.ErrorHandling -eq 2)
    {
        Write-Log-Abstract -Category 'WAR' -MessageName 'NonExistingGroup' -AdditionalMessage $Group.Name
    }
}
