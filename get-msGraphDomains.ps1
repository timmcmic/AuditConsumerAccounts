function Get-MSGraphDomains
{
    out-logfile -string "Begin Get-MSGraphDomains"

    try {
        out-logfile -string "Using graph call to obtain verified domains."

        $domainList = get-MGDomain -All | where {$_.isVerified -eq $TRUE} | Select-Object Id

        out-logfile -string "Graph call to obtain domains successful."
    }
    catch {
        out-logfile -string "Graph call to obtain domains failed."
        out-logfile -string $_ -isError:$true
    }

    out-logfile -string ("Count of domains obtained: "+$domainList.Count.ToString())

    foreach ($domain in $domainList)
    {
        out-logfile -string $domain
    }

    out-logfile -string "End Get-MSGraphDomains"

    return $domainList
}