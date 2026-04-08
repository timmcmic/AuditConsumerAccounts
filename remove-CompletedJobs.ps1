function remove-CompletedJobs
{
    Param
    (
        [Parameter(Mandatory = $false)]
        $removeAll=$FALSE
    )

    out-logfile -string "Entering Remove-CompletedJobs"

    $jobCount = Get-Job

    out-logfile -string ("Job Count: "+$jobCount.count.toString())

    if ($removeAll -eq $FALSE)
    {
        try {
            get-Job -state Completed | remove-job -erroraction STOP
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Manual job cleanup required."
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

    start-garbageCollect

    out-logfile -string ("Job Count: "+$jobCount.count.toString())
        
    out-logfile -string "Exiting Remove-CompletedJobs"
}