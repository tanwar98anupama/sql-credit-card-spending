# Credit Card Spending Analysis (SQL Portfolio Project)

This project analyzes **credit card spending habits** using SQL Server.  
It demonstrates my ability to write **clean, production-style SQL** using:

- Window functions (ROW_NUMBER, RANK, SUM() OVER)
- Common Table Expressions (CTEs)
- Date functions and aggregations
- Business-focused analysis (city, card type, spend patterns)

---

## 1. Dataset

- **Source:** Kaggle – *Analyzing Credit Card Spending Habits in India*  
- **Rows:** ~26,000 credit card transactions  
- **Key columns:**
  - `transaction_id` – unique ID per transaction  
  - `transaction_date` – date of the transaction  
  - `city` – city where the transaction happened  
  - `card_type` – e.g., Silver, Gold, Platinum, Signature  
  - `exp_type` – expense category (fuel, bills, food, entertainment, etc.)  
  - `gender` – M / F  
  - `amount` – transaction amount  

> **Tech stack:** SQL Server (SSMS), T-SQL, GitHub

---

## 2. Business Questions Answered

1. **Which 5 cities drive the highest credit card spend, and what % of total spend do they contribute?**
2. **For each card type, which month had the highest spend?**
3. **For each card type, when did cumulative spend first cross ₹1,000,000?**
4. **Which city contributes the least to overall Gold card usage?**
5. **For each city, what are the highest and lowest expense categories?**
6. **For each expense type, what % of spend comes from female cardholders?**
7. **Which card type + expense type combo had the highest month-over-month growth in Jan 2014?**
8. **On weekends, which city has the highest average spend per transaction?**
9. **Which city reached its 500th transaction the fastest (fewest days from first transaction)?**

---

## 3. Key SQL Features Demonstrated

- **CTEs** for breaking down complex logic into readable steps.
- **Window functions**:
  - `SUM(...) OVER (PARTITION BY ...)` for cumulative and partitioned totals.
  - `ROW_NUMBER` and `RANK` to pick top / bottom categories per city or card type.
- **Date handling** with `DATEPART`, `DATENAME`, `DATEFROMPARTS`, and month truncation.
- **Conditional aggregation** with `CASE WHEN` to compare genders and card types.
- **Performance-aware grouping** and filtering instead of nested `SELECT *` everywhere.

---

## 4. High-Level Insights

- **Concentration of spend:**  
  The **top 5 cities** account for roughly **~56% of total spend**, indicating that credit card usage is highly concentrated in a few urban centers.

- **Card type seasonality:**  
  - For **Signature / Platinum** cards, the highest spending month was **January**, likely driven by big-ticket purchases or festive offers.  
  - **Silver / Gold** cards show peak usage in **January**, aligned with everyday spending patterns.

- **Growth milestones:**  
  - **Gold-Card Type** reached ₹1,000,000 cumulative spend the fastest, suggesting a more engaged or affluent customer base.  
  - **Platinum-Card Type** lagged behind, which might indicate room for targeted campaigns.

- **Gold card underpenetrated cities:**  
  - **City Ahmedabad** has the **lowest contribution to global Gold card spend**, making it a candidate for **Gold-specific promotions** or **upgrade offers**.

- **City-wise category mix:**  
  - In **City Delhi**, the highest spend category is **Bills**, while the lowest is **Entertainment**, reflecting local lifestyle or infrastructure (e.g., metro vs. tier-2 city).

- **Female spend patterns:**  
  - For **expense type, “bills”**, **female cardholders contribute ~64% of total spend**, suggesting strong product–segment fit.
  - Some categories show much lower female contribution, indicating potential for targeted offers.

- **MoM growth hot-spot:**  
  - The **card_type-gold + expense_type- travel** combo saw the **highest month-over-month growth in Jan 2014**, hinting at the success of a campaign or emerging category.

- **Weekend behavior:**  
  - On weekends, **Sonepur** shows the **highest average spend per transaction**, suggesting strong discretionary / leisure spending.

- **Ramp-up velocity:**  
  - **Bengaluru** reached its **500th transaction in the fewest days** from its first, showing rapid adoption of credit cards vs. other cities.

---

## 5. How to Run This Project

1. **Clone or download this repo.**
2. Load the Kaggle dataset into SQL Server (instructions given in `sql/credit_card_spending_analysis.sql` comments).
3. Run the script in order:
   - Quick sanity checks
   - Questions 1–9
4. (Optional) Export aggregated outputs to Power BI / Tableau to build dashboards (see Visualization Ideas section).

---

## 6. Next Steps (Roadmap)

- Build a **Power BI / Tableau dashboard** on top of these queries.
- Add a **Jupyter Notebook** or **Python script** to reproduce key aggregations and charts.
- Extend analysis to **customer segmentation** or **propensity modeling** (high-value segment, weekend shoppers, etc.).

