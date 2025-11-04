# 🏕️ ScoutTrack

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white)
![SignalR](https://img.shields.io/badge/SignalR-68217A?style=for-the-badge&logo=dotnet&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🎯 Project Overview

**ScoutTrack** is a comprehensive digital platform for the Scout Association (SIFBiH) — designed to modernize scouting operations by centralizing member management, event organization, communication, and activity tracking.

It unifies:

- **Members (Scouts)** – through a mobile app  
- **Troops (Odredi)** – through a desktop app  
- **Administrators (SIFBiH)** – through a desktop app with full control and analytics  

ScoutTrack replaces disparate tools (spreadsheets, chat groups, manual tracking) with a modern system that supports the spirit of scouting: **community, learning, adventure**.

---

## 🧩 System Architecture

### Roles & Interfaces

| Role                          | Interface           | Responsibilities                                                   |
|-------------------------------|---------------------|-------------------------------------------------------------------|
| 🧍‍♂️ Member (Scout / Izviđač)   | Mobile App (Flutter)| Browse & join activities, track badges, connect with peers        |
| 🏕️ Troop (Odred)              | Desktop App (Flutter for Windows) | Manage members, events, galleries, badges, announcements       |
| 🏛️ Administrator (SIFBiH)     | Desktop App         | Oversee all troops and members, moderate content, analytics, global reports   |

### Key Infrastructure Components

- **Backend API** built in .NET (C#)  
- **Database**: Microsoft SQL Server  
- **Messaging & Eventing**: RabbitMQ for asynchronous communication (e.g., background tasks, notifications)  
- **Real-time updates**: SignalR used for live notifications and event changes (e.g., attendance updates, chat)  
- **Containerization**: Docker + Docker Compose  
- **Storage**: Local filesystem for uploaded images/documents (wwwroot/images)  
- **Auth**: JWT Token-based authentication  
- **Recommendation Engine**: Hybrid (Content-based & User-based filtering)  

---

## 📱 Mobile Application

Built with Flutter, the mobile app is tailored for scout members to engage with their troop and events.

#### Key Features

- Personalized **Home Screen** with recommended activities  
- **Activity Calendar** – colour-coded days with events  
- Join / Cancel event participation
- Leave reviews for activities participated in
- View **Event Details**, **Galleries**, **Reviews**  
- Upload photos, like and comment on event galleries  
- Manage **Profile**, **Badges** (vještarstva)  
- Receive **Push Notifications** (via backend + SignalR)  
- Interactive map of troop locations  
- Add & manage **Friends**, get recommendations  
- Access official scout documents  

---

## 💻 Desktop Application

### 🏕️ Troop (Odred) Module

This module allows each troop leadership to manage their internal operations.

**Features include:**

- CRUD operations for members  
- Event creation, registration handling, attendance 
- Upload & manage event galleries  
- Assign and track badges (vještarstva)  
- Announcements to members  
- Generate **PDF reports** and view statistics dashboard  
- Real-time updates via SignalR (e.g., registration status updates)  
- Background tasks via RabbitMQ (e.g., sending notifications, report generation)

### 🏛️ Administrator Module

Full federation-level control for oversight and analytics.

**Features include:**

- Manage all troops, members, activities, registrations, reviews, etc. across the platform  
- Moderate content: posts, comments, galleries  
- Manage and define badges (vještarstva) and skill requirements  
- Advanced analytics dashboard with charts: most active troops/members, participation trends, demographic breakdowns  
- Generate federation-level reports (PDF)  
- Use of RabbitMQ for cross-module communication and service orchestration  

---

## ✨ Recommendation System

A hybrid recommendation engine is built to enhance engagement:

- 🧭 **Content-based filtering**: Suggests activities based on member’s past participation, preferences, location, and reviews.  
- 👥 **User-based filtering**: Recommends potential friends (scout connections) based on interest similarity and interaction patterns.  

---

## 🗄️ Technologies Used

| Layer               | Technology                                  |
|----------------------|----------------------------------------------|
| **Mobile Frontend**  | Flutter                                      |
| **Desktop Frontend** | Flutter (Windows/Desktop)                     |
| **Backend/API**      | .NET 8 (C#)                                   |
| **Database**         | Microsoft SQL Server                          |
| **Auth**             | JWT Token-based                               |
| **Messaging/Eventing**| RabbitMQ                                     |
| **Real-time Communication**| SignalR                                |
| **Containerization** | Docker                                        |

---

## ⚙️ Setup & Installation

### 🧱 Prerequisites

- [.NET 8+ SDK](https://dotnet.microsoft.com/)  
- [SQL Server](https://www.microsoft.com/en-us/sql-server)  
- [Docker Desktop](https://www.docker.com/)  
- [Flutter SDK](https://flutter.dev/)  
- [RabbitMQ](https://www.rabbitmq.com/)  

---

## Running the Application

### 1. Prepare backend
- Unpack `fit-build-2025_env.zip`  
- Inside the folder, run: 
   ```bash
  docker-compose up --build
   ```

### 2. Mobile App
- Unpack `fit-build-2025-11-01.zip`
- Find the APK: `fit-build-2025-11-03/flutter-apk/app-release.apk`
- Drag & drop APK into Android Emulator (AVD)
- Launch the app in emulator
- **API Base URL:** `http://10.0.2.2:5164/`

### 3. Desktop App
- In the same extracted zip, go to: `fit-build-2025-11-03/Release/`
- Run the `.exe` file
- **API Base URL:** `http://localhost:5164/`

---

### Test Accounts

**Desktop :**
| Role      | Username | Password |
| --------- | -------- | -------- |
| 🛠️ Admin | `admin`  | `test`   |
| 🏕️ Troop | `troop`  | `test`   |

**Mobile:**
| Role      | Username | Password |
| --------- | -------- | -------- |
| 👤 Member | `member` | `test`   |

Additionally, there are several troop and member test accounts available, all using the password `test`.

---

## License

This project is licensed under the [MIT License](https://github.com/aminag03/ScoutTrack/blob/main/LICENSE).
