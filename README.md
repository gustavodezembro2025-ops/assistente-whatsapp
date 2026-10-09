# Assistente WhatsApp

Central que monitora os grupos de WhatsApp dos clientes e do squad, levanta as demandas de tráfego pago direcionadas ao Gustavo, gera resumos e alimenta uma base de conhecimento por cliente. A interface principal é o chat do Claude, conectado aos dados via MCP.

> Este repositório guarda a **estrutura** do sistema (config, prompts, conhecimento, workflows, schema). As **mensagens** ficam no banco, nunca aqui.

## Arquitetura

```
WhatsApp (número do Gustavo)
        │
   Evolution API ──webhook──► n8n ──► Postgres (VPS)
                               │          ▲
                               │          │ consultas
                               ▼          │
                     alerta urgente   MCP Server (n8n)
                     (WhatsApp)           │
                                          ▼
                                 Claude (chat / Projeto)
                                   │            │
                                Notion      tarefas agendadas
                          (demandas + agenda)  (resumo, varredura)
```

| Camada | Ferramenta | Papel |
|---|---|---|
| Captura | Evolution API | Recebe todas as mensagens do número |
| Motor | n8n (VPS, HTTPS) | Filtra grupos, transcreve áudio, salva, alerta, expõe MCP |
| Memória | Postgres na VPS (+ pgvector depois) | Mensagens, demandas, resumos |
| Estrutura | Este repositório | Config, prompts, perfis de cliente, workflows, schema |
| Interface | Claude (plano Pro) via conector MCP | Resumos, pendências, criação de tarefas, rascunhos |
| Tarefas e agenda | Notion | Banco de demandas com visões kanban, calendário e por cliente |

## Regras do sistema

- **Whitelist de grupos:** só os grupos em `config/grupos.yaml` com `ativo: true` são processados. Tudo o resto é descartado na entrada, sem salvar.
- **Quem é dono da demanda:** nos grupos de cliente, toda solicitação sobre **tráfego, campanha ou anúncio** é do Gustavo, mesmo sem menção. Pedidos de outras áreas (design, social, site) aparecem no resumo como "outras áreas", sem virar tarefa.
- **Grupo interno (squad):** demandas que citam o Gustavo ou envolvem tráfego dos clientes também entram.
- **Aprovação humana:** demandas começam como `sugerida` e só viram tarefa no Notion depois de confirmadas. Nada é enviado aos clientes sem aprovação.
- **Alerta imediato:** menção direta ao Gustavo ou palavras como "urgente" geram um aviso no WhatsApp na hora (regra simples no n8n, sem IA).
- **Base de conhecimento:** atualizações em `clientes/*.md` vindas das conversas são sempre propostas (rascunho ou PR), nunca aplicadas sozinhas.

## Fases

| Fase | Entrega | Status |
|---|---|---|
| 1 | Evolution → n8n → Postgres, transcrição de áudio, MCP com `listar_grupos` e `buscar_mensagens`, "resumo de hoje" pelo chat | Em andamento |
| 2 | Classificação de demandas, banco no Notion, confirmação, agenda, alerta urgente | Pendente |
| 3 | Perfis por cliente (`clientes/`), base vetorial com pgvector | Pendente |
| 4 | Integração com Meta Ads e Google Ads | Pendente |
| 5 | Rascunhos no tom do Gustavo, aprovados antes do envio | Pendente |

Detalhes da fase atual: [`docs/fase-1.md`](docs/fase-1.md). Decisões tomadas: [`docs/decisoes.md`](docs/decisoes.md).

## Estrutura do repositório

```
├── README.md
├── CLAUDE.md                 # contexto para o Claude ao trabalhar neste repo
├── .env.example              # variáveis necessárias (sem valores reais)
├── docs/
│   ├── decisoes.md           # log de decisões
│   └── fase-1.md             # passo a passo da fase atual
├── config/
│   └── grupos.yaml           # ID do grupo → cliente, tipo, ativo
├── prompts/
│   ├── classificar-demanda.md
│   ├── resumo-diario.md
│   └── tom-de-voz.md
├── clientes/
│   └── _modelo.md            # modelo de perfil de cliente
├── db/
│   └── schema.sql
└── n8n/
    └── workflows/            # JSON exportado de cada fluxo
```

## Segurança e LGPD

- Repositório **privado**. Nenhuma mensagem, transcrição ou chave entra aqui.
- Credenciais ficam nas credenciais do n8n ou em `.env` (no `.gitignore`).
- O endpoint MCP exige autenticação (token no header).
- Política de retenção das mensagens no banco: a definir (sugestão: 12 meses).
