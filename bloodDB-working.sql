-- Pro vztahy generalizace a specializace jsme se rozhodli spolecne atributy
-- ukladat do specificky tabulek a ne do generalizovane tabulky.

DROP TABLE Darce CASCADE CONSTRAINTS;
DROP TABLE Zamestnanec CASCADE CONSTRAINTS;
DROP TABLE Adresa CASCADE CONSTRAINTS;
DROP TABLE Zarizeni CASCADE CONSTRAINTS;
DROP TABLE Odber CASCADE CONSTRAINTS;
DROP TABLE Polozka_objednavky CASCADE CONSTRAINTS;
DROP TABLE Objednavka CASCADE CONSTRAINTS;
DROP TABLE Odber_Zamestnanec CASCADE CONSTRAINTS;

DROP SEQUENCE darce_seq;
DROP SEQUENCE zamestnanec_seq;
DROP SEQUENCE adresa_seq;
DROP SEQUENCE zarizeni_seq;
DROP SEQUENCE odber_seq;
DROP SEQUENCE polozka_seq;
DROP SEQUENCE objednavka_seq;



CREATE TABLE Darce(
    id_darce INTEGER,
    typ_krve VARCHAR(3),
    datum_posledniho_odberu DATE,

    -- Osoba
    rodne_cislo CHAR(11),
    jmeno VARCHAR(50),
    prijmeni VARCHAR(50),
    datum_narozeni DATE,
    telefonni_cislo CHAR(9),
    email VARCHAR(100),
    fk_id_adresa INTEGER
);

CREATE TABLE Zamestnanec(
    id_zamestnanec INTEGER,
    pozice VARCHAR(50),
    fk_id_zarizeni INTEGER,

    -- Osoba
    rodne_cislo CHAR(11),
    jmeno VARCHAR(50),
    prijmeni VARCHAR(50),
    datum_narozeni DATE,
    telefonni_cislo CHAR(9),
    email VARCHAR(100),
    fk_id_adresa INTEGER
);

CREATE TABLE Adresa(
    id_adresa INTEGER,
    ulice VARCHAR(50),
    cislo_popisne INTEGER,
    mesto VARCHAR(50),
    psc CHAR(5)
);

CREATE TABLE Zarizeni(
    id_zarizeni INTEGER,
    nazev VARCHAR(100),
    fk_id_adresa INTEGER
);

CREATE TABLE Odber(
    id_odber INTEGER,
    datum DATE,
    fk_id_darce INTEGER,
    fk_id_zarizeni INTEGER,
    fk_id_objednavka INTEGER,

    -- Mnozstvi_krve
    typ_krve VARCHAR(3),
    mnozstvi INTEGER
);

CREATE TABLE Polozka_objednavky(
    id_polozka INTEGER,
    priorita INTEGER,
    fk_id_objednavka INTEGER,

    -- Mnozstvi_krve
    typ_krve VARCHAR(3),
    mnozstvi INTEGER
);

CREATE TABLE Objednavka(
    id_objednavka INTEGER,
    datum_vytvoreni DATE,
    stav VARCHAR(20),
    fk_id_zarizeni_objednavatel INTEGER,
    fk_id_zarizeni_dodavatel INTEGER
);

-- vytvoreni spojivacich tabulek
CREATE TABLE Odber_Zamestnanec(
    fk_id_odber INTEGER,
    fk_id_zamestnanec INTEGER
);

-- Vytvoreni primarnich klicu
ALTER TABLE Darce ADD CONSTRAINT PK_darce PRIMARY KEY (id_darce);
ALTER TABLE Zamestnanec ADD CONSTRAINT PK_zamestnanec PRIMARY KEY (id_zamestnanec);
ALTER TABLE Adresa ADD CONSTRAINT PK_adresa PRIMARY KEY (id_adresa);
ALTER TABLE Zarizeni ADD CONSTRAINT PK_zarizeni PRIMARY KEY (id_zarizeni);
ALTER TABLE Odber ADD CONSTRAINT PK_odber PRIMARY KEY (id_odber);
ALTER TABLE Polozka_objednavky ADD CONSTRAINT PK_polozka PRIMARY KEY (id_polozka);
ALTER TABLE Objednavka ADD CONSTRAINT PK_objednavka PRIMARY KEY (id_objednavka);

-- Vytvoreni cizich klicu
ALTER TABLE Odber ADD CONSTRAINT FK_odber_darce FOREIGN KEY (fk_id_darce) REFERENCES Darce ON DELETE CASCADE;
ALTER TABLE Darce ADD CONSTRAINT FK_darce_adresa FOREIGN KEY (fk_id_adresa) REFERENCES Adresa ON DELETE CASCADE;
ALTER TABLE Zamestnanec ADD CONSTRAINT FK_zamestnanec_zarizeni FOREIGN KEY (fk_id_zarizeni) REFERENCES Zarizeni ON DELETE CASCADE;
ALTER TABLE Zarizeni ADD CONSTRAINT FK_zarizeni_adresa FOREIGN KEY (fk_id_adresa) REFERENCES Adresa ON DELETE CASCADE;
ALTER TABLE Odber ADD CONSTRAINT FK_odber_zarizeni FOREIGN KEY (fk_id_zarizeni) REFERENCES Zarizeni ON DELETE CASCADE;
ALTER TABLE Odber ADD CONSTRAINT FK_odber_objednavka FOREIGN KEY (fk_id_objednavka) REFERENCES Objednavka ON DELETE CASCADE;
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_zarizeni_objednavatel FOREIGN KEY (fk_id_zarizeni_objednavatel) REFERENCES Zarizeni ON DELETE CASCADE;
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_zarizeni_dodavatel FOREIGN KEY (fk_id_zarizeni_dodavatel) REFERENCES Zarizeni ON DELETE CASCADE;
ALTER TABLE Polozka_objednavky ADD CONSTRAINT FK_polozka_objednavka FOREIGN KEY (fk_id_objednavka) REFERENCES Objednavka ON DELETE CASCADE;
ALTER TABLE Odber_Zamestnanec ADD CONSTRAINT FK_odber_zamestnanec FOREIGN KEY (fk_id_odber) REFERENCES Odber ON DELETE CASCADE;
ALTER TABLE Odber_Zamestnanec ADD CONSTRAINT FK_zamestnanec_odber FOREIGN KEY (fk_id_zamestnanec) REFERENCES Zamestnanec ON DELETE CASCADE;

-- Omezeni rodneho cisla
-- iba numericke znaky
ALTER TABLE Darce ADD CONSTRAINT CK_darce_rodne_cislo CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$'));
ALTER TABLE Zamestnanec ADD CONSTRAINT CK_zamestnanec_rodne_cislo CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$'));

-- omezeni typu krve
ALTER TABLE Darce ADD CONSTRAINT CK_darce_typ_krve CHECK (REGEXP_LIKE(typ_krve, '^(A|B|0|AB)[+|-]$'));
ALTER TABLE Odber ADD CONSTRAINT CK_odber_typ_krve CHECK (REGEXP_LIKE(typ_krve, '^(A|B|0|AB)[+|-]$'));
ALTER TABLE Polozka_objednavky ADD CONSTRAINT CK_polozka_typ_krve CHECK (REGEXP_LIKE(typ_krve, '^(A|B|0|AB)[+|-]$'));


-- Automaticka inkrementace postupnich primarnich klicu
CREATE SEQUENCE darce_seq;
CREATE SEQUENCE zamestnanec_seq;
CREATE SEQUENCE adresa_seq;
CREATE SEQUENCE zarizeni_seq;
CREATE SEQUENCE odber_seq;
CREATE SEQUENCE polozka_seq;
CREATE SEQUENCE objednavka_seq;

-- Vlozeni dat
-- ADRESA
INSERT INTO Adresa
VALUES(adresa_seq.NEXTVAL,'Komenskeho', 5, 'Brno', '60200');
INSERT INTO Adresa
VALUES(adresa_seq.NEXTVAL,'Cejl', 8, 'Brno', '60200');
INSERT INTO Adresa
VALUES(adresa_seq.NEXTVAL,'Dusikova', 5, 'Brno', '63800');

-- ZARIZENI
INSERT INTO Zarizeni
VALUES(zarizeni_seq.NEXTVAL,'Fakultni nemocnice Brno',1);
INSERT INTO Zarizeni
VALUES(zarizeni_seq.NEXTVAL,'Statni nemocnice Brno',2);

-- DARCE
INSERT INTO Darce
VALUES(darce_seq.NEXTVAL,'A+',TO_DATE('10.10.2023', 'dd.mm.yyyy'),'440726/0671','Jan','Novak',TO_DATE('26.07.1999', 'dd.mm.yyyy'),'123456789','jan.novak@gmail.com', 3);
INSERT INTO Darce
VALUES(darce_seq.NEXTVAL,'AB-',TO_DATE('12.10.2023', 'dd.mm.yyyy'),'440726/0672','Petr','Vesely',TO_DATE('26.07.1999', 'dd.mm.yyyy'),'123456789','veselko@gmail.com', 2);

-- ZAMESTNANEC
INSERT INTO Zamestnanec
VALUES(zamestnanec_seq.NEXTVAL,'Lekar',1,'440726/0672','Peter','Novotny',TO_DATE('26.07.1978', 'dd.mm.yyyy'),'123456789','novota@gmail.com', 3);
INSERT INTO Zamestnanec
VALUES(zamestnanec_seq.NEXTVAL,'Lekar',2,'440726/0673','Jan','Slovak',TO_DATE('26.07.1944', 'dd.mm.yyyy'),'123456789','slovensko123@gmail.com', 1);

-- OBJEDNAVKA
INSERT INTO Objednavka
VALUES(objednavka_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),'vytvorena',1,2);

-- POLOZKA_OBJEDNAVKA
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,1,'A+',500);

-- ODBER
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),1,1,1,'A+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('12.10.2023', 'dd.mm.yyyy'),2,1,NULL,'AB-', 1000);

-- ODBER_ZAMESTNANEC
INSERT INTO Odber_Zamestnanec
VALUES(1,1);
INSERT INTO Odber_Zamestnanec
VALUES(1,2);
INSERT INTO Odber_Zamestnanec
VALUES(2,2);


COMMIT;