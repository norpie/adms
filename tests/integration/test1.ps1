$ProjectDir = $PSCommandPath.replace('tests\integration\test1.ps1', '')
$Script = "$ProjectDir\src\main.ps1"

& $Script -Reset -ConsoleVerbosity 2

# Add actions
& $Script -Entity OU -File .\example\add_action_ous.csv -MakeReport -ConsoleVerbosity 2
& $Script -Entity User -File .\example\add_action_users.csv -MakeReport -ConsoleVerbosity 2
& $Script -Entity Group -File .\example\add_action_groups.csv -MakeReport -ConsoleVerbosity 2
& $Script -Entity GroupUser -File .\example\add_action_users_for_groups.csv -MakeReport -ConsoleVerbosity 2

# Modify actions
& $Script -Entity Group -File .\example\modify_action_groups.csv -MakeReport -ConsoleVerbosity 2
& $Script -Entity User -File .\example\modify_action_users.csv -MakeReport -ConsoleVerbosity 2
& $Script -Entity OU -File .\example\modify_action_ous.csv -MakeReport -ConsoleVerbosity 2

# Remove actions
& $Script -Entity GroupUser -File .\example\remove_action_users_groups.csv -MakeReport -ConsoleVerbosity 2
& $Script -Entity Group -File .\example\remove_action_groups.csv -MakeReport -ConsoleVerbosity 2
& $Script -Entity User -File .\example\remove_action_users.csv -MakeReport -ConsoleVerbosity 2
# Use recursive here because I am too lazy to invert the file's lines
& $Script -Entity OU -File .\example\remove_action_ous.csv -MakeReport -RecursiveDelete -ConsoleVerbosity 2
