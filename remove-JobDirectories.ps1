function remove-JobDirectories
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $baseName,
        [Parameter(Mandatory = $true)]
        $logFolderPath
    )

    out-logfile -string "Remove-JobDirectories"

    $rootPath = $logFolderPath + "\" + $baseName + "\"

    out-logfile -string ("Root Path: "+$rootPath)

    $directories = @(Get-ChildItem -path $rootPath -directory)

    out-logfile -string ("Directory Count: "+$directories.count.tostring())

    <#

    foreach ($directory in $directories)
    {
        out-logfile -string ("Processing directory: "+$directory)

        try {
            remove-Item -path $directory -Recurse -Force -ErrorAction STOP
        }
        catch {
            out-logfile -string "Unable to remove a job directory - manual deletion required."
            out-logfile -string $_
        }
    }

    #>

    $directories | foreach-object -Parallel {
        try {
            remove-Item -path $_ -Recurse -Force -ErrorAction STOP
        }
        catch {
            out-logfile -string "Unable to remove a job directory - manual deletion required."
            out-logfile -string $_
        } -ThrottleLimit 10
    }
        
    out-logfile -string "End Remove-JobDirectories"
}