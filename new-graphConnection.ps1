function New-GraphConnection
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $graphHashTable
    )

    #Declare local variables.

    $msGraphInteractive = "Interactive"
    $msGraphCertificate = "Certificate"
    $msGraphClientSecret = "ClientSecret"
    $msGraphScopesRequired = $graphHashTable.msGraphDomainPermissions + "," + $graphHashTable.msGraphUserPermissions

    out-logfile -string "Begin New-GraphConnection"

    out-logfile -string "Create connection based on graph parameter set name."
    out-logfile -string ("Authentication Type: "+$graphHashTable.msGraphAuthenticationType)
    out-logfile -string ("Scopes Calculated: " +$msGraphScopesRequired)

    switch ($graphHashTable.msGraphAuthenticationType) 
    {
        $msGraphInteractive 
        {  
            out-logfile -string "Entering graph interactive authentication."

            try 
            {
                connect-mgGraph -tenantID $graphHashTable.msGraphTenantID -scopes $msGraphScopesRequired -Environment $graphHashTable.msGraphEnvironmentName -errorAction Stop
            }
            catch 
            {
                out-logfile -string "Graph authentication failed."
                out-logfile -string $_ -isError:$TRUE
            }

            out-logfile -string "Graph authentication successful."

        }
        $msGraphCertificate 
        {  
            out-logfile -string "Entering graph certificate authentication."

            try {
                connect-mgGraph -tenantID $graphHashTable.msGraphTenantID -ClientId $graphHashTable.msGraphApplicationID -CertificateThumbprint $graphHashTable.msGraphCertificateThumbprint -Environment $graphHashTable.msGraphEnvironmentName -errorAction Stop
            }
            catch {
                out-logfile -string "Graph authentication failed."
                out-logfile -string $_ -isError:$TRUE
            }

            out-logfile -string "Graph authentication successful."

        }
        $msGraphClientSecret 
        {  
            out-logfile -string "Entering graph client secret authentication."
            
            $securedPasswordPassword = ConvertTo-SecureString -String $graphHashTable.msGraphClientSecret -AsPlainText -Force

            $clientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -argumentList $graphHashTable.msGraphApplicationID,$securedPasswordPassword

             try {
                connect-mgGraph -tenantID $graphHashTable.msGraphTenantID -Environment $graphHashTable.msGraphEnvironmentName -ClientSecretCredential $clientSecretCredential -errorAction Stop
            }
            catch {
                out-logfile -string "Graph authentication failed."
                out-logfile -string $_ -isError:$TRUE
            }
        }
        Default 
        {
            out-logfile -string "You should have never ended up here - this is an issue - contact author." -isError:$TRUE
        }
    }

    out-logfile -string "End New-GraphConnection"
}