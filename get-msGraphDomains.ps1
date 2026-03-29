function Get-MSGraphDomains
{
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$bringYourOwnDomains=@()
    )

    $onMicrosoft = "onmicrosoft.com"

    out-logfile -string "Begin Get-MSGraphDomains"

    if ($bringYourOwnDomains.count -eq 0)
    {
        try {
            out-logfile -string "Using graph call to obtain verified domains."

            $domainList = get-MGDomain -All | where {($_.isVerified -eq $TRUE) -and ($_.ID -notMatch $onMicrosoft)} | Select-Object Id

            out-logfile -string "Graph call to obtain domains successful."
        }
        catch {
            out-logfile -string "Graph call to obtain domains failed."
            out-logfile -string $_ -isError:$true
        }
    }
    else 
    {
        out-logfile -string "Using user supplied domains..."

        $domainList = @()

        foreach ($domain in $bringYourOwnDomains)
        {
            out-logfile -string ("Processing domains: "+$domain)

            try {
                $domainList += get-MGDomain -domainID $domain -errorAction STOP | Select-Object Id,IsVerified
            }
            catch {
                out-logfile -string $_
                out-logfile -string "Unable to obtain the domain..." -isError:$true
            }
        }

        foreach ($domain in $domainlist)
        {
            if ($domain.isVerified -ne $TRUE)
            {
                out-logfile -string "User supplied domain added to tenant but not verified - exception." -isError:$true
            }
            else 
            {
                out-logfile -string "Domain is verified - proceed."
            }
        }
    }

    out-logfile -string ("Count of domains obtained: "+$domainList.Count.ToString())

    foreach ($domain in $domainList)
    {
        out-logfile -string $domain
    }

    out-logfile -string "End Get-MSGraphDomains"

    return $domainList
}