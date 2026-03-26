function Get-MSGraphUsers
{
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$bringYourOwnAddresses=@()
    )

    #Declare local variables.

    $propertiesToObtain="ID,UserPrincipalName,ProxyAddresses,Mail"

    out-logfile -string "Begin Get-MSGraphUsers"

    if ($bringYourOwnAddresses.count -eq 0)
    {
        try 
        {
            out-logfile -string "Using graph call to obtain all users."

            $userList = [System.Collections.Generic.List[Object]]@(get-MGUser -all -Property $propertiesToObtain -errorAction Stop | Select-Object ID,userPrincipalName,proxyAddresses,Mail)
            #$userList = [System.Collections.Generic.List[Object]]@(get-MGUser -userId "Tim@e-mcmichael.com" -Property $propertiesToObtain -errorAction Stop | Select-Object ID,userPrincipalName,proxyAddresses,Mail)

            out-logfile -string "Graph call to obtain users successful."
        }
        catch 
        {
            out-logfile -string "Graph call to obtain users failed."
            out-logfile -string $_ -isError:$true
        }
    }
    else 
    {
        out-logfile -string "A user list was supplied - functioning on only users."

        $userList = [System.Collections.Generic.List[Object]]@()

        foreach ($user in $bringYourOwnAddresses)
        {
            out-logfile -string ("Processing user: " + $user)
            try {
                $userLookup = get-MGUser -UserId $user -Property $propertiesToObtain -ErrorAction STOP
            }
            catch {
                out-logfile -string $_
                out-logfile -string "Unable to locate a user defined user" -isError:$true
            }

            $userList.add($userLookup)
        }
    }

    out-logfile -string ("Count of users obtained: "+$userList.Count.ToString())

    out-logfile -string "End Get-MSGraphUsers"

    return $userList
}