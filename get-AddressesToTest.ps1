function get-AddressesToTest
{
   Param
    (
        [Parameter(Mandatory = $true)]
        $userList,
        [Parameter(Mandatory = $true)]
        $domainsList
    )

    out-logfile -string "Being Get-AddressesToTest"

    #Create return list.

    $returnList = [System.Collections.Generic.List[psCustomObject]]::new()
    $returnListCount = 0
    $returnListCountSorted = 0

    $testString = "smtp:"
    $guestString = "#EXT#@"

    #Iterate through each address and ensure that each address is an SMTP address an that it is at a domain that is verified in the tenant.

    foreach ($user in $userList)
    {
        out-logfile -string ("Processing user: "+$user.Id)
        out-logfile -string ("Processing UPN: "+$user.userPrincipalName)

        if ($user.userPrincipalName.contains($guestString))
        {
            out-logfile -string "Skipping UPN evaluate as adddress as it is a guest account."
        }
        else 
        {
             $outputObject = New-Object PSObject -Property @{
                    ID = $user.id
                    UPN = $user.userPrincipalName
                    Address = $user.userPrincipalName
            }
        }

        $returnList.add($outputObject) | Out-Null

        foreach ($address in $user.proxyAddresses)
        {
            if ($address.startsWith($testString))
            {
                out-logfile -string $address
                $tempAddress = $address.subString(5)
                out-logfile -string $tempAddress
                $tempDomain = $tempAddress.split("@")
                out-logfile -string $tempDomain[1]

                if ($domainslist.Id.contains($tempDomain[1]))
                {
                    out-logfile -string "Address is valid to test."

                    $outputObject = New-Object PSObject -Property @{
                        ID = $user.id
                        UPN = $user.userPrincipalName
                        Address = $tempAddress
                    }

                    $returnList.add($outputObject)
                }
                else 
                {
                    out-logfile -string "Address is not valid to test."
                }
            }
        }
    }

    $returnListCount = $returnList.Count

    out-logfile -string "Sort and unique the return list."

    $returnList = $returnList | Sort-Object -Property ID,Address -Unique

    $returnListCountSorted = $returnList.count

    out-logfile -string ("Count of Users Evaluated: "+$userList.count.toString())
    out-logfile -string ("Count of Total Address Combinations: "+$returnListCount.ToString())
    out-logfile -string ("Count of Total Sorted Address Combinations: "+$returnListCountSorted.ToString())

    return $returnList
}