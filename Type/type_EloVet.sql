--================================================================================
-- TYPE - elo_json_campo / elo_json_campos
--   Tipos elo_json_campo / elo_json_campos: usados pela Funcao 1 para
--   representar, de forma generica, um conjunto de pares "nome do campo /
--   valor" que sera transformado manualmente em uma string JSON. Tambem
--   sao usados pela trigger de auditoria para montar os valores :OLD/:NEW.
--================================================================================
CREATE OR REPLACE TYPE elo_json_campo AS OBJECT (
    nome_campo  VARCHAR2(100),  
    valor_campo VARCHAR2(4000),
    tipo_campo  VARCHAR2(10)    
);
/

CREATE OR REPLACE TYPE elo_json_campos AS TABLE OF elo_json_campo;
/