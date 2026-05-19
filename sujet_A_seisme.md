# Sujet A — Gestion post-crise d'un séisme majeur

> Groupe : **A** · Durée : 4h · À lire avant de commencer

---

## 1. Contexte métier

Le 8 septembre 2023, un séisme de magnitude 6,8 a frappé la région d'Al Haouz, dans le Haut Atlas marocain. Près de 3 000 victimes, des centaines de milliers de sinistrés, des centaines de villages partiellement ou totalement détruits dans des zones difficiles d'accès.

Vous êtes mandatés par la **Direction Générale de la Protection Civile (DGPC)** et l'**Agence pour le Développement du Haut Atlas (ADHA)** pour concevoir une **base de données opérationnelle de gestion post-crise sismique**. Cette base doit être utilisable dans les 72 heures qui suivent un futur séisme par trois types d'utilisateurs :

- **Les équipes de terrain** (Croix-Rouge, Protection Civile, FAR) qui ont besoin de savoir où aller en priorité, quels villages sont coupés, quels enjeux sont touchés, où acheminer secours et aide d'urgence.
- **La cellule de crise nationale** qui doit piloter l'allocation des moyens, suivre les bilans humains et matériels, coordonner les acteurs internationaux.
- **Les services de reconstruction** qui prennent le relais après les premières semaines : inventaire des sinistres, planification du relogement, suivi des chantiers.

La base doit servir aussi bien le **temps réel de la crise** (J+0 à J+30) que la **mémoire de long terme** (référentiel des séismes passés pour les études d'aléa).

---

## 2. Données disponibles à modéliser

Vous devez supposer disponibles les sources de données suivantes (pour l'atelier, vous générerez du seed simulé représentatif) :

### Données sismologiques (en flux temps réel)

- **Catalogue des séismes** : magnitude (échelle de Richter), profondeur du foyer, coordonnées de l'épicentre, datetime, intensité maximale observée (échelle MSK ou EMS-98). Données fournies par le CSEM-EMSC, l'Institut Scientifique de Rabat, l'USGS.
- **Carte d'intensité** : un séisme génère plusieurs zones isoséistes (polygones concentriques d'intensité décroissante depuis l'épicentre, mais déformées par la géologie).

### Données géographiques de base

- **Communes touchées** : périmètres administratifs, population estimée (INRH/HCP), densité, classe d'altitude.
- **Localités** (douars, villages) : nom, population, accessibilité (route praticable / piste / hélicoptère seulement), commune de rattachement.
- **Réseau routier principal** : tronçons avec leur statut (ouvert / coupé / partiellement praticable) — pour les équipes de terrain.

### Données enjeux

- **Bâtiments stratégiques** : hôpitaux, écoles, mosquées, sièges administratifs, prisons, casernes — chacun avec sa capacité d'accueil et son état après évaluation (intact / endommagé / détruit).
- **Habitat** : on ne modélise pas chaque maison, mais on dispose d'**estimations agrégées par localité** (nombre de logements habituels, % détruits, % endommagés, sans-abris estimés).

### Données opérationnelles de crise

- **Bilan humain par localité** : victimes (décès), blessés (graves / légers), disparus, déplacés. **Données sensibles, à modéliser avec attention RGPD.**
- **Camps d'évacuation** : localisation, capacité d'accueil théorique, occupation effective.
- **Distributions d'aide** : tentes, vivres, eau, kits hygiène — qui livre quoi à quelle localité et quand.
- **Équipes engagées sur le terrain** : nom de l'organisation, type d'équipe (médicale, BTP, recherche-sauvetage…), zone d'intervention assignée.

### Données historiques

- **Séismes anciens** dans la région : magnitude, date, dégâts estimés a posteriori. Utile pour les études d'aléa.

---

## 3. Cahier des charges fonctionnel

Votre base doit permettre de répondre à des questions opérationnelles du type :

- *"Quels villages sont encore inaccessibles par la route à J+5 ?"*
- *"Combien de sans-abris dans un rayon de 20 km autour de cette localité ?"*
- *"Quels hôpitaux fonctionnels sont les plus proches d'une zone de forte intensité ?"*
- *"Quelle est la couverture en distribution de tentes par commune ?"*
- *"Quels camps d'évacuation sont surchargés ?"*
- *"Reconstituer l'historique sismique de la région pour les 50 dernières années."*

Vous inventerez vos propres requêtes "vitrines" — ce sont vos 5 requêtes à présenter en défense.

### Contraintes techniques

- PostgreSQL + PostGIS, toutes les géométries en SRID 4326
- Index GIST sur toutes les colonnes géométriques
- Types de géométries explicites (POINT, LINESTRING, POLYGON)
- Une attention particulière aux **données personnelles** liées aux victimes et déplacés (RGPD / loi 09-08)

### Subtilités à anticiper

- Un séisme ne touche pas uniformément les zones à équidistance de l'épicentre : la géologie locale (effet de site) crée des amplifications. L'épicentre est un point, mais l'aléa est un polygone irrégulier.
- Le bilan évolue dans le temps : un blessé peut devenir un décès, un disparu peut être retrouvé. Comment modéliser cette évolution sans perdre l'historique ?
- Les villages du Haut Atlas n'ont pas tous un nom unique et standardisé. Plusieurs douars peuvent porter le même nom dans des communes différentes.

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

- Le **seed** ne doit pas inventer un séisme historique fictif : reprenez Al Haouz 2023 comme référence, avec des chiffres plausibles. Vous pouvez aussi ajouter des séismes anciens (Agadir 1960, Al Hoceïma 2004) en données de fond pour l'historique.
- Demandez-vous **dès le prompt initial** quelles tables vont contenir des données personnelles. Ce n'est pas une question à traiter à la fin.
- Pour le dashboard, pensez **vue cellule de crise** : ce qu'un coordonnateur en pleine crise veut voir en un coup d'œil sur grand écran.
- Le séisme Al Haouz est encore vif dans les esprits. **Restez dans un ton sobre et professionnel** sur les chiffres de victimes, sans dramatisation excessive ni minimisation.

---

## 6. Au-delà de l'énoncé

Si votre groupe avance vite, voici des extensions possibles :

- Une **série temporelle des bilans humains** par localité : reconstituer la courbe d'évolution des décès recensés au fil des jours suivant le séisme.
- Une **vue "héliports"** : où peut-on poser un hélicoptère médical à proximité de chaque village inaccessible par la route ?
- Une **intégration de réplique sismique** : les répliques peuvent ré-endommager des bâtiments fragilisés. Comment lier un séisme principal et ses répliques ?
- Une vue **avant/après** : comparer la cartographie d'aléa théorique pré-séisme avec les zones effectivement touchées. Utile pour les modèles futurs.

---

*Bonne conception. N'hésitez pas à appeler le formateur si vous bloquez.*
