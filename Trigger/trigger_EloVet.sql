--================================================================================
-- TRIGGER DE AUDITORIA - trg_auditoria_agendamento
--   AFTER INSERT OR UPDATE OR DELETE ON elo_agendamento, FOR EACH ROW.
--   Grava em elo_auditoria: usuario da sessao, tipo de operacao, data/hora,
--   tabela afetada, chave do registro afetado e os valores :OLD e :NEW
--   (cada um convertido para JSON manualmente atraves da Funcao 1).
--================================================================================
DROP TRIGGER trg_auditoria_agendamento;

CREATE OR REPLACE TRIGGER trg_auditoria_agendamento
AFTER INSERT OR UPDATE OR DELETE ON elo_agendamento
FOR EACH ROW
DECLARE
    v_tipo_operacao  VARCHAR2(10);
    v_id_registro    NUMBER;
    v_campos_antigos elo_json_campos;
    v_campos_novos   elo_json_campos;
    v_json_antigo    CLOB;
    v_json_novo      CLOB;
BEGIN
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_id_registro   := :NEW.id_agendamento;
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_id_registro   := :NEW.id_agendamento;
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_id_registro   := :OLD.id_agendamento;
    END IF;

    IF NOT DELETING THEN
        v_campos_novos := elo_json_campos(
            elo_json_campo('id_agendamento', TO_CHAR(:NEW.id_agendamento), 'NUMERO'),
            elo_json_campo('id_pet',         TO_CHAR(:NEW.id_pet), 'NUMERO'),
            elo_json_campo('id_veterinario', TO_CHAR(:NEW.id_veterinario), 'NUMERO'),
            elo_json_campo('id_clinica',     TO_CHAR(:NEW.id_clinica), 'NUMERO'),
            elo_json_campo('status',         :NEW.status, 'TEXTO'),
            elo_json_campo('data_hora',      TO_CHAR(:NEW.data_hora_agendamento, 'DD/MM/YYYY HH24:MI'), 'TEXTO')
        );
        v_json_novo := fn_monta_json(v_campos_novos);
    END IF;

    IF NOT INSERTING THEN
        v_campos_antigos := elo_json_campos(
            elo_json_campo('id_agendamento', TO_CHAR(:OLD.id_agendamento), 'NUMERO'),
            elo_json_campo('id_pet',         TO_CHAR(:OLD.id_pet), 'NUMERO'),
            elo_json_campo('id_veterinario', TO_CHAR(:OLD.id_veterinario), 'NUMERO'),
            elo_json_campo('id_clinica',     TO_CHAR(:OLD.id_clinica), 'NUMERO'),
            elo_json_campo('status',         :OLD.status, 'TEXTO'),
            elo_json_campo('data_hora',      TO_CHAR(:OLD.data_hora_agendamento, 'DD/MM/YYYY HH24:MI'), 'TEXTO')
        );
        v_json_antigo := fn_monta_json(v_campos_antigos);
    END IF;

    INSERT INTO elo_auditoria (
        nome_usuario, tipo_operacao, data_hora_operacao,
        tabela_afetada, id_registro_afetado,
        valores_anteriores, valores_novos
    ) VALUES (
        SYS_CONTEXT('USERENV', 'SESSION_USER'), v_tipo_operacao, SYSTIMESTAMP,
        'ELO_AGENDAMENTO', v_id_registro,
        v_json_antigo, v_json_novo
    );

EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20050, 'Erro de conversao de dados na trigger de auditoria de elo_agendamento: ' || SQLERRM);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20051, 'Erro inesperado na trigger de auditoria de elo_agendamento: ' || SQLERRM);
END trg_auditoria_agendamento;
