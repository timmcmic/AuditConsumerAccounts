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

    $files = get-ChildItem -path $rootPath -name $fileName -Recurse

    out-logfile -string ("File Count: "+$files.count.tostring())

    $returnList = [System.Collections.Generic.List[psCustomObject]]::new()

    foreach ($file in $files)
    {
        out-logfile -string ("Processing file: "+$file.FullName)

        $data = Import-Clixml -Path $file.FullName

        out-logfile -string ("Processing entry count: "+$data.Count.tostring())

        $returnList.add($data)

        out-logfile -string ("Return list count: "+$returnList.Count.tostring())
    }

    out-logfile -string ("Return list imported count: "+$returnList.Count.tostring())

    $returnList = $returnList | Sort-Object -Property ID,Address -Unique

    out-logfile -string ("Sorted return list imported count: "+$returnList.Count.tostring())

    out-logfile -string "End Get-MultipleXMLFiles"

    return $returnList
}