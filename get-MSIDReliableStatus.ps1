function Get-MsIdReliableStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$outputObject
    )

    $url = "https://login.microsoftonline.com/common/userrealm?user=$([uri]::EscapeDataString($outputObject.address))&api-version=2.1&checkForMicrosoftAccount=True"

    out-logfile -string $url

    $r = Invoke-WebRequest -Uri $url -Method Get -UserAgent "Mozilla/5.0" -UseBasicParsing -TimeoutSec 10
    $data = $r.Content | ConvertFrom-Json

    $status = $false

    if ($data.IsMicrosoftAccountSet -eq $true) 
    {
        out-logfile -string $data.IsMicrosoftAccountSet
        out-logfile -string $data.MicrosoftAccount
        if ($data.MicrosoftAccount -eq 0) { $status = $true }
        elseif ($data.MicrosoftAccount -eq 1) { $status = $false }
    }

    $outputObject.accountPresent = $status
    $outputObject.requestID = $response.Headers["x-ms-request-id"]
    $outputObject.TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    return $outputObject
}