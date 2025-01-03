. $PSScriptRoot/log.ps1

Function Write-Report
{
    param (
        $ApiReport
    )
    if ($global:ActionLog.Size -eq 0)
    {
        Write-host "# Nothing to report."
        return
    }
    if ($ApiReport)
    {
        Invoke-RestMethod -Method Post -Uri $ApiReport -Body $global:ActionLog
    }
    $Entity = $global:ActionLog[0].Entity
    $Success = 0
    $Errored = 0
    $Added = 0
    $Removed = 0
    $Modified = 0
    foreach ($item in $global:ActionLog)
    {
        if ($item.Result -eq "Success")
        {
            $Success++
        } else
        {
            $Errored++
        }
        if ($item.Action -eq "Add")
        {
            $Added++
        } elseif ($item.Action -eq "Remove")
        {
            $Removed++
        } elseif ($item.Action -eq "Modify")
        {
            $Modified++
        }
    }
    $Total = $Success + $Errored
    Write-Log-Abstract -Category INF -MessageName "ReportTitle"
    Write-Log-Abstract -Category INF -MessageName "ReportSubject" -AdditionalMessage "$Entity"
    Write-Log-Abstract -Category INF -MessageName "ActionSummary"
    Write-Log-Abstract -Category INF -MessageName "ActionAddedCount" -AdditionalMessage "$Added"
    Write-Log-Abstract -Category INF -MessageName "ActionRemovedCount" -AdditionalMessage "$Removed"
    Write-Log-Abstract -Category INF -MessageName "ActionModifiedCount" -AdditionalMessage "$Modified"
    Write-Log-Abstract -Category INF -MessageName "ActionTotalCount" -AdditionalMessage "$Total"
    Write-Log-Abstract -Category INF -MessageName "CompletionSummary"
    Write-Log-Abstract -Category INF -MessageName "CompletionSuccessCount" -AdditionalMessage "$Success"
    Write-Log-Abstract -Category INF -MessageName "CompletionErrorCount" -AdditionalMessage "$Errored"
}
