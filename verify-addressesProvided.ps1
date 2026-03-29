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

            regExAddressToTest -addressToTest $address

            $returnArray+=$address
        }
    }
    else 
    {
        out-logfile -string "Testing based on objects provided."

        foreach ($address in $addressList)
        {
            if ($address.PSObject.Properties['Address'])
            {
                out-logfile -string "Address property found..."
                regExAddressToTest -addressToTest $address
            }
            else 
            {
                out-logfile -string "Object missing address property, when using custom objects each must have an address property."
            }

            $returnArray+=$address.address
        }
    }

    out-logfile -string "Exit verify-AddressesProvided"

    return $returnArray
}