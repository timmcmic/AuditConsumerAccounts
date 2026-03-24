function get-ConsumerAccounts
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $accountList
    )

    Function Do-It 
    {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $address
    )
        get-msIdHasMicrosoftAccount -mail $address -Debug
    }

    $firstSplitValue = "x-ms-request-id:"
    $secondSplitValue = "x-ms-ests-server:"
    $thirdValue = "`r"

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
            #$test = get-msIdHasMicrosoftAccount -mail $account.Address -ErrorAction STOP
            $result = Do-It -address $account.address -Debug 5>&1
            $test = $result | where { $_ -isnot [System.Management.Automation.DebugRecord] }
            $debugEntry = $result | where { $_ -is [System.Management.Automation.DebugRecord] }

            $debugEntry = $debugEntry.message.split($thirdValue)

            foreach ($entry in $debugEntry)
            {
                if ($entry.contains($firstSplitValue))
                {
                    $entry = $entry.split(": ")
                    $account.RequestID = $entry[1]
                }

                if ($entry.contains($secondSplitValue))
                {
                    $entry = $entry.split(": ")
                    $account.server = $entry[1]
                }
            }

            out-logfile -string $account.RequestID
            out-logfile -string $account.Server
        }
        catch {
            out-logfile -string "Ufonable to test for presence of commercial account."
            out-logfile -string $_
            
            $account.AccountError = $true
            $account.AccountErrorText = $_
            $account.RequestID = "Error"
            $account.server = "Error"
        }

        out-logfile -string "Parse debug entry."

        out-logfile -string "Successfully tested for consumer account."

        if ($test -eq $TRUE)
        {
            out-logfile -string "A consumer account is present."

            $account.AccountPresent = $true

            $returnList.add($account)
        }
        elseif ($account.AccountError -eq $TRUE) 
        {
            out-logfile -string "A consumer account is not presenet but account is in error - add."

            $returnList.add($account)
        }
        else 
        {
            out-logfile -string "A consumer account is not present and the account is not in error - skip."
        }

        #Start-Sleep -s 2
    }

    write-progress -activity "Processing Recipient" -completed

    $returnList = $returnlist | where {($_.accountError -eq $TRUE) -or ($_.AccountPresent -eq $true)}

    out-logfile -string ("Count of consumer accounts located: "+($returnList | where {$_.AccountPresent -eq $true}).Count)
    out-logfile -string ("Count of account test failures: "+($returnList | where {$_.AccountError -eq $true}).Count)

    out-logfile -string "End Get-ConsumerAccounts"

    return $returnList
}