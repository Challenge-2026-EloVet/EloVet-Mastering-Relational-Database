--================================================================================
-- DML - CARGA DE DADOS
--================================================================================

-- 1 Enderecos (15): 1-5 clinicas | 6-10 responsaveis | 11-15 veterinarios
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua dos Pinheiros', '500', 'Sala 12', 'Pinheiros', 'Sao Paulo', 'SP', '05422000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Avenida Ibirapuera', '2000', NULL, 'Moema', 'Sao Paulo', 'SP', '04029000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua Tuiuti', '800', 'Loja 3', 'Tatuape', 'Sao Paulo', 'SP', '03307000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Avenida Santo Amaro', '1500', NULL, 'Santo Amaro', 'Sao Paulo', 'SP', '04702000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Alameda Rio Negro', '300', 'Bloco B', 'Alphaville', 'Barueri', 'SP', '06454000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua das Camelias', '45', 'Apto 61', 'Vila Mariana', 'Sao Paulo', 'SP', '04023000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua Augusta', '1200', NULL, 'Consolacao', 'Sao Paulo', 'SP', '01304000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua Harmonia', '220', 'Casa 2', 'Sumarezinho', 'Sao Paulo', 'SP', '05435000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua Girassol', '150', NULL, 'Vila Madalena', 'Sao Paulo', 'SP', '05433000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Avenida Paulista', '900', 'Apto 122', 'Bela Vista', 'Sao Paulo', 'SP', '01310100');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua Oscar Freire', '600', NULL, 'Jardins', 'Sao Paulo', 'SP', '01426000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua dos Tres Irmaos', '80', 'Apto 34', 'Vila Romana', 'Sao Paulo', 'SP', '05068000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua Cardeal Arcoverde', '310', NULL, 'Pinheiros', 'Sao Paulo', 'SP', '05407000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Rua Bela Cintra', '750', 'Sala 4', 'Consolacao', 'Sao Paulo', 'SP', '01415000');
INSERT INTO elo_endereco (logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES ('Avenida Faria Lima', '3000', 'Conjunto 91', 'Itaim Bibi', 'Sao Paulo', 'SP', '04538000');

-- 2 Clinicas (5) - endereco 1 a 5
INSERT INTO elo_clinica (nome, cnpj, telefone, email, id_endereco) VALUES ('Elo Vet Pinheiros', '12345678000190', '1130451122', 'contato@elovet-pinheiros.com.br', 1);
INSERT INTO elo_clinica (nome, cnpj, telefone, email, id_endereco) VALUES ('Elo Vet Moema', '23456789000181', '1130452233', 'contato@elovet-moema.com.br', 2);
INSERT INTO elo_clinica (nome, cnpj, telefone, email, id_endereco) VALUES ('Elo Vet Tatuape', '34567890000172', '1130453344', 'contato@elovet-tatuape.com.br', 3);
INSERT INTO elo_clinica (nome, cnpj, telefone, email, id_endereco) VALUES ('Elo Vet Santo Amaro', '45678901000163', '1130454455', 'contato@elovet-santoamaro.com.br', 4);
INSERT INTO elo_clinica (nome, cnpj, telefone, email, id_endereco) VALUES ('Elo Vet Alphaville', '56789012000154', '1130455566', 'contato@elovet-alphaville.com.br', 5);

-- 3 Especialidades (5)
INSERT INTO elo_especialidade (nome, descricao) VALUES ('Clinica Geral', 'Atendimento clinico geral e preventivo de rotina');
INSERT INTO elo_especialidade (nome, descricao) VALUES ('Dermatologia', 'Diagnostico e tratamento de doencas de pele e pelagem');
INSERT INTO elo_especialidade (nome, descricao) VALUES ('Ortopedia', 'Tratamento de ossos, articulacoes e mobilidade');
INSERT INTO elo_especialidade (nome, descricao) VALUES ('Cardiologia', 'Avaliacao e acompanhamento cardiaco');
INSERT INTO elo_especialidade (nome, descricao) VALUES ('Odontologia', 'Saude bucal e procedimentos odontologicos');

-- 4 Login (10) - 1 a 5 responsaveis | 6 a 10 veterinarios
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('ana.souza', 'ana.souza@email.com', 'HASH_SENHA_0001', 'RESPONSAVEL');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('bruno.lima', 'bruno.lima@email.com', 'HASH_SENHA_0002', 'RESPONSAVEL');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('carla.fernandes', 'carla.fernandes@email.com', 'HASH_SENHA_0003', 'RESPONSAVEL');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('diego.martins', 'diego.martins@email.com', 'HASH_SENHA_0004', 'RESPONSAVEL');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('elisa.nogueira', 'elisa.nogueira@email.com', 'HASH_SENHA_0005', 'RESPONSAVEL');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('fabio.ramos', 'fabio.ramos@elovet.com.br', 'HASH_SENHA_0006', 'VETERINARIO');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('gabriela.torres', 'gabriela.torres@elovet.com.br', 'HASH_SENHA_0007', 'VETERINARIO');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('henrique.alves', 'henrique.alves@elovet.com.br', 'HASH_SENHA_0008', 'VETERINARIO');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('isabela.rocha', 'isabela.rocha@elovet.com.br', 'HASH_SENHA_0009', 'VETERINARIO');
INSERT INTO elo_login (nome_usuario, email, senha_hash, tipo_usuario) VALUES ('joao.salles', 'joao.salles@elovet.com.br', 'HASH_SENHA_0010', 'VETERINARIO');

-- 5 Responsaveis (5) - usuario 1-5, endereco 6-10
INSERT INTO elo_responsavel (id_usuario, nome_completo, cpf, rg, data_nascimento, telefone, id_endereco) VALUES (1, 'Ana Beatriz Souza', '11144477735', '221334455', DATE '1990-03-14', '11987650001', 6);
INSERT INTO elo_responsavel (id_usuario, nome_completo, cpf, rg, data_nascimento, telefone, id_endereco) VALUES (2, 'Bruno Cesar Lima', '52998224725', '221334456', DATE '1985-07-22', '11987650002', 7);
INSERT INTO elo_responsavel (id_usuario, nome_completo, cpf, rg, data_nascimento, telefone, id_endereco) VALUES (3, 'Carla Fernandes', '39876543253', '221334457', DATE '1993-11-02', '11987650003', 8);
INSERT INTO elo_responsavel (id_usuario, nome_completo, cpf, rg, data_nascimento, telefone, id_endereco) VALUES (4, 'Diego Martins', '85274196373', '221334458', DATE '1988-01-30', '11987650004', 9);
INSERT INTO elo_responsavel (id_usuario, nome_completo, cpf, rg, data_nascimento, telefone, id_endereco) VALUES (5, 'Elisa Nogueira', '14725836982', '221334459', DATE '1996-05-18', '11987650005', 10);

-- 6 Veterinarios (5) - usuario 6-10, endereco 11-15
INSERT INTO elo_veterinario (id_usuario, nome_completo, cpf, rg, data_nascimento, crmv, telefone, id_endereco) VALUES (6, 'Fabio Ramos', '96385274128', '331445566', DATE '1982-02-10', 'CRMV-SP 10234', '11976540001', 11);
INSERT INTO elo_veterinario (id_usuario, nome_completo, cpf, rg, data_nascimento, crmv, telefone, id_endereco) VALUES (7, 'Gabriela Torres', '74185296355', '331445567', DATE '1987-09-05', 'CRMV-SP 10567', '11976540002', 12);
INSERT INTO elo_veterinario (id_usuario, nome_completo, cpf, rg, data_nascimento, crmv, telefone, id_endereco) VALUES (8, 'Henrique Alves', '25836914737', '331445568', DATE '1979-12-19', 'CRMV-SP 10891', '11976540003', 13);
INSERT INTO elo_veterinario (id_usuario, nome_completo, cpf, rg, data_nascimento, crmv, telefone, id_endereco) VALUES (9, 'Isabela Rocha', '36914725837', '331445569', DATE '1991-06-27', 'CRMV-SP 11023', '11976540004', 14);
INSERT INTO elo_veterinario (id_usuario, nome_completo, cpf, rg, data_nascimento, crmv, telefone, id_endereco) VALUES (10, 'Joao Pedro Salles', '45678912364', '331445570', DATE '1984-04-08', 'CRMV-SP 11345', '11976540005', 15);

-- 7 Vinculo clinica x veterinario (5)
INSERT INTO elo_clinica_veterinario (id_clinica, id_veterinario) VALUES (1, 1);
INSERT INTO elo_clinica_veterinario (id_clinica, id_veterinario) VALUES (1, 2);
INSERT INTO elo_clinica_veterinario (id_clinica, id_veterinario) VALUES (2, 3);
INSERT INTO elo_clinica_veterinario (id_clinica, id_veterinario) VALUES (3, 4);
INSERT INTO elo_clinica_veterinario (id_clinica, id_veterinario) VALUES (4, 5);

-- 8 Vinculo veterinario x especialidade (5)
INSERT INTO elo_veterinario_especialidade (id_veterinario, id_especialidade) VALUES (1, 1);
INSERT INTO elo_veterinario_especialidade (id_veterinario, id_especialidade) VALUES (2, 2);
INSERT INTO elo_veterinario_especialidade (id_veterinario, id_especialidade) VALUES (3, 3);
INSERT INTO elo_veterinario_especialidade (id_veterinario, id_especialidade) VALUES (4, 4);
INSERT INTO elo_veterinario_especialidade (id_veterinario, id_especialidade) VALUES (5, 5);

-- 9 Pets (10) - usados no Procedimento 2 (especie / sexo / idade_aproximada)
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Rex', 'Canino', 'SRD', 'M', 5, 1);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Luna', 'Canino', 'Poodle', 'F', 3, 1);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Thor', 'Canino', 'Labrador', 'M', 7, 0);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Mel', 'Felino', 'SRD', 'F', 2, 1);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Nina', 'Felino', 'Siames', 'F', 4, 1);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Bidu', 'Canino', 'Vira-lata', 'M', 1, 0);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Miau', 'Felino', 'Persa', 'M', 6, 1);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Amora', 'Felino', 'SRD', 'F', 3, 0);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Zeus', 'Canino', 'Pastor Alemao', 'M', 4, 1);
INSERT INTO elo_pet (nome, especie, raca, sexo, idade_aproximada, flag_castrado) VALUES ('Kiara', 'Felino', 'SRD', 'N', 1, 0);

-- 10 Vinculo pet x responsavel (10)
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (1, 1);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (2, 1);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (3, 2);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (4, 3);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (5, 3);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (6, 4);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (7, 4);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (8, 5);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (9, 5);
INSERT INTO elo_pet_responsavel (id_pet, id_responsavel) VALUES (10, 5);

-- 11 Agendamentos (8) 
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (1, 1, 1, 1, TIMESTAMP '2026-08-10 09:00:00', 'CONCLUIDO', 'Consulta de rotina');
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (2, 1, 2, 1, TIMESTAMP '2026-09-15 10:30:00', 'AGENDADO', 'Avaliacao dermatologica');
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (3, 2, 3, 2, TIMESTAMP '2026-09-12 14:00:00', 'CONFIRMADO', 'Acompanhamento ortopedico');
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (4, 3, 4, 3, TIMESTAMP '2026-08-20 11:15:00', 'CONCLUIDO', 'Check-up cardiaco');
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (5, 3, 1, 1, TIMESTAMP '2026-08-25 16:00:00', 'CANCELADO', 'Tutor remarcou');
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (6, 4, 5, 4, TIMESTAMP '2026-09-20 08:30:00', 'AGENDADO', 'Avaliacao odontologica');
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (7, 4, 2, 1, TIMESTAMP '2026-08-05 13:45:00', 'NAO_COMPARECEU', 'Tutor nao compareceu');
INSERT INTO elo_agendamento (id_pet, id_responsavel, id_veterinario, id_clinica, data_hora_agendamento, status, observacao) VALUES (8, 5, 3, 2, TIMESTAMP '2026-09-09 15:00:00', 'EM_ATENDIMENTO', 'Consulta em andamento');

COMMIT;