# Usage

<!-- pwsh -ExecutionPolicy bypass -File .\src\main.ps1 -Entity OU -File .\example\modify_action_ous.csv -RecursiveDelete -MakeReport -OverwriteExisting-->

<!--
NAME
         main.ps1
PARAMETERS
         -LogDir            Set the directory where the log files will be stored.
         -ActionLogDir      Set the directory where the action log files will be stored.
         -LogFileName       Set the name of the log file.
         -ActionLogFileName Set the name of the action log file.
         -LogVerbosity      Set the verbosity of the log file.
         -ConsoleVerbosity  Set the verbosity of the console output.
         -Help              Display this help message.
         -ErrorHandling     Set the error handling mode.
         -Reset             Deletes all user-made OUs recursively.
         -OverwriteExisting Overwrite existing AD entities.
         -FillDefaults      Fill missing values with default values for fields that are not required.
         -RecursiveDelete   Recursively delete OUs.
         -Entity            The type of entity to process [OU Group User GroupUser]
         -File              The file to read the data from.
         -Export            Is this an export operation.
PARAMETER ALIASES
         -H                 -help
-->

**To get help at any time, use the -Help parameter or the -H alias.**

## Verbosities

- **1** - INF - Informational messages. This is the default.
- **2** - WAR - Warning messages.
- **3** - ERR - Error messages.

## Error Handling modes

- **1** - Ignore - Ignores errors and continues execution with the next item.
- **2** - Skip - Warns and continues execution with the next item.
- **3** - Stop - Stops execution and displays the error.

## Entities

- **-OU** - Organizational Unit
- **-User** - User
- **-Group** - Group
- **-GroupUser** - Refers to user's group membership

## Actions

> [!NOTE]
> Not all actions are available for all entities. E.g., the **-Modify** action is not available for the **-GroupUser** entity, as you can not really edit a membership.

- **-Add** - Adds the specified entity.
- **-Remove** - Removes the specified entity.
- **-Modify** - Updates the specified entity.

## Parameters

- **-LogDir** - The directory to write the log files to.
- **-ActionLogDir** - The directory to write the actionlogs to.
- **-LogFile** - The log file's name to write to.
- **-ActionLogFileName** - The actionlog's filename.
- **-LogVerbosity** - The verbosity of the log file. 1-3 (Default: 1)
- **-ConsoleVerbosity** - The verbosity of the console output.
- **-Help** - Display this help message.
- **-ErrorHandling** - Set the error handling mode. 1-3 (Default: 3)
- **-Reset** - Remove all user created OUs from AD, this will execute immediatly and will destroy your environment. USE WITH CAUTION.
- **-OverwriteExisting** - Overwrites existing entities when 'Add'-actioning.
- **-FillDefaults** - Fills the default values for the entities when they are missing from the CSV.
- **-RecursiveDelete** - When removing an OU, this will also remove all child entities.
- **-Entity** - The entity to act upon.
- **-File** - The CSV file to act upon.
- **-Export** - Whether this is an export operation. Creates a CSV file with 'Add' actions in the `-File` arguments location, so that you can import them using this script again.

## Aliases

- **-H** - Alias for the `-Help` parameter
