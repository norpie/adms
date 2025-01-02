Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Function New-Select-Form
{
    param(
        $Title,
        $Options
    )
    # Create a group box for radio buttons
    $Panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $Panel.AutoSize = $true
    $Panel.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
    $Panel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown

    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Title
    $Label.AutoSize = $true
    $Panel.Controls.Add($Label)

    foreach($Option in $Options)
    {
        $RadioButton = New-Object System.Windows.Forms.RadioButton
        $RadioButton.Text = $Option
        if ($Option -eq $Options[0])
        {
            $RadioButton.Checked = $true
        }
        $Panel.Controls.Add($RadioButton)
    }
    return $Panel
}
