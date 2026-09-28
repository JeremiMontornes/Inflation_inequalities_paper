# Inflation par quintile, zone euro, 2022 — présentation FMI

`generate_ea20_imf_quintiles_2022.R` produit une figure PDF vectorielle, une
image PNG à 240 dpi, un CSV des contributions et des fichiers de contrôle et
de provenance dans `fig/fig_EA20_2022_inflation_by_quintile_imf*`.

Depuis la racine du dépôt, sous PowerShell :

```powershell
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts/generate_ea20_imf_quintiles_2022.R
```

Pour refaire uniquement le graphique à partir du CSV fourni (R de base suffit) :

```powershell
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts/generate_ea20_imf_quintiles_2022.R --plot-only
```

Le recalcul complet utilise les dépôts voisins `build-figures-tables` et
`inflationinequality`, leurs dépendances R et leurs données locales HBS/IPCH.
Il est hors ligne ; aucun téléchargement n'est requis. Les variables
`INFLATION_BUILD_ROOT` et `INFLATIONINEQUALITY_PACKAGE_REPO` permettent de
modifier leurs emplacements. Les helpers existants peuvent actualiser leurs
caches et leur manifeste de sources HBS.

## Définition

- Zone euro à 20 pays, périmètre du papier hors loyers réels et imputés (041/042).
- Quintiles nationaux de revenu net total du ménage, agrégés par les poids pays
  IPCH ; ce ne sont pas des quintiles d'une distribution de revenu européenne.
- Paniers HBS et calibration RAS du pipeline canonique des tableaux 1 et 2.
  Les exceptions nationales et sources macro de secours restent celles du pipeline.
- Inflation : variation de l'indice moyen de 2022 par rapport à celui de 2021.
- Contributions annuelles : contributions mensuelles en glissement annuel
  pondérées par l'indice du même mois de 2021. Cette pondération assure
  l'égalité exacte entre la somme des contributions et le taux annuel.
- Ligne rouge : inflation de l'agrégat EA20 calculé séparément sur le même
  périmètre, et non moyenne simple des cinq quintiles.

## Présentation

La figure reprend les quatre catégories et l'ordre d'empilement de la figure
2.5 du *Fiscal Monitor* du FMI (avril 2023), disponible localement dans
`fig/imf_fm2023_figure2_5.png` :

| Catégorie | COICOP | Couleur |
|---|---|---|
| Alimentation et boissons non alcoolisées | 01 | Bleu `#4472C4` |
| Logement, eau, électricité, gaz et autres combustibles | 04, hors 041/042 | Orange `#ED7D31` |
| Transports | 07 | Gris `#A5A5A5` |
| Autres dépenses | Reste, y compris 05 | Vert `#00B050` |
| Inflation agrégée | Agrégat séparé | Rouge pointillé `#FF0000` |

Les couleurs sont reconstituées depuis l'image raster du FMI. Les panneaux
originaux couvrent 2021T2–2022T2 et utilisent des définitions de quintiles
propres aux pays ; ici la période est l'année civile 2022 et les définitions
sont celles du papier. L'axe vertical conserve l'échelle 0–16 de la référence.

Le script vérifie les douze mois de chaque année, les cinq quintiles,
l'absence de loyers, les identités de décomposition à 1e-9 près et la
concordance de l'inflation agrégée et de l'écart Q1–Q5 avec le tableau 2.
Les données individuelles ne sont pas exportées.
