--================================================================================
-- TRIGGER DE AUDITORIA - trg_auditoria_agendamento
--   AFTER INSERT OR UPDATE OR DELETE ON elo_agendamento, FOR EACH ROW.
--   Identifica a operação e repassa os valores :OLD e :NEW para
--   pkg_elovet.pr_audita_agendamento, que contém a lógica de auditoria e o
--   tratamento de exceções.
--================================================================================

CREATE OR REPLACE TRIGGER trg_auditoria_agendamento
AFTER INSERT OR UPDATE OR DELETE ON elo_agendamento
FOR EACH ROW
DECLARE
    v_tipo_operacao VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
    END IF;

    pkg_elovet.pr_audita_agendamento(
        p_tipo_operacao       => v_tipo_operacao,
        p_id_agendamento_ant  => :OLD.id_agendamento,
        p_id_pet_ant          => :OLD.id_pet,
        p_id_veterinario_ant  => :OLD.id_veterinario,
        p_id_clinica_ant      => :OLD.id_clinica,
        p_status_ant          => :OLD.status,
        p_data_hora_ant       => :OLD.data_hora_agendamento,
        p_id_agendamento_novo => :NEW.id_agendamento,
        p_id_pet_novo         => :NEW.id_pet,
        p_id_veterinario_novo => :NEW.id_veterinario,
        p_id_clinica_novo     => :NEW.id_clinica,
        p_status_novo         => :NEW.status,
        p_data_hora_novo      => :NEW.data_hora_agendamento
    );
END trg_auditoria_agendamento;
/
