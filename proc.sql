CREATE PROCEDURE Pridani_odberu_do_objednavky(
    id_polozka IN Polozka_objednavky.id_polozka%TYPE
) AS
    id_objednavka Polozka_objednavky.fk_id_objednavka%TYPE;
    mnozstvi_krve_polozka INTEGER;
    typ_krve_polozka Polozka_objednavky.typ_krve%TYPE;
    mnozstvi_krve_odber INTEGER;
    mnozstvi_krve_odbery_celkem INTEGER;
    -- cursor pro vyber odberu, ktere se maji pridat do objednavky
    -- vybere odbery, ktere jeste nesjsou v zadne objednavce a jsou v zarizeni dodavatele a maji stejny typ krve jako polozka objednavky
    DECLARE CURSOR odbery_cursor IS
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

    SELECT typ_krve INTO typ_krve_polozka
        FROM Polozka_objednavky
        WHERE id_polozka = Pridani_odberu_do_objednavky.id_polozka;
        
    mnozstvi_krve_odbery_celkem := 0;
    OPEN odbery_cursor;
    LOOP
        EXIT WHEN mnozstvi_krve_odbery >= mnozstvi_krve_polozka;
        FETCH odbery_cursor INTO id_odber, mnozstvi_krve_odber;
        UPDATE Odber AS o
        SET fk_id_objednavka = id_objednavka
        WHERE id_odber = o.id_odber;
        mnozstvi_krve_odbery_celkem := mnozstvi_krve_odbery_celkem + mnozstvi_krve_odber;
    END LOOP;
    CLOSE odbery_cursor;
END;
/