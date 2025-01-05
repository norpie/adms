param (
    [Parameter(Mandatory = $true)]
    [int]
    $Step
)

$Script = "$PSScriptRoot\..\src\main.ps1"

switch ($Step)
{
    0
    {
        & $Script -Reset
    }
    1
    {
        Write-Host "Executing: $Script -Entity OU -File 'add_action_ous.csv'"
        & $Script -Entity OU -File "add_action_ous.csv"
    }
    2
    {
        Write-Host "Executing: $Script -Entity User -File 'add_action_users.csv'"
        & $Script -Entity User -File "add_action_users.csv"
    }
    3
    {
        Write-Host "Executing: $Script -Entity Group -File 'add_action_groups.csv'"
        & $Script -Entity Group -File "add_action_groups.csv"
    }
    4
    {
        Write-Host "Executing: $Script -Entity GroupUser -File 'add_action_users_for_groups.csv'"
        & $Script -Entity GroupUser -File "add_action_users_for_groups.csv"
    }
    5
    {
        Write-Host "Executing: $Script -Entity OU -File 'modify_action_ous.csv'"
        & $Script -Entity OU -File "modify_action_ous.csv"
    }
    6
    {
        Write-Host "Executing: $Script -Entity User -File 'modify_action_users.csv'"
        & $Script -Entity User -File "modify_action_users.csv"
    }
    7
    {
        Write-Host "Executing: $Script -Entity Group -File 'modify_action_groups.csv'"
        & $Script -Entity Group -File "modify_action_groups.csv"
    }
    8
    {
        Write-Host "Executing: $Script -Entity GroupUser -File 'modify_action_users_groups.csv'"
        & $Script -Entity GroupUser -File "modify_action_users_groups.csv"
    }
    9
    {
        Write-Host "Executing: $Script -Entity GroupUser -File 'remove_action_users_groups.csv'"
        & $Script -Entity GroupUser -File "remove_action_users_groups.csv"
    }
    10
    {
        Write-Host "Executing: $Script -Entity Group -File 'remove_action_groups.csv'"
        & $Script -Entity Group -File "remove_action_groups.csv"
    }
    11
    {
        Write-Host "Executing: $Script -Entity User -File 'remove_action_users.csv'"
        & $Script -Entity User -File "remove_action_users.csv"
    }
    12
    {
        Write-Host "Executing: $Script -Entity OU -File 'remove_action_ous.csv' -RecursiveDelete"
        & $Script -Entity OU -File "remove_action_ous.csv" -RecursiveDelete
    }
}
