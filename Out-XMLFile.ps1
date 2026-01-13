Function Out-XMLFile
    {
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        $itemToExport,
        [Parameter(Mandatory = $true)]
        [string]$itemNameToExport
    )

    Out-LogFile -string "Beging Out-XMLFile"

    #Declare function variables.

    $fileName = $global:LogFile.Replace(".log",$itemNameToExport+".xml")

    # Write everything to our log file and the screen

    try 
    {
        $itemToExport | export-CLIXML -path $fileName
    }
    catch 
    {
        throw $_
    }

    Out-LogFile -string "End Out-XMLFile"
}