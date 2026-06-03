# 網路使用率與經濟生產力 (Internet Usage and Economic Productivity)

### 世界銀行 WDI · 2000–2020

---

## 專案核心架構

數位經濟在過去 20 年間蓬勃發展，政策制定者普遍假設「提升網路普及率」能直接帶動國家的經濟生產力（以人均 GDP 衡量）。然而，在傳統的跨國總體經濟分析中，若僅使用簡單的迴歸模型，往往會忽略**序列相關（Serial Correlation）與內生性控制**等計量經濟學上的偏誤，進而導致高估網路普及的直接經濟效益。


本專案旨在利用實證計量經濟學方法，嚴格檢定「核心自變數（網路普及率）」對「應變數（人均 GDP 對數值）」的因果影響。

* **核心挑戰：** 控制其他總體經濟變數（資本投資、教育、貿易、都市化），並解決跨國面板數據中常見的異質性與時間序列相關問題。
* **研究假說：** * 虛無假說 (H0): 網路普及率對人均 GDP 沒有顯著影響。
* 對立假說 (H1): 網路普及率對人均 GDP 有正向顯著影響。



為了得到穩健的估計結果，本專案依序推圖並建構了以下計量模型與診斷流程：

1. **數據 Wrangling 與清洗：** 透過世界銀行數據庫導入約 240 個國家、橫跨 21 年（2000–2020）的面板數據，進行 Wide-to-Long 格式轉換與多來源合併，最終篩選出 4,592 筆有效觀測值。
2. **多模型漸進估計：** 從基準的混合普通最小二乘法（Pooled OLS）**出發，逐步加入控制變數，並進一步擴展至**國家固定效應模型（Country FE）以控制不隨時間變化的國家異質性。
3. **偏好模型設定（Preferred Model）：** 導入**雙向固定效應模型（Two-Way FE）**，同時控制「國家固定效應」與「年度固定效應」，排除全球總體經濟景氣波動的干擾。
4. **嚴格診斷檢定：**
* 運用 **豪斯曼檢定（Hausman Test）** 確認固定效應模型（FE）優於隨機效應模型（RE）。
* 執行 **Wooldridge 序列相關檢定**，發現殘差存在嚴重的序列相關問題。
* **關鍵修正：** 最終導入集群穩健標準誤（Cluster-Robust Standard Errors，國家層級）對標準誤進行修正，以獲得不偏且有效的統計推論。


模型估計的漸進結果如下表所示：

| 模型設定 (Model) | 網路普及率係數 (Internet Coeff.) | 統計顯著性 (Significant?) |
| --- | --- | --- |
| OLS (1) — 無控制變數 | 0.0372 | ✅ *** |
| OLS (2) — 包含控制變數 | 0.0162 | ✅ *** |
| 國家固定效應模型 (Country FE) | 0.0040 | ✅ *** |
| 雙向固定效應模型 (Two-Way FE) | 0.0006 | ✅ ** |
| **雙向固定效應 + 穩健標準誤 (Robust SE)** | **0.0006** | ❌ **p = 0.521 (不顯著)** |

* **關鍵計量洞察：** 在標準的 OLS 與固定效應模型下，網路普及率皆呈現顯著正向影響；但在**修正序列相關（Robust SE）後，網路的直接效應在統計上變得不顯著**。
* **經濟學意涵：** 實證結果推翻了傳統直覺。這表明網路普及對經濟增長的推動並非獨立存在的直接效應，而是透過**資本形成總額**（p = 0.034）與**都市化程度**（p = 0.012）等實體建設與人口集聚來發揮**間接影響**。

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

1. 複製（Clone）本專案至本地端。
2. 下載上述 6 個 WDI 的 CSV 數據檔案，並放置於 `data/` 資料夾中。
3. 在 `R/analysis.R` 中設定您的工作目錄（Working Directory）。
4. 依序執行 `R/analysis.R` 內的各個程式碼區塊。
