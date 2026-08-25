import streamlit as st
import pandas as pd
import numpy as np
import pickle
import plotly.express as px
import plotly.graph_objects as go

st.set_page_config(page_title="VitaCure No-Show Risk Tool", page_icon="🏥", layout="wide")

# ── Load model ──────────────────────────────────────────────────────────────
@st.cache_resource
def load_model():
    with open("noshow_model.pkl", "rb") as f:
        return pickle.load(f)

bundle = load_model()
model = bundle["model"]
encoders = bundle["encoders"]
feature_cols = bundle["feature_cols"]

@st.cache_data
def load_data():
    return pd.read_csv("vitacure_bookings_phase2.csv", parse_dates=["Scheduled_Date"])

df = load_data()

# ── Sidebar navigation ──────────────────────────────────────────────────────
st.sidebar.title("🏥 VitaCure")
st.sidebar.caption("No-Show Prediction Tool — Phase 2")
page = st.sidebar.radio("Navigate", ["Risk Predictor", "Booking Overview", "Model Insights"])

BRAND = "#1A6B8A"
ACCENT = "#E05A2B"

# ── Page 1: Risk Predictor ──────────────────────────────────────────────────
if page == "Risk Predictor":
    st.title("📋 Booking No-Show Risk Predictor")
    st.write("Enter the details of an upcoming booking to estimate its no-show risk.")

    col1, col2, col3 = st.columns(3)

    with col1:
        therapist = st.selectbox("Therapist", sorted(encoders["Therapist"].classes_))
        condition = st.selectbox("Condition", sorted(encoders["Condition"].classes_))
        session_type = st.selectbox("Session Type", sorted(encoders["Session_Type"].classes_))

    with col2:
        location = st.selectbox("Location", sorted(encoders["Location"].classes_))
        day_of_week = st.selectbox("Day of Week", sorted(encoders["Day_of_Week"].classes_))
        hour = st.slider("Scheduled Hour", 9, 19, 11)

    with col3:
        lead_time = st.slider("Lead Time (days before session)", 1, 14, 5)
        prior_cancellations = st.slider("Patient's Prior Cancellations", 0, 5, 0)
        reminder_sent = st.toggle("Reminder Sent?", value=True)

    therapist_exp_map = {
        "Dr. Priya Sharma": 8, "Dr. Arjun Nair": 3, "Dr. Meena Iyer": 11,
        "Dr. Rohan Verma": 2, "Dr. Kavitha Reddy": 6, "Dr. Suresh Pillai": 15,
    }

    if st.button("Predict No-Show Risk", type="primary"):
        input_row = pd.DataFrame([{
            "Hour": hour,
            "Therapist_Experience_Years": therapist_exp_map[therapist],
            "Lead_Time_Days": lead_time,
            "Prior_Cancellations": prior_cancellations,
            "Reminder_Sent": 1 if reminder_sent else 0,
            "Day_of_Week_enc": encoders["Day_of_Week"].transform([day_of_week])[0],
            "Therapist_enc": encoders["Therapist"].transform([therapist])[0],
            "Condition_enc": encoders["Condition"].transform([condition])[0],
            "Session_Type_enc": encoders["Session_Type"].transform([session_type])[0],
            "Location_enc": encoders["Location"].transform([location])[0],
        }])[feature_cols]

        risk_proba = model.predict_proba(input_row)[0][1]
        risk_pct = risk_proba * 100

        st.divider()
        c1, c2 = st.columns([1, 2])

        with c1:
            if risk_pct >= 50:
                st.error(f"### ⚠️ High Risk\n## {risk_pct:.1f}%")
                st.write("Recommend a confirmation call before the session.")
            elif risk_pct >= 30:
                st.warning(f"### ⚡ Moderate Risk\n## {risk_pct:.1f}%")
                st.write("Send a reminder if not already scheduled.")
            else:
                st.success(f"### ✅ Low Risk\n## {risk_pct:.1f}%")
                st.write("Standard booking — no extra action needed.")

        with c2:
            fig = go.Figure(go.Indicator(
                mode="gauge+number",
                value=risk_pct,
                title={'text': "No-Show Risk Score"},
                gauge={'axis': {'range': [0, 100]},
                       'bar': {'color': ACCENT if risk_pct >= 50 else BRAND},
                       'steps': [
                           {'range': [0, 30], 'color': '#d4edda'},
                           {'range': [30, 50], 'color': '#fff3cd'},
                           {'range': [50, 100], 'color': '#f8d7da'}]}))
            fig.update_layout(height=280, margin=dict(t=40, b=10))
            st.plotly_chart(fig, use_container_width=True)

# ── Page 2: Booking Overview ────────────────────────────────────────────────
elif page == "Booking Overview":
    st.title("📊 Booking Overview — Oct 2025 to Jan 2026")

    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Total Bookings", f"{len(df):,}")
    c2.metric("No-Show Rate", f"{df['No_Show'].mean()*100:.1f}%")
    c3.metric("Avg Lead Time", f"{df['Lead_Time_Days'].mean():.1f} days")
    c4.metric("Reminder Coverage", f"{df['Reminder_Sent'].mean()*100:.0f}%")

    col1, col2 = st.columns(2)

    with col1:
        weekly = df.set_index("Scheduled_Date").resample("W")["Booking_ID"].count().reset_index()
        fig = px.line(weekly, x="Scheduled_Date", y="Booking_ID",
                       title="Weekly Booking Volume", markers=True,
                       color_discrete_sequence=[BRAND])
        st.plotly_chart(fig, use_container_width=True)

    with col2:
        therapist_noshow = df.groupby("Therapist")["No_Show"].mean().sort_values(ascending=True) * 100
        fig = px.bar(therapist_noshow, orientation="h",
                      title="No-Show Rate by Therapist",
                      color_discrete_sequence=[BRAND])
        fig.update_layout(showlegend=False, xaxis_title="No-Show Rate (%)", yaxis_title="")
        st.plotly_chart(fig, use_container_width=True)

    col3, col4 = st.columns(2)
    with col3:
        condition_counts = df["Condition"].value_counts()
        fig = px.pie(values=condition_counts.values, names=condition_counts.index,
                      title="Bookings by Condition", hole=0.4)
        st.plotly_chart(fig, use_container_width=True)

    with col4:
        location_counts = df.groupby("Location")["No_Show"].agg(["count", "mean"]).reset_index()
        location_counts["mean"] = (location_counts["mean"] * 100).round(1)
        fig = px.bar(location_counts, x="Location", y="count", color="mean",
                      title="Bookings by Location (color = No-Show %)",
                      color_continuous_scale="Reds")
        st.plotly_chart(fig, use_container_width=True)

# ── Page 3: Model Insights ──────────────────────────────────────────────────
else:
    st.title("🔍 Model Insights")
    st.write("Performance and feature importance for the Random Forest no-show prediction model.")

    importances = pd.Series(model.feature_importances_, index=feature_cols).sort_values(ascending=True)
    fig = px.bar(importances, orientation="h", title="Feature Importance",
                  color_discrete_sequence=[BRAND])
    fig.update_layout(showlegend=False, xaxis_title="Importance", yaxis_title="")
    st.plotly_chart(fig, use_container_width=True)

    st.subheader("Model Performance (Test Set)")
    perf = pd.DataFrame({
        "Metric": ["Accuracy", "Precision", "Recall", "F1 Score", "ROC-AUC"],
        "Logistic Regression": [0.595, 0.392, 0.679, 0.497, 0.645],
        "Random Forest": [0.700, 0.487, 0.339, 0.400, 0.608],
    })
    st.dataframe(perf, use_container_width=True, hide_index=True)

    st.info(
        "Random Forest was selected for the production tool due to higher overall accuracy and precision, "
        "reducing false alarms for front-desk staff while Logistic Regression's higher recall makes it a useful "
        "secondary check for catching more at-risk bookings."
    )

st.sidebar.divider()
st.sidebar.caption("VitaCure Healthcare Pvt. Ltd. | Data Analyst Intern Project")
