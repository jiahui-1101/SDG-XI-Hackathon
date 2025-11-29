# 🌿 **EcoRabbit — AI Housing Assistant for Sustainable Cities**

**Fixing Traffic by Moving People, Not Cars**

---

## 📌 **Overview**

**EcoRabbit** is an **AI-driven housing assistant** that helps young professionals find **Transit-Oriented homes** by optimizing **Affordability**, **Public Transport Connectivity**, and **Traffic Prediction**.

Unlike typical property apps, EcoRabbit starts with your **workplace** and **commute patterns** to reduce car dependency — directly supporting **SDG 11: Sustainable Cities & Communities**.

---

## 🧩 **Why EcoRabbit Exists**

* **Long Commutes:** Malaysians spend **44–60 minutes** on one-way commutes (DOSM, 2023).
* **Poor Transit Access:** **70%** of Klang Valley residents live **beyond walking distance** from MRT/LRT stations (KRI, 2023).
* **Lack of Mobility Tools:** Cities lack **real-time mobility & accessibility analysis**, leading to **reactive planning** (MIP, 2024).

---

## 🚀 **Key Features**

### ✅ **1. Smart Commute-First Search & Reality Checks**

* Search using **workplace**, **current staying location**, **budget**, and **income**.
* Every listing includes **future lifestyle projections** based on commute patterns.

#### **Eco-Score Formula**

* **30%** Affordability
* **40%** Public Transport Connectivity
* **30%** Traffic Prediction

#### **🧋 The Bubble Tea Index**

Converts savings into a fun metric:
**“Save RM 200/month → +12 Cups of Tealive!”**

#### **🔮 Message from 2030**

Your future self reacts to your housing choice.

* **Bad Choice:**
  *“2030 Me: Help. Still stuck in Genting Klang traffic. Why didn’t you listen?”*

* **Good Choice:**
  *“2030 Me: Bought an iPhone 20 with all the petrol money we saved!”*

---

### ✅ **2. Dynamic City Pulse Layers + Time-Travel**

Visualize the **real-time** and **future** heartbeat of the city.

* **Traffic Stress Map:** Congestion predictions using GTFS
* **Affordability Map:** Housing price heatmap
* **Population Map:** Density visualization

#### **📅 Future Time-Travel Slider (2025–2030)**

See how:

* new **MRT lines**
* new **malls**
* future **urban growth**

affect commute quality and property value.

Powered by AI models that adjust **heatmap opacity & intensity**.

---

### ✅ **3. EcoRabbit Insight Agent — Your AI Urban Advisor**

Powered by **Google Gemini API**.

#### **Standard Mode**

Practical mobility insights:

> *“Choose Cheras. 40% lower morning congestion risk than Setapak.”*

#### **Malaysian Auntie Mode (👵)**

Classic wisdom:

> *“Aiyo this area jam until cannot move. You sure want to stay here?”*

### 📈 **Rental Growth Prediction Graph**

Visualize **5-year rental yield** and **property value growth** using historical + urban planning data.

---

## 🛠️ **Tech Stack**

* **Frontend:** Flutter
* **Backend:** Python
* **Database:** Firebase
* **AI:** Google Gemini API

---

## 📊 **Datasets Used**

### **1. Population Table: Administrative Districts**

Source: **data.gov.my**
Used for: **Population density mapping**, **urban growth model**, heatmap layering.
🔗 [Link](https://data.gov.my/data-catalogue/population_district?state=w-p-kuala-lumpur&district=w-p-kuala-lumpur&visual=table)

### **2. Housing Prices Malaysia 2025 (HuggingFace)**

Source: **HuggingFace Datasets**
Used for: **Affordability scoring**, **Eco-Score**, **rental growth prediction model**.
🔗 [Link](https://huggingface.co/datasets/jienweng/housing-prices-malaysia-2025/viewer/default/train)

### **3. House Prices in Malaysia (2025)**

Source: **Kaggle**
Used for: **Cross-validation** of affordability heatmaps and pricing trends.
🔗 [Link](https://www.kaggle.com/datasets/lyhatt/house-prices-in-malaysia-2025)

### **4. KL Property Listings Overview**

Source: **OpenDataBay**
Used for: **Real property listings**, metadata, and **district-level supply insights**.
🔗 [Link](https://www.opendatabay.com/data/ai-ml/19a75bde-15b2-4e4c-9fb8-50753952ebd1)

### **5. Population Data — Kuala Lumpur**

Source: **DOSM Kawasanku Dashboard**
Used for: **Population density**, **demographic heatmaps**, **urban activity modeling**.
🔗 [Link](https://open.dosm.gov.my/dashboard/kawasanku/W.P.%20Kuala%20Lumpur)

### **6. Traffic Information for Major Cities in Malaysia**

Source: **Malaysia Government Portal**
Used for: **Real-time congestion**, **traffic stress baseline**, **trend calibration**.
🔗 [Link](https://www.malaysia.gov.my/portal/trafficinfo?service=38&agency=101)

### **7. Malaysia Road Traffic Data**

Source: **xMap.ai**
Used for: **Road network modeling**, **travel-time predictions**, **Traffic Stress Map**.
🔗 [Link](https://www.xmap.ai/data-catalogs/malaysia-road-traffic-data)

---

## 🌍 **SDG Impact — SDG 11: Sustainable Cities & Communities**

* We are committed to building **Sustainable Cities & Communities** through a four-pronged approach:

* **🏠 Affordable Housing (SDG 11.1):** AI-driven matching to help B40/M40 demographics find affordable homes within their budget.
* **🚆 Green Mobility (SDG 11.2):** promoting public transport usage to reduce car dependency and traffic congestion.
* **📊 Smart Urbanization (SDG 11.3):** Providing data insights to bridge the gap between residents and urban planners.
* **🍃 Environmental Health (SDG 11.6):** Lowering carbon emissions and pollution through the promotion of a Transit-Oriented Development (TOD) lifestyle.

---

## 📱 **User Flow**

1. **Input:** Workplace, budget, commute preferences
2. **Process:** Backend calculates **Eco-Score**
3. **Visualize:** Bubble Tea Index, Time-Travel Maps
4. **Consult:** AI Agent roast / advice
5. **Predict:** Rental Growth Projection
6. **Decide:** Choose a sustainable, affordable home

---

## ⚙️ Installation & Run

### 1\. Prerequisites

Ensure you have the following installed:

  * **Flutter SDK** (Latest Stable)
  * **Node.js** (Required for Firebase CLI)
  * **Firebase CLI** (`npm install -g firebase-tools`)
  * **VS Code** (Recommended) with Flutter extension

### 2\. Clone & Setup

```bash
# Clone the repository
git clone https://github.com/your-username/ecohabit.git

# Navigate to project directory
cd ecohabit

# Install dependencies
flutter pub get
```

### 3\. Firebase Configuration (Crucial\!)

Since EcoHabit uses **Firebase AI Logic**, you must link it to your Firebase project:

```bash
# 1. Login to Firebase
firebase login

# 2. Configure FlutterFire (Select 'Web' platform)
flutterfire configure
```

*Note: Ensure **Gemini Developer API** is enabled in your Google Cloud Console for this project.*


### 4\. Run the App (Web Mode)

EcoHabit is optimized for Web. Run the following command to launch in Chrome:

```bash
flutter run -d chrome
```

-----
