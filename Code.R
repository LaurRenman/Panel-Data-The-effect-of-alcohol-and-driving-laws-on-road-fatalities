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

# Graphique 2 : Barres pour l'Âge Légal 
df$age_group <- cut(df$drinkage,
                    breaks = c(18, 19, 20, 21, 22),
                    labels = c("[18,19)", "[19,20)", "[20,21)", "[21,22]"),
                    right = FALSE)

# Agréger les données par année et groupe d'âge
drinkage_summary <- aggregate(
  list(n_states = df$state),
  by = list(year = df$year, age_group = df$age_group),
  FUN = function(x) length(unique(x))
)

# Définir les couleurs pour chaque groupe d'âge 
df$age_group <- cut(df$drinkage,
                    breaks = c(18, 19, 20, 21, 22),
                    labels = c("[18,19)", "[19,20)", "[20,21)", "[21,22]"),
                    right = FALSE)

# Agréger les données
drinkage_summary <- aggregate(
  list(n_states = df$state),
  by = list(year = df$year, age_group = df$age_group),
  FUN = function(x) length(unique(x))
)

# Définir les couleurs exactes comme dans l'image
age_colors <- c(
  "[18,19)" = "#FF6B6B",    
  "[19,20)" = "#4ECDC4",    
  "[20,21)" = "#45B7D1",   
  "[21,22]" = "#FFD700"    
)

# Graphique final
ggplot(drinkage_summary, aes(x = year, y = n_states, fill = age_group)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(width = 0.8),
    width = 0.7,
    color = "black"
  ) +
  labs(
    title = "Minimum Legal Drinking Age",
    x = "Year",
    y = "# of States",
    fill = "Age Group"
  ) +
  scale_fill_manual(values = age_colors) + 
  scale_y_continuous(limits = c(0, 50), breaks = seq(0, 50, 10)) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    axis.line = element_line(color = "black")
  )

# Graphique 3 : Relation entre taxe sur la bière et mortalité
ggplot(df, aes(x = beertax, y = fatal_rate)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", color = "blue") +
  labs(title = "Taxe sur la Bière vs. Mortalité Routière (pour 10 000 habitants)", 
       x = "Taxe sur la bière (USD)", y = "Taux de mortalité") +
  theme_minimal()
