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

    foreach ($account in $accountList)
    {
        $MbxNumber++

        out-logfile -string ("Testing consumer account for: "+$account.address)

        write-progress -activity "Processing Recipient" -status $account.UPN -PercentComplete $PercentComplete

        $PercentComplete += $ProgressDelta

        try {
            $test = get-msIdHasMicrosoftAccount -mail $account.Address -ErrorAction STOP
        }
        catch {
            out-logfile -string "Unable to test for presence of commercial account."
            out-logfile -string $_
        }

        out-logfile -string "Successfully tested for consumer account."

        if ($test -eq $TRUE)
        {
            out-logfile -string "A consumer account is present."

            $returnList.add($account)
        }
        else 
        {
            out-logfile -string "A consumer account is not present."
        }
    }

    write-progress -activity "Processing Recipient" -completed

    out-logfile -string ("Count of consumer accounts located: "+$returnList.Count)

    out-logfile -string "End Get-ConsumerAccounts"

    return $returnList
}