# 網路使用率與經濟生產力 (Internet Usage and Economic Productivity)

### 世界銀行 WDI · 2000–2020

---

## 專案核心架構

本專案實證探討「網路普及率」對各國經濟生產力（人均 GDP）的因果影響。透過世界銀行 WDI 數據庫，分析 2000–2020 年間約 240 個國家的面板數據（共 4,592 筆觀測值）。

* **核心挑戰：** 處理跨國總體經濟數據中嚴重的序列相關（Serial Correlation）與國家異質性偏誤。
* **主要發現：** 雖然在標準 OLS 與固定效應模型下網路普及呈現顯著正向影響，但在**導入集群穩健標準誤（Cluster-Robust SE）修正序列相關後，該直接效應在統計上變得不顯著**。
* **經濟意涵：** 網路普及並非獨立的直接驅動引擎，而是透過**資本形成總額**與**都市化程度**發揮**間接影響**。

---

## 模型估計結果 (Key Results)

| 模型設定 (Model) | 網路普及率係數 (Internet Coeff.) | 統計顯著性 (Significant?) |
| --- | --- | --- |
| OLS (1) — 無控制變數 | 0.0372 | ✅ *** |
| OLS (2) — 包含控制變數 | 0.0162 | ✅ *** |
| 國家固定效應模型 (Country FE) | 0.0040 | ✅ *** |
| 雙向固定效應模型 (Two-Way FE) | 0.0006 | ✅ ** |
| **雙向固定效應 + 穩健標準誤 (Robust SE)** | **0.0006** | ❌ **p = 0.521 (不顯著)** |

> 修正後結果顯示，**資本形成總額** (p = 0.034) 與**都市化程度** (p = 0.012) 才是推動人均 GDP 的核心關鍵。

---

## 數據指標來源 (Data)

| 變數名稱 (Variable) | WDI 代碼 | 在模型中的角色 |
| --- | --- | --- |
| 人均 GDP 對數值 (Log GDP per Capita) | NY.GDP.PCAP.KD | 因變數 / 應變數 (Y) |
| 網路使用者比例 (Internet Users %) | IT.NET.USER.ZS | 核心自變數 (X1) |
| 資本形成總額 (Gross Capital Formation) | NE.GDI.TOTL.ZS | 控制變數 (X2) |
| 高等教育入學率 (Tertiary Enrollment) | SE.TER.ENRR | 控制變數 (X3) |
| 貿易總額占 GDP 比例 (Trade % GDP) | NE.TRD.GNFS.ZS | 控制變數 (X4) |
| 都市人口比例 (Urban Population %) | SP.URB.TOTL.IN.ZS | 控制變數 (X5) |

---

## 技術亮點與統計檢定 (Methodology)

* **漸進式面板模型：** Pooled OLS → Country FE → Two-Way FE (偏好模型，排除全球景氣波動)。
* **模型診斷：** * 經 **豪斯曼檢定 (Hausman Test)** 確認固定效應模型 (FE) 優於隨機效應模型 (RE)。
* 經 **Wooldridge 檢定** 發現嚴重序列相關，最終以 **Cluster-Robust SE** 修正統計推論。



---

## 圖表成果 (Figures)

|  |  |
| --- | --- |
|  |  |
| 全球網路普及率趨勢圖 | 網路普及率 vs. 人均 GDP 對數值 (2020橫斷面) |
|  |  |
| 變數相關性矩陣圖 |  |

---

## 專案目錄結構 (Repository Structure)

```text
internet-productivity-panel/
├── README.md
├── R/
│   └── analysis.R          # 完整分析 R 腳本
├── data/                   # 請在此存放世界銀行的 CSV 數據檔案
│   └── .gitkeep
└── output/
    ├── fig1_trend.png
    ├── fig2_scatter.png
    ├── fig3_corrplot.png
    └── table1_descriptive.csv

```

---

## 環境需求 (Requirements)

```r
install.packages(c("plm", "tidyverse", "lmtest", "sandwich", "corrplot"))

```

* R 版本需為 4.x 或以上。

---

## 如何執行 (How to Run)

1. Clone 本專案至本地端。
2. 下載 6 個 WDI 的 CSV 數據檔案並放置於 `data/` 資料夾。
3. 在 `R/analysis.R` 中設定工作目錄並依序執行程式碼。
