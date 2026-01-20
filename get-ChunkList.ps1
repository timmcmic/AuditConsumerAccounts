function get-ChunkList
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $listToChunk
    )

    out-logfile -string "Start Get-ChunkList"

    $chunkSize = 1000

    $chunks = [System.Collections.Generic.List[Object]]::New()

    out-logfile -string "Starting to chunk the list provided..."

    for ($i = 0; $i -lt $listToChunk.count ; $i += $chunkSize)
    {
        out-logfile -string ("Processing chunk: "+$i.tostring())
        
        $endIndex = [Math]::Min($i + $chunkSize - 1, $listToChunk.Count - 1)

        $chunks.Add($listToChunk[$i..$endIndex]) | Out-Null
    }

    out-logfile -string ("Count of chunks: "+$chunks.Count)

    out-logfile -string "End Get-ChunkList"

    return $chunks
}