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
