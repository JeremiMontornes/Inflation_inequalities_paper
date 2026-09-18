# Blindspot Report — slides_long

Date : 17 septembre 2026. Verdict : **CONDITIONAL**.

La présentation peut soutenir une discussion académique des écarts d’exposition aux prix. Plusieurs conventions de mesure et hypothèses du contrefactuel doivent toutefois être rendues plus visibles pour que les résultats ne soient pas interprétés comme des pertes effectives de revenu ou des effets causaux complets.

Audit effectué selon la skill `C:/Users/jerem/.codex/skills/blindspot/SKILL.md`. Lecture du source, inspection visuelle des 52 pages du PDF, confrontation ciblée avec `main.tex` et les tables utilisées. Pas de réexécution des estimations, ni de vérification exhaustive des références externes. Aucun changement apporté au TEX ou au PDF. DONE signifie « point examiné et déjà correctement encadré » ; FLAG signale une question ouverte ou une amélioration proposée, pas nécessairement une erreur.

Repérage : les numéros désignent les slides affichées (1–36), puis A1–A15 pour les annexes. Le séparateur Appendix est la page PDF 33 ; les slides 33–36 occupent les pages PDF 34–37 ; A1 commence à la page PDF 38.

## Inventaire avant interprétation

| Élément observé | Slides |
|---|---|
| Le gap annuel Q1–Q5 passe de 0,1 à 0,9 puis 0,0 point ; en 2022, les pays sélectionnés vont de −1,1 à +4,6 points. | 12 |
| En 2023, alimentation +0,6 et autres contributions de signes opposés coexistent avec un total arrondi à zéro. | 13 |
| Les courbes par âge et résidence se rapprochent après le pic ; le coefficient villes/rural devient +0,22 en 2023. | 14–15, 31 |
| Les indices de prix cumulés étaient déjà distincts avant 2021. | 16 |
| Le contrefactuel électrique français rejoint brusquement l’observé en 2024 ; la fermeture est explicitement imposée. | 21–22 |
| L’effet sur l’inflation moyenne est positif en Italie en 2023 (+0,7), mais le gap Q1–Q5 reste réduit (−0,1). | 26 |
| L’histogramme 2022 est asymétrique à droite ; les médianes sont 9,29 et 10,83 %. | 29 |
| L’IQR passe de 4,43 à 3,01 après effets pays, puis 2,90 après contrôles individuels. | 30 |
| Le burden est 12,3 contre 6,1 % en 2022, pour un échantillon de 18 pays. | 32 |
| La granularité réduit le gap allemand (1,9 → 1,4), mais l’augmente aux Pays-Bas (1,7 → 3,6). | 33 |
| L’exposition simulée au choc d’importation énergétique atteint +6,0 points en moyenne et −0,1 point sur le gap. | A8 |

## Vice 1 — Ce qui est visible mais insuffisamment expliqué

### FLAG — Priorité 1 : le niveau de prix contrefactuel français dépend d’une fermeture imposée (21–22, 27)

La slide 21 dit bien que le retour à l’observé en février 2024 est une « model closure ». Le panneau électrique suivant montre ce raccordement, mais sans annotation à l’endroit de la rupture. C’est le trait visuel le plus difficile à défendre si le public interprète toute la courbe comme une trajectoire tarifaire documentée.

Explication à examiner d’abord : construction du scénario, avant toute histoire économique de normalisation du marché. La slide 27 explique correctement les effets de base ; elle ne permet pas de mesurer leur sensibilité à la date de fermeture.

Action : annoter le point de raccordement et distinguer trajectoire documentée et fermeture. Préparer une variante de date/raccordement pour les résultats après 2023. Ne pas présumer que cette sensibilité change les résultats annuels 2021–2023. Sur 21, préciser aussi la définition de Δ et la provenance des coefficients 0,82 et 1,02 : le tableau des références temporelles ne suffit pas à reconstruire les niveaux.

### FLAG — Priorité 1 : plusieurs objets portent le même nom de gap (12, 28, 31, 33)

Le gap agrégé est 0,9 point en 2022 ; la régression conditionnelle donne Q5–Q1 = −1,50. Ce n’est pas une contradiction : sens du contraste inversé, pondérations, loyers, échantillon et conditionnement diffèrent. De même, l’Allemagne apparaît à 0,9 en slide 12 et 1,4 au niveau D3 en slide 33.

Action : ajouter une phrase de transition : « Household regressions estimate conditional differences using non-rent indices; they do not reproduce the aggregate Q1–Q5 gap. » Le support signale déjà une partie de ces différences en slide 28 ; une petite table des périmètres les rendrait beaucoup plus faciles à retenir.

### FLAG — Priorité 2 : désaccord avec le texte du papier sur le choc importé (A8)

A8 reproduit −0,1 point, conforme à `tables/tab_shock_extraEU_import_prices_EA20_product_2022.tex`. Le texte actif de `main.tex` annonce −0,3 dans l’introduction et dans la discussion de la simulation. Un commentaire du TEX des slides signale déjà ce problème, mais il reste non résolu.

Action : identifier la version de résultat faisant référence et aligner le texte du papier. Ne pas changer la slide à −0,3 au seul motif que le papier fait référence : le tableau inclus dans ce même papier indique −0,1.

### DONE — Les changements de signe et les arrondis ne sont pas automatiquement des erreurs

La slide 27 explique pourquoi une mesure peut relever l’inflation ultérieure. Les différences modestes entre sommes de contributions affichées et totaux sont compatibles avec les arrondis ; elles ne justifient pas de modifier les données. Ajouter « Totals computed before rounding » sur 13, 19 et 25 éviterait des questions inutiles. L’annexe A8 contient déjà cette précaution.

## Vice 2 — Ce qui manque sans attirer l’attention

### FLAG — Priorité 1 : la sensibilité aux loyers est disponible, mais ses résultats sont absents (8, 28, 33, A5)

A5 expose les conventions sans donner leur ordre de grandeur. Or `tab_EA20_rent_mapping_robustness_2021_06_2023_06.tex` rapporte, à pondération relative identique :

| Gap 2022, points | Tous loyers | Loyers effectifs seuls | Hors loyers |
|---|---:|---:|---:|
| Zone euro | 0,9 | 0,0 | 1,2 |
| Allemagne | 0,9 | −0,6 | 1,4 |
| France | 0,1 | −0,7 | 0,2 |
| Pays-Bas | 1,8 | −0,4 | 2,7 |

Ces résultats ne sont pas une sensibilité RAS à méthode inchangée : la table utilise les poids relatifs. Ils montrent néanmoins qu’un choix de couverture peut modifier le signe et pas seulement le niveau du gap.

Action : compléter A5 avec cette table et sa méthode, puis mentionner oralement que le logement est une convention substantielle. Pour tester spécifiquement le résultat RAS de référence, refaire les variantes sous RAS ; cet audit ne l’a pas fait.

### FLAG — Priorité 1 : contribution des couches calibrées non quantifiée (20, 23–26)

Le papier distingue les mesures reconstruites à partir de taxes/tarifs et les effets agrégés calibrés faute d’informations détaillées. Les slides donnent uniquement leur combinaison. On ne voit donc pas quelle part des −1,3 point d’inflation et −0,4 point de gap en 2022 dépend de cette seconde couche.

Action : présenter en annexe un résultat « statutory/reference-price only », le résultat complet, puis leur différence. Le principe est même proposé dans un passage commenté de `main.tex` près de la description des couches calibrées. Il s’agit d’une analyse à produire, pas d’un résultat vérifié ici.

### FLAG — Priorité 1 : le burden peut être entendu comme une perte effective de revenu (4, 32, A2)

Le résultat combine inflation hors loyers et ratio consommation totale/revenu observé en 2020, winsorisé au percentile national 99. Il n’intègre pas l’évolution des revenus en 2021–2023. A2 et le papier le précisent, mais le chiffre apparaît dès la slide 4 sans cette définition.

Action immédiate : qualifier le chiffre de « scaled exposure using 2020 expenditure-to-income ratios », et afficher la formule près de la slide 32. Vérification à préparer : sensibilité aux très faibles revenus, au seuil de winsorisation, à un numérateur de consommation hors loyers et à la couverture des produits appariés. Le papier précise qu’aucun seuil minimal de dépense appariée n’est imposé. Ne pas appeler 12,3 % une baisse observée du revenu réel.

### FLAG — Priorité 2 : changer de granularité peut aussi changer la couverture (33)

La table source `tab_EU5_aggregation_bias_excluding_rents_harmonized.tex` précise que la couverture peut varier selon la source et le niveau COICOP. La slide ne reprend pas cette réserve. Le passage néerlandais de 1,7 à 3,6 ne peut donc pas être attribué sans précaution au seul effet de désagrégation.

Action : conserver la réserve de couverture et préparer une comparaison à univers de produits commun. Expliquer les D4 manquants plutôt que laisser « -- » sans légende.

## Virtue 1 — Les questions que les résultats invitent à poser

### FLAG — Opportunité forte : zéro gap agrégé n’est pas zéro inégalité (13, 30–31)

En 2023, le total Q1–Q5 est nul alors que l’alimentation contribue +0,6, que plusieurs produits compensent cette contribution et que l’IQR intra-pays reste à 1,86 point avant contrôles individuels. Le retournement villes/rural renforce ce message. Les périmètres micro et macro diffèrent : les rapprocher conceptuellement, pas les traiter comme une décomposition commune.

Message possible : « A zero income-quintile gap can coexist with substantial household inflation dispersion. » Cela relie directement les résultats par groupes à la partie micro et à la nouvelle slide scanner.

### FLAG — Opportunité forte : les politiques amortissent-elles aussi la queue supérieure ? (29)

La médiane ne décrit pas le long côté droit de la distribution. Les scénarios utilisent les mêmes ménages et paniers : calculer la distribution appariée de π observée − π contrefactuelle, puis les gains par décile d’exposition initiale, par pays et par quintile.

Cela permettrait de distinguer déplacement global et protection des ménages les plus exposés. La slide précise déjà correctement que la différence des médianes n’est pas la médiane des effets individuels. Ne pas déduire une réduction de dispersion du seul déplacement vers la gauche.

### FLAG — Opportunité : un choc énergétique ne produit pas mécaniquement un gap positif (13, A8)

Dans la simulation d’importations, la contribution logement énergétique est compensée par les transports et d’autres produits. C’est un contrepoint utile au récit de la slide 13. Il ne s’agit pas du même objet que la décomposition observée ; il peut néanmoins ouvrir une discussion des prix relatifs, des réseaux de production et de la composition du choc, sans assimiler simulation et décomposition causale.

## Virtue 2 — Les forces encore sous-exploitées

### DONE — Une comptabilité cohérente et des limites souvent bien formulées

La calibration aux poids HICP est clairement expliquée en 10. La portée « consommation » est annoncée dès 3. Le caractère descriptif des régressions, les effets de base, et la distinction flux d’inflation/niveau cumulé sont explicités. Ces précautions doivent être conservées.

### FLAG — Mieux montrer la validation sans la surinterpréter (10, A1, A10)

Le papier donne, pour l’Allemagne, une RMSE de 0,118 point avec RAS contre 0,166 avec poids relatifs, sur 88 mois. Ce résultat quantifie mieux l’apport que deux courbes presque superposées. A10 apporte une comparaison des profils par décile français.

Action : ajouter un petit encart textuel de validation, sans boîte décorative. L’alignement agrégé est en partie attendu du calibrage ; il ne prouve pas à lui seul que les écarts entre quintiles sont exacts. Distinguer validation agrégée et validation distributive.

### FLAG — Exploiter la structure appariée pour isoler les canaux (24–29)

L’utilisation des mêmes paniers dans les scénarios est une force pour isoler comptablement le canal direct des prix. La combinaison décomposition par produits × hétérogénéité pays permet de montrer pourquoi l’électricité/gaz et le carburant agissent différemment sur le gap. Cela soutient un résultat précis sur l’incidence des prix, sans établir que les mesures sont optimales une fois financement et revenus intégrés.

## Deux points de lecture complémentaires

- **FLAG — Séparateur Appendix :** il précède actuellement les slides 33–36 et donc la conclusion, alors que la numérotation principale continue. Ce placement vient des demandes successives de réorganisation ; ce n’est pas une erreur de résultat. Décider si 33–35 sont de la discussion principale ou des annexes, puis faire coïncider séparateur, conclusion et compteur. Aucun déplacement effectué ici.
- **DONE / réserve — FMI et cheapflation :** les différences de période et de définition des quintiles sont indiquées en 18 ; les marges sont bien présentées comme mécanisme possible en 35. Pour une comparaison chiffrée plus forte, il faudrait des périodes et périmètres harmonisés. Les graphiques FMI de paniers ne démontrent pas eux-mêmes les messages sur revenus/patrimoine : ceux-ci reposent sur le texte cité.

## Ordre d’action proposé

1. Montrer la sensibilité aux loyers déjà disponible et préciser la nature du burden dès sa première occurrence.
2. Distinguer contrefactuels documentés, couches calibrées et fermeture française ; préparer les sensibilités correspondantes.
3. Relier explicitement les estimands macro/micro et la couverture des comparaisons de granularité.
4. Résoudre le désaccord −0,1/−0,3 dans le papier et clarifier l’emplacement du séparateur.
5. Renforcer le fil narratif : compensation des contributions en 2023, dispersion persistante, effets appariés des politiques.

Le verdict CONDITIONAL concerne la visibilité des conventions et la portée des conclusions. Il ne constitue ni une certification de la chaîne de calcul, ni une demande d’arrêter le travail.
