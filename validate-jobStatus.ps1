function validate-jobStatus
{
    out-logfile -string "Start Validate-JobStatus"

    try {
        $jobs = @(Get-Job -State "Failed" -errorAction STOP)
    }
    catch {
        out-logfile -string "Unable to obtain failed jobs."
    }

    if ($jobs.count -gt 0)
    {
        out-logfile -string "A job required to complete this module has failed."
        out-logfile -string "Review each individual log file within the main log file directory."
        out-logfile -string "Job Failed" -isError:$TRUE
    }

    out-logfile -string "End"
}