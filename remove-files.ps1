function remove-JobFiles
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $baseName,
        [Parameter(Mandatory = $true)]
        $logFolderPath
    )

    write-host "Enter Remove-JobFiles"

    $rootPath = $logFolderPath + "\" + $baseName + "\"

    write-host $rootPath

    $files = @(Get-ChildItem -path $rootPath -File)

    Write-Host $files.Count.tostring()

    foreach ($file in $files)
    {
        out-logfile -string $file

        try {
            remove-Item -path $file -Force -ErrorAction STOP
        }
        catch {
            write-error $_
        }
    }
        
    write-host "End Get-MultipleLogFiles"
}