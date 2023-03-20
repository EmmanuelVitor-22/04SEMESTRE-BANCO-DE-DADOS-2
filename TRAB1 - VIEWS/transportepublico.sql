CREATE TABLE tarifa (
id_tarifa SERIAL NOT NULL PRIMARY KEY,
valor float NOT NULL
);

CREATE TABLE passageiro (
    id_passageiro SERIAL NOT NULL PRIMARY KEY,
    nome VARCHAR(30),
    cpf VARCHAR(14),
    id_tarifa INTEGER REFERENCES tarifa (id_tarifa),
    CONSTRAINT fk_id_tarifa FOREIGN KEY (id_tarifa) REFERENCES tarifa (id_tarifa)
);

CREATE TABLE motorista (
    id_motorista SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnh VARCHAR(20) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE
);

CREATE TABLE cobrador (
    id_cobrador SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE
);

CREATE TABLE onibus (
    id_veiculo SERIAL PRIMARY KEY,
    placa VARCHAR(10) NOT NULL UNIQUE,
    capacidade INTEGER NOT NULL,
    modelo VARCHAR(100) NOT NULL
);

CREATE TABLE itinerario (
    id_itinerario SERIAL PRIMARY KEY
);

CREATE TABLE ponto_de_onibus (
    id_ponto SERIAL PRIMARY KEY,
    localizacao VARCHAR(100) NOT NULL
);

CREATE TABLE linha (
    id_linha SERIAL PRIMARY KEY,
    id_itinerario INTEGER REFERENCES itinerario(id_itinerario),
    nome_da_linha VARCHAR(100) NOT NULL,
    saida varchar(30) NOT NULL,
    lFinal  varchar(30)  NOT NULL,
    CONSTRAINT fk_itinerario FOREIGN KEY (id_itinerario) REFERENCES itinerario (id_itinerario)
);

CREATE TABLE itinerario_ponto (
    id_itinerario INTEGER NOT NULL REFERENCES itinerario (id_itinerario),
    id_ponto INTEGER NOT NULL REFERENCES ponto_de_onibus (id_ponto),
    PRIMARY KEY (id_itinerario, id_ponto),
    CONSTRAINT fk_itinerario_ponto_itinerario FOREIGN KEY (id_itinerario) REFERENCES itinerario (id_itinerario),
    CONSTRAINT fk_itinerario_ponto_ponto FOREIGN KEY (id_ponto) REFERENCES ponto_de_onibus (id_ponto)
);

CREATE TABLE viagem (
    id_viagem SERIAL PRIMARY KEY,
    id_motorista INTEGER REFERENCES motorista(id_motorista),
    id_cobrador INTEGER REFERENCES cobrador(id_cobrador),
    id_veiculo INTEGER REFERENCES onibus(id_veiculo),
    id_linha INTEGER REFERENCES linha(id_linha),
    id_passageiro INTEGER REFERENCES passageiro(id_passageiro),
    dt_entrada TIMESTAMP NOT NULL
);

INSERT INTO tarifa (valor) VALUES (2.50), (3.00), (3.50), (4.00), (4.50);

INSERT INTO passageiro (nome, cpf, id_tarifa) VALUES
('João da Silva', '123.456.789-00', 1),
('Maria Santos', '987.654.321-00', 2),
('Lucas Souza', '456.789.123-00', 3),
('Ana Paula', '789.123.456-00', 4),
('Fernando Oliveira', '321.654.987-00', 5);

INSERT INTO motorista (nome, cnh, cpf) VALUES
('José Santos', '12345678900', '111.222.333-44'),
('Carlos Ferreira', '98765432100', '222.333.444-55'),
('Pedro Oliveira', '45678912300', '333.444.555-66'),
('Márcio Souza', '78912345600', '444.555.666-77'),
('Bruna Oliveira', '32165498700', '555.666.777-88');

INSERT INTO cobrador (nome, cpf) VALUES
('Ana Silva', '111.222.333-44'),
('Lucas Ferreira', '222.333.444-55'),
('Paula Oliveira', '333.444.555-66'),
('Fernando Souza', '444.555.666-77'),
('Gabriel Santos', '555.666.777-88');

INSERT INTO onibus (placa, capacidade, modelo) VALUES
('ABC1234', 50, 'Marcopolo Viaggio G7'),
('DEF5678', 40, 'Neobus Thunder Way'),
('GHI9012', 60, 'Comil Svelto'),
('JKL3456', 30, 'Busscar Urbanuss Pluss'),
('MNO7890', 45, 'Caio Apache Vip');

INSERT INTO itinerario DEFAULT VALUES;

INSERT INTO ponto_de_onibus (localizacao) VALUES
('Avenida Paulista, 1000'),
('Rua Augusta, 200'),
('Rua Oscar Freire, 500'),
('Avenida Faria Lima, 1500'),
('Avenida Brigadeiro Faria Lima, 2000');

INSERT INTO linha (id_itinerario, nome_da_linha, saida, lFinal) VALUES
(1, 'Linha 1', 'A', 'B'),
(1, 'Linha 2', 'C', 'D'),
(1, 'Linha 3', 'E', 'F'),
(1, 'Linha 4', 'G', 'H'),
(1, 'Linha 5', 'I', 'J');

INSERT INTO itinerario_ponto (id_itinerario, id_ponto) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5);

INSERT INTO viagem (id_motorista, id_cobrador, id_veiculo, id_linha, id_passageiro, dt_entrada) VALUES
(1, 1, 1, 1, 1, NOW()),
(2, 2, 2, 2, 2, NOW()),
(3, 3, 3, 3, 3, NOW()),
(4, 4, 4, 4, 4, NOW()),
(5, 5, 5, 5, 5, NOW());

CREATE MATERIALIZED VIEW dados_viagem_arrecadacao AS
SELECT
     dt_entrada AS data,
    COUNT(*) AS num_passageiros,
    SUM(t.valor) AS valor_arrecadado,
    l.nome_da_linha AS linha
FROM
    viagem v
    JOIN passageiro p ON v.id_passageiro = p.id_passageiro
    JOIN linha l ON v.id_linha = l.id_linha
    JOIN tarifa t ON p.id_tarifa = t.id_tarifa
GROUP BY
  dt_entrada,
    l.nome_da_linha;

SELECT * FROM   dados_viagem_arrecadacao;