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

    out-logfile -string "Start Get-MultipleLogFiles"

    $rootPath = $logFolderPath + "\" + $baseName + "\"
    $fileName = $baseName+$fileName+".log"

    out-logfile -string ("Root Path: "+$rootPath)
    out-logfile -string ("File Name: "+$fileName)

    $files = @(Get-ChildItem -path $rootPath -name $fileName -Recurse)

    out-logfile -string ("File Count: "+$files.count.tostring())

    for ($i = 0 ; $i -lt $files.count ; $i++)
    {
        out-logfile -string ("Processing file: "+$files[$i])

        $importFile = $rootPath + $files[$i]

        if ($importFile -ne $global:LogFile)
        {
            out-logfile -string ("Processing import file: "+$importFile)

            try {
                $data = get-content -Path $importFile -errorAction STOP
            }
            catch {
                out-logfile -string "Unable to obtain the log file contents."
                out-logfile -string $_ -isError:$TRUE
            }
        }
        else 
        {
            out-logfile -string "Main log file - skip"
        }

        out-logfile -string "---------------------------------------------------------------"
        out-logfile -string ("Job Log for Job: "+$i.tostring())
        out-logfile -string "---------------------------------------------------------------"

        try {
            $data | Out-File -FilePath $global:LogFile -Append -ErrorAction STOP
        }
        catch {
            out-logfile -string "Unable to append job logs to the main log file."
            out-logfile -string $_ -isError:$TRUE
        }
    }
        
    out-logfile -string "End Get-MultipleXMLFiles"
}