. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\util.ps1
. $PSScriptRoot\path.ps1

Function Invoke-GroupUser-Actions
{
    param (
        $Actions
    )
    foreach ($Action in $Actions)
    {
        try
        {
            Invoke-GroupUser-Action -Action $Action
        } catch
        {
            if ($global:ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -Category 'WAR' -MessageName 'UserGroupActionFailed' -AdditionalMessage $_.Exception.Message
            } elseif ($global:ADOptions.ErrorHandling -eq 3)
            {
                Write-Log-Abstract -Category 'ERR' -MessageName 'UserGroupActionFailed' -AdditionalMessage $_.Exception.Message -Throw
            }
            continue
        }
    }
}

Function Invoke-GroupUser-Action
{
    param (
        $Action
    )
    $Action.Action = Read-Field -Field $Action.Action -FieldName "Action"
    $Action.UserName = Read-Field -Field $Action.UserName -FieldName "UserName"
    $Action.GroupName = Read-Field -Field $Action.GroupName -FieldName "GroupName"

    if ($Action.Action -eq 'Add')
    {
        Add-UserToGroup -UserName $Action.UserName -GroupName $Action.GroupName
    } elseif ($Action.Action -eq 'Remove')
    {
        Remove-UserFromGroup -UserName $Action.UserName -GroupName $Action.GroupName
    } else
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'InvalidUserGroupAction' -AdditionalMessage $Action.Action -Throw
    }
}

Function Add-UserToGroup
{
    param (
        $UserName,
        $GroupName
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'AddingUserToGroup' -AdditionalMessage "User: $UserName, Group: $GroupName"
    $User = Get-ADUser -Filter {Name -eq $UserName}
    $Group = Get-ADGroup -Filter {Name -eq $GroupName}

    if (-not $User)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingUser' -AdditionalMessage $UserName -Throw
    }
    if (-not $Group)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingGroup' -AdditionalMessage $GroupName -Throw
    }

    Add-ADGroupMember -Identity $Group -Members $User -Confirm:$false
    Write-Log-Abstract -Category 'INF' -MessageName 'AddedUserToGroup' -AdditionalMessage "User: $UserName, Group: $GroupName"
}

Function Remove-UserFromGroup
{
    param (
        $UserName,
        $GroupName
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovingUserFromGroup' -AdditionalMessage "User: $UserName, Group: $GroupName"
    $User = Get-ADUser -Filter {Name -eq $UserName}
    $Group = Get-ADGroup -Filter {Name -eq $GroupName}

    if (-not $User)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingUser' -AdditionalMessage $UserName -Throw
    }
    if (-not $Group)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingGroup' -AdditionalMessage $GroupName -Throw
    }

    Remove-ADGroupMember -Identity $Group -Members $User -Confirm:$false
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovedUserFromGroup' -AdditionalMessage "User: $UserName, Group: $GroupName"
}
