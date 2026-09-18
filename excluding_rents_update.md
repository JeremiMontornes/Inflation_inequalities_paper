# Mise à jour hors loyers — 18 septembre 2026

Documents : main.tex et slides_long.tex. Champ de référence : exclusion des loyers effectifs et imputés, COICOP 041 et 042. Les tableaux et figures régénérés du dépôt constituent la référence ; aucune hypothèse économique supplémentaire n'a été introduite.

## Résultats actualisés
- Inflation moyenne ZE 2021/2022/2023 : 2,7 / 9,0 / 5,6 %.
- Écart annuel Q1–Q5 : 0,1 / 1,2 / 0,1 point.
- Effet des politiques sur l'inflation moyenne : −0,1 / −1,4 / −0,3 point ; sur l'écart : −0,1 / −0,5 / −0,4 point.
- Choc de prix des importations énergétiques : +6,5 points d'inflation et +0,7 point d'écart Q1–Q5.
- Comparaison longue ZE–US : écart des indices base janvier 2002 = 100 en mai 2026, 4,5 points ZE et 17,3 points US. La couverture des deux sources demeure différente.
- Tableaux recopiés dans les slides : pays, contributions par produits, politiques et granularité actualisés. Les commentaires sur la granularité ont été révisés.
- Les résultats individuels (régressions, dispersion, exposition rapportée au revenu) étaient déjà hors loyers et restent inchangés.

## Méthode et graphiques
Les explications de pondération distinguent désormais explicitement les indices par groupe hors loyers avec RAS et les indices individuels à poids relatifs de dépense. Les validations officielles à champ complet et les variantes de sensibilité gardent leur champ de référence explicite. L'annexe H de long terme et son renvoi dans le corps sont conservés.

Deux graphiques propres au deck ont été régénérés avec les nouvelles données : comparaison ZE–US et écart observé/contrefactuel. Leurs scripts et données intermédiaires sont conservés dans scripts/ et fig/.

## Points non résolus dans les données sources
1. La table des catégories de politiques donne des effets totaux de −1,3 et −0,2 point en 2022 et 2023, contre −1,4 et −0,3 dans les tables par pays et produits. Les résultats principaux suivent ces dernières ; la table par catégories n'a pas été modifiée artificiellement. Les interactions entre catégories signalées dans les notes n'expliquent pas à elles seules cette différence entre totaux.
2. Le journal de reconstruction signale une trajectoire d'hypothèse manquante : NL_transport_fuel_excise_cut_2023_H1_calibrated (audit_missing_model_trajectories.csv). Pas de reconstruction ou de correction de cette hypothèse dans cette intervention.

Référence de production : build-figures-tables/outputs/rebuild_excluding_rents_20260917/README.md et sorties associées. Les chiffres américains sont ceux du CSV fourni, attribué par l'utilisateur à Jaravel (2024).

## Contrôles
Compilation des deux documents, vérification des renvois, contrôle visuel des pages et slides modifiés. Le manuscrit conserve des avertissements de mise en page préexistants.
