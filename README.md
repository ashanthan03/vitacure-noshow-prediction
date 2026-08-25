# 🏥 VitaCure Healthcare — No-Show Prediction & Demand Forecasting

**Internship Project (Phase 2) | VitaCure Healthcare Private Limited**  
**Analyst:** A. Shanthan Kumar | **Period:** October 2025 – January 2026  
**Tools:** Python · Pandas · Scikit-learn · Matplotlib · Seaborn · Streamlit · Plotly

---

## 📌 Project Overview

This is the second phase of a Data Analyst internship at VitaCure Healthcare, a physiotherapy startup. Phase 1 (Jul–Oct 2025) delivered a Power BI dashboard for operational visibility into revenue, cancellations, and therapist performance. Phase 2 builds on that foundation by moving from **descriptive analytics** (what happened) to **predictive analytics** (what's likely to happen next).

**Business Problem:** Front-desk staff had no way to anticipate which upcoming bookings were at high risk of a no-show, making it hard to prioritize confirmation calls and reminder outreach.

**Solution Delivered:**
- A booking-level dataset (950 records) with lead time, reminder status, and patient history features
- Two classification models (Logistic Regression, Random Forest) predicting no-show risk
- Feature importance analysis identifying the strongest drivers of no-shows
- A simple weekly demand forecast baseline
- An interactive Streamlit tool for front-desk staff to score new bookings in real time

---

## 📊 Key Findings

| Finding | Detail |
|---|---|
| Overall no-show rate | ~29.6% of bookings |
| Best model (by accuracy/precision) | Random Forest — 70.0% accuracy, ROC-AUC 0.61 |
| Best model (by recall) | Logistic Regression — catches 68% of actual no-shows |
| Strongest no-show predictor | Reminder not sent |
| Other key drivers | Prior cancellations, booking lead time, Monday bookings |

---

## 💡 Recommendations Delivered

1. **Mandatory reminder protocol** for every booking, prioritizing long lead-time bookings
2. **High-risk patient flag** for patients with 2+ prior cancellations
3. **Confirmation calls** for bookings made more than 10 days in advance
4. **Use the model's risk score** in the daily front-desk workflow to prioritize outreach

---

## 📁 Repository Structure

```
vitacure-noshow-prediction/
│
├── vitacure_bookings_phase2.csv         # Booking-level dataset (950 rows × 14 features)
├── VitaCure_NoShow_Prediction.ipynb     # Full Python EDA + ML notebook (executed)
├── app.py                                # Streamlit no-show risk scoring tool
├── noshow_model.pkl                      # Trained Random Forest model + encoders
├── requirements.txt                      # Python dependencies
└── README.md
```

---

## 🗂️ Dataset Description

| Column | Description |
|---|---|
| Booking_ID | Unique booking identifier |
| Patient_ID | Unique patient identifier |
| Scheduled_Date | Date of the scheduled session |
| Day_of_Week | Day name |
| Hour | Scheduled hour (9–19) |
| Therapist | Assigned physiotherapist |
| Therapist_Experience_Years | Years of experience |
| Condition | Medical condition being treated |
| Session_Type | In-Clinic / Home Visit / Teleconsultation |
| City | Patient city |
| Lead_Time_Days | Days between booking and scheduled session |
| Prior_Cancellations | Patient's historical cancellation count |
| Reminder_Sent | Whether a reminder was sent (1/0) |
| No_Show | Target variable — 1 if cancelled/no-show, 0 otherwise |

---

## 🛠️ How to Run

### Notebook
```bash
pip install pandas numpy matplotlib seaborn scikit-learn jupyter
jupyter notebook VitaCure_NoShow_Prediction.ipynb
```

### Streamlit App
```bash
pip install -r requirements.txt
streamlit run app.py
```

---

## 📈 App Features

| Page | Description |
|---|---|
| Risk Predictor | Enter booking details to get a real-time no-show risk score with a visual gauge |
| Booking Overview | KPIs, weekly volume trend, therapist/city/condition breakdowns |
| Model Insights | Feature importance chart and model performance comparison table |

---

*Built as Phase 2 of a Data Analyst Internship at VitaCure Healthcare Private Limited, extending the Phase 1 operations dashboard into predictive analytics.*
