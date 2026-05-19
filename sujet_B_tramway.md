# Sujet B — Gestion opérationnelle d'un réseau de tramway

> Groupe : **B** · Durée : 4h · À lire avant de commencer

---

## 1. Contexte métier

Casablanca exploite deux lignes de tramway depuis 2012, Rabat-Salé deux lignes depuis 2011. Une extension est en chantier dans chaque ville. Les régies de transport (**Casa Transports** et **STRS — Société du Tramway de Rabat-Salé**) ont besoin d'une base de données spatiale unifiée pour piloter l'exploitation au quotidien et préparer les extensions.

Vous êtes mandatés pour concevoir cette base, qui doit servir trois usages :

- **Pilotage opérationnel temps réel** : où sont les rames, quels sont les retards en ce moment, quels incidents en cours, quelle fréquentation sur quelle station.
- **Service voyageur** : alimenter une appli mobile et des bornes d'information avec les horaires théoriques, les temps d'attente estimés, les itinéraires conseillés en cas de perturbation.
- **Planification et analyse** : étudier la fréquentation par tranche horaire pour ajuster les fréquences, évaluer l'intermodalité avec les bus, préparer le tracé des futures extensions.

> ⚠️ Précision importante : ce sujet **n'est pas** un sujet de gestion de catastrophes naturelles comme les trois autres. Il porte sur des **opérations critiques continues** d'un réseau de transport public. Mais les défis spatiaux qu'il pose sont tout aussi formateurs.

---

## 2. Données disponibles à modéliser

### Données structurelles du réseau (semi-statiques)

- **Lignes** : nom (T1, T2, L1, L2…), ville (Casablanca / Rabat-Salé), tracé complet sous forme de polyligne, longueur totale, date de mise en service, opérateur.
- **Stations** : nom, position, ligne(s) desservie(s), accessibilité PMR (oui/non), services présents (parking, billettique, commerces…).
- **Tronçons** : les segments entre deux stations consécutives, avec leur longueur, leur durée de parcours théorique.
- **Dépôts** : où dorment et sont entretenues les rames la nuit, polygone du périmètre, capacité d'accueil.
- **Rames du parc** : numéro, modèle, capacité, date de mise en service, statut courant (en service / au dépôt / en maintenance).

### Données d'exploitation (temps réel et historique)

- **Horaires théoriques** : pour chaque jour-type (semaine, samedi, dimanche), passages prévus à chaque station, par ligne et direction.
- **Passages réels** : à chaque passage d'une rame dans une station, on enregistre l'heure réelle. Le delta avec l'horaire théorique donne le retard.
- **Incidents** : panne matérielle, accident, manifestation, travaux d'urgence — chacun avec lieu (point ou tronçon), datetime de début/fin, impact (ralentissement / arrêt total / déviation).
- **Fréquentation** : nombre de validations par station, par tranche horaire (15 minutes). Source : système billettique.

### Données contextuelles

- **Réseau de bus** : arrêts de bus à proximité du tram (pour l'intermodalité). On ne modélise pas les lignes de bus complètes, juste les arrêts géolocalisés.
- **Points d'intérêt à proximité** : gares ferroviaires, aéroports, universités, centres commerciaux, hôpitaux, stades — pour analyser ce qui structure la demande de déplacement.
- **Zones administratives** : préfectures, arrondissements, à des fins d'analyse de couverture territoriale.

### Données projet (extension future)

- **Tracés étudiés** des extensions à venir, sous forme de polyligne, avec un statut (à l'étude / approuvé / en travaux), un horizon de mise en service estimé.

---

## 3. Cahier des charges fonctionnel

Votre base doit permettre de répondre à des questions opérationnelles du type :

- *"Quelles sont les 10 stations les plus fréquentées de Casablanca aux heures de pointe du matin ?"*
- *"Pour chaque station, combien d'arrêts de bus dans un rayon de 300 mètres ? (mesure d'intermodalité)"*
- *"Quels incidents ont eu un impact supérieur à 30 minutes sur la ligne T1 ce dernier mois ?"*
- *"Quelle est la régularité moyenne (passages à l'heure) par station ?"*
- *"Quels points d'intérêt majeurs sont à plus de 500 mètres de toute station de tram (mal desservis) ?"*
- *"Évaluer le potentiel d'usagers supplémentaires d'une extension de ligne en cours d'étude."*

Vous inventerez vos propres requêtes "vitrines" — ce sont vos 5 requêtes à présenter en défense.

### Contraintes techniques

- PostgreSQL + PostGIS, toutes les géométries en SRID 4326
- Index GIST sur toutes les colonnes géométriques
- Les **lignes de tramway** sont des LINESTRING : c'est votre type géométrique central. Un soin particulier à porter au stockage de ce type.
- Les **tronçons** entre stations doivent être manipulables individuellement (pour l'analyse des perturbations).
- Les **séries temporelles** (passages réels, fréquentation) peuvent vite devenir volumineuses : pensez performance et indexation.

### Subtilités à anticiper

- Une station peut être desservie par **plusieurs lignes**. La représentation "une station par ligne" est plus simple mais redondante. Comment modéliser ?
- L'**ordre des stations** le long d'une ligne a son importance (le tram T1 passe par X *avant* Y). Comment garantir cet ordre dans le schéma ?
- Le **sens** de circulation : aller et retour ne suivent pas toujours exactement le même tracé (sens uniques sur certains tronçons).
- La **fréquentation** est forcément une donnée approximative et agrégée. Comment éviter de stocker du bruit ?

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

- Le **tracé des lignes de tram** est public et connaissable (cartes en ligne). Vous pouvez simplifier mais vos polylignes doivent **suivre les rues réelles** — pas couper à travers les bâtiments. Les SIGistes du groupe peuvent éventuellement extraire des tracés simplifiés depuis OpenStreetMap.
- Le **dashboard** se prête particulièrement bien à un **mode "PCC" (Poste de Commandement Centralisé)** : un opérateur voit en temps réel l'état du réseau, les retards par ligne, les incidents en cours. Pensez "salle de contrôle".
- Pour les **horaires** et la **fréquentation**, ne cherchez pas à seedeer des milliers de lignes : ~5-10 passages par station + un jour-type suffisent à montrer la mécanique.
- Inspirez-vous, pour les noms de stations, des **vrais noms** : Anoual, Place des Nations Unies, Bab Lamrissa, Hassan, etc. Ça rendra votre démo immédiatement crédible.

---

## 6. Au-delà de l'énoncé

Si votre groupe avance vite, voici des extensions possibles :

- **Calculer un "indice d'intermodalité"** par station, croisant le nombre d'arrêts de bus, de gares, et de POIs majeurs dans son rayon. Très intéressant à cartographier.
- **Modéliser les correspondances** entre lignes (les stations multi-lignes) et calculer pour chaque trajet le temps total estimé.
- Une **vue temporelle** : afficher la fréquentation par tranche horaire sous forme de graphique (avec Chart.js par exemple, importable dans le HTML).
- Une **analyse de couverture** : quel pourcentage de la population de Casa/Rabat habite à moins de 500m d'une station ? À moins de 1000m ?
- L'intégration d'un mode "perturbations en cours" qui calcule en temps réel les tronçons impactés.

---

*Bonne conception. N'hésitez pas à appeler le formateur si vous bloquez.*
