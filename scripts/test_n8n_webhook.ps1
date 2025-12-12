$url = "http://192.168.29.71:5678/webhook/n8n"
$body = @{
    event = "message_created"
    message_type = "incoming"
    content = "Meu nome é João Silva"
    contact = @{ id = 123; phone_number = "5566999999999" }
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
} | ConvertTo-Json

Write-Host "Testando Webhook n8n (POST) em: $url"
Write-Host "Payload: $body"

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    Write-Host "✅ Sucesso! Resposta do n8n:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "❌ Erro ao chamar Webhook:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)"
    Write-Host "Mensagem: $($_.ErrorDetails.Message)"
    
    # Check if it is the 404 error
    if ($_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Host "`n⚠️  Diagnóstico: O n8n retornou 404 (Não Encontrado)." -ForegroundColor Yellow
        Write-Host "Possíveis causas:"
        Write-Host "1. O Workflow não está Ativo (chave 'Active' no topo direito da tela do n8n)."
        Write-Host "2. O nó Webhook não está configurado para o método POST."
        Write-Host "3. O path do Webhook não é '/webhook/n8n'."
    }
}
