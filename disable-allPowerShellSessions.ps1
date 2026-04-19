Function disable-allPowerShellSessions
{

    out-logfile -string "Begin disable-allPowerShellSessions"

    try {
        Set-MgGraphOption -DisableLoginByWAM $FALSE -errorAction STOP
    }
    catch {
       out-logfile -string $_
       out-logfile -string "Unable to reset WAM disabled option."
    }

    try {
        Disconnect-MgGraph -errorAction STOP 
    }
    catch {
        out-logfile -string "Error disconnecting powershell graph - hard abort since this is called in exit code."
    }

    out-logfile -string "***IT MAY BE NECESSARY TO EXIT THIS POWERSHELL WINDOW AND REOPEN TO RESTART FROM A FAILED MIGRATION***"

    out-logfile -string "End Disable-AllPowerShellSessions"
}