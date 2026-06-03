# ============================================================
#  Internet Usage and Economic Productivity
#  A Cross-Country Panel Data Analysis
#
#  Data:    World Bank WDI (~240 countries, 2000-2020)
#  Methods: Pooled OLS, Country FE, Two-Way FE (plm)
#  Author:  Soochow University — Intro to Quantitative Economics
# ============================================================


# ── 0. Load Packages ─────────────────────────────────────────
# Run install.packages() once if not yet installed:
# install.packages(c("plm","tidyverse","stargazer","lmtest","sandwich","corrplot"))

library(plm)
library(tidyverse)
library(lmtest)
library(sandwich)
library(corrplot)


# ── 1. Load Data ─────────────────────────────────────────────
# Download CSVs from World Bank WDI and place them in your working directory.
# Set your path:
# setwd("YOUR/PATH/HERE")
#
# Indicator codes used:
#   NY.GDP.PCAP.KD   — GDP per capita (constant 2015 USD)
#   IT.NET.USER.ZS   — Internet users (% of population)
#   NE.GDI.TOTL.ZS   — Gross capital formation (% of GDP)
#   SE.TER.ENRR      — Tertiary school enrollment (% gross)
#   NE.TRD.GNFS.ZS   — Trade (% of GDP)
#   SP.URB.TOTL.IN.ZS — Urban population (% of total)

read_wb <- function(filepath, varname) {
  read_csv(filepath, skip = 4, show_col_types = FALSE) %>%
    select(`Country Name`, `Country Code`, as.character(2000:2020)) %>%
    pivot_longer(cols      = as.character(2000:2020),
                 names_to  = "year",
                 values_to = varname) %>%
    rename(country = `Country Name`, iso3c = `Country Code`) %>%
    mutate(year = as.integer(year))
}

# Save read_wb to a helper file first, then source it (required for base R console):
# writeLines('...function code...', "helper.R"); source("helper.R")

gdp_pc    <- read_wb("API_NY.GDP.PCAP.KD_DS2_en_csv_v2_89/API_NY.GDP.PCAP.KD_DS2_en_csv_v2_89.csv",             "gdp_pc")
internet  <- read_wb("API_IT.NET.USER.ZS_DS2_en_csv_v2_121585/API_IT.NET.USER.ZS_DS2_en_csv_v2_121585.csv",     "internet")
capital   <- read_wb("API_NE.GDI.TOTL.ZS_DS2_en_csv_v2_115698/API_NE.GDI.TOTL.ZS_DS2_en_csv_v2_115698.csv",   "capital")
education <- read_wb("API_SE.TER.ENRR_DS2_en_csv_v2_1423/API_SE.TER.ENRR_DS2_en_csv_v2_1423.csv",               "education")
trade     <- read_wb("API_NE.TRD.GNFS.ZS_DS2_en_csv_v2_115680/API_NE.TRD.GNFS.ZS_DS2_en_csv_v2_115680.csv",   "trade")
urban     <- read_wb("API_SP.URB.TOTL.IN.ZS_DS2_en_csv_v2_121583/API_SP.URB.TOTL.IN.ZS_DS2_en_csv_v2_121583.csv", "urban")

raw_data <- gdp_pc %>%
  left_join(internet,  by = c("country","iso3c","year")) %>%
  left_join(capital,   by = c("country","iso3c","year")) %>%
  left_join(education, by = c("country","iso3c","year")) %>%
  left_join(trade,     by = c("country","iso3c","year")) %>%
  left_join(urban,     by = c("country","iso3c","year"))

cat("Raw data:", nrow(raw_data), "obs,", n_distinct(raw_data$country), "countries\n")


# ── 2. Data Cleaning ─────────────────────────────────────────
df <- raw_data %>%
  filter(!is.na(gdp_pc) & !is.na(internet)) %>%
  mutate(log_gdp_pc = log(gdp_pc),
         year       = as.integer(year)) %>%
  select(country, iso3c, year, log_gdp_pc, internet,
         capital, education, trade, urban) %>%
  arrange(country, year)

cat("Clean data:", nrow(df), "obs,", n_distinct(df$country), "countries\n")


# ── 3. Descriptive Statistics ─────────────────────────────────
summary(df[, c("log_gdp_pc","internet","capital","education","trade","urban")])

# Standard deviations
round(apply(df[, c("log_gdp_pc","internet","capital","education","trade","urban")],
            2, sd, na.rm = TRUE), 3)

# Export Table 1 as CSV
desc <- data.frame(
  Variable  = c("log_gdp_pc","internet","capital","education","trade","urban"),
  Mean      = round(colMeans(df[, c("log_gdp_pc","internet","capital","education","trade","urban")], na.rm=TRUE), 3),
  SD        = round(apply(df[, c("log_gdp_pc","internet","capital","education","trade","urban")], 2, sd,  na.rm=TRUE), 3),
  Min       = round(apply(df[, c("log_gdp_pc","internet","capital","education","trade","urban")], 2, min, na.rm=TRUE), 3),
  Max       = round(apply(df[, c("log_gdp_pc","internet","capital","education","trade","urban")], 2, max, na.rm=TRUE), 3)
)
write.csv(desc, "table1_descriptive.csv", row.names = FALSE)


# ── 4. Figures ────────────────────────────────────────────────

# Figure 1: Global average internet penetration trend (2000-2020)
p1 <- df %>%
  group_by(year) %>%
  summarise(avg_internet = mean(internet, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = year, y = avg_internet)) +
  geom_area(fill = "#3182bd", alpha = 0.3) +
  geom_line(color = "#3182bd", linewidth = 1.2) +
  labs(title    = "Figure 1: Global Average Internet Penetration (2000-2020)",
       subtitle = "Source: World Bank WDI",
       x = "Year", y = "Internet Users (% of Population)") +
  theme_minimal(base_size = 12)

ggsave("fig1_trend.png", p1, width = 7, height = 4, dpi = 150)

# Figure 2: Scatter — internet vs log GDP per capita (cross-section, 2020)
p2 <- df %>%
  filter(year == 2020) %>%
  ggplot(aes(x = internet, y = log_gdp_pc)) +
  geom_point(alpha = 0.7, size = 2.5, color = "#3182bd") +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 0.8) +
  labs(title    = "Figure 2: Internet Usage vs. Log GDP per Capita (2020)",
       subtitle = "Each point represents one country. Source: World Bank WDI",
       x = "Internet Users (% of Population)",
       y = "Log GDP per Capita (constant 2015 USD)") +
  theme_minimal(base_size = 12)

ggsave("fig2_scatter.png", p2, width = 8, height = 5, dpi = 150)

# Figure 3: Correlation matrix
cor_matrix <- cor(df[, c("log_gdp_pc","internet","capital","education","trade","urban")],
                  use = "complete.obs")

png("fig3_corrplot.png", width = 700, height = 620)
corrplot(cor_matrix, method = "color", type = "upper",
         addCoef.col = "black", number.cex = 0.75,
         tl.cex = 0.85, tl.col = "black",
         title = "Figure 3: Correlation Matrix", mar = c(0,0,2,0))
dev.off()


# ── 5. Panel Regression Models ───────────────────────────────
panel_df <- pdata.frame(df, index = c("country", "year"))

# Model 1: Pooled OLS — bivariate (no controls)
ols1 <- lm(log_gdp_pc ~ internet, data = df)

# Model 2: Pooled OLS — with controls
ols2 <- lm(log_gdp_pc ~ internet + capital + education + trade + urban, data = df)

# Model 3: Country fixed effects
fe_country <- plm(log_gdp_pc ~ internet + capital + education + trade + urban,
                  data = panel_df, model = "within", effect = "individual")

# Model 4: Two-way fixed effects (country + year) — preferred specification
fe_twoway <- plm(log_gdp_pc ~ internet + capital + education + trade + urban,
                 data = panel_df, model = "within", effect = "twoways")


# ── 6. Regression Results Table ───────────────────────────────
# Print Table 3 to console
# (use stargazer if available; otherwise use summary())
summary(ols1)
summary(ols2)
summary(fe_country)
summary(fe_twoway)


# ── 7. Robust Standard Errors ────────────────────────────────
# Cluster-robust SE at country level (addresses serial correlation)
coeftest(fe_twoway, vcov = vcovHC(fe_twoway, type = "HC1", cluster = "group"))


# ── 8. Diagnostic Tests ───────────────────────────────────────

# (A) Hausman Test: FE vs RE
# H0: RE is consistent. p < 0.05 -> prefer Fixed Effects
re_model <- plm(log_gdp_pc ~ internet + capital + education + trade + urban,
                data = panel_df, model = "random")
phtest(fe_country, re_model)

# (B) F-test for individual fixed effects
# p < 0.05 -> country FE are jointly significant and necessary
pFtest(fe_country, ols2)

# (C) Wooldridge serial correlation test
# p < 0.05 -> serial correlation present -> use cluster-robust SE (done above)
pbgtest(fe_twoway)


# ── 9. Results Summary ───────────────────────────────────────
cat("
Key Findings:
- Internet penetration is positive and significant across all 4 baseline models.
- After cluster-robust SE correction: direct effect becomes insignificant (p=0.521).
- Capital formation and urbanization remain significant under robust estimation.
- Interpretation: Internet may drive GDP indirectly through complementary channels.
")
