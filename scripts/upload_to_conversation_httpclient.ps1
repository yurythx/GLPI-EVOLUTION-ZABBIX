$ErrorActionPreference = 'Stop'
$cid = 2
$token = 'CDuFU9XcuoXTF7uHarDFWCw3'
$url = "http://192.168.0.159:3000/api/v1/accounts/1/conversations/$cid/messages"
$filePath = Join-Path $PSScriptRoot 'sample_upload.txt'
if (-not (Test-Path $filePath)) { throw "Arquivo nao encontrado: $filePath" }

Add-Type -AssemblyName System.Net.Http
$handler = New-Object System.Net.Http.HttpClientHandler
$client = New-Object System.Net.Http.HttpClient($handler)
$client.DefaultRequestHeaders.Add('api_access_token', $token)

$content = New-Object System.Net.Http.MultipartFormDataContent
$content.Add((New-Object System.Net.Http.StringContent('Teste MinIO via API')), 'content')

$bytes = [System.IO.File]::ReadAllBytes($filePath)
$fileContent = New-Object System.Net.Http.ByteArrayContent($bytes, 0, $bytes.Length)
$fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('text/plain')
$content.Add($fileContent, 'attachments[]', 'sample_upload.txt')

$response = $client.PostAsync($url, $content).Result
Write-Host "StatusCode: $($response.StatusCode)"
$respBody = $response.Content.ReadAsStringAsync().Result
Write-Output $respBody
