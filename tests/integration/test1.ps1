$ProjectDir = $PSCommandPath.replace('tests\integration\test1.ps1', '')

& "$ProjectDir\src\main.ps1" -Reset
& "$ProjectDir\src\main.ps1" -Entity OU -File .\example\action_ous.csv -RecursiveDelete -MakeReport -OverwriteExisting
& "$ProjectDir\src\main.ps1" -Entity User -File .\example\action_users.csv -RecursiveDelete -MakeReport -OverwriteExisting
& "$ProjectDir\src\main.ps1" -Entity Group -File .\example\action_groups.csv -RecursiveDelete -MakeReport -OverwriteExisting
& "$ProjectDir\src\main.ps1" -Entity GroupUser -File .\example\action_users_for_groups.csv -RecursiveDelete -MakeReport -OverwriteExisting
