Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Function New-Button
{
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [string]$DialogResult = "OK"
    )

    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point($X, $Y)
    $Button.Size = New-Object System.Drawing.Size($Width, $Height)
    $Button.Text = $Text
    if ($DialogResult -eq "OK")
    {
        $Button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    } else
    {
        $Button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    }
    return $Button
}

Function New-Label
{
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )

    $Label = New-Object System.Windows.Forms.Label
    $Label.Location = New-Object System.Drawing.Point($X, $Y)
    $Label.Size = New-Object System.Drawing.Size($Width, $Height)
    $Label.Text = $Text
    return $Label
}

$Main = New-Object System.Windows.Forms.Form
$Main.Text = "ADMS GUI"
$Main.Size = New-Object System.Drawing.Size(800,600)
$Main.StartPosition = "CenterScreen"

# Bottom left corner
$OkButton = New-Button -Text "OK" -X 10 -Y 10 -Width 75 -Height 23
# Bottom right corner
$CancelButton = New-Button -Text "Cancel" -X 715 -Y 10 -Width 75 -Height 23 -DialogResult "Cancel"

$Main.Controls.Add($OkButton)
$Main.AcceptButton = $OkButton

$Main.Controls.Add($CancelButton)
$Main.CancelButton = $CancelButton

$Main.Controls.Add((New-Label -Text "Please enter the information in the space below:" -X 10 -Y 40 -Width 300 -Height 20))

$Main.Topmost = $true
$result = $Main.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    Write-Host "OK"
} else
{
    Write-Host "Cancel"
}
