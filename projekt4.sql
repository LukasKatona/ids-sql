-- Pro vztahy generalizace a specializace jsme se rozhodli vytvorit tabulku Osoba, ktera bude obsahovat vsechny spolecne atributy pro tabulky Darce a Zamestnanec.
-- Tabulka Darce bude obsahovat atributy typ_krve a datum_posledniho_odberu, ktere jsou specificke pro darce. Jeho primarni klic bude cizi klic na tabulku Osoba.
-- Tabulka Zamestnanec bude obsahovat atributy pozice a zarizeni, ktere jsou specificke pro zamestnance. Jeho primarni klic bude cizi klic na tabulku Osoba.
-- Toto reseni jsme zvolili pro vysoky pocet spolecnych atributu a protoze Darce muze byt zaroven zamestnancem a naopak.

-- Pro entitni mnozinu Mnozstvi_krve jsme se rozhodli jeji atributy zahrnout primo do tabulek Odber a Polozka_objednavky.
-- Toto reseni jsme zvolili pro nizky pocet spolecnych atributu a zachovani prehlednosti.

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

-- Vytvoreni triggru

-- trigger na nastaveni stavu objednavky a data pri vytvoreni nove objednavky
CREATE OR REPLACE TRIGGER Objednavka_vytvorena_trigger
BEFORE INSERT ON Objednavka
FOR EACH ROW
BEGIN
    IF :NEW.fk_id_zarizeni_objednavatel = :NEW.fk_id_zarizeni_dodavatel THEN
        RAISE_APPLICATION_ERROR(-20001, 'Zarizeni objednavatel a dodavatel nesmi byt stejne');
    END IF;

    :NEW.stav := 'vytvorena';
    :NEW.datum_vytvoreni := SYSDATE;
END;
/

-- trigger na kontrolu typu krve pri vytvoreni noveho odberu
CREATE OR REPLACE TRIGGER Odber_typ_krve_trigger
BEFORE INSERT ON Odber
FOR EACH ROW
DECLARE
    typ Darce.typ_krve%TYPE;
BEGIN
    SELECT typ_krve INTO typ
    FROM Darce
    WHERE id_darce_fk_osoba = :NEW.fk_id_darce;

    IF :NEW.typ_krve != typ THEN
        RAISE_APPLICATION_ERROR(-20001, 'Typ krve neodpovida typu krve darce');
    END IF;
END;
/

-- Vytvoreni procedur

-- procedura pro Dokonceni objednavky
-- nastavi stav objednavky na dokoncena
-- presune vsechny Odbery do ciloveho zarizeni a nastavi mu objednavku na null
CREATE OR REPLACE PROCEDURE Dokonceni_objednavky(
    id_objednavka IN Objednavka.id_objednavka%TYPE
) AS BEGIN
    UPDATE Objednavka
    SET stav = 'dokoncena'
    WHERE id_objednavka = Dokonceni_objednavky.id_objednavka;

    UPDATE Odber
    SET fk_id_zarizeni = (
            SELECT fk_id_zarizeni_objednavatel
            FROM Objednavka
            WHERE id_objednavka = Dokonceni_objednavky.id_objednavka
        ),
        fk_id_objednavka = NULL
    WHERE fk_id_objednavka = Dokonceni_objednavky.id_objednavka;
END;
/

-- procedura pro pridani odberu do objednavky (S KURZOREM)
-- prida odbery nachazejici se v zarizeni dodavatele objednavky, dokud neni dosazene mnozstvi krve polozky objednavky
CREATE OR REPLACE PROCEDURE Pridani_odberu_do_objednavky(
    id_polozka IN Polozka_objednavky.id_polozka%TYPE
) AS
    id_objednavka Polozka_objednavky.fk_id_objednavka%TYPE;
    mnozstvi_krve_polozka INTEGER;
    id_odber_cursor Odber.id_odber%TYPE;
    mnozstvi_krve_odber INTEGER;
    mnozstvi_krve_odbery_celkem INTEGER;
    -- cursor pro vyber odberu, ktere se maji pridat do objednavky
    -- vybere odbery, ktere jeste nesjsou v zadne objednavce a jsou v zarizeni dodavatele a maji stejny typ krve jako polozka objednavky
    CURSOR odbery_cursor IS
        SELECT id_odber, mnozstvi FROM Odber
        WHERE fk_id_objednavka IS NULL AND
        fk_id_zarizeni = (
            SELECT fk_id_zarizeni_dodavatel
            FROM Objednavka
            WHERE id_objednavka = (
                SELECT fk_id_objednavka
                FROM Polozka_objednavky
                WHERE id_polozka = Pridani_odberu_do_objednavky.id_polozka
            )
        ) AND
        typ_krve = (
            SELECT typ_krve
            FROM Polozka_objednavky
            WHERE id_polozka = Pridani_odberu_do_objednavky.id_polozka
        );
BEGIN
    SELECT fk_id_objednavka INTO id_objednavka
        FROM Polozka_objednavky
        WHERE id_polozka = Pridani_odberu_do_objednavky.id_polozka;

    SELECT mnozstvi INTO mnozstvi_krve_polozka
        FROM Polozka_objednavky
        WHERE id_polozka = Pridani_odberu_do_objednavky.id_polozka;
        
    mnozstvi_krve_odbery_celkem := 0;
    OPEN odbery_cursor;
    LOOP
        -- ukonci pokud je kurzor prazdny nebo pokud je celkove mnozstvi krve odberu vetsi nez mnozstvi krve polozky objednavky
        EXIT WHEN odbery_cursor%NOTFOUND OR mnozstvi_krve_odbery_celkem >= mnozstvi_krve_polozka;
        FETCH odbery_cursor INTO id_odber_cursor, mnozstvi_krve_odber;
        UPDATE Odber SET fk_id_objednavka = id_objednavka
        WHERE id_odber_cursor = id_odber;
        mnozstvi_krve_odbery_celkem := mnozstvi_krve_odbery_celkem + mnozstvi_krve_odber;
    END LOOP;
    CLOSE odbery_cursor;
END;
/

-- procedura pro pridani odberu do objednavky (BEZ KURZORU)
-- prida odbery nachazejici se v zarizeni dodavatele objednavky, dokud neni dosazene mnozstvi krve polozky objednavky
CREATE OR REPLACE PROCEDURE Pridani_odberu_do_objednavky_bez_kurzoru(
    id_polozka IN Polozka_objednavky.id_polozka%TYPE
) AS
    id_objednavka_polozky Polozka_objednavky.fk_id_objednavka%TYPE;
    mnozstvi_krve_polozka INTEGER;
    id_odber_cursor Odber.id_odber%TYPE;
    mnozstvi_krve_odber INTEGER;
    mnozstvi_krve_odbery_celkem INTEGER;
BEGIN
    SELECT fk_id_objednavka INTO id_objednavka_polozky
        FROM Polozka_objednavky
        WHERE id_polozka = Pridani_odberu_do_objednavky_bez_kurzoru.id_polozka;

    SELECT mnozstvi INTO mnozstvi_krve_polozka
        FROM Polozka_objednavky
        WHERE id_polozka = Pridani_odberu_do_objednavky_bez_kurzoru.id_polozka;
        
    mnozstvi_krve_odbery_celkem := 0;
    LOOP
        id_odber_cursor := NULL;
        SELECT id_odber INTO id_odber_cursor
            FROM Odber
            WHERE fk_id_objednavka IS NULL AND
            fk_id_zarizeni = (
                SELECT fk_id_zarizeni_dodavatel
                FROM Objednavka
                WHERE id_objednavka = id_objednavka_polozky
            ) AND
            typ_krve = (
                SELECT typ_krve
                FROM Polozka_objednavky
                WHERE id_polozka = Pridani_odberu_do_objednavky_bez_kurzoru.id_polozka
            )
            AND ROWNUM = 1;

        EXIT WHEN id_odber_cursor IS NULL;

        SELECT mnozstvi INTO mnozstvi_krve_odber
            FROM Odber
            WHERE id_odber = id_odber_cursor;
        
        UPDATE Odber SET fk_id_objednavka = id_objednavka_polozky
        WHERE id_odber = id_odber_cursor;

        mnozstvi_krve_odbery_celkem := mnozstvi_krve_odbery_celkem + mnozstvi_krve_odber;
        EXIT WHEN mnozstvi_krve_odbery_celkem >= mnozstvi_krve_polozka;
    END LOOP;
END;
/

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
INSERT INTO Zarizeni
VALUES(zarizeni_seq.NEXTVAL,'Krajska nemocnice Brno',3);

-- OSOBA
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0671','Jan','Novak',TO_DATE('26.07.1999', 'dd.mm.yyyy'),'123456789','jan.novak@gmail.com', 3);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0672','Petr','Vesely',TO_DATE('26.07.1999', 'dd.mm.yyyy'),'123456789','veselko@gmail.com', 2);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0673','Peter','Novotny',TO_DATE('26.07.1978', 'dd.mm.yyyy'),'123456789','novota@gmail.com', 3);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0674','Jan','Slovak',TO_DATE('26.07.1944', 'dd.mm.yyyy'),'123456789','slovensko123@gmail.com', 1);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0675','Petr','Cech',TO_DATE('26.07.1999', 'dd.mm.yyyy'),'123456789','cz123@gmail.com', 2);
INSERT INTO Osoba
VALUES(osoba_seq.NEXTVAL,'440726/0676','Peter','Slovak',TO_DATE('26.07.1978', 'dd.mm.yyyy'),'123456789','pptr@gmail.com', 3);

-- DARCE
INSERT INTO Darce
VALUES(1,'A+',TO_DATE('10.10.2023', 'dd.mm.yyyy'));
INSERT INTO Darce
VALUES(2,'AB-',TO_DATE('12.10.2023', 'dd.mm.yyyy'));
INSERT INTO Darce
VALUES(3,'B+',TO_DATE('21.10.2023', 'dd.mm.yyyy'));
INSERT INTO Darce
VALUES(4,'A-',TO_DATE('10.10.2023', 'dd.mm.yyyy'));
INSERT INTO Darce
VALUES(5,'AB+',TO_DATE('12.10.2023', 'dd.mm.yyyy'));
INSERT INTO Darce
VALUES(6,'B-',TO_DATE('21.10.2023', 'dd.mm.yyyy'));


-- ZAMESTNANEC
INSERT INTO Zamestnanec
VALUES(3,'Lekar',1);
INSERT INTO Zamestnanec
VALUES(4,'Lekar',2);
INSERT INTO Zamestnanec
VALUES(1,'Sestricka',2);

-- OBJEDNAVKA
INSERT INTO Objednavka (id_objednavka, fk_id_zarizeni_objednavatel, fk_id_zarizeni_dodavatel)
VALUES(objednavka_seq.NEXTVAL, 2, 1);
INSERT INTO Objednavka (id_objednavka, fk_id_zarizeni_objednavatel, fk_id_zarizeni_dodavatel)
VALUES(objednavka_seq.NEXTVAL, 1, 2);

-- ODBER
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),1,1,NULL,'A+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('12.10.2023', 'dd.mm.yyyy'),2,2,NULL,'AB-', 1000);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.4.2023', 'dd.mm.yyyy'),1,1,NULL,'A+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('21.10.2023', 'dd.mm.yyyy'),3,1,NULL,'B+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),4,2,NULL,'A-', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('12.10.2023', 'dd.mm.yyyy'),2,2,NULL,'AB-', 1000);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.4.2023', 'dd.mm.yyyy'),4,2,NULL,'A-', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('21.10.2023', 'dd.mm.yyyy'),3,2,NULL,'B+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),1,2,NULL,'A+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('12.10.2023', 'dd.mm.yyyy'),2,2,NULL,'AB-', 1000);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.4.2023', 'dd.mm.yyyy'),1,2,NULL,'A+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('21.10.2023', 'dd.mm.yyyy'),3,2,NULL,'B+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),4,2,NULL,'A-', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('12.10.2023', 'dd.mm.yyyy'),4,2,NULL,'A-', 1000);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.4.2023', 'dd.mm.yyyy'),5,2,NULL,'AB+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('21.10.2023', 'dd.mm.yyyy'),3,2,NULL,'B+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),1,2,NULL,'A+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('12.10.2023', 'dd.mm.yyyy'),5,2,NULL,'AB+', 1000);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.4.2023', 'dd.mm.yyyy'),1,2,NULL,'A+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('21.10.2023', 'dd.mm.yyyy'),3,2,NULL,'B+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),6,2,NULL,'B-', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('12.10.2023', 'dd.mm.yyyy'),6,2,NULL,'B-', 1000);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.4.2023', 'dd.mm.yyyy'),6,2,NULL,'B-', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('21.10.2023', 'dd.mm.yyyy'),3,2,NULL,'B+', 500);
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),4,2,NULL,'A-', 500);

-- POLOZKA_OBJEDNAVKA
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,1,'A+',1000);
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,2,'AB-',500);
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,1,'A+',500);
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,1,'B+',900);
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,2,'A+',600);
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,2,'AB+',500);
INSERT INTO Polozka_objednavky
VALUES(polozka_seq.NEXTVAL,1,2,'B-',400);

-- ODBER_ZAMESTNANEC
INSERT INTO Odber_Zamestnanec
VALUES(odber_zamestnanec_seq.NEXTVAL, 1,1);
INSERT INTO Odber_Zamestnanec
VALUES(odber_zamestnanec_seq.NEXTVAL, 1,3);
INSERT INTO Odber_Zamestnanec
VALUES(odber_zamestnanec_seq.NEXTVAL, 2,3);

COMMIT;

-- Prideleni prav druhemu clenovi tymu
GRANT ALL ON Osoba TO XKEJDO00;
GRANT ALL ON Darce TO XKEJDO00;
GRANT ALL ON Zamestnanec TO XKEJDO00;
GRANT ALL ON Adresa TO XKEJDO00;
GRANT ALL ON Zarizeni TO XKEJDO00;
GRANT ALL ON Odber TO XKEJDO00;
GRANT ALL ON Polozka_objednavky TO XKEJDO00;
GRANT ALL ON Objednavka TO XKEJDO00;
GRANT ALL ON Odber_Zamestnanec TO XKEJDO00;
-- REVOKE ALL ON Osoba FROM XKEJDO00;
-- REVOKE ALL ON Darce FROM XKEJDO00;
-- REVOKE ALL ON Zamestnanec FROM XKEJDO00;
-- REVOKE ALL ON Adresa FROM XKEJDO00;
-- REVOKE ALL ON Zarizeni FROM XKEJDO00;
-- REVOKE ALL ON Odber FROM XKEJDO00;
-- REVOKE ALL ON Polozka_objednavky FROM XKEJDO00;
-- REVOKE ALL ON Objednavka FROM XKEJDO00;
-- REVOKE ALL ON Odber_Zamestnanec FROM XKEJDO00;

-- Vsechny zarizeni spolu s mnozstvim objednane krve a statusu jestli objednali nejvice krve, mene, nebo zadnou
WITH MnozstviObjednaneKrve AS (
    SELECT o.fk_id_zarizeni_objednavatel, SUM(p.mnozstvi) AS mozstvi_objednane_krve
    FROM Objednavka o
    JOIN Polozka_objednavky p ON o.id_objednavka = p.fk_id_objednavka
    GROUP BY o.fk_id_zarizeni_objednavatel
)
SELECT 
    z.id_zarizeni, 
    z.nazev, 
    t.mozstvi_objednane_krve,
    CASE 
        WHEN t.mozstvi_objednane_krve = (
            SELECT MAX(mozstvi_objednane_krve) AS max_objednane_mnozstvi_krve
            FROM MnozstviObjednaneKrve
        ) THEN 'MAX'
        WHEN t.mozstvi_objednane_krve IS NULL THEN 'NONE'
        ELSE 'LESS'
    END AS max_status
FROM MnozstviObjednaneKrve t
RIGHT JOIN Zarizeni z ON t.fk_id_zarizeni_objednavatel = z.id_zarizeni;

-- Predvedeni triggeru
-- Vytvoreni nove objednavky
INSERT INTO Objednavka (id_objednavka, fk_id_zarizeni_objednavatel, fk_id_zarizeni_dodavatel)
VALUES(objednavka_seq.NEXTVAL, 1, 2);
SELECT * FROM Objednavka WHERE id_objednavka = 3;
-- Vytvoreni spatne objednavky - zarizeni objednavatel a dodavatel je stejne
INSERT INTO Objednavka (id_objednavka, fk_id_zarizeni_objednavatel, fk_id_zarizeni_dodavatel)
VALUES(objednavka_seq.NEXTVAL, 1, 1);
-- Vytvoreni spatneho odberu - typ krve neodpovida typu krve darce
INSERT INTO Odber
VALUES(odber_seq.NEXTVAL,TO_DATE('10.10.2023', 'dd.mm.yyyy'),1,1,NULL,'B+', 500);

-- Predvedeni procedur
-- Pridani odberu do objednavky s kurzorem
EXEC Pridani_odberu_do_objednavky(1);
SELECT * FROM Odber WHERE fk_id_objednavka = 1;
EXEC Pridani_odberu_do_objednavky(2);
SELECT * FROM Odber WHERE fk_id_objednavka = 2;
-- Dokoceni objednavky
EXEC Dokonceni_objednavky(1);
SELECT * FROM Objednavka WHERE id_objednavka = 1;
SELECT * FROM Odber WHERE id_odber = 1 OR id_odber = 3;

-- VIEW Seznam všech dárců a počet jejich darování, tato cast scriptu by se mela spustit druhym clenem tymu
DROP MATERIALIZED VIEW Darci_a_pocet_odberu;
CREATE MATERIALIZED VIEW Darci_a_pocet_odberu
REFRESH ON DEMAND AS
    SELECT b.jmeno, b.prijmeni, COUNT(o.id_odber) AS odberu_celkem
    FROM XKATON00.Darce d
    LEFT JOIN XKATON00.Odber o ON d.id_darce_fk_osoba = o.fk_id_darce
    JOIN XKATON00.Osoba b ON d.id_darce_fk_osoba = b.id_osoba
    GROUP BY b.jmeno, b.prijmeni ORDER BY COUNT(o.id_odber) DESC;
COMMIT;
SELECT * FROM Darci_a_pocet_odberu;

-- EXPLAIN PLAN pro puvodni dotaz a dotaz s indexem
explain plan for
SELECT b.jmeno, b.prijmeni, COUNT(o.id_odber) AS odberu_celkem
FROM Odber o
JOIN Osoba b ON o.fk_id_darce = b.id_osoba
GROUP BY b.jmeno, b.prijmeni ORDER BY COUNT(o.id_odber) DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Index na fk_id_darce, ktery se pouziva v dotazu pro zjisteni poctu odberu jednotlivych darcu
-- diki indexu se snizi cas vyhledavani a zpracovani dotazu na tabulku Odber
CREATE INDEX idx_fk_id_darce ON Odber(fk_id_darce);
COMMIT;
explain plan for
SELECT b.jmeno, b.prijmeni, COUNT(o.id_odber) AS odberu_celkem
FROM Odber o
JOIN Osoba b ON o.fk_id_darce = b.id_osoba
GROUP BY b.jmeno, b.prijmeni ORDER BY COUNT(o.id_odber) DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
DROP INDEX idx_fk_id_darce;
COMMIT;