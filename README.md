# 🚀 Stack ITSM, Monitoramento & Automação (GLPI + Zabbix + Chatwoot + Evolution API)

Este repositório contém a infraestrutura completa, orquestrada via Docker Compose, para uma suíte de Gestão de Serviços de TI (ITSM), Monitoramento de Infraestrutura e Atendimento Omnichannel.

O projeto foi desenhado para ser modular, escalável e seguro, utilizando segmentação de redes e persistência de dados.

---

## 📋 Índice
1. [Arquitetura da Solução](#-arquitetura-da-solução)
2. [Fluxograma de Dados](#-fluxograma-de-dados)
3. [Componentes da Stack](#-componentes-da-stack)
4. [Pré-requisitos](#-pré-requisitos)
5. [Instalação e Deploy](#-instalação-e-deploy)
6. [Pós-Instalação (Setup Inicial)](#-pós-instalação-setup-inicial)
7. [Estrutura de Diretórios](#-estrutura-de-diretórios)
8. [Troubleshooting](#-troubleshooting)

---

## 🏛 Arquitetura da Solução

A infraestrutura utiliza uma **rede virtual unificada** (`stack_network`) para facilitar a comunicação entre todos os serviços, mantendo a organização lógica através da orquestração via Docker Compose.

*   **`stack_network`:** Rede compartilhada por todos os componentes (GLPI, Zabbix, Chatwoot, Evolution API, MinIO e n8n), permitindo comunicação direta e eficiente via DNS interno do Docker.

O **n8n** atua como o **Hub de Integração**, orquestrando os fluxos de dados entre os serviços.

---

## 🔄 Fluxograma de Dados

Abaixo, o diagrama detalhado das conexões, redes e fluxo de dados entre os serviços.

```mermaid
graph TD
    %% Definição de Estilos
    classDef external fill:#f9f,stroke:#333,stroke-width:2px;
    classDef internal fill:#e1f5fe,stroke:#0277bd,stroke-width:2px;
    classDef db fill:#fff3e0,stroke:#ef6c00,stroke-width:1px;

    %% Atores Externos
    User(("Usuário / Admin")):::external
    Customer(("Cliente WhatsApp")):::external

    %% Subgraph: Stack Network
    subgraph Stack_Network ["☁️ Rede Unificada: stack_network"]
        direction TB
        
        %% Serviços
        EvolAPI["📱 Evolution API<br/>(Porta: 8081)"]:::internal
        MinIO["🗄️ MinIO S3<br/>(Porta: 9004/9005)"]:::internal
        n8n["⚡ n8n Workflow<br/>(Porta: 5678)"]:::internal
        GLPI["🛠️ GLPI<br/>(Porta: 18080)"]:::internal
        Zabbix["📈 Zabbix Server/Web<br/>(Porta: 18081)"]:::internal
        Chatwoot["💬 Chatwoot<br/>(Porta: 3000)"]:::internal

        %% Bancos de Dados e Cache
        RedisEvol[("Redis Evol")]:::db
        PostgresEvol[("Postgres Evol")]:::db
        PostgresN8N[("Postgres n8n")]:::db
        RedisN8N[("Redis n8n")]:::db
        MariaDB[("MariaDB GLPI")]:::db
        PostgresZabbix[("Postgres Zabbix")]:::db
        PostgresChat[("Postgres Chatwoot")]:::db
        RedisChat[("Redis Chatwoot")]:::db
    end

    %% Conexões Externas
    User -->|Acesso Web| GLPI
    User -->|Acesso Web| Zabbix
    User -->|Acesso Web| Chatwoot
    User -->|Acesso Web| n8n
    User -->|Acesso Web| MinIO
    Customer -->|Mensagens| EvolAPI

    %% Conexões Internas (Serviços)
    EvolAPI --> RedisEvol
    EvolAPI --> PostgresEvol
    EvolAPI -->|Integração Nativa| Chatwoot
    
    n8n -->|Orquestração| EvolAPI
    n8n -->|API| Chatwoot
    n8n -->|API| GLPI
    n8n -->|Webhooks| Zabbix
    n8n --> PostgresN8N
    n8n --> RedisN8N

    Chatwoot --> PostgresChat
    Chatwoot --> RedisChat
    Chatwoot -.->|Armazenamento| MinIO

    GLPI --> MariaDB
    Zabbix --> PostgresZabbix
```

---

## 🧩 Componentes da Stack

### 1. **GLPI (v11.0.1)**
*   **Função:** Service Desk, Gestão de Ativos (CMDB) e Rastreamento de Problemas.
*   **Imagem:** `glpi/glpi:11.0.1`
*   **Banco:** MariaDB 10.11

### 2. **Chatwoot (v4.8.0)**
*   **Função:** Plataforma de atendimento ao cliente (Live Chat, WhatsApp, Email).
*   **Imagem:** `chatwoot/chatwoot:v4.8.0` (Edição Community)
*   **Recursos:** Suporte a `pgvector` para funcionalidades de IA.

### 3. **Zabbix (v7.0 LTS)**
*   **Função:** Monitoramento de redes, servidores e aplicações em tempo real.
*   **Imagem:** Alpine based (leve e segura).

### 4. **Evolution API (Latest)**
*   **Função:** Gateway para conexão com o WhatsApp (baseado na biblioteca Baileys).
*   **Recursos:** Multi-sessão, envio de mídia, webhooks.

### 5. **n8n**
*   **Função:** Orquestrador de automação "Low-code". Conecta todos os serviços acima.

### 6. **MinIO**
*   **Função:** Object Storage compatível com S3.
*   **Uso:** Armazenamento centralizado de arquivos (anexos do Chatwoot, backups).

---

## ⚙️ Pré-requisitos

Para rodar esta stack, seu servidor deve atender aos requisitos mínimos:

*   **Sistema Operacional:** Linux (Ubuntu 22.04+ recomendado) ou Windows (com WSL2).
*   **Docker:** Versão 24.0+
*   **Docker Compose:** Versão 2.20+
*   **Hardware Recomendado:**
    *   **CPU:** 4 vCPUs
    *   **RAM:** 8GB+ (O Zabbix e GLPI juntos consomem consideravelmente, e o Java do Elasticsearch [se adicionado futuramente] demandaria mais).
    *   **Disco:** 50GB SSD livre.

---

## 🚀 Instalação e Deploy

### Opção A: Deploy Padrão (Docker Compose)

1.  **Clone o Repositório:**
    ```bash
    git clone https://seu-git/projeto-itsm.git
    cd projeto-itsm
    ```

2.  **Configuração de Ambiente (.env):**
    O arquivo `.env` na raiz contém todas as senhas e chaves. **ALTERE AS SENHAS PADRÃO** antes de subir em produção.
    ```bash
    # Exemplo de variáveis críticas
    POSTGRES_PASSWORD=sua_senha_segura
    MINIO_ROOT_PASSWORD=sua_senha_minio
    SECRET_KEY_BASE=gere_uma_hash_longa_para_o_chatwoot
    ```

3.  **Iniciar a Stack:**
    Utilizamos um arquivo `compose.yaml` central que importa os módulos individuais.
    ```bash
    docker compose up -d
    ```

4.  **Verificar Status:**
    ```bash
    docker compose ps
    ```
    *Aguarde alguns minutos até que todos os serviços estejam com status `(healthy)`.*

### Opção B: Deploy no aaPanel (Ubuntu/CentOS)

O **aaPanel** é um painel de controle popular que gerencia Nginx/Apache. Como esta stack usa Docker, o aaPanel atuará principalmente como **Proxy Reverso** e gerenciador de Firewall.

1.  **Instale o Docker via aaPanel:**
    *   Vá em **App Store** > Procure por **Docker** > Instale a versão mais recente.

2.  **Clone e Suba a Stack via Terminal:**
    *   Acesse o terminal do servidor (via SSH ou Terminal do aaPanel).
    *   Navegue para `/www/wwwroot/` (recomendado para organizar).
    *   Siga os passos 1, 2 e 3 da "Opção A" acima.

3.  **Configuração de Domínios e Proxy Reverso:**
    Para cada serviço, crie um site no aaPanel e aponte para a porta local do container.

    | Serviço | Porta Local | Configuração no aaPanel |
    | :--- | :--- | :--- |
    | **Chatwoot** | `3000` | Crie site `chat.seudominio.com` > Config > Reverse Proxy > Target: `http://127.0.0.1:3000` |
    | **GLPI** | `18080` | Crie site `suporte.seudominio.com` > Config > Reverse Proxy > Target: `http://127.0.0.1:18080` |
    | **Zabbix** | `18081` | Crie site `monitor.seudominio.com` > Config > Reverse Proxy > Target: `http://127.0.0.1:18081` |
    | **n8n** | `5678` | Crie site `n8n.seudominio.com` > Config > Reverse Proxy > Target: `http://127.0.0.1:5678` |
    | **Evolution API**| `8081` | Crie site `api.seudominio.com` > Config > Reverse Proxy > Target: `http://127.0.0.1:8081` |
    | **MinIO API** | `9004` | Crie site `s3.seudominio.com` > Config > Reverse Proxy > Target: `http://127.0.0.1:9004` |
    | **MinIO Console**| `9005` | Crie site `minio.seudominio.com` > Config > Reverse Proxy > Target: `http://127.0.0.1:9005` |

4.  **WebSocket (Importante para Chatwoot/Evolution):**
    *   No arquivo de configuração do Nginx do aaPanel (Config > Config file), adicione suporte a Upgrade de headers para conexões WebSocket funcionarem corretamente, caso o Proxy reverso padrão não configure automaticamente.

---

## 🛠 Pós-Instalação (Setup Inicial)

Após subir os containers, você precisa finalizar a configuração via navegador:

### 1. Chatwoot (`http://localhost:3000`)
*   Acesse a URL.
*   Crie a conta de administrador (email/senha).
*   *Nota: O banco já foi inicializado via script.*

### 2. GLPI (`http://localhost:18080`)
*   Selecione o idioma.
*   Aceite a licença.
*   **Instalar** > Verificar requisitos.
*   **Configuração do Banco:**
    *   Servidor: `glpi-db`
    *   Usuário: `glpi_user`
    *   Senha: (ver no .env, padrão `sua_senha_glpi_db`)
*   Selecione o banco `glpi_db`.

### 3. Zabbix (`http://localhost:18081`)
*   **Database Host:** `zabbix-db`
*   **Database Name:** `zabbix_db`
*   **User:** `zabbix_user`
*   **Password:** (ver no .env, padrão `sua_senha_zabbix_db`)

### 4. Evolution API (`http://localhost:8081`)
*   A API é "Headless" (sem interface visual nativa complexa). Use o **n8n** ou Postman para interagir.
*   **Global API Key:** Definida no `.env` (`AUTHENTICATION_API_KEY`).

---

## 📂 Estrutura de Diretórios

```plaintext
/
├── compose.yaml          # Arquivo mestre de orquestração
├── .env                  # Variáveis de ambiente globais
├── README.md             # Esta documentação
│
├── Chatwoot/
│   ├── compose.yaml      # Definição do serviço Chatwoot
│   └── .env              # Variáveis específicas do Chatwoot
│
├── GLPI/
│   ├── glpi.yml          # Definição do serviço GLPI + MariaDB
│   └── .env              # Variáveis específicas
│
├── Zabbix/
│   └── zabbix.yml        # Definição do Zabbix Server/Web/Agent
│
├── evolution/
│   └── compose.yaml      # Definição da API de WhatsApp
│
├── n8n/
│   └── compose.yaml      # Definição do n8n + Redis/Postgres dedicados
│
└── minio/
    └── compose.yaml      # Definição do Object Storage
```

---

## 🔧 Troubleshooting

### Chatwoot não mostra tela de cadastro
Execute o reset forçado do banco de dados (CUIDADO: Apaga dados do Chatwoot):
```bash
docker compose -f Chatwoot/compose.yaml down -v
docker compose -f Chatwoot/compose.yaml up -d
docker compose -f Chatwoot/compose.yaml exec web bundle exec rails db:create db:schema:load db:seed
```

### Erro de Conexão no Banco (GLPI/Zabbix)
Verifique se o container do banco está saudável:
```bash
docker compose ps | grep db
```
Se o banco reiniciar em loop, verifique os logs:
```bash
docker compose logs glpi-db
```
*Geralmente é erro de senha ou permissão de volume.*

### Portas Ocupadas
Se receber erro `Bind for 0.0.0.0:8080 failed: port is already allocated`, edite o `.env` ou os arquivos `compose.yaml` para alterar a porta externa (ex: mudar `18080:80` para `18081:80`).
