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
}