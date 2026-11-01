--================================================================================
-- PACKAGE - pkg_elovet
--   Reúne as functions, as procedures e a lógica da trigger de auditoria do
--   EloVet. A trigger em si continua fora da package (Trigger/trigger_EloVet.sql)
--   porque o Oracle exige que ela seja um objeto de schema ligado à tabela; o
--   corpo dela apenas chama pr_audita_agendamento.
--
--   Os tipos elo_json_campo / elo_json_campos continuam em Type/type_EloVet.sql.
--================================================================================
 
CREATE OR REPLACE PACKAGE pkg_elovet
IS
    FUNCTION fn_monta_json (p_campos IN elo_json_campos) RETURN CLOB;
 
    FUNCTION fn_valida_cpf (p_cpf IN VARCHAR2) RETURN VARCHAR2;
 
    FUNCTION fn_exporta_valores_novos RETURN CLOB;
 
    PROCEDURE pr_agenda_json;
 
    PROCEDURE pr_totaliza_idade_pet;
 
    PROCEDURE pr_audita_agendamento (
        p_tipo_operacao      IN VARCHAR2,
        p_id_agendamento_ant IN elo_agendamento.id_agendamento%TYPE,
        p_id_pet_ant         IN elo_agendamento.id_pet%TYPE,
        p_id_veterinario_ant IN elo_agendamento.id_veterinario%TYPE,
        p_id_clinica_ant     IN elo_agendamento.id_clinica%TYPE,
        p_status_ant         IN elo_agendamento.status%TYPE,
        p_data_hora_ant      IN elo_agendamento.data_hora_agendamento%TYPE,
        p_id_agendamento_novo IN elo_agendamento.id_agendamento%TYPE,
        p_id_pet_novo         IN elo_agendamento.id_pet%TYPE,
        p_id_veterinario_novo IN elo_agendamento.id_veterinario%TYPE,
        p_id_clinica_novo     IN elo_agendamento.id_clinica%TYPE,
        p_status_novo         IN elo_agendamento.status%TYPE,
        p_data_hora_novo      IN elo_agendamento.data_hora_agendamento%TYPE
    );
END pkg_elovet;
/
 
CREATE OR REPLACE PACKAGE BODY pkg_elovet
IS
 
    --============================================================================
    -- FUNCTION 1 - fn_monta_json
    --   Recebe uma coleção de pares campo/valor (tipo elo_json_campos) e devolve
    --   manualmente a string JSON equivalente, SEM usar nenhuma função Oracle
    --   pronta de JSON (não usa TO_JSON, JSON_OBJECT, JSON_VALUE, JSON_QUERY,
    --   JSON_TABLE ou similares). A montagem é feita por concatenação de string
    --   (operador ||) dentro de um loop, incluindo escape manual de aspas e
    --   barra invertida.
    --============================================================================
    FUNCTION fn_monta_json (p_campos IN elo_json_campos) RETURN CLOB
    IS
        v_json           CLOB;
 
        v_valor_escapado VARCHAR2 (4000);
 
        e_lista_vazia EXCEPTION;
 
        e_campo_sem_nome EXCEPTION;
 
    BEGIN
        IF p_campos IS NULL OR p_campos.COUNT = 0 THEN
            RAISE e_lista_vazia;
        END IF;
 
        v_json := '{';
 
        FOR i IN 1 .. p_campos.COUNT LOOP
 
            IF p_campos(i).nome_campo IS NULL THEN
                RAISE e_campo_sem_nome;
            END IF;
 
            v_valor_escapado := p_campos(i).valor_campo;
            IF v_valor_escapado IS NOT NULL THEN
                v_valor_escapado := REPLACE(v_valor_escapado, '\', '\\');
                v_valor_escapado := REPLACE(v_valor_escapado, '"', '\"');
            END IF;
 
            v_json := v_json || '"' || p_campos(i).nome_campo || '":';
 
            IF p_campos(i).tipo_campo = 'JSON' THEN
                -- Valor que ja e um JSON montado (objeto aninhado): entra sem aspas e sem escape
                IF p_campos(i).valor_campo IS NULL THEN
                    v_json := v_json || 'null';
                ELSE
                    v_json := v_json || p_campos(i).valor_campo;
                END IF;
            ELSIF p_campos(i).tipo_campo = 'NUMERO' THEN
                IF v_valor_escapado IS NULL THEN
                    v_json := v_json || 'null';
                ELSE
 
                    IF NOT REGEXP_LIKE(v_valor_escapado, '^-?[0-9]+(\.[0-9]+)?$') THEN
                        RAISE VALUE_ERROR;
                    END IF;
                    v_json := v_json || v_valor_escapado;
                END IF;
            ELSIF p_campos(i).tipo_campo = 'NULO' OR v_valor_escapado IS NULL THEN
                v_json := v_json || 'null';
            ELSE
                v_json := v_json || '"' || v_valor_escapado || '"';
            END IF;
 
            IF i < p_campos.COUNT THEN
                v_json := v_json || ',';
            END IF;
 
        END LOOP;
 
        v_json := v_json || '}';
 
        RETURN v_json;
 
    EXCEPTION
        WHEN e_lista_vazia THEN
            DBMS_OUTPUT.PUT_LINE('[fn_monta_json] Aviso: lista de campos vazia ou nula. Retornando JSON vazio.');
            RETURN '{}';
        WHEN e_campo_sem_nome THEN
            DBMS_OUTPUT.PUT_LINE('[fn_monta_json] Erro: existe campo sem nome (nome_campo nulo) na colecao recebida.');
            RETURN NULL;
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('[fn_monta_json] Erro de conversao: campo marcado como NUMERO contem valor nao numerico. ' || SQLERRM);
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[fn_monta_json] Erro inesperado: ' || SQLERRM);
            RETURN NULL;
    END fn_monta_json;
 
 
    --============================================================================
    -- FUNCTION 2 - fn_valida_cpf
    --   Substitui o processo de validação de CPF do cadastro de responsáveis e
    --   veterinários (elo_responsavel.cpf / elo_veterinario.cpf). A constraint
    --   de tabela só garante 11 dígitos numéricos; esta função calcula os dois
    --   dígitos verificadores (algoritmo oficial módulo 11) e confirma se o CPF
    --   informado é matematicamente válido.
    --============================================================================
    FUNCTION fn_valida_cpf (p_cpf IN VARCHAR2) RETURN VARCHAR2
    IS
        v_cpf            VARCHAR2(11);
        v_soma           PLS_INTEGER;
        v_resto          PLS_INTEGER;
        v_digito1        PLS_INTEGER;
        v_digito2        PLS_INTEGER;
        v_digitos_iguais BOOLEAN := TRUE;
 
        e_tamanho_invalido  EXCEPTION;
        e_digitos_repetidos EXCEPTION;
    BEGIN
        IF p_cpf IS NULL THEN
            RAISE VALUE_ERROR;
        END IF;
 
        v_cpf := TRIM(p_cpf);
 
        IF LENGTH(v_cpf) <> 11 OR NOT REGEXP_LIKE(v_cpf, '^[0-9]{11}$') THEN
            RAISE e_tamanho_invalido;
        END IF;
 
        v_digitos_iguais := TRUE;
        FOR i IN 2 .. 11 LOOP
            IF SUBSTR(v_cpf, i, 1) <> SUBSTR(v_cpf, 1, 1) THEN
                v_digitos_iguais := FALSE;
                EXIT;
            END IF;
        END LOOP;
 
        IF v_digitos_iguais THEN
            RAISE e_digitos_repetidos;
        END IF;
 
 
        v_soma := 0;
        FOR i IN 1 .. 9 LOOP
            v_soma := v_soma + TO_NUMBER(SUBSTR(v_cpf, i, 1)) * (11 - i);
        END LOOP;
        v_resto := MOD(v_soma, 11);
        v_digito1 := CASE WHEN v_resto < 2 THEN 0 ELSE 11 - v_resto END;
 
 
        v_soma := 0;
        FOR i IN 1 .. 10 LOOP
            v_soma := v_soma + TO_NUMBER(SUBSTR(v_cpf, i, 1)) * (12 - i);
        END LOOP;
        v_resto := MOD(v_soma, 11);
        v_digito2 := CASE WHEN v_resto < 2 THEN 0 ELSE 11 - v_resto END;
 
        IF TO_NUMBER(SUBSTR(v_cpf, 10, 1)) = v_digito1
           AND TO_NUMBER(SUBSTR(v_cpf, 11, 1)) = v_digito2 THEN
            RETURN 'VALIDO';
        ELSE
            RETURN 'INVALIDO';
        END IF;
 
    EXCEPTION
        WHEN e_tamanho_invalido THEN
            DBMS_OUTPUT.PUT_LINE('[fn_valida_cpf] Erro: CPF deve conter exatamente 11 digitos numericos.');
            RETURN 'INVALIDO';
        WHEN e_digitos_repetidos THEN
            DBMS_OUTPUT.PUT_LINE('[fn_valida_cpf] Erro: CPF com todos os digitos iguais nao e valido.');
            RETURN 'INVALIDO';
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('[fn_valida_cpf] Erro: valor de entrada nulo ou nao numerico.');
            RETURN 'INVALIDO';
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[fn_valida_cpf] Erro inesperado: ' || SQLERRM);
            RETURN 'INVALIDO';
    END fn_valida_cpf;
 
 
    --============================================================================
    -- FUNCTION 3 - fn_exporta_valores_novos
    --   Exporta como um array JSON os registros de elo_auditoria gravados no dia
    --   anterior (de 00:00:00 de ontem até antes de 00:00:00 de hoje) que tenham
    --   valores novos (registros de DELETE ficam de fora).
    --
    --   Cada objeto do array traz:
    --     - os metadados da auditoria (id, operação, data/hora, usuário);
    --     - valores_novos: o snapshot do agendamento gravado pela trigger;
    --     - pet, responsavel, veterinario e clinica: os dados descritivos de cada
    --       entidade relacionada, para que o documento seja autoexplicativo no
    --       MongoDB sem depender de JOIN.
    --
    --   Os ids de pet, veterinário e clínica são lidos do próprio snapshot (o
    --   JSON é tratado como texto, com REGEXP_SUBSTR), para descrever exatamente
    --   o pet/veterinário/clínica auditados. O responsável vem do agendamento.
    --   Dados pessoais sensíveis (CPF, RG e data de nascimento das pessoas) não
    --   são exportados.
    --
    --   Todo o JSON é montado por concatenação, via fn_monta_json, sem funções
    --   Oracle prontas de JSON.
    --============================================================================
    FUNCTION fn_exporta_valores_novos RETURN CLOB
    IS
        CURSOR c_auditoria IS
            SELECT au.id_auditoria,
                   au.tipo_operacao,
                   au.data_hora_operacao,
                   au.nome_usuario,
                   au.id_registro_afetado,
                   au.valores_novos_txt,
                   p.id_pet,
                   p.nome             AS pet_nome,
                   p.especie          AS pet_especie,
                   p.raca             AS pet_raca,
                   p.sexo             AS pet_sexo,
                   p.data_nascimento  AS pet_data_nascimento,
                   p.idade_aproximada AS pet_idade_aproximada,
                   p.flag_castrado    AS pet_flag_castrado,
                   r.id_responsavel,
                   r.nome_completo    AS resp_nome,
                   r.telefone         AS resp_telefone,
                   v.id_veterinario,
                   v.nome_completo    AS vet_nome,
                   v.crmv             AS vet_crmv,
                   v.telefone         AS vet_telefone,
                   c.id_clinica,
                   c.nome             AS clin_nome,
                   c.cnpj             AS clin_cnpj,
                   c.telefone         AS clin_telefone,
                   c.email            AS clin_email,
                   e.bairro           AS clin_bairro,
                   e.cidade           AS clin_cidade,
                   e.estado           AS clin_estado
            FROM  (SELECT a.id_auditoria,
                          a.tipo_operacao,
                          a.data_hora_operacao,
                          a.nome_usuario,
                          a.id_registro_afetado,
                          DBMS_LOB.SUBSTR(a.valores_novos, 4000, 1) AS valores_novos_txt
                   FROM   elo_auditoria a
                   WHERE  a.data_hora_operacao >= TRUNC(SYSDATE) - 1
                   AND    a.data_hora_operacao <  TRUNC(SYSDATE)
                   AND    a.valores_novos IS NOT NULL) au
            LEFT JOIN elo_pet p
                   ON p.id_pet = TO_NUMBER(REGEXP_SUBSTR(au.valores_novos_txt, '"id_pet":([0-9]+)', 1, 1, NULL, 1))
            LEFT JOIN elo_veterinario v
                   ON v.id_veterinario = TO_NUMBER(REGEXP_SUBSTR(au.valores_novos_txt, '"id_veterinario":([0-9]+)', 1, 1, NULL, 1))
            LEFT JOIN elo_clinica c
                   ON c.id_clinica = TO_NUMBER(REGEXP_SUBSTR(au.valores_novos_txt, '"id_clinica":([0-9]+)', 1, 1, NULL, 1))
            LEFT JOIN elo_endereco e
                   ON e.id_endereco = c.id_endereco
            LEFT JOIN elo_agendamento ag
                   ON ag.id_agendamento = au.id_registro_afetado
            LEFT JOIN elo_responsavel r
                   ON r.id_responsavel = ag.id_responsavel
            ORDER BY au.id_auditoria;

        v_json        CLOB;
        v_pet         VARCHAR2(4000);
        v_responsavel VARCHAR2(4000);
        v_veterinario VARCHAR2(4000);
        v_clinica     VARCHAR2(4000);

        v_qtd_linhas PLS_INTEGER := 0;

        e_sem_dados EXCEPTION;

    BEGIN
        v_json := '[';

        FOR r_aud IN c_auditoria LOOP
            v_qtd_linhas := v_qtd_linhas + 1;

            -- Cada entidade vira um objeto aninhado; se não for encontrada, fica null
            v_pet := NULL;
            IF r_aud.id_pet IS NOT NULL THEN
                v_pet := DBMS_LOB.SUBSTR(fn_monta_json(elo_json_campos(
                    elo_json_campo('id_pet',           TO_CHAR(r_aud.id_pet), 'NUMERO'),
                    elo_json_campo('nome',             r_aud.pet_nome, 'TEXTO'),
                    elo_json_campo('especie',          r_aud.pet_especie, 'TEXTO'),
                    elo_json_campo('raca',             r_aud.pet_raca, 'TEXTO'),
                    elo_json_campo('sexo',             r_aud.pet_sexo, 'TEXTO'),
                    elo_json_campo('data_nascimento',  TO_CHAR(r_aud.pet_data_nascimento, 'DD/MM/YYYY'), 'TEXTO'),
                    elo_json_campo('idade_aproximada', TO_CHAR(r_aud.pet_idade_aproximada), 'NUMERO'),
                    elo_json_campo('castrado',         CASE r_aud.pet_flag_castrado WHEN 1 THEN 'SIM' WHEN 0 THEN 'NAO' END, 'TEXTO')
                )), 4000, 1);
            END IF;

            v_responsavel := NULL;
            IF r_aud.id_responsavel IS NOT NULL THEN
                v_responsavel := DBMS_LOB.SUBSTR(fn_monta_json(elo_json_campos(
                    elo_json_campo('id_responsavel', TO_CHAR(r_aud.id_responsavel), 'NUMERO'),
                    elo_json_campo('nome_completo',  r_aud.resp_nome, 'TEXTO'),
                    elo_json_campo('telefone',       r_aud.resp_telefone, 'TEXTO')
                )), 4000, 1);
            END IF;

            v_veterinario := NULL;
            IF r_aud.id_veterinario IS NOT NULL THEN
                v_veterinario := DBMS_LOB.SUBSTR(fn_monta_json(elo_json_campos(
                    elo_json_campo('id_veterinario', TO_CHAR(r_aud.id_veterinario), 'NUMERO'),
                    elo_json_campo('nome_completo',  r_aud.vet_nome, 'TEXTO'),
                    elo_json_campo('crmv',           r_aud.vet_crmv, 'TEXTO'),
                    elo_json_campo('telefone',       r_aud.vet_telefone, 'TEXTO')
                )), 4000, 1);
            END IF;

            v_clinica := NULL;
            IF r_aud.id_clinica IS NOT NULL THEN
                v_clinica := DBMS_LOB.SUBSTR(fn_monta_json(elo_json_campos(
                    elo_json_campo('id_clinica', TO_CHAR(r_aud.id_clinica), 'NUMERO'),
                    elo_json_campo('nome',       r_aud.clin_nome, 'TEXTO'),
                    elo_json_campo('cnpj',       r_aud.clin_cnpj, 'TEXTO'),
                    elo_json_campo('telefone',   r_aud.clin_telefone, 'TEXTO'),
                    elo_json_campo('email',      r_aud.clin_email, 'TEXTO'),
                    elo_json_campo('bairro',     r_aud.clin_bairro, 'TEXTO'),
                    elo_json_campo('cidade',     r_aud.clin_cidade, 'TEXTO'),
                    elo_json_campo('estado',     r_aud.clin_estado, 'TEXTO')
                )), 4000, 1);
            END IF;

            IF v_qtd_linhas > 1 THEN
                v_json := v_json || ',';
            END IF;

            v_json := v_json || fn_monta_json(elo_json_campos(
                elo_json_campo('id_auditoria',       TO_CHAR(r_aud.id_auditoria), 'NUMERO'),
                elo_json_campo('tipo_operacao',      r_aud.tipo_operacao, 'TEXTO'),
                elo_json_campo('data_hora_operacao', TO_CHAR(r_aud.data_hora_operacao, 'DD/MM/YYYY HH24:MI:SS'), 'TEXTO'),
                elo_json_campo('usuario_banco',      r_aud.nome_usuario, 'TEXTO'),
                elo_json_campo('id_agendamento',     TO_CHAR(r_aud.id_registro_afetado), 'NUMERO'),
                elo_json_campo('valores_novos',      r_aud.valores_novos_txt, 'JSON'),
                elo_json_campo('pet',                v_pet, 'JSON'),
                elo_json_campo('responsavel',        v_responsavel, 'JSON'),
                elo_json_campo('veterinario',        v_veterinario, 'JSON'),
                elo_json_campo('clinica',            v_clinica, 'JSON')
            ));
        END LOOP;

        IF v_qtd_linhas = 0 THEN
            RAISE e_sem_dados;
        END IF;

        v_json := v_json || ']';

        RETURN v_json;

    EXCEPTION
        WHEN e_sem_dados THEN
            DBMS_OUTPUT.PUT_LINE('[fn_exporta_valores_novos] Aviso: nao ha valores novos auditados no dia anterior. Retornando array vazio.');
            RETURN '[]';
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('[fn_exporta_valores_novos] Erro de conversao ao montar o JSON: ' || SQLERRM);
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[fn_exporta_valores_novos] Erro inesperado: ' || SQLERRM);
            RETURN NULL;
    END fn_exporta_valores_novos;
 
 
    --============================================================================
    -- PROCEDURE 1 - pr_agenda_json
    --   Faz JOIN entre elo_agendamento, elo_pet, elo_veterinario e elo_clinica
    --   (4 tabelas relacionais) e exibe cada linha como um objeto JSON (string),
    --   montado manualmente através da FUNCTION 1 (fn_monta_json).
    --============================================================================
    PROCEDURE pr_agenda_json
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
 
 
    --============================================================================
    -- PROCEDURE 2 - pr_totaliza_idade_pet
    --   Lê elo_pet (colunas categóricas: especie, sexo | coluna numérica:
    --   idade_aproximada) e imprime:
    --     - o total de idade_aproximada por combinação completa (especie, sexo)
    --     - o subtotal por espécie
    --     - o total geral
    --   Toda a soma é feita em variáveis PL/SQL, acumulando linha a linha em um
    --   ÚNICO passo pelo cursor (técnica de quebra de controle / control break).
    --   Não há SUM(), GROUP BY, ROLLUP, CUBE, GROUPING SETS ou GROUPING - a
    --   única cláusula SQL usada é o ORDER BY, apenas para garantir que as
    --   combinações iguais fiquem agrupadas na leitura sequencial.
    --============================================================================
    PROCEDURE pr_totaliza_idade_pet
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
 
 
    --============================================================================
    -- PROCEDURE 3 - pr_audita_agendamento
    --   Lógica da trigger trg_auditoria_agendamento. Grava em elo_auditoria:
    --   usuário da sessão, tipo de operação, data/hora, tabela afetada, chave do
    --   registro afetado e os valores :OLD e :NEW (cada um convertido para JSON
    --   manualmente através da FUNCTION 1). Uma package não enxerga :OLD/:NEW,
    --   por isso a trigger repassa esses valores como parâmetros.
    --============================================================================
    PROCEDURE pr_audita_agendamento (
        p_tipo_operacao      IN VARCHAR2,
        p_id_agendamento_ant IN elo_agendamento.id_agendamento%TYPE,
        p_id_pet_ant         IN elo_agendamento.id_pet%TYPE,
        p_id_veterinario_ant IN elo_agendamento.id_veterinario%TYPE,
        p_id_clinica_ant     IN elo_agendamento.id_clinica%TYPE,
        p_status_ant         IN elo_agendamento.status%TYPE,
        p_data_hora_ant      IN elo_agendamento.data_hora_agendamento%TYPE,
        p_id_agendamento_novo IN elo_agendamento.id_agendamento%TYPE,
        p_id_pet_novo         IN elo_agendamento.id_pet%TYPE,
        p_id_veterinario_novo IN elo_agendamento.id_veterinario%TYPE,
        p_id_clinica_novo     IN elo_agendamento.id_clinica%TYPE,
        p_status_novo         IN elo_agendamento.status%TYPE,
        p_data_hora_novo      IN elo_agendamento.data_hora_agendamento%TYPE
    )
    IS
        v_id_registro    NUMBER;
        v_campos_antigos elo_json_campos;
        v_campos_novos   elo_json_campos;
        v_json_antigo    CLOB;
        v_json_novo      CLOB;
    BEGIN
        IF p_tipo_operacao = 'DELETE' THEN
            v_id_registro := p_id_agendamento_ant;
        ELSE
            v_id_registro := p_id_agendamento_novo;
        END IF;
 
        IF p_tipo_operacao <> 'DELETE' THEN
            v_campos_novos := elo_json_campos(
                elo_json_campo('id_agendamento', TO_CHAR(p_id_agendamento_novo), 'NUMERO'),
                elo_json_campo('id_pet',         TO_CHAR(p_id_pet_novo), 'NUMERO'),
                elo_json_campo('id_veterinario', TO_CHAR(p_id_veterinario_novo), 'NUMERO'),
                elo_json_campo('id_clinica',     TO_CHAR(p_id_clinica_novo), 'NUMERO'),
                elo_json_campo('status',         p_status_novo, 'TEXTO'),
                elo_json_campo('data_hora',      TO_CHAR(p_data_hora_novo, 'DD/MM/YYYY HH24:MI'), 'TEXTO')
            );
            v_json_novo := fn_monta_json(v_campos_novos);
        END IF;
 
        IF p_tipo_operacao <> 'INSERT' THEN
            v_campos_antigos := elo_json_campos(
                elo_json_campo('id_agendamento', TO_CHAR(p_id_agendamento_ant), 'NUMERO'),
                elo_json_campo('id_pet',         TO_CHAR(p_id_pet_ant), 'NUMERO'),
                elo_json_campo('id_veterinario', TO_CHAR(p_id_veterinario_ant), 'NUMERO'),
                elo_json_campo('id_clinica',     TO_CHAR(p_id_clinica_ant), 'NUMERO'),
                elo_json_campo('status',         p_status_ant, 'TEXTO'),
                elo_json_campo('data_hora',      TO_CHAR(p_data_hora_ant, 'DD/MM/YYYY HH24:MI'), 'TEXTO')
            );
            v_json_antigo := fn_monta_json(v_campos_antigos);
        END IF;
 
        INSERT INTO elo_auditoria (
            nome_usuario, tipo_operacao, data_hora_operacao,
            tabela_afetada, id_registro_afetado,
            valores_anteriores, valores_novos
        ) VALUES (
            SYS_CONTEXT('USERENV', 'SESSION_USER'), p_tipo_operacao, SYSTIMESTAMP,
            'ELO_AGENDAMENTO', v_id_registro,
            v_json_antigo, v_json_novo
        );
 
    EXCEPTION
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20050, 'Erro de conversao de dados na trigger de auditoria de elo_agendamento: ' || SQLERRM);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20051, 'Erro inesperado na trigger de auditoria de elo_agendamento: ' || SQLERRM);
    END pr_audita_agendamento;
 
END pkg_elovet;
/