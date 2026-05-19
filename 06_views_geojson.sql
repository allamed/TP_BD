-- =====================================================================
-- TP : Gestion du risque d'inondation au Maroc
-- Fichier 6/X : Vues GeoJSON pour le dashboard cartographique
-- =====================================================================
-- À exécuter après 02_seed.sql.
-- Crée 6 vues qui exposent chaque couche dans un format facilement
-- consommable par une application web via l'API REST de Supabase.
-- =====================================================================
-- POURQUOI DES VUES ?
-- Supabase auto-génère une API REST pour chaque table et chaque vue du
-- schéma public. Mais l'API ne sait pas convertir les géométries PostGIS
-- en GeoJSON toute seule. On crée donc des vues qui font cette
-- conversion en SQL (ST_AsGeoJSON), et le client web n'a plus qu'à
-- assembler les morceaux en FeatureCollections GeoJSON standard.
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- VUE 1 : Bassins versants
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_bassins_geojson AS
SELECT
  id,
  nom,
  code,
  superficie_km2,
  ST_AsGeoJSON(geom)::jsonb AS geom_json
FROM bassins_versants;

-- ─────────────────────────────────────────────────────────────────────
-- VUE 2 : Oueds (avec nom du bassin joint pour les popups)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_oueds_geojson AS
SELECT
  o.id,
  o.nom,
  o.regime,
  o.longueur_km,
  b.nom AS bassin_nom,
  ST_AsGeoJSON(o.geom)::jsonb AS geom_json
FROM oueds o
LEFT JOIN bassins_versants b ON o.bassin_id = b.id;

-- ─────────────────────────────────────────────────────────────────────
-- VUE 3 : Zones d'aléa (avec superficie calculée en km²)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_zones_alea_geojson AS
SELECT
  z.id,
  z.nom,
  z.niveau,
  z.periode_retour_ans,
  b.nom AS bassin_nom,
  ROUND((ST_Area(z.geom::geography) / 1000000)::numeric, 2)
    AS superficie_km2,
  ST_AsGeoJSON(z.geom)::jsonb AS geom_json
FROM zones_alea z
LEFT JOIN bassins_versants b ON z.bassin_id = b.id;

-- ─────────────────────────────────────────────────────────────────────
-- VUE 4 : Capteurs (avec niveau d'alerte courant dérivé des seuils)
-- ─────────────────────────────────────────────────────────────────────
-- Note pédagogique : on calcule le niveau d'alerte ICI, dans la vue,
-- plutôt que côté client. Centralise la logique métier au plus près
-- de la donnée. Si on change les règles, on change la vue.
CREATE OR REPLACE VIEW v_capteurs_geojson AS
SELECT
  c.id,
  c.code,
  c.type_capteur,
  c.unite,
  c.statut,
  c.derniere_valeur,
  c.derniere_mesure_at,
  c.seuil_jaune,
  c.seuil_orange,
  c.seuil_rouge,
  b.nom AS bassin_nom,
  CASE
    WHEN c.derniere_valeur IS NULL OR c.seuil_jaune IS NULL THEN NULL
    WHEN c.derniere_valeur >= c.seuil_rouge  THEN 'ROUGE'
    WHEN c.derniere_valeur >= c.seuil_orange THEN 'ORANGE'
    WHEN c.derniere_valeur >= c.seuil_jaune  THEN 'JAUNE'
    ELSE 'OK'
  END AS niveau_actuel,
  ST_AsGeoJSON(c.geom)::jsonb AS geom_json
FROM capteurs c
LEFT JOIN bassins_versants b ON c.bassin_id = b.id;

-- ─────────────────────────────────────────────────────────────────────
-- VUE 5 : Événements d'inondation (avec drapeau "en cours")
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_evenements_geojson AS
SELECT
  e.id,
  e.nom,
  e.date_debut,
  e.date_fin,
  e.gravite,
  e.nb_victimes,
  e.nb_personnes_evacuees,
  e.cout_estime_mad,
  e.description,
  (e.date_fin IS NULL) AS en_cours,
  b.nom AS bassin_nom,
  ST_AsGeoJSON(e.geom)::jsonb AS geom_json
FROM evenements_inondation e
LEFT JOIN bassins_versants b ON e.bassin_id = b.id;

-- ─────────────────────────────────────────────────────────────────────
-- VUE 6 : Enjeux exposés (POINT ou POLYGON dans la même table)
-- ─────────────────────────────────────────────────────────────────────
-- On expose le type géométrique réel pour que le client puisse choisir
-- entre un marqueur (POINT) et une couche polygonale (POLYGON).
CREATE OR REPLACE VIEW v_enjeux_geojson AS
SELECT
  e.id,
  e.nom,
  e.type_enjeu,
  e.capacite,
  e.population_estimee,
  b.nom AS bassin_nom,
  GeometryType(e.geom) AS geom_type,
  ST_AsGeoJSON(e.geom)::jsonb AS geom_json
FROM enjeux_exposes e
LEFT JOIN bassins_versants b ON e.bassin_id = b.id;

-- =====================================================================
-- AUTORISATIONS POUR L'API REST PUBLIQUE
-- =====================================================================
-- Sur Supabase, l'API REST utilise le rôle "anon" pour les requêtes
-- non authentifiées. Pour que le dashboard web puisse lire les vues,
-- il faut accorder explicitement le droit SELECT à ce rôle.
--
-- ATTENTION : ça expose ces vues en lecture publique. Pour un TP c'est
-- exactement ce qu'on veut. Pour une vraie application opérationnelle,
-- on passerait par une authentification utilisateur + RLS.

GRANT SELECT ON v_bassins_geojson    TO anon;
GRANT SELECT ON v_oueds_geojson      TO anon;
GRANT SELECT ON v_zones_alea_geojson TO anon;
GRANT SELECT ON v_capteurs_geojson   TO anon;
GRANT SELECT ON v_evenements_geojson TO anon;
GRANT SELECT ON v_enjeux_geojson     TO anon;

-- =====================================================================
-- VÉRIFICATION : la vue capteurs doit renvoyer quelques niveaux ROUGE
-- =====================================================================
SELECT niveau_actuel, COUNT(*) AS nb
FROM v_capteurs_geojson
WHERE niveau_actuel IS NOT NULL
GROUP BY niveau_actuel
ORDER BY niveau_actuel;
-- Attendu : quelques ROUGE (épisode Ourika), quelques ORANGE/JAUNE,
-- la majorité OK ou NULL.

-- =====================================================================
-- FIN
-- Prochaine étape : ouvrir dashboard.html dans un navigateur après
-- y avoir renseigné l'URL et la clé anon de votre projet Supabase.
-- =====================================================================
