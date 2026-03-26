function Get-MsIdReliableStatus {
    param(
        [Parameter(Mandatory=$true)]
        $outputObject
    )

    $url = "https://login.microsoftonline.com/common/userrealm?user=$([uri]::EscapeDataString($outputObject.address))&api-version=2.1&checkForMicrosoftAccount=True"

    out-logfile -string $url

    $outputObject.TimeStamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")

    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -UserAgent "Mozilla/5.0" -UseBasicParsing -TimeoutSec 10 -errorAction STOP
        $outputObject.requestID = $response.Headers["x-ms-request-id"]
=
        try {
                $data = $response.Content | ConvertFrom-Json -ErrorAction Stop

        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to convert the response to JSON - failure." -isError:$true
        }
    }
    catch {
        out-logfile -string "Unable to test for presence of commercial account."
        out-logfile -string $_
            
        $outputObject.AccountError = $true
        $outputObject.AccountErrorText = $_
        $outputObject.requestID = "None"
    }

    $status = $false

    if ($data.IsMicrosoftAccountSet -eq $true) 
    {
        out-logfile -string $data.IsMicrosoftAccountSet
        out-logfile -string $data.MicrosoftAccount
        if ($data.MicrosoftAccount -eq 0) { $status = $true }
        elseif ($data.MicrosoftAccount -eq 1) { $status = $false }
        elseif ($data.MicrosoftAccount -eq 2) 
        { 
            $outputObject.AccountError = $true
            $outputObject.AccountErrorText = "Validation request throttled by service." 
        }
        else 
        {
            $outputObject.AccountError = $true
            $outputObject.AccountErrorText = "Unknown error - search logs for any clues." 
        }
    }

    $outputObject.accountPresent = $status

    out-logfile -string $outputObject.accountPresent
    out-logfile -string $outputObject.requestID
    out-logfile -string $outputObject.TimeStamp

    return $outputObject
}