$ErrorActionPreference = 'Stop'
$headers = @{ 'api_access_token' = 'CDuFU9XcuoXTF7uHarDFWCw3' }
$cid = 2
$filePath = Join-Path $PSScriptRoot 'sample_upload.txt'
if (-not (Test-Path $filePath)) { throw "Arquivo nao encontrado: $filePath" }
$form = @{
  'content' = 'Teste MinIO via API'
  'attachments[]' = Get-Item -LiteralPath $filePath
}
$resp = Invoke-WebRequest -Uri "http://192.168.29.71:3000/api/v1/accounts/1/conversations/$cid/messages" -Headers $headers -Method Post -Form $form -UseBasicParsing
Write-Output $resp.Content

