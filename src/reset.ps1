. $PSScriptRoot/log.ps1

function Reset
{
    Write-Log-Abstract -Category INF -MessageName "Resetting"
    $OUs = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | Where-Object { $_.Name -notin $DefaultOUs } | Sort-Object -Descending { $_.DistinguishedName.Length }
    foreach ($OU in $OUs)
    {
        Write-Log-Abstract -Category INF -MessageName "RemovingOU" -AdditionalMessage $OU.Name
        Set-ADObject -Identity $OU.DistinguishedName -ProtectedFromAccidentalDeletion:$false
        Remove-ADOrganizationalUnit -Identity $OU.DistinguishedName -Recursive -Confirm:$false
        Write-Log-Abstract -Category INF -MessageName "RemovedOU" -AdditionalMessage $OU.Name
    }
    Write-Log-Abstract -Category INF -MessageName "Resetted"
}
