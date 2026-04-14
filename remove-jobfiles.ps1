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

    $directories = @(Get-ChildItem -path $rootPath -Directory)

    foreach ($directory in $directories)
    {
        out-logfile -string ("Processing directory: "+$directory.fullName)

        $files = @(Get-ChildItem -path $directory.fullName -File)

         Write-Host $files.Count.tostring()

         <#

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

        #>

        $files | foreach-object -Parallel {
            try {
                remove-Item -path $_ -Force -ErrorAction STOP
            }
            catch {
                out-logfile -string "Unable to remove a file - manual deletion required."
            out-logfile -string $_
            } -ThrottleLimit 10
        }
    }
  
    write-host "End Get-Remove-JobFiles"
}