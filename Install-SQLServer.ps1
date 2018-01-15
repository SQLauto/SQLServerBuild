<#
    Install SQL Server via DSC

    Installs RSAT to create service accounts (random passwords not stored)
    Creates DSC MOF file using -Module xSmbShare, xSQLServer
        Creates Share on U drive (lack permissions)
#>


$ServerName = $env:COMPUTERNAME
$domain = "domain"
$OUPath = "OU=SQL, OU=Service Accounts, OU=CM USers,DC=Domain,DC=COM"
$SQLServerServiceGroup = "SRV-SQL-Engines"

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
$SVCSQL = $ServerName + "_sql"
$SVCAgt = $ServerName + "_agt"

$SVCSQLPwd = Get-NewPassword 15
$SVCAgtPwd = Get-NewPassword 15
$SAPwd = Get-NewPassword 15


## Install .NET 3.5
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:\\Server\winsxs\2016\sxs

## Create SQL Server Service Account 
IF (Get-ADUser -LDAPFilter "(sAMAccountName=$SVCSQL)")
    {
        Remove-ADUser $SVCSQL -Confirm:$false 
        try
        {
        New-ADUser  $SVCSQL -AccountPassword (ConvertTo-SecureString $SVCSQLPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
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
            New-ADUser  $SVCSQL -AccountPassword (ConvertTo-SecureString $SVCSQLPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
        }
        catch
        {
            Write-Warning "Failed creating the SQL Server Engine service account Run script again to try and fix"
            break
        }
    }
 
## Create SQL Agent Service Account 
IF (Get-ADUser -LDAPFilter "(sAMAccountName=$SVCAgt)")
    {
        try
        {
        Remove-ADUser $SVCAgt -Confirm:$false
        New-ADUser $SVCAgt -AccountPassword (ConvertTo-SecureString $SVCAgtPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
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
        New-ADUser $SVCAgt -AccountPassword (ConvertTo-SecureString $SVCAgtPwd -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -Path $OUPath
        }
        catch
        {
            Write-Warning "Failed creating the SQL Server Agent service account Run script again to try and fix"
            break
        }
    }
 
$SQLServerServiceGroupMembers = Get-ADGroupMember -Identity $SQLServerServiceGroup -Recursive
 
IF (!($SQLServerServiceGroupMembers.SamAccountName –contains $SVCSQL))
    {
        Add-ADGroupMember $SQLServerServiceGroup $SVCSQL
    }

$SQLServiceAccountPwd = ConvertTo-SecureString $SVCSQLPwd -AsPlainText -Force
$SQLServiceAccountCreds = New-Object System.Management.Automation.PSCredential ("$domain\$SVCSQL",$SQLServiceAccountPwd)

$SQLAgtServiceAccountPwd = ConvertTo-SecureString $SVCAgtPwd -AsPlainText -Force
$SQLAgtServiceAccountCreds = New-Object System.Management.Automation.PSCredential ("$domain\$SVCAgt", $SQLAgtServiceAccountPwd)

$SAPwdSecure = ConvertTo-SecureString $SAPwd -AsPlainText -Force
$SACreds = New-Object System.Management.Automation.PSCredential ("sa", $SAPwdSecure)

$AdminPassword = ConvertTo-SecureString 'Password123' -AsPlainText -Force
$AdminCreds = New-Object System.Management.Automation.PSCredential ('domain\Stephen.bennett', $AdminPassword)

## DSC
Configuration SQLServerInstallation {
## Import Modules needed
Import-DscResource -Module xSmbShare, xSQLServer
Node localhost {
File SQLServer
{
    DestinationPath="S:\SQL Server"
    Type="Directory"
    Ensure="Present"
}    
File SQLDataFolder 
{
    DestinationPath="D:\SQLData"
    Type="Directory"
    Ensure="Present"
}
File SQLLogFolder 
{
    DestinationPath="L:\SQLLog"
    Type="Directory"
    Ensure="Present"
}
File SQLTempDBFolder 
{
    DestinationPath="T:\SQLTempDB"
    Type="Directory"
    Ensure="Present"
}
File UserData 
{
    DestinationPath="U:\UserData"
    Type="Directory"
    Ensure="Present"
}
File BackupTemp 
{
    DestinationPath="U:\BackupTemp"
    Type="Directory"
    Ensure="Present"
}
xSmbShare UserDataShare
{
    DependsOn = "[File]UserData"
    Ensure = "Present" 
    Name   = "UserData"
    Path = "U:\UserData"  
    Description = "Only load files here" 
    FullAccess = "Everyone"
}

xSqlServerSetup SQLInstall
{
    SourcePath = "U:\SQL2016\Source"
    SetupCredential = $Node.AdminCreds
    InstanceName = "MSSQLSERVER"
    Features = "SQLENGINE"
    SQLSysAdminAccounts = "CREATORMAIL\DBA"
    InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
    InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
    InstanceDir = "S:\SQL Server"
    InstallSQLDataDir = "S:\SQL Server"
    SQLUserDBDir = "D:\SQLData"
    SQLUserDBLogDir = "L:\SQLLog"
    SQLTempDBDir = "T:\SQLTempDB"
    SQLTempDBLogDir = "T:\SQLTempDB"
    SQLBackupDir = "U:\BackupTemp"
    SecurityMode = "SQL"
    SAPwd =  $Node.SACreds
    SQLSvcAccount = $Node.EngineCreds
    AgtSvcAccount = $Node.AgtCreds
    UpdateEnabled = $true
    UpdateSource = "U:\SQL2016\Updates"
}
xSQLServerNetwork SQLTcp
{
    DependsOn = "[xSqlServerSetup]SQLInstall"
    InstanceName = "MSSQLSERVER"
    ProtocolName = "TCP"
    IsEnabled = $true
    TCPPort = 1433
    RestartService = $true
} 



} # File localhost
} # Configuration SQLServerInstallation

$configData = @{
    AllNodes = @(
            @{
                NodeName = 'localhost';
                PSDscAllowPlainTextPassword = $true
                AdminCreds = $AdminCreds
                SACreds = $SACreds
                AgtCreds = $SQLAgtServiceAccountCreds
                EngineCreds = $SQLServiceAccountCreds
            }
        )
}

SQLServerInstallation -ConfigurationData $configData 

Start-DscConfiguration -Path .\SQLServerInstallation -Wait -Verbose -Force