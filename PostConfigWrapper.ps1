<#

    SQL ServerPost Configuration Steps

        Sets up configs using DBATools recommendations for:
            Max memory
            MaxDop
            TempDB Files (using 4GB of disk space)
            Setting all DB's to be owned by SA

        Runs all *.sql in sub folder(s)

#>
# parameters
$SqlServer = "localhost"
$filePath = "C:\Users\Stephen\OneDrive\itg\GIT\DBA\Build\PostConfig"

# ,pdi;es
Import-Module DBATools

## Run DBATools Functions
Set-SqlMaxMemory $SqlServer 
Set-DbaMaxDop -SqlInstance $sqlServer
Set-SqlTempDbConfiguration -SqlServer $SqlServer -DataFileSizeMB 4000 
Set-DbaDatabaseOwner -SqlServer $SqlServer

# Run all SQL files
$files = Get-ChildItem $filePath -recurse -File -Filter *.sql 
Invoke-DbaSqlCmd -SqlServer $SqlServer -File ($files)
