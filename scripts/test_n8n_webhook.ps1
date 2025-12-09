$bodyObj = @{ test = $true }
$body = $bodyObj | ConvertTo-Json
try {
  Write-Host "Enviando teste para webhook do n8n..."
  $resp = Invoke-RestMethod -Uri 'http://192.168.0.159:5678/webhook/evolution' -Method Post -Body $body -ContentType 'application/json'
  Write-Host "Resposta do n8n:"; Write-Output $resp
} catch {
  Write-Host "Falha ao enviar webhook: $($_.Exception.Message)"
  if ($_.Exception.Response) {
    $stream = $_.Exception.Response.GetResponseStream(); if ($stream) {
      $reader = New-Object System.IO.StreamReader($stream); $responseBody = $reader.ReadToEnd();
      Write-Host "Detalhes (Body): $responseBody"
    }
  }
}

