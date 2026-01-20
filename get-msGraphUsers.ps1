function Get-MSGraphUsers
{
    #Declare local variables.

    $propertiesToObtain="ID,UserPrincipalName,ProxyAddresses,Mail"

    out-logfile -string "Begin Get-MSGraphUsers"

    try {
        out-logfile -string "Using graph call to obtain all users."

        #$userList = [System.Collections.Generic.List[Object]]@(get-MGUser -all -Property $propertiesToObtain -errorAction Stop | Select-Object ID,userPrincipalName,proxyAddresses,Mail)

            $userList = [System.Collections.Generic.List[Object]]::New()
        $user = get-mgUser -UserId 'tim@e-mcmichael.com' -Property $propertiesToObtain | Select-Object ID,userPrincipalName,proxyAddresses,Mail
        $userList.add($user)
        $user = get-mgUser -UserId 'amy@e-mcmichael.com' -Property $propertiesToObtain | Select-Object ID,userPrincipalName,proxyAddresses,Mail
        $userList.add($user)

        out-logfile -string "Graph call to obtain users successful."
    }
    catch {
        out-logfile -string "Graph call to obtain users failed."
        out-logfile -string $_ -isError:$true
    }

    out-logfile -string ("Count of users obtained: "+$userList.Count.ToString())

    out-logfile -string "End Get-MSGraphUsers"

    return $userList
}