# 🌿 EcoRabbit — AI Housing Assistant for Sustainable Cities
### Fixing Traffic by Moving People, Not Cars

## 📌 Overview
EcoHabit is an AI-driven housing assistant that helps young professionals find Transit-Oriented housing by optimizing Affordability, Public Transport Connectivity, and Traffic Prediction. Instead of searching for a home by district, EcoHabit begins with your workplace and commute patterns to reduce long-term car dependency—directly supporting SDG 11: Sustainable Cities & Communities.

## 🧩 Why EcoRabbit Exists
### Spatial Mismatch: The Real Cause of Traffic
Low-income and young professionals (B40/M40) often cannot afford homes near city centers. They are pushed to disconnected suburbs and forced to drive, causing:
- Daily traffic congestion  
- High carbon emissions  
- Increased cost of living  

Most AI traffic solutions fix congestion **after** it happens. EcoHabit fixes it at the root: better housing choices.

## 🚀 Key Features

### ✅ 1. Smart Commute-First Search
Search by workplace, income, and budget.  
EcoHabit generates an Eco-Score for each property:
- 30% Affordability  
- 40% Public Transport Connectivity  
- 30% Traffic Prediction  

Listings include driving vs. transit time, cost, and carbon impact comparison.

### ✅ 2. Dynamic City Pulse Layers
**Traffic Stress Map:** Predicted congestion zones from GTFS data
**Affordability Map:** Highlights expensive vs. affordable regions

### ✅ 3. EcoRabbit Insight Agent (AI Assistant)
Powered by Google Gemini API.  
Provides personalized urban mobility recommendations based on:
- Property data  
- Commute patterns  
- Traffic predictions  

Example:  
“Choose Cheras. It has 40% lower morning congestion risk than Setapak and better MRT access.”

## 🛠️ Tech Stack
**Frontend:** Flutter  
**Backend:** Python  
**Database:** Firebase  
**AI:** Google Gemini API  
**Datasets:**  
- GTFS Traffic Prediction (Kaggle)  
- OpenStreetMap Transit Network  
- Malaysia Housing Price Dataset (Kaggle)

## 🌍 Impact (SDG 11)
**SDG 11.2:** Promotes sustainable transport by shifting users from cars to public transit  
**SDG 11.1:** Supports affordable housing access for B40/M40  
**Environmental:** Reduces carbon emissions through TOD lifestyle

## 📱 User Flow
1. User enters workplace, budget, and commute preference  
2. EcoHabit fetches candidate properties  
3. Backend computes Eco-Score  
4. App displays: commute comparison, heatmaps, and AI recommendations  

## ⚙️ Installation & Run
**Requirements:** Flutter SDK, VS Code/Android Studio, Firebase config, Google Maps API key, Gemini API key

Run the app:
```bash
flutter pub get
flutter run
