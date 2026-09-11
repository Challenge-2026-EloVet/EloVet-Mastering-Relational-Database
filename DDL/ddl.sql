-- Gerado por Oracle SQL Developer Data Modeler 24.3.1.351.0831
--   em:        2026-09-10 11:03:11 BRT
--   site:      Oracle Database 21c
--   tipo:      Oracle Database 21c



DROP TABLE elo_agendamento CASCADE CONSTRAINTS 
;

DROP TABLE elo_auditoria CASCADE CONSTRAINTS 
;

DROP TABLE elo_clinica CASCADE CONSTRAINTS 
;

DROP TABLE elo_clinica_veterinario CASCADE CONSTRAINTS 
;

DROP TABLE elo_endereco CASCADE CONSTRAINTS 
;

DROP TABLE elo_especialidade CASCADE CONSTRAINTS 
;

DROP TABLE elo_login CASCADE CONSTRAINTS 
;

DROP TABLE elo_pet CASCADE CONSTRAINTS 
;

DROP TABLE elo_pet_responsavel CASCADE CONSTRAINTS 
;

DROP TABLE elo_responsavel CASCADE CONSTRAINTS 
;

DROP TABLE elo_veterinario CASCADE CONSTRAINTS 
;

DROP TABLE elo_veterinario_especialidade CASCADE CONSTRAINTS 
;

-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE elo_agendamento 
    ( 
     id_agendamento        NUMBER  NOT NULL , 
     id_pet                NUMBER  NOT NULL , 
     id_responsavel        NUMBER  NOT NULL , 
     id_veterinario        NUMBER  NOT NULL , 
     id_clinica            NUMBER  NOT NULL , 
     data_hora_agendamento TIMESTAMP  NOT NULL , 
     status                VARCHAR2 (30) DEFAULT 'AGENDADO'  NOT NULL , 
     observacao            VARCHAR2 (500) 
    ) 
;
CREATE INDEX ix_elo_agendamento_pet ON elo_agendamento 
    ( 
     id_pet ASC 
    ) 
;
CREATE INDEX ix_elo_agendamento_responsavel ON elo_agendamento 
    ( 
     id_responsavel ASC 
    ) 
;
CREATE INDEX ix_elo_agendamento_veterinario ON elo_agendamento 
    ( 
     id_veterinario ASC 
    ) 
;
CREATE INDEX ix_elo_agendamento_clinica ON elo_agendamento 
    ( 
     id_clinica ASC 
    ) 
;

ALTER TABLE elo_agendamento 
    ADD CONSTRAINT ck_elo_agendamento_status 
    CHECK (status IN ( 'AGENDADO', 'CONFIRMADO', 'EM_ATENDIMENTO', 'CONCLUIDO', 'CANCELADO', 'NAO_COMPARECEU' ))
;
ALTER TABLE elo_agendamento 
    ADD CONSTRAINT pk_elo_agendamento PRIMARY KEY ( id_agendamento ) ;

CREATE TABLE elo_auditoria 
    ( 
     id_auditoria        INTEGER  NOT NULL , 
     nome_usuario        VARCHAR2 (100)  NOT NULL , 
     tipo_operacao       VARCHAR2 (10)  NOT NULL , 
     data_hora_operacao  TIMESTAMP , 
     tabela_afetada      VARCHAR2 (30) , 
     id_registro_afetado INTEGER , 
     valores_anteriores  CLOB , 
     valores_novos       CLOB 
    ) 
;

ALTER TABLE elo_auditoria 
    ADD CONSTRAINT pk_elo_auditoria PRIMARY KEY ( id_auditoria ) ;

CREATE TABLE elo_clinica 
    ( 
     id_clinica  NUMBER  NOT NULL , 
     nome        VARCHAR2 (150)  NOT NULL , 
     cnpj        VARCHAR2 (14)  NOT NULL , 
     telefone    VARCHAR2 (20) , 
     email       VARCHAR2 (150) , 
     id_endereco NUMBER  NOT NULL 
    ) 
;

ALTER TABLE elo_clinica 
    ADD CONSTRAINT ck_elo_clinica_cnpj 
    CHECK (REGEXP_LIKE(cnpj, '^[0-9]{14}$'))
;
ALTER TABLE elo_clinica 
    ADD CONSTRAINT pk_elo_clinica PRIMARY KEY ( id_clinica ) ;

ALTER TABLE elo_clinica 
    ADD CONSTRAINT uk_elo_clinica_cnpj UNIQUE ( cnpj ) ;

CREATE TABLE elo_clinica_veterinario 
    ( 
     id_clinica_veterinario NUMBER  NOT NULL , 
     id_clinica             NUMBER  NOT NULL , 
     id_veterinario         NUMBER  NOT NULL 
    ) 
;
CREATE INDEX ix_elo_clinica_veterinario_clinica ON elo_clinica_veterinario 
    ( 
     id_clinica ASC 
    ) 
;
CREATE INDEX ix_elo_clinica_veterinario_vet ON elo_clinica_veterinario 
    ( 
     id_veterinario ASC 
    ) 
;

ALTER TABLE elo_clinica_veterinario 
    ADD CONSTRAINT pk_elo_clinica_veterinario PRIMARY KEY ( id_clinica_veterinario ) ;

ALTER TABLE elo_clinica_veterinario 
    ADD CONSTRAINT uk_elo_clinica_veterinario UNIQUE ( id_clinica , id_veterinario ) ;

CREATE TABLE elo_endereco 
    ( 
     id_endereco NUMBER  NOT NULL , 
     logradouro  VARCHAR2 (200)  NOT NULL , 
     numero      VARCHAR2 (20)  NOT NULL , 
     complemento VARCHAR2 (100) , 
     bairro      VARCHAR2 (100)  NOT NULL , 
     cidade      VARCHAR2 (100)  NOT NULL , 
     estado      VARCHAR2 (2)  NOT NULL , 
     cep         VARCHAR2 (8)  NOT NULL 
    ) 
;

ALTER TABLE elo_endereco 
    ADD CONSTRAINT ck_elo_endereco_estado 
    CHECK (LENGTH(estado) = 2)
;


ALTER TABLE elo_endereco 
    ADD CONSTRAINT ck_elo_endereco_cep 
    CHECK (REGEXP_LIKE(cep, '^[0-9]{8}$'))
;
ALTER TABLE elo_endereco 
    ADD CONSTRAINT pk_elo_endereco PRIMARY KEY ( id_endereco ) ;

CREATE TABLE elo_especialidade 
    ( 
     id_especialidade NUMBER  NOT NULL , 
     nome             VARCHAR2 (100)  NOT NULL , 
     descricao        VARCHAR2 (500) 
    ) 
;

ALTER TABLE elo_especialidade 
    ADD CONSTRAINT pk_elo_especialidade PRIMARY KEY ( id_especialidade ) ;

ALTER TABLE elo_especialidade 
    ADD CONSTRAINT uk_elo_especialidade_nome UNIQUE ( nome ) ;

CREATE TABLE elo_login 
    ( 
     id_usuario   NUMBER  NOT NULL , 
     nome_usuario VARCHAR2 (100)  NOT NULL , 
     email        VARCHAR2 (150)  NOT NULL , 
     senha_hash   VARCHAR2 (256)  NOT NULL , 
     tipo_usuario VARCHAR2 (20)  NOT NULL 
    ) 
;

ALTER TABLE elo_login 
    ADD CONSTRAINT ck_elo_login_tipo_usuario 
    CHECK (tipo_usuario IN ( 'ADMIN', 'USER', 'VETERINARIO', 'RESPONSAVEL' ))
;
ALTER TABLE elo_login 
    ADD CONSTRAINT pk_elo_login PRIMARY KEY ( id_usuario ) ;

ALTER TABLE elo_login 
    ADD CONSTRAINT uk_elo_login_nome_usuario UNIQUE ( nome_usuario ) ;

ALTER TABLE elo_login 
    ADD CONSTRAINT uk_elo_login_email UNIQUE ( email ) ;

CREATE TABLE elo_pet 
    ( 
     id_pet           NUMBER  NOT NULL , 
     nome             VARCHAR2 (150)  NOT NULL , 
     especie          VARCHAR2 (50)  NOT NULL , 
     raca             VARCHAR2 (100) , 
     sexo             CHAR (1) , 
     data_nascimento  DATE , 
     idade_aproximada NUMBER (3) , 
     flag_castrado    NUMBER (1) , 
     foto             BLOB 
    ) 
;

ALTER TABLE elo_pet 
    ADD CONSTRAINT ck_elo_pet_sexo 
    CHECK (sexo IN ('M', 'F', 'N'))
;


ALTER TABLE elo_pet 
    ADD CONSTRAINT ck_elo_pet_castrado 
    CHECK (flag_castrado IN (0, 1))
;


ALTER TABLE elo_pet 
    ADD CONSTRAINT ck_elo_pet_idade 
    CHECK (idade_aproximada >= 0)
;


ALTER TABLE elo_pet 
    ADD CONSTRAINT ck_elo_pet_data_idade 
    CHECK (data_nascimento IS NOT NULL OR idade_aproximada IS NOT NULL)
;
ALTER TABLE elo_pet 
    ADD CONSTRAINT pk_elo_pet PRIMARY KEY ( id_pet ) ;

CREATE TABLE elo_pet_responsavel 
    ( 
     id_pet_responsavel NUMBER  NOT NULL , 
     id_pet             NUMBER  NOT NULL , 
     id_responsavel     NUMBER  NOT NULL , 
     data_elo           DATE DEFAULT SYSDATE  NOT NULL 
    ) 
;
CREATE INDEX ix_elo_pet_responsavel_pet ON elo_pet_responsavel 
    ( 
     id_pet ASC 
    ) 
;
CREATE INDEX ix_elo_pet_responsavel_responsavel ON elo_pet_responsavel 
    ( 
     id_responsavel ASC 
    ) 
;

ALTER TABLE elo_pet_responsavel 
    ADD CONSTRAINT pk_elo_pet_responsavel PRIMARY KEY ( id_pet_responsavel ) ;

ALTER TABLE elo_pet_responsavel 
    ADD CONSTRAINT uk_elo_pet_responsavel UNIQUE ( id_pet , id_responsavel ) ;

CREATE TABLE elo_responsavel 
    ( 
     id_responsavel  NUMBER  NOT NULL , 
     id_usuario      NUMBER  NOT NULL , 
     nome_completo   VARCHAR2 (150)  NOT NULL , 
     cpf             VARCHAR2 (11)  NOT NULL , 
     rg              VARCHAR2 (20) , 
     data_nascimento DATE , 
     telefone        VARCHAR2 (20) , 
     id_endereco     NUMBER  NOT NULL 
    ) 
;

ALTER TABLE elo_responsavel 
    ADD CONSTRAINT ck_elo_responsavel_cpf 
    CHECK (REGEXP_LIKE(cpf, '^[0-9]{11}$'))
;
ALTER TABLE elo_responsavel 
    ADD CONSTRAINT pk_elo_responsavel PRIMARY KEY ( id_responsavel ) ;

ALTER TABLE elo_responsavel 
    ADD CONSTRAINT uk_elo_responsavel_cpf UNIQUE ( cpf ) ;

ALTER TABLE elo_responsavel 
    ADD CONSTRAINT uk_elo_responsavel_usuario UNIQUE ( id_usuario ) ;

CREATE TABLE elo_veterinario 
    ( 
     id_veterinario  NUMBER  NOT NULL , 
     id_usuario      NUMBER  NOT NULL , 
     nome_completo   VARCHAR2 (150)  NOT NULL , 
     cpf             VARCHAR2 (11)  NOT NULL , 
     rg              VARCHAR2 (20) , 
     data_nascimento DATE , 
     crmv            VARCHAR2 (30)  NOT NULL , 
     telefone        VARCHAR2 (20) , 
     id_endereco     NUMBER  NOT NULL 
    ) 
;

ALTER TABLE elo_veterinario 
    ADD CONSTRAINT ck_elo_veterinario_cpf 
    CHECK (REGEXP_LIKE(cpf, '^[0-9]{11}$'))
;
ALTER TABLE elo_veterinario 
    ADD CONSTRAINT pk_elo_veterinario PRIMARY KEY ( id_veterinario ) ;

ALTER TABLE elo_veterinario 
    ADD CONSTRAINT uk_elo_veterinario_cpf UNIQUE ( cpf ) ;

ALTER TABLE elo_veterinario 
    ADD CONSTRAINT uk_elo_veterinario_crmv UNIQUE ( crmv ) ;

ALTER TABLE elo_veterinario 
    ADD CONSTRAINT uk_elo_veterinario_usuario UNIQUE ( id_usuario ) ;

CREATE TABLE elo_veterinario_especialidade 
    ( 
     id_veterinario_especialidade NUMBER  NOT NULL , 
     id_veterinario               NUMBER  NOT NULL , 
     id_especialidade             NUMBER  NOT NULL 
    ) 
;
CREATE INDEX ix_elo_veterinario_especialidade_vet ON elo_veterinario_especialidade 
    ( 
     id_veterinario ASC 
    ) 
;
CREATE INDEX ix_elo_veterinario_especialidade_esp ON elo_veterinario_especialidade 
    ( 
     id_especialidade ASC 
    ) 
;

ALTER TABLE elo_veterinario_especialidade 
    ADD CONSTRAINT pk_elo_vet_especialidade PRIMARY KEY ( id_veterinario_especialidade ) ;

ALTER TABLE elo_veterinario_especialidade 
    ADD CONSTRAINT uk_ev_es_veterinario_especialidade UNIQUE ( id_veterinario , id_especialidade ) ;

ALTER TABLE elo_clinica_veterinario 
    ADD CONSTRAINT fk_ecv_clinica FOREIGN KEY 
    ( 
     id_clinica
    ) 
    REFERENCES elo_clinica 
    ( 
     id_clinica
    ) 
;

ALTER TABLE elo_clinica_veterinario 
    ADD CONSTRAINT fk_ecv_veterinario FOREIGN KEY 
    ( 
     id_veterinario
    ) 
    REFERENCES elo_veterinario 
    ( 
     id_veterinario
    ) 
;

ALTER TABLE elo_agendamento 
    ADD CONSTRAINT fk_elo_agendamento_clinica FOREIGN KEY 
    ( 
     id_clinica
    ) 
    REFERENCES elo_clinica 
    ( 
     id_clinica
    ) 
;

ALTER TABLE elo_agendamento 
    ADD CONSTRAINT fk_elo_agendamento_pet FOREIGN KEY 
    ( 
     id_pet
    ) 
    REFERENCES elo_pet 
    ( 
     id_pet
    ) 
;

ALTER TABLE elo_agendamento 
    ADD CONSTRAINT fk_elo_agendamento_responsavel FOREIGN KEY 
    ( 
     id_responsavel
    ) 
    REFERENCES elo_responsavel 
    ( 
     id_responsavel
    ) 
;

ALTER TABLE elo_agendamento 
    ADD CONSTRAINT fk_elo_agendamento_veterinario FOREIGN KEY 
    ( 
     id_veterinario
    ) 
    REFERENCES elo_veterinario 
    ( 
     id_veterinario
    ) 
;

ALTER TABLE elo_clinica 
    ADD CONSTRAINT fk_elo_clinica_endereco FOREIGN KEY 
    ( 
     id_endereco
    ) 
    REFERENCES elo_endereco 
    ( 
     id_endereco
    ) 
;

ALTER TABLE elo_pet_responsavel 
    ADD CONSTRAINT fk_elo_pet_responsavel_pet FOREIGN KEY 
    ( 
     id_pet
    ) 
    REFERENCES elo_pet 
    ( 
     id_pet
    ) 
;

ALTER TABLE elo_pet_responsavel 
    ADD CONSTRAINT fk_elo_pet_responsavel_responsavel FOREIGN KEY 
    ( 
     id_responsavel
    ) 
    REFERENCES elo_responsavel 
    ( 
     id_responsavel
    ) 
;

ALTER TABLE elo_responsavel 
    ADD CONSTRAINT fk_elo_responsavel_endereco FOREIGN KEY 
    ( 
     id_endereco
    ) 
    REFERENCES elo_endereco 
    ( 
     id_endereco
    ) 
;

ALTER TABLE elo_responsavel 
    ADD CONSTRAINT fk_elo_responsavel_usuario FOREIGN KEY 
    ( 
     id_usuario
    ) 
    REFERENCES elo_login 
    ( 
     id_usuario
    ) 
;

ALTER TABLE elo_veterinario 
    ADD CONSTRAINT fk_elo_veterinario_endereco FOREIGN KEY 
    ( 
     id_endereco
    ) 
    REFERENCES elo_endereco 
    ( 
     id_endereco
    ) 
;

ALTER TABLE elo_veterinario 
    ADD CONSTRAINT fk_elo_veterinario_usuario FOREIGN KEY 
    ( 
     id_usuario
    ) 
    REFERENCES elo_login 
    ( 
     id_usuario
    ) 
;

ALTER TABLE elo_veterinario_especialidade 
    ADD CONSTRAINT fk_ev_es_especialidade FOREIGN KEY 
    ( 
     id_especialidade
    ) 
    REFERENCES elo_especialidade 
    ( 
     id_especialidade
    ) 
;

ALTER TABLE elo_veterinario_especialidade 
    ADD CONSTRAINT fk_ev_es_veterinario FOREIGN KEY 
    ( 
     id_veterinario
    ) 
    REFERENCES elo_veterinario 
    ( 
     id_veterinario
    ) 
;

CREATE SEQUENCE elo_agendamento_id_agendamento_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_agendamento_id_agendamento_TRG 
BEFORE INSERT ON elo_agendamento 
FOR EACH ROW 
WHEN (NEW.id_agendamento IS NULL) 
BEGIN 
    :NEW.id_agendamento := elo_agendamento_id_agendamento_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_auditoria_id_auditoria_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER elo_auditoria_id_auditoria_TRG 
BEFORE INSERT ON elo_auditoria 
FOR EACH ROW 
WHEN (NEW.id_auditoria IS NULL) 
BEGIN 
    :NEW.id_auditoria := elo_auditoria_id_auditoria_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_clinica_id_clinica_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_clinica_id_clinica_TRG 
BEFORE INSERT ON elo_clinica 
FOR EACH ROW 
WHEN (NEW.id_clinica IS NULL) 
BEGIN 
    :NEW.id_clinica := elo_clinica_id_clinica_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_clinica_veterinario_id_clinica_veterinario_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_clinica_veterinario_id_clinica_veterinario_TRG 
BEFORE INSERT ON elo_clinica_veterinario 
FOR EACH ROW 
WHEN (NEW.id_clinica_veterinario IS NULL) 
BEGIN 
    :NEW.id_clinica_veterinario := elo_clinica_veterinario_id_clinica_veterinario_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_endereco_id_endereco_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_endereco_id_endereco_TRG 
BEFORE INSERT ON elo_endereco 
FOR EACH ROW 
WHEN (NEW.id_endereco IS NULL) 
BEGIN 
    :NEW.id_endereco := elo_endereco_id_endereco_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_especialidade_id_especialidade_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_especialidade_id_especialidade_TRG 
BEFORE INSERT ON elo_especialidade 
FOR EACH ROW 
WHEN (NEW.id_especialidade IS NULL) 
BEGIN 
    :NEW.id_especialidade := elo_especialidade_id_especialidade_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_login_id_usuario_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_login_id_usuario_TRG 
BEFORE INSERT ON elo_login 
FOR EACH ROW 
WHEN (NEW.id_usuario IS NULL) 
BEGIN 
    :NEW.id_usuario := elo_login_id_usuario_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_pet_id_pet_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_pet_id_pet_TRG 
BEFORE INSERT ON elo_pet 
FOR EACH ROW 
WHEN (NEW.id_pet IS NULL) 
BEGIN 
    :NEW.id_pet := elo_pet_id_pet_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_pet_responsavel_id_pet_responsavel_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_pet_responsavel_id_pet_responsavel_TRG 
BEFORE INSERT ON elo_pet_responsavel 
FOR EACH ROW 
WHEN (NEW.id_pet_responsavel IS NULL) 
BEGIN 
    :NEW.id_pet_responsavel := elo_pet_responsavel_id_pet_responsavel_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_responsavel_id_responsavel_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_responsavel_id_responsavel_TRG 
BEFORE INSERT ON elo_responsavel 
FOR EACH ROW 
WHEN (NEW.id_responsavel IS NULL) 
BEGIN 
    :NEW.id_responsavel := elo_responsavel_id_responsavel_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_veterinario_id_veterinario_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_veterinario_id_veterinario_TRG 
BEFORE INSERT ON elo_veterinario 
FOR EACH ROW 
WHEN (NEW.id_veterinario IS NULL) 
BEGIN 
    :NEW.id_veterinario := elo_veterinario_id_veterinario_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE elo_veterinario_especialidade_id_veterinario_especialidade_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER elo_veterinario_especialidade_id_veterinario_especialidade_TRG 
BEFORE INSERT ON elo_veterinario_especialidade 
FOR EACH ROW 
WHEN (NEW.id_veterinario_especialidade IS NULL) 
BEGIN 
    :NEW.id_veterinario_especialidade := elo_veterinario_especialidade_id_veterinario_especialidade_SEQ.NEXTVAL; 
END;
/



-- Relatório do Resumo do Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            12
-- CREATE INDEX                            10
-- ALTER TABLE                             50
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                          12
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                         12
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
