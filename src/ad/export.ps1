. $PSScriptRoot\path.ps1

$DefaultOUs = @(
    "Builtin",
    "Computers",
    "Domain Controllers",
    "ForeignSecurityPrincipals",
    "Managed Service Accounts",
    "Users"
)

$DefaultUsers = @(
    "Administrator",
    "Guest",
    "krbtgt"
)

$DefaultGroups = @(
    "Account Operators",
    "Administrators",
    "Backup Operators",
    "Cert Publishers",
    "Domain Admins",
    "Domain Computers",
    "Domain Controllers",
    "Domain Guests",
    "Domain Users",
    "Enterprise Admins",
    "Group Policy Creator Owners",
    "Guests",
    "Incoming Forest Trust Builders",
    "Network Configuration Operators",
    "Pre-Windows 2000 Compatible Access",
    "Print Operators",
    "Read-Only Domain Controllers",
    "Remote Desktop Users",
    "Replicator",
    "Schema Admins",
    "Server Operators",
    "Users",
    "Performance Monitor Users",
    "Performance Log Users",
    "Distributed COM Users",
    "IIS_IUSRS",
    "Cryptographic Operators",
    "Event Log Readers",
    "Certificate Service DCOM Access",
    "RDS Remote Access Servers",
    "RDS Endpoint Servers",
    "RDS Management Servers",
    "Hyper-V Administrators",
    "Access Control Assistance Operators",
    "Remote Management Users",
    "Storage Replica Administrators",
    "RAS and IAS Servers",
    "Windows Authorization Access Group",
    "Terminal Server License Servers",
    "Allowed RODC Password Replication Group",
    "Denied RODC Password Replication Group",
    "Enterprise Read-only Domain Controllers",
    "Cloneable Domain Controllers",
    "Protected Users",
    "Key Admins",
    "Enterprise Key Admins",
    "DnsAdmins",
    "DnsUpdateProxy"
)

# Check which entity to export, and execute respective function
Function Invoke-Export
{
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Entity,
        [Parameter(Mandatory=$true)]
        [string]
        $File
    )
    if ($Entity -eq "OU")
    {
        Export-OUs -File $File
    } elseif ($Entity -eq "User")
    {
        Export-Users -File $File
    } elseif ($Entity -eq "Group")
    {
        Export-Groups -File $File
    } elseif ($Entity -eq "GroupUsers")
    {
        Export-GroupUsers -File $File
    } else
    {
        Write-Log-Abstract -Category ERR -MessageName "UnknownEntity" -AdditionalMessage $Entity -Exit
    }
}

Function Export-OUs
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$File
    )
    Write-Log-Abstract -Category INF -MessageName "ExportingOUs" -AdditionalMessage $File
    $OUs = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | Where-Object { $_.Name -notin $DefaultOUs }
    $CustomOUs = @()
    foreach ($OU in $OUs)
    {
        Write-Log-Abstract -Category INF -MessageName "ExportingOU" -AdditionalMessage $OU.Name
        $ADPath = Get-AD-Compatible-Path -Path $OU.DistinguishedName
        $ADPath = $ADPath.Replace("/$($OU.Name)", "")
        $CustomOUs += [PSCustomObject]@{
            "Action" = "Add"
            "Path" = $ADPath
            "Name" = $OU.Name
            "Protect" = $false
        }
        Write-Log-Abstract -Category INF -MessageName "ExportedOU" -AdditionalMessage $OU.Name
    }
    Write-Log-Abstract -Category INF -MessageName "ExportedOUs" -AdditionalMessage $File
    $CustomOUs | Export-Csv -Path $File -NoTypeInformation
}

Function Export-Users
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$File
    )
    Write-Log-Abstract -Category INF -MessageName "ExportingUsers" -AdditionalMessage $File
    $Users = Get-ADUser -Filter * -Properties * | Where-Object { $_.Name -notin $DefaultUsers }
    $CustomUsers = @()
    foreach ($User in $Users)
    {
        Write-Log-Abstract -Category INF -MessageName "ExportingUser" -AdditionalMessage $User.Name
        $CustomUsers += [PSCustomObject]@{
            "Action" = "Add"
            "Path" = Get-AD-Compatible-Path -Path $User.DistinguishedName
            "Name" = $User.Name
            "DisplayName" = $User.DisplayName
            "Password" = $null
            "Email" = $User.EmailAddress
            "Department" = $User.Department
            # "Status" = $User.Enabled
        }
        Write-Log-Abstract -Category INF -MessageName "ExportedUser" -AdditionalMessage $User.Name
    }
    $CustomUsers | Export-Csv -Path $File -NoTypeInformation
    Write-Log-Abstract -Category INF -MessageName "ExportedUsers" -AdditionalMessage $File
}

Function Export-Groups
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$File
    )
    Write-Log-Abstract -Category INF -MessageName "ExportingGroups" -AdditionalMessage $File
    $Groups = Get-ADGroup -Filter * -Properties * | Where-Object { $_.Name -notin $DefaultGroups }
    $CustomGroups = @()
    foreach ($Group in $Groups)
    {
        Write-Log-Abstract -Category INF -MessageName "ExportingGroup" -AdditionalMessage $Group.Name
        $CustomGroups += [PSCustomObject]@{
            "Action" = "Add"
            "Path" = Get-AD-Compatible-Path -Path $Group.DistinguishedName
            "Name" = $Group.Name
            "Scope" = $Group.GroupScope
            "Type" = $Group.GroupCategory
            "Description" = $Group.Description
        }
        Write-Log-Abstract -Category INF -MessageName "ExportedGroup" -AdditionalMessage $Group.Name
    }
    $CustomGroups | Export-Csv -Path $File -NoTypeInformation
    Write-Log-Abstract -Category INF -MessageName "ExportedGroups" -AdditionalMessage $File
}

Function Export-GroupUsers
{
    param(
        [Parameter(Mandatory = $true)]
        [String]$File
    )
    Write-Log-Abstract -Category INF -MessageName "ExportingGroupUsers" -AdditionalMessage $File
    $Users = Get-ADUser -Filter * -Properties * | Where-Object { $_.Name -notin $DefaultUsers }
    $UsersGroups = @()
    foreach ($User in $Users)
    {
        Write-Log-Abstract -Category INF -MessageName "ExportingGroupUser" -AdditionalMessage "User: $User.Name"
        $Groups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object { $_.Name -notin $DefaultGroups }
        $UserPath = Get-AD-Compatible-Path -Path $User.DistinguishedName -AllowCN
        foreach ($Group in $Groups)
        {
            $UsersGroups += [PSCustomObject]@{
                Action = "Add"
                UserPath = $UserPath
                GroupPath = Get-AD-Compatible-Path -Path $Group.DistinguishedName -AllowCN
            }
        }
        Write-Log-Abstract -Category INF -MessageName "ExportedGroupUser" -AdditionalMessage "User: $User.Name"
    }
    $UsersGroups | Export-Csv -Path $File -NoTypeInformation
    Write-Log-Abstract -Category INF -MessageName "ExportedGroupUsers" -AdditionalMessage $File
}
