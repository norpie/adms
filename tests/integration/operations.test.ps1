param (
    $ConsoleVerbosity = 2
)

$ProjectDir = $PSCommandPath.replace('tests\integration\test1.ps1', '')
$Script = "$ProjectDir\src\main.ps1"

& $Script -Reset -ConsoleVerbosity $ConsoleVerbosity

# Add actions
& $Script -Entity OU -File .\example\add_action_ous.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity User -File .\example\add_action_users.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity Group -File .\example\add_action_groups.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity GroupUser -File .\example\add_action_users_for_groups.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity

# Modify actions
& $Script -Entity Group -File .\example\modify_action_groups.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity User -File .\example\modify_action_users.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity OU -File .\example\modify_action_ous.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity

# Remove actions
& $Script -Entity GroupUser -File .\example\remove_action_users_groups.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity Group -File .\example\remove_action_groups.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
& $Script -Entity User -File .\example\remove_action_users.csv -MakeReport -ConsoleVerbosity $ConsoleVerbosity
# Use recursive here because I am too lazy to match the removes above, otherwise we error with: "The operation cannot be performed because child objects..."
& $Script -Entity OU -File .\example\remove_action_ous.csv -MakeReport -RecursiveDelete -ConsoleVerbosity $ConsoleVerbosity
