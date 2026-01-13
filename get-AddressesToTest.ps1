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
    $teststring2 = "SMTP:"
    $guestString = "#EXT#@"

    #Iterate through each address and ensure that each address is an SMTP address an that it is at a domain that is verified in the tenant.

    $ProgressDelta = 100/($userList.count); $PercentComplete = 0; $MbxNumber = 0

    foreach ($user in $userList)
    {
        $MbxNumber++

        out-logfile -string ("Processing user: "+$user.Id)
        out-logfile -string ("Processing UPN: "+$user.userPrincipalName)

        write-progress -activity "Processing Recipient" -status $user.userPrincipalName -PercentComplete $PercentComplete -id 1

        $PercentComplete += $ProgressDelta

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

        if ($user.proxyAddresses.count -gt 0)
        {
            $ProgressDeltaAddress = 100/($user.proxyAddresses.count); $PercentCompleteAddress = 0; $AddressCount = 0

            foreach ($address in $user.proxyAddresses)
            {
                out-logfile -string ("Processing Address: "+$user.userPrincipalName)

                $AddressCount++

                Write-Progress -Activity "Processing address" -Status $address -PercentComplete $PercentCompleteAddress -id 2 -ParentId 1

                $PercentCompleteAddress += $ProgressDeltaAddress

                if (($address.startsWith($testString)) -or ($address.startsWith($testString2)))
                {
                    $tempAddress = $address.subString(5)
                    $tempDomain = $tempAddress.split("@")

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
    }

    write-progress -activity "Processing Recipient" -completed

    $returnListCount = $returnList.Count

    out-logfile -string "Sort and unique the return list."

    $returnList = $returnList | Sort-Object -Property ID,Address -Unique

    $returnListCountSorted = $returnList.count

    out-logfile -string ("Count of Users Evaluated: "+$userList.count.toString())
    out-logfile -string ("Count of Total Address Combinations: "+$returnListCount.ToString())
    out-logfile -string ("Count of Total Sorted Address Combinations: "+$returnListCountSorted.ToString())

    return $returnList
}