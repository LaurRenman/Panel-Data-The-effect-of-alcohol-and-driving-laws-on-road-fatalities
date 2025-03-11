# Effet des lois sur l’alcool et la conduite sur la mortalité routière – Données de Panel  

## Question de recherche :  
Les politiques publiques sur l’alcool réduisent-elles significativement le nombre d’accidents mortels?  

---

## Description du Projet

Le projet examine l'importance de la taxe sur la bière et d'autres lois étatiques sur les taux annuels de mortalité par accident de la route entre 1982 et 1988. Les effets des conditions économiques prédominantes et des facteurs démographiques sont également pris en compte dans les modèles de régression de données de panel afin de comprendre les effets réels

---

## Méthodologie  
L’analyse repose sur des modèles économétriques avec différentes spécifications :  
- **Régression par Moindres Carrés Ordinaires (MCO)**  
- **Modèle à Effets Fixes**  
- **Modèle à Effets Aléatoires**  


---

## Données et Variables  

### Variable dépendante  
- **Taux de mortalité routière liée à l’alcool** (*fatal rate*) : Nombre de décès (*afatal*) divisé par la population de l’État, multiplié par 10 000 habitants (pour normaliser les comparaisons entre États).  

### Variables explicatives principales  
- **Taxe sur une caisse de bière** (*beertax*) : Montant en dollars.  
- **Âge légal minimal pour la consommation d’alcool** (*drinkage*) : De 18 à 21 ans.  
- **Lois sur l’alcootest préliminaire** (*breath*), **peines de prison obligatoires** (*jail*), **service communautaire** (*service*).  

### Variables de contrôle  
- **Taux de chômage** (*unemp*) : En pourcentage.  
- **Revenu annuel moyen par habitant** (*income*) : En dollars constants.  
- **Proportion de conducteurs âgés de 15 à 24 ans** (*youngdrivers*) : En pourcentage.  
---

## Structure du Projet  
Le dépôt GitHub contient :  
- `README.md` : Documentation du projet.  
- `Code.R` : Code du projet.
- `Data` : Données de Panel utilisées.
---

## Contributions  
Les contributions sont les bienvenues ! Veuillez ouvrir une *issue* ou une *pull request* pour discuter des améliorations. 
