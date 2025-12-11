$ErrorActionPreference = 'Stop'

$baseUrl = 'http://192.168.29.71:3000'
$accountId = 1
$token = 'CDuFU9XcuoXTF7uHarDFWCw3'
$headers = @{ 'api_access_token' = $token }

function Get-InboxId {
  $resp = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/$accountId/inboxes" -Headers $headers -Method Get
  if ($resp.payload.inboxes.Count -gt 0) { return $resp.payload.inboxes[0].id }
  Write-Host 'Nenhuma inbox encontrada, criando uma (API inbox: Havoc)...'
  return Create-Inbox
}

function Create-Inbox {
  $body = @{ name = 'Havoc'; channel = 'api' } | ConvertTo-Json
  $resp = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/$accountId/inboxes" -Headers $headers -Method Post -Body $body -ContentType 'application/json'
  return $resp.payload.inbox.id
}

function Create-Contact {
  $body = @{ name = 'MinIO Test'; email = 'minio@test.local'; phone_number = '+5566990000000' } | ConvertTo-Json
  $resp = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/$accountId/contacts" -Headers $headers -Method Post -Body $body -ContentType 'application/json'
  return $resp.payload.contact.id
}

function Create-Conversation {
  param($contactId, $inboxId)
  try {
    $body = @{ inbox_id = $inboxId } | ConvertTo-Json
    $resp = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/$accountId/contacts/$contactId/conversations" -Headers $headers -Method Post -Body $body -ContentType 'application/json'
    return $resp.payload.conversation.id
  } catch {
    $body2 = @{ contact_id = $contactId; inbox_id = $inboxId } | ConvertTo-Json
    $resp2 = Invoke-RestMethod -Uri "$baseUrl/api/v1/accounts/$accountId/conversations" -Headers $headers -Method Post -Body $body2 -ContentType 'application/json'
    return $resp2.payload.conversation.id
  }
}

function Upload-Attachment {
  param($conversationId, $filePath)
  $form = @{
    'content' = 'Teste de upload para MinIO'
    'attachments[]' = Get-Item -LiteralPath $filePath
  }
  $resp = Invoke-WebRequest -Uri "$baseUrl/api/v1/accounts/$accountId/conversations/$conversationId/messages" -Headers $headers -Method Post -Form $form
  return $resp.Content
}

Write-Host 'Buscando inbox...'
$inboxId = Get-InboxId
Write-Host "Inbox ID: $inboxId"

Write-Host 'Criando contato...'
$contactId = Create-Contact
Write-Host "Contact ID: $contactId"

Write-Host 'Criando conversa...'
$conversationId = Create-Conversation -contactId $contactId -inboxId $inboxId
Write-Host "Conversation ID: $conversationId"

$filePath = Join-Path $PSScriptRoot 'sample_upload.txt'
if (-not (Test-Path $filePath)) { throw "Arquivo de teste nao encontrado: $filePath" }

Write-Host 'Enviando mensagem com anexo...'
$result = Upload-Attachment -conversationId $conversationId -filePath $filePath
Write-Host 'Resposta da API:'
Write-Output $result
