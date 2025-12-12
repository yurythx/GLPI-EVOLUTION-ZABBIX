$n8nUser = "admin"
$n8nPass = "password"
$pair = "$( $n8nUser ):$( $n8nPass )"
$b64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
$headers = @{ Authorization = "Basic $b64"; "Content-Type" = "application/json" }
$url = "http://192.168.29.71:5678/rest/workflows"

$workflow = @{
  name = "Chatwoot → Evolution"
  active = $false
  nodes = @(
    @{ parameters = @{ path = "n8n"; options = @{}; responseMode = "onReceived"; httpMethod = "POST"; responseCode = 200 }; id = "Webhook1"; name = "Webhook"; type = "n8n-nodes-base.webhook"; typeVersion = 1; position = @(260,300) },
    @{ parameters = @{ functionCode = 'return [{ event: $json.event, message: $json.message?.content || $json.content || $json.payload?.content || "", direction: $json.message_type || $json.payload?.message_type || "", phone: $json.phone || $json.contact?.phone_number || $json.sender?.phone_number || "" }];' }; id = "Function1"; name = "Map"; type = "n8n-nodes-base.function"; typeVersion = 1; position = @(500,300) },
    @{ parameters = @{ conditions = @{ string = @(@{ value1 = '={{$json.direction}}'; operation = "equal"; value2 = "outgoing" }) } }; id = "If1"; name = "Is Outgoing"; type = "n8n-nodes-base.if"; typeVersion = 1; position = @(700,300) },
    @{ parameters = @{ url = "http://evolution_api:8081/message/send"; options = @{ }; queryParametersUi = @{ parameter = @() }; sendBody = $true; jsonParameters = $true; authentication = "none"; headerParametersUi = @{ parameter = @(@{ name = "apikey"; value = "B8963286-1598-4542-8952-223366998855" }) }; bodyParametersJson = '={ "number": {{$json.phone}}, "text": {{$json.message}}, "instanceName": "Havoc" }'; method = "POST" }; id = "Http1"; name = "Send to Evolution"; type = "n8n-nodes-base.httpRequest"; typeVersion = 3; position = @(900,300) }
  )
  connections = @{ 
    Webhook = @{ main = @(@(@{ node = "Map"; type = "main"; index = 0 })) }
    Map = @{ main = @(@(@{ node = "Is Outgoing"; type = "main"; index = 0 })) }
    "Is Outgoing" = @{ main = @(@(@{ node = "Send to Evolution"; type = "main"; index = 0 }), @()) }
  }
  settings = @{}
  staticData = @{}
}

$body = $workflow | ConvertTo-Json -Depth 20
$createResp = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
$id = $createResp.id

if ($id) {
  $patchUrl = "http://192.168.29.71:5678/rest/workflows/$id"
  $patchBody = @{ active = $true } | ConvertTo-Json
  $patchResp = Invoke-RestMethod -Uri $patchUrl -Method Patch -Headers $headers -Body $patchBody
  Write-Output "Workflow criado e ativado: ID $id"
} else {
  Write-Output "Falha ao criar workflow"
}
