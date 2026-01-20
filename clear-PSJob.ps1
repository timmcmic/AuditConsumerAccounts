function Clear-PSJob
{
    out-logfile -string "Start Clear-PSJob"

    Get-Job | Remove-Job -confirm:$FALSE -Force

    out-logfile -string "End Clear-PSJob"
}