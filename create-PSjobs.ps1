function create-PSjobs
{
    Param
    (
        #Define Microsoft Graph Parameters
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [ValidateSet("China","Global","USGov","USGovDod")]
        [string]$msGraphEnvironmentName,
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
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [ValidateSet("Domain.Read.All","Domain.ReadWrite.All")]        
        [string]$msGraphDomainPermissions,
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [ValidateSet("User.Read.All","User.ReadWrite.All","Directory.Read.All","Directory.ReadWrite.All")]        
        [string]$msGraphUserPermissions,
        [Parameter(Mandatory = $false)]
        $bringYourOwnDomains=$NULL,
        [Parameter(Mandatory = $false)]
        $bringYourOwnUsers=$NULL,
        [Parameter(Mandatory = $false)]
        $bringYourOwnAddresses=$NULL,
        [Parameter(Mandatory = $true)]
        [string]$logFolderPath
    )

    out-logfile -string "Start Create-PSJobs"

    if ($bringYourOwnUsers -ne $NULL)
    {
        for ($i = 0 ; $i -lt $addressesToTest.count ; $i++)
        {
            out-logfile -string ("Starting address collection job: "+$i.tostring())

            $jobFolderPath = $logFolderPath + "\" + $logFileName + "\" + $i.toString()

            if ($msGraphValues.msGraphAuthenticationType -eq "Certificate")
            {
                Start-Job -name $logFileName -InitializationScript {Import-Module "C:\Users\timmcmic\OneDrive - Microsoft\Repository\AuditConsumerAccounts\AuditConsumerAccounts.psd1" -Force} -ScriptBlock {Start-AuditConsumerAccounts -msGraphEnvironmentName $args[0] -msGraphTenantID $args[1] -msGraphCertificateThumbprint $args[2] -msGraphApplicationID $args[3] -msGraphDomainPermissions $args[4] -msGraphUserPermissions $args[5] -logFolderPath $args[6] -allowTelemetryCollection $args[7] -testPrimarySMTPOnly $args[8] -bringYourOwnAddresses $args[9] } -ArgumentList $msGraphEnvironmentName,$msGraphTenantID,$msGraphCertificateThumbprint,$msGraphApplicationID,$msGraphDomainPermissions,$msGraphUserPermissions,$jobFolderPath,$allowTelemetryCollection,$testPrimarySMTPOnly,$addressesToTest
            }
            elseif ($msGraphValues.msGraphAuthenticationType -eq "ClientSecret")
            {
                Start-Job -name $logFileName -InitializationScript {Import-Module "C:\Users\timmcmic\OneDrive - Microsoft\Repository\AuditConsumerAccounts\AuditConsumerAccounts.psd1" -Force} -ScriptBlock {Start-AuditConsumerAccounts -msGraphEnvironmentName $args[0] -msGraphTenantID $args[1] -msGraphApplicationID $args[2] -msGraphClientSecret $args[3] -msGraphDomainPermissions $args[4] -msGraphUserPermissions $args[5] -logFolderPath $args[6] -allowTelemetryCollection $args[7] -testPrimarySMTPOnly $args[8] -bringYourOwnAddresses $args[9] } -ArgumentList $msGraphEnvironmentName,$msGraphTenantID,$msGraphApplicationID,$msGraphClientSecret,$msGraphDomainPermissions,$msGraphUserPermissions,$jobFolderPath,$allowTelemetryCollection,$testPrimarySMTPOnly,$addressesToTest
            }    
        }
    }

    if ($bringYourOwnAddresses -ne $NULL)
    {
        for ($i = 0 ; $i -lt $addressesToTest.count ; $i++)
        {
            out-logfile -string ("Starting address collection job: "+$i.tostring())

            $jobFolderPath = $logFolderPath + "\" + $logFileName + "\" + $i.toString()

            if ($msGraphValues.msGraphAuthenticationType -eq "Certificate")
            {
                Start-Job -name $logFileName -InitializationScript {Import-Module "C:\Users\timmcmic\OneDrive - Microsoft\Repository\AuditConsumerAccounts\AuditConsumerAccounts.psd1" -Force} -ScriptBlock {Start-AuditConsumerAccounts -msGraphEnvironmentName $args[0] -msGraphTenantID $args[1] -msGraphCertificateThumbprint $args[2] -msGraphApplicationID $args[3] -msGraphDomainPermissions $args[4] -msGraphUserPermissions $args[5] -logFolderPath $args[6] -allowTelemetryCollection $args[7] -testPrimarySMTPOnly $args[8] -bringYourOwnAddresses $args[9] -bringYourOwnDomains $args[10]} -ArgumentList $msGraphEnvironmentName,$msGraphTenantID,$msGraphCertificateThumbprint,$msGraphApplicationID,$msGraphDomainPermissions,$msGraphUserPermissions,$jobFolderPath,$allowTelemetryCollection,$testPrimarySMTPOnly,$addressesToTest,$bringYourOwnDomains
            }
            elseif ($msGraphValues.msGraphAuthenticationType -eq "ClientSecret")
            {
                Start-Job -name $logFileName -InitializationScript {Import-Module "C:\Users\timmcmic\OneDrive - Microsoft\Repository\AuditConsumerAccounts\AuditConsumerAccounts.psd1" -Force} -ScriptBlock {Start-AuditConsumerAccounts -msGraphEnvironmentName $args[0] -msGraphTenantID $args[1] -msGraphApplicationID $args[2] -msGraphClientSecret $args[3] -msGraphDomainPermissions $args[4] -msGraphUserPermissions $args[5] -logFolderPath $args[6] -allowTelemetryCollection $args[7] -testPrimarySMTPOnly $args[8] -bringYourOwnAddresses $args[9] -bringYourOwnDomains $args[10]} -ArgumentList $msGraphEnvironmentName,$msGraphTenantID,$msGraphApplicationID,$msGraphClientSecret,$msGraphDomainPermissions,$msGraphUserPermissions,$jobFolderPath,$allowTelemetryCollection,$testPrimarySMTPOnly,$addressesToTest,$bringYourOwnDomains
            }    
        }
    }

    out-logfile -string "End Create-PSJobs"
}