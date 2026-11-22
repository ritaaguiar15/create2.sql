CREATE TABLE Ciclista (
    CiclistaID      INTEGER PRIMARY KEY,
    nome            TEXT NOT NULL,
    nacionalidade   TEXT NOT NULL,
    dataNascimento  TEXT NOT NULL
);

CREATE TABLE Equipa (
    sigla           TEXT PRIMARY KEY,
    nome            TEXT NOT NULL,
    país            TEXT NOT NULL,
    patrocinador    TEXT NOT NULL
);

CREATE TABLE Edição (
    EdiçãoID        INTEGER PRIMARY KEY,
    dataInício      TEXT NOT NULL,
    dataFim         TEXT NOT NULL,
    CHECK (dataFim >= dataInício)
);

CREATE TABLE Comissário (
    numLicença      INTEGER PRIMARY KEY,
    nome            TEXT NOT NULL
);

CREATE TABLE EdiçãoComissário (
    EdiçãoID        INTEGER NOT NULL,
    numLicença      INTEGER NOT NULL,
    PRIMARY KEY (EdiçãoID, numLicença),
    FOREIGN KEY (EdiçãoID) REFERENCES Edição(EdiçãoID),
    FOREIGN KEY (numLicença) REFERENCES Comissário(numLicença)
);

CREATE TABLE Inscrição (
    EdiçãoID        INTEGER NOT NULL,
    dorsal          INTEGER NOT NULL CHECK (dorsal > 0),
    CiclistaID      INTEGER NOT NULL,
    sigla           TEXT NOT NULL,
    PRIMARY KEY (EdiçãoID, dorsal),
    UNIQUE (EdiçãoID, CiclistaID),
    FOREIGN KEY (EdiçãoID) REFERENCES Edição(EdiçãoID),
    FOREIGN KEY (CiclistaID) REFERENCES Ciclista(CiclistaID),
    FOREIGN KEY (sigla) REFERENCES Equipa(sigla)
);

CREATE TABLE Etapa (
    EdiçãoID        INTEGER NOT NULL,
    número          INTEGER NOT NULL CHECK (número > 0),
    partida         TEXT NOT NULL,
    chegada         TEXT NOT NULL,
    distância       INTEGER NOT NULL CHECK (distância > 0),
    data            TEXT NOT NULL,
    PRIMARY KEY (EdiçãoID, número),
    FOREIGN KEY (EdiçãoID) REFERENCES Edição(EdiçãoID)
);

CREATE TABLE EtapaContrarrelógio (
    EdiçãoID            INTEGER NOT NULL,
    número              INTEGER NOT NULL,
    tipo                TEXT NOT NULL,
    intervaloPartida    TEXT NOT NULL,
    PRIMARY KEY (EdiçãoID, número),
    FOREIGN KEY (EdiçãoID, número) REFERENCES Etapa(EdiçãoID, número)
);

CREATE TABLE EtapaMontanha (
    EdiçãoID            INTEGER NOT NULL,
    número              INTEGER NOT NULL,
    ganhoElevação       INTEGER NOT NULL CHECK (ganhoElevação >= 0),
    altitudeMáxima      INTEGER NOT NULL CHECK (altitudeMáxima >= 0),
    PRIMARY KEY (EdiçãoID, número),
    FOREIGN KEY (EdiçãoID, número) REFERENCES Etapa(EdiçãoID, número)
);

CREATE TABLE Percurso (
    EdiçãoID        INTEGER NOT NULL,
    número          INTEGER NOT NULL,
    local           TEXT NOT NULL,
    PRIMARY KEY (EdiçãoID, número, local),
    FOREIGN KEY (EdiçãoID, número) REFERENCES Etapa(EdiçãoID, número)
);

CREATE TABLE PontoIntermédio (
    PontoIntermédioID   INTEGER PRIMARY KEY,
    EdiçãoID            INTEGER NOT NULL,
    número              INTEGER NOT NULL,
    quilómetro          INTEGER NOT NULL CHECK (quilómetro >= 0),
    UNIQUE (PontoIntermédioID, EdiçãoID, número),
    FOREIGN KEY (EdiçãoID, número) REFERENCES Etapa(EdiçãoID, número)
);

CREATE TABLE Sprint (
    PontoIntermédioID   INTEGER PRIMARY KEY,
    tempoBonificação    INTEGER NOT NULL CHECK (tempoBonificação > 0),
    FOREIGN KEY (PontoIntermédioID) REFERENCES PontoIntermédio(PontoIntermédioID)
        ON DELETE CASCADE
);

CREATE TABLE PontoMontanha (
    PontoIntermédioID   INTEGER PRIMARY KEY,
    categoria           TEXT NOT NULL,
    FOREIGN KEY (PontoIntermédioID) REFERENCES PontoIntermédio(PontoIntermédioID)
        ON DELETE CASCADE
);

CREATE TABLE Participação (
    EdiçãoID        INTEGER NOT NULL,
    dorsal          INTEGER NOT NULL,
    número          INTEGER NOT NULL,
    posição         INTEGER NOT NULL CHECK (posição > 0),
    tempoBruto      TEXT NOT NULL,
    PRIMARY KEY (EdiçãoID, dorsal, número),
    UNIQUE (EdiçãoID, número, posição),
    FOREIGN KEY (EdiçãoID, dorsal) REFERENCES Inscrição(EdiçãoID, dorsal),
    FOREIGN KEY (EdiçãoID, número) REFERENCES Etapa(EdiçãoID, número)
);

CREATE TABLE Penalização (
    PenalizaçãoID   INTEGER PRIMARY KEY,
    EdiçãoID        INTEGER NOT NULL,
    dorsal          INTEGER NOT NULL,
    número          INTEGER NOT NULL,
    motivo          TEXT NOT NULL,
    tempoAdicionado TEXT NOT NULL,
    FOREIGN KEY (EdiçãoID, dorsal, número)
        REFERENCES Participação(EdiçãoID, dorsal, número)
);

CREATE TABLE Incidente (
    IncidenteID     INTEGER PRIMARY KEY,
    EdiçãoID        INTEGER NOT NULL,
    dorsal          INTEGER NOT NULL,
    número          INTEGER NOT NULL,
    quilómetro      INTEGER NOT NULL CHECK (quilómetro >= 0),
    tipo            TEXT NOT NULL,
    FOREIGN KEY (EdiçãoID, dorsal, número)
        REFERENCES Participação(EdiçãoID, dorsal, número)
);

CREATE TABLE Bonificação (
    BonificaçãoID       INTEGER PRIMARY KEY,
    EdiçãoID            INTEGER NOT NULL,
    dorsal              INTEGER NOT NULL,
    número              INTEGER NOT NULL,
    PontoIntermédioID   INTEGER,
    tempoDescontado     TEXT NOT NULL,
    FOREIGN KEY (EdiçãoID, dorsal, número)
        REFERENCES Participação(EdiçãoID, dorsal, número),
    FOREIGN KEY (PontoIntermédioID, EdiçãoID, número)
        REFERENCES PontoIntermédio(PontoIntermédioID, EdiçãoID, número)
);