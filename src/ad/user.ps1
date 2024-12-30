. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\util.ps1
. $PSScriptRoot\path.ps1

Function Read-User-Fields
{
    param (
        $User,
        [switch]
        $Remove
    )
    $User.Path = Read-Field -Field $User.Path -Default '' -FieldName 'Path'
    $User.Path = Get-Parsed-Path -Path $User.Path
    $User.Name = Read-Field -Field $User.Name -FieldName 'Name'
    if ($Remove)
    {
        return $User
    }
    $User.DisplayName = Read-Field -Field $User.DisplayName -FieldName 'DisplayName'
    $User.Password = Read-Field -Field $User.Password -FieldName 'Password'
    $User.Password = ConvertTo-SecureString -String $User.Password -AsPlainText -Force
    $User.Email = Read-Field -Field $User.Email -Default '' -FieldName 'Email'
    $User.Department = Read-Field -Field $User.Department -Default '' -FieldName 'Department'
    $User.Status = Read-Field -Field $User.Status -Default 'Active' -FieldName 'Status'
    return $User
}

Function Invoke-User-Actions
{
    param (
        $Actions
    )
    foreach ($Action in $Actions)
    {
        try
        {
            Invoke-User-Action -Action $Action
        } catch
        {
            if ($global:ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -Category 'WAR' -MessageName 'UserActionFailed' -AdditionalMessage $_.Exception.Message
                continue
            } elseif ($global:ADOptions.ErrorHandling -eq 3)
            {
                Write-Log-Abstract -Category 'ERR' -MessageName 'UserActionFailed' -AdditionalMessage $_.Exception.Message -Throw
            }
        }
    }
}

Function Invoke-User-Action
{
    param (
        $Action
    )
    $Action.Action = Read-Field -Field $Action.Action -FieldName "Action"
    if ($Action.Action -eq 'Add')
    {
        New-User -User $Action
    } elseif ($Action.Action -eq 'Remove')
    {
        Remove-User -User $Action
    } else
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'InvalidUserAction' -AdditionalMessage $Action.Action -Throw
    }
}

Function New-User
{
    param (
        $User
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'AddingUser' -AdditionalMessage $User.Name
    $User = Read-User-Fields -User $User
    $Name = $User.Name
    $Existing = Get-ADUser -Filter {Name -eq $Name}
    if ($Existing)
    {
        Write-Log-Abstract -Category 'WAR' -MessageName 'ExistingUser' -AdditionalMessage $User.Name
        if ($global:ADOptions.OverwriteExisting)
        {
            Remove-ADUser -Confirm:$false -Identity $Existing
            Write-Log-Abstract -Category 'INF' -MessageName 'RemovedUser' -AdditionalMessage $Name
        } elseif
            ($global:ADOptions.ErrorHandling -eq 3)
        {
            Write-Log-Abstract -Category 'ERR' -MessageName 'ExistingUser' -AdditionalMessage $User.Name -Throw
        } elseif ($global:ADOptions.ErrorHandling -eq 2)
        {
            Write-Log-Abstract -Category 'WAR' -MessageName 'ExistingUser' -AdditionalMessage $User.Name
            return
        }
    }
    New-ADUser -Name $User.Name -DisplayName $User.DisplayName -AccountPassword $User.Password -Path $User.Path
    Write-Log-Abstract -Category 'INF' -MessageName 'AddedUser' -AdditionalMessage $Name
}

Function Remove-User
{
    param (
        $User
    )
    Write-Log-Abstract -Category 'INF' -MessageName 'RemovingUser' -AdditionalMessage $User.Name
    $User = Read-User-Fields -User $User -Remove
    $Name = $User.Name
    $Existing = Get-ADUser -Filter {Name -eq $Name}
    if ($Existing)
    {
        Remove-ADUser -Confirm:$false -Identity $Existing
        Write-Log-Abstract -Category 'INF' -MessageName 'RemovedUser' -AdditionalMessage $Name
    } elseif ($global:ADOptions.ErrorHandling -eq 3)
    {
        Write-Log-Abstract -Category 'ERR' -MessageName 'NonExistingUser' -AdditionalMessage $User.Name -Throw
    } elseif ($global:ADOptions.ErrorHandling -eq 2)
    {
        Write-Log-Abstract -Category 'WAR' -MessageName 'NonExistingUser' -AdditionalMessage $User.Name
    }
}
