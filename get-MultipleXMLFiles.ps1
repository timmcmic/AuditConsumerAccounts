function get-MultipleXMLFiles
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $fileName,
        [Parameter(Mandatory = $true)]
        $baseName,
        [Parameter(Mandatory = $true)]
        $logFolderPath
    )

    out-logfile -string "Start Get-MultipleXMLFiles"

    $rootPath = $logFolderPath + "\" + $baseName + "\"
    $fileName = $baseName+$fileName+".xml"

    out-logfile -string ("Root Path: "+$rootPath)
    out-logfile -string ("File Name: "+$fileName)

    $files = @(Get-ChildItem -path $rootPath -name $fileName -Recurse)

    out-logfile -string ("File Count: "+$files.count.tostring())

    $data = @()

    foreach ($file in $files)
    {
        out-logfile -string ("Processing file: "+$file)

        $importFile = $rootPath + $file

        out-logfile -string ("Processing import file: "+$importFile)

        try {
            $data += Import-Clixml -Path $importFile -errorAction STOP

        }
        catch {
            out-logfile -string "Unable to obtain the contents of the XML file."
            out-logfile -string $_ -isError:$TRUE
        }

        out-logfile -string ("Processing entry count: "+$data.Count.tostring())
    }

    $returnList = [System.Collections.Generic.List[psCustomObject]]$data

    out-logfile -string ("Return list imported count: "+$returnList.Count.tostring())

    $returnList = $returnList | Sort-Object -Property ID,Address -Unique

    out-logfile -string ("Sorted return list imported count: "+$returnList.Count.tostring())

    out-logfile -string "End Get-MultipleXMLFiles"

    return $returnList
}