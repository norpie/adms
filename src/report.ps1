Function Write-Report
{
    param (
        $Report
    )
    # Report is a hashtable with keys: Success, Errored, Todo
    Write-Host "# Report:"
    Write-Host "## Todo:"
    Write-Host "$($Report.Todo)"
    if ($Report.Errored -ne 0)
    {
        Write-Host "## Errored:"
        Write-Host "$($Report.Errored)/$($Report.Todo)"
    }
    if ($Report.Success -ne 0)
    {
        Write-Host "## Success:"
        Write-Host "$($Report.Success)/$($Report.Todo)"
    }
    if ($Report.Success + $Report.Errored -lt $Report.Todo)
    {
        Write-Host "## Not ran:"
        Write-Host "$($Report.Todo - ($Report.Success + $Report.Errored))/$($Report.Todo)"
    }
}
