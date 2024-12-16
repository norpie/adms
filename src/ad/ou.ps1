. $PSScriptRoot\..\log.ps1
. $PSScriptRoot\util.ps1

Function Read-OU-Fields
{
    param(
        [hashtable] $LoggingOptions,
        [hashtable] $LocaleOptions,
        [hashtable] $ADOptions,
        $OU
    )
    $OU.Name = Read-Field -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -ADOptions $ADOptions -Field $OU.Name
    $OU.Protect = Read-Field -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -ADOptions $ADOptions -Field $OU.Protect
    $OU.Protect = [bool]::Parse($OU.Protect)
    $OU.Description = Read-Field -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -ADOptions $ADOptions -Field $OU.Description
    return $OU
}

Function New-OU
{
    param(
        [hashtable] $LoggingOptions,
        [hashtable] $LocaleOptions,
        [hashtable] $ADOptions,
        $OU
    )
    $OU = Read-OU-Fields -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -ADOptions $ADOptions -OU $OU
    Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'INF' -MessageName 'CreatingOU' -AdditionalMessage $OU.Name
    # Get the old one if it exists
    $Name = $OU.Name
    $Existing = Get-ADOrganizationalUnit -Filter {Name -eq $Name}
    if ($Existing)
    {
        if ($ADOptions.OverwriteExisting)
        {
            Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'INF' -MessageName 'DeletingOU' -AdditionalMessage $OU.Name
            Set-ADObject -Identity $Existing.DistinguishedName -ProtectedFromAccidentalDeletion:$false -PassThru | Out-Null
            Remove-ADOrganizationalUnit -Identity $Existing.DistinguishedName -Confirm:$false
            Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'INF' -MessageName 'DeletedOU' -AdditionalMessage $OU.Name
        } elseif
            ($ADOptions.ErrorHandling -eq 3)
        {
            Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'ERR' -MessageName 'ExistingOU' -AdditionalMessage $OU.Name -Throw
        } elseif ($ADOptions.ErrorHandling -eq 2)
        {
            Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'WAR' -MessageName 'ExistingOU' -AdditionalMessage $OU.Name
            return
        }
    }
    New-ADOrganizationalUnit -Name $OU.Name -ProtectedFromAccidentalDeletion $OU.Protect -Description $OU.Description  | Out-Null
    Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'INF' -MessageName 'CreatedOU' -AdditionalMessage $OU.Name
}

Function New-OUs
{
    param (
        [hashtable] $LoggingOptions,
        [hashtable] $LocaleOptions,
        [hashtable] $ADOptions,
        [string] $OUInputFile
    )
    Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'INF' -MessageName 'StartCreateOUs'
    $OUs = Import-Csv -Path $OUInputFile
    for ($i = 0; $i -lt $OUs.Length; $i++)
    {
        try
        {
            $OU = $OUs[$i]
            New-OU -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -ADOptions $ADOptions -OU $OU
        } catch
        {
            if ($ADOptions.ErrorHandling -eq 2)
            {
                Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'WAR' -MessageName 'CreatingOUFailed' -AdditionalMessage $OU.Name
                continue
            } elseif ($ADOptions.ErrorHandling -eq 3)
            {
                Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'ERR' -MessageName 'CreatingOUFailed' -AdditionalMessage $OU.Name -Throw
            }
        }
    }
    Write-Log-Abstract -LoggingOptions $LoggingOptions -LocaleOptions $LocaleOptions -Category 'INF' -MessageName 'EndCreateOUs'
}
