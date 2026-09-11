# EloVet

Sistema B2B2C para clínicas veterinárias e tutores de pets, modelado em **Oracle Database**.

Projeto acadêmico FIAP — **Mastering Relational Database, Sprint 3**.

## Sobre o projeto

O EloVet conecta clínicas veterinárias, veterinários e responsáveis de pets em um único modelo relacional, cobrindo:

- Cadastro de clínicas, endereços, veterinários e suas especialidades;
- Cadastro de responsáveis e dos pets sob sua responsabilidade (relação N:N);
- Agendamento de consultas, vinculando pet, responsável, veterinário e clínica;
- Login/autenticação segmentado por tipo de usuário (`ADMIN`, `USER`, `VETERINARIO`, `RESPONSAVEL`);
- Auditoria automática das alterações feitas nos agendamentos.

## Estrutura do repositório

```
├── DDL/
│   └── ddl.sql                  # Tabelas, constraints, índices, FKs e sequences/triggers de PK
├── Type/
│   └── type_EloVet.sql          # Tipos elo_json_campo / elo_json_campos
├── Function/
│   └── function_EloVet.sql      # fn_monta_json e fn_valida_cpf
├── Procedure/
│   └── procedure_EloVet.sql     # pr_agenda_json e pr_totaliza_idade_pet
├── Trigger/
│   └── trigger_EloVet.sql       # trg_auditoria_agendamento
└── DML/
    └── carga_de_Dados.sql       # Massa de dados para teste (mínimo 5 registros por tabela)
```

## Modelo de dados

O modelo é composto por 12 tabelas principais:

| Tabela | Descrição |
|---|---|
| `elo_endereco` | Endereços reutilizados por clínicas, responsáveis e veterinários |
| `elo_clinica` | Clínicas veterinárias parceiras |
| `elo_especialidade` | Especialidades veterinárias (dermatologia, ortopedia, etc.) |
| `elo_login` | Credenciais e tipo de usuário do sistema |
| `elo_responsavel` | Tutores dos pets |
| `elo_veterinario` | Veterinários cadastrados (CRMV) |
| `elo_pet` | Pets cadastrados |
| `elo_pet_responsavel` | Associação N:N entre pets e responsáveis |
| `elo_clinica_veterinario` | Associação N:N entre clínicas e veterinários |
| `elo_veterinario_especialidade` | Associação N:N entre veterinários e especialidades |
| `elo_agendamento` | Consultas agendadas |
| `elo_auditoria` | Log de auditoria das operações em `elo_agendamento` |

Principais regras de negócio aplicadas via `CHECK`:

- CPF de responsáveis e veterinários com exatamente 11 dígitos numéricos (validação do dígito verificador é feita à parte, na função `fn_valida_cpf`);
- CNPJ de clínica com 14 dígitos numéricos;
- CEP com 8 dígitos numéricos e UF com 2 caracteres;
- `sexo` do pet restrito a `M`, `F` ou `N`, com `idade_aproximada` não-negativa e obrigatoriedade de `data_nascimento` OU `idade_aproximada`;
- `status` do agendamento restrito a `AGENDADO`, `CONFIRMADO`, `EM_ATENDIMENTO`, `CONCLUIDO`, `CANCELADO` ou `NAO_COMPARECEU`.

## Objetos PL/SQL

### Types

- **`elo_json_campo`** / **`elo_json_campos`** — tipo objeto e tabela de objetos que representam pares `nome do campo / valor / tipo`, usados como entrada genérica para a montagem manual de JSON.

### Functions

- **`fn_monta_json(p_campos IN elo_json_campos) RETURN CLOB`** — recebe uma coleção de `elo_json_campo` e monta a string JSON equivalente por concatenação manual (sem `TO_JSON`, `JSON_OBJECT` ou qualquer função nativa de JSON do Oracle), incluindo escape de aspas e barra invertida.
- **`fn_valida_cpf(p_cpf IN VARCHAR2) RETURN VARCHAR2`** — calcula os dois dígitos verificadores do CPF pelo algoritmo oficial (módulo 11) e retorna `'VALIDO'` ou `'INVALIDO'`.

### Procedures

- **`pr_agenda_json`** — faz `JOIN` entre `elo_agendamento`, `elo_pet`, `elo_veterinario` e `elo_clinica` e imprime cada agendamento como um objeto JSON, montado via `fn_monta_json`.
- **`pr_totaliza_idade_pet`** — percorre `elo_pet` com técnica de **quebra de controle** (control break) para somar `idade_aproximada` por combinação `especie/sexo`, com subtotal por espécie e total geral — sem usar `SUM`, `GROUP BY`, `ROLLUP` ou `CUBE`.

### Trigger

- **`trg_auditoria_agendamento`** — `AFTER INSERT OR UPDATE OR DELETE ON elo_agendamento`, `FOR EACH ROW`. Grava em `elo_auditoria` o usuário da sessão, o tipo de operação, a tabela e o registro afetados, além dos valores `:OLD` e `:NEW` convertidos para JSON via `fn_monta_json`.

Todas as functions, procedures e a trigger tratam exceções específicas (dados ausentes, CPF inválido, conversão numérica, etc.) além de um `WHEN OTHERS` genérico.

## Como executar

Pré-requisito: acesso a um schema Oracle Database (21c ou compatível), por exemplo via SQL Developer, SQLcl ou Oracle Live SQL.

Execute os scripts nesta ordem:

```sql
@DDL/ddl.sql
@Type/type_EloVet.sql
@Function/function_EloVet.sql
@Procedure/procedure_EloVet.sql
@Trigger/trigger_EloVet.sql
@DML/carga_de_Dados.sql
```

Após a carga, é possível testar os objetos criados:

```sql
SET SERVEROUTPUT ON;
EXEC pr_agenda_json;
EXEC pr_totaliza_idade_pet;

SELECT fn_valida_cpf('11144477735') FROM dual;
```

## Tecnologias

- Oracle Database 21c
- PL/SQL (types, functions, procedures, triggers)
- Modelagem gerada com Oracle SQL Developer Data Modeler

## Equipe

| Nome | RM |
| --- | --- |
| Arthur Graciani | RM561728 |
| Gustavo Oliveira | RM566358 |
| João Pedro Scarpin | RM565421 |
| Lucas Hideki | RM565355 |
| Wesley Andrade | RM563593 |

Projeto desenvolvido para a disciplina **Mastering Relational Database** — FIAP, Sprint 3.
