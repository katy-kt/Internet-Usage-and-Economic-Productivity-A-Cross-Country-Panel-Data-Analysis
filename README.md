# Internet Usage and Economic Productivity
### A Cross-Country Panel Data Analysis | R · World Bank WDI · 2000–2020

---

## Overview

This project empirically investigates whether greater internet penetration leads to higher economic productivity across countries. Using a cross-country panel dataset covering ~240 countries over 2000–2020, we estimate a series of regression models from pooled OLS to two-way fixed effects, and rigorously test for serial correlation and model misspecification.

**Key finding:** While internet usage shows a positive and significant effect on GDP per capita under standard OLS and fixed effects models, the direct effect becomes statistically insignificant after correcting for serial correlation using cluster-robust standard errors. This suggests internet adoption may drive economic growth **indirectly** — through capital investment and urbanization — rather than as a standalone effect.

---

## Research Question

> Does greater internet penetration lead to higher GDP per capita across countries, after controlling for capital investment, education, trade openness, and urbanization?

**H₀:** Internet penetration has no significant effect on GDP per capita.  
**H₁:** Internet penetration has a positive effect on GDP per capita.

---

## Data

All data sourced from the **World Bank World Development Indicators (WDI)** database.

| Variable | WDI Code | Role |
|---|---|---|
| Log GDP per Capita | NY.GDP.PCAP.KD | Dependent (Y) |
| Internet Users (%) | IT.NET.USER.ZS | Key Independent (X₁) |
| Gross Capital Formation | NE.GDI.TOTL.ZS | Control (X₂) |
| Tertiary Enrollment | SE.TER.ENRR | Control (X₃) |
| Trade (% GDP) | NE.TRD.GNFS.ZS | Control (X₄) |
| Urban Population (%) | SP.URB.TOTL.IN.ZS | Control (X₅) |

**Sample:** ~240 countries · 2000–2020 · 4,592 observations (after cleaning)

To download the data, visit [World Bank Data](https://data.worldbank.org) and search each indicator code above. Download as CSV and place in the `data/` folder.

---

## Methods

```
Pooled OLS (baseline)
  → Pooled OLS + controls
    → Country Fixed Effects
      → Two-Way Fixed Effects (country + year) ← preferred model
        → Cluster-Robust Standard Errors (country level)
```

**Diagnostic tests:**
- Hausman Test (FE vs RE selection)
- F-test for individual fixed effects
- Wooldridge serial correlation test

---

## Results

| Model | Internet Coeff. | Significant? |
|---|---|---|
| OLS (1) — no controls | 0.0372 | ✅ *** |
| OLS (2) — with controls | 0.0162 | ✅ *** |
| Country Fixed Effects | 0.0040 | ✅ *** |
| Two-Way Fixed Effects | 0.0006 | ✅ ** |
| Two-Way FE + Robust SE | 0.0006 | ❌ p=0.521 |

After correcting for serial correlation, **capital formation** (p=0.034) and **urbanization** (p=0.012) are the key drivers of GDP per capita.

---

## Figures

| | |
|---|---|
| ![Figure 1](output/fig1_trend.png) | ![Figure 2](output/fig2_scatter.png) |
| Global internet penetration trend | Internet vs. Log GDP (2020 cross-section) |
| ![Figure 3](output/fig3_corrplot.png) | |
| Correlation matrix | |

---

## Repository Structure

```
internet-productivity-panel/
├── README.md
├── R/
│   └── analysis.R          # Full analysis script
├── data/                   # Place World Bank CSVs here
│   └── .gitkeep
└── output/
    ├── fig1_trend.png
    ├── fig2_scatter.png
    ├── fig3_corrplot.png
    └── table1_descriptive.csv
```

---

## Requirements

```r
install.packages(c("plm", "tidyverse", "lmtest", "sandwich", "corrplot"))
```

R version 4.x or above.

---

## How to Run

1. Clone this repository
2. Download the 6 WDI CSV files and place them in `data/`
3. Set your working directory in `R/analysis.R`
4. Run `R/analysis.R` section by section

---

## Skills Demonstrated

- **Panel data econometrics** — pooled OLS, fixed effects, two-way FE
- **Robustness testing** — cluster-robust standard errors, Hausman test
- **Data wrangling** — World Bank API, wide-to-long transformation, multi-source merging
- **Data visualization** — ggplot2, corrplot
- **Econometric interpretation** — distinguishing direct vs. indirect effects

---

## Citation

World Bank. (2024). *World Development Indicators*. https://data.worldbank.org

---

*Final project for Introduction to Quantitative Economics with R — Soochow University, Department of Economics*
