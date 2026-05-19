# Sujet C — Surveillance de la sécheresse et du stress hydrique

> Groupe : **C** · Durée : 4h · À lire avant de commencer

---

## 1. Contexte métier

Le Maroc traverse depuis 2018 la pire sécheresse de son histoire récente. En 2024, plusieurs barrages étaient sous les 20 % de leur capacité, les nappes phréatiques continuent de baisser à un rythme alarmant dans le Saïss, le Souss, le Tadla. Le gouvernement a déclenché un plan d'urgence avec restrictions d'arrosage, transferts d'eau entre bassins, recours massif au dessalement.

Vous êtes mandatés par une **cellule de pilotage interministérielle** (Eau, Agriculture, Intérieur) pour concevoir une base de données de **surveillance du stress hydrique national**. À la différence des autres sujets de cet atelier, vous ne gérez pas un événement ponctuel : vous surveillez un **risque chronique** qui s'installe sur des mois ou des années.

Trois usages principaux :

- **Suivi opérationnel mensuel** par la cellule de pilotage : où en sont les barrages, les nappes, les pluies cumulées par rapport aux moyennes historiques. Détection des zones qui basculent en stress sévère.
- **Aide à la décision** pour le déclenchement des mesures restrictives : qui doit imposer quoi à qui (par commune, par bassin, par type d'usage agricole, industriel, domestique).
- **Reporting et alerte** vers le public et les médias : tableau de bord national, rapports mensuels au gouvernement, communication grand public sur les niveaux d'alerte.

---

## 2. Données disponibles à modéliser

### Données hydrologiques de fond

- **Barrages** : nom, bassin de rattachement, capacité totale (en millions de m³), localisation, date de mise en service, type (réservoir, en eau, écrêteur de crue).
- **Mesures de remplissage des barrages** : pour chaque barrage, des relevés réguliers (hebdomadaires ou mensuels) du volume actuel et du taux de remplissage. C'est une **série temporelle continue sur plusieurs années**.
- **Piézomètres** : capteurs mesurant le niveau des nappes phréatiques. Localisation, profondeur du puits, nappe surveillée.
- **Mesures piézométriques** : niveau de la nappe (mètres sous le sol), datetime de mesure. Série temporelle.
- **Stations pluviométriques** : localisation, altitude, période d'activité.
- **Mesures de pluviométrie** : pluviométrie cumulée par mois, par station. Disponible aussi sur **les 30 dernières années** comme historique de référence pour les moyennes.

### Données administratives

- **Bassins hydrographiques** : les 9 grands bassins du Maroc (Bouregreg, Sebou, Oum Er-Rbia, Tensift, Souss-Massa, Moulouya, Loukkos, Drâa, Guir-Ziz-Rheris-Bouânane).
- **Communes** : périmètres administratifs, population, classification (urbaine / rurale / périurbaine).
- **Périmètres irrigués** : grandes zones agricoles aménagées (les "ORMVA" — Office Régionaux de Mise en Valeur Agricole). Surface, type de cultures dominantes, source d'eau (barrage / nappe / mixte).

### Données opérationnelles

- **Niveaux d'alerte par commune** : pour chaque commune et chaque période (mois courant), un niveau de stress hydrique de 1 (vert) à 4 (rouge), déclenché à partir des indicateurs ci-dessus.
- **Mesures restrictives en vigueur** : interdiction d'arrosage des jardins, restriction d'irrigation agricole, coupures d'eau en horaires creux, etc. Avec leur périmètre d'application (commune, bassin, province) et leur période de validité.
- **Transferts d'eau** : les volumes d'eau transférés d'un bassin excédentaire vers un bassin déficitaire, avec origine, destination, dates, volumes.
- **Usines de dessalement** : localisation, capacité de production, statut (en service / en construction / en projet), zones desservies.

### Données d'usage et de demande

- **Demande agricole estimée** par périmètre irrigué et par saison (en millions de m³).
- **Consommation domestique** par commune (en m³/an/habitant ou agrégée).
- **Consommation industrielle** par zone industrielle ou par grand consommateur (cimenteries, mines, agroindustrie).

---

## 3. Cahier des charges fonctionnel

Votre base doit permettre de répondre à des questions opérationnelles du type :

- *"Quelles communes ont basculé en alerte rouge ce mois-ci par rapport au mois dernier ?"*
- *"Pour chaque bassin, quel est le taux de remplissage moyen des barrages en mai 2024 ?"*
- *"Quels périmètres irrigués sont alimentés par un barrage à moins de 30 % de sa capacité ?"*
- *"Comparer la pluviométrie cumulée des 12 derniers mois à la moyenne 30 ans, par bassin."*
- *"Quels piézomètres ont vu leur niveau baisser de plus de 5 mètres en 3 ans ?"*
- *"Population totale vivant en commune classée en alerte sévère ou rouge."*

Vous inventerez vos propres requêtes "vitrines" — ce sont vos 5 requêtes à présenter en défense.

### Contraintes techniques

- PostgreSQL + PostGIS, toutes les géométries en SRID 4326
- Index GIST sur les colonnes géométriques **et** index BTREE classiques sur les colonnes temporelles (les mesures vont être nombreuses)
- Le cœur du sujet est sur les **séries temporelles longues**, autant en stockage qu'en interrogation
- La notion de **moyenne historique sur 30 ans** doit pouvoir se calculer (ou être pré-calculée et stockée)

### Subtilités à anticiper

- Le **niveau d'alerte** d'une commune n'est pas une donnée d'entrée : c'est un **indicateur composite calculé** à partir de plusieurs sources (pluies, barrages amont, nappes locales, demande). Le stockez-vous comme valeur figée, ou comme vue dérivée ?
- La **fréquence des mesures** varie d'une source à l'autre (les barrages : hebdomadaires ; les nappes : mensuelles ; les pluies : journalières mais agrégées en mensuel). Comment gérer cette hétérogénéité ?
- Les **moyennes historiques** sont coûteuses à recalculer à chaque requête. Pensez aux **vues matérialisées** (concept qu'on n'a pas vu le matin).
- Un **bassin** peut couvrir plusieurs régions, et une commune peut être à cheval sur deux bassins. Comment trancher ?

---

## 4. Livrables attendus

Reportez-vous au document d'introduction (`00_introduction_atelier.md`) pour la liste complète des 6 livrables :

1. `schema.sql` — DDL complet avec PostGIS
2. Diagramme E-R via Supabase Schema Visualizer
3. `seed.sql` — données simulées (~200-400 lignes)
4. `views.sql` — au moins 4 vues GeoJSON
5. `dashboard.html` — adapté à votre métier
6. **5 requêtes vitrines** dont au moins 3 spatiales

---

## 5. Indications pédagogiques

- Pour le **seed**, ne vous noyez pas dans les séries temporelles : 12-24 mois d'historique sur quelques barrages suffisent à illustrer le propos. **N'essayez pas de simuler 30 ans de pluies sur 100 stations** : créez plutôt une table `moyennes_historiques` pré-agrégée pour les besoins du dashboard.
- Votre **dashboard** doit donner une lecture "carte de stress" du pays : communes colorées par niveau d'alerte, barrages avec leur taux de remplissage en marqueur de taille variable, panneau latéral avec les évolutions du mois. Pensez "carte météo de la sécheresse".
- C'est le sujet où le **piège du LLM est conceptuel** plus que technique : il va probablement vous proposer un modèle où le niveau d'alerte est une colonne fixe d'une table commune. **Réfléchissez à si c'est vraiment le bon design**.
- N'oubliez pas que la sécheresse touche des **populations réelles**. Votre dashboard doit aussi montrer combien de personnes sont concernées par les restrictions, pas juste des surfaces et des volumes.

---

## 6. Au-delà de l'énoncé

Si votre groupe avance vite, voici des extensions possibles :

- **Visualisation temporelle** : un slider qui permet de voir l'évolution des niveaux d'alerte mois par mois sur les 12 derniers mois. Très impactant visuellement.
- **Comparaison inter-bassins** : un graphique qui compare le taux de remplissage moyen des barrages des 9 bassins, en évolution sur 24 mois.
- **Carte des transferts d'eau** : des flèches sur la carte montrant les flux entre bassins excédentaires et déficitaires.
- Un **modèle d'alerte prospectif** : à partir des données actuelles, prédire les communes qui basculeront en rouge dans 3 mois si rien ne change.
- **Croisement avec les cultures sensibles** : identifier les périmètres irrigués où les cultures à forte consommation d'eau (canne à sucre, agrumes) sont concentrées dans des zones de stress.

---

*Bonne conception. N'hésitez pas à appeler le formateur si vous bloquez.*
