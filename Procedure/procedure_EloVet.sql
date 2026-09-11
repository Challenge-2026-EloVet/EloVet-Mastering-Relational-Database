--================================================================================
-- PROCEDURE 1 - pr_agenda_json
--   Faz JOIN entre elo_agendamento, elo_pet, elo_veterinario e elo_clinica
--   (4 tabelas relacionais) e exibe cada linha como um objeto JSON (string),
--   montado manualmente atraves da FUNCTION 1 (fn_monta_json). 
--================================================================================
DROP PROCEDURE pr_agenda_json;

CREATE OR REPLACE PROCEDURE pr_agenda_json
IS
    CURSOR c_agenda IS
        SELECT a.id_agendamento,
               p.nome            AS nome_pet,
               p.especie,
               v.nome_completo   AS nome_veterinario,
               c.nome            AS nome_clinica,
               a.status,
               a.data_hora_agendamento
        FROM   elo_agendamento a
        JOIN   elo_pet         p ON p.id_pet = a.id_pet
        JOIN   elo_veterinario v ON v.id_veterinario = a.id_veterinario
        JOIN   elo_clinica     c ON c.id_clinica = a.id_clinica
        ORDER  BY a.id_agendamento;

v_campos elo_json_campos;

v_json_linha CLOB;

v_qtd_linhas PLS_INTEGER := 0;

v_indice PLS_INTEGER := 0;

e_sem_dados EXCEPTION;

BEGIN
    SELECT COUNT(*)
    INTO   v_qtd_linhas
    FROM   elo_agendamento a
    JOIN   elo_pet         p ON p.id_pet = a.id_pet
    JOIN   elo_veterinario v ON v.id_veterinario = a.id_veterinario
    JOIN   elo_clinica     c ON c.id_clinica = a.id_clinica;

    IF v_qtd_linhas = 0 THEN
        RAISE e_sem_dados;
    END IF;

    DBMS_OUTPUT.PUT_LINE('[');

    FOR r_agenda IN c_agenda LOOP
        v_indice := v_indice + 1;

        v_campos := elo_json_campos(
            elo_json_campo('id_agendamento', TO_CHAR(r_agenda.id_agendamento), 'NUMERO'),
            elo_json_campo('pet',            r_agenda.nome_pet,                'TEXTO'),
            elo_json_campo('especie',        r_agenda.especie,                 'TEXTO'),
            elo_json_campo('veterinario',    r_agenda.nome_veterinario,        'TEXTO'),
            elo_json_campo('clinica',        r_agenda.nome_clinica,            'TEXTO'),
            elo_json_campo('status',         r_agenda.status,                  'TEXTO'),
            elo_json_campo('data_hora',      TO_CHAR(r_agenda.data_hora_agendamento, 'DD/MM/YYYY HH24:MI'), 'TEXTO')
        );

        v_json_linha := fn_monta_json(v_campos);

        IF v_indice < v_qtd_linhas THEN
            DBMS_OUTPUT.PUT_LINE('  ' || v_json_linha || ',');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ' || v_json_linha);
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(']');

EXCEPTION
    WHEN e_sem_dados THEN
        DBMS_OUTPUT.PUT_LINE('[pr_agenda_json] Aviso: nao ha agendamentos cadastrados para exibir.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('[pr_agenda_json] Erro de conversao de dados ao montar o JSON: ' || SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[pr_agenda_json] Erro inesperado: ' || SQLERRM);
END pr_agenda_json;
/

--================================================================================
-- PROCEDURE 2 - pr_totaliza_idade_pet
--   Le elo_pet (colunas categoricas: especie, sexo | coluna numerica:
--   idade_aproximada) e imprime:
--     - o total de idade_aproximada por combinacao completa (especie, sexo)
--     - o subtotal por especie
--     - o total geral
--   Toda a soma e feita em variaveis PL/SQL, acumulando linha a linha em um
--   UNICO passo pelo cursor (tecnica de quebra de controle / control break).
--   Nao ha SUM(), GROUP BY, ROLLUP, CUBE, GROUPING SETS ou GROUPING - a
--   unica clausula SQL usada e o ORDER BY, apenas para garantir que as
--   combinacoes iguais fiquem agrupadas na leitura sequencial.
--================================================================================
DROP PROCEDURE pr_totaliza_idade_pet;

CREATE OR REPLACE PROCEDURE pr_totaliza_idade_pet
IS
    CURSOR c_pet IS
        SELECT especie, sexo, idade_aproximada
        FROM   elo_pet
        ORDER  BY especie ASC, sexo ASC;

v_especie_ant elo_pet.especie % TYPE;

v_sexo_ant elo_pet.sexo % TYPE;

v_soma_combo NUMBER := 0;

v_soma_especie NUMBER := 0;

v_soma_geral NUMBER := 0;

v_primeira BOOLEAN := TRUE;

v_qtd_linhas PLS_INTEGER := 0;

e_sem_dados EXCEPTION;

e_idade_invalida EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_qtd_linhas FROM elo_pet;
    IF v_qtd_linhas = 0 THEN
        RAISE e_sem_dados;
    END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD('Especie', 10) || RPAD('Sexo', 6) || 'IdadeTotal');
    DBMS_OUTPUT.PUT_LINE(RPAD('-------', 10) || RPAD('----', 6) || '----------');

    FOR r_pet IN c_pet LOOP

        IF r_pet.idade_aproximada IS NULL OR r_pet.idade_aproximada < 0 THEN
            RAISE e_idade_invalida;
        END IF;

        IF v_primeira THEN
            v_especie_ant := r_pet.especie;
            v_sexo_ant    := r_pet.sexo;
            v_primeira    := FALSE;
        END IF;

        IF r_pet.especie <> v_especie_ant OR r_pet.sexo <> v_sexo_ant THEN

            DBMS_OUTPUT.PUT_LINE(RPAD(v_especie_ant, 10) || RPAD(v_sexo_ant, 6) || TO_CHAR(v_soma_combo));
            v_soma_especie := v_soma_especie + v_soma_combo;
            v_soma_combo   := 0;

            IF r_pet.especie <> v_especie_ant THEN
                DBMS_OUTPUT.PUT_LINE(RPAD(' ', 10) || 'Sub Total ' || TO_CHAR(v_soma_especie));
                v_soma_geral   := v_soma_geral + v_soma_especie;
                v_soma_especie := 0;
            END IF;

            v_especie_ant := r_pet.especie;
            v_sexo_ant    := r_pet.sexo;
        END IF;

        v_soma_combo := v_soma_combo + r_pet.idade_aproximada;

    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD(v_especie_ant, 10) || RPAD(v_sexo_ant, 6) || TO_CHAR(v_soma_combo));
    v_soma_especie := v_soma_especie + v_soma_combo;
    DBMS_OUTPUT.PUT_LINE(RPAD(' ', 10) || 'Sub Total ' || TO_CHAR(v_soma_especie));
    v_soma_geral := v_soma_geral + v_soma_especie;

    DBMS_OUTPUT.PUT_LINE('Total Geral          ' || TO_CHAR(v_soma_geral));

EXCEPTION
    WHEN e_sem_dados THEN
        DBMS_OUTPUT.PUT_LINE('[pr_totaliza_idade_pet] Aviso: nao ha pets cadastrados para totalizar.');
    WHEN e_idade_invalida THEN
        DBMS_OUTPUT.PUT_LINE('[pr_totaliza_idade_pet] Erro: existe pet com idade_aproximada nula ou negativa. Corrija o cadastro antes de totalizar.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('[pr_totaliza_idade_pet] Erro de conversao numerica: ' || SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[pr_totaliza_idade_pet] Erro inesperado: ' || SQLERRM);
END pr_totaliza_idade_pet;
