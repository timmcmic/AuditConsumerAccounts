function Get-MsIdReliableStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserEmail
    )

    $url = "https://login.microsoftonline.com/common/userrealm?user=$([uri]::EscapeDataString($UserEmail))&api-version=2.1&checkForMicrosoftAccount=True"

    out-logfile -string $url

    $r = Invoke-WebRequest -Uri $url -Method Get -UserAgent "Mozilla/5.0" -UseBasicParsing -TimeoutSec 10
    $data = $r.Content | ConvertFrom-Json

    $hasConsumer = $false
    if ($data.MicrosoftAccount -eq 1 -or $data.IsMicrosoftAccountSet -eq $true) {
        $hasConsumer = $true
    }

    out-logfile -string $hasConsumer

    return $hasConsumer
}