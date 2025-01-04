. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\..\actionlog.ps1
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
            Write-Action-To-Action-Log -Entity 'UserToGroup' -Action $Action.Action -Id "$($Action.UserPath):$($Action.GroupPath)" -Result 'Failed'
            if ($global:ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -Category 'WAR' -MessageName 'UserGroupActionFailed' -AdditionalMessage $_.Exception.Message
                continue
            } elseif ($global:ADOptions.ErrorHandling -eq 3)
            {
                Write-Log-Abstract -Category 'ERR' -MessageName 'UserGroupActionFailed' -AdditionalMessage $_.Exception.Message
                break
            }
        }
        Write-Action-To-Action-Log -Entity 'UserToGroup' -Action $Action.Action -Id "$($Action.UserPath):$($Action.GroupPath)" -Result 'Success'
    }
}

Function Invoke-GroupUser-Action
{
    param (
        $Action
    )
    $Action.Action = Read-Field -Field $Action.Action -FieldName "Action"
    $Action.UserPath = Read-Field -Field $Action.UserPath -FieldName "UserPath"
    $Action.UserPath = Get-Parsed-Path -Path $Action.UserPath -LastCN
    $Action.GroupPath = Read-Field -Field $Action.GroupPath -FieldName "GroupPath"
    $Action.GroupPath = Get-Parsed-Path -Path $Action.GroupPath -LastCN

    if ($Action.Action -eq 'Add')
    {
        Add-UserToGroup -UserPath $Action.UserPath -GroupPath $Action.GroupPath
    } elseif ($Action.Action -eq 'Remove')
    {
        Remove-UserFromGroup -UserPath $Action.UserPath -GroupPath $Action.GroupPath
    } else
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'InvalidUserGroupAction' -AdditionalMessage $Action.Action -Throw
    }
}

Function Add-UserToGroup
{
    param (
        $UserPath,
        $GroupPath
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'AddingUserToGroup' -AdditionalMessage "User: $UserPath, Group: $GroupPath"
    $User = Get-ADUser -Filter {Name -eq $UserPath}
    $Group = Get-ADGroup -Filter {Name -eq $GroupPath}

    if (-not $User)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingUser' -AdditionalMessage $UserPath -Throw
    }
    if (-not $Group)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingGroup' -AdditionalMessage $GroupPath -Throw
    }

    Add-ADGroupMember -Identity $Group -Members $User -Confirm:$false
    Write-Log-Abstract -Category 'INF' -MessageName 'AddedUserToGroup' -AdditionalMessage "User: $UserPath, Group: $GroupPath"
}

Function Remove-UserFromGroup
{
    param (
        $UserPath,
        $GroupPath
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovingUserFromGroup' -AdditionalMessage "User: $UserPath, Group: $GroupPath"
    $Group = Get-ADGroup -Filter {DistinguishedName -eq $GroupPath}
    $User = Get-ADUser -Filter {DistinguishedName -eq $UserPath}

    if (-not $User)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingUser' -AdditionalMessage $UserPath -Throw
    }

    if (-not $Group)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingGroup' -AdditionalMessage $GroupPath -Throw
    }

    Remove-ADGroupMember -Identity $Group -Members $User -Confirm:$false
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovedUserFromGroup' -AdditionalMessage "User: $UserPath, Group: $GroupPath"
}
