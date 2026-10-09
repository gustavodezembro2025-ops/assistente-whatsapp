# Contexto para o Claude

Este repositório é a estrutura do assistente de WhatsApp do Gustavo (gestor de tráfego pago em agência). Leia o `README.md` para a arquitetura e `docs/decisoes.md` para o que já foi decidido.

- Responda em português.
- Antes de propor mudanças, diga em que fase estamos (tabela de fases no README) e o que muda.
- Ao tomar uma decisão nova, registre em `docs/decisoes.md`.
- Ao concluir um item da fase, marque no checklist de `docs/fase-N.md` e atualize o status no README.
- Nunca coloque mensagens de clientes, transcrições, tokens ou chaves no repositório.
- Perfis de cliente em `clientes/` seguem `clientes/_modelo.md`; mudanças vindas de conversas são propostas para o Gustavo aprovar.
- Prompts ficam em `prompts/`; ao alterar um, explique o motivo no commit.
