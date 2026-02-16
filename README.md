# ELK Logging Project 🔍

Sistema completo de centralização de logs usando ELK Stack (Elasticsearch, Logstash, Kibana) com aplicações de teste em múltiplas linguagens.

![ELK Stack](https://img.shields.io/badge/ELK-8.11.0-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-blue)
![Python](https://img.shields.io/badge/Python-3.11-green)
![.NET](https://img.shields.io/badge/.NET-8.0-purple)
![Go](https://img.shields.io/badge/Go-1.21-cyan)
![Node.js](https://img.shields.io/badge/Node.js-20-green)
![Rust](https://img.shields.io/badge/Rust-1.75-orange)

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação Rápida](#-instalação-rápida)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Uso Detalhado](#-uso-detalhado)
- [Aplicações](#-aplicações)
- [Template Python](#-template-python)
- [Visualização no Kibana](#-visualização-no-kibana)
- [Troubleshooting](#-troubleshooting)
- [Contribuindo](#-contribuindo)

## 🎯 Visão Geral

Este projeto implementa uma infraestrutura completa para centralização de logs utilizando a stack ELK (Elasticsearch, Logstash, Kibana). Inclui:

- ✅ **ELK Stack 8.11.0** completo em Docker
- ✅ **5 aplicações de exemplo** em diferentes linguagens
- ✅ **Logs estruturados em JSON** com metadata rica
- ✅ **Template Python reutilizável** para novos projetos
- ✅ **Dashboard Kibana** pré-configurado
- ✅ **Makefile** com comandos úteis
- ✅ **Documentação completa**

### Aplicações Incluídas

1. **Python** - Usando logging nativo do Python
2. **.NET (C#)** - Usando System.Text.Json
3. **Go** - Usando pacotes nativos
4. **Node.js** - Usando módulos nativos
5. **Rust** - Usando serde_json e chrono

Todas as aplicações:
- Geram logs em **todos os níveis** (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Enviam logs **estruturados em JSON** para Logstash
- Incluem **metadata** completa (timestamp, hostname, app_name, environment)
- Executam em **loop contínuo** para testes
- Têm **health checks** configurados

## 🏗 Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                      Applications                            │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐       │
│  │ Python  │  .NET   │   Go    │ Node.js │  Rust   │       │
│  └────┬────┴────┬────┴────┬────┴────┬────┴────┬────┘       │
│       │         │         │         │         │             │
│       └─────────┴─────────┴─────────┴─────────┘             │
│                         │                                    │
│                    JSON Logs (TCP)                          │
│                         ▼                                    │
│  ┌───────────────────────────────────────────────┐          │
│  │            Logstash (Port 5000)               │          │
│  │  - Receives JSON logs via TCP                 │          │
│  │  - Parses and enriches data                   │          │
│  │  - Normalizes fields                          │          │
│  └──────────────────┬────────────────────────────┘          │
│                     │                                        │
│                     ▼                                        │
│  ┌───────────────────────────────────────────────┐          │
│  │         Elasticsearch (Port 9200)             │          │
│  │  - Stores logs in daily indices               │          │
│  │  - Full-text search capabilities              │          │
│  │  - Persistent storage                         │          │
│  └──────────────────┬────────────────────────────┘          │
│                     │                                        │
│                     ▼                                        │
│  ┌───────────────────────────────────────────────┐          │
│  │           Kibana (Port 5601)                  │          │
│  │  - Web UI for log visualization              │          │
│  │  - Dashboards and analytics                  │          │
│  │  - Query interface                           │          │
│  └───────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo de Dados

1. **Aplicações** geram logs estruturados em JSON
2. **Logstash** recebe logs via TCP (porta 5000)
3. **Logstash** processa e enriquece os logs
4. **Elasticsearch** armazena logs em índices diários (`logs-YYYY.MM.DD`)
5. **Kibana** permite visualização e análise dos logs

## 📦 Pré-requisitos

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Make** (opcional, mas recomendado)
- **4GB RAM** mínimo disponível
- **10GB** de espaço em disco

### Verificar Pré-requisitos

```bash
docker --version
docker-compose --version
make --version
```

## 🚀 Instalação Rápida

### 1. Clone o repositório

```bash
git clone https://github.com/joaomb98/elk-logging-project.git
cd elk-logging-project
```

### 2. Configure variáveis de ambiente

```bash
cp .env.example .env
# Edite .env se necessário (opcional para começar)
```

### 3. Inicie o ELK Stack

```bash
make elk-up
```

Aguarde cerca de 60 segundos para o ELK Stack ficar totalmente operacional.

### 4. Verifique o status

```bash
make check-elk
```

### 5. Inicie as aplicações

```bash
make apps-up
```

### 6. Acesse o Kibana

Abra seu navegador em: http://localhost:5601

## 📁 Estrutura do Projeto

```
elk-logging-project/
├── elk-stack/                          # ELK Stack configuration
│   ├── docker-compose.yml              # Docker Compose for ELK
│   ├── elasticsearch/
│   │   └── config/
│   │       └── elasticsearch.yml       # Elasticsearch config
│   ├── logstash/
│   │   ├── config/
│   │   │   └── logstash.yml           # Logstash config
│   │   └── pipeline/
│   │       └── logstash.conf          # Logstash pipeline
│   └── kibana/
│       └── config/
│           └── kibana.yml             # Kibana config
│
├── applications/                       # Sample applications
│   ├── docker-compose.yml             # Docker Compose for apps
│   ├── python-app/                    # Python application
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   ├── logger_config.py
│   │   └── requirements.txt
│   ├── dotnet-app/                    # .NET application
│   │   ├── Dockerfile
│   │   ├── Program.cs
│   │   └── LoggingApp.csproj
│   ├── go-app/                        # Go application
│   │   ├── Dockerfile
│   │   ├── main.go
│   │   └── go.mod
│   ├── nodejs-app/                    # Node.js application
│   │   ├── Dockerfile
│   │   ├── app.js
│   │   └── package.json
│   └── rust-app/                      # Rust application
│       ├── Dockerfile
│       ├── Cargo.toml
│       └── src/
│           └── main.rs
│
├── templates/                          # Reusable templates
│   └── python-logging-template/
│       ├── logger_config.py           # Logger configuration
│       ├── requirements.txt           # Dependencies
│       └── README.md                  # Template documentation
│
├── kibana-dashboards/                  # Kibana dashboards
│   └── logs-dashboard.ndjson          # Pre-configured dashboard
│
├── .env.example                        # Environment variables template
├── .gitignore                          # Git ignore rules
├── Makefile                            # Useful commands
└── README.md                           # This file
```

## 🔧 Uso Detalhado

### Comandos Make

#### ELK Stack

```bash
make elk-up              # Iniciar ELK Stack
make elk-down            # Parar ELK Stack
make elk-restart         # Reiniciar ELK Stack
make check-elk           # Verificar saúde do ELK
make logs-elk            # Ver logs do ELK
```

#### Aplicações

```bash
make apps-up             # Iniciar todas as aplicações
make apps-down           # Parar todas as aplicações
make apps-restart        # Reiniciar todas as aplicações
make apps-build          # Rebuild aplicações
make check-apps          # Verificar status das apps
make logs-apps           # Ver logs de todas as apps
```

#### Logs Individuais

```bash
make logs-python         # Ver logs da app Python
make logs-dotnet         # Ver logs da app .NET
make logs-go             # Ver logs da app Go
make logs-nodejs         # Ver logs da app Node.js
make logs-rust           # Ver logs da app Rust
```

#### Comandos Combinados

```bash
make all-up              # Iniciar tudo (ELK + Apps)
make all-down            # Parar tudo
make status              # Status de todos os serviços
make clean               # Parar e remover volumes
make clean-all           # Limpeza completa (incluindo imagens)
```

### Comandos Docker Compose Diretos

Se preferir não usar o Makefile:

```bash
# ELK Stack
cd elk-stack
docker-compose up -d
docker-compose down
docker-compose logs -f

# Applications
cd applications
docker-compose up -d
docker-compose down
docker-compose logs -f
```

## 📱 Aplicações

### Python Application

**Localização**: `applications/python-app/`

- **Linguagem**: Python 3.11
- **Framework**: Logging nativo
- **Características**:
  - Sem dependências externas
  - Logging estruturado em JSON
  - Formatador customizado
  - Handlers para console e Logstash

**Executar localmente**:
```bash
cd applications/python-app
export LOGSTASH_HOST=localhost
export LOGSTASH_PORT=5000
python app.py
```

### .NET Application

**Localização**: `applications/dotnet-app/`

- **Linguagem**: C# .NET 8.0
- **Características**:
  - Multi-stage build
  - System.Text.Json para serialização
  - Conexão TCP para Logstash

**Executar localmente**:
```bash
cd applications/dotnet-app
dotnet run
```

### Go Application

**Localização**: `applications/go-app/`

- **Linguagem**: Go 1.21
- **Características**:
  - Build otimizado com Alpine
  - Encoding/json nativo
  - Goroutines para logging assíncrono

**Executar localmente**:
```bash
cd applications/go-app
go run main.go
```

### Node.js Application

**Localização**: `applications/nodejs-app/`

- **Linguagem**: Node.js 20
- **Características**:
  - Módulos nativos (net, os)
  - Event-driven logging
  - Sem dependências externas

**Executar localmente**:
```bash
cd applications/nodejs-app
node app.js
```

### Rust Application

**Localização**: `applications/rust-app/`

- **Linguagem**: Rust 1.75
- **Bibliotecas**:
  - serde_json
  - chrono
  - hostname
- **Características**:
  - Multi-stage build
  - Memory-safe
  - Alto desempenho

**Executar localmente**:
```bash
cd applications/rust-app
cargo run
```

## 🐍 Template Python

O template Python reutilizável está localizado em `templates/python-logging-template/`.

### Como Usar

1. **Copie o logger_config.py para seu projeto**:
```bash
cp templates/python-logging-template/logger_config.py your-project/
```

2. **Use em sua aplicação**:
```python
from logger_config import get_logger

logger = get_logger('my-app')
logger.info('Application started')
logger.error('An error occurred', exc_info=True)
```

3. **Configure variáveis de ambiente**:
```bash
export APP_NAME=my-application
export ENVIRONMENT=production
export LOGSTASH_HOST=logstash
export LOGSTASH_PORT=5000
```

### Documentação Completa

Veja `templates/python-logging-template/README.md` para documentação detalhada.

## 📊 Visualização no Kibana

### Acessar Kibana

1. Abra: http://localhost:5601
2. Aguarde o Kibana carregar

### Criar Index Pattern

1. Vá para **Stack Management** > **Index Patterns**
2. Clique em **Create index pattern**
3. Digite: `logs-*`
4. Selecione `@timestamp` como campo de tempo
5. Clique em **Create index pattern**

### Visualizar Logs

1. Vá para **Discover**
2. Selecione o index pattern `logs-*`
3. Ajuste o período de tempo (ex: Last 15 minutes)
4. Use os filtros para buscar logs específicos

### Queries Úteis

```
# Logs de uma aplicação específica
app_name: "python-app"

# Logs de erro ou crítico
level: ("ERROR" OR "CRITICAL")

# Logs de um ambiente
environment: "production"

# Logs de múltiplas apps
app_name: ("python-app" OR "go-app")

# Logs contendo texto específico
message: *database*
```

### Dashboard Pré-configurado

Importe o dashboard:
1. Vá para **Stack Management** > **Saved Objects**
2. Clique em **Import**
3. Selecione `kibana-dashboards/logs-dashboard.ndjson`
4. Clique em **Import**

## 📝 Formato dos Logs

Todos os logs seguem este formato JSON:

```json
{
  "timestamp": "2024-01-15T10:30:45.123456Z",
  "level": "INFO",
  "message": "Processing request",
  "logger": "app-logger",
  "app_name": "python-app",
  "environment": "development",
  "hostname": "python-app-container",
  "path": "/app/main.py",
  "line": 42,
  "function": "process_request"
}
```

### Campos

- **timestamp**: ISO 8601 UTC timestamp
- **level**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **message**: Mensagem do log
- **logger**: Nome do logger
- **app_name**: Nome da aplicação
- **environment**: Ambiente (dev/staging/production)
- **hostname**: Nome do host/container
- **path**: Caminho do arquivo fonte
- **line**: Número da linha
- **function**: Nome da função

## 🔍 Troubleshooting

### ELK Stack não inicia

**Problema**: Serviços do ELK não sobem

**Soluções**:
```bash
# Verificar logs
make logs-elk

# Aumentar memória virtual (Linux)
sudo sysctl -w vm.max_map_count=262144

# Verificar portas
netstat -tuln | grep -E '9200|9300|5000|5601'

# Limpar e reiniciar
make clean
make elk-up
```

### Aplicações não conectam ao Logstash

**Problema**: Aplicações não enviam logs

**Soluções**:
```bash
# Verificar se Logstash está rodando
docker ps | grep logstash

# Verificar logs do Logstash
docker logs logstash

# Verificar rede
docker network inspect elk-network

# Testar conexão manualmente
telnet localhost 5000
```

### Logs não aparecem no Kibana

**Problema**: Logs não estão visíveis

**Soluções**:
```bash
# Verificar índices do Elasticsearch
curl http://localhost:9200/_cat/indices?v

# Verificar saúde do cluster
curl http://localhost:9200/_cluster/health?pretty

# Verificar logs nas aplicações
make logs-python

# Verificar se logs chegam ao Logstash
docker logs logstash | grep -i error
```

### Elasticsearch usa muita memória

**Problema**: Alto uso de memória

**Solução**: Edite `.env`:
```bash
ES_JAVA_OPTS=-Xms512m -Xmx512m
```

Reinicie:
```bash
make elk-restart
```

### Erro "max virtual memory"

**Problema**: Elasticsearch não inicia com erro de memória virtual

**Solução (Linux)**:
```bash
sudo sysctl -w vm.max_map_count=262144

# Permanente
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

**Solução (macOS Docker Desktop)**:
```bash
# Docker Desktop já tem configuração adequada
# Se necessário, aumente memória em Docker Desktop settings
```

**Solução (Windows WSL2)**:
```powershell
wsl -d docker-desktop
sysctl -w vm.max_map_count=262144
```

## 🧪 Testando o Sistema

### Teste Completo

```bash
# 1. Iniciar ELK Stack
make elk-up
sleep 60  # Aguardar inicialização

# 2. Verificar saúde
make check-elk

# 3. Iniciar aplicações
make apps-up

# 4. Verificar aplicações
make check-apps

# 5. Ver logs sendo gerados
make logs-python

# 6. Verificar índices
curl http://localhost:9200/_cat/indices?v

# 7. Abrir Kibana
open http://localhost:5601
```

### Teste Manual de Logging

Envie um log manual para Logstash:

```bash
echo '{"timestamp":"2024-01-15T10:00:00Z","level":"INFO","message":"Test log","app_name":"test"}' | nc localhost 5000
```

## 🔐 Segurança

⚠️ **IMPORTANTE**: Esta configuração é para desenvolvimento/teste.

Para produção:
1. Habilite autenticação no Elasticsearch
2. Use HTTPS/TLS
3. Configure senhas fortes
4. Restrinja acesso à rede
5. Use secrets management
6. Habilite audit logs

## 🚀 Próximos Passos

- [ ] Adicionar autenticação
- [ ] Configurar TLS/SSL
- [ ] Adicionar mais filtros no Logstash
- [ ] Criar mais dashboards
- [ ] Adicionar alertas
- [ ] Integrar com Grafana
- [ ] Adicionar métricas (Metricbeat)
- [ ] Configurar backups

## 📚 Recursos Adicionais

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Logstash Documentation](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é fornecido como está para fins educacionais e de demonstração.

## 👤 Autor

João Marques - [@joaomb98](https://github.com/joaomb98)

## 🙏 Agradecimentos

- Elastic Stack team
- Open source community
- Contributors

---

**⭐ Se este projeto foi útil, considere dar uma estrela!**
