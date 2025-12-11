# Scripts de Automação e Teste

Esta pasta contém scripts PowerShell auxiliares para testar, validar e configurar a integração entre Chatwoot, MinIO e outras ferramentas.

## Scripts Principais de Integração MinIO

### `test_minio_connection.ps1`
**Função**: Testa a conectividade direta com o MinIO usando a API S3.
**Uso**: Verifica se as credenciais e o endpoint estão acessíveis fora do Chatwoot. Útil para isolar se o problema é no MinIO ou na config do Chatwoot.

### `upload_to_conversation_httpclient.ps1`
**Função**: Envia um arquivo de texto (`sample_upload.txt`) para uma conversa específica no Chatwoot via API.
**Uso**: Valida se o fluxo de upload de ponta a ponta está funcionando. Se o Chatwoot estiver mal configurado, este script retornará erro (geralmente 422 ou 500).
**Configuração**: Edite as variáveis `$cid` (ID da conversa) e `$token` (Token da API) no início do arquivo.

### `check_single_redirect.ps1`
**Função**: Verifica o comportamento de redirecionamento de anexos.
**Uso**: Pega uma URL de anexo do Chatwoot e verifica para onde ela aponta. Deve redirecionar para o endpoint do MinIO.

## Outros Scripts Úteis

- **`test_chatwoot_minio.ps1`**: Script de teste legado/inicial.
- **`create_n8n_workflow.ps1`**: Cria workflows no n8n via API.
- **`setup_integration.ps1`**: Script geral de setup (pode estar desatualizado, verifique antes de usar).

## Como Executar

Abra um terminal PowerShell como Administrador (ou com permissões adequadas) e execute:

```powershell
# Exemplo
powershell -ExecutionPolicy Bypass -File .\test_minio_connection.ps1
```
