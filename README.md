# 🩺 Carenet

Carenet is a digital health platform designed to connect patients with licensed health practitioners and grant access to reliable healthcare systems. It streamlines patient–doctor interactions, appointment scheduling, and medical data management—all in one unified platform.

---

## 🚀 Features

- 📱 Connect with licensed health practitioners
- 🏥 Book appointments with hospitals and clinics
- 🧾 Maintain and access medical records securely
- 🔔 Get reminders for medications and check-ups
- 📊 Monitor and track personal health metrics

---

## 🧱 Project Architecture

This project follows the **Clean Architecture** pattern for improved scalability, modularity, and testability.

### 🧭 Layered Structure

- **Presentation Layer**  
  UI components, view models, and state management.

- **Domain Layer**  
  Core business logic, use cases, and entities.

- **Data Layer**  
  Network services, repositories, and data models.

- **Shared Layer** *(optional)*  
  Common themes, constants, utilities, and resources.

### 📁 Sample Folder Structure

lib/
├── core/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── ...
├── shared/
└── main.dart


---

## 🌿 Branching Strategy

To maintain a clean and stable repository, we follow these rules:

### `main` Branch
- The **stable** and **production-ready** branch.
- No direct commits—only pull requests (PRs) after peer review and successful testing.

### Developer Feature Branches
- Each developer must work on their **own branch**, using this naming format:
- Branch name <feature name>
- All feature development, testing, and debugging must occur here.

### Pull Request Guidelines
- Once a feature is complete, submit a **PR to the `main` branch**.
- Ensure your branch is **up to date** with `main` before submitting.
- All PRs must:
- Be reviewed by at least one other contributor.
- Pass all tests.
- Contain meaningful commit messages.
- Once merged, branch must be replaced by next feature

---

## 🛠️ Tech Stack

- **Flutter**: `>=3.27.0`
- **Dart**
- **REST API** (for external integrations)

---

## 🧪 Testing

Carenet uses layered testing for each part of the architecture:

### ✅ What to Test
- **Unit tests** for domain logic (use cases, entities)
- **Widget tests** for UI
- **Integration tests** for external service interaction

### 🧪 Run Tests

```bash
flutter test
