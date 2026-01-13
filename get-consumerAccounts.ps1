function get-ConsumerAccounts
{
   Param
    (
        [Parameter(Mandatory = $true)]
        $accountList
    )

    out-logfile -string "Being Get-ConsumerAccounts"

    #Create return list.

    $returnList = [System.Collections.Generic.List[psCustomObject]]::new()
    $returnListCount = 0

    #Interate through each of the accounts and test for a consumer account.

    foreach ($account in $accountList)
    {
        
    }

    return $returnList
}