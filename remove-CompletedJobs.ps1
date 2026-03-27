function remove-CompletedJobs
{

    out-logfile -string "Remove-CompletedJobs"

    $jobCount = Get-Job

    if ($jobCount.count -gt 0)
    {
        out-logfile -string ("Job Count: "+$jobCount.count.toString())

        try {
            get-Job | remove-job -erroraction STOP
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Manual job cleanup required."
        }
    }

    $jobCount = Get-Job

    out-logfile -string ("Job Count: "+$jobCount.count.toString())
        
    out-logfile -string "End Remove-CompletedJobs"
}