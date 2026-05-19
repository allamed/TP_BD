# Dashboard cartographique — Mode d'emploi

Ce dashboard est une page HTML autoportante qui se connecte en direct à votre base Supabase pour afficher les 6 couches du TP inondation sur une carte interactive. Pas de framework, pas de build, juste un fichier qu'on ouvre dans un navigateur.

---

## Installation en 4 étapes (5 minutes)

### 1. Charger les vues SQL dans Supabase

Dans le **SQL Editor** de Supabase, coller et exécuter le contenu de `06_views_geojson.sql`. Ça crée 6 vues qui exposent chaque couche dans un format consommable par l'API REST, et accorde les permissions de lecture au rôle public.

À la fin de l'exécution, le script affiche un tableau récapitulatif des niveaux d'alerte courants — c'est normal de voir quelques `ROUGE` (épisode Ourika).

### 2. Récupérer vos identifiants Supabase

Dans votre projet Supabase :

1. **Settings** (icône engrenage en bas à gauche) → **API**
2. Repérer deux valeurs dans la section "Project API keys" :
   - **Project URL** : `https://xxxxx.supabase.co`
   - **anon public** : une longue chaîne commençant par `eyJ...`

> ⚠️ La clé `anon` est faite pour être publique. La clé `service_role` qui est juste à côté **ne doit jamais** être copiée dans un fichier HTML — elle donne un accès complet à la base.

### 3. Configurer le fichier HTML

Ouvrir `dashboard.html` dans un éditeur de texte. Tout en haut du `<script>`, renseigner les deux constantes :

```javascript
const SUPABASE_URL = 'https://xxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJ...';
```

### 4. Ouvrir le fichier

Double-cliquer sur `dashboard.html` dans le navigateur, ou faire glisser le fichier dans une fenêtre de navigateur. Pas besoin de serveur local — la page consomme directement l'API HTTPS de Supabase.

---

## Ce que vous devriez voir

- **Carte du Maroc** centrée, avec les 5 bassins en bordures pointillées
- **Sidebar gauche** : statut opérationnel (épisode Ourika en cours en rouge en haut), stats des capteurs, ventilation des alertes, toggles des couches, liste des événements cliquable
- **Légende** en bas à droite pour les niveaux d'aléa
- Tous les éléments cliquables ouvrent une popup avec les détails

Les capteurs sont représentés par des pastilles colorées (vert OK / jaune / orange / rouge), avec leur initiale (P/L/M pour pluviomètre/limnimètre/météo). Les enjeux ponctuels (hôpitaux, écoles, postes, barrages) ont leur propre marqueur, les zones (résidentielles, industrielles, agricoles) sont en polygones colorés.

Cliquer sur un événement dans la sidebar zoome la carte dessus.

---

## En cas de problème

### "Le fichier doit être configuré avant la première utilisation."
Vous avez ouvert la page sans renseigner `SUPABASE_URL` et `SUPABASE_ANON_KEY`. Revenir à l'étape 3.

### "Erreur de connexion à Supabase" avec un code 401
La clé `anon` est incorrecte ou les permissions ne sont pas accordées. Vérifier que :
- La clé copiée est bien la `anon public` (pas `service_role`)
- Le script `06_views_geojson.sql` a bien été exécuté en entier (notamment les `GRANT SELECT ... TO anon`)

### "Erreur de connexion à Supabase" avec un code 404
L'URL est incorrecte, ou les vues n'existent pas. Vérifier dans le SQL Editor : `SELECT * FROM v_bassins_geojson LIMIT 1;` doit fonctionner.

### La carte se charge mais reste vide
Les vues existent mais ne renvoient pas de données. Vérifier que `02_seed.sql` a bien été exécuté en amont. Tester dans SQL Editor : `SELECT COUNT(*) FROM bassins_versants;` doit renvoyer 5.

### Les marqueurs des capteurs sont tous gris
Le champ `statut` n'est pas reconnu, ou le navigateur bloque les classes CSS dynamiques. Ouvrir la console développeur (F12) pour voir les erreurs.

---

## Pour aller plus loin pédagogiquement

Ce dashboard est volontairement simple et ouvert. Quelques pistes pour les participants curieux :

- **Ajouter un filtre par bassin** : un menu déroulant en haut de la sidebar qui filtre toutes les couches affichées.
- **Brancher l'API temps réel de Supabase** (Realtime) : Supabase peut pousser les nouvelles mesures dès qu'elles sont insérées. Le dashboard deviendrait *vraiment* temps réel sans avoir besoin de cliquer "Actualiser".
- **Heatmap des événements** : agréger toutes les zones d'événements en une carte de chaleur pour visualiser les "points chauds" historiques.
- **Routing** : afficher pour chaque hôpital le chemin le plus court vers le capteur le plus proche (pgRouting + Leaflet Routing Machine).

Ces extensions sont d'excellents sujets de projet de fin de formation.

---

## Note de sécurité

La clé `anon` de Supabase est conçue pour être exposée côté client. Elle ne donne accès qu'aux tables et vues sur lesquelles le rôle `anon` a explicitement reçu des permissions (et seulement aux opérations autorisées par les politiques RLS).

Pour ce TP, on a accordé `SELECT` sur 6 vues — c'est tout ce qui est exposé publiquement. Aucune donnée sensible n'est accessible. En production réelle, on ajouterait une authentification utilisateur et des politiques RLS plus fines.
