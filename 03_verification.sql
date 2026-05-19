-- =====================================================================
-- TP : Gestion du risque d'inondation au Maroc
-- Fichier 3/5 : Vérification du chargement
-- =====================================================================
-- À exécuter après 02_seed.sql
-- Permet aux participants de vérifier que tout est bien chargé
-- =====================================================================

-- =====================================================================
-- 1. Comptage par table : doit correspondre à l'attendu
-- =====================================================================
SELECT 'bassins_versants' AS table_name, COUNT(*) AS nb_lignes,
       5 AS attendu,
       CASE WHEN COUNT(*) = 5 THEN '✓' ELSE '✗ INCORRECT' END AS statut
FROM bassins_versants
UNION ALL SELECT 'niveaux_alerte', COUNT(*), 3,
  CASE WHEN COUNT(*) = 3 THEN '✓' ELSE '✗ INCORRECT' END FROM niveaux_alerte
UNION ALL SELECT 'oueds', COUNT(*), 20,
  CASE WHEN COUNT(*) = 20 THEN '✓' ELSE '✗ INCORRECT' END FROM oueds
UNION ALL SELECT 'zones_alea', COUNT(*), 37,
  CASE WHEN COUNT(*) = 37 THEN '✓' ELSE '✗ INCORRECT' END FROM zones_alea
UNION ALL SELECT 'capteurs', COUNT(*), 51,
  CASE WHEN COUNT(*) = 51 THEN '✓' ELSE '✗ INCORRECT' END FROM capteurs
UNION ALL SELECT 'mesures', COUNT(*), 30,
  CASE WHEN COUNT(*) = 30 THEN '✓' ELSE '✗ INCORRECT' END FROM mesures
UNION ALL SELECT 'evenements_inondation', COUNT(*), 15,
  CASE WHEN COUNT(*) = 15 THEN '✓' ELSE '✗ INCORRECT' END FROM evenements_inondation
UNION ALL SELECT 'enjeux_exposes', COUNT(*), 177,
  CASE WHEN COUNT(*) = 177 THEN '✓' ELSE '✗ INCORRECT' END FROM enjeux_exposes
UNION ALL SELECT 'evenement_enjeu', COUNT(*), 37,
  CASE WHEN COUNT(*) = 37 THEN '✓' ELSE '✗ INCORRECT' END FROM evenement_enjeu;

-- =====================================================================
-- 2. Sanity checks géométriques : toutes les géométries doivent être valides
-- =====================================================================
SELECT
  'bassins_versants' AS table_name,
  COUNT(*) FILTER (WHERE NOT ST_IsValid(geom)) AS geom_invalides,
  COUNT(*) FILTER (WHERE ST_SRID(geom) != 4326) AS mauvais_srid
FROM bassins_versants
UNION ALL SELECT 'oueds',
  COUNT(*) FILTER (WHERE NOT ST_IsValid(geom)),
  COUNT(*) FILTER (WHERE ST_SRID(geom) != 4326)
FROM oueds
UNION ALL SELECT 'zones_alea',
  COUNT(*) FILTER (WHERE NOT ST_IsValid(geom)),
  COUNT(*) FILTER (WHERE ST_SRID(geom) != 4326)
FROM zones_alea
UNION ALL SELECT 'capteurs',
  COUNT(*) FILTER (WHERE NOT ST_IsValid(geom)),
  COUNT(*) FILTER (WHERE ST_SRID(geom) != 4326)
FROM capteurs
UNION ALL SELECT 'evenements_inondation',
  COUNT(*) FILTER (WHERE NOT ST_IsValid(geom)),
  COUNT(*) FILTER (WHERE ST_SRID(geom) != 4326)
FROM evenements_inondation
UNION ALL SELECT 'enjeux_exposes',
  COUNT(*) FILTER (WHERE NOT ST_IsValid(geom)),
  COUNT(*) FILTER (WHERE ST_SRID(geom) != 4326)
FROM enjeux_exposes;

-- Attendu : 0 partout pour geom_invalides et mauvais_srid

-- =====================================================================
-- 3. Cohérence métier : quelques contrôles spécifiques
-- =====================================================================

-- 3.1 Tous les capteurs avec seuils ont seuil_jaune < orange < rouge ?
SELECT 'capteurs avec seuils incohérents' AS test,
       COUNT(*) AS nb,
       CASE WHEN COUNT(*) = 0 THEN '✓' ELSE '✗' END AS statut
FROM capteurs
WHERE seuil_jaune IS NOT NULL
  AND seuil_orange IS NOT NULL
  AND seuil_rouge IS NOT NULL
  AND NOT (seuil_jaune < seuil_orange AND seuil_orange < seuil_rouge);

-- 3.2 Tous les enjeux ont bien une géométrie POINT ou POLYGON ?
SELECT 'enjeux avec géométrie inattendue' AS test,
       COUNT(*) AS nb,
       CASE WHEN COUNT(*) = 0 THEN '✓' ELSE '✗' END AS statut
FROM enjeux_exposes
WHERE GeometryType(geom) NOT IN ('POINT','POLYGON');

-- 3.3 Tous les événements terminés ont date_fin >= date_debut ?
SELECT 'événements avec dates incohérentes' AS test,
       COUNT(*) AS nb,
       CASE WHEN COUNT(*) = 0 THEN '✓' ELSE '✗' END AS statut
FROM evenements_inondation
WHERE date_fin IS NOT NULL AND date_fin < date_debut;

-- =====================================================================
-- 4. Aperçu spatial : voir si les données sont au bon endroit
-- =====================================================================

-- 4.1 Bounding box globale du dataset (doit grosso modo couvrir le Maroc)
-- Maroc approximatif : longitude [-13, -1], latitude [21, 36]
SELECT
  MIN(ST_XMin(geom)) AS lon_min,
  MAX(ST_XMax(geom)) AS lon_max,
  MIN(ST_YMin(geom)) AS lat_min,
  MAX(ST_YMax(geom)) AS lat_max
FROM bassins_versants;

-- 4.2 Tous les capteurs sont bien dans leur bassin déclaré ?
SELECT
  c.code,
  b.nom AS bassin_declare,
  CASE
    WHEN ST_Within(c.geom, b.geom) THEN '✓'
    ELSE '✗ HORS BASSIN'
  END AS coherence
FROM capteurs c
JOIN bassins_versants b ON c.bassin_id = b.id
WHERE NOT ST_Within(c.geom, b.geom)
LIMIT 10;
-- Si la table renvoie 0 lignes : tout est cohérent
-- Sinon : ces capteurs ont un bassin_id qui ne correspond pas à leur position

-- =====================================================================
-- 5. Premier aperçu visuel pour donner envie
-- =====================================================================

-- Top 5 des événements les plus coûteux
SELECT
  nom,
  TO_CHAR(date_debut, 'YYYY-MM-DD') AS date_debut,
  gravite,
  nb_victimes,
  nb_personnes_evacuees,
  TO_CHAR(cout_estime_mad, '999,999,999') AS cout_mad
FROM evenements_inondation
WHERE cout_estime_mad IS NOT NULL
ORDER BY cout_estime_mad DESC
LIMIT 5;

-- Nombre d'enjeux par type
SELECT type_enjeu, COUNT(*) AS nb
FROM enjeux_exposes
GROUP BY type_enjeu
ORDER BY nb DESC;

-- Nombre de capteurs en alerte (statut différent de 'actif')
SELECT statut, COUNT(*) AS nb
FROM capteurs
GROUP BY statut
ORDER BY nb DESC;

-- =====================================================================
-- FIN VÉRIFICATION
-- Si toutes les lignes "statut" affichent ✓ et qu'aucun problème
-- n'est remonté dans les sanity checks, on peut passer aux exercices !
-- =====================================================================
