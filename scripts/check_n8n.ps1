try {
    Write-Host "Verificando status do n8n (http://192.168.29.71:5678)..."
    $response = Invoke-RestMethod -Uri "http://192.168.29.71:5678/healthz" -Method Get
    Write-Host "n8n esta online!"
    Write-Output $response
} catch {
    Write-Host "Erro ao conectar no n8n: $($_.Exception.Message)"
}
