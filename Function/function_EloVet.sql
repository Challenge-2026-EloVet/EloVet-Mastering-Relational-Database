--================================================================================
-- FUNCTION 1 - fn_monta_json
--   Recebe uma colecao de pares campo/valor (tipo elo_json_campos) e devolve
--   manualmente a string JSON equivalente, SEM usar nenhuma funcao Oracle
--   pronta de JSON (nao usa TO_JSON, JSON_OBJECT, JSON_VALUE, JSON_QUERY,
--   JSON_TABLE ou similares). A montagem e feita por concatenacao de string
--   (operador ||) dentro de um loop, incluindo escape manual de aspas e
--   barra invertida.
--================================================================================
DROP FUNCTION fn_monta_json;

CREATE OR REPLACE FUNCTION fn_monta_json (p_campos IN elo_json_campos) RETURN CLOB
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

        IF p_campos(i).tipo_campo = 'NUMERO' THEN
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
/


--================================================================================
-- FUNCTION 2 - fn_valida_cpf
--   Substitui o processo de validacao de CPF do cadastro de responsaveis e
--   veterinarios (elo_responsavel.cpf / elo_veterinario.cpf). A constraint
--   de tabela so garante 11 digitos numericos; esta funcao calcula os dois
--   digitos verificadores (algoritmo oficial modulo 11) e confirma se o CPF
--   informado e matematicamente valido.
--================================================================================
DROP FUNCTION fn_valida_cpf;

CREATE OR REPLACE FUNCTION fn_valida_cpf (p_cpf IN VARCHAR2) RETURN VARCHAR2
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
/