$headers = @{
    "api_access_token" = "CDuFU9XcuoXTF7uHarDFWCw3"
    "Content-Type" = "application/json"
}

try {
    Write-Host "Verificando webhooks no Chatwoot..."
    $response = Invoke-RestMethod -Uri "http://192.168.29.71:3000/api/v1/accounts/1/webhooks" -Method Get -Headers $headers
    Write-Host "Webhooks encontrados:"
    Write-Output $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "Erro ao verificar webhooks: $($_.Exception.Message)"
}
