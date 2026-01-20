function Clear-PSJob
{
    out-logfile -string "Start Clear-PSJob"

    try {
        $jobs = get-Job -ErrorAction STOP
    }
    catch {
        out-logfile -string "Unable to obtain jobs."
        out-logfile -string $_ -isError:$TRUE
    }

    try {
        $jobs | stop-job -Confirm:$FALSE:$FALSE -ErrorAction Stop
    }
    catch {
        out-logfile -string "Unable to stop jobs."
        out-logfile -string $_ -isError:$TRUE
    }

    try {
        $jobs | remove-job -Confirm:$FALSE -Force
    }
    catch {
        out-logfile -string "Unable to remove jobs."
        out-logfile -string $_ -isError:$TRUE
    }

    out-logfile -string "End Clear-PSJob"
}