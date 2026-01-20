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

        $data += Import-Clixml -Path $importFile

        out-logfile -string ("Processing entry count: "+$data.Count.tostring())
    }

    $returnList = [System.Collections.Generic.List[psCustomObject]]::new($data)

    out-logfile -string ("Return list imported count: "+$returnList.Count.tostring())

    $returnList = $returnList | Sort-Object -Property ID,Address -Unique

    out-logfile -string ("Sorted return list imported count: "+$returnList.Count.tostring())

    out-logfile -string "End Get-MultipleXMLFiles"

    return $returnList
}