# Sujet D — Système d'alerte tsunami sur la côte atlantique

> Groupe : **D** · Durée : 4h · À lire avant de commencer

---

## 1. Contexte métier

La côte atlantique marocaine est exposée à un risque tsunami réel mais rare. Le séisme de Lisbonne en 1755 (M ~8,7 au large du Cap Saint-Vincent) avait généré une vague qui a touché les côtes marocaines avec plusieurs mètres d'eau dans les ports. La zone sismique du **Golfe de Cadix** et la **faille de Gloria** restent actives. Une catastrophe similaire aujourd'hui mettrait en péril des millions de personnes et l'essentiel des infrastructures touristiques et portuaires du pays.

Vous êtes mandatés par la **Direction de la Météorologie Nationale (DMN)** et la **Direction Générale de la Protection Civile (DGPC)** pour concevoir une base de données spatiale d'aide à l'**alerte et à la planification d'évacuation tsunami**.

À la différence des autres sujets de gestion de risques (séisme post-coup, sécheresse chronique), votre temporalité métier est **l'anticipation et l'urgence** : entre la détection d'un séisme sous-marin et l'arrivée de la vague sur la côte marocaine, il s'écoule **30 à 90 minutes**. La base doit servir trois usages :

- **Préparation à froid** (en temps normal) : cartographie des zones de risque, recensement des enjeux exposés, planification des itinéraires d'évacuation, formation des populations côtières.
- **Activation en alerte rouge** (les 30 minutes qui suivent une détection sismique sous-marine) : identifier les zones à évacuer, prévenir les enjeux critiques, déclencher les sirènes.
- **Retour d'expérience** (après un éventuel événement réel) : analyser ce qui a fonctionné, mettre à jour les scénarios pour l'avenir.

---

## 2. Données disponibles à modéliser

### Données sismiques (en flux temps réel et historique)

- **Catalogue des séismes sous-marins** dans les zones génératrices de tsunamis pour le Maroc : magnitude, profondeur, coordonnées de l'épicentre, datetime, source sismique (faille de Gloria, golfe de Cadix, etc.).
- **Bulletins d'alerte** : pour chaque séisme qualifié, le centre d'alerte tsunami régional (NEAMTWS) émet un bulletin avec un niveau (information / advisory / watch / warning) et un délai d'arrivée estimé sur chaque portion de côte.

### Scénarios de submersion (pré-calculés à froid)

Vous **ne calculez pas** les scénarios — ils vous sont fournis par les ingénieurs hydrauliciens. Vous les modélisez et les stockez. Pour chaque scénario :

- **Identifiant et description** : ex. "Scénario M8.5 Gloria 200km", "Scénario M7.0 Cadix proche".
- **Zone source** : polygone de la source sismique.
- **Magnitude générant ce scénario**.
- **Zones submergées prévues** : un ou plusieurs polygones représentant la zone qui serait inondée par la vague selon ce scénario (avec une hauteur d'eau estimée, en mètres).
- **Temps d'arrivée estimé** sur différents points de la côte (en minutes après le séisme).

### Données géographiques côtières

- **Trait de côte** : polyligne du littoral atlantique marocain de Tanger à Lagouira.
- **Communes côtières** : nom, population, périmètre administratif.
- **Plages** : nom, longueur, fréquentation estimée (jour de pointe estival).
- **Ports** : commerciaux et de pêche, polygone du périmètre portuaire, activité.

### Enjeux exposés

Pour chaque enjeu, on a sa position **et son altitude approximative** (en mètres, attribut stocké directement en colonne — pas de MNT raster dans cet exercice) :

- **Population résidentielle** par zone côtière, avec une **estimation de l'altitude moyenne du quartier**.
- **Hébergements touristiques** : hôtels, résidences, campings — avec leur capacité d'accueil et leur altitude.
- **Infrastructures critiques** : hôpitaux, écoles, centrales électriques côtières, stations d'épuration, dessalement, raffineries.
- **Infrastructures portuaires** : grues, terminaux, navires habituellement à quai.

### Données d'évacuation

- **Points hauts d'évacuation** : lieux identifiés en hauteur (collines, étages élevés de bâtiments résistants, terrains surélevés) où la population peut se réfugier. Localisation, **altitude**, capacité d'accueil estimée.
- **Itinéraires d'évacuation pré-définis** : chemins recommandés (polylignes) reliant des zones d'habitation à des points hauts. Longueur, durée estimée à pied, type de revêtement.
- **Sirènes d'alerte** : positions des dispositifs de prévention sonore avec leur portée audible théorique.

---

## 3. Cahier des charges fonctionnel

Votre base doit permettre de répondre à des questions opérationnelles du type :

- *"Quelle population vit dans une zone submergée par le scénario M8.5 Gloria ET à une altitude inférieure à 10 mètres ?"*
- *"Pour chaque hôtel en zone exposée, quel est le point haut d'évacuation le plus proche et son altitude ?"*
- *"Quelles plages ont une capacité de fréquentation supérieure à la capacité des points hauts dans un rayon de 1 km ?"*
- *"Quels enjeux critiques (hôpitaux, écoles) sont en zone de submersion mais à une altitude > 15 m (donc finalement non concernés) ?"*
- *"Quelles zones de la côte ne sont couvertes par aucune sirène d'alerte audible ?"*
- *"Délai d'évacuation théorique le plus long observé entre une zone d'habitation et son point haut désigné."*

Vous inventerez vos propres requêtes "vitrines" — ce sont vos 5 requêtes à présenter en défense.

### Contraintes techniques

- PostgreSQL + PostGIS, toutes les géométries en SRID 4326
- Index GIST sur toutes les colonnes géométriques
- L'**altitude** est stockée comme **colonne classique** (`altitude_m NUMERIC`) sur les enjeux concernés. Vous ne manipulez pas de raster MNT dans cet atelier.

### Subtilités à anticiper

- Une zone "à risque tsunami" n'est pas une notion absolue : elle dépend du **scénario** considéré. Un enjeu peut être en zone de risque pour un scénario M8.5 et hors risque pour un scénario M7.0. Comment modéliser cette dépendance ?
- L'**altitude est critique** mais elle est rarement intégrée dans les premiers schémas qu'un LLM va vous proposer. Pensez-y dès le début.
- Les **itinéraires d'évacuation** sont des polylignes, mais ils doivent être **associés à des zones de départ** et à des **points d'arrivée**. Comment modéliser ces relations ?
- La **capacité d'accueil** des points hauts est une donnée saturable : si 5 000 personnes doivent évacuer vers un point haut de 800 places, c'est un problème. Comment représenter cette tension ?

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

- Pour le **seed**, concentrez-vous sur **une ou deux villes côtières** (par exemple Tanger + Agadir, ou Casablanca + Essaouira) plutôt que de couvrir toute la côte. Vous gagnerez en densité et en plausibilité.
- Définissez **2 ou 3 scénarios** différents (par exemple Gloria-M8.0, Cadix-M7.5, Gloria-M8.7) avec des zones de submersion volontairement différentes pour montrer la sensibilité au scénario.
- Pour les **altitudes**, des valeurs plausibles : centre-ville d'Agadir 5-10m, hauteurs d'Anza 60-120m, médina de Tanger 50-80m, plage de Saidia ~2m, hauteurs de la Vieille Montagne 100-180m.
- Votre **dashboard** se prête à un mode "centre d'alerte" très visuel : carte avec les scénarios sélectionnables (radio buttons), code couleur intensité, panneau "estimation des impacts du scénario sélectionné". Pensez à l'expérience utilisateur d'un opérateur qui doit décider en 5 minutes.
- Le tsunami est un risque **rare mais réel**. Ton sobre, ne théâtralisez pas. Mais montrez que vous prenez la gravité au sérieux.

---

## 6. Au-delà de l'énoncé

Si votre groupe avance vite, voici des extensions possibles :

- Une **vue "scénario actif"** : un sélecteur de scénario qui recalcule en direct le nombre de personnes touchées, les enjeux critiques en zone rouge, les points hauts requis. Très impressionnant en défense.
- **Saturation des points hauts** : pour chaque point haut, calculer la population qui *devrait* y évacuer (selon les itinéraires) et la comparer à sa capacité.
- Un **mode "compte à rebours"** : pour un séisme détecté à un moment donné, calculer en chaque point de la côte le délai restant avant arrivée de la vague.
- Une **carte des zones aveugles** : zones côtières habitées ni couvertes par une sirène, ni desservies par un itinéraire d'évacuation. Pépite opérationnelle.
- L'intégration d'un **historique des bulletins** : pour mémoire et REX, conserver tous les bulletins d'alerte émis, même ceux qui n'ont pas donné lieu à activation.

---

*Bonne conception. N'hésitez pas à appeler le formateur si vous bloquez.*
