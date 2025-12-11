$headers = @{ 'api_access_token' = 'CDuFU9XcuoXTF7uHarDFWCw3' }
$baseUrl = 'http://192.168.29.71:3000'

try {
  $resp = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/1/conversations" -Headers $headers -Method Get
  $foundUrl = $null
  foreach ($c in $resp.payload.conversations) {
    if ($c.messages) {
      foreach ($m in $c.messages) {
        if ($m.attachments -and $m.attachments.Count -gt 0) { $foundUrl = $m.attachments[0].data_url; break }
      }
    }
    if ($foundUrl) { break }
  }
  if (-not $foundUrl) { throw 'Nenhum anexo encontrado nas conversas' }
  $url = $foundUrl
  Write-Host "Anexo encontrado: $url"
  $wr = Invoke-WebRequest -Uri $url -Headers $headers -MaximumRedirection 0 -ErrorAction SilentlyContinue
  if ($wr.StatusCode -eq 302 -or $wr.StatusCode -eq 301) {
    Write-Host "Redirect Location:" $wr.Headers['Location']
  } else {
    Write-Host "Status sem redirect:" $wr.StatusCode
  }
} catch {
  Write-Host "Erro: $($_.Exception.Message)"
}
