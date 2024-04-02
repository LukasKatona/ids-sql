-- Informace o drárci
SELECT d.*, a.ulice, a.cislo_popisne, a.mesto, a.psc
FROM Darce d
JOIN Osoba o ON d.id_darce_fk_osoba = o.id_osoba
JOIN Adresa a ON o.fk_id_adresa = a.id_adresa;

-- Informace o darované krvi
SELECT o.*, zr.nazev AS zarizeni_objednavatel, p.typ_krve, p.mnozstvi
FROM Objednavka o
JOIN Zarizeni zr ON o.fk_id_zarizeni_objednavatel = zr.id_zarizeni
JOIN Polozka_objednavky p ON o.id_objednavka = p.fk_id_objednavka;

-- Mnnožství darované krve podle typu krve
SELECT d.typ_krve, COUNT(*) AS pocet_odberu
FROM Darce d
JOIN Odber o ON d.id_darce_fk_osoba = o.fk_id_darce
GROUP BY d.typ_krve;

-- Celkove mnnožství krve objednané jednotlivými zařízeními
SELECT o.fk_id_zarizeni_objednavatel, SUM(p.mnozstvi) AS celkem_objednane_krve
FROM Objednavka o
JOIN Polozka_objednavky p ON o.id_objednavka = p.fk_id_objednavka
GROUP BY o.fk_id_zarizeni_objednavatel;

-- Seznam všech dárců a počet jejich darování
SELECT d.id_darce_fk_osoba, COUNT(o.id_odber) AS odberu_celkem
FROM Darce d
LEFT JOIN Odber o ON d.id_darce_fk_osoba = o.fk_id_darce
GROUP BY d.id_darce_fk_osoba;

-- Seznam všech zaměstnanců a jejich adres
SELECT z.*, a.ulice, a.cislo_popisne, a.mesto, a.psc, z.pozice
FROM Zamestnanec z
JOIN Osoba o ON z.id_zamestnanec_fk_osoba = o.id_osoba
JOIN Adresa a ON o.fk_id_adresa = a.id_adresa;

-- Průměrné množství krve objednané v jednotlivých objednávkách
SELECT fk_id_objednavka, AVG(mnozstvi) AS prumerne_mnozstvi_krve
FROM Polozka_objednavky
GROUP BY fk_id_objednavka;

-- Zaměstnanci, kteří jsou zároveň dárci
SELECT *
FROM Darce d
WHERE EXISTS (
    SELECT 1
    FROM Zamestnanec z
    WHERE z.id_zamestnanec_fk_osoba = d.id_darce_fk_osoba
);

-- Vrací všechny objednávky konkrétního typu krve
SELECT *
FROM Objednavka
WHERE fk_id_zarizeni_objednavatel IN (
    SELECT fk_id_zarizeni
    FROM Odber
    WHERE typ_krve = 'A+'
);

-- Nejnovější darování krve od každého dárce
SELECT d.id_darce_fk_osoba, MAX(o.datum) AS posledni_odber
FROM Darce d
LEFT JOIN Odber o ON d.id_darce_fk_osoba = o.fk_id_darce
GROUP BY d.id_darce_fk_osoba;

-- Dárci, kteří darovali nejvíce krve
SELECT d.id_darce_fk_osoba, b.jmeno, b.prijmeni, SUM(o.mnozstvi) AS celkem_darovano
FROM Darce d
NATURAL JOIN Odber o NATURAL JOIN Osoba b WHERE d.id_darce_fk_osoba = o.fk_id_darce
GROUP BY d.id_darce_fk_osoba, b.jmeno, b.prijmeni
HAVING SUM(o.mnozstvi) = (
    SELECT MAX(celkem_darovano)
    FROM (
        SELECT SUM(o2.mnozstvi) AS celkem_darovano
        FROM Darce d2
        JOIN Odber o2 ON d2.id_darce_fk_osoba = o2.fk_id_darce
        GROUP BY d2.id_darce_fk_osoba
    )
);

-- Nemocnice, která objednala nejvíce krve
WITH MnozstviObjednaneKrve AS (
    SELECT o.fk_id_zarizeni_objednavatel, SUM(p.mnozstvi) AS mozstvi_objednane_krve
    FROM Objednavka o
    JOIN Polozka_objednavky p ON o.id_objednavka = p.fk_id_objednavka
    WHERE p.typ_krve = 'A+'
    GROUP BY o.fk_id_zarizeni_objednavatel
), MaxMnozstviObjednaneKrve AS (
    SELECT MAX(mozstvi_objednane_krve) AS max_objednane_mnozstvi_krve
    FROM MnozstviObjednaneKrve
)
SELECT z.id_zarizeni, z.nazev, t.mozstvi_objednane_krve
FROM MnozstviObjednaneKrve t
JOIN Zarizeni z ON t.fk_id_zarizeni_objednavatel = z.id_zarizeni
JOIN MaxMnozstviObjednaneKrve m ON t.mozstvi_objednane_krve = m.max_objednane_mnozstvi_krve;
