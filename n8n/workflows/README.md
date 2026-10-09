# Workflows do n8n

JSON exportado de cada fluxo. Numerados pela ordem do pipeline:

| Arquivo | Função | Fase |
|---|---|---|
| `01-ingestao.json` | Webhook da Evolution → filtro → Postgres | 1 |
| `02-transcricao.json` | Transcreve áudios pendentes | 1 |
| `03-mcp.json` | MCP Server Trigger com as ferramentas de consulta | 1 |
| `04-alerta-urgente.json` | Aviso imediato por menção ou "urgente" | 2 |
| `05-backup-workflows.json` | Exporta os workflows e faz commit aqui | 1–2 |

Ao exportar, confira se não há chaves embutidas nos nós (use sempre credenciais do n8n).
