#############################################################################################
# DISCLAIMER:																				#
#																							#
# THE SAMPLE SCRIPTS ARE NOT SUPPORTED UNDER ANY MICROSOFT STANDARD SUPPORT					#
# PROGRAM OR SERVICE. THE SAMPLE SCRIPTS ARE PROVIDED AS IS WITHOUT WARRANTY				#
# OF ANY KIND. MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING, WITHOUT		#
# LIMITATION, ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR OF FITNESS FOR A PARTICULAR		#
# PURPOSE. THE ENTIRE RISK ARISING OUT OF THE USE OR PERFORMANCE OF THE SAMPLE SCRIPTS		#
# AND DOCUMENTATION REMAINS WITH YOU. IN NO EVENT SHALL MICROSOFT, ITS AUTHORS, OR			#
# ANYONE ELSE INVOLVED IN THE CREATION, PRODUCTION, OR DELIVERY OF THE SCRIPTS BE LIABLE	#
# FOR ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS	#
# PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS)	#
# ARISING OUT OF THE USE OF OR INABILITY TO USE THE SAMPLE SCRIPTS OR DOCUMENTATION,		#
# EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES						#
#############################################################################################

function Start-MultipleAuditConsumerAccounts
{
    <#
    .SYNOPSIS

    This function begins the process of collecting information for the purposes of auditing consumer accounts in the Microsoft ecosystem based off domains and addresses in EntraID.

    .DESCRIPTION

    Trigger function.

    .PARAMETER LOGFOLDERPATH

    *REQUIRED*
    This is the logging directory for storing the migration log and all backup XML files.
    If running multiple SINGLE instance migrations use different logging directories.

    .PARAMETER msGraphEnvironmentName

    The MSGraph environment where to invoke commands.

    .PARAMETER msGraphTenantID

    The msGraphTenantID where the graph commands should be invoked.

    .PARAMETER msGraphCertificateThumbprint

    This is the graph certificate thumbprint with the associated app id.
   
    .OUTPUTS

    Creates a CSV and HTML report of all consumer accounts located based off proxy addresses and UPNs in the EntraID environment

    .NOTES

    The following blog posts maintain documentation regarding this module.

    https://timmcmic.wordpress.com.  

    Refer to the first pinned blog post that is the table of contents.

    
    .EXAMPLE

    Start-DistributionListMigration -groupSMTPAddress $groupSMTPAddress -globalCatalogServer server.domain.com -activeDirectoryCredential $cred -logfolderpath c:\temp -dnNoSyncOU "OU" -exchangeOnlineCredential $cred -azureADCredential $cred

    .EXAMPLE

    Start-DistributionListMigration -groupSMTPAddress $groupSMTPAddress -globalCatalogServer server.domain.com -activeDirectoryCredential $cred -logfolderpath c:\temp -dnNoSyncOU "OU" -exchangeOnlineCredential $cred -azureADCredential $cred -enableHybridMailFlow:$TRUE -triggerUpgradeToOffice365Group:$TRUE

    .EXAMPLE

    Start-DistributionListMigration -groupSMTPAddress $groupSMTPAddress -globalCatalogServer server.domain.com -activeDirectoryCredential $cred -logfolderpath c:\temp -dnNoSyncOU "OU" -exchangeOnlineCredential $cred -azureADCredential $cred -enableHybridMailFlow:$TRUE -triggerUpgradeToOffice365Group:$TRUE -useCollectedOnPremMailboxFolderPermissions:$TRUE -useCollectedOffice365MailboxFolderPermissions:$TRUE -useCollectedOnPremSendAs:$TRUE -useCollectedOnPremFullMailboxAccess:$TRUE -useCollectedOffice365FullMailboxAccess:$TRUE

    #>

     [cmdletbinding()]

    Param
    (
        #Define Microsoft Graph Parameters
        [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [ValidateSet("China","Global","USGov","USGovDod")]
        [string]$msGraphEnvironmentName,
        [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [string]$msGraphTenantID,
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [string]$msGraphCertificateThumbprint,
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [string]$msGraphApplicationID,
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]        
        [string]$msGraphClientSecret,
        [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [ValidateSet("Domain.Read.All","Domain.ReadWrite.All")]        
        [string]$msGraphDomainPermissions,
        [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [ValidateSet("User.Read.All","User.ReadWrite.All","Directory.Read.All","Directory.ReadWrite.All")]        
        [string]$msGraphUserPermissions,
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$logFolderPath,
        #Define telemetry parameters
        [Parameter(Mandatory = $false)]
        [boolean]$allowTelemetryCollection=$TRUE,
        #Define optional paramters
        [Parameter(Mandatory = $false)]
        [boolean]$testPrimarySMTPOnly=$false,
        [Parameter(Mandatory = $false)]
        [int]$userBatchSize=1000,
        [Parameter(Mandatory = $false)]
        [int]$jobThreadCount=5
    )

    #Initialize telemetry collection.

    $appInsightAPIKey = "63d673af-33f4-401c-931e-f0b64a218d89"
    $traceModuleName = "AuditConsumerAccounts"

    if ($allowTelemetryCollection -eq $TRUE)
    {
        start-telemetryConfiguration -allowTelemetryCollection $allowTelemetryCollection -appInsightAPIKey $appInsightAPIKey -traceModuleName $traceModuleName
    }

    #Create powershell hash table.

    $powershellModules = @{}
    $powershellModules['Authentication']="Microsoft.Graph.Authentication"
    $powershellModules['Users']="Microsoft.Graph.Users"
    $powershellModules['Directory']="Microsoft.Graph.Identity.DirectoryManagement"
    $powershellModules['Telemetry']="TelemetryHelper"
    $powershellModules['HTML']="PSWriteHTML"
    $powershellModules['Identity']="MSIdentityTools"
    $powershellModules['AuditConsumerAccounts']="AuditConsumerAccounts"


    #Create the telemetry values hash table.

    $telemetryValues = @{}
    $telemetryValues['telemetryAuditConsumerAccounts']="None"
    $telemetryValues['telemetryMSIdentityTools']="None"
    $telemetryValues['telemetryMSGraphAuthentication']="None"
    $telemetryValues['telemetryMSGraphUsers']="None"
    $telemetryValues['telemetryMSGraphDirectory']="None"
    $telemetryValues['telemetryOSVersion']="None"
    $telemetryValues['telemetryStartTime']=(get-UniversalDateTime)
    $telemetryValues['telemetryEndTime']="None"
    $telemetryValues['telemetryElapsedSeconds']=[double]0
    $telemetryValues['telemetryEventName']="Start-AuditConsumerAccounts"
    $telemetryValues['telemetryNumberOfUsers']=[double]0
    $telemetryValues['telemetryNumberofAddresses']=[double]0
    $telemetryValues['telemetryNumberOfConsumerAccounts']=[double]0

    #Create MSGraphHashTable

    $msGraphValues = @{}
    $msGraphValues['msGraphEnvironmentName']=$msGraphEnvironmentName
    $msGraphValues['msGraphTenantID']=$msGraphTenantID
    $msGraphValues['msGraphApplicationID']=$msGraphApplicationID
    $msGraphValues['msGraphCertificateThumbprint']=$msGraphCertificateThumbprint
    $msGraphValues['msGraphClientSecret']=$msGraphClientSecret
    $msGraphValues['msGraphDomainPermissions']=$msGraphDomainPermissions
    $msGraphValues['msGraphUserPermissions']=$msGraphUserPermissions
    $msGraphValues['msGraphAuthenticationType']=$PSCmdlet.ParameterSetName

    #Create HTML Table

    $htmlValues = @{}
    $htmlValues['htmlStartTime']=Get-Date

    #Create export table

    $exportNames = @{}
    $exportNames['usersXML']="-UsersXML"
    $exportNames['domainsCSV']="-DomainsCSV"
    $exportNames['addressesToTextXML']="-AddressToTestXML"
    $exportNames['consumerAccountsXML']="-ConsumerAccounts"

    #Set the execution windows name.

    $windowTitle = "Start-AuditConsumerAccounts"
    $host.ui.RawUI.WindowTitle = $windowTitle

    #Define global variables.

    [string]$global:staticFolderName="\AuditConsumerAccounts\"

    #Define local variables.

    [string]$logFileName = "AuditConsumerAccounts"
    $userList
    $domainsList
    $addressesToTest
    $consumerAccountList
    $chunkedAddressesToTest

    #Start the log file.

    new-logFile -logFileName $logFileName -logFolderPath $logFolderPath

    out-logfile -string "==============================================================="
    out-logfile -string "BEGIN Start-MultipleAuditConsumerAccounts"
    out-logfile -string "==============================================================="

    out-logfile -string "Testing for supported graph authentication method."

    out-logfile -string $msGraphValues.msGraphAuthenticationType

    if (($msGraphValues.msGraphAuthenticationType -ne "Certificate") -and ($msGraphValues.msGraphAuthenticationType -ne "ClientSecret"))
    {
        out-logfile -string "Client secret or certificate authentication is required to perform multiple tests."
        out-logfile -string "Invalid graph authentication type for multiple tests." -isError:$TRUE
    }
    else 
    {
        out-logfile -string "Certificate or client secret authentication type - proceed."
    }

    $htmlValues['htmlStartPowershellValidation']=Get-Date

    $telemetryValues['telemetryMSGraphAuthentication']=Test-PowershellModule -powershellModuleName $powershellModules.Authentication -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphUsers']=Test-PowershellModule -powershellModuleName $powershellModules.Users -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphDirectory']=Test-PowershellModule -powershellModuleName $powershellModules.Directory -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSIdentityTools']=Test-PowershellModule -powershellModuleName $powershellModules.Identity -powershellVersionTest:$TRUE
    $telemetryValues['telemetryAuditConsumerAccounts']=Test-PowerShellModule -powershellModuleName $powershellModules.AuditConsumerAccounts -powershellVersionTest:$TRUE
    $null=Test-PowershellModule -powershellModuleName $powershellModules.telemetry -powershellVersionTest:$TRUE
    $null=Test-PowershellModule -powershellModuleName $powershellModules.html -powershellVersionTest:$TRUE

    $htmlValues['htmlStartMSGraph']=Get-Date

    out-logfile -string "Establish graph connection."

    new-graphConnection -graphHashTable $msGraphValues

    $htmlValues['htmlVerifyMSGraph']=Get-Date

    out-logfile -string "Verify graph connection."

    verify-graphConnection -graphHashTable $msGraphValues

    $htmlValues['htmlGetMSGraphUsers']=Get-Date

    out-logfile -string "Obtain all users from entra ID."

    $userList = get-MSGraphUsers

    out-xmlFile -itemToExport $userList -itemNameToExport $exportNames.usersXML

    $htmlValues['htmlGetMSGraphDomains']=Get-Date

    out-logfile -string "Obtain all domains from entra id."

    $domainsList = get-msGraphDomains

    out-CSVFile -itemToExport $domainsList -itemNameToExport $exportNames.domainsCSV

    $htmlValues['htmlAddressesToTest']=Get-Date

    $userList = get-chunklist -listToChunk $userList -userBatchSize $userBatchSize

    out-logfile -string "Clear any jobs that may exist."

    Clear-PSJob

    create-PSJob -msGraphEnvironmentName $msGraphEnvironmentName -msGraphTenantID $msGraphTenantID -msGraphCertificateThumbprint $msGraphCertificateThumbprint -msGraphApplicationID $msGraphApplicationID -msGraphClientSecret $msGraphClientSecret -msGraphDomainPermissions $msGraphDomainPermissions -msGraphUserPermissions $msGraphUserPermissions -bringYourOwnDomains $bringYourOwnDomains -bringYourOwnUsers $bringYourOwnUsers -logFolderPath $logFolderPath

    test-jobStatus

    validate-jobStatus

    $addressesToTest = get-multipleXMLFiles -fileName $exportNames.addressesToTextXML -baseName $logFileName -logFolderPath $logFolderPath

    out-xmlFile -itemToExport $addressesToTest -itemNameToExport $exportNames.addressesToTextXML

    Clear-PSJob

    $htmlValues['htmlConsumerAccountTest']=Get-Date

    $addressesToTest = get-chunklist -listToChunk $addressesToTest -userBatchSize $userBatchSize

    create-PSJob -msGraphEnvironmentName $msGraphEnvironmentName -msGraphTenantID $msGraphTenantID -msGraphCertificateThumbprint $msGraphCertificateThumbprint -msGraphApplicationID $msGraphApplicationID -msGraphClientSecret $msGraphClientSecret -msGraphDomainPermissions $msGraphDomainPermissions -msGraphUserPermissions $msGraphUserPermissions -bringYourOwnDomains $bringYourOwnDomains -bringYourOwnUsers $bringYourOwnUsers -bringYourOwnDomains $bringYourOwnDomains -logFolderPath $logFolderPath

    test-jobStatus

    validate-jobStatus

    start-sleep -s 600

    <#




    $consumerAccountList = get-ConsumerAccounts -accountList $addressesToTest

    out-xmlFile -itemToExport $consumerAccountList -itemNameToExport $exportNames.consumerAccountsXML

    #>

    $telemetryValues['telemetryNumberOfUsers']=[double]$userList.count
    $telemetryValues['telemetryNumberofAddresses']=[double]$addressesToTest.count
    $telemetryValues['telemetryNumberOfConsumerAccounts']=[double]$consumerAccountList.Count
    $telemetryValues['telemetryEndTime']=(Get-UniversalDateTime)
    $telemetryValues['telemetryElapsedSeconds']=[double](Get-ElapsedTime -startTime $telemetryValues['telemetryStartTime'] -endTime  $telemetryValues['telemetryEndTime'])

    $htmlValues['htmlEndTime']=Get-Date

    generate-htmlFile -htmlTime $htmlValues -accounts $consumerAccountList

    if ($allowTelemetryCollection -eq $TRUE)
    {
        $telemetryEventProperties = @{
            AuditConsumerAccountsCommand = $telemetryValues.telemetryEventName
            AuditConsumerAccountCommandVersion = $telemetryValues.telemetryAuditConsumerAccounts
            MSGraphAuthentication = $telemetryValues.telemetryMSGraphAuthentication
            MSGraphUsers = $telemetryValues.telemetryMSGraphUsers
            MSGraphDirectory = $telemetryValues.telemetryMSGraptelemetryMSGraphDirectory
            MSIdentityTools = $telemetryValues.telemetryMSIdentityTools
            OSVersion = $telemetryValues.telemetryOSVersion
            MigrationStartTimeUTC = $telemetryValues.telemetryStartTime
            MigrationEndTimeUTC = $telemetryValues.telemetryEndTime
        }

        $telemetryEventMetrics = @{
                MigrationElapsedSeconds = $telemetryValues.telemetryElapsedSeconds
                NumberOfUsers = $telemetryValues.telemetryNumberOfUsers
                NumberOfAddresses = $telemetryValues.telemetryNumberofAddresses
                NumberOfConsumerAccounts = $telemetryValues.telemetryNumberOfConsumerAccounts
        }
    }

    if ($allowTelemetryCollection -eq $TRUE)
    {
        out-logfile -string "Telemetry1"
        out-logfile -string $traceModuleName
        out-logfile -string "Telemetry2"
        out-logfile -string $telemetryValues.telemetryEventName
        out-logfile -string "Telemetry3"
        out-logfile -string $telemetryEventMetrics
        out-logfile -string "Telemetry4"
        out-logfile -string $telemetryEventProperties
        send-TelemetryEvent -traceModuleName $traceModuleName -eventName $telemetryValues.telemetryEventName -eventMetrics $telemetryEventMetrics -eventProperties $telemetryEventProperties
    }
}