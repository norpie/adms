$ProjectDir = $PSCommandPath.replace('tests\integration\test1.ps1', '')

& "$ProjectDir\src\main.ps1" -Reset
& "$ProjectDir\src\main.ps1" -Entity OU -File .\example\add_action_ous.csv -MakeReport
& "$ProjectDir\src\main.ps1" -Entity User -File .\example\add_action_users.csv -MakeReport
& "$ProjectDir\src\main.ps1" -Entity Group -File .\example\add_action_groups.csv -MakeReport
& "$ProjectDir\src\main.ps1" -Entity GroupUser -File .\example\add_action_users_for_groups.csv -MakeReport
