# Installation et chargement des packages necessaires
install. packages (c("AER", "plm", "stargazer", "Imtest", "car"))
library (AER)
library (plm)
library (stargazer)
library (Imtest)
library (car)
data ("Fatalities")
df <- Fatalities
# Selection des variables pertinentes
df ‹- df[, c("state", "year", "fatal", "afatal", "drinkage", "beertax", "breath",
"jail", "service", "unemp", "income", "youngdrivers", "miles", "pop")]
# Creer une variable de taux de mortalite (normalisee par la population)
df$fatal rate ‹- df$afatal / df$pop * 10000
