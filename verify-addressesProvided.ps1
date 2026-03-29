function verify-addressesProvided
{
    Param
    (
        [Parameter(Mandatory = $TRUE)]
        $addressList
    )

    function regExTestEmail
    {
        Param
        (
            [Parameter(Mandatory = $TRUE)]
            $addressToTest
        )

        if ($addressToTest -notMatch '^[^@]+@[^@]+\.[^@]+$')
        {
            out-logfile -string "Error:  email address provided not in valid format." -isError:$true
        }
        else 
        {
            out-logfile -string "Address in valid regex email format."
        }
    }

    $isString = $false
    $returnArray = @()

    out-logfile -string "Entering verify-AddressesProvided"

    out-logfile -string "Addresses may be provided as arrays of string or arrays of objects."

    out-logfile -string "Determine if the list is objects or string."

    if ($addressList[1] -is [PSCustomObject])
    {
        out-logfile -string "Array of PSCustomObjects provided."
    }
    elseif ($addressList[1] -is [string])
    {
        out-logfile -string "Array of strings provided."
        $isString = $true
    }

    if ($isString -eq $TRUE)
    {
        out-logfile -string "Testing addresses based on string type"

        foreach ($address in $addressList)
        {
            out-logfile -string ("Testing address:"+$address)

            regExTestEmail -addressToTest $address

            $returnArray+=$address
        }
    }
    else 
    {
        out-logfile -string "Testing based on objects provided."

        foreach ($address in $addressList)
        {
            out-logfile -string ("Testing Address: "+$address.address)

            if ($address.PSObject.Properties['Address'])
            {
                out-logfile -string "Address property found..."
                regExTestEmail -addressToTest $address.address
            }
            else 
            {
                out-logfile -string "Object missing address property, when using custom objects each must have an address property."
            }

            if (($address.PSObject.Properties['UPN']) -and ($address.PSObject.Properties['AccountPresent']) -and ($address.PSObject.Properties['AccountError']) -and ($address.PSObject.Properties['AccountErrorText']) -and ($address.PSObject.Properties['RequestID']) -and ($address.PSObject.Properties['TimeStamp']))
            {
                out-logfile -string "Customer object provided has all the necessary properties"
                $address.AccountPresent = $false
                $address.AccountError=$false
                $address.AccountErrorText=""
                $address.requestID=""
                $address.timeStamp=""
            }
            else
            {
                out-logfile -string "When provied custom objects for bringYourOwnAddresses..."
                out-logfile -string "Each object must have an ID propertie with the Entra objectID"
                out-logfile -string "Each object must have an UPN propertie with the Entra UPN"
                out-logfile -string "Each object must have an AccountPresent property set to NULL"
                out-logfile -string "Each object must have an AccountErrorText property set to NULL"
                out-logfile -string "Each object must have an RequestID property set to NULL"
                out-logfile -string "Each object must have an TimeStamp property set to NULL"
                out-logfile -string "EXCEPTION:  User provided object not in correct format..." -isError:$true
            }
            
            $returnArray+=$address
        }
    }

    out-logfile -string "Exit verify-AddressesProvided"

    return $returnArray
}