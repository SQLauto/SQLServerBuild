<#
    Install SQL Server BI via DSC

    Installs RSAT to create service accounts (random passwords not stored)
    Creates DSC MOF file using -Module xSQLServer
#>


$ServerName = $env:COMPUTERNAME
$domain = "domain"
$OUPath = "OU=SQL, OU=Service Accounts, OU=CM USers,DC=Domain,DC=COM"

# functions and resources
IF ((Get-WindowsFeature RSAT-AD-PowerShell).InstallState -ne 'Installed') 
    {
        Add-WindowsFeature RSAT-AD-PowerShell
    }

function Get-NewPassword ([int32]$len)
{
    if (!$len) 
        {
            [int32]$len = 40
        } #length of 30 should give us > 128bit password entropy - see http://www.ask.com/wiki/Password_strength?qsrc=3044
    
    [string]$charset = 'abcdefghkmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!@%^[{]}'
    $randchar = 1..$len | ForEach-Object { Get-Random -Maximum $charset.length }
    $ofs="" #$ofs = output field separator
    [string]$charset[$randchar] #if we don't use [string] then there is a CR between chars
   [string]$charset[$randchar] | CLIP #this puts the password in the clipboard, ready for use
}



## Load AD PowerShell modules
$SVCRS = $ServerName + "_rs"
$SVCIS = $ServerName + "_is"

$SVCRSPwd = Get-NewPassword 15
$SVCISPwd = Get-NewPassword 15

## Create SQL Server Service Account 
IF (Get-ADUser -LDAPFilter "(sAMAccountName=$SVCRS)")
    {
        Remove-ADUser $SVCRS -Confirm:$false 
        try
        {
        New-ADUser  $SVCRS -AccountPassword (ConvertTo-SecureString $SVCRSPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
        }
        catch
        {
            Write-Warning "Failed creating the SQL Server Engine service account Run script again to try and fix"
            break
        }
    }
ELSE
    {
        try
        {
            New-ADUser  $SVCRS -AccountPassword (ConvertTo-SecureString $SVCRSPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
        }
        catch
        {
            Write-Warning "Failed creating the SQL Server Engine service account Run script again to try and fix"
            break
        }
    }
 
## Create SQL Agent Service Account 
IF (Get-ADUser -LDAPFilter "(sAMAccountName=$SVCIS)")
    {
        try
        {
        Remove-ADUser $SVCIS -Confirm:$false
        New-ADUser $SVCIS -AccountPassword (ConvertTo-SecureString $SVCISPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
        }
        catch
        {
            Write-Warning "Failed creating the SQL Server Agent service account Run script again to try and fix"
            break
        }
    }
ELSE
    {
        try
        {
        New-ADUser $SVCIS -AccountPassword (ConvertTo-SecureString $SVCISPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
        }
        catch
        {
            Write-Warning "Failed creating the SQL Server Agent service account Run script again to try and fix"
            break
        }
    }
 

$SQLRSServiceAccountPwd = ConvertTo-SecureString $SVCRSPwd -AsPlainText -Force
$SQLRSServiceAccountCreds = New-Object System.Management.Automation.PSCredential ("$domain\$SVCRS",$SQLRSServiceAccountPwd)

$SQLISServiceAccountPwd = ConvertTo-SecureString $SVCISPwd -AsPlainText -Force
$SQLISServiceAccountCreds = New-Object System.Management.Automation.PSCredential ("$domain\$SVCIS", $SQLISServiceAccountPwd)

$AdminPassword = ConvertTo-SecureString 'Password123' -AsPlainText -Force
$AdminCreds = New-Object System.Management.Automation.PSCredential ('Domain\Stephen.bennett', $AdminPassword)

## DSC
Configuration SQLServerInstallationBI {
## Import Modules needed
Import-DscResource -Module xSmbShare, xSQLServer
Node localhost {

xSqlServerSetup SQLInstall
{
    SourcePath = "U:\SQL2016\Source"
    SetupCredential = $Node.AdminCreds
    InstanceName = "MSSQLSERVER"
    Features = "IS, RS"
    SQLSysAdminAccounts = "CREATORMAIL\DBA"
    InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
    InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
    InstanceDir = "S:\SQL Server"
    InstallSQLDataDir = "S:\SQL Server"
    RSSvcAccount = $Node.RSCreds
    ISSvcAccount = $Node.ISCreds
    UpdateEnabled = $true
    UpdateSource = "U:\SQL2016\Updates"
}

xSQLServerRSConfig SSRS
{
    DependsOn = "[xSqlServerSetup]SQLInstall"
    InstanceName        = "localhost"
    RSSQLServer         = "localhost"
    RSSQLInstanceName   = "localhost"
    SQLAdminCredential  = $Node.AdminCreds
}


} # File localhost
} # Configuration SQLServerInstallation

$configData = @{
    AllNodes = @(
            @{
                NodeName = 'localhost';
                PSDscAllowPlainTextPassword = $true
                AdminCreds = $AdminCreds
                RSCreds = $SQLRSServiceAccountCreds
                ISCreds = $SQLISServiceAccountCreds
            }
        )
}

SQLServerInstallationBI  -ConfigurationData $configData 

Start-DscConfiguration -Path .\SQLServerInstallationBI -Wait -Verbose -Force


