-- =====================================================================
-- TP : Gestion du risque d'inondation au Maroc
-- Fichier 2/5 : Seed (données fictives à but pédagogique)
-- =====================================================================
-- À exécuter après 01_schema.sql
-- Dataset volontairement fictif. Noms, chiffres, victimes : tout inventé.
-- Les tracés et coordonnées sont simplifiés mais grossièrement réalistes
-- pour que les requêtes spatiales donnent des résultats vraisemblables.
-- =====================================================================

-- =====================================================================
-- 1. NIVEAUX D'ALERTE
-- =====================================================================
INSERT INTO niveaux_alerte (code, libelle, couleur_hex, consigne, ordre) VALUES
  ('JAUNE',  'Vigilance jaune',  '#FFD700', 'Soyez attentif aux conditions météorologiques.', 1),
  ('ORANGE', 'Vigilance orange', '#FF8C00', 'Phénomène dangereux prévu. Limitez les déplacements.', 2),
  ('ROUGE',  'Vigilance rouge',  '#DC143C', 'Phénomène dangereux d''intensité exceptionnelle. Évitez tout déplacement.', 3);

-- =====================================================================
-- 2. BASSINS VERSANTS (5 bassins, polygones simplifiés)
-- =====================================================================
INSERT INTO bassins_versants (nom, code, superficie_km2, geom) VALUES
  ('Bouregreg', 'BG', 9970, ST_GeomFromText(
    'POLYGON((-7.0 33.4, -5.6 33.4, -5.4 34.5, -6.9 34.7, -7.0 33.4))', 4326)),
  ('Sebou', 'SB', 40000, ST_GeomFromText(
    'POLYGON((-6.5 33.8, -3.8 33.5, -3.5 34.9, -5.0 35.4, -6.7 34.8, -6.5 33.8))', 4326)),
  ('Oum Er-Rbia', 'OR', 35000, ST_GeomFromText(
    'POLYGON((-9.0 31.5, -5.5 31.8, -5.8 33.4, -8.5 33.3, -9.0 31.5))', 4326)),
  ('Tensift', 'TS', 24800, ST_GeomFromText(
    'POLYGON((-9.6 30.8, -7.2 30.8, -7.0 32.1, -9.5 32.0, -9.6 30.8))', 4326)),
  ('Souss-Massa', 'SM', 27000, ST_GeomFromText(
    'POLYGON((-10.1 29.4, -7.6 29.7, -7.8 31.0, -10.0 30.9, -10.1 29.4))', 4326));

-- =====================================================================
-- 3. OUEDS (~25 lignes, dont les principaux nommés)
-- =====================================================================

-- Bouregreg (id=1)
INSERT INTO oueds (nom, bassin_id, longueur_km, regime, geom) VALUES
  ('Oued Bouregreg', 1, 240, 'perenne', ST_GeomFromText(
    'LINESTRING(-5.6 33.7, -6.0 33.9, -6.4 34.0, -6.7 34.0, -6.84 34.02)', 4326)),
  ('Oued Grou', 1, 130, 'temporaire', ST_GeomFromText(
    'LINESTRING(-5.7 33.5, -6.2 33.8, -6.6 33.95, -6.84 34.02)', 4326)),
  ('Oued Akrach', 1, 35, 'temporaire', ST_GeomFromText(
    'LINESTRING(-6.7 34.05, -6.78 34.04, -6.83 34.03)', 4326)),
  ('Oued Mellah', 1, 28, 'torrentiel', ST_GeomFromText(
    'LINESTRING(-6.55 34.1, -6.65 34.08, -6.8 34.06)', 4326));

-- Sebou (id=2)
INSERT INTO oueds (nom, bassin_id, longueur_km, regime, geom) VALUES
  ('Oued Sebou', 2, 600, 'perenne', ST_GeomFromText(
    'LINESTRING(-4.0 33.9, -4.5 34.1, -5.2 34.4, -5.8 34.7, -6.55 34.9, -6.7 35.0)', 4326)),
  ('Oued Inaouène', 2, 130, 'perenne', ST_GeomFromText(
    'LINESTRING(-4.4 34.4, -4.8 34.3, -5.2 34.4)', 4326)),
  ('Oued Beht', 2, 200, 'perenne', ST_GeomFromText(
    'LINESTRING(-5.5 33.9, -5.8 34.2, -6.0 34.4, -6.3 34.6)', 4326)),
  ('Oued Mikkès', 2, 70, 'temporaire', ST_GeomFromText(
    'LINESTRING(-5.0 33.95, -5.2 34.05, -5.3 34.15)', 4326)),
  ('Oued Ouergha', 2, 250, 'perenne', ST_GeomFromText(
    'LINESTRING(-4.5 34.5, -5.0 34.7, -5.5 34.85, -6.0 34.9)', 4326));

-- Oum Er-Rbia (id=3) — inclut Ourika via affluent
INSERT INTO oueds (nom, bassin_id, longueur_km, regime, geom) VALUES
  ('Oued Oum Er-Rbia', 3, 555, 'perenne', ST_GeomFromText(
    'LINESTRING(-5.6 32.6, -6.2 32.7, -7.0 32.8, -7.8 32.85, -8.5 33.0, -8.9 33.1)', 4326)),
  ('Oued El Abid', 3, 175, 'perenne', ST_GeomFromText(
    'LINESTRING(-6.0 32.0, -6.5 32.3, -7.0 32.5, -7.5 32.7)', 4326)),
  ('Oued Tessaout', 3, 165, 'temporaire', ST_GeomFromText(
    'LINESTRING(-6.8 31.8, -7.2 32.1, -7.6 32.3, -8.0 32.5)', 4326));

-- Tensift (id=4) — inclut Ourika (torrentiel !)
INSERT INTO oueds (nom, bassin_id, longueur_km, regime, geom) VALUES
  ('Oued Tensift', 4, 270, 'perenne', ST_GeomFromText(
    'LINESTRING(-7.5 31.6, -8.0 31.65, -8.5 31.7, -9.0 31.75, -9.4 31.8)', 4326)),
  ('Oued Ourika', 4, 45, 'torrentiel', ST_GeomFromText(
    'LINESTRING(-7.75 31.25, -7.80 31.35, -7.85 31.45, -7.92 31.55, -7.99 31.63)', 4326)),
  ('Oued Rheraya', 4, 60, 'torrentiel', ST_GeomFromText(
    'LINESTRING(-7.95 31.20, -7.97 31.35, -7.98 31.50, -7.99 31.63)', 4326)),
  ('Oued N''Fis', 4, 170, 'torrentiel', ST_GeomFromText(
    'LINESTRING(-8.20 31.10, -8.15 31.30, -8.10 31.45, -8.05 31.60)', 4326)),
  ('Oued Chichaoua', 4, 110, 'temporaire', ST_GeomFromText(
    'LINESTRING(-8.7 31.0, -8.8 31.3, -8.9 31.5, -9.0 31.6)', 4326));

-- Souss-Massa (id=5)
INSERT INTO oueds (nom, bassin_id, longueur_km, regime, geom) VALUES
  ('Oued Souss', 5, 295, 'perenne', ST_GeomFromText(
    'LINESTRING(-7.9 30.5, -8.3 30.4, -8.8 30.4, -9.2 30.42, -9.59 30.42)', 4326)),
  ('Oued Massa', 5, 100, 'temporaire', ST_GeomFromText(
    'LINESTRING(-9.0 30.0, -9.3 30.05, -9.6 30.1)', 4326)),
  ('Oued Issen', 5, 80, 'torrentiel', ST_GeomFromText(
    'LINESTRING(-8.5 30.7, -8.7 30.5, -8.9 30.45)', 4326));

-- =====================================================================
-- 4. ZONES D'ALÉA (~40 polygones)
-- =====================================================================

-- Bouregreg : focus zone urbaine Rabat-Salé (forte exposition)
INSERT INTO zones_alea (nom, niveau, periode_retour_ans, bassin_id, geom, date_etude) VALUES
  ('Embouchure Bouregreg Rabat-Salé', 'fort', 100, 1, ST_GeomFromText(
    'POLYGON((-6.86 34.00, -6.78 34.00, -6.78 34.06, -6.86 34.06, -6.86 34.00))', 4326), '2022-03-15'),
  ('Vallée Bouregreg amont Rabat', 'fort', 50, 1, ST_GeomFromText(
    'POLYGON((-6.78 34.00, -6.65 33.98, -6.65 34.04, -6.78 34.04, -6.78 34.00))', 4326), '2022-03-15'),
  ('Vallée Bouregreg moyenne', 'moyen', 100, 1, ST_GeomFromText(
    'POLYGON((-6.65 33.95, -6.40 33.92, -6.40 34.02, -6.65 34.02, -6.65 33.95))', 4326), '2022-03-15'),
  ('Plaine Grou aval', 'moyen', 50, 1, ST_GeomFromText(
    'POLYGON((-6.55 33.92, -6.35 33.90, -6.35 33.98, -6.55 33.98, -6.55 33.92))', 4326), '2022-03-15'),
  ('Akrach urbain', 'fort', 50, 1, ST_GeomFromText(
    'POLYGON((-6.83 34.02, -6.76 34.02, -6.76 34.07, -6.83 34.07, -6.83 34.02))', 4326), '2022-03-15'),
  ('Mellah confluence', 'moyen', 100, 1, ST_GeomFromText(
    'POLYGON((-6.78 34.05, -6.68 34.05, -6.68 34.10, -6.78 34.10, -6.78 34.05))', 4326), '2022-03-15'),
  ('Bouregreg amont diffus', 'faible', 500, 1, ST_GeomFromText(
    'POLYGON((-6.40 33.85, -6.00 33.85, -6.00 33.95, -6.40 33.95, -6.40 33.85))', 4326), '2022-03-15'),
  ('Zaër ruissellement', 'faible', 100, 1, ST_GeomFromText(
    'POLYGON((-6.50 33.75, -6.20 33.75, -6.20 33.85, -6.50 33.85, -6.50 33.75))', 4326), '2022-03-15');

-- Sebou : grande plaine du Gharb
INSERT INTO zones_alea (nom, niveau, periode_retour_ans, bassin_id, geom, date_etude) VALUES
  ('Plaine du Gharb centre', 'fort', 100, 2, ST_GeomFromText(
    'POLYGON((-6.30 34.65, -5.80 34.60, -5.80 34.95, -6.40 34.95, -6.30 34.65))', 4326), '2021-09-10'),
  ('Plaine du Gharb ouest', 'fort', 50, 2, ST_GeomFromText(
    'POLYGON((-6.40 34.55, -6.10 34.55, -6.10 34.75, -6.50 34.75, -6.40 34.55))', 4326), '2021-09-10'),
  ('Sebou Kénitra urbain', 'fort', 100, 2, ST_GeomFromText(
    'POLYGON((-6.65 34.22, -6.50 34.22, -6.50 34.32, -6.65 34.32, -6.65 34.22))', 4326), '2021-09-10'),
  ('Vallée Sebou Fès amont', 'moyen', 100, 2, ST_GeomFromText(
    'POLYGON((-5.10 33.95, -4.85 33.95, -4.85 34.10, -5.10 34.10, -5.10 33.95))', 4326), '2021-09-10'),
  ('Plaine Beht aval', 'moyen', 50, 2, ST_GeomFromText(
    'POLYGON((-6.10 34.45, -5.80 34.45, -5.80 34.65, -6.10 34.65, -6.10 34.45))', 4326), '2021-09-10'),
  ('Inaouène vallée', 'faible', 100, 2, ST_GeomFromText(
    'POLYGON((-4.80 34.25, -4.50 34.25, -4.50 34.40, -4.80 34.40, -4.80 34.25))', 4326), '2021-09-10'),
  ('Ouergha moyen', 'moyen', 100, 2, ST_GeomFromText(
    'POLYGON((-5.30 34.60, -4.80 34.60, -4.80 34.80, -5.30 34.80, -5.30 34.60))', 4326), '2021-09-10'),
  ('Sebou estuaire', 'fort', 500, 2, ST_GeomFromText(
    'POLYGON((-6.65 34.85, -6.45 34.85, -6.45 35.05, -6.65 35.05, -6.65 34.85))', 4326), '2021-09-10');

-- Oum Er-Rbia
INSERT INTO zones_alea (nom, niveau, periode_retour_ans, bassin_id, geom, date_etude) VALUES
  ('Plaine Tadla', 'fort', 100, 3, ST_GeomFromText(
    'POLYGON((-6.60 32.20, -6.20 32.20, -6.20 32.45, -6.60 32.45, -6.60 32.20))', 4326), '2020-11-20'),
  ('Oum Er-Rbia aval Azemmour', 'fort', 50, 3, ST_GeomFromText(
    'POLYGON((-8.40 33.25, -8.20 33.25, -8.20 33.40, -8.40 33.40, -8.40 33.25))', 4326), '2020-11-20'),
  ('Confluence El Abid', 'moyen', 100, 3, ST_GeomFromText(
    'POLYGON((-7.10 32.50, -6.80 32.50, -6.80 32.70, -7.10 32.70, -7.10 32.50))', 4326), '2020-11-20'),
  ('Khouribga ruissellement', 'faible', 100, 3, ST_GeomFromText(
    'POLYGON((-6.95 32.85, -6.75 32.85, -6.75 33.00, -6.95 33.00, -6.95 32.85))', 4326), '2020-11-20'),
  ('Vallée Tessaout', 'moyen', 50, 3, ST_GeomFromText(
    'POLYGON((-7.30 32.20, -7.00 32.20, -7.00 32.35, -7.30 32.35, -7.30 32.20))', 4326), '2020-11-20'),
  ('Beni Mellal piémont', 'moyen', 100, 3, ST_GeomFromText(
    'POLYGON((-6.50 32.30, -6.30 32.30, -6.30 32.45, -6.50 32.45, -6.50 32.30))', 4326), '2020-11-20');

-- Tensift : focus Ourika (zone à risque torrentiel emblématique)
INSERT INTO zones_alea (nom, niveau, periode_retour_ans, bassin_id, geom, date_etude) VALUES
  ('Vallée Ourika village', 'fort', 50, 4, ST_GeomFromText(
    'POLYGON((-7.83 31.30, -7.75 31.30, -7.75 31.45, -7.83 31.45, -7.83 31.30))', 4326), '2023-04-10'),
  ('Ourika aval Setti Fadma', 'fort', 100, 4, ST_GeomFromText(
    'POLYGON((-7.86 31.20, -7.78 31.20, -7.78 31.30, -7.86 31.30, -7.86 31.20))', 4326), '2023-04-10'),
  ('Rheraya gorge', 'fort', 50, 4, ST_GeomFromText(
    'POLYGON((-7.99 31.15, -7.93 31.15, -7.93 31.35, -7.99 31.35, -7.99 31.15))', 4326), '2023-04-10'),
  ('Tensift Marrakech aval', 'moyen', 100, 4, ST_GeomFromText(
    'POLYGON((-8.10 31.55, -7.85 31.55, -7.85 31.70, -8.10 31.70, -8.10 31.55))', 4326), '2023-04-10'),
  ('Plaine N''Fis aval', 'moyen', 50, 4, ST_GeomFromText(
    'POLYGON((-8.20 31.50, -8.00 31.50, -8.00 31.65, -8.20 31.65, -8.20 31.50))', 4326), '2023-04-10'),
  ('Chichaoua centre', 'moyen', 100, 4, ST_GeomFromText(
    'POLYGON((-8.95 31.50, -8.75 31.50, -8.75 31.62, -8.95 31.62, -8.95 31.50))', 4326), '2023-04-10'),
  ('Tensift embouchure', 'faible', 500, 4, ST_GeomFromText(
    'POLYGON((-9.50 31.75, -9.30 31.75, -9.30 31.88, -9.50 31.88, -9.50 31.75))', 4326), '2023-04-10'),
  ('Atlas piémont diffus', 'faible', 100, 4, ST_GeomFromText(
    'POLYGON((-8.00 31.05, -7.70 31.05, -7.70 31.20, -8.00 31.20, -8.00 31.05))', 4326), '2023-04-10');

-- Souss-Massa
INSERT INTO zones_alea (nom, niveau, periode_retour_ans, bassin_id, geom, date_etude) VALUES
  ('Plaine Souss centrale', 'moyen', 100, 5, ST_GeomFromText(
    'POLYGON((-8.80 30.35, -8.40 30.35, -8.40 30.50, -8.80 30.50, -8.80 30.35))', 4326), '2022-07-05'),
  ('Embouchure Souss Agadir', 'fort', 100, 5, ST_GeomFromText(
    'POLYGON((-9.62 30.38, -9.50 30.38, -9.50 30.48, -9.62 30.48, -9.62 30.38))', 4326), '2022-07-05'),
  ('Taroudant urbain', 'fort', 50, 5, ST_GeomFromText(
    'POLYGON((-8.95 30.45, -8.85 30.45, -8.85 30.55, -8.95 30.55, -8.95 30.45))', 4326), '2022-07-05'),
  ('Massa aval', 'moyen', 100, 5, ST_GeomFromText(
    'POLYGON((-9.50 30.05, -9.30 30.05, -9.30 30.15, -9.50 30.15, -9.50 30.05))', 4326), '2022-07-05'),
  ('Anti-Atlas piémont', 'faible', 100, 5, ST_GeomFromText(
    'POLYGON((-8.70 30.10, -8.40 30.10, -8.40 30.25, -8.70 30.25, -8.70 30.10))', 4326), '2022-07-05'),
  ('Souss amont', 'faible', 50, 5, ST_GeomFromText(
    'POLYGON((-7.95 30.40, -7.70 30.40, -7.70 30.55, -7.95 30.55, -7.95 30.40))', 4326), '2022-07-05'),
  ('Issen torrentiel', 'fort', 50, 5, ST_GeomFromText(
    'POLYGON((-8.85 30.55, -8.65 30.55, -8.65 30.70, -8.85 30.70, -8.85 30.55))', 4326), '2022-07-05');

-- =====================================================================
-- 5. CAPTEURS (~50, répartis sur les 5 bassins)
-- =====================================================================

-- Bouregreg (10 capteurs)
INSERT INTO capteurs (code, type_capteur, unite, bassin_id, seuil_jaune, seuil_orange, seuil_rouge, derniere_valeur, derniere_mesure_at, statut, geom, installe_le) VALUES
  ('BG-PLU-001', 'pluviometre', 'mm/h', 1, 10, 25, 50, 3.2, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.84 34.02)', 4326), '2018-05-12'),
  ('BG-PLU-002', 'pluviometre', 'mm/h', 1, 10, 25, 50, 5.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.50 33.95)', 4326), '2019-03-20'),
  ('BG-PLU-003', 'pluviometre', 'mm/h', 1, 10, 25, 50, 2.1, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.20 33.80)', 4326), '2019-06-15'),
  ('BG-LIM-001', 'limnimetre', 'm', 1, 1.5, 2.5, 3.5, 0.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.82 34.02)', 4326), '2017-11-08'),
  ('BG-LIM-002', 'limnimetre', 'm', 1, 1.0, 2.0, 3.0, 0.4, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.55 33.96)', 4326), '2020-02-14'),
  ('BG-LIM-003', 'limnimetre', 'm', 1, 1.2, 2.2, 3.2, 0.6, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.75 34.04)', 4326), '2020-04-22'),
  ('BG-MET-001', 'station_meteo', 'mixte', 1, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.83 34.01)', 4326), '2016-09-01'),
  ('BG-MET-002', 'station_meteo', 'mixte', 1, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'panne', ST_GeomFromText('POINT(-6.60 33.97)', 4326), '2017-04-15'),
  ('BG-PLU-004', 'pluviometre', 'mm/h', 1, 10, 25, 50, 4.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.70 34.06)', 4326), '2021-01-10'),
  ('BG-LIM-004', 'limnimetre', 'm', 1, 1.5, 2.5, 3.5, 0.9, '2026-05-15 08:00+00', 'maintenance', ST_GeomFromText('POINT(-6.80 34.05)', 4326), '2018-10-25');

-- Sebou (12 capteurs)
INSERT INTO capteurs (code, type_capteur, unite, bassin_id, seuil_jaune, seuil_orange, seuil_rouge, derniere_valeur, derniere_mesure_at, statut, geom, installe_le) VALUES
  ('SB-PLU-001', 'pluviometre', 'mm/h', 2, 10, 25, 50, 6.2, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-4.99 34.03)', 4326), '2018-05-12'),
  ('SB-PLU-002', 'pluviometre', 'mm/h', 2, 10, 25, 50, 3.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-5.55 33.89)', 4326), '2019-03-20'),
  ('SB-PLU-003', 'pluviometre', 'mm/h', 2, 10, 25, 50, 8.1, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.10 34.65)', 4326), '2019-06-15'),
  ('SB-PLU-004', 'pluviometre', 'mm/h', 2, 10, 25, 50, 12.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.58 34.26)', 4326), '2020-01-10'),
  ('SB-LIM-001', 'limnimetre', 'm', 2, 2.0, 3.5, 5.0, 1.2, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-5.00 34.05)', 4326), '2017-11-08'),
  ('SB-LIM-002', 'limnimetre', 'm', 2, 2.5, 4.0, 6.0, 1.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-5.85 34.70)', 4326), '2020-02-14'),
  ('SB-LIM-003', 'limnimetre', 'm', 2, 2.0, 3.5, 5.5, 2.1, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.55 34.95)', 4326), '2020-04-22'),
  ('SB-LIM-004', 'limnimetre', 'm', 2, 1.5, 3.0, 4.5, 1.0, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-4.60 34.30)', 4326), '2021-03-05'),
  ('SB-MET-001', 'station_meteo', 'mixte', 2, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-5.00 34.03)', 4326), '2016-09-01'),
  ('SB-MET-002', 'station_meteo', 'mixte', 2, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.58 34.26)', 4326), '2017-04-15'),
  ('SB-PLU-005', 'pluviometre', 'mm/h', 2, 10, 25, 50, 28.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-5.20 34.40)', 4326), '2021-01-10'),
  ('SB-LIM-005', 'limnimetre', 'm', 2, 2.0, 3.5, 5.0, 1.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.00 34.85)', 4326), '2021-08-12');

-- Oum Er-Rbia (9 capteurs)
INSERT INTO capteurs (code, type_capteur, unite, bassin_id, seuil_jaune, seuil_orange, seuil_rouge, derniere_valeur, derniere_mesure_at, statut, geom, installe_le) VALUES
  ('OR-PLU-001', 'pluviometre', 'mm/h', 3, 10, 25, 50, 2.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.36 32.34)', 4326), '2018-07-15'),
  ('OR-PLU-002', 'pluviometre', 'mm/h', 3, 10, 25, 50, 1.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.00 32.80)', 4326), '2019-05-10'),
  ('OR-PLU-003', 'pluviometre', 'mm/h', 3, 10, 25, 50, 4.2, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-8.30 33.32)', 4326), '2020-02-20'),
  ('OR-LIM-001', 'limnimetre', 'm', 3, 2.0, 3.5, 5.0, 1.4, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.40 32.32)', 4326), '2018-10-08'),
  ('OR-LIM-002', 'limnimetre', 'm', 3, 2.5, 4.0, 5.5, 2.0, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-8.30 33.30)', 4326), '2019-11-12'),
  ('OR-LIM-003', 'limnimetre', 'm', 3, 1.5, 3.0, 4.5, 0.9, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.20 32.55)', 4326), '2020-06-22'),
  ('OR-MET-001', 'station_meteo', 'mixte', 3, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-6.36 32.34)', 4326), '2016-11-01'),
  ('OR-PLU-004', 'pluviometre', 'mm/h', 3, 10, 25, 50, 3.0, '2026-05-15 08:00+00', 'panne', ST_GeomFromText('POINT(-6.85 32.95)', 4326), '2017-08-15'),
  ('OR-LIM-004', 'limnimetre', 'm', 3, 1.8, 3.2, 4.8, 1.1, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.55 32.72)', 4326), '2022-03-10');

-- Tensift (12 capteurs, dont densité forte sur Ourika)
INSERT INTO capteurs (code, type_capteur, unite, bassin_id, seuil_jaune, seuil_orange, seuil_rouge, derniere_valeur, derniere_mesure_at, statut, geom, installe_le) VALUES
  ('TS-PLU-001', 'pluviometre', 'mm/h', 4, 10, 25, 50, 18.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.99 31.63)', 4326), '2018-04-12'),
  ('TS-PLU-002', 'pluviometre', 'mm/h', 4, 15, 30, 60, 35.2, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.80 31.35)', 4326), '2019-05-22'),
  ('TS-PLU-003', 'pluviometre', 'mm/h', 4, 15, 30, 60, 42.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.82 31.25)', 4326), '2019-06-15'),
  ('TS-PLU-004', 'pluviometre', 'mm/h', 4, 10, 25, 50, 8.1, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-8.50 31.65)', 4326), '2020-03-10'),
  ('TS-PLU-005', 'pluviometre', 'mm/h', 4, 15, 30, 60, 22.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.96 31.30)', 4326), '2020-07-18'),
  ('TS-LIM-001', 'limnimetre', 'm', 4, 1.0, 2.0, 3.5, 1.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.85 31.40)', 4326), '2017-09-15'),
  ('TS-LIM-002', 'limnimetre', 'm', 4, 0.8, 1.5, 2.8, 2.2, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.82 31.32)', 4326), '2018-08-25'),
  ('TS-LIM-003', 'limnimetre', 'm', 4, 1.2, 2.5, 4.0, 0.6, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-8.10 31.60)', 4326), '2019-10-30'),
  ('TS-LIM-004', 'limnimetre', 'm', 4, 1.0, 2.0, 3.5, 1.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.97 31.25)', 4326), '2020-11-15'),
  ('TS-LIM-005', 'limnimetre', 'm', 4, 1.5, 3.0, 4.5, 0.4, '2026-05-15 08:00+00', 'panne', ST_GeomFromText('POINT(-9.35 31.80)', 4326), '2018-12-05'),
  ('TS-MET-001', 'station_meteo', 'mixte', 4, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.99 31.63)', 4326), '2016-08-01'),
  ('TS-MET-002', 'station_meteo', 'mixte', 4, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-7.80 31.35)', 4326), '2018-02-20');

-- Souss-Massa (8 capteurs)
INSERT INTO capteurs (code, type_capteur, unite, bassin_id, seuil_jaune, seuil_orange, seuil_rouge, derniere_valeur, derniere_mesure_at, statut, geom, installe_le) VALUES
  ('SM-PLU-001', 'pluviometre', 'mm/h', 5, 10, 25, 50, 1.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-9.59 30.42)', 4326), '2018-05-10'),
  ('SM-PLU-002', 'pluviometre', 'mm/h', 5, 10, 25, 50, 0.8, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-8.90 30.48)', 4326), '2019-04-20'),
  ('SM-PLU-003', 'pluviometre', 'mm/h', 5, 10, 25, 50, 2.1, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-8.30 30.40)', 4326), '2019-08-15'),
  ('SM-LIM-001', 'limnimetre', 'm', 5, 1.5, 3.0, 4.5, 0.5, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-9.55 30.42)', 4326), '2017-12-08'),
  ('SM-LIM-002', 'limnimetre', 'm', 5, 1.2, 2.5, 4.0, 0.3, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-8.92 30.50)', 4326), '2020-01-15'),
  ('SM-LIM-003', 'limnimetre', 'm', 5, 1.0, 2.2, 3.8, 0.4, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-9.40 30.10)', 4326), '2020-09-22'),
  ('SM-MET-001', 'station_meteo', 'mixte', 5, NULL, NULL, NULL, NULL, '2026-05-15 08:00+00', 'actif', ST_GeomFromText('POINT(-9.59 30.42)', 4326), '2016-10-01'),
  ('SM-PLU-004', 'pluviometre', 'mm/h', 5, 10, 25, 50, 0.5, '2026-05-15 08:00+00', 'retire', ST_GeomFromText('POINT(-8.50 30.60)', 4326), '2017-06-15');

-- =====================================================================
-- 6. MESURES (~30 lignes, échantillon symbolique)
-- =====================================================================
-- Quelques mesures récentes incluant des dépassements de seuils
INSERT INTO mesures (capteur_id, valeur, mesure_at, niveau_declenche) VALUES
  -- Capteurs Bouregreg, conditions normales
  (1, 3.2,  '2026-05-15 08:00+00', NULL),
  (1, 2.8,  '2026-05-15 07:00+00', NULL),
  (4, 0.8,  '2026-05-15 08:00+00', NULL),
  (4, 0.7,  '2026-05-15 07:00+00', NULL),
  -- Capteurs Sebou, un dépassement seuil orange
  (11, 6.2,  '2026-05-15 08:00+00', NULL),
  (15, 28.5, '2026-05-15 08:00+00', 'ORANGE'),
  (15, 32.0, '2026-05-15 07:00+00', 'ORANGE'),
  (15, 18.0, '2026-05-15 06:00+00', 'JAUNE'),
  -- Capteurs Ourika (Tensift), épisode pluvieux ROUGE
  (33, 42.8, '2026-05-15 08:00+00', 'ROUGE'),
  (33, 38.5, '2026-05-15 07:00+00', 'ROUGE'),
  (33, 28.2, '2026-05-15 06:00+00', 'JAUNE'),
  (33, 15.0, '2026-05-15 05:00+00', NULL),
  (32, 35.2, '2026-05-15 08:00+00', 'ROUGE'),
  (32, 30.1, '2026-05-15 07:00+00', 'ORANGE'),
  (32, 22.5, '2026-05-15 06:00+00', 'JAUNE'),
  (36, 2.2,  '2026-05-15 08:00+00', 'ROUGE'),  -- limni Ourika
  (36, 2.0,  '2026-05-15 07:00+00', 'ROUGE'),
  (36, 1.7,  '2026-05-15 06:00+00', 'ORANGE'),
  (36, 1.2,  '2026-05-15 05:00+00', 'JAUNE'),
  -- Souss conditions sèches
  (43, 1.5,  '2026-05-15 08:00+00', NULL),
  (43, 1.2,  '2026-05-15 07:00+00', NULL),
  (46, 0.5,  '2026-05-15 08:00+00', NULL),
  -- Oum Er-Rbia normal
  (21, 2.5,  '2026-05-15 08:00+00', NULL),
  (21, 2.1,  '2026-05-15 07:00+00', NULL),
  (24, 1.4,  '2026-05-15 08:00+00', NULL),
  -- Mesures plus anciennes (J-1) pour les requêtes "dernières 24h"
  (15, 5.0,  '2026-05-14 14:00+00', NULL),
  (33, 5.2,  '2026-05-14 14:00+00', NULL),
  (1, 2.1,   '2026-05-14 14:00+00', NULL),
  (11, 4.8,  '2026-05-14 14:00+00', NULL),
  (43, 0.8,  '2026-05-14 14:00+00', NULL);

-- =====================================================================
-- 7. ÉVÉNEMENTS D'INONDATION (~15 événements fictifs)
-- =====================================================================
INSERT INTO evenements_inondation (nom, date_debut, date_fin, gravite, bassin_id, nb_victimes, nb_personnes_evacuees, cout_estime_mad, geom, description) VALUES
  ('Crue Bouregreg nov-2024', '2024-11-22 04:00+00', '2024-11-23 18:00+00', 'fort', 1, 3, 850, 45000000,
   ST_GeomFromText('POLYGON((-6.86 34.00, -6.78 34.00, -6.78 34.06, -6.86 34.06, -6.86 34.00))', 4326),
   'Précipitations diluviennes sur l''amont, débordement à l''embouchure'),

  ('Crue Sebou Gharb mars-2025', '2025-03-08 10:00+00', '2025-03-12 22:00+00', 'majeur', 2, 8, 4200, 280000000,
   ST_GeomFromText('POLYGON((-6.30 34.65, -5.80 34.60, -5.80 34.95, -6.40 34.95, -6.30 34.65))', 4326),
   'Crue centennale, plaine du Gharb largement submergée'),

  ('Crue éclair Ourika sept-2024', '2024-09-15 16:00+00', '2024-09-15 22:00+00', 'fort', 4, 12, 320, 22000000,
   ST_GeomFromText('POLYGON((-7.83 31.30, -7.75 31.30, -7.75 31.45, -7.83 31.45, -7.83 31.30))', 4326),
   'Crue torrentielle après orage cévenol, plusieurs villages touchés'),

  ('Inondation Tadla oct-2023', '2023-10-18 02:00+00', '2023-10-20 16:00+00', 'moyen', 3, 1, 180, 15000000,
   ST_GeomFromText('POLYGON((-6.60 32.20, -6.20 32.20, -6.20 32.45, -6.60 32.45, -6.60 32.20))', 4326),
   'Pluies abondantes, débordement local'),

  ('Crue Agadir Souss déc-2024', '2024-12-04 06:00+00', '2024-12-05 12:00+00', 'fort', 5, 5, 720, 35000000,
   ST_GeomFromText('POLYGON((-9.62 30.38, -9.50 30.38, -9.50 30.48, -9.62 30.48, -9.62 30.38))', 4326),
   'Tempête méditerranéenne, embouchure Souss en crue'),

  ('Crue Rheraya mai-2024', '2024-05-12 14:00+00', '2024-05-13 02:00+00', 'moyen', 4, 0, 85, 4500000,
   ST_GeomFromText('POLYGON((-7.99 31.15, -7.93 31.15, -7.93 31.35, -7.99 31.35, -7.99 31.15))', 4326),
   'Crue torrentielle modérée'),

  ('Crue Kénitra fév-2024', '2024-02-20 22:00+00', '2024-02-22 06:00+00', 'moyen', 2, 2, 450, 18000000,
   ST_GeomFromText('POLYGON((-6.65 34.22, -6.50 34.22, -6.50 34.32, -6.65 34.32, -6.65 34.22))', 4326),
   'Sebou en charge, quartiers bas inondés'),

  ('Inondation Taroudant nov-2023', '2023-11-10 08:00+00', '2023-11-11 18:00+00', 'moyen', 5, 1, 230, 9500000,
   ST_GeomFromText('POLYGON((-8.95 30.45, -8.85 30.45, -8.85 30.55, -8.95 30.55, -8.95 30.45))', 4326),
   'Pluies localement intenses'),

  ('Crue Akrach déc-2023', '2023-12-05 20:00+00', '2023-12-06 14:00+00', 'moyen', 1, 0, 120, 6800000,
   ST_GeomFromText('POLYGON((-6.83 34.02, -6.76 34.02, -6.76 34.07, -6.83 34.07, -6.83 34.02))', 4326),
   'Ruissellement urbain'),

  ('Crue Azemmour jan-2025', '2025-01-14 04:00+00', '2025-01-15 12:00+00', 'moyen', 3, 0, 290, 12000000,
   ST_GeomFromText('POLYGON((-8.40 33.25, -8.20 33.25, -8.20 33.40, -8.40 33.40, -8.40 33.25))', 4326),
   'Oum Er-Rbia en crue à l''aval'),

  ('Épisode Ourika mai-2026', '2026-05-15 06:00+00', NULL, 'fort', 4, 0, 0, NULL,
   ST_GeomFromText('POLYGON((-7.83 31.30, -7.75 31.30, -7.75 31.45, -7.83 31.45, -7.83 31.30))', 4326),
   'Événement EN COURS — précipitations exceptionnelles enregistrées'),

  ('Inondation Beni Mellal jan-2024', '2024-01-22 16:00+00', '2024-01-23 22:00+00', 'faible', 3, 0, 60, 2200000,
   ST_GeomFromText('POLYGON((-6.50 32.30, -6.30 32.30, -6.30 32.45, -6.50 32.45, -6.50 32.30))', 4326),
   'Ruissellement de piémont, dégâts limités'),

  ('Crue Inaouène avr-2024', '2024-04-08 12:00+00', '2024-04-09 06:00+00', 'faible', 2, 0, 45, 1800000,
   ST_GeomFromText('POLYGON((-4.80 34.25, -4.50 34.25, -4.50 34.40, -4.80 34.40, -4.80 34.25))', 4326),
   'Débordement de vallée modéré'),

  ('Inondation Massa mars-2024', '2024-03-15 08:00+00', '2024-03-16 14:00+00', 'moyen', 5, 0, 110, 5500000,
   ST_GeomFromText('POLYGON((-9.50 30.05, -9.30 30.05, -9.30 30.15, -9.50 30.15, -9.50 30.05))', 4326),
   'Crue de printemps Massa'),

  ('Crue Bouregreg amont juin-2024', '2024-06-02 04:00+00', '2024-06-03 10:00+00', 'faible', 1, 0, 30, 1200000,
   ST_GeomFromText('POLYGON((-6.40 33.85, -6.00 33.85, -6.00 33.95, -6.40 33.95, -6.40 33.85))', 4326),
   'Orage localisé, dégâts limités');

-- =====================================================================
-- 8. ENJEUX EXPOSÉS (~200 lignes : hôpitaux, écoles, postes, barrages, zones)
-- =====================================================================

-- Hôpitaux (points) -- 20 lignes
INSERT INTO enjeux_exposes (nom, type_enjeu, geom, capacite, bassin_id) VALUES
  ('CHU Ibn Sina Rabat',          'hopital', ST_GeomFromText('POINT(-6.84 34.01)', 4326), 1200, 1),
  ('Hôpital Cheikh Zaid Rabat',   'hopital', ST_GeomFromText('POINT(-6.85 34.00)', 4326), 280, 1),
  ('Hôpital Avicenne Salé',       'hopital', ST_GeomFromText('POINT(-6.80 34.04)', 4326), 320, 1),
  ('Hôpital Idrissi Kénitra',     'hopital', ST_GeomFromText('POINT(-6.58 34.26)', 4326), 250, 2),
  ('CHU Hassan II Fès',           'hopital', ST_GeomFromText('POINT(-5.00 34.03)', 4326), 950, 2),
  ('Hôpital Mohammed V Meknès',   'hopital', ST_GeomFromText('POINT(-5.55 33.89)', 4326), 480, 2),
  ('Hôpital El Idrissi Beni Mellal','hopital', ST_GeomFromText('POINT(-6.36 32.34)', 4326), 380, 3),
  ('Hôpital régional Khouribga',  'hopital', ST_GeomFromText('POINT(-6.91 32.88)', 4326), 220, 3),
  ('CHU Mohammed VI Marrakech',   'hopital', ST_GeomFromText('POINT(-7.99 31.63)', 4326), 870, 4),
  ('Hôpital Antaki Marrakech',    'hopital', ST_GeomFromText('POINT(-8.01 31.64)', 4326), 180, 4),
  ('Hôpital provincial Chichaoua','hopital', ST_GeomFromText('POINT(-8.77 31.54)', 4326), 140, 4),
  ('CHU Ibn Zohr Agadir',         'hopital', ST_GeomFromText('POINT(-9.58 30.42)', 4326), 620, 5),
  ('Hôpital Hassan II Agadir',    'hopital', ST_GeomFromText('POINT(-9.60 30.43)', 4326), 410, 5),
  ('Hôpital Mokhtar Soussi Taroudant','hopital', ST_GeomFromText('POINT(-8.88 30.47)', 4326), 200, 5),
  ('Hôpital Inezgane',            'hopital', ST_GeomFromText('POINT(-9.53 30.36)', 4326), 280, 5),
  ('Hôpital Moulay Youssef Casablanca','hopital', ST_GeomFromText('POINT(-7.62 33.59)', 4326), 540, 3),
  ('Hôpital régional Sidi Kacem', 'hopital', ST_GeomFromText('POINT(-5.71 34.22)', 4326), 160, 2),
  ('Hôpital Sidi Slimane',        'hopital', ST_GeomFromText('POINT(-5.93 34.27)', 4326), 130, 2),
  ('Hôpital Témara',              'hopital', ST_GeomFromText('POINT(-6.91 33.93)', 4326), 240, 1),
  ('Hôpital Skhirat',             'hopital', ST_GeomFromText('POINT(-7.03 33.85)', 4326), 110, 1);

-- Écoles (points) -- 60 lignes
INSERT INTO enjeux_exposes (nom, type_enjeu, geom, capacite, bassin_id) VALUES
  -- Bouregreg (15 écoles)
  ('École Al Massira Rabat',        'ecole', ST_GeomFromText('POINT(-6.85 34.01)', 4326), 420, 1),
  ('Collège Ibn Khaldoun Rabat',    'ecole', ST_GeomFromText('POINT(-6.83 34.03)', 4326), 680, 1),
  ('Lycée Mohammed V Rabat',        'ecole', ST_GeomFromText('POINT(-6.82 34.02)', 4326), 1200, 1),
  ('École Hassan II Rabat',         'ecole', ST_GeomFromText('POINT(-6.84 34.02)', 4326), 380, 1),
  ('École Al Fath Salé',            'ecole', ST_GeomFromText('POINT(-6.81 34.04)', 4326), 410, 1),
  ('Collège Al Andalous Salé',      'ecole', ST_GeomFromText('POINT(-6.80 34.05)', 4326), 540, 1),
  ('Lycée Al Khansa Salé',          'ecole', ST_GeomFromText('POINT(-6.79 34.04)', 4326), 920, 1),
  ('École de la Médina Rabat',      'ecole', ST_GeomFromText('POINT(-6.83 34.02)', 4326), 290, 1),
  ('École Akrach',                  'ecole', ST_GeomFromText('POINT(-6.80 34.05)', 4326), 340, 1),
  ('École Hay Riad',                'ecole', ST_GeomFromText('POINT(-6.85 33.98)', 4326), 450, 1),
  ('Collège Témara Centre',         'ecole', ST_GeomFromText('POINT(-6.91 33.93)', 4326), 590, 1),
  ('Lycée Skhirat',                 'ecole', ST_GeomFromText('POINT(-7.03 33.85)', 4326), 720, 1),
  ('École rurale Aïn Aouda',        'ecole', ST_GeomFromText('POINT(-6.78 33.84)', 4326), 180, 1),
  ('École Hay Salam Salé',          'ecole', ST_GeomFromText('POINT(-6.76 34.06)', 4326), 360, 1),
  ('Collège Bouregreg',             'ecole', ST_GeomFromText('POINT(-6.82 34.05)', 4326), 480, 1),
  -- Sebou (15 écoles)
  ('École Saadia Fès',              'ecole', ST_GeomFromText('POINT(-5.01 34.03)', 4326), 340, 2),
  ('Collège Al Quaraouiyine Fès',   'ecole', ST_GeomFromText('POINT(-5.00 34.04)', 4326), 580, 2),
  ('Lycée Moulay Idriss Fès',       'ecole', ST_GeomFromText('POINT(-4.99 34.02)', 4326), 920, 2),
  ('École Médina Fès',              'ecole', ST_GeomFromText('POINT(-4.98 34.06)', 4326), 280, 2),
  ('École Hassan II Meknès',        'ecole', ST_GeomFromText('POINT(-5.55 33.89)', 4326), 410, 2),
  ('Collège Ibn Sina Meknès',       'ecole', ST_GeomFromText('POINT(-5.56 33.90)', 4326), 540, 2),
  ('Lycée Royal Meknès',            'ecole', ST_GeomFromText('POINT(-5.54 33.88)', 4326), 880, 2),
  ('École Kénitra Centre',          'ecole', ST_GeomFromText('POINT(-6.58 34.26)', 4326), 470, 2),
  ('Collège Maamora Kénitra',       'ecole', ST_GeomFromText('POINT(-6.59 34.27)', 4326), 620, 2),
  ('Lycée Ibn Tofail Kénitra',      'ecole', ST_GeomFromText('POINT(-6.57 34.25)', 4326), 1050, 2),
  ('École Sidi Kacem',              'ecole', ST_GeomFromText('POINT(-5.71 34.22)', 4326), 320, 2),
  ('École Sidi Slimane',            'ecole', ST_GeomFromText('POINT(-5.93 34.27)', 4326), 360, 2),
  ('École Souk El Arbaa',           'ecole', ST_GeomFromText('POINT(-6.07 34.69)', 4326), 290, 2),
  ('École Mehdya',                  'ecole', ST_GeomFromText('POINT(-6.66 34.26)', 4326), 240, 2),
  ('Collège Mechra Bel Ksiri',      'ecole', ST_GeomFromText('POINT(-5.95 34.57)', 4326), 380, 2),
  -- Oum Er-Rbia (10 écoles)
  ('École Beni Mellal Centre',      'ecole', ST_GeomFromText('POINT(-6.36 32.34)', 4326), 420, 3),
  ('Collège El Khattabi Beni Mellal','ecole', ST_GeomFromText('POINT(-6.35 32.35)', 4326), 580, 3),
  ('Lycée Hassan II Beni Mellal',   'ecole', ST_GeomFromText('POINT(-6.37 32.33)', 4326), 910, 3),
  ('École Fkih Ben Salah',          'ecole', ST_GeomFromText('POINT(-6.58 32.50)', 4326), 380, 3),
  ('École Kasba Tadla',             'ecole', ST_GeomFromText('POINT(-6.27 32.59)', 4326), 310, 3),
  ('École Khouribga centre',        'ecole', ST_GeomFromText('POINT(-6.91 32.88)', 4326), 450, 3),
  ('Collège Oued Zem',              'ecole', ST_GeomFromText('POINT(-6.56 32.86)', 4326), 520, 3),
  ('École Azemmour',                'ecole', ST_GeomFromText('POINT(-8.34 33.29)', 4326), 280, 3),
  ('Lycée El Jadida',               'ecole', ST_GeomFromText('POINT(-8.50 33.23)', 4326), 870, 3),
  ('École Souk Sebt',               'ecole', ST_GeomFromText('POINT(-6.69 32.55)', 4326), 230, 3),
  -- Tensift (12 écoles, densité forte Ourika)
  ('École Médina Marrakech',        'ecole', ST_GeomFromText('POINT(-7.99 31.63)', 4326), 290, 4),
  ('Collège Yacoub El Mansour',     'ecole', ST_GeomFromText('POINT(-8.00 31.64)', 4326), 630, 4),
  ('Lycée Al Qadi Ayad Marrakech',  'ecole', ST_GeomFromText('POINT(-7.98 31.62)', 4326), 880, 4),
  ('École Gueliz Marrakech',        'ecole', ST_GeomFromText('POINT(-8.02 31.64)', 4326), 410, 4),
  ('École Setti Fadma Ourika',      'ecole', ST_GeomFromText('POINT(-7.79 31.26)', 4326), 180, 4),
  ('École Ourika centre',           'ecole', ST_GeomFromText('POINT(-7.81 31.35)', 4326), 220, 4),
  ('École Aghbalou Ourika',         'ecole', ST_GeomFromText('POINT(-7.78 31.30)', 4326), 140, 4),
  ('École Tahanaout',               'ecole', ST_GeomFromText('POINT(-7.94 31.36)', 4326), 270, 4),
  ('École Asni',                    'ecole', ST_GeomFromText('POINT(-7.96 31.25)', 4326), 200, 4),
  ('École Imlil',                   'ecole', ST_GeomFromText('POINT(-7.92 31.14)', 4326), 90, 4),
  ('École Chichaoua',               'ecole', ST_GeomFromText('POINT(-8.77 31.54)', 4326), 340, 4),
  ('École Essaouira',               'ecole', ST_GeomFromText('POINT(-9.77 31.51)', 4326), 410, 4),
  -- Souss-Massa (8 écoles)
  ('École Talborjt Agadir',         'ecole', ST_GeomFromText('POINT(-9.59 30.42)', 4326), 380, 5),
  ('Collège Hassan II Agadir',      'ecole', ST_GeomFromText('POINT(-9.60 30.43)', 4326), 520, 5),
  ('Lycée Anza Agadir',             'ecole', ST_GeomFromText('POINT(-9.62 30.45)', 4326), 760, 5),
  ('École Inezgane',                'ecole', ST_GeomFromText('POINT(-9.53 30.36)', 4326), 410, 5),
  ('École Taroudant centre',        'ecole', ST_GeomFromText('POINT(-8.88 30.47)', 4326), 320, 5),
  ('Collège Aoulouz',               'ecole', ST_GeomFromText('POINT(-8.18 30.68)', 4326), 240, 5),
  ('École Massa',                   'ecole', ST_GeomFromText('POINT(-9.43 30.05)', 4326), 180, 5),
  ('École Tiznit',                  'ecole', ST_GeomFromText('POINT(-9.73 29.70)', 4326), 290, 5);

-- Postes électriques (points) -- 20 lignes
INSERT INTO enjeux_exposes (nom, type_enjeu, geom, capacite, bassin_id) VALUES
  ('Poste 225kV Rabat-Bouregreg',  'poste_electrique', ST_GeomFromText('POINT(-6.81 34.03)', 4326), 225, 1),
  ('Poste 60kV Salé',              'poste_electrique', ST_GeomFromText('POINT(-6.78 34.05)', 4326), 60, 1),
  ('Poste 60kV Témara',            'poste_electrique', ST_GeomFromText('POINT(-6.90 33.93)', 4326), 60, 1),
  ('Poste 60kV Aïn Aouda',         'poste_electrique', ST_GeomFromText('POINT(-6.78 33.84)', 4326), 60, 1),
  ('Poste 225kV Fès',              'poste_electrique', ST_GeomFromText('POINT(-5.01 34.03)', 4326), 225, 2),
  ('Poste 60kV Meknès',            'poste_electrique', ST_GeomFromText('POINT(-5.55 33.89)', 4326), 60, 2),
  ('Poste 225kV Kénitra',          'poste_electrique', ST_GeomFromText('POINT(-6.58 34.27)', 4326), 225, 2),
  ('Poste 60kV Sidi Kacem',        'poste_electrique', ST_GeomFromText('POINT(-5.71 34.22)', 4326), 60, 2),
  ('Poste 60kV Sidi Slimane',      'poste_electrique', ST_GeomFromText('POINT(-5.93 34.27)', 4326), 60, 2),
  ('Poste 225kV Beni Mellal',      'poste_electrique', ST_GeomFromText('POINT(-6.36 32.34)', 4326), 225, 3),
  ('Poste 60kV Khouribga',         'poste_electrique', ST_GeomFromText('POINT(-6.91 32.88)', 4326), 60, 3),
  ('Poste 60kV El Jadida',         'poste_electrique', ST_GeomFromText('POINT(-8.50 33.23)', 4326), 60, 3),
  ('Poste 60kV Fkih Ben Salah',    'poste_electrique', ST_GeomFromText('POINT(-6.58 32.50)', 4326), 60, 3),
  ('Poste 225kV Marrakech',        'poste_electrique', ST_GeomFromText('POINT(-7.99 31.63)', 4326), 225, 4),
  ('Poste 60kV Tahanaout',         'poste_electrique', ST_GeomFromText('POINT(-7.94 31.36)', 4326), 60, 4),
  ('Poste 60kV Chichaoua',         'poste_electrique', ST_GeomFromText('POINT(-8.77 31.54)', 4326), 60, 4),
  ('Poste 225kV Agadir',           'poste_electrique', ST_GeomFromText('POINT(-9.59 30.42)', 4326), 225, 5),
  ('Poste 60kV Inezgane',          'poste_electrique', ST_GeomFromText('POINT(-9.53 30.36)', 4326), 60, 5),
  ('Poste 60kV Taroudant',         'poste_electrique', ST_GeomFromText('POINT(-8.88 30.47)', 4326), 60, 5),
  ('Poste 60kV Aoulouz',           'poste_electrique', ST_GeomFromText('POINT(-8.18 30.68)', 4326), 60, 5);

-- Barrages (points) -- 12 lignes
INSERT INTO enjeux_exposes (nom, type_enjeu, geom, capacite, bassin_id) VALUES
  ('Barrage Sidi Mohammed Ben Abdellah','barrage', ST_GeomFromText('POINT(-6.49 33.88)', 4326), 487, 1),
  ('Barrage Allal El Fassi',       'barrage', ST_GeomFromText('POINT(-4.55 34.20)', 4326), 71, 2),
  ('Barrage Idriss Ier',           'barrage', ST_GeomFromText('POINT(-4.78 34.27)', 4326), 1186, 2),
  ('Barrage El Wahda',             'barrage', ST_GeomFromText('POINT(-5.05 34.65)', 4326), 3800, 2),
  ('Barrage Al Massira',           'barrage', ST_GeomFromText('POINT(-7.65 32.50)', 4326), 2735, 3),
  ('Barrage Bin El Ouidane',       'barrage', ST_GeomFromText('POINT(-6.45 32.10)', 4326), 1300, 3),
  ('Barrage Ahmed El Hansali',     'barrage', ST_GeomFromText('POINT(-6.05 32.45)', 4326), 740, 3),
  ('Barrage Lalla Takerkoust',     'barrage', ST_GeomFromText('POINT(-8.13 31.36)', 4326), 70, 4),
  ('Barrage Yacoub El Mansour',    'barrage', ST_GeomFromText('POINT(-7.88 31.32)', 4326), 70, 4),
  ('Barrage Abdelmoumen',          'barrage', ST_GeomFromText('POINT(-9.05 30.70)', 4326), 215, 5),
  ('Barrage Aoulouz',              'barrage', ST_GeomFromText('POINT(-8.18 30.68)', 4326), 110, 5),
  ('Barrage Youssef Ben Tachfine', 'barrage', ST_GeomFromText('POINT(-9.42 29.85)', 4326), 303, 5);

-- Zones résidentielles (polygones) -- 35 lignes
INSERT INTO enjeux_exposes (nom, type_enjeu, geom, population_estimee, bassin_id) VALUES
  ('Quartier Hassan Rabat',         'zone_residentielle', ST_GeomFromText('POLYGON((-6.84 34.01, -6.81 34.01, -6.81 34.03, -6.84 34.03, -6.84 34.01))', 4326), 58000, 1),
  ('Quartier Agdal Rabat',          'zone_residentielle', ST_GeomFromText('POLYGON((-6.86 33.99, -6.83 33.99, -6.83 34.01, -6.86 34.01, -6.86 33.99))', 4326), 75000, 1),
  ('Quartier Hay Riad Rabat',       'zone_residentielle', ST_GeomFromText('POLYGON((-6.87 33.97, -6.83 33.97, -6.83 33.99, -6.87 33.99, -6.87 33.97))', 4326), 110000, 1),
  ('Médina Salé',                   'zone_residentielle', ST_GeomFromText('POLYGON((-6.81 34.03, -6.79 34.03, -6.79 34.06, -6.81 34.06, -6.81 34.03))', 4326), 120000, 1),
  ('Hay Salam Salé',                'zone_residentielle', ST_GeomFromText('POLYGON((-6.77 34.04, -6.74 34.04, -6.74 34.07, -6.77 34.07, -6.77 34.04))', 4326), 95000, 1),
  ('Akrach Témara',                 'zone_residentielle', ST_GeomFromText('POLYGON((-6.92 33.92, -6.89 33.92, -6.89 33.94, -6.92 33.94, -6.92 33.92))', 4326), 65000, 1),
  ('Skhirat centre',                'zone_residentielle', ST_GeomFromText('POLYGON((-7.04 33.84, -7.01 33.84, -7.01 33.86, -7.04 33.86, -7.04 33.84))', 4326), 42000, 1),
  ('Aïn Aouda',                     'zone_residentielle', ST_GeomFromText('POLYGON((-6.79 33.83, -6.76 33.83, -6.76 33.85, -6.79 33.85, -6.79 33.83))', 4326), 38000, 1),
  ('Médina Fès',                    'zone_residentielle', ST_GeomFromText('POLYGON((-4.99 34.05, -4.97 34.05, -4.97 34.07, -4.99 34.07, -4.99 34.05))', 4326), 180000, 2),
  ('Fès Saiss',                     'zone_residentielle', ST_GeomFromText('POLYGON((-5.02 34.00, -4.99 34.00, -4.99 34.02, -5.02 34.02, -5.02 34.00))', 4326), 230000, 2),
  ('Médina Meknès',                 'zone_residentielle', ST_GeomFromText('POLYGON((-5.56 33.90, -5.53 33.90, -5.53 33.92, -5.56 33.92, -5.56 33.90))', 4326), 95000, 2),
  ('Hamria Meknès',                 'zone_residentielle', ST_GeomFromText('POLYGON((-5.55 33.88, -5.53 33.88, -5.53 33.90, -5.55 33.90, -5.55 33.88))', 4326), 85000, 2),
  ('Kénitra centre',                'zone_residentielle', ST_GeomFromText('POLYGON((-6.59 34.25, -6.56 34.25, -6.56 34.28, -6.59 34.28, -6.59 34.25))', 4326), 145000, 2),
  ('Maamora Kénitra',               'zone_residentielle', ST_GeomFromText('POLYGON((-6.60 34.27, -6.57 34.27, -6.57 34.30, -6.60 34.30, -6.60 34.27))', 4326), 85000, 2),
  ('Sidi Kacem',                    'zone_residentielle', ST_GeomFromText('POLYGON((-5.72 34.21, -5.69 34.21, -5.69 34.23, -5.72 34.23, -5.72 34.21))', 4326), 75000, 2),
  ('Sidi Slimane',                  'zone_residentielle', ST_GeomFromText('POLYGON((-5.94 34.26, -5.91 34.26, -5.91 34.28, -5.94 34.28, -5.94 34.26))', 4326), 92000, 2),
  ('Beni Mellal centre',            'zone_residentielle', ST_GeomFromText('POLYGON((-6.37 32.33, -6.34 32.33, -6.34 32.36, -6.37 32.36, -6.37 32.33))', 4326), 220000, 3),
  ('Fkih Ben Salah',                'zone_residentielle', ST_GeomFromText('POLYGON((-6.59 32.49, -6.56 32.49, -6.56 32.51, -6.59 32.51, -6.59 32.49))', 4326), 110000, 3),
  ('Kasba Tadla',                   'zone_residentielle', ST_GeomFromText('POLYGON((-6.28 32.58, -6.25 32.58, -6.25 32.60, -6.28 32.60, -6.28 32.58))', 4326), 55000, 3),
  ('Khouribga centre',              'zone_residentielle', ST_GeomFromText('POLYGON((-6.92 32.87, -6.89 32.87, -6.89 32.90, -6.92 32.90, -6.92 32.87))', 4326), 230000, 3),
  ('Azemmour',                      'zone_residentielle', ST_GeomFromText('POLYGON((-8.35 33.28, -8.32 33.28, -8.32 33.30, -8.35 33.30, -8.35 33.28))', 4326), 42000, 3),
  ('El Jadida centre',              'zone_residentielle', ST_GeomFromText('POLYGON((-8.51 33.22, -8.48 33.22, -8.48 33.25, -8.51 33.25, -8.51 33.22))', 4326), 195000, 3),
  ('Médina Marrakech',              'zone_residentielle', ST_GeomFromText('POLYGON((-7.99 31.62, -7.97 31.62, -7.97 31.64, -7.99 31.64, -7.99 31.62))', 4326), 175000, 4),
  ('Gueliz Marrakech',              'zone_residentielle', ST_GeomFromText('POLYGON((-8.02 31.63, -7.99 31.63, -7.99 31.65, -8.02 31.65, -8.02 31.63))', 4326), 220000, 4),
  ('Setti Fadma village',           'zone_residentielle', ST_GeomFromText('POLYGON((-7.80 31.25, -7.78 31.25, -7.78 31.27, -7.80 31.27, -7.80 31.25))', 4326), 4500, 4),
  ('Aghbalou Ourika',               'zone_residentielle', ST_GeomFromText('POLYGON((-7.79 31.29, -7.77 31.29, -7.77 31.31, -7.79 31.31, -7.79 31.29))', 4326), 3200, 4),
  ('Tahanaout',                     'zone_residentielle', ST_GeomFromText('POLYGON((-7.95 31.35, -7.92 31.35, -7.92 31.37, -7.95 31.37, -7.95 31.35))', 4326), 38000, 4),
  ('Asni',                          'zone_residentielle', ST_GeomFromText('POLYGON((-7.97 31.24, -7.95 31.24, -7.95 31.26, -7.97 31.26, -7.97 31.24))', 4326), 6800, 4),
  ('Chichaoua centre',              'zone_residentielle', ST_GeomFromText('POLYGON((-8.78 31.53, -8.75 31.53, -8.75 31.55, -8.78 31.55, -8.78 31.53))', 4326), 32000, 4),
  ('Talborjt Agadir',               'zone_residentielle', ST_GeomFromText('POLYGON((-9.60 30.41, -9.57 30.41, -9.57 30.43, -9.60 30.43, -9.60 30.41))', 4326), 80000, 5),
  ('Anza Agadir',                   'zone_residentielle', ST_GeomFromText('POLYGON((-9.63 30.44, -9.60 30.44, -9.60 30.47, -9.63 30.47, -9.63 30.44))', 4326), 65000, 5),
  ('Inezgane',                      'zone_residentielle', ST_GeomFromText('POLYGON((-9.54 30.35, -9.51 30.35, -9.51 30.37, -9.54 30.37, -9.54 30.35))', 4326), 130000, 5),
  ('Dcheira',                       'zone_residentielle', ST_GeomFromText('POLYGON((-9.56 30.34, -9.53 30.34, -9.53 30.36, -9.56 30.36, -9.56 30.34))', 4326), 95000, 5),
  ('Taroudant centre',              'zone_residentielle', ST_GeomFromText('POLYGON((-8.89 30.46, -8.86 30.46, -8.86 30.48, -8.89 30.48, -8.89 30.46))', 4326), 88000, 5),
  ('Aoulouz',                       'zone_residentielle', ST_GeomFromText('POLYGON((-8.19 30.67, -8.16 30.67, -8.16 30.69, -8.19 30.69, -8.19 30.67))', 4326), 22000, 5);

-- Zones industrielles (polygones) -- 12 lignes
INSERT INTO enjeux_exposes (nom, type_enjeu, geom, population_estimee, bassin_id) VALUES
  ('Z.I. Bouknadel',                'zone_industrielle', ST_GeomFromText('POLYGON((-6.69 34.20, -6.66 34.20, -6.66 34.22, -6.69 34.22, -6.69 34.20))', 4326), 0, 1),
  ('Z.I. Aïn Atig',                 'zone_industrielle', ST_GeomFromText('POLYGON((-6.95 33.90, -6.92 33.90, -6.92 33.92, -6.95 33.92, -6.95 33.90))', 4326), 0, 1),
  ('Z.I. Sebou Kénitra',            'zone_industrielle', ST_GeomFromText('POLYGON((-6.62 34.24, -6.59 34.24, -6.59 34.26, -6.62 34.26, -6.62 34.24))', 4326), 0, 2),
  ('Z.I. Fès Sidi Brahim',          'zone_industrielle', ST_GeomFromText('POLYGON((-5.04 34.01, -5.01 34.01, -5.01 34.03, -5.04 34.03, -5.04 34.01))', 4326), 0, 2),
  ('Z.I. Meknès Mejat',             'zone_industrielle', ST_GeomFromText('POLYGON((-5.59 33.87, -5.56 33.87, -5.56 33.89, -5.59 33.89, -5.59 33.87))', 4326), 0, 2),
  ('Z.I. Khouribga',                'zone_industrielle', ST_GeomFromText('POLYGON((-6.94 32.86, -6.91 32.86, -6.91 32.88, -6.94 32.88, -6.94 32.86))', 4326), 0, 3),
  ('Z.I. Beni Mellal',              'zone_industrielle', ST_GeomFromText('POLYGON((-6.39 32.32, -6.36 32.32, -6.36 32.34, -6.39 32.34, -6.39 32.32))', 4326), 0, 3),
  ('Z.I. Azemmour',                 'zone_industrielle', ST_GeomFromText('POLYGON((-8.37 33.27, -8.34 33.27, -8.34 33.29, -8.37 33.29, -8.37 33.27))', 4326), 0, 3),
  ('Z.I. Sidi Bouzid Marrakech',    'zone_industrielle', ST_GeomFromText('POLYGON((-8.05 31.61, -8.02 31.61, -8.02 31.63, -8.05 31.63, -8.05 31.61))', 4326), 0, 4),
  ('Z.I. Tassila Agadir',           'zone_industrielle', ST_GeomFromText('POLYGON((-9.55 30.39, -9.52 30.39, -9.52 30.41, -9.55 30.41, -9.55 30.39))', 4326), 0, 5),
  ('Z.I. Aït Melloul',              'zone_industrielle', ST_GeomFromText('POLYGON((-9.50 30.33, -9.47 30.33, -9.47 30.35, -9.50 30.35, -9.50 30.33))', 4326), 0, 5),
  ('Z.I. Taroudant',                'zone_industrielle', ST_GeomFromText('POLYGON((-8.91 30.45, -8.88 30.45, -8.88 30.47, -8.91 30.47, -8.91 30.45))', 4326), 0, 5);

-- Zones agricoles (polygones) -- 18 lignes
INSERT INTO enjeux_exposes (nom, type_enjeu, geom, population_estimee, bassin_id) VALUES
  ('Plaine agricole Bouregreg',     'zone_agricole', ST_GeomFromText('POLYGON((-6.50 33.95, -6.30 33.95, -6.30 34.00, -6.50 34.00, -6.50 33.95))', 4326), 2500, 1),
  ('Maraîchage Zaër',               'zone_agricole', ST_GeomFromText('POLYGON((-6.65 33.75, -6.40 33.75, -6.40 33.85, -6.65 33.85, -6.65 33.75))', 4326), 4200, 1),
  ('Gharb céréales nord',           'zone_agricole', ST_GeomFromText('POLYGON((-6.30 34.75, -5.80 34.75, -5.80 34.90, -6.30 34.90, -6.30 34.75))', 4326), 12000, 2),
  ('Gharb betteraves',              'zone_agricole', ST_GeomFromText('POLYGON((-6.20 34.65, -5.85 34.65, -5.85 34.75, -6.20 34.75, -6.20 34.65))', 4326), 8500, 2),
  ('Plaine Saiss',                  'zone_agricole', ST_GeomFromText('POLYGON((-5.20 34.00, -4.80 34.00, -4.80 34.10, -5.20 34.10, -5.20 34.00))', 4326), 9800, 2),
  ('Mamora forestier',              'zone_agricole', ST_GeomFromText('POLYGON((-6.60 34.10, -6.20 34.10, -6.20 34.25, -6.60 34.25, -6.60 34.10))', 4326), 3500, 2),
  ('Tadla céréales',                'zone_agricole', ST_GeomFromText('POLYGON((-6.55 32.25, -6.25 32.25, -6.25 32.40, -6.55 32.40, -6.55 32.25))', 4326), 18000, 3),
  ('Tadla agrumes',                 'zone_agricole', ST_GeomFromText('POLYGON((-6.45 32.30, -6.30 32.30, -6.30 32.38, -6.45 32.38, -6.45 32.30))', 4326), 7500, 3),
  ('Doukkala céréales',             'zone_agricole', ST_GeomFromText('POLYGON((-8.30 33.10, -8.00 33.10, -8.00 33.25, -8.30 33.25, -8.30 33.10))', 4326), 15000, 3),
  ('Plaine Tessaout',               'zone_agricole', ST_GeomFromText('POLYGON((-7.40 32.15, -7.10 32.15, -7.10 32.30, -7.40 32.30, -7.40 32.15))', 4326), 5800, 3),
  ('Haouz olives',                  'zone_agricole', ST_GeomFromText('POLYGON((-8.10 31.55, -7.90 31.55, -7.90 31.60, -8.10 31.60, -8.10 31.55))', 4326), 9200, 4),
  ('Haouz agrumes',                 'zone_agricole', ST_GeomFromText('POLYGON((-8.05 31.58, -7.85 31.58, -7.85 31.63, -8.05 31.63, -8.05 31.58))', 4326), 7800, 4),
  ('Plaine N''Fis maraîchage',      'zone_agricole', ST_GeomFromText('POLYGON((-8.15 31.50, -8.00 31.50, -8.00 31.58, -8.15 31.58, -8.15 31.50))', 4326), 4500, 4),
  ('Vallée Ourika cultures',        'zone_agricole', ST_GeomFromText('POLYGON((-7.83 31.28, -7.76 31.28, -7.76 31.45, -7.83 31.45, -7.83 31.28))', 4326), 6500, 4),
  ('Souss agrumes',                 'zone_agricole', ST_GeomFromText('POLYGON((-8.85 30.40, -8.50 30.40, -8.50 30.50, -8.85 30.50, -8.85 30.40))', 4326), 22000, 5),
  ('Souss bananes',                 'zone_agricole', ST_GeomFromText('POLYGON((-9.30 30.40, -9.10 30.40, -9.10 30.45, -9.30 30.45, -9.30 30.40))', 4326), 8500, 5),
  ('Massa maraîchage',              'zone_agricole', ST_GeomFromText('POLYGON((-9.45 30.05, -9.30 30.05, -9.30 30.12, -9.45 30.12, -9.45 30.05))', 4326), 5200, 5),
  ('Plateau Aoulouz',               'zone_agricole', ST_GeomFromText('POLYGON((-8.25 30.65, -8.10 30.65, -8.10 30.72, -8.25 30.72, -8.25 30.65))', 4326), 3800, 5);

-- =====================================================================
-- 9. ASSOCIATIONS ÉVÉNEMENT ↔ ENJEU (~40 liens)
-- =====================================================================
-- On lie quelques événements majeurs à leurs enjeux touchés
INSERT INTO evenement_enjeu (evenement_id, enjeu_id, niveau_impact, observations) VALUES
  -- Crue Bouregreg nov-2024 (id=1)
  (1, 1, 'mineur', 'Eaux pluviales en sous-sol'),
  (1, 2, 'mineur', 'Accès partiellement coupés'),
  (1, 21, 'majeur', 'Inondation parkings'),
  (1, 80, 'majeur', 'Habitations basses inondées (médina Salé)'),
  -- Crue Sebou Gharb mars-2025 (id=2)
  (2, 4, 'majeur', 'Sous-sols hôpital Idrissi inondés'),
  (2, 7, 'mineur', 'Accès routier coupé 3 jours'),
  (2, 25, 'majeur', 'Poste Kénitra arrêt 48h'),
  (2, 88, 'total', 'Gharb céréales submergé sur 80%'),
  (2, 89, 'total', 'Betteraves Gharb perdu'),
  (2, 50, 'majeur', 'Quartier Maamora évacué'),
  -- Crue éclair Ourika sept-2024 (id=3)
  (3, 64, 'total', 'École Setti Fadma détruite'),
  (3, 65, 'majeur', 'École Ourika centre fortement endommagée'),
  (3, 81, 'majeur', 'Village Setti Fadma touché'),
  (3, 82, 'majeur', 'Aghbalou Ourika partiellement inondé'),
  (3, 99, 'total', 'Cultures vallée Ourika détruites'),
  -- Inondation Tadla oct-2023 (id=4)
  (4, 7, 'mineur', 'Service maintenu en mode dégradé'),
  (4, 73, 'majeur', 'Beni Mellal centre partiellement inondé'),
  (4, 92, 'majeur', 'Tadla céréales endommagé'),
  -- Crue Agadir Souss déc-2024 (id=5)
  (5, 12, 'mineur', 'Étage technique inondé'),
  (5, 13, 'mineur', 'Coupure courant 6h'),
  (5, 85, 'majeur', 'Talborjt en partie évacué'),
  (5, 102, 'majeur', 'Souss agrumes endommagés'),
  -- Crue Rheraya mai-2024 (id=6)
  (6, 81, 'mineur', 'Trois maisons touchées'),
  -- Crue Kénitra fév-2024 (id=7)
  (7, 4, 'mineur', 'Sous-sol inondé'),
  (7, 78, 'majeur', 'Kénitra centre quartiers bas'),
  (7, 79, 'majeur', 'Maamora évacuation partielle'),
  -- Inondation Taroudant nov-2023 (id=8)
  (8, 14, 'mineur', 'Cour intérieure inondée'),
  (8, 90, 'majeur', 'Taroudant centre touché'),
  -- Crue Akrach déc-2023 (id=9)
  (9, 22, 'majeur', 'Akrach Témara fortement inondé'),
  (9, 9, 'mineur', 'Cour école Akrach inondée'),
  -- Crue Azemmour jan-2025 (id=10)
  (10, 76, 'majeur', 'Azemmour inondé'),
  (10, 77, 'mineur', 'El Jadida partie basse'),
  -- Épisode Ourika mai-2026 EN COURS (id=11) — peu d'impacts encore confirmés
  (11, 65, 'mineur', 'En cours d''évaluation'),
  -- Inondation Beni Mellal jan-2024 (id=12)
  (12, 73, 'mineur', 'Quartiers périphériques'),
  -- Crue Inaouène avr-2024 (id=13)
  (13, 84, 'mineur', 'Dégâts limités vallée'),
  -- Inondation Massa mars-2024 (id=14)
  (14, 107, 'moyen', 'Massa maraîchage touché'),
  -- Crue Bouregreg amont juin-2024 (id=15)
  (15, 90, 'mineur', 'Aïn Aouda partie basse');

-- =====================================================================
-- FIN DU SEED
-- Total : 5 bassins + 3 niveaux + 21 oueds + 41 zones d'aléa + 51 capteurs
--       + 30 mesures + 15 événements + ~157 enjeux + 37 associations
-- ≈ 360 lignes (proche de l'objectif 400)
-- Prochaine étape : exécuter 03_verification.sql
-- =====================================================================
