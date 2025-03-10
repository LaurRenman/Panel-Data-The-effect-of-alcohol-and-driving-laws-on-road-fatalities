# Installation et chargement des packages necessaires
install.packages (c("AER", "plm", "ggplot2", "stargazer", "Imtest", "ggrepel", "car"))
library (AER)
library (plm)
library(ggplot2)
library (stargazer)
library(lmtest)
library (ggrepel)
library (car)
data("'Fatalities")
df <- Fatalities
# Selection des variables pertinentes
df <- df[, c("state", "year", "fatal", "afatal", "drinkage",
"beertax", "breath",
"jail",
"service", "unemp", "income", "youngdrivers", "miles", "pop"›]
# Creer une variable de taux de mortalite (normalisee par la population)
df$fatal_rate ‹- df$afatal / df$pop * 10000
# Convertir les variables binaires en facteurs
df$state ‹- as. factor (df$state)
df $year ‹- as. factor (df$year)
df $breath ‹- as. factor (df$breath)
df$jail ‹- as. factor (df$jail)
df $service ‹- as. factor (df$service)
# Supprimer les donnees manquantes
df <- na.omit (df)
# Tests de specification
plmtest(fatal_rate ~ beertax + drinkage + breath + jail + service + unemp + income + youngdrivers,
data = df, effect="indiv", type="bp") # Test de Breusch-Pagan pour effets individuels
plmtest(fatal_rate ~ beertax + drinkage + breath + jail + service + unemp + income + youngdrivers,
data = df, effect="time", type="bp") # Test de Breusch-Pagan pour effets temporels
# pas d'effet significatif pour temporels'
# Resume statistique des variables cles
df_subset ‹- df [, c("'fatal_rate", "beertax"
, "drinkage", "unemp", "income", "youngdrivers")]
stargazer (df_subset, type = "text", title = "Statistiques Descriptives")
# Matrice de correlation
cor_matrix ‹- cor(af[, c("beertax", "drinkage", "unemp", "income", "youngdrivers", "fatal_rate")])
print (cor_matrix)
# Modele Pooled OLS (baseline)
Model_OLS <- plm(fatal_rate ~ beertax + drinkage + breath + jail + service +
unemp + income + youngdrivers,
data = df, model = "pooling", effect = "indiv")
summary (Model_OLS)
# Modele a Effets Fixes (Etat + Annee)
Model Fixe ‹- plm(fatal_ rate ~ beertax + drinkage + breath + jail + service +
unemp + income + youngdrivers,
data = df, model = "within", effect = "indiv")
summary (Model_Fixe)
