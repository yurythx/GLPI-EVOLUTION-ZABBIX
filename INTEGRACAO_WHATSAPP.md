# 📱 Guia de Integração: WhatsApp (Evolution API) -> Chatwoot -> n8n -> GLPI

Este guia detalha o processo para configurar a comunicação entre o WhatsApp (via Evolution API), a plataforma de atendimento Chatwoot e o orquestrador n8n. O objetivo final é permitir que mensagens recebidas via WhatsApp possam abrir tickets automaticamente no GLPI ou serem tratadas por agentes humanos.

# 📱 Esquema de Configuração da Automação (Chatwoot -> n8n)

A chave do sucesso é usar o **endereço interno** (nome do serviço) para a comunicação entre containers e o **endereço externo** (192.168.29.77) onde for necessário (como na criação da URL do n8n para visualização).

---

## Fase 1: Chatwoot <-> Evolution (O Canal)

Aqui, o Chatwoot precisa se comunicar com a Evolution API para gerenciar o WhatsApp.

| Configuração | Local | Valor a Inserir | Observações |
| :--- | :--- | :--- | :--- |
| **Evolution API URL** | Chatwoot (Configuração do Inbox) | `http://evolution_api:8080` | **Importante:** Use o nome do serviço Docker (`evolution_api`) e a **porta interna 8080** (a porta 8081 é apenas para acesso externo). |
| **Evolution API Key** | Chatwoot (Configuração do Inbox) | `B8963286-1598-4542-8952-223366998855` | Chave definida no `.env` da Evolution. |
| **Evolution Instance Name** | Chatwoot (Configuração do Inbox) | `chatwoot_session` | O nome da instância criado na Evolution. |

---

## Fase 2: n8n (O Gatilho)

O n8n precisa gerar a URL que o Chatwoot chamará.

### 2.1. Configuração do Nó Webhook (n8n)
1.  Crie um Workflow no n8n.
2.  Adicione o nó **Webhook**.
    *   **Method:** POST.
    *   **Endpoint URL:** Deixe o n8n gerar a URL. Ela será similar a: `http://192.168.29.77:5678/webhook/SEU_ID_UNICO`
    *   *Nota: O n8n usará o IP externo configurado (192.168.29.77) pois definimos `WEBHOOK_URL` no compose.*

### 2.2. Obter a URL Interna para o Chatwoot
A URL do passo 2.1 é a URL pública (para acesso externo). No entanto, quando configurarmos o Chatwoot, **devemos modificar o host** para usar o endereço interno do Docker:

| Tipo de URL | Endereço Interno a Ser Usado no Chatwoot |
| :--- | :--- |
| **Webhook URL** | `http://n8n:5678/webhook/SEU_ID_UNICO` |

---

## Fase 3: Chatwoot -> n8n (O Webhook de Saída)

Esta é a ponte principal para iniciar a automação.

| Configuração | Local | Valor a Inserir | Observações |
| :--- | :--- | :--- | :--- |
| **Webhook URL** | Chatwoot (Configurações > Webhooks) | `http://n8n:5678/webhook/SEU_ID_UNICO` | **Crucial:** Use o nome do serviço `n8n` para a comunicação interna entre os containers. |
| **Webhook Eventos** | Chatwoot (Configurações > Webhooks) | Marcar: `message_created`, `conversation_created` | Garante que novas mensagens de WhatsApp acionem o fluxo. |
| **Filtro de Inbox** | Chatwoot (Configurações > Webhooks) | Filtrar para o Inbox de WhatsApp | Recomendado para evitar que mensagens de Email ou Chat Live ativem a abertura de tickets no GLPI. |

---

## ✅ Lista de Verificação Pós-Configuração

Após inserir as URLs conforme o esquema acima, execute estes testes:

1.  **Evolution OK:** Envie um WhatsApp. A mensagem aparece no Chatwoot? (Se sim, Fase 1 OK).
2.  **n8n Escutando:** Ative o Workflow no n8n.
3.  **Webhook OK:** Envie um segundo WhatsApp. O nó Webhook Trigger do n8n mostra um Item de dados recebido? (Se sim, Fase 2 e 3 OK).
