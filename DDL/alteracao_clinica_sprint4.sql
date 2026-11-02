--================================================================================
-- ALTERACAO SPRINT 4 - DADOS DE CLINICA PARA O APP DO TUTOR
--   Script incremental para bancos que ja possuem o modelo criado (ddl.sql) e
--   os dados carregados. NAO apaga tabelas nem dados existentes.
--
--   - elo_endereco: latitude e longitude (coordenadas do endereco)
--   - elo_clinica: avaliacao (nota de 0 a 5)
--   - elo_acessibilidade + elo_clinica_acessibilidade: recursos de acessibilidade
--     de cada clinica (relacao N:N)
--   - Especialidades da clinica nao precisam de tabela nova: sao obtidas pelos
--     veterinarios que atendem nela (elo_clinica_veterinario x
--     elo_veterinario_especialidade).
--
--   Para um banco novo, use ddl.sql + carga_de_Dados.sql, que ja incluem tudo isto.
--================================================================================

-- 1. Novas colunas e restricoes
ALTER TABLE elo_endereco ADD (
    latitude  NUMBER (9,6),
    longitude NUMBER (9,6)
);

ALTER TABLE elo_endereco
    ADD CONSTRAINT ck_elo_endereco_coordenadas
    CHECK ((latitude IS NULL AND longitude IS NULL)
        OR (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180));

ALTER TABLE elo_clinica ADD (
    avaliacao NUMBER (2,1)
);

ALTER TABLE elo_clinica
    ADD CONSTRAINT ck_elo_clinica_avaliacao
    CHECK (avaliacao BETWEEN 0 AND 5);

-- 2. Novas tabelas de acessibilidade
CREATE TABLE elo_acessibilidade (
    id_acessibilidade NUMBER         NOT NULL,
    descricao         VARCHAR2 (100) NOT NULL,
    CONSTRAINT pk_elo_acessibilidade PRIMARY KEY (id_acessibilidade),
    CONSTRAINT uk_elo_acessibilidade_descricao UNIQUE (descricao)
);

CREATE TABLE elo_clinica_acessibilidade (
    id_clinica_acessibilidade NUMBER NOT NULL,
    id_clinica                NUMBER NOT NULL,
    id_acessibilidade         NUMBER NOT NULL,
    CONSTRAINT pk_elo_clinica_acessibilidade PRIMARY KEY (id_clinica_acessibilidade),
    CONSTRAINT uk_elo_clinica_acessibilidade UNIQUE (id_clinica, id_acessibilidade),
    CONSTRAINT fk_elo_clinica_acess_clinica FOREIGN KEY (id_clinica)
        REFERENCES elo_clinica (id_clinica),
    CONSTRAINT fk_elo_clinica_acess_acessibilidade FOREIGN KEY (id_acessibilidade)
        REFERENCES elo_acessibilidade (id_acessibilidade)
);

CREATE INDEX ix_elo_clinica_acess_clinica ON elo_clinica_acessibilidade (id_clinica);

CREATE SEQUENCE elo_acessibilidade_id_acessibilidade_SEQ START WITH 1 NOCACHE;

CREATE OR REPLACE TRIGGER elo_acessibilidade_id_acessibilidade_TRG
BEFORE INSERT ON elo_acessibilidade
FOR EACH ROW
WHEN (NEW.id_acessibilidade IS NULL)
BEGIN
    :NEW.id_acessibilidade := elo_acessibilidade_id_acessibilidade_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE elo_clinica_acessibilidade_id_clinica_acessibilidade_SEQ START WITH 1 NOCACHE;

CREATE OR REPLACE TRIGGER elo_clinica_acessibilidade_id_clinica_acessibilidade_TRG
BEFORE INSERT ON elo_clinica_acessibilidade
FOR EACH ROW
WHEN (NEW.id_clinica_acessibilidade IS NULL)
BEGIN
    :NEW.id_clinica_acessibilidade := elo_clinica_acessibilidade_id_clinica_acessibilidade_SEQ.NEXTVAL;
END;
/

-- 3. Dados das clinicas ja cadastradas (coordenadas aproximadas dos enderecos)
UPDATE elo_endereco SET latitude = -23.566870, longitude = -46.683930 WHERE id_endereco = 1;
UPDATE elo_endereco SET latitude = -23.601270, longitude = -46.664460 WHERE id_endereco = 2;
UPDATE elo_endereco SET latitude = -23.540560, longitude = -46.575960 WHERE id_endereco = 3;
UPDATE elo_endereco SET latitude = -23.593680, longitude = -46.678470 WHERE id_endereco = 4;
UPDATE elo_endereco SET latitude = -23.500620, longitude = -46.848240 WHERE id_endereco = 5;

UPDATE elo_clinica SET avaliacao = 4.8 WHERE cnpj = '12345678000190';
UPDATE elo_clinica SET avaliacao = 4.6 WHERE cnpj = '23456789000181';
UPDATE elo_clinica SET avaliacao = 4.3 WHERE cnpj = '34567890000172';
UPDATE elo_clinica SET avaliacao = 4.7 WHERE cnpj = '45678901000163';
UPDATE elo_clinica SET avaliacao = 4.5 WHERE cnpj = '56789012000154';

-- A clinica Alphaville (5) passa a ter veterinarios e, portanto, especialidades
INSERT INTO elo_clinica_veterinario (id_clinica, id_veterinario) VALUES (5, 2);
INSERT INTO elo_clinica_veterinario (id_clinica, id_veterinario) VALUES (5, 4);

INSERT INTO elo_acessibilidade (descricao) VALUES ('Rampa de acesso');
INSERT INTO elo_acessibilidade (descricao) VALUES ('Banheiro adaptado');
INSERT INTO elo_acessibilidade (descricao) VALUES ('Estacionamento para PcD');
INSERT INTO elo_acessibilidade (descricao) VALUES ('Elevador');
INSERT INTO elo_acessibilidade (descricao) VALUES ('Piso tatil');

INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (1, 1);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (1, 2);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (1, 4);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (2, 1);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (2, 3);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (3, 1);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (4, 1);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (4, 2);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (4, 5);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (5, 1);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (5, 3);
INSERT INTO elo_clinica_acessibilidade (id_clinica, id_acessibilidade) VALUES (5, 4);

COMMIT;
