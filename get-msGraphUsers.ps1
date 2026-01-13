function Get-MSGraphUsers
{
    #Declare local variables.

    $propertiesToObtain="ID,UserPrincipalName,ProxyAddresses"

    out-logfile -string "Begin Get-MSGraphUsers"

    try {
        out-logfile -string "Using graph call to obtain all users."

        #$userList = [System.Collections.Generic.List[Object]]@(get-MGUser -all -Property $propertiesToObtain -errorAction Stop | Select-Object ID,userPrincipalName,proxyAddresses)

        $userList = [System.Collections.Generic.List[Object]]::new()
        $user = get-MGUser -userID "tim@e-mcmichael.com" -Property $propertiesToObtain -errorAction Stop | Select-Object ID,userPrincipalName,proxyAddresses
        $userList.add($user)
        $user = get-MGUser -userID "amy@e-mcmichael.com" -Property $propertiesToObtain -errorAction Stop | Select-Object ID,userPrincipalName,proxyAddresses
        $userList.add($user)
        $user = get-MGUser -userID "sharon@e-mcmichael.com" -Property $propertiesToObtain -errorAction Stop | Select-Object ID,userPrincipalName,proxyAddresses
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