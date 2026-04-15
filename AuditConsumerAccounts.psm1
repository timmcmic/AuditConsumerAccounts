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

function Start-AuditConsumerAccounts
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
        $recursiveAddresses=$NULL,
        [Parameter(Mandatory = $false)]
        $recursiveDomains=$NULL,
        [Parameter(Mandatory = $false)]
        [array]$bringYourOwnAddresses=@(),
        [Parameter(Mandatory = $false)]
        [array]$bringYourOwnDomains=@(),
        [Parameter(Mandatory = $false)]
        $jobNumber = -1,
        [Parameter(Mandatory = $false)]
        [boolean]$getAddressesOnly = $false
    )

    function CreateJob
    {
        $jobName = "AuditConsumerAccounts_"+$i.tostring()

        switch ($msGraphValues.msGraphAuthenticationType) 
        {
            $msGraphValues.msGraphCertificateAuth 
            {  
                out-logfile -string "Graph Certificate Jobs"

                try {
                    Start-Job -name $jobName -initializationScript {import-module "AuditConsumerAccounts" -Force} -scriptBlock {start-AuditConsumerAccounts -logFolderPath $args[0] -msGraphEnvironmentName $args[1] -msGraphTenantID $args[2] -msGraphApplicationID $args[3] -msGraphCertificateThumbprint $args[4] -msGraphDomainPermissions $args[5] -msGraphUserPermissions $args[6] -jobNumber $args[7] -recursiveAddresses $args[8] -recursiveDomains $args[9]} -argumentList $logFolderPath,$msGraphEnvironmentName,$msGraphTenantID,$msGraphApplicationID,$msGraphCertificateThumbprint,$msGraphDomainPermissions,$msGraphUserPermissions,$i,$chunkList[$i],$domainsList -ErrorAction Stop

                }
                catch {
                    out-logfile -string "Unable to start job."
                    out-logfile -string $_ -isError:$true
                }
            }
            $msGraphValues.msGraphClientSecretAuth 
            {  
                out-logfile -string "Graph Client Secret Auth"

                try {
                    Start-Job -name $jobName -initializationScript {import-module "AuditConsumerAccounts" -Force} -scriptBlock {start-AuditConsumerAccounts -logFolderPath $args[0] -msGraphEnvironmentName $args[1] -msGraphTenantID $args[2] -msGraphApplicationID $args[3] -msGraphClientSecret $args[4] -msGraphDomainPermissions $args[5] -msGraphUserPermissions $args[6] -jobNumber $args[7] -recursiveAddresses $args[8] -recursiveDomains $args[9]} -argumentList $logFolderPath,$msGraphEnvironmentName,$msGraphTenantID,$msGraphApplicationID,$msGraphClientSecret,$msGraphDomainPermissions,$msGraphUserPermissions,$i,$chunkList[$i],$domainsList -errorAction STOP
                }
                catch {
                    out-logfile -string "Unable to start job."
                    out-logfile -string $_ -isError:$true
                }
            }
        }
    }
    function CreateAddressJob
    {
        $jobName = "AuditConsumerAccounts_"+$i.tostring()

        switch ($msGraphValues.msGraphAuthenticationType) 
        {
            $msGraphValues.msGraphCertificateAuth 
            {  
                out-logfile -string "Graph Certificate Jobs"

                try {
                    Start-Job -name $jobName -initializationScript {import-module "AuditConsumerAccounts" -Force} -scriptBlock {start-AuditConsumerAccounts -logFolderPath $args[0] -msGraphEnvironmentName $args[1] -msGraphTenantID $args[2] -msGraphApplicationID $args[3] -msGraphCertificateThumbprint $args[4] -msGraphDomainPermissions $args[5] -msGraphUserPermissions $args[6] -jobNumber $args[7] -recursiveAddresses $args[8] -recursiveDomains $args[9] -getAddressesOnly $args[10] -testPrimarySMTPOnly $args[11]} -argumentList $logFolderPath,$msGraphEnvironmentName,$msGraphTenantID,$msGraphApplicationID,$msGraphCertificateThumbprint,$msGraphDomainPermissions,$msGraphUserPermissions,$i,$chunkList[$i],$domainsList,$TRUE,$testPrimarySMTPOnly -ErrorAction Stop

                }
                catch {
                    out-logfile -string "Unable to start job."
                    out-logfile -string $_ -isError:$true
                }
            }
            $msGraphValues.msGraphClientSecretAuth 
            {  
                out-logfile -string "Graph Client Secret Auth"

                try {
                    Start-Job -name $jobName -initializationScript {import-module "AuditConsumerAccounts" -Force} -scriptBlock {start-AuditConsumerAccounts -logFolderPath $args[0] -msGraphEnvironmentName $args[1] -msGraphTenantID $args[2] -msGraphApplicationID $args[3] -msGraphClientSecret $args[4] -msGraphDomainPermissions $args[5] -msGraphUserPermissions $args[6] -jobNumber $args[7] -recursiveAddresses $args[8] -recursiveDomains $args[9] -getAddressesOnly $args[10] -testPrimarySMTPOnly $args[11]} -argumentList $logFolderPath,$msGraphEnvironmentName,$msGraphTenantID,$msGraphApplicationID,$msGraphClientSecret,$msGraphDomainPermissions,$msGraphUserPermissions,$i,$chunkList[$i],$domainsList,$TRUE,$testPrimarySMTPOnly -errorAction STOP
                }
                catch {
                    out-logfile -string "Unable to start job."
                    out-logfile -string $_ -isError:$true
                }
            }
        }
    }

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
    $telemetryValues['telemetryHTML']="None"
    $telemetryValues['telemetryTelemetry']="None"
    $telemetryValues['telemetryOSVersion']="None"
    $telemetryValues['telemetryStartTime']=(get-UniversalDateTime)
    $telemetryValues['telemetryEndTime']="None"
    $telemetryValues['telemetryElapsedSeconds']=[double]0
    $telemetryValues['telemetryEventName']="Start-AuditConsumerAccounts"
    $telemetryValues['telemetryNumberOfUsers']=[double]0
    $telemetryValues['telemetryNumberofAddresses']=[double]0
    $telemetryValues['telemetryNumberOfConsumerAccounts']=[double]0
    $telemetryValues['telemetryNumberOfConsumerAccountsErrors']=[double]0


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
    $msGraphValues['msGraphCertificateAuth']="Certificate"
    $msGraphValues['msGraphInteractiveAuth']="Interactive"
    $msGraphValues['msGraphClientSecretAuth']="ClientSecret"

    #Create HTML Table

    $htmlValues = @{}
    $htmlValues['htmlStartTime']=Get-Date

    #Create export table

    $exportNames = @{}
    $exportNames['usersXML']="-UsersXML"
    $exportNames['domainsCSV']="-DomainsCSV"
    $exportNames['addressesToTextXML']="-AddressToTestXML"
    $exportNames['consumerAccountsXML']="-ConsumerAccounts"
    $exportNames['consumerAccountsErrorsXML']="-ConsumerAccountsErrors"

    #Set the execution windows name.

    if ($jobNumber -eq -1)
    {
        $windowTitle = "Start-AuditConsumerAccounts"
        $host.ui.RawUI.WindowTitle = $windowTitle
    }

    #Define global variables.

    if ($jobNumber -eq -1)
    {
         [string]$global:staticFolderName="\AuditConsumerAccounts\"
    }
    else 
    {
         [string]$global:staticFolderName="\AuditConsumerAccounts\"+$jobNumber.toString()+"\"
    }
   

    #Define local variables.

    [string]$logFileName = "AuditConsumerAccounts"
    $userList
    $domainsList
    $addressesToTest
    $consumerAccountList

    $chunkList = @()
    $chunkSize = 50

    $maxJobCount = 5
    $maxAddressJobCount = 10

    #Start the log file.

    new-logFile -logFileName $logFileName -logFolderPath $logFolderPath

    out-logfile -string "==============================================================="
    out-logfile -string "BEGIN Start-AuditConsumerAccounts"
    out-logfile -string "==============================================================="

    out-logfile -string ("User supplied domains count: "+$bringYourOwnDomains.count)
    out-logfile -string ("User supplied addresses count: "+$bringYourOwnAddresses.Count)

    $htmlValues['htmlStartPowershellValidation']=Get-Date
    
    $telemetryValues['telemetryMSGraphAuthentication']=Test-PowershellModule -powershellModuleName $powershellModules.Authentication -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphUsers']=Test-PowershellModule -powershellModuleName $powershellModules.Users -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphDirectory']=Test-PowershellModule -powershellModuleName $powershellModules.Directory -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSIdentityTools']=Test-PowershellModule -powershellModuleName $powershellModules.Identity -powershellVersionTest:$TRUE
    $telemetryValues['telemetryAuditConsumerAccounts']=Test-PowerShellModule -powershellModuleName $powershellModules.AuditConsumerAccounts -powershellVersionTest:$TRUE
    $telemetryValues['telemetryTelemetry']=Test-PowershellModule -powershellModuleName $powershellModules.telemetry -powershellVersionTest:$TRUE
    $telemetryValues['telemetryHTML']=Test-PowershellModule -powershellModuleName $powershellModules.html -powershellVersionTest:$TRUE

    if (($recursiveAddresses -eq $NULL) -and ($getAddressesOnly -eq $false))
    {
        $htmlValues['htmlStartMSGraph']=Get-Date

        out-logfile -string "Establish graph connection."

        new-graphConnection -graphHashTable $msGraphValues

        $htmlValues['htmlVerifyMSGraph']=Get-Date

        verify-graphConnection -graphHashTable $msGraphValues

        $htmlValues['ValidateAddressesProvided']=Get-Date

        if ($bringYourOwnAddresses.count -gt 0)
        {
            out-logfile -string "Address validation required."
            
            $bringYourOwnAddresses = @(verify-AddressesProvided -addressList $bringYourOwnAddresses)
        }
        else 
        {
            out-logfile -string "Address validation not required."
        }


        $htmlValues['htmlGetMSGraphUsers']=Get-Date

        if ($bringYourOwnAddresses.count -eq 0)
        {
            $userList = get-MSGraphUsers
        }
        else 
        {
            if ($bringYourOwnAddresses[0].gettype().fullName -eq "System.Management.Automation.PSCustomObject")
            {
                out-logfile -string "Administrator has provided specific objects to test"
                $userList = @()
            }
            else 
            {
                $userList = get-MSGraphUsers -bringYourOwnAddresses $bringYourOwnAddresses
            }
        }

        if ($userList.count -gt 0)
        {
            out-xmlFile -itemToExport $userList -itemNameToExport $exportNames.usersXML
        }

        $htmlValues['htmlGetMSGraphDomains']=Get-Date

        if($bringYourOwnDomains.count -eq 0)
        {
            $domainsList = get-msGraphDomains
        }
        else 
        {
            $domainsList = get-msGraphDomains -bringYourOwnDomains $bringYourOwnDomains
        }
        
        if ($domainsList.count -gt 0)
        {
            out-CSVFile -itemToExport $domainsList -itemNameToExport $exportNames.domainsCSV
        }

        $htmlValues['htmlChunkUsers']=Get-Date

        if (($userList.count -ge $chunkSize) -or ($bringYourOwnAddresses.count -ge $chunkSize))
        {
            if ($bringYourOwnAddresses[0] -is [PSCustomObject])
            {
                $htmlValues['htmlAddressesToTest']=Get-Date
                $addressesToTest = $bringYourOwnAddresses
                $bringYourOwnAddresses = $null
            }
            else 
            {
                $chunkList = get-chunkList -userBatchSize $chunkSize -listToChunk $userList

                $htmlValues['htmlAddressesToTest']=Get-Date

                out-logfile -string "The number of users required chunking - start jobs to process groups of users."

                if ($chunkList.count -lt $maxAddressJobCount)
                {
                    out-logfile -string "Number of chunks is less that specified max - resetting."
                    $maxAddressJobCount = $chunkList.Count-1
                }
                else 
                {
                    out-logfile -string "Number of chunks is greater than maxAddressJobCount."
                }
                
                for ($i = 0 ; $i -lt $chunkList.count ; $i++)
                {
                    if ($i -lt $maxAddressJobCount)
                    {
                        out-logfile -string ("Provision the first "+$maxAddressJobCount.tostring()+" jobs...")

                        CreateAddressJob
                    }
                    else 
                    {
                        out-logfile -string "Sleep and provision new jobs as a job completes."

                        if ($i+1 -ne $chunkList.count)
                        {
                            while ((Get-Job -state Running).count -ge $maxAddressJobCount)
                            {
                                out-logfile -string "Max jobs currently in progress - waiting to start next job."

                                $jobs = Get-Job -state Running

                                foreach ($job in $jobs)
                                {
                                    out-logfile -string ("Job Name: "+$job.name+" Job Status: "+$job.state)
                                }

                                #$addressesToTest += @(Get-Job | Wait-Job -Any | Receive-Job)
                                Get-Job | Wait-Job | Out-Null
                                $addressesToTest += @(Get-Job -State Completed | Receive-Job)
                                out-logfile -string ("Count of addresses discovered: "+$addressesToTest.Count.tostring())
    
                            }

                            Remove-CompletedJobs

                            out-logfile -string "Provision next job..."

                            CreateAddressJob
                        }
                        else
                        {
                            while ((Get-Job -State Running).count -eq $maxAddressJobCount)
                            {
                                start-sleepProgress -sleepSeconds 30 -sleepString "Sleeping until time to create final job..."
                            }

                            out-logfile -string "Provision final job..."

                            CreateAddressJob
            
                            out-logfile -string "Final jobs currently in progress - waiting to start next job."

                            $jobs = Get-Job -state Running

                            foreach ($job in $jobs)
                            {
                                out-logfile -string ("Job Name: "+$job.name+" Job Status: "+$job.state)
                            }

                            #$addressesToTest += @(Get-Job | Wait-Job | Receive-Job)
                            Get-Job | Wait-Job | Out-Null
                            $addressesToTest += @(Get-Job -State Completed | Receive-Job)
                            out-logfile -string ("Count of addresses discovered: "+$addressesToTest.Count.tostring())
                        }
                    }
                }

                get-multipleLogFiles -logFolderPath $logFolderPath -baseName $logFileName -fileName $logFileName

                remove-jobFiles -logFolderPath $logFolderPath -baseName $logFileName

                remove-jobDirectories -logFolderPath $logFolderPath -baseName $logFileName

                remove-completedJobs -removeAll $TRUE

                $chunkList = $null

                start-garbageCollect

                $returnListCount = $addressesToTest.Count

                out-logfile -string "Sort and unique the return list."

                $addressesToTest = $addressesToTest | Sort-Object -Property ID,Address -Unique

                $returnListCountSorted = $addressesToTest.count

                out-logfile -string ("Count of Users Evaluated: "+$userList.count.toString())
                out-logfile -string ("Count of Total Address Combinations: "+$returnListCount.ToString())
                out-logfile -string ("Count of Total Sorted Address Combinations: "+$returnListCountSorted.ToString())
            }
        }
        elseif (($userList.count -lt $chunkSize) -or ($bringYourOwnAddresses.count -lt $chunkSize)) 
        {
            out-logfile -string "Addresses or user count < chunk size - do nothing."
            if ($bringYourOwnAddresses[0].gettype().fullName -eq "System.Management.Automation.PSCustomObject")
            {
                out-logfile -string "Addresses are object type -> proceed."
                $htmlValues['htmlChunkUsers']=Get-Date
                $htmlValues['htmlAddressesToTest']=Get-Date
                $addressesToTest = $bringYourOwnAddresses
            }
            else 
            {
                $htmlValues['htmlChunkUsers']=Get-Date
                $htmlValues['htmlAddressesToTest']=Get-Date
                out-logfile -string "Addresses are string type -> proceed."
                $addressesToTest = @(get-AddressesToTest -userList $userList -domainsList $domainsList -testPrimarySMTPOnly $testPrimarySMTPOnly)
            }
        }
        
        if ($addressesToTest.count -gt 0)
        {
            out-xmlFile -itemToExport $addressesToTest -itemNameToExport $exportNames.addressesToTextXML
        }

        $htmlValues['htmlChunkAccounts']=Get-Date

        if ($addressesToTest.count -gt $chunkSize)
        {
            out-logfile -string "Number of addresses to test > chunk size -> chunk the addresses."

            $chunkList = get-chunkList -userBatchSize $chunkSize -listToChunk $addressesToTest

            out-logfile -string "Completed chunking list."
        }
        else 
        {
            out-logfile -string "Number of addresses to test < chunk size -> proceed with standard testing."
        }

        $htmlValues['htmlConsumerAccountTest']=Get-Date

        if (($chunkList.count -gt 0) -and (($msGraphValues.msGraphAuthenticationType -eq $msGraphValues.msGraphCertificateAuth ) -or ($msGraphValues.msGraphAuthenticationType -eq $msGraphValues.msGraphClientSecretAuth)))
        {
            $telemetryValues.telemetryNumberofAddresses=[double]$addressesToTest.count
            $addressesToTest = $null
            $jobCounter = 0
            $jobsCompleted = 0
            $totalElapsedTime = 0

            start-garbageCollect

            out-logfile -string "The number of users required chunking - start jobs to process groups of users."

            $jobsCompleted = 0

            if ($chunkList.count -lt $maxJobCount)
            {
                out-logfile -string "Number of chunks less than jobs to create."
                $maxJobCount = $chunkList.count - 1
            }
            else 
            {
                out-logfile -string "Max job counter greater than chunk list - proceed."    
            }
            
            for ($i = 0 ; $i -lt $chunkList.count ; $i++)
            {
                $start = Get-Date

                if ($i -lt $maxJobCount)
                {
                    out-logfile -string "Provision the first 5 jobs."

                    CreateJob
                }
                else 
                {
                    out-logfile -string "Sleep and provision new jobs as a job completes."

                    if ($i+1 -ne $chunkList.count)
                    {
                        while ((Get-Job -state Running).count -ge $maxJobCount)
                        {
                            out-logfile -string "Max jobs currently in progress - waiting to start next job."

                            $jobs = Get-Job -state Running

                            foreach ($job in $jobs)
                            {
                                out-logfile -string ("Job Name: "+$job.name+" Job Status: "+$job.state)
                            }

                            Get-Job | Wait-Job -Any | Out-Null
                        }

                        Remove-CompletedJobs

                        out-logfile -string "Provision next job..."

                        CreateJob

                        $jobsCompleted++
                    }
                    else
                    {
                        while ((Get-Job -State Running).count -eq $maxJobCount)
                        {
                            start-sleepProgress -sleepSeconds 30 -sleepString "Sleeping until time to create final job..."

                            $jobs = Get-Job -state Running

                            foreach ($job in $jobs)
                            {
                                out-logfile -string ("Job Name: "+$job.name+" Job Status: "+$job.state)
                            }
                        }

                        out-logfile -string "Provision final job..."

                        CreateJob
        
                        out-logfile -string "Final jobs currently in progress - waiting to start next job."

                        $jobs = Get-Job -state Running

                        foreach ($job in $jobs)
                        {
                            out-logfile -string ("Job Name: "+$job.name+" Job Status: "+$job.state)
                        }

                        while ((Get-Job -State Running).count -ne 0)
                        {
                            start-sleepProgress -sleepSeconds 30 -sleepString "Sleeping until final jobs finish..."

                            $jobs = Get-Job -state Running

                            foreach ($job in $jobs)
                            {
                                out-logfile -string ("Job Name: "+$job.name+" Job Status: "+$job.state)
                            }
                        }
                    }

                    $jobCounter = $chunkList.Count
                }

                $end = Get-Date
                $time = ($end - $start).TotalMinutes
                $totalElapsedTime = $totalElapsedTime + $time
                $averageTime = $totalElapsedTime / $jobsCompleted
                $jobStatusPending = $chunkList.count - $jobsCompleted

                out-logfile -string ("Jobs Completed: "+$jobsCompleted.tostring())
                out-logfile -string ("All Pending Job Count: "+$jobStatusPending.tostring())
                out-logfile -string ("Time Elapsed Processing Jobs in Minutes: "+$totalElapsedTime)
                out-logfile -string ("Average Job Time in Minutes: "+$averageTime)
            }

            out-logfile -string ("Total Time Processing Jobs: "+$totalElapsedTime)
            out-logfile -string ("Average Job Time in Minutes: "+$averageTime)

            out-logfile -string "Collect all log files from the associated jobs."

            get-multipleLogFiles -logFolderPath $logFolderPath -baseName $logFileName -fileName $logFileName

            out-logfile -string "All log files successfully appeded to current log."

            out-logfile -string "Gather all XML files for consumer accounts."

            $consumerAccountList = get-MultipleXMLFiles -fileName $exportNames.consumerAccountsXML -baseName $logFileName -logFolderPath $logFolderPath

            if ($consumerAccountList.count -gt 0)
            {
                out-xmlFile -itemToExport $consumerAccountList -itemNameToExport $exportNames.consumerAccountsXML
                out-CSVFile -itemToExport $consumerAccountList -itemNameToExport $exportNames.consumerAccountsXML
            }

            remove-jobFiles -logFolderPath $logFolderPath -baseName $logFileName

            remove-jobDirectories -logFolderPath $logFolderPath -baseName $logFileName

            remove-completedJobs -removeAll $TRUE
        }
        else 
        {
            out-logfile -string "Addresses provided - proceed with consumer testing."

            $consumerAccountList = get-ConsumerAccounts -accountList $addressesToTest

            $addressesToTest = $null
        }

        if ($consumerAccountList.count -gt 0)
        {
            out-xmlFile -itemToExport $consumerAccountList -itemNameToExport $exportNames.consumerAccountsXML
            out-CSVFile -itemToExport $consumerAccountList -itemNameToExport $exportNames.consumerAccountsXML
        }

        if (($consumerAccountList | where {$_.accountError -eq $TRUE}).count -gt 0)
        {
            out-xmlFile -itemToExport ($consumerAccountList | where {$_.accountError -eq $TRUE}) -itemNameToExport $exportNames.consumerAccountsErrorsXML
        }

        $telemetryValues.telemetryNumberOfUsers=[double]$userList.count
        $telemetryValues.telemetryNumberOfConsumerAccounts=[double](@($consumerAccountList | where {$_.accountError -eq $false}).count)
        $telemetryValues.telemetryNumberOfConsumerAccountsErrors=[double](@($consumerAccountList | where {$_.accountError -eq $true}).count)
        $telemetryValues.telemetryEndTime=(Get-UniversalDateTime)
        $telemetryValues.telemetryElapsedSeconds=[double](Get-ElapsedTime -startTime $telemetryValues.telemetryStartTime -endTime  $telemetryValues.telemetryEndTime)

        $htmlValues['htmlEndTime']=Get-Date

        if ($consumerAccountList -eq $NULL)
        {
            $consumerAccountList = @()
        }

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
                PSWriteHTML = $telemetryValues.telemetryHTML
                TelemtryHelper = $telemetryValues.telemetryTelemetry
                OSVersion = $telemetryValues.telemetryOSVersion
                MigrationStartTimeUTC = $telemetryValues.telemetryStartTime
                MigrationEndTimeUTC = $telemetryValues.telemetryEndTime
            }

            $telemetryEventMetrics = @{
                    MigrationElapsedSeconds = $telemetryValues.telemetryElapsedSeconds
                    NumberOfUsers = $telemetryValues.telemetryNumberOfUsers
                    NumberOfAddresses = $telemetryValues.telemetryNumberofAddresses
                    NumberOfConsumerAccounts = $telemetryValues.telemetryNumberOfConsumerAccounts
                    NumberOfConsumerAccountErrors = $telemetryValues.telemetryNumberOfConsumerAccountsErrors
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

        disable-allPowerShellSessions
    }
    elseif (($recursiveAddresses -ne $NULL) -and ($getAddressesOnly -eq $true))
    {
        out-logfile -string "Job created to obtain addresses only."

        get-addressesToTest -userList $recursiveAddresses -domainsList $recursiveDomains -testPrimarySMTPOnly $testPrimarySMTPOnly -isBulk:$true

        exit
    }
    else 
    {   
        out-logfile -string "Starting account testing based off provided domains and data."

        $consumerAccountList = get-ConsumerAccounts -accountList $recursiveAddresses

        if ($consumerAccountList.count -gt 0)
        {
            out-xmlFile -itemToExport $consumerAccountList -itemNameToExport $exportNames.consumerAccountsXML
            out-CSVFile -itemToExport $consumerAccountList -itemNameToExport $exportNames.consumerAccountsXML
        }

        $consumerAccountList = $null

        out-logfile -string 'Executing random throttling value between 5 and 10 minutes.'

        start-sleep -seconds ((Get-Random -Minimum 5 -Maximum 10)*60)
        #start-sleep -seconds ((Get-Random -Minimum 1 -Maximum 2)*60)
    }
}