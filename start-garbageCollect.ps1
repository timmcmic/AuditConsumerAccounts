function start-garbageCollect
{
    out-logfile -string "Entering start-garbageCollect"

    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()

    out-logfile -string "Ending start-garbageCollect"
}