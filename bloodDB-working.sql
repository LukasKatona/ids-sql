-- Pro vztahy generalizace a specializace jsme se rozhodli vytvorit tabulku Osoba, ktera bude obsahovat vsechny spolecne atributy pro tabulky Darce a Zamestnanec.
-- Tabulka Darce bude obsahovat atributy typ_krve a datum_posledniho_odberu, ktere jsou specificke pro darce. Jeho primarni klic bude cizi klic na tabulku Osoba.
-- Tabulka Zamestnanec bude obsahovat atributy pozice a zarizeni, ktere jsou specificke pro zamestnance. Jeho primarni klic bude cizi klic na tabulku Osoba.
-- Toto reseni jsme zvolili pro vysoky pocet spolecnych atributu a protoze Darce muze byt zaroven zamestnancem a naopak.

DROP TABLE Osoba CASCADE CONSTRAINTS;
DROP TABLE Darce CASCADE CONSTRAINTS;
DROP TABLE Zamestnanec CASCADE CONSTRAINTS;
DROP TABLE Adresa CASCADE CONSTRAINTS;
DROP TABLE Zarizeni CASCADE CONSTRAINTS;
DROP TABLE Odber CASCADE CONSTRAINTS;
DROP TABLE Polozka_objednavky CASCADE CONSTRAINTS;
DROP TABLE Objednavka CASCADE CONSTRAINTS;
DROP TABLE Odber_Zamestnanec CASCADE CONSTRAINTS;

DROP SEQUENCE osoba_seq;
DROP SEQUENCE adresa_seq;
DROP SEQUENCE zarizeni_seq;
DROP SEQUENCE odber_seq;
DROP SEQUENCE polozka_seq;
DROP SEQUENCE objednavka_seq;
DROP SEQUENCE odber_zamestnanec_seq;

CREATE TABLE Osoba(
    id_osoba INTEGER PRIMARY KEY,
    rodne_cislo CHAR(11) UNIQUE NOT NULL,
    jmeno VARCHAR(50) NOT NULL,
    prijmeni VARCHAR(50) NOT NULL,
    datum_narozeni DATE NOT NULL,
    telefonni_cislo CHAR(9) NOT NULL,
    email VARCHAR(100),
    fk_id_adresa INTEGER NOT NULL
);

CREATE TABLE Darce(
    id_darce_fk_osoba INTEGER PRIMARY KEY,
    typ_krve VARCHAR(3) NOT NULL,
    datum_posledniho_odberu DATE
);

CREATE TABLE Zamestnanec(
    id_zamestnanec_fk_osoba INTEGER PRIMARY KEY,
    pozice VARCHAR(50),
    fk_id_zarizeni INTEGER NOT NULL
);

CREATE TABLE Adresa(
    id_adresa INTEGER PRIMARY KEY,
    ulice VARCHAR(50) NOT NULL,
    cislo_popisne INTEGER NOT NULL,
    mesto VARCHAR(50) NOT NULL,
    psc CHAR(5) NOT NULL
);

CREATE TABLE Zarizeni(
    id_zarizeni INTEGER PRIMARY KEY,
    nazev VARCHAR(100) NOT NULL,
    fk_id_adresa INTEGER NOT NULL
);

CREATE TABLE Odber(
    id_odber INTEGER PRIMARY KEY,
    datum DATE NOT NULL,
    fk_id_darce INTEGER NOT NULL,
    fk_id_zarizeni INTEGER NOT NULL,
    fk_id_objednavka INTEGER,

    -- Mnozstvi_krve
    typ_krve VARCHAR(3) NOT NULL,
    mnozstvi INTEGER NOT NULL
);

CREATE TABLE Polozka_objednavky(
    id_polozka INTEGER PRIMARY KEY,
    priorita INTEGER NOT NULL,
    fk_id_objednavka INTEGER NOT NULL,

    -- Mnozstvi_krve
    typ_krve VARCHAR(3) NOT NULL,
    mnozstvi INTEGER NOT NULL
);

CREATE TABLE Objednavka(
    id_objednavka INTEGER PRIMARY KEY,
    datum_vytvoreni DATE NOT NULL,
    stav VARCHAR(20) NOT NULL,
    fk_id_zarizeni_objednavatel INTEGER NOT NULL,
    fk_id_zarizeni_dodavatel INTEGER
);

-- vytvoreni spojivacich tabulek
CREATE TABLE Odber_Zamestnanec(
    id_odber_zamestnanec INTEGER PRIMARY KEY,
    fk_id_odber INTEGER NOT NULL,
    fk_id_zamestnanec INTEGER NOT NULL
);

-- Vytvoreni cizich klicu
ALTER TABLE Odber ADD CONSTRAINT FK_odber_darce FOREIGN KEY (fk_id_darce) REFERENCES Darce;
ALTER TABLE Odber ADD CONSTRAINT FK_odber_zarizeni FOREIGN KEY (fk_id_zarizeni) REFERENCES Zarizeni;
ALTER TABLE Odber ADD CONSTRAINT FK_odber_objednavka FOREIGN KEY (fk_id_objednavka) REFERENCES Objednavka ON DELETE SET NULL;
ALTER TABLE Osoba ADD CONSTRAINT FK_osoba_adresa FOREIGN KEY (fk_id_adresa) REFERENCES Adresa;
ALTER TABLE Darce ADD CONSTRAINT FK_darce_osoba FOREIGN KEY (id_darce_fk_osoba) REFERENCES Osoba ON DELETE CASCADE;
ALTER TABLE Zamestnanec ADD CONSTRAINT FK_zamestnanec_osoba FOREIGN KEY (id_zamestnanec_fk_osoba) REFERENCES Osoba ON DELETE CASCADE;
ALTER TABLE Zamestnanec ADD CONSTRAINT FK_zamestnanec_zarizeni FOREIGN KEY (fk_id_zarizeni) REFERENCES Zarizeni;
ALTER TABLE Zarizeni ADD CONSTRAINT FK_zarizeni_adresa FOREIGN KEY (fk_id_adresa) REFERENCES Adresa;
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_zarizeni_objednavatel FOREIGN KEY (fk_id_zarizeni_objednavatel) REFERENCES Zarizeni ON DELETE CASCADE;
ALTER TABLE Objednavka ADD CONSTRAINT FK_objednavka_zarizeni_dodavatel FOREIGN KEY (fk_id_zarizeni_dodavatel) REFERENCES Zarizeni ON DELETE SET NULL;
ALTER TABLE Polozka_objednavky ADD CONSTRAINT FK_polozka_objednavka FOREIGN KEY (fk_id_objednavka) REFERENCES Objednavka ON DELETE CASCADE;
ALTER TABLE Odber_Zamestnanec ADD CONSTRAINT FK_odber_zamestnanec FOREIGN KEY (fk_id_odber) REFERENCES Odber ON DELETE CASCADE;
ALTER TABLE Odber_Zamestnanec ADD CONSTRAINT FK_zamestnanec_odber FOREIGN KEY (fk_id_zamestnanec) REFERENCES Zamestnanec ON DELETE CASCADE;

-- Omezeni rodneho cisla
ALTER TABLE Osoba ADD CONSTRAINT CK_osoba_rodne_cislo CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$'));

-- Omezeni typu krve
ALTER TABLE Darce ADD CONSTRAINT CK_darce_typ_krve CHECK (REGEXP_LIKE(typ_krve, '^(A|B|0|AB)[+|-]$'));
ALTER TABLE Odber ADD CONSTRAINT CK_odber_typ_krve CHECK (REGEXP_LIKE(typ_krve, '^(A|B|0|AB)[+|-]$'));
ALTER TABLE Polozka_objednavky ADD CONSTRAINT CK_polozka_typ_krve CHECK (REGEXP_LIKE(typ_krve, '^(A|B|0|AB)[+|-]$'));


-- Automaticka inkrementace postupnich primarnich klicu
CREATE SEQUENCE osoba_seq;
CREATE SEQUENCE adresa_seq;
CREATE SEQUENCE zarizeni_seq;
CREATE SEQUENCE odber_seq;
CREATE SEQUENCE polozka_seq;
CREATE SEQUENCE objednavka_seq;
CREATE SEQUENCE odber_zamestnanec_seq;

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

-- OSOBA
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0671','Jan','Novak',TO_DATE('26.07.1999', 'dd.mm.yyyy'),'123456789','jan.novak@gmail.com', 3);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0672','Petr','Vesely',TO_DATE('26.07.1999', 'dd.mm.yyyy'),'123456789','veselko@gmail.com', 2);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0673','Peter','Novotny',TO_DATE('26.07.1978', 'dd.mm.yyyy'),'123456789','novota@gmail.com', 3);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0674','Jan','Slovak',TO_DATE('26.07.1944', 'dd.mm.yyyy'),'123456789','slovensko123@gmail.com', 1);

-- DARCE
INSERT INTO Darce
VALUES(1,'A+',TO_DATE('10.10.2023', 'dd.mm.yyyy'));
INSERT INTO Darce
VALUES(2,'AB-',TO_DATE('12.10.2023', 'dd.mm.yyyy'));

-- ZAMESTNANEC
INSERT INTO Zamestnanec
VALUES(3,'Lekar',1);
INSERT INTO Zamestnanec
VALUES(4,'Lekar',2);
INSERT INTO Zamestnanec
VALUES(1,'Sestricka',2);

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
VALUES(odber_zamestnanec_seq.NEXTVAL, 1,1);
INSERT INTO Odber_Zamestnanec
VALUES(odber_zamestnanec_seq.NEXTVAL, 1,3);
INSERT INTO Odber_Zamestnanec
VALUES(odber_zamestnanec_seq.NEXTVAL, 2,3);

-- Vypis vsech tabulek
SELECT * FROM Osoba;
SELECT * FROM Darce;
SELECT * FROM Zamestnanec;
SELECT * FROM Adresa;
SELECT * FROM Zarizeni;
SELECT * FROM Odber;
SELECT * FROM Polozka_objednavky;
SELECT * FROM Objednavka;
SELECT * FROM Odber_Zamestnanec;

COMMIT;