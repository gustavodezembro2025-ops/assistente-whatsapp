# Fase 1 — Captura e consulta

**Objetivo:** todas as mensagens dos grupos da whitelist chegam ao banco (com áudios transcritos), e pelo chat do Claude é possível pedir "me dá o resumo de hoje".

## Checklist

- [ ] 1. Criar o banco `assistente` no Postgres e rodar `db/schema.sql`
- [ ] 2. Levantar os IDs dos grupos e preencher `config/grupos.yaml`
- [ ] 3. Carregar os grupos no banco (tabela `grupos`)
- [ ] 4. Configurar o webhook da Evolution apontando para o n8n
- [ ] 5. Workflow `01-ingestao`: receber, filtrar, normalizar e salvar
- [ ] 6. Workflow `02-transcricao`: transcrever áudios pendentes
- [ ] 7. Workflow `03-mcp`: MCP Server Trigger com as ferramentas da fase 1
- [ ] 8. Conectar o MCP no Claude como conector personalizado
- [ ] 9. Teste: "resumo de hoje" e "o que rolou no grupo X ontem?"
- [ ] 10. Exportar os workflows para `n8n/workflows/` e fazer commit

## 1. Banco

```bash
# dentro da VPS (ajuste usuário/host conforme seu Postgres)
psql -U postgres -c "CREATE DATABASE assistente;"
psql -U postgres -d assistente -f db/schema.sql
```

Se a Evolution já usa um Postgres, use a mesma instância com este banco separado. Crie um usuário próprio para o n8n com acesso só ao banco `assistente`.

## 2. IDs dos grupos

Pela API da Evolution:

```
GET {EVOLUTION_URL}/group/fetchAllGroups/{INSTANCIA}?getParticipants=false
Header: apikey: {EVOLUTION_API_KEY}
```

A resposta lista cada grupo com `id` (termina em `@g.us`) e `subject` (nome). Copie os grupos dos clientes e o grupo interno para `config/grupos.yaml`.

## 4. Webhook da Evolution

Na instância, configure:

- **URL:** a URL de produção do webhook do workflow `01-ingestao`
- **Eventos:** `MESSAGES_UPSERT`
- **Webhook by events:** desligado
- **Base64:** ligado (para o áudio chegar junto e poder ser transcrito)

## 5. Workflow `01-ingestao`

1. **Webhook** recebe o evento.
2. **Filtro:** `remoteJid` termina em `@g.us` **e** existe na tabela `grupos` com `ativo = true`. Se não, encerra sem salvar nada.
3. **Normalização:** extrai `id` da mensagem, grupo, remetente, nome (`pushName`), se é minha (`fromMe`), tipo (texto, áudio, imagem, documento...), texto ou legenda, mensagem citada e menções.
4. **Insert** em `mensagens` com `ON CONFLICT (id) DO NOTHING` (a Evolution pode reenviar eventos).
5. Se for áudio, salva com `transcricao_status = 'pendente'`.

## 6. Workflow `02-transcricao`

Roda a cada poucos minutos, pega áudios pendentes, transcreve e atualiza `transcricao`.

Opções de transcrição (decisão pendente):
- **Groq (Whisper large v3):** tem camada gratuita com limites; rápido.
- **OpenAI Whisper API:** pago, custo baixo por minuto.
- **Whisper local na VPS:** gratuito, mas pesa na CPU/RAM.

## 7. Workflow `03-mcp`

Nó **MCP Server Trigger** com autenticação por Bearer token. Ferramentas da fase 1 (cada uma um nó de consulta ao Postgres):

| Ferramenta | Parâmetros | Retorna |
|---|---|---|
| `listar_grupos` | — | grupos ativos com cliente e tipo |
| `buscar_mensagens` | `cliente` (opcional), `desde`, `ate` | mensagens do período, com remetente, horário e texto/transcrição |

Com essas duas o Claude já faz resumos por dia, por cliente ou do grupo interno.

## 8. Conectar no Claude

Adicione a URL de produção do MCP Server Trigger como conector personalizado no Claude, informando o token. Depois, no Projeto, teste: "liste meus grupos" e "me dá o resumo de hoje".

## Pronto quando

- Uma mensagem enviada num grupo da whitelist aparece no banco em segundos.
- Um áudio aparece transcrito em poucos minutos.
- Mensagens de conversas fora da whitelist não aparecem no banco.
- O Claude responde "resumo de hoje" usando dados reais.
