function receive-completedJobs
{
    out-logfile -string "Start Receive-CompletedJobs"

    try {
        get-Job -state Completed | receive-job -erroraction STOP
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Manual job cleanup required."
    }
        
    out-logfile -string "End Receive-CompletedJobs"
}