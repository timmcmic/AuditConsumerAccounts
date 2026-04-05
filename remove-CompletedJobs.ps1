function remove-CompletedJobs
{
    Param
    (
        [Parameter(Mandatory = $false)]
        $removeAll=$FALSE
    )

    out-logfile -string "Remove-CompletedJobs"

    $jobCount = Get-Job

    if ($removeAll -eq $FALSE)
    {
        if ($jobCount.count -gt 0)
        {
            out-logfile -string ("Job Count: "+$jobCount.count.toString())

            try {
                get-Job -state Completed | remove-job -erroraction STOP
            }
            catch {
                out-logfile -string $_
                out-logfile -string "Manual job cleanup required."
            }
        }
    }
    else 
    {
        try {
            get-Job | remove-job -erroraction STOP
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Manual job cleanup required."
        }
    }
    

    $jobCount = Get-Job

    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()

    out-logfile -string ("Job Count: "+$jobCount.count.toString())
        
    out-logfile -string "End Remove-CompletedJobs"
}