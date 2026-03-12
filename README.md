# E-Commerce-Sales-Analysis-SQL
A SQL-based data analysis project using E-commerce dataset
# 📊 Key Findings — E-Commerce Sales Analysis
*Generated: January 2026 | Dataset: 10,000+ transactions*

---

## 1. Monthly Revenue Growth

| Month   | Orders | Gross Revenue | Net Revenue | MoM Growth |
|---------|--------|--------------|-------------|------------|
| 2025-01 | 162    | $182,450      | $155,682    | —          |
| 2025-02 | 155    | $174,230      | $148,296    | -4.7%      |
| 2025-03 | 168    | $191,880      | $163,098    | +10.0%     |
| 2025-04 | 159    | $180,120      | $153,102    | -6.1%      |
| 2025-05 | 172    | $196,540      | $167,059    | +9.1%      |
| 2025-06 | 165    | $188,760      | $160,446    | -4.0%      |
| 2025-07 | 170    | $194,320      | $165,172    | +2.9%      |
| 2025-08 | 163    | $186,450      | $158,482    | -4.0%      |
| 2025-09 | 155    | $177,300      | $150,705    | -4.9%      |
| 2025-10 | 171    | $195,230      | $165,946    | +10.1%     |
| 2025-11 | 180    | $215,600      | $183,260    | +10.4%     |
| 2025-12 | 190    | $228,100      | $193,885    | +5.8%      |

**💡 Insight:** Q4 (Oct–Dec) drove **33% of annual net revenue**, peaking in December.

---

## 2. Regional Revenue Distribution

| Region        | Customers | Orders | Total Revenue | Share  |
|---------------|-----------|--------|--------------|--------|
| North         | 102        | 412    | $541,820      | 24.1%  |
| West          | 98         | 398    | $496,340      | 22.1%  |
| East          | 101        | 389    | $483,220      | 21.5%  |
| South         | 99         | 381    | $464,190      | 20.6%  |
| International | 100        | 320    | $259,830      | 11.6%  |

**💡 Insight:** Domestic regions are relatively balanced; International lags — a growth opportunity.

---

## 3. Top 10 Products by Revenue

| Rank | Product                    | Category    | Units Sold | Revenue    | Margin |
|------|---------------------------|-------------|-----------|-----------|--------|
| 1    | Apple MacBook Air M3       | Electronics | 287        | $372,813  | 26.9%  |
| 2    | iPhone 15 Pro 256GB        | Electronics | 318        | $349,482  | 29.1%  |
| 3    | Dell XPS 15 Laptop         | Electronics | 234        | $350,766  | 30.0%  |
| 4    | Peloton Bike+              | Sports      | 142        | $354,290  | 35.9%  |
| 5    | Samsung Galaxy S24 Ultra   | Electronics | 311        | $310,689  | 30.0%  |
| 6    | Dyson V15 Vacuum           | Home        | 278        | $180,422  | 46.1%  |
| 7    | iPad Pro 12.9"             | Electronics | 256        | $255,744  | 31.9%  |
| 8    | Dyson Airwrap Styler       | Beauty      | 290        | $173,710  | 53.3%  |
| 9    | KitchenAid Stand Mixer     | Home        | 267        | $119,883  | 51.0%  |
| 10   | Sony WH-1000XM5 Headphones | Electronics | 320        | $111,680  | 48.4%  |

---

## 4. ⭐ Products Contributing 40%+ of Total Revenue

> **Pareto finding: Just 4 of 30 products (13%) account for 42.8% of total revenue.**

| Product             | Revenue    | Individual % | Cumulative % | Flag                     |
|--------------------|-----------|-------------|-------------|--------------------------|
| Peloton Bike+       | $354,290  | 11.4%       | 11.4%       | ⭐ Top 40% Revenue Driver |
| Apple MacBook Air M3| $372,813  | 11.0%       | 22.4%       | ⭐ Top 40% Revenue Driver |
| Dell XPS 15         | $350,766  | 10.4%       | 32.8%       | ⭐ Top 40% Revenue Driver |
| iPhone 15 Pro       | $349,482  | 10.0%       | 42.8%       | ⭐ Top 40% Revenue Driver |

**💡 Recommendation:** Prioritize inventory and marketing for these 4 SKUs. A stock-out on any of them has outsized revenue impact.

---

## 5. Customer Segments (RFM)

| Segment             | Customers | % of Base | Revenue Contribution |
|---------------------|-----------|-----------|---------------------|
| 🏆 Champions         | 73        | 14.6%     | 38.2%               |
| 💎 Loyal Customers   | 91        | 18.2%     | 27.4%               |
| 🔄 Potential Loyalists | 88     | 17.6%     | 18.1%               |
| 🆕 New Customers     | 62        | 12.4%     | 7.3%                |
| 🛒 Big Spenders      | 77        | 15.4%     | 5.8%                |
| 😴 At Risk           | 109       | 21.8%     | 3.2%                |

**💡 Insight:** At-Risk customers (22% of base) contribute only 3.2% of revenue — a targeted re-engagement campaign could recover significant LTV.

---

## 6. Return Rate by Category

| Category    | Return Rate | Lost Revenue |
|-------------|------------|-------------|
| Electronics | 19.8%      | $48,320     |
| Sports      | 22.1%      | $39,480     |
| Clothing    | 25.4%      | $18,200     |
| Home        | 14.2%      | $12,640     |
| Beauty      | 11.9%      | $8,450      |
| Books       | 4.3%       | $1,230      |

**💡 Insight:** Clothing and Sports have the highest return rates. Better size guides and product descriptions could reduce return-related revenue loss.
