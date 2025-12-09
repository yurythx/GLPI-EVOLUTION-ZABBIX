$headers = @{
    "apikey" = "B8963286-1598-4542-8952-223366998855"
}
try {
    $response = Invoke-RestMethod -Uri "http://192.168.0.159:8081/instance/fetchInstances" -Method Get -Headers $headers
    Write-Output $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "Erro:" $_.Exception.Message
}
