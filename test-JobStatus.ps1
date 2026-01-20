function test-jobStatus
{
    out-logfile -string "Start Test-JobStatus"

    do {
        out-logfile -string "Jobs are not yet completed in this batch."

        try {
            $loopJobs = Get-Job -state Running -errorAction Stop| where {$_.name -eq $logFileName}
        }
        catch {
            out-logfile -string "Unable to obtain jobs to determine status."
            out-logfile -string $_ -isError:$TRUE
        }
        
        out-logfile -string ("Number of jobs that are running: "+$loopJobs.count.tostring())

        start-sleepProgress -sleepString "Sleeping waiting on job completion." -sleepSeconds 30
    } until (
        (Get-Job -state Running | where {$_.name -eq $logFileName}).count -eq 0
    )
}