# Blindspot Report — slides_long

Date : 21 septembre 2026. Verdict : **HOLD sur le bloc empirique ménages (slides 27–29)** ; **CONDITIONAL pour le reste**.

Le récit économique est cohérent, mais la présentation associe désormais une méthode RAS actualisée à plusieurs résultats et libellés hérités d'une ancienne version. Il faut réconcilier ces versions avant de diffuser le bloc ménages comme résultat actuel. Ce verdict ne remet pas en cause, à lui seul, les conclusions qualitatives du papier.

## Périmètre et convention

Skill appliquée : [blindspot](C:/Users/jerem/.codex/skills/blindspot/SKILL.md). Lecture du TEX, examen visuel des 50 pages du PDF sous forme de planches, comparaison ciblée avec `main.tex` et les tables locales. Les références externes n'ont pas fait l'objet d'un audit bibliographique ; les estimations et pipelines n'ont pas été réexécutés. Ce rapport évalue les résultats présentés et leur interprétation, pas la correction du code.

Numérotation actuelle : 32 slides principales ; séparateur page PDF 33 ; annexes A1–A17, pages PDF 34–50. Le rapport du 17 septembre est conservé, mais ses numéros et plusieurs chiffres ne sont plus à jour. Aucun changement au TEX ou au PDF dans cet audit.

**DONE** : point examiné, correctement encadré à ce stade. **FLAG** : problème ou opportunité à traiter. P1 = avant diffusion ; P2 = amélioration importante ; P3 = approfondissement.

## Inventaire avant interprétation

| Ce qui est visible | Repère |
|---|---|
| Une hausse uniforme de 40 % donne un gap nul ; une hausse de l'énergie seule donne 1,6 point. | 5 |
| Le graphique des paniers inclut les loyers ; les indices de référence les excluent. | 7–8 |
| Le gap agrégé vaut 0,1 / 1,2 / 0,1 point ; les pays ont des signes et amplitudes différents. | 12, A7 |
| En 2023, l'alimentation contribue encore +0,7 point malgré un gap total de +0,1. | 13 |
| Les écarts d'âge et de résidence se resserrent après le pic ; certains classements s'inversent. | 14–15, 29 |
| Le contrefactuel français présente des raccordements brusques aux prix observés ; celui de l'électricité est explicitement imposé. | 19–20 |
| L'Italie a un effet positif sur l'inflation moyenne en 2023 (+0,7) et négatif sur le gap (−0,1). | 24 |
| La méthode annonce des parts de dépense réévaluée, mais l'histogramme annonce des parts de ménages pondérées par enquête. | 26–27 |
| Les traits de médiane de l'histogramme sont visuellement autour de 8,5 et 9,7 %, tandis que le texte indique 9,29 et 10,83 %. | 27 |
| La dispersion est présentée en IQR et les régressions affichent 152 440 observations par année. | 28–29 |
| Le burden affiché en 2022 est 12,3 % pour Q1 contre 6,1 % pour Q5. | 4, 30 |
| La granularité réduit le gap aux Pays-Bas mais l'augmente en Lituanie ; la couverture néerlandaise tombe à 87,8 % en D5. | A6 |
| L'exposition simulée au choc énergétique importé atteint 6,5 points en moyenne et +0,7 sur le gap. | A10 |

## Vice 1 — Les éléments présents mais insuffisamment expliqués

### FLAG · P1 — La slide 27 mélange deux versions du résultat

**Constat confirmé.** La slide 26 annonce des distributions pondérées par dépense réévaluée. La slide 27 indique pourtant « Survey-weighted household shares » et des médianes de **9,29 / 10,83 %**. Le papier utilise le même fichier graphique et décrit des parts de dépense réévaluée, un échantillon de 19 pays, et des médianes 2022 de **8,51 / 9,73 %**, soit une différence de **1,22 point** (`main.tex:1206–1223`).

C'est le signe le plus difficile à expliquer sous l'hypothèse d'une présentation entièrement actualisée : le texte sous l'image ne correspond plus aux marqueurs de l'image. L'explication à examiner en premier est un texte figé après remplacement du graphique, pas une propriété économique de la distribution.

**Action :** aligner le libellé, les médianes, le périmètre et la figure sur une même sortie. Dire explicitement « shares of revalued expenditure » si c'est bien l'objet retenu. Une médiane pondérée par dépenses n'est pas la médiane des ménages de la population. Ne pas appeler la différence entre deux médianes « effet médian individuel ».

### FLAG · P1 — Les slides 28–29 ne suivent pas la spécification actuelle

La slide 29 reproduit l'ancienne table `tables/tab_AT_BE_CY_DE_EE_EL_ES_FI_FR_HR_IE_IT_LT_LU_LV_MT_NL_PT_SI_SK_hbs_inflation_regressions_by_year.tex`. Le papier inclut maintenant le fichier se terminant par `_regressions.tex`, avec RAS, OLS non pondérés, éducation et **138 797 observations par année dans 17 pays** (`main.tex:1300–1312`).

| Résultat 2022 | Slide 29 | Table incluse dans le papier |
|---|---:|---:|
| Q5 relativement à Q1 | −1,50 | −1,291 |
| Moins de 30 ans relativement à 60+ | −1,37 | −1,253 |
| Villes relativement aux zones rurales | −1,17 | −1,083 |
| Observations | 152 440 | 138 797 |

Le changement n'est pas seulement un arrondi : coefficients, erreurs-types, contrôles et échantillon diffèrent. En 2023, l'écart villes/rural est désormais +0,3043 avec trois étoiles dans la table, contre +0,22 avec une étoile sur la slide.

La slide 28 conserve des IQR (4,43 → 3,01 → 2,90 en 2022 ; réduction affichée 3,64 %). La table de dispersion actuellement incluse dans le papier est une **ANOVA non pondérée**, où les caractéristiques représentent **6,63 % de la variance intra-pays** en 2022. L'audit ne retrouve pas de sortie actuelle justifiant les IQR affichés. **6,63 % ne doit pas remplacer mécaniquement 3,64 % : les métriques diffèrent.**

**Action :** actualiser la slide 29 à partir de la table effectivement retenue ; pour la slide 28, choisir entre une ANOVA actuelle et un recalcul des IQR sur le même échantillon. Actualiser aussi les commentaires de correction du QCM A16, qui citent les anciens coefficients ; les réponses C et D restent compatibles avec les nouveaux résultats.

### FLAG · P2 — La fermeture du contrefactuel français est un élément du résultat

Le raccordement brutal de l'électricité en 2024 est visible en slide 20 et explicitement qualifié de fermeture du modèle en slide 19. La slide 25 explique les effets de base, mais ne distingue pas visuellement une trajectoire documentée et cette fermeture imposée.

**Action :** annoter le raccordement sur la figure et préparer une sensibilité de calendrier pour les résultats postérieurs. Ne pas présenter la discontinuité comme une normalisation spontanée du marché. Ce point ne prouve pas une fragilité des résultats 2021–2023.

### FLAG · P2 — Le burden Q5 est incohérent au sein même du papier

Les slides 4 et 30 disent **6,1 %** en 2022. Le paragraphe de résultats de `main.tex:1277` dit **6,0 %**, tandis que l'introduction et la conclusion du papier conservent 6,1. C'est une incohérence confirmée, mais le chiffre à retenir doit être établi à partir de la sortie numérique RAS sous-jacente, pas choisi entre deux paragraphes.

**Action :** vérifier la valeur non arrondie et synchroniser papier, graphique et slides.

### DONE — Les signes et les sommes arrondies ne suffisent pas à diagnostiquer une erreur

L'effet positif italien sur l'inflation 2023 est compatible avec l'explication des effets de base en slide 25. Les totaux de contributions peuvent différer des sommes affichées à un chiffre après la virgule. Le résultat énergétique de A10 (+6,5 / +0,7) correspond au tableau actuel et au texte du papier : l'ancienne alerte du rapport du 17 septembre sur ce point n'est plus d'actualité.

## Vice 2 — Les éléments absents qui passent inaperçus

### FLAG · P1 — Il manque une passerelle entre populations et pondérations

Le public passe de 20 pays pour les groupes à 19 pour les distributions, 18 pour le burden et 17 pour les régressions actuelles. L'agrégation passe aussi des poids pays HICP aux dépenses réévaluées, aux poids d'enquête pour le burden, puis aux observations non pondérées pour les régressions. Le papier justifie ces choix, mais la présentation ne les rassemble pas.

**Action :** une courte note méthodologique, éventuellement en annexe, avec quatre lignes « objet / pays / pondération / exclusions ». Portugal : loyers non isolables dans les microdonnées ; Italie : revenu individuel indisponible pour les analyses par revenu ; Pays-Bas : éducation indisponible pour la spécification complète. Cela évite de lire des écarts entre résultats comme une contradiction ou un changement économique.

### FLAG · P2 — La sensibilité aux loyers reste sans ordre de grandeur dans les slides

Le graphique descriptif de la slide 7 inclut les loyers, alors que la slide 8 les exclut de l'indice. A1 documente la convention, sans montrer sa sensibilité. La table locale `tab_EA20_rent_mapping_robustness_2021_06_2023_06.tex` donne pour 2022 des gaps zone euro de 0,9 / 0,0 / 1,2 selon la convention, et des changements de signe dans certains pays.

**Limite essentielle :** cette table utilise des poids relatifs, pas le RAS de référence. Elle indique que la question mérite un contrôle ; elle ne constitue pas un test RAS toutes choses égales par ailleurs.

**Action :** préciser oralement le changement de panier descriptif vers panier retenu, puis préparer une sensibilité RAS homogène si l'on veut quantifier l'effet propre de l'exclusion des loyers.

### FLAG · P2 — Le poids des mesures calibrées dans le contrefactuel reste invisible

A4 mentionne les effets de prix calibrés, mais les résultats agrègent ceux-ci aux reconstructions fondées sur taxes ou tarifs. Le papier distingue ces couches (`main.tex:967–976`) ; la présentation ne quantifie pas leur contribution aux −1,4 point d'inflation et −0,5 point de gap en 2022.

**Action proposée, non réalisée :** comparer un scénario limité aux mesures directement reconstruites au scénario complet, puis varier les hypothèses des couches calibrées. Cette incertitude de scénario ne se résume pas à une erreur-type statistique.

### FLAG · P2 — La granularité n'est pas isolée de la couverture dans A6

Aux Pays-Bas, le gap micro passe de 3,0 en D3 à 1,9 en D5, tandis que la couverture passe de 99,9 % à 87,8 %. La slide le signale correctement, mais le public peut encore attribuer toute la différence à la finesse des produits.

**Action proposée :** calculer D3 et D5 sur une même intersection de produits et de ménages, puis séparer l'effet « détail » de l'effet « couverture ». À défaut, présenter cette comparaison comme un changement conjoint.

## Vertu 1 — Les questions que les résultats invitent à poser

### FLAG · P2 — Un gap presque nul peut masquer de fortes forces opposées

En slide 13, le total 2023 est +0,1 alors que l'alimentation contribue +0,7 ; d'autres postes compensent. L'exemple de la slide 5 enseigne qu'un choc uniforme ne produit pas de gap. Le tableau réel permet d'ajouter la réciproque qui ne tient pas : **un gap nul ne prouve pas que les chocs sont uniformes**.

**Exploitation :** souligner oralement la compensation en 2023 ; distinguer disparition du gap courant et disparition des écarts cumulés. Le QCM A17 demeure pertinent, même après suppression de l'ancienne slide sur les prix cumulés.

### FLAG · P2 — Un ciblage par produit peut être redistributif sans ciblage par revenu

Les slides 18 et 23 montrent surtout des mesures non ciblées et une réduction du gap portée par le gaz et l'électricité ; les carburants vont dans l'autre sens en 2022. C'est un mécanisme plus précis que « les politiques réduisent les inégalités ».

**Exploitation :** demander quelle composition du soutien explique son incidence relative. Cela ne démontre ni un meilleur ciblage budgétaire ni un gain de bien-être net : il manque les montants reçus par groupe et le financement.

### FLAG · P3 — Les classements sociaux peuvent dépendre du choc dominant

Le coefficient villes/rural devient positif en 2023, alors que les écarts d'âge restent négatifs. La table actuelle conserve cette inversion et la rend plus nette statistiquement. Cela invite à une décomposition par produits et pays sur un même échantillon, plutôt qu'à un classement permanent de groupes « vulnérables ».

## Vertu 2 — Les atouts insuffisamment exploités

### DONE — L'exemple à deux chocs isole clairement le mécanisme

La slide 5 maintient les paniers constants et fait varier uniquement les prix. Le contraste 1,6 point / zéro permet de comprendre les différences de prix relatifs avant les résultats. Les calculs sont cohérents.

### FLAG · P2 — L'identité d'agrégation micro est un véritable atout de validation

Le papier établit une identité entre moyenne pondérée des inflations individuelles et croissance de l'indice agrégé, avec poids proportionnels à dépense représentée × indice antérieur (`main.tex:1178–1191`). A2 expose seulement les marges RAS.

**Exploitation :** ajouter, si nécessaire en notes orales ou en annexe, une vérification de cette identité sur les mêmes microdonnées. Cela rend concret le lien micro–macro. Ne pas en déduire automatiquement l'égalité à l'HICP publié tous postes : prix, couverture et profils doivent aussi coïncider. A5 est un exercice de référence, pas à lui seul une validation complète du nouvel indice individuel hors loyers.

### DONE — La présentation sépare déjà plusieurs objets souvent confondus

La slide 3 distingue prix, revenus et patrimoine ; la slide 25 précise les limites du contrefactuel ; la slide 30 et A3 qualifient le burden d'exposition rapportée aux ressources de 2020. Ces précautions sont utiles et doivent être conservées. A12 précise également que son IQR américain n'est pas directement comparable à celui de la zone euro.

### FLAG · P3 — Le support reproductible peut rendre les versions vérifiables

Le lien vers le package en slide 11 donne une voie de réplication. Le problème actuel est précisément la coexistence de sorties anciennes et nouvelles. Une provenance commune pour chaque figure/table — méthode, échantillon, pondération, fichier de sortie — serait plus utile qu'un nouvel indicateur.

## Ordre de traitement recommandé

1. **Avant diffusion :** réconcilier les slides 27–29 avec la version actuelle ; contrôler les valeurs du burden et leurs reprises en slide 4 ; clarifier les quatre périmètres/pondérations.
2. **Ensuite :** annoter le raccordement du contrefactuel français ; distinguer granularité et couverture ; rendre explicite le rôle des couches calibrées et la sensibilité aux loyers.
3. **Pour renforcer le message sans ajouter beaucoup de slides :** exploiter les compensations en 2023, le ciblage par produit et l'identité d'agrégation.

Les FLAG de sensibilité sont des analyses proposées, pas des tests exécutés. L'absence d'un résultat dans la présentation n'établit pas qu'il n'existe nulle part dans le projet.

## Traçabilité

Empreintes SHA-256 des fichiers audités :

- `slides_long.tex` : `984D1B3E9820D21A71CBA2A4848D66968ED8196B7D135517687F98923C5A70A9`
- `slides_long.pdf` : `822F474BCDB81D4A3DEF7A9539B748D8103E15ADED59FFADE26FAF3DBBA56059`

Seul ce nouveau rapport est livré ; l'audit n'a modifié ni la présentation, ni le papier, ni les tables.
