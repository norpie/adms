. $PSScriptRoot\radio.ps1
. $PSScriptRoot\..\locale.ps1

$global:File = ""
$Locale = Get-Best-Locale

$global:LocaleOptions = @{
    Locale = $Locale
    LocaleData = Read-Locale -Locale $Locale
}

# Helper function to convert "enums" to number
Function Convert-Enum-To-Num
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Enum
    )
    switch ($Enum)
    {
        "INF"
        { return 1
        }
        "WAR"
        { return 2
        }
        "ERR"
        { return 3
        }
        "Stop"
        { return 3
        }
        "Skip"
        { return 2
        }
        "Ignore"
        {
            return 1
        }
        Default
        {
            return 999
        }
    }
}

# Helper function to convert a radio button selection to a string
Function Convert-Radio-To-String
{
    param (
        $RadioSelection
    )
    foreach ($Item in $RadioSelection.Controls)
    {
        if ($Item.Checked)
        {
            return $Item.Text
        }
    }
}

# Main form
$Main = New-Object System.Windows.Forms.Form
$Main.Text = "ADMS GUI"
$Main.Size = New-Object System.Drawing.Size(800,600)
$Main.StartPosition = "CenterScreen"

# A panel to organize, autosize, and flow
$Panel = New-Object System.Windows.Forms.FlowLayoutPanel
$Panel.Dock = [System.Windows.Forms.DockStyle]::Fill
$Panel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$Main.Controls.Add($Panel)

# Checkbox to control whether this is an export op.
$ExportCheckbox = New-Object System.Windows.Forms.CheckBox
$ExportCheckbox.Text = Get-Message "GUIExport"
$ExportCheckbox.AutoSize = $true
$Panel.Controls.Add($ExportCheckbox)

$BrowseLabel = New-Object System.Windows.Forms.Label
$BrowseLabel.Text = Get-Message "GUIImport"
$BrowseLabel.AutoSize = $true
$Panel.Controls.Add($BrowseLabel)

$BrowseButton = New-Object System.Windows.Forms.Button
$BrowseButton.Text = Get-Message "GUIBrowse"
$BrowseLabel.AutoSize = $true
$Panel.Controls.Add($BrowseButton)

$ApiReportLabel = New-Object System.Windows.Forms.Label
$ApiReportLabel.Text = Get-Message "GUIReport"
$ApiReportLabel.AutoSize = $true
$Panel.Controls.Add($ApiReportLabel)

# Textinput for an API address
$ApiReportTextInput = New-Object System.Windows.Forms.TextBox
$ApiReportTextInput.Text = ""
$ApiReportTextInput.AutoSize = $true
$Panel.Controls.Add($ApiReportTextInput)

# A panel for all of the radio selections
$RadioPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$RadioPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$RadioPanel.Size = New-Object System.Drawing.Size(200, 200)
$RadioPanel.AutoSize = $true
$RadioPanel.Auto
$RadioPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$Panel.Controls.Add($RadioPanel)

$EntityTitle = Get-Message "GUIEntity"
$EntitySelection = New-Select-Form -Title $EntityTitle -Options @(
    "OU",
    "User",
    "Group",
    "GroupUser"
)

$RadioPanel.Controls.Add($EntitySelection)

$ConsoleVerbosityTitle = Get-Message "GUIConsoleVerbosity"
$ConsoleVerbositySelection = New-Select-Form -Title $ConsoleVerbosityTitle -Options @(
    "INF",
    "WAR",
    "ERR"
)

$RadioPanel.Controls.Add($ConsoleVerbositySelection)

$LogVerbosityTitle = Get-Message "GUILogVerbosity"
$LogVerbositySelection = New-Select-Form -Title $LogVerbosityTitle -Options @(
    "INF",
    "WAR",
    "ERR"
)

$RadioPanel.Controls.Add($LogVerbositySelection)

$ErrorHandlingTitile = Get-Message "GUIErrorHandling"
$ErrorHandlingSelection = New-Select-Form -Title $ErrorHandlingTitile -Options @(
    "Stop"
    "Skip",
    "Ignore"
)

$RadioPanel.Controls.Add($ErrorHandlingSelection)

# Panel for all the switches
$SwitchPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$SwitchPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$SwitchPanel.AutoSize = $true
$SwitchPanel.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink

$RadioPanel.Controls.Add($SwitchPanel)

$OverwriteExistingCheckbox = New-Object System.Windows.Forms.CheckBox
$OverwriteExistingCheckbox.Text = Get-Message "GUIOverwrite"
$OverwriteExistingCheckbox.AutoSize = $true
$SwitchPanel.Controls.Add($OverwriteExistingCheckbox)

$FillDefaultsCheckbox = New-Object System.Windows.Forms.CheckBox
$FillDefaultsCheckbox.Text = Get-Message "GUIFillDefaults"
$FillDefaultsCheckbox.AutoSize = $true
$SwitchPanel.Controls.Add($FillDefaultsCheckbox)

$RecursiveDeleteCheckbox = New-Object System.Windows.Forms.CheckBox
$RecursiveDeleteCheckbox.Text = Get-Message "GUIRecursiveDelete"
$RecursiveDeleteCheckbox.AutoSize = $true
$SwitchPanel.Controls.Add($RecursiveDeleteCheckbox)

# Browse to a file using explorer.exe
$BrowseButton.Add_Click({
        $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $FileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
        if ($FileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $BrowseLabel.Text = $FileDialog.FileName
            $global:File = $FileDialog.FileName
        }
    })

$ExecuteButton = New-Object System.Windows.Forms.Button
$ExecuteButton.Text = Get-Message "GUIExecute"
$ExecuteButton.AutoSize = $true
# Run the command with all the options
$ExecuteButton.Add_Click({
        $Command = ".\src\main.ps1"
        if ($ExportCheckbox.Checked)
        {
            $Command += " -Export"
        }
        if ($File -eq "")
        {
            Write-Host "No file selected"
            return
        }
        $Command += " -File $File"
        $Entity = Convert-Radio-To-String -RadioSelection $EntitySelection
        $Command += " -Entity $Entity"
        $ConsoleVerbosity = Convert-Radio-To-String -RadioSelection $ConsoleVerbositySelection
        $Command += " -ConsoleVerbosity $(Convert-Enum-To-Num -Enum $ConsoleVerbosity)"
        $LogVerbosity = Convert-Radio-To-String -RadioSelection $LogVerbositySelection
        $Command += " -LogVerbosity $(Convert-Enum-To-Num -Enum $LogVerbosity)"
        $ErrorHandling = Convert-Radio-To-String -RadioSelection $ErrorHandlingSelection
        $Command += " -ErrorHandling $(Convert-Enum-To-Num -Enum $ErrorHandling)"
        if ($OverwriteExistingCheckbox.Checked)
        {
            $Command += " -OverwriteExisting"
        }
        if ($FillDefaultsCheckbox.Checked)
        {
            $Command += " -FillDefaults"
        }
        if ($RecursiveDeleteCheckbox.Checked)
        {
            $Command += " -Recursive"
        }
        if ($ApiReportTextInput.Text -ne "")
        {
            $Command += " -MakeReport -ApiReport $($ApiReportTextInput.Text)"
        }
        Invoke-Expression $Command
    })

$Panel.Controls.Add($ExecuteButton)

$Main.Topmost = $true
$Main.ShowDialog()
