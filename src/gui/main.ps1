Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
. $PSScriptRoot\radio.ps1

$global:File = ""

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

$Main = New-Object System.Windows.Forms.Form
$Main.Text = "ADMS GUI"
$Main.Size = New-Object System.Drawing.Size(800,600)
$Main.StartPosition = "CenterScreen"

$Panel = New-Object System.Windows.Forms.FlowLayoutPanel
$Panel.Dock = [System.Windows.Forms.DockStyle]::Fill
$Panel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$Main.Controls.Add($Panel)

$ExportCheckbox = New-Object System.Windows.Forms.CheckBox
$ExportCheckbox.Text = "Export (This overwrites the file browsed to bellow)"
$ExportCheckbox.AutoSize = $true
$Panel.Controls.Add($ExportCheckbox)

$BrowseLabel = New-Object System.Windows.Forms.Label
$BrowseLabel.Text = "Select the import file"
$BrowseLabel.AutoSize = $true
$Panel.Controls.Add($BrowseLabel)

$BrowseButton = New-Object System.Windows.Forms.Button
$BrowseButton.Text = "Browse"
$BrowseLabel.AutoSize = $true
$Panel.Controls.Add($BrowseButton)

$ApiReportLabel = New-Object System.Windows.Forms.Label
$ApiReportLabel.Text = "Report to endpoint (optional)"
$ApiReportLabel.AutoSize = $true
$Panel.Controls.Add($ApiReportLabel)

$ApiReportTextInput = New-Object System.Windows.Forms.TextBox
$ApiReportTextInput.Text = ""
$ApiReportTextInput.AutoSize = $true
$Panel.Controls.Add($ApiReportTextInput)


$RadioPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$RadioPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$RadioPanel.Size = New-Object System.Drawing.Size(200, 200)
$RadioPanel.AutoSize = $true
$RadioPanel.Auto
$RadioPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$Panel.Controls.Add($RadioPanel)

$EntitySelection = New-Select-Form -Title "Entity" -Options @(
    "OU",
    "User",
    "Group",
    "GroupUser"
)

$RadioPanel.Controls.Add($EntitySelection)

$ConsoleVerbositySelection = New-Select-Form -Title "Console Verbosity" -Options @(
    "INF",
    "WAR",
    "ERR"
)

$RadioPanel.Controls.Add($ConsoleVerbositySelection)

$LogVerbositySelection = New-Select-Form -Title "Log Verbosity" -Options @(
    "INF",
    "WAR",
    "ERR"
)

$RadioPanel.Controls.Add($LogVerbositySelection)

$ErrorHandlingSelection = New-Select-Form -Title "Error Handling" -Options @(
    "Stop"
    "Skip",
    "Ignore"
)

$RadioPanel.Controls.Add($ErrorHandlingSelection)

$SwitchPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$SwitchPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$SwitchPanel.AutoSize = $true
$SwitchPanel.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink

$RadioPanel.Controls.Add($SwitchPanel)

$OverwriteExistingCheckbox = New-Object System.Windows.Forms.CheckBox
$OverwriteExistingCheckbox.Text = "Overwrite existing entities"
$OverwriteExistingCheckbox.AutoSize = $true
$SwitchPanel.Controls.Add($OverwriteExistingCheckbox)

$FillDefaultsCheckbox = New-Object System.Windows.Forms.CheckBox
$FillDefaultsCheckbox.Text = "Fill in default values"
$FillDefaultsCheckbox.AutoSize = $true
$SwitchPanel.Controls.Add($FillDefaultsCheckbox)

$RecursiveDeleteCheckbox = New-Object System.Windows.Forms.CheckBox
$RecursiveDeleteCheckbox.Text = "Recursively delete entities"
$RecursiveDeleteCheckbox.AutoSize = $true
$SwitchPanel.Controls.Add($RecursiveDeleteCheckbox)

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
$ExecuteButton.Text = "Execute"
$ExecuteButton.AutoSize = $true
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
        if ($ApiReportTextInput.Text -ne "") {
            $Command += " -MakeReport -ApiReport $($ApiReportTextInput.Text)"
        }
        # Run the command
        Invoke-Expression $Command
    })

$Panel.Controls.Add($ExecuteButton)

$OutputTextBox = New-Object System.Windows.Forms.TextBox
$OutputTextBox.Multiline = $true
$OutputTextBox.ScrollBars = "Vertical"
$OutputTextBox.ReadOnly = $true
$OutputTextBox.AutoSize = $true
$OutputTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$OutputTextBox.Text = ""

$Panel.Controls.Add($OutputTextBox)

$Main.Topmost = $true
$Main.ShowDialog()
