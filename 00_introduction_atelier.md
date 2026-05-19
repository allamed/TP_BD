# Atelier après-midi — Conception en groupe d'une base spatiale

> Durée : **4 heures** · Format : 4 groupes en parallèle · Restitution croisée en fin de session

---

## L'esprit de l'atelier

Ce matin, vous avez **consommé** un schéma de base spatiale conçu pour vous. Cet après-midi, vous allez en **produire un**, de A à Z, en collaboration avec un LLM.

Chaque groupe travaille sur **une problématique différente** de gestion des risques (ou d'opérations critiques) au Maroc. À la fin de l'après-midi, chaque groupe défendra son travail devant les autres : c'est l'occasion de découvrir les choix de modélisation des trois autres groupes, leurs pièges, leurs astuces.

**Le message à garder en tête tout au long de l'atelier** :

> *Un LLM produit du SQL qui s'exécute. Pas nécessairement du SQL qui est juste. Le métier reste à vous.*

---

## Les 4 problématiques

| Groupe | Sujet | Géométrie dominante | Angle métier |
|--------|-------|---------------------|--------------|
| **A** | Post-séisme Al Haouz | Polygones + points | Gestion de crise après-coup |
| **B** | Tramway Casablanca / Rabat-Salé | Lignes (linestrings) | Opérations continues |
| **C** | Sécheresse et stress hydrique | Polygones administratifs | Surveillance chronique |
| **D** | Alerte tsunami côte atlantique | Mix complet | Anticipation et évacuation |

Chaque sujet a son énoncé dédié. **Lisez d'abord votre énoncé en entier avant de commencer.**

---

## Les livrables (identiques pour les 4 groupes)

À la fin des 4 heures, votre groupe doit produire :

### 1. Un fichier `schema.sql`

Le DDL complet de votre base : `CREATE EXTENSION postgis`, `CREATE TABLE`, contraintes, index GIST sur toutes les géométries, commentaires SQL pédagogiques sur les tables et colonnes non évidentes.

### 2. Un diagramme entité-relation

Capture d'écran du **Schema Visualizer** intégré à Supabase (Database → Schema Visualizer), à projeter pendant la défense. C'est votre support principal pour expliquer votre modélisation.

### 3. Un fichier `seed.sql`

Données simulées plausibles. **Environ 200 à 400 lignes au total**, réparties intelligemment entre vos tables. Vous n'avez pas besoin d'être exhaustifs — vous devez surtout couvrir les cas qui rendront vos requêtes intéressantes (au moins un événement "en cours", des données qui couvrent plusieurs zones, des cas limites pour tester les contraintes).

> ⚠️ Les coordonnées doivent rester géographiquement plausibles. Si votre sujet concerne Marrakech, ne mettez pas de points en Sibérie. Sinon votre dashboard final sera incompréhensible.

### 4. Un fichier `views.sql`

Au moins **4 vues GeoJSON** qui exposeront vos couches à votre dashboard. Modèle de référence : voir `06_views_geojson.sql` de ce matin.

### 5. Un `dashboard.html`

Une page HTML autoportante (sur le modèle de celui du matin) qui se branche à votre Supabase et affiche **au minimum** :
- Une carte avec vos couches principales (avec toggles)
- Une zone de stats latérales en rapport avec votre métier
- Des popups détaillés sur chaque entité

Vous êtes libres d'aller plus loin : filtres, recherche, graphiques, animations temporelles… Le dashboard du matin est un plancher, pas un plafond.

### 6. Cinq requêtes SQL "vitrines"

Choisissez 5 requêtes qui mettent en valeur la richesse de votre base. **Au moins 3 doivent être spatiales** (jointures via `ST_Intersects` / `ST_DWithin`, distances, surfaces, etc.). Ces requêtes seront jouées en live pendant la défense.

> 💡 C'est votre côté créatif : vous inventez les questions métier auxquelles votre base répond. Plus elles sont opérationnellement utiles, plus c'est convaincant.

---

## La stack recommandée

**Recommandée mais pas obligatoire** :

- **Base** : Supabase (PostgreSQL + PostGIS, gratuit, déjà familier depuis ce matin)
- **Front** : un fichier HTML + Leaflet, sur le modèle du dashboard du matin
- **IA pour la conception** : ChatGPT, Claude, Mistral, Gemini — au choix. Plusieurs en parallèle, c'est encore mieux pour comparer.

Si votre groupe veut tester autre chose (MapLibre, MapBox, QGIS Server, Django REST…), libre à vous — mais ne perdez pas de temps sur la stack, le cœur de l'évaluation porte sur la qualité de votre modélisation.

---

## Timing indicatif

| Phase | Durée | Activité |
|-------|-------|----------|
| **1. Cadrage** | 20 min | Lecture de l'énoncé, prise en main du sujet, premier prompt minimaliste à un LLM pour voir ce qu'il produit naïvement |
| **2. Prompt ingénieré** | 30 min | Rédaction d'un vrai prompt détaillé (sur le modèle du prompt du matin), test sur 2 LLMs en parallèle, comparaison |
| **3. Schéma final + import** | 60 min | Affinage manuel du schéma, choix de modélisation assumés, import dans Supabase, validation du diagramme E-R |
| **4. Seed** | 45 min | Génération du jeu de données simulées (souvent partiellement délégué à un LLM, mais à relire !) |
| **5. Vues + dashboard** | 60 min | Création des vues GeoJSON, adaptation du dashboard du matin à votre métier |
| **6. Préparation défense** | 25 min | Choix des 5 requêtes vitrines, répétition de la démo, désignation du porte-parole |

Le formateur passera dans chaque groupe régulièrement. **N'hésitez pas à l'appeler** dès que vous bloquez plus de 10 minutes sur un point.

---

## La défense (en fin d'après-midi)

Chaque groupe passe **10 à 12 minutes** devant les trois autres groupes :

1. **Présentation du métier** (1 min) : à qui sert votre base, dans quel contexte.
2. **Présentation du schéma E-R** (3 min) : projection du diagramme Supabase, explication des choix de modélisation et des compromis assumés.
3. **Démo dashboard** (3 min) : tour de la carte interactive, explication de ce qui s'y joue.
4. **Démo des 5 requêtes** (3 min) : on les joue en live dans le SQL Editor.
5. **Questions** (2-3 min) : les autres groupes et le formateur posent des questions.

**Tous les membres du groupe doivent prendre la parole** à un moment ou un autre. Ce n'est pas une présentation par un porte-parole unique.

---

## Quelques principes pédagogiques à garder en tête

1. **L'IA est un partenaire, pas un oracle.** Vous validez tout ce qu'elle produit. Si elle vous donne un schéma sans PostGIS alors que vous lui en avez parlé, vous corrigez (et vous lui expliquez pourquoi).

2. **Documentez vos compromis.** Aucun schéma n'est parfait. Le critère n'est pas "avez-vous fait le bon choix ?", c'est "pouvez-vous justifier vos choix ?".

3. **La qualité prime sur l'exhaustivité.** Une base avec 6 tables bien pensées vaut mieux qu'une base avec 15 tables où la moitié sont mal calibrées.

4. **Ne réinventez pas le matin.** Reprenez les patterns du matin (vues GeoJSON, structure du dashboard, format du seed). Vous n'avez pas à tout refaire from scratch.

5. **Restez géographiquement réalistes.** Vos coordonnées doivent correspondre à la zone du sujet. Si vous mettez des écoles fictives à Marrakech, mettez-les dans des quartiers qui existent vraiment.

---

## Et après ?

À la fin des défenses, le formateur fera une synthèse transversale : qu'avez-vous tous les quatre fait pareil ? Quels patterns sont apparus indépendamment dans plusieurs groupes ? Quels sont les pièges récurrents ? C'est là que la valeur pédagogique du croisement entre les 4 sujets prendra tout son sens.

**Bonne conception.**
