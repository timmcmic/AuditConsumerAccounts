function verify-GraphConnection
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $graphHashTable
    )

    out-logfile -string "Begin Verify-GraphConnection"
    out-logfile -string "Obtain the graph context..."

    try {
        $graphContext = Get-MgContext -ErrorAction Stop
        out-logfile -string 'Graph context obtained successfully'
    }
    catch {
        out-logfile -string "Unable to obtain the graph context."
        out-logfile -string $_ -isError:$true
    }

    out-logfile -string "Record all scopes associated with the graph context."

    foreach ($scope in $graphContext.scopes)
    {
        out-logfile -string $scope
    }

    out-logfile -string "Validate that the scopes contain the specified domain scope."

    if ($graphContext.Scopes -contains $graphHashTable.msGraphDomainPermissions)
    {
        out-logfile -string "A valid domain permission scope is available."
    }
    else 
    {
        out-logfile -string "Missing valid domain scope.  User or application must have Domain.Read.All or Domain.ReadWrite.All"
    }

    out-logfile -string "Validate that the scopes contain the specified user scope."

    if ($graphContext.Scopes -contains $graphHashTable.msGraphUserPermissions)
    {
        out-logfile -string "A valid user permission scope is available."
    }
    else 
    {
        out-logfile -string "Missing valid user scope.  User or application must have User.Read.All or User.ReadWrite.All or Directory.Read.All or Directory.ReadWrite.All"
    }

    out-logfile -string "End Verify-GraphConnection"
}