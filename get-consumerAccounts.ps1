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

        $account = Get-MSIDReliableStatus -outputObject $account -errorAction STOP

        out-logfile -string "Successfully tested for consumer account."

        $returnList.add($account)

        Start-Sleep -s 1
    }

    write-progress -activity "Processing Recipient" -completed

    $returnList = $returnlist | where {($_.accountError -eq $TRUE) -or ($_.AccountPresent -eq $true)}

    out-logfile -string ("Count of consumer accounts located: "+($returnList | where {$_.AccountPresent -eq $true}).Count)
    out-logfile -string ("Count of account test failures: "+($returnList | where {$_.AccountError -eq $true}).Count)

    out-logfile -string "End Get-ConsumerAccounts"

    return $returnList
}