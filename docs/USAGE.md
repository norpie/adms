# Usage

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

## Parameters

- **-LogDir** - **DIR** The directory to write the log files to.
- **-ActionLogDir** - **DIR** The directory to write the actionlogs to.
- **-LogFile** - **String** The log file's name to write to.
- **-ActionLogFileName** - **String** The actionlog's filename.
- **-LogVerbosity** - **Int** The verbosity of the log file. 1-3 (Default: 1)
- **-ConsoleVerbosity** - **Int** The verbosity of the console output.
- **-Help** - **Switch** Display the help message.
- **-ErrorHandling** - **Int** Set the error handling mode. 1-3 (Default: 3)
- **-Reset** - **Switch** Remove all user created OUs from AD, this will execute immediately and will destroy your environment. USE WITH CAUTION.
- **-OverwriteExisting** - **Switch** Overwrites existing entities when 'Add'-actioning.
- **-FillDefaults** - **Switch** Fills the default values for the entities when they are missing from the CSV where possible.
- **-RecursiveDelete** - **Switch** When removing an OU, this will also remove all child entities.
- **-Entity** - **Enum** The entity to act upon. [OU, User, Group, GroupUser]
- **-File** - **FILE** The CSV file to act upon.
- **-Export** - **Switch** Whether this is an export operation. Creates a CSV file with 'Add' actions in the `-File` arguments location, so that you can import them using this script again.
- **-MakeReport** - **Switch** Prints a summary of all the actions performed at the end.
- **-ApiReport** - **String** Send the summary of all actions performed to a specified endpoint in a POST.

## Aliases

- **-H** - **Switch** Alias for the `-Help` parameter

## Examples

### Example 1

> Import all OUs from the OUs.csv file.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv
```

### Example 2

> Import all OUs from the OUs.csv file and print a summary of all the actions performed at the end.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv -MakeReport
```

### Example 3

> Import all OUs from the OUs.csv file and only print errors to the console.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv -ConsoleVerbosity 3
```

### Example 4

> Export all OUs to the OUs.csv file.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv -Export
```
