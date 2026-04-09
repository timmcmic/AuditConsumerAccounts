function receive-completedJobs
{
    out-logfile -string "Start Receive-CompletedJobs"

    try {
        $jobs = get-Job -state Completed
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to retrieve jobs." -isError:$true
    }

    foreach ($job in $jobs)
    {
        try {
            Receive-Job -Id $job.Id -errorAction STOP
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to receive job." -isError:$true
        }
    }
        
    out-logfile -string "End Receive-CompletedJobs"
}