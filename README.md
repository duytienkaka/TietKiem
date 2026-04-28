# 💰 Personal Finance Mobile App (Flutter)

## 📌 Overview

This project is a **mobile personal finance management application** built with **Flutter**.
It helps users track income and expenses, manage multiple wallets, and gain better control over their financial habits.

The app is designed with a **modern fintech UX/UI approach**, focusing on:

* Minimal user friction
* Fast data entry
* Clear financial insights
* Offline-first experience

---

## 🎯 Objectives

* Provide a simple yet powerful tool for managing personal finances
* Reduce friction when recording transactions
* Improve financial awareness through clear data visualization
* Deliver a **production-like UX** similar to real fintech apps

---

## 🛠️ Tech Stack

### 📱 Frontend

* Flutter (Material 3)
* Dart

### 🗄️ Local Storage

* Drift (SQLite ORM)
* Offline-first architecture

### 📦 Key Packages

* `drift` – local database
* `intl` – currency & date formatting
* `image_picker` – attach receipt images
* `math_expressions` – calculator feature
* `flutter_localizations` – multi-language support

---

## 🧱 Project Structure

```
lib/
├── core/               # Theme, constants, utilities
├── data/               # Database (Drift), models, repositories
├── features/
│   ├── home/
│   ├── transaction/
│   ├── wallet/
│   ├── statistics/
│   ├── profile/
│   └── settings/
├── shared/             # Reusable widgets
└── main.dart
```

---

## ✨ Core Features

### 💳 Wallet Management

* Create multiple wallets
* Track balance per wallet
* Visual wallet cards

---

### 💸 Transaction Management

* Add income / expense / transfer
* Attach receipt images
* Categorize transactions
* View transaction history

---

### 🔍 Transaction Detail (Read-only UX)

* Clean detail view
* Prevent accidental edits
* Edit via separate action

---

### ⚡ Quick Add (Optimized UX)

* Minimal steps to add transaction
* Smart defaults (last used data)
* Bottom sheet interaction

---

### 💰 Currency Formatting

* Real-time formatting (Vietnamese style)

  * `1000000 → 1.000.000`
* Clean number display

---

### 🧮 Built-in Calculator

* Standalone calculator (bottom sheet)
* Supports:

  * `+ - × ÷`
* Return result directly into amount input

---

### 📊 Statistics

* Expense breakdown (categories)
* Income vs expense charts
* Time-based filtering

---

### 🌐 Localization (i18n)

* Vietnamese (default)
* English (fallback)
* Easy to extend

---

### 👤 Profile Screen

* Avatar
* User info
* Basic stats

---

### ⚙️ Settings Screen

* Language switch
* Dark mode (optional)
* Data management (export/reset)
* App info

---

## 🧠 UX Principles

* **Zero-think interaction**: minimal decisions required
* **Fast input**: < 3 seconds to add transaction
* **Visual clarity**: strong hierarchy (amount, type, status)
* **Safe editing**: controlled modification of data
* **Feedback-driven UI**: animations & micro-interactions

---

## 🔄 User Flow (Simplified)

```
Open App
	↓
View Dashboard
	↓
Tap "Add Transaction"
	↓
Enter Amount (or use Calculator)
	↓
Confirm
	↓
View Updated Balance
```

---

## 🔐 Data & Storage

* All data is stored **locally on device**
* No internet required
* SQLite database via Drift
* Designed for persistence and performance

---

## 🚀 Getting Started

### 1. Clone repo

```bash
git clone <repo-url>
cd <project-folder>
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run app

```bash
flutter run
```

---

## 📦 Build

```bash
flutter build apk
flutter build ios
```

---

## 🧪 Future Improvements

* 🔐 App lock (PIN / biometrics)
* ☁️ Cloud sync & backup
* 🧠 Smart suggestions (AI-based categorization)
* 📈 Advanced analytics
* 🔔 Notifications & reminders
* 🌙 Full dark mode system

---

## 🤖 Agent Instructions (IMPORTANT)

This section helps AI agents understand how to work with this project.

### 🔧 Rules for modifying code

* Do NOT break existing business logic
* Follow current architecture (feature-based)
* Reuse existing widgets/components
* Keep UI consistent (Material 3 + fintech style)

---

### 🎯 Priorities when implementing features

1. UX first (reduce user actions)
2. Clean UI (card-based, spacing, hierarchy)
3. Performance (avoid unnecessary rebuilds)
4. Scalability (modular code)

---

### 🧩 Code Guidelines

* Use `const` where possible
* Split large widgets into smaller components
* Avoid hardcoded strings → use localization
* Keep database logic in repository layer

---

### ❗ Common Pitfalls to Avoid

* Hardcoding UI text
* Breaking navigation flow
* Overusing fixed sizes (causes overflow)
* Ignoring SafeArea / padding
* Poor state management

---

## 📄 License

This project is for educational and development purposes.

---

## 👨‍💻 Author

Developed as a personal project to explore:

* Flutter development
* UX/UI design
* Fintech application patterns

---

## ⭐ Final Note

This project is not just a CRUD app — it is designed to simulate a **real-world financial application** with attention to:

* User experience
* Performance
* Scalability
* Maintainability

---

👉 Feel free to contribute, extend, or use as a foundation for production apps.
