$headers = @{ 'api_access_token' = 'CDuFU9XcuoXTF7uHarDFWCw3' }
$baseUrl = 'http://192.168.0.159:3000'

try {
  $convResp = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/1/conversations" -Headers $headers -Method Get
  foreach ($c in $convResp.payload.conversations) {
    $cid = $c.id
    $msgResp = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/1/conversations/$cid/messages" -Headers $headers -Method Get
    foreach ($m in $msgResp.payload.messages) {
      if ($m.attachments -and $m.attachments.Count -gt 0) {
        $url = $m.attachments[0].data_url
        Write-Host ("Anexo encontrado na conversa {0}: {1}" -f $cid, $url)
        $wr = Invoke-WebRequest -Uri $url -Headers $headers -MaximumRedirection 0 -ErrorAction SilentlyContinue
        if ($wr.StatusCode -eq 302 -or $wr.StatusCode -eq 301) {
          Write-Host "Redirect Location:" $wr.Headers['Location']
        } else {
          Write-Host "Status sem redirect:" $wr.StatusCode
        }
        return
      }
    }
  }
  Write-Host 'Nenhum anexo encontrado nas conversas'
} catch {
  Write-Host "Erro: $($_.Exception.Message)"
}
