# 📱 Guia de Integração: WhatsApp (Evolution API) -> Chatwoot -> n8n -> GLPI

Este guia detalha o processo para configurar a comunicação entre o WhatsApp (via Evolution API), a plataforma de atendimento Chatwoot e o orquestrador n8n. O objetivo final é permitir que mensagens recebidas via WhatsApp possam abrir tickets automaticamente no GLPI ou serem tratadas por agentes humanos.

## 📋 Pré-requisitos

*   Stack Docker rodando (`docker compose up -d`).
*   Acesso administrativo ao Chatwoot, n8n e Evolution API.
*   Um número de WhatsApp disponível para conexão.

---

## 🚀 Passo 1: Configurar a Sessão na Evolution API

Como a Evolution API é um gateway, precisamos criar uma "instância" que representará sua conexão com o WhatsApp.

1.  **Acesse a documentação/Swagger da Evolution API** (opcional para testes) ou use um terminal/Postman.
    *   URL Local: `http://localhost:8081`

2.  **Criar uma Instância**:
    Execute o seguinte comando no seu terminal (ou use Postman) para criar a instância chamada `chatwoot_session`. Substitua `SUA_API_KEY` pela chave definida no `.env` (padrão: `B8963286-1598-4542-8952-223366998855`).

    ```bash
    curl -X POST http://localhost:8081/instance/create \
    -H "apikey: B8963286-1598-4542-8952-223366998855" \
    -H "Content-Type: application/json" \
    -d '{
      "instanceName": "chatwoot_session",
      "token": "token_seguro_da_sessao",
      "qrcode": true,
      "integration": "WHATSAPP-BAILEYS"
    }'
    ```
    *(Nota: A API pode retornar um QR Code em Base64 imediatamente ou você pode buscá-lo no próximo passo).*

3.  **Ler o QR Code**:
    Conecte a instância chamando o endpoint de conexão. Copie o Base64 retornado e use um site como [Base64 to Image](https://codebeautify.org/base64-to-image-converter) para ver o QR Code, ou visualize no log se estiver usando o Manager.

    ```bash
    curl -X GET http://localhost:8081/instance/connect/chatwoot_session \
    -H "apikey: B8963286-1598-4542-8952-223366998855"
    ```
    *   Escaneie o QR Code com seu aplicativo WhatsApp no celular (Aparelhos Conectados > Conectar Aparelho).
    *   Verifique se o status mudou para `open` ou `connected`.

---

## 💬 Passo 2: Configurar Inbox no Chatwoot

Agora vamos dizer ao Chatwoot para usar essa instância da Evolution API como um canal de entrada.

1.  **Login no Chatwoot**:
    *   Acesse: `http://localhost:3000`
    *   Login: `admin@admin.com` / `password` (ou suas credenciais criadas).

2.  **Criar Nova Caixa de Entrada (Inbox)**:
    *   Vá em **Settings (Configurações)** -> **Inboxes** -> **Add Inbox**.
    *   Selecione **WhatsApp**.
    *   Escolha **Evolution API** (ou "API Cloud" se a versão for antiga, mas a v4.8+ tem suporte nativo ou via webhook genérico. Se não houver "Evolution API" explícito, selecione **API Channel** ou siga a configuração via Webhook da Evolution).
    
    *Recomendação para Evolution API v2 + Chatwoot v4+*:
    A Evolution API v2 possui uma integração nativa que envia os dados formatados para o Chatwoot. Portanto, configuraremos a Evolution para enviar para o Chatwoot, e no Chatwoot criaremos um **API Channel** (Canal de API).

    **No Chatwoot (Alternativa via API Channel):**
    *   Escolha **API**.
    *   Nome do Canal: `WhatsApp Suporte`
    *   Webhook URL: O Chatwoot fornecerá uma URL (ex: `http://localhost:3000/webhooks/123...`). Copie apenas o token ou a parte final se necessário, mas para a integração nativa da Evolution, precisamos do **Account ID** e **Inbox ID**.
    *   Após criar, observe a URL no navegador: `.../app/accounts/1/inbox/2`. Aqui, Account ID = 1, Inbox ID = 2.

3.  **Configurar a Evolution para falar com o Chatwoot**:
    Agora que temos o Inbox ID, vamos atualizar as configurações da instância na Evolution API.

    ```bash
    curl -X POST http://localhost:8081/chatwoot/set/chatwoot_session \
    -H "apikey: B8963286-1598-4542-8952-223366998855" \
    -H "Content-Type: application/json" \
    -d '{
      "enabled": true,
      "accountId": 1,
      "token": "TOKEN_DO_INBOX_DO_CHATWOOT",
      "url": "http://chatwoot_web:3000",
      "signMsg": true,
      "reopenConversation": true,
      "conversationPending": false
    }'
    ```
    *   **Importante**: 
        *   `url`: Use `http://chatwoot_web:3000` (endereço interno na rede Docker).
        *   `token`: É o `API Access Token` do Inbox que você criou no Chatwoot (Settings > Inboxes > Settings do Inbox criado > Configuration).

---

## ⚡ Passo 3: Enviar Dados do Chatwoot para o n8n

Quando uma mensagem chega no Chatwoot, queremos que o n8n saiba (para abrir ticket no GLPI).

1.  **Configurar n8n**:
    *   Acesse `http://localhost:5678`.
    *   Crie um novo Workflow.
    *   Adicione um nó **Webhook**.
    *   Método: `POST`.
    *   Copie a URL de Teste (ex: `http://localhost:5678/webhook-test/...`) ou Produção.
    *   **Atenção**: Para o Chatwoot (que roda no Docker) acessar o n8n, troque `localhost` por `n8n`.
    *   URL para o Chatwoot usar: `http://n8n:5678/webhook/SEU-UUID-AQUI`.

2.  **Configurar Webhook no Chatwoot**:
    *   No Chatwoot, vá em **Settings** -> **Integrations** -> **Webhooks**.
    *   Clique em **Add New Webhook**.
    *   **URL**: Cole a URL do n8n modificada (`http://n8n:5678/webhook/...`).
    *   **Events**: Selecione `Message Created` e `Conversation Created`.
    *   Salvar.

---

## 🧪 Teste Integrado

1.  **Ative o Workflow no n8n** (clique em "Listen" ou ative o modo Produção).
2.  Envie uma mensagem de WhatsApp (do seu celular pessoal) para o número conectado na Evolution API.
3.  **Fluxo Esperado**:
    *   WhatsApp -> Evolution API
    *   Evolution API -> Chatwoot (Cria conversa/mensagem)
    *   Chatwoot -> Webhook -> n8n (Recebe JSON da mensagem)
4.  No n8n, você verá o JSON chegando com o conteúdo da mensagem, número do remetente, etc.

---

## 🛠️ Solução de Problemas Comuns

*   **Erro de Conexão (ECONNREFUSED)**: Verifique se está usando os nomes de host corretos (`chatwoot_web`, `n8n`, `evolution_api`) e se todos estão na rede `stack_network`.
*   **Mensagem não aparece no Chatwoot**: Verifique os logs da Evolution API (`docker logs evolution_api`) para ver se houve erro ao enviar para o Chatwoot. Confirme se o `accountId` e `token` estão corretos.
*   **QR Code não gera**: Reinicie a Evolution API. Certifique-se de que não há outra sessão conectada nesse número.
