$headers = @{
    "api_access_token" = "CDuFU9XcuoXTF7uHarDFWCw3"
    "Content-Type" = "application/json"
}

try {
    Write-Host "Verificando token no Chatwoot (http://localhost:3000)..."
    $response = Invoke-RestMethod -Uri "http://192.168.29.71:3000/api/v1/accounts/1" -Method Get -Headers $headers
    Write-Host "Sucesso! Token valido."
    Write-Output $response
} catch {
    Write-Host "Erro ao conectar no Chatwoot: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Detalhes do erro: $responseBody"
        }
    }
}
