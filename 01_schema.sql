-- =====================================================================
-- TP : Gestion du risque d'inondation au Maroc
-- Fichier 1/5 : Schéma de la base de données
-- =====================================================================
-- À exécuter en premier dans le SQL Editor de Supabase.
-- L'extension PostGIS est activée automatiquement ci-dessous.
-- =====================================================================

-- =====================================================================
-- 0. ACTIVATION DE POSTGIS
-- =====================================================================
-- Sur Supabase, les extensions vivent par convention dans le schéma
-- "extensions" (qui existe déjà par défaut). On y installe PostGIS.
-- Si la commande échoue, activer manuellement :
--   Supabase → Database → Extensions → chercher "postgis" → toggle ON
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA extensions;

-- On s'assure que le search_path inclut "extensions" pour que les
-- types et fonctions PostGIS (GEOMETRY, ST_*) soient trouvés sans
-- préfixe. Sur Supabase c'est en général déjà configuré, mais on
-- le force pour cette session au cas où.
SET search_path TO public, extensions;

-- Sécurité : tout reconstruire proprement si on relance
DROP TABLE IF EXISTS evenement_enjeu CASCADE;
DROP TABLE IF EXISTS mesures CASCADE;
DROP TABLE IF EXISTS enjeux_exposes CASCADE;
DROP TABLE IF EXISTS evenements_inondation CASCADE;
DROP TABLE IF EXISTS capteurs CASCADE;
DROP TABLE IF EXISTS zones_alea CASCADE;
DROP TABLE IF EXISTS oueds CASCADE;
DROP TABLE IF EXISTS niveaux_alerte CASCADE;
DROP TABLE IF EXISTS bassins_versants CASCADE;

-- =====================================================================
-- 1. RÉFÉRENTIELS
-- =====================================================================

-- Bassins versants : découpage hydrologique principal du Maroc
COMMENT ON SCHEMA public IS 'TP gestion risque inondation - dataset fictif à but pédagogique';

CREATE TABLE bassins_versants (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100) NOT NULL UNIQUE,
  code VARCHAR(10) NOT NULL UNIQUE,
  superficie_km2 NUMERIC(10,2),
  geom GEOMETRY(POLYGON, 4326) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_bassins_geom ON bassins_versants USING GIST(geom);

COMMENT ON TABLE bassins_versants IS 'Bassins hydrographiques (découpage simplifié)';
COMMENT ON COLUMN bassins_versants.geom IS 'Polygone en EPSG:4326 (degrés)';

-- Niveaux d'alerte : table de référence plutôt qu'un enum,
-- pour porter les couleurs et consignes associées
CREATE TABLE niveaux_alerte (
  code VARCHAR(10) PRIMARY KEY,
  libelle VARCHAR(50) NOT NULL,
  couleur_hex VARCHAR(7) NOT NULL,
  consigne TEXT NOT NULL,
  ordre INTEGER NOT NULL UNIQUE
);

COMMENT ON TABLE niveaux_alerte IS 'Référentiel des niveaux de vigilance (jaune/orange/rouge)';

-- =====================================================================
-- 2. RÉSEAU HYDROGRAPHIQUE
-- =====================================================================

CREATE TABLE oueds (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  bassin_id INTEGER NOT NULL REFERENCES bassins_versants(id),
  longueur_km NUMERIC(8,2),
  regime VARCHAR(20) CHECK (regime IN ('perenne','temporaire','torrentiel')),
  geom GEOMETRY(LINESTRING, 4326) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_oueds_geom ON oueds USING GIST(geom);
CREATE INDEX idx_oueds_bassin ON oueds(bassin_id);

COMMENT ON TABLE oueds IS 'Réseau hydrographique principal (linestrings simplifiés)';

-- =====================================================================
-- 3. ALÉA — cartographie statique du risque
-- =====================================================================

CREATE TABLE zones_alea (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(150),
  niveau VARCHAR(10) NOT NULL CHECK (niveau IN ('faible','moyen','fort')),
  periode_retour_ans INTEGER CHECK (periode_retour_ans IN (10,50,100,500)),
  bassin_id INTEGER REFERENCES bassins_versants(id),
  geom GEOMETRY(POLYGON, 4326) NOT NULL,
  date_etude DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_zones_alea_geom ON zones_alea USING GIST(geom);
CREATE INDEX idx_zones_alea_niveau ON zones_alea(niveau);

COMMENT ON TABLE zones_alea IS 'Zones d''aléa inondation (équivalent PPRI simplifié)';

-- =====================================================================
-- 4. SURVEILLANCE TEMPS RÉEL
-- =====================================================================

-- Capteurs : pluviomètres, limnimètres, stations météo
-- Compromis pédagogique : seuils et état courant fusionnés ici
CREATE TABLE capteurs (
  id SERIAL PRIMARY KEY,
  code VARCHAR(30) NOT NULL UNIQUE,
  type_capteur VARCHAR(20) NOT NULL CHECK (
    type_capteur IN ('pluviometre','limnimetre','station_meteo')
  ),
  unite VARCHAR(10) NOT NULL,
  bassin_id INTEGER REFERENCES bassins_versants(id),

  seuil_jaune NUMERIC(10,3),
  seuil_orange NUMERIC(10,3),
  seuil_rouge NUMERIC(10,3),
  CHECK (seuil_jaune IS NULL OR seuil_orange IS NULL OR seuil_jaune < seuil_orange),
  CHECK (seuil_orange IS NULL OR seuil_rouge IS NULL OR seuil_orange < seuil_rouge),

  derniere_valeur NUMERIC(10,3),
  derniere_mesure_at TIMESTAMPTZ,
  statut VARCHAR(20) NOT NULL DEFAULT 'actif'
    CHECK (statut IN ('actif','panne','maintenance','retire')),

  geom GEOMETRY(POINT, 4326) NOT NULL,
  installe_le DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_capteurs_geom ON capteurs USING GIST(geom);
CREATE INDEX idx_capteurs_type ON capteurs(type_capteur);
CREATE INDEX idx_capteurs_bassin ON capteurs(bassin_id);

COMMENT ON TABLE capteurs IS 'Réseau de capteurs (pluvio, limni, météo) avec seuils et état courant fusionnés';

-- Mesures : table append-only
CREATE TABLE mesures (
  id BIGSERIAL PRIMARY KEY,
  capteur_id INTEGER NOT NULL REFERENCES capteurs(id) ON DELETE CASCADE,
  valeur NUMERIC(10,3) NOT NULL,
  mesure_at TIMESTAMPTZ NOT NULL,
  niveau_declenche VARCHAR(10) REFERENCES niveaux_alerte(code),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_mesures_capteur_time ON mesures(capteur_id, mesure_at DESC);
CREATE INDEX idx_mesures_time ON mesures(mesure_at DESC);

COMMENT ON TABLE mesures IS 'Historique des mesures (append-only). Partitionner par mois en production.';

-- =====================================================================
-- 5. ÉVÉNEMENTS — gestion de crise
-- =====================================================================

CREATE TABLE evenements_inondation (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(150) NOT NULL,
  date_debut TIMESTAMPTZ NOT NULL,
  date_fin TIMESTAMPTZ,
  gravite VARCHAR(10) NOT NULL CHECK (gravite IN ('faible','moyen','fort','majeur')),
  bassin_id INTEGER REFERENCES bassins_versants(id),

  nb_victimes INTEGER DEFAULT 0 CHECK (nb_victimes >= 0),
  nb_personnes_evacuees INTEGER DEFAULT 0 CHECK (nb_personnes_evacuees >= 0),
  cout_estime_mad NUMERIC(15,2) CHECK (cout_estime_mad IS NULL OR cout_estime_mad >= 0),

  geom GEOMETRY(POLYGON, 4326) NOT NULL,

  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (date_fin IS NULL OR date_fin >= date_debut)
);
CREATE INDEX idx_evenements_geom ON evenements_inondation USING GIST(geom);
CREATE INDEX idx_evenements_dates ON evenements_inondation(date_debut, date_fin);

COMMENT ON TABLE evenements_inondation IS 'Crues identifiées (passées et en cours). Dégâts agrégés ici par simplicité.';

-- =====================================================================
-- 6. ENJEUX EXPOSÉS — polymorphe (points OU polygones)
-- =====================================================================

CREATE TABLE enjeux_exposes (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(150) NOT NULL,
  type_enjeu VARCHAR(30) NOT NULL CHECK (type_enjeu IN (
    'hopital','ecole','poste_electrique','barrage',
    'zone_residentielle','zone_industrielle','zone_agricole'
  )),

  -- Géométrie générique : accepte POINT et POLYGON
  -- Compromis pédagogique volontaire (à discuter en débrief)
  geom GEOMETRY(GEOMETRY, 4326) NOT NULL,

  capacite INTEGER,
  population_estimee INTEGER,
  bassin_id INTEGER REFERENCES bassins_versants(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_enjeux_geom ON enjeux_exposes USING GIST(geom);
CREATE INDEX idx_enjeux_type ON enjeux_exposes(type_enjeu);

COMMENT ON TABLE enjeux_exposes IS 'Enjeux humains et matériels. Géométrie polymorphe (POINT ou POLYGON).';

-- =====================================================================
-- 7. ASSOCIATION ÉVÉNEMENT ↔ ENJEU
-- =====================================================================

CREATE TABLE evenement_enjeu (
  evenement_id INTEGER NOT NULL REFERENCES evenements_inondation(id) ON DELETE CASCADE,
  enjeu_id INTEGER NOT NULL REFERENCES enjeux_exposes(id) ON DELETE CASCADE,
  niveau_impact VARCHAR(20) NOT NULL CHECK (niveau_impact IN ('mineur','moyen','majeur','total')),
  observations TEXT,
  PRIMARY KEY (evenement_id, enjeu_id)
);

COMMENT ON TABLE evenement_enjeu IS 'Association N:N événements/enjeux avec niveau d''impact';

-- =====================================================================
-- FIN DU SCHÉMA
-- Prochaine étape : exécuter 02_seed.sql
-- =====================================================================
