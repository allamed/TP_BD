https://docs.google.com/presentation/d/1a1rH_2TMTzpP8X2bX6upEwUuyVXxcrz6WAS98o32euY/edit?usp=sharing
# Guide TP — Concevoir et interroger une base spatiale du risque d'inondation au Maroc

> Durée estimée : **2h30 à 3h** · Public : développeurs, SIGistes, débutants en BD
> Stack : PostgreSQL 15+ avec PostGIS, hébergé sur Supabase (gratuit)
> Dataset : fictif à but pédagogique, inspiré de la géographie marocaine réelle

---

## 0. Ce que vous allez apprendre

À la fin de ce TP, vous saurez :

1. **Concevoir** un schéma de base de données spatiale en collaboration avec un LLM, en évitant les pièges classiques d'une demande naïve.
2. **Charger** un dataset géospatial réaliste dans PostgreSQL/PostGIS.
3. **Écrire** des requêtes spatiales correctes — et surtout, **détecter** les requêtes qui semblent correctes mais sont fausses.
4. **Distinguer** les notions de SRID, projection, geometry vs geography, qui sont les sources d'erreur les plus fréquentes en spatial.
5. **Auditer** une réponse de LLM contenant du SQL spatial avec une checklist de 5 questions-réflexes.

**Le message central du TP** : *l'IA produit du code qui s'exécute, pas nécessairement du code qui est juste*. Le rôle du développeur ou du SIGiste reste critique. Vous allez en faire l'expérience plutôt que de l'entendre.

---

## 1. Préparation de l'environnement (10 min)

### 1.1 Créer un projet Supabase

1. Aller sur [supabase.com](https://supabase.com), créer un compte gratuit
2. **New project** → choisir un nom, un mot de passe (à garder), une région (Europe West)
3. Attendre 2 minutes que le projet s'initialise

### 1.2 Vérifier PostGIS

1. Dans la sidebar : **Database** → **Extensions**
2. Chercher `postgis` dans la barre de recherche
3. S'il n'est pas activé : cliquer sur le toggle pour l'activer

> Le script `01_schema.sql` tentera également l'activation automatiquement (`CREATE EXTENSION IF NOT EXISTS postgis`), mais il vaut mieux le faire en amont pour éviter toute surprise.

### 1.3 Ouvrir le SQL Editor

Dans la sidebar : **SQL Editor**. C'est là que vous collerez tous les scripts du TP.

---

## 2. Partie 1 — Concevoir un schéma avec un LLM (45 min)

### 2.1 Round 1 : le prompt minimaliste

Vous allez d'abord faire ce que la plupart des gens font naturellement : demander à un LLM de générer un schéma avec un prompt court et générique.

**Outils** : ouvrez **deux LLMs différents** dans deux onglets (par exemple ChatGPT et Claude, ou ChatGPT-4 et Mistral, peu importe).

**Le prompt à coller dans les deux** :

```
Conçois-moi une base de données PostgreSQL pour gérer le risque
d'inondation au Maroc. Donne-moi le schéma SQL complet.
```

C'est tout. Pas de contexte, pas de contraintes, pas d'exemples.

**Ce que vous devez observer** :

1. Lancez le prompt sur les deux LLMs.
2. **Notez le nombre de tables** que chacun a produit.
3. **Notez si chacun a utilisé PostGIS** ou s'il a stocké les coordonnées dans des colonnes `lat`/`lng` séparées.
4. **Comparez** : les deux schémas sont-ils identiques ? Très similaires ? Très différents ?
5. Si vous avez le temps, relancez le même prompt une deuxième fois sur le **même** LLM : obtenez-vous exactement la même réponse ?

**Mise en commun en plénière (5 min)** — on partagera ce qu'on a obtenu.

### 2.3 Round 2 : le prompt ingénieré

On va maintenant donner au LLM **tout ce qu'il a besoin de savoir** pour produire un schéma proche de celui d'un humain senior. Voici le prompt :

```
RÔLE
Tu es un architecte de bases de données géospatiales avec 15 ans
d'expérience en gestion du risque hydrologique. Tu maîtrises
PostgreSQL/PostGIS, les standards OGC, et la modélisation orientée
métier.

CONTEXTE MÉTIER
Une agence de bassin hydraulique marocaine a besoin d'une base de
données opérationnelle pour gérer le risque d'inondation. Elle a 3
types d'utilisateurs :

1. Service prévention : cartographie statique des aléas, identification
   des enjeux exposés, planification de l'aménagement.
2. Service surveillance temps réel : monitoring des pluviomètres et
   limnimètres, détection des dépassements de seuils.
3. Cellule de crise : gestion d'événements d'inondation (passés et en
   cours), suivi des enjeux touchés, retour d'expérience.

CONTRAINTES TECHNIQUES
- PostgreSQL 15+ avec extension PostGIS
- Toutes les géométries en SRID 4326 (WGS84, standard GPS)
- Types de géométries explicites (POINT, LINESTRING, POLYGON) — pas
  de GEOMETRY générique sauf cas justifié
- Index GIST sur toutes les colonnes géométriques
- Contraintes CHECK pour les valeurs énumérées critiques
- Clés étrangères avec stratégies de suppression réfléchies
- Horodatage TIMESTAMPTZ partout

INVARIANTS MÉTIER
- Les mesures de capteurs forment une table append-only (jamais
  d'UPDATE, seulement INSERT)
- Les niveaux d'alerte (jaune/orange/rouge) doivent être une table de
  référence, pas un ENUM (pour porter les couleurs et consignes
  associées et permettre l'ajout d'un niveau sans migration)
- Un événement d'inondation peut être en cours (date_fin NULL)
- Un capteur a un statut courant (actif/panne/maintenance/retiré)
- Les seuils d'alerte sont spécifiques à chaque capteur
- Une crue impacte plusieurs enjeux, et un enjeu peut être impacté
  par plusieurs crues sur le temps long (relation N:N avec niveau
  d'impact qualifié)

DONNÉES MAROCAINES À PRENDRE EN COMPTE
- 5 grands bassins versants : Bouregreg, Sebou, Oum Er-Rbia, Tensift,
  Souss-Massa
- Oueds par bassin avec régimes différents (pérenne, temporaire,
  torrentiel)
- Enjeux exposés : hôpitaux, écoles, postes électriques, barrages,
  zones résidentielles, zones industrielles, zones agricoles

REQUÊTES QUE LA BASE DOIT POUVOIR SERVIR
- "Quels capteurs sont à moins de 5 km d'un oued torrentiel ?"
- "Combien de personnes sont exposées à un aléa fort dans la plaine
  du Gharb ?"
- "Pour chaque hôpital, quel est le capteur le plus proche ?"
- "Identifier les zones d'aléa fort sans aucun capteur actif dans un
  rayon de 5 km"
- "Pour chaque crue passée, lister les enjeux touchés et leur niveau
  d'impact"

LIVRABLE
Schéma SQL complet, en un seul fichier, avec :
- Création de toutes les tables avec contraintes
- Création des index (GIST inclus)
- Commentaires SQL sur chaque table et chaque colonne ambiguë
- Pas de données de test, juste le schéma

AVANT D'ÉCRIRE LE SQL
Liste-moi d'abord :
1. Les tables que tu prévois et leur rôle (1 phrase chacune)
2. Les compromis de modélisation que tu fais et pourquoi
```

**Ce qui change avec ce prompt** :

| Avant | Après |
|-------|-------|
| Le LLM invente | Le LLM applique des règles explicites |
| Variabilité énorme entre exécutions | Variabilité résiduelle mais bornée |
| Oubli de dimensions critiques (PostGIS, append-only, N:N) | Toutes les dimensions sont injectées dans le prompt |
| Pas de cahier des charges | Les requêtes cibles guident le modèle |

**À faire** : relancez ce prompt sur les **mêmes** deux LLMs qu'avant. Comparez :
- Le nombre de tables
- La présence/absence de PostGIS
- La table de référence pour les niveaux d'alerte
- La structure capteur/mesure

Vous devriez constater que les sorties **convergent fortement** vers une structure similaire — proche du schéma de référence que vous allez charger ensuite. Il restera des différences mineures (nommage, ordre des colonnes, choix précis sur la table des dégâts), mais l'architecture globale sera la même.

