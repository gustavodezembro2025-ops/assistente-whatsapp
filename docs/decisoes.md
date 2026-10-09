# Log de decisões

Formato: data — decisão — motivo.

- **2026-10-09** — Interface principal é o chat do Claude, conectado via MCP Server do n8n. — Permite conversar livremente com os dados; a inteligência roda na assinatura Pro, deixando a API paga como opcional.
- **2026-10-09** — n8n + Evolution ficam responsáveis por captura e alertas 24h. — O chat é reativo e não monitora sozinho.
- **2026-10-09** — Proatividade via tarefas agendadas do Claude (resumo do fim do dia, varreduras ao longo do dia). — Evita depender de API para o que não precisa ser em tempo real.
- **2026-10-09** — GitHub guarda a estrutura; mensagens ficam no banco. — Versionamento sem expor dados de clientes (LGPD).
- **2026-10-09** — Banco: Postgres na VPS existente, com pgvector quando necessário. — Gratuito, sem limite de plano, dados sob controle próprio.
- **2026-10-09** — Gestor de tarefas: Notion. — Banco de dados com campos (cliente, prazo, origem, prioridade), visões kanban/calendário/cliente e consultas por filtro.
- **2026-10-09** — Demanda de tráfego, campanha ou anúncio nos grupos de cliente é sempre do Gustavo, mesmo sem menção. — Regra da agência; classificação por assunto, não por @.
- **2026-10-09** — Demandas entram como `sugerida` e exigem confirmação; nenhuma mensagem é enviada a cliente sem aprovação. — Reduz falso positivo e risco na relação com cliente e de banimento do número.
- **2026-10-09** — Atualizações automáticas da base de conhecimento são propostas, não aplicadas. — Evita que um mal-entendido vire "verdade" sobre o cliente.
