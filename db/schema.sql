-- Assistente WhatsApp — schema inicial (fase 1 + estrutura da fase 2)
-- Rodar no banco "assistente":  psql -d assistente -f db/schema.sql

-- Grupos monitorados (espelho de config/grupos.yaml)
CREATE TABLE IF NOT EXISTS grupos (
    jid           TEXT PRIMARY KEY,                 -- ex: 1203630xxxxxxxx@g.us
    nome          TEXT NOT NULL,                    -- nome do grupo no WhatsApp
    cliente       TEXT,                             -- slug do cliente (null no grupo interno)
    tipo          TEXT NOT NULL CHECK (tipo IN ('cliente', 'interno')),
    ativo         BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Mensagens recebidas dos grupos da whitelist
CREATE TABLE IF NOT EXISTS mensagens (
    id                  TEXT PRIMARY KEY,           -- key.id da Evolution
    grupo_jid           TEXT NOT NULL REFERENCES grupos(jid),
    remetente_jid       TEXT,
    remetente_nome      TEXT,                       -- pushName
    de_mim              BOOLEAN NOT NULL DEFAULT FALSE,
    tipo                TEXT NOT NULL,              -- texto, audio, imagem, video, documento, figurinha, outro
    texto               TEXT,                       -- texto ou legenda
    transcricao         TEXT,                       -- para áudios
    transcricao_status  TEXT CHECK (transcricao_status IN ('pendente', 'ok', 'erro')),
    citada_id           TEXT,                       -- id da mensagem respondida
    mencoes             TEXT[] NOT NULL DEFAULT '{}',
    enviada_em          TIMESTAMPTZ NOT NULL,       -- messageTimestamp
    recebida_em         TIMESTAMPTZ NOT NULL DEFAULT now(),
    processada          BOOLEAN NOT NULL DEFAULT FALSE  -- já passou pela classificação de demandas
);

CREATE INDEX IF NOT EXISTS idx_mensagens_grupo_data ON mensagens (grupo_jid, enviada_em DESC);
CREATE INDEX IF NOT EXISTS idx_mensagens_data       ON mensagens (enviada_em DESC);
CREATE INDEX IF NOT EXISTS idx_mensagens_pendentes  ON mensagens (processada) WHERE processada = FALSE;
CREATE INDEX IF NOT EXISTS idx_mensagens_transcricao ON mensagens (transcricao_status) WHERE transcricao_status = 'pendente';

-- Texto pronto para leitura (texto ou transcrição)
CREATE OR REPLACE VIEW v_mensagens AS
SELECT
    m.id,
    m.grupo_jid,
    g.nome     AS grupo,
    g.cliente,
    g.tipo     AS tipo_grupo,
    m.remetente_nome,
    m.de_mim,
    m.tipo,
    COALESCE(m.texto, m.transcricao) AS conteudo,
    m.citada_id,
    m.mencoes,
    m.enviada_em
FROM mensagens m
JOIN grupos g ON g.jid = m.grupo_jid;

-- Demandas levantadas a partir das mensagens (fase 2)
CREATE TABLE IF NOT EXISTS demandas (
    id              BIGSERIAL PRIMARY KEY,
    grupo_jid       TEXT NOT NULL REFERENCES grupos(jid),
    cliente         TEXT,
    mensagem_ids    TEXT[] NOT NULL,                -- mensagens que originaram a demanda
    titulo          TEXT NOT NULL,
    descricao       TEXT,
    solicitante     TEXT,
    area            TEXT NOT NULL DEFAULT 'trafego' CHECK (area IN ('trafego', 'outra')),
    prioridade      TEXT NOT NULL DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
    prazo           DATE,
    status          TEXT NOT NULL DEFAULT 'sugerida'
                    CHECK (status IN ('sugerida', 'confirmada', 'descartada', 'concluida')),
    notion_page_id  TEXT,
    criada_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizada_em   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_demandas_status  ON demandas (status);
CREATE INDEX IF NOT EXISTS idx_demandas_cliente ON demandas (cliente);

-- Resumos gerados (para histórico e para não refazer)
CREATE TABLE IF NOT EXISTS resumos (
    id          BIGSERIAL PRIMARY KEY,
    data        DATE NOT NULL,
    grupo_jid   TEXT REFERENCES grupos(jid),        -- null = resumo geral do dia
    conteudo    TEXT NOT NULL,
    criado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Fase 3 (base vetorial) — descomentar quando chegar lá
-- CREATE EXTENSION IF NOT EXISTS vector;
-- CREATE TABLE IF NOT EXISTS conhecimento (
--     id         BIGSERIAL PRIMARY KEY,
--     cliente    TEXT NOT NULL,
--     origem     TEXT NOT NULL,                     -- mensagem, perfil, campanha...
--     conteudo   TEXT NOT NULL,
--     embedding  vector(1024),
--     criado_em  TIMESTAMPTZ NOT NULL DEFAULT now()
-- );
