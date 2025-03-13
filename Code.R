# Installation et chargement des packages nécessaires
install.packages(c("AER", "plm", "ggplot2", "stargazer", "lmtest", "ggrepel", "car"))
library(AER)       
library(plm)       
library(ggplot2)   
library(stargazer) 
library(lmtest)    
library(ggrepel)
library(car)

data("Fatalities")
df <- Fatalities

# Sélection des variables pertinentes
df <- df[, c("state", "year", "fatal", "afatal", "drinkage", "beertax", "breath", 
             "jail", "service", "unemp", "income", "youngdrivers", "miles", "pop")]

# Créer une variable de taux de mortalité (normalisée par la population)
df$fatal_rate <- df$afatal / df$pop * 10000  

# Convertir les variables binaires en facteurs
df$state <- as.factor(df$state)
df$year <- as.factor(df$year)
df$breath <- as.factor(df$breath)  
df$jail <- as.factor(df$jail)      
df$service <- as.factor(df$service)


# Supprimer les données manquantes 
df <- na.omit(df)

# Tests de spécification
plmtest(fatal_rate ~ beertax + drinkage + breath + jail + service + unemp + income + youngdrivers,
        data = df, effect="indiv", type="bp") # Test de Breusch-Pagan pour effets individuels
plmtest(fatal_rate ~ beertax + drinkage + breath + jail + service + unemp + income + youngdrivers,
        data = df, effect="time", type="bp") # Test de Breusch-Pagan pour effets temporels
# pas d'effet significatif pour temporels'

# Résumé statistique des variables clés
df_subset <- df[, c("fatal_rate", "beertax", "drinkage", "unemp", "income", "youngdrivers")]
stargazer(df_subset, type = "text", title = "Statistiques Descriptives")

# Matrice de corrélation
cor_matrix <- cor(df[, c("beertax", "drinkage", "unemp", "income", "youngdrivers", "fatal_rate")])
print(cor_matrix)

# Modèle Pooled OLS (baseline)
Model_OLS <- plm(fatal_rate ~ beertax + drinkage + breath + jail + service + 
                unemp + income + youngdrivers, 
              data = df, model = "pooling", effect = "indiv")
summary(Model_OLS)

# Modèle à Effets Fixes (État + Année)
Model_Fixe <- plm(fatal_rate ~ beertax + drinkage + breath + jail + service + 
            unemp + income + youngdrivers, 
          data = df, model = "within", effect = "indiv")
summary(Model_Fixe)

# Modèle à Effets Aléatoires
Model_Aleatoire <- plm(fatal_rate ~ beertax + drinkage + breath + jail + service + 
            unemp + income + youngdrivers, 
          data = df, model = "random", effect = "indiv")
summary(Model_Aleatoire)

# Test de Hausman 
hausman_test <- phtest(Model_Fixe, Model_Aleatoire)
print(hausman_test)

# Test d'effets fixes (F-test)
pFtest(Model_Fixe, Model_OLS)  # Si significatif, FE est meilleur que Pooled OLS

# Test d'hétéroscédasticité (Breusch-Pagan)
bptest(Model_Fixe)

# Test d'autocorrélation (Wooldridge)
pbgtest(Model_Fixe)

vcov_Fixe <- coeftest(Model_Fixe, vcovHC(Model_Fixe, method = "arellano"))
vcov_Fixe

# Tableau comparatif des modèles
sigma2_OLS <- sigma(Model_OLS)^2
sigma2_Fixe <- sigma(Model_Fixe)^2
sigma2_Aleatoire <- sigma(Model_Aleatoire)^2

stargazer(Model_OLS, Model_Fixe, Model_Aleatoire, 
          type = "text",
          title = "Résultats des Estimations",
          column.labels = c("Modèle OLS", "Effets Fixes", "Effets Aléatoires"),
          covariate.labels = c("Taxe sur la bière", "Âge légal", "Alcootest (Oui)", 
                               "Prison (Oui)", "Service (Oui)", "Chômage", 
                               "Revenu", "Jeunes conducteurs"),
          add.lines = list(
            c("Sigma²", 
              round(sigma2_OLS, 3), 
              round(sigma2_Fixe, 3), 
              round(sigma2_Aleatoire, 3))
          ))

# Graphique 1 : Évolution temporelle du taux de mortalité et de la taxe sur la bière
ggplot(df, aes(x = year, y = fatal_rate, group = state, color = state)) +
  geom_line(alpha = 0.5) +
  stat_summary(aes(group = 1), fun = mean, geom = "line", size = 1.5, color = "red") +
  geom_text_repel(
    data = subset(df, year == 1988),
    aes(label = toupper(state)), 
    size = 3,
    direction = "y",
    segment.color = NA
  ) +
  labs(
    title = "Évolution du Taux de Mortalité Routière (1982-1988)",
    x = "Année",
    y = "Taux de mortalité (pour 10 000 habitants)"
  ) +
  scale_color_discrete(name = "État") +  
  theme_minimal()
