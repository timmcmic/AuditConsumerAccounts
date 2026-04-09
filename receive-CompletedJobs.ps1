function receive-completedJobs
{
    out-logfile -string "Start Receive-CompletedJobs"

    get-Job -state Completed | Receive-Job
        
    out-logfile -string "End Receive-CompletedJobs"
}