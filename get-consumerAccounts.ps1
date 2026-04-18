function get-ConsumerAccounts
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $accountList
    )

    out-logfile -string "Begin Get-ConsumerAccounts"

    #Create return list.

    $returnList = [System.Collections.Generic.List[psCustomObject]]::new()
    $returnListCount = 0

    #Interate through each of the accounts and test for a consumer account.

    $ProgressDelta = 100/($accountList.count); $PercentComplete = 0; $MbxNumber = 0

    $counter = $accountList.count
    $totalTime = 0
    $longThrottle = 0
    $totalElapsedTime = 0
    
    foreach ($account in $accountList)
    {
        $start = Get-Date
        out-logfile -string ("Testing consumer account for: "+$account.address)

        write-progress -activity "Processing Recipient" -status $account.UPN -PercentComplete $PercentComplete -id 1

        $PercentComplete += $ProgressDelta

        $account = Get-MSIDReliableStatus -outputObject $account -errorAction STOP

        if ($account.accountError -eq $TRUE)
        {
            $longThrottle++
            start-sleepProgress -sleepSeconds ((Get-Random -Minimum 5 -Maximum 10)*60) -sleepString "Last request throttled - sleeping random 5 - 10 min" -sleepParentID 1 -sleepID 2
        }

        out-logfile -string "Successfully tested for consumer account."

        $returnList.add($account)

        $counter--
        out-logfile -string ("Accounts Remaining: "+$counter.tostring())

        start-sleepProgress -sleepSeconds (get-Random -minimum 2 -maximum 5) -sleepString "Stadard sleep after each call..." -sleepParentID 1 -sleepID 2
        $end = Get-Date
        $time = ($end - $start).TotalMinutes
        $totalElapsedTime = $totalElapsedTime + $time
        $averageTime = $totalElapsedTime / ($accountList.count - $counter)
        out-logfile -string ("Total elapsed time: "+$totalElapsedTime)
        out-logfile -string ("Average account processing time: "+$averageTime)
        out-logfile -string ("Number of long throttle operations: "+$longThrottle.tostring())
    }

    write-progress -activity "Processing Recipient" -completed

    $returnList = $returnlist | where {($_.accountError -eq $TRUE) -or ($_.AccountPresent -eq $true)}

    out-logfile -string ("Count of consumer accounts located: "+($returnList | where {$_.AccountPresent -eq $true}).Count)
    out-logfile -string ("Count of account test failures: "+($returnList | where {$_.AccountError -eq $true}).Count)

   

    out-logfile -string ("Total evaluation time in mintues: "+$totalTime.tostring())

    out-logfile -string "End Get-ConsumerAccounts"

    return $returnList
}