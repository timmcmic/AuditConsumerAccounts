Function Out-CSVFile
    {
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        $itemToExport,
        [Parameter(Mandatory = $true)]
        [string]$itemNameToExport
    )

    Out-LogFile -string "Begin Out-CSVFile"

    #Declare function variables.

    $fileName = $global:LogFile.Replace(".log",$itemNameToExport+".csv")

    # Write everything to our log file and the screen

    try 
    {
        $itemToExport | Export-Csv -path $fileName
    }
    catch 
    {
        throw $_
    }

    Out-LogFile -string "End Out-CSVFile"
}