param (
    $ConsoleVerbosity = 2
)

$ProjectDir = $PSCommandPath.replace('tests\integration\export.test.ps1', '')
$Script = "$ProjectDir\src\main.ps1"

& $Script -Reset -ConsoleVerbosity $ConsoleVerbosity

# Add actions
& $Script -Entity OU -File .\example\add_action_ous.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity User -File .\example\add_action_users.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity Group -File .\example\add_action_groups.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity GroupUser -File .\example\add_action_users_for_groups.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity

# Exports
& $Script -Entity OU -File .\example\export_ous.csv -Export -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity User -File .\example\export_user.csv -Export -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity Group -File .\example\export_group.csv -Export -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity GroupUsers -File .\example\export_group_user.csv -Export -ConsoleVerbosity $ConsoleVerbosity
