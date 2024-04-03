-- Informace o drárci
SELECT o.jmeno,o.prijmeni, o.rodne_cislo, a.ulice, a.cislo_popisne, a.mesto, a.psc, d.typ_krve, d.datum_posledniho_odberu
FROM Darce d
JOIN Osoba o ON d.id_darce_fk_osoba = o.id_osoba
JOIN Adresa a ON o.fk_id_adresa = a.id_adresa;

-- Objednávky mezi zařízeními
SELECT o. id_objednavka, o.stav, o.datum_vytvoreni, zr.nazev AS zarizeni_objednavatel, z.nazev AS zarizeni_dodavatel
FROM Objednavka o
JOIN Zarizeni zr ON o.fk_id_zarizeni_objednavatel = zr.id_zarizeni
JOIN Zarizeni z ON o.fk_id_zarizeni_dodavatel = z.id_zarizeni;

-- Mnnožství darované krve podle typu krve
SELECT o.typ_krve, SUM(o.mnozstvi) AS mnozstvi_krve
FROM Odber o
GROUP BY o.typ_krve;

-- Celkove mnnožství krve objednané jednotlivými zařízeními
SELECT z.nazev, SUM(p.mnozstvi) AS celkem_objednane_krve
FROM Objednavka o
JOIN Zarizeni z ON z.id_zarizeni = o.fk_id_zarizeni_objednavatel
JOIN Polozka_objednavky p ON o.id_objednavka = p.fk_id_objednavka
GROUP BY z.nazev;

-- Seznam všech dárců a počet jejich darování
SELECT b.jmeno, b.prijmeni, COUNT(o.id_odber) AS odberu_celkem
FROM Darce d
LEFT JOIN Odber o ON d.id_darce_fk_osoba = o.fk_id_darce
JOIN Osoba b ON d.id_darce_fk_osoba = b.id_osoba
GROUP BY b.jmeno, b.prijmeni ORDER BY COUNT(o.id_odber) DESC;

-- Průměrné množství krve objednané v jednotlivých objednávkách
SELECT fk_id_objednavka, AVG(mnozstvi) AS prumerne_mnozstvi_krve
FROM Polozka_objednavky
GROUP BY fk_id_objednavka;

-- Dárci, kteří jsou zároveň zaměstnanci
SELECT DISTINCT o. jmeno, o.prijmeni, d.typ_krve
FROM Darce d JOIN Osoba o ON d.id_darce_fk_osoba = o.id_osoba
WHERE EXISTS (
    SELECT 1
    FROM Zamestnanec z
    WHERE z.id_zamestnanec_fk_osoba = d.id_darce_fk_osoba
);

-- Zařízení která si nic neobjednala
SELECT z.nazev
FROM Zarizeni z
WHERE z.nazev NOT IN(
    SELECT DISTINCT z1.nazev
    FROM Zarizeni z1
    JOIN Objednavka o ON z1.id_zarizeni = o.fk_id_zarizeni_objednavatel
);

-- Všechna zařízení, která mají v nabídce krev typu A+
SELECT nazev
FROM Zarizeni
WHERE id_zarizeni IN (
    SELECT DISTINCT fk_id_zarizeni
    FROM Odber
    WHERE typ_krve = 'A+'
);

-- Nejnovější darování krve od každého dárce
SELECT o. id_osoba, o.jmeno, o.prijmeni, MAX(o.datum) AS posledni_odber
FROM Osoba o
JOIN Odber o ON o.id_osoba = o.fk_id_darce
GROUP BY o.id_osoba, o.jmeno, o.prijmeni ORDER BY MAX(o.datum) DESC;

-- Dárci, kteří darovali nejvíce krve
SELECT b.id_osoba, b.jmeno, b.prijmeni, SUM(o.mnozstvi) AS celkem_darovano
FROM Osoba b
JOIN Odber o ON b.id_osoba = o.fk_id_darce
GROUP BY b.id_osoba, b.jmeno, b.prijmeni
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
)
SELECT z.id_zarizeni, z.nazev, t.mozstvi_objednane_krve
FROM MnozstviObjednaneKrve t
JOIN Zarizeni z ON t.fk_id_zarizeni_objednavatel = z.id_zarizeni
WHERE t.mozstvi_objednane_krve IN (
    SELECT MAX(mozstvi_objednane_krve) AS max_objednane_mnozstvi_krve
    FROM MnozstviObjednaneKrve
);


