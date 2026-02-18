# Bal Vikas - Early Childhood Development Screening Platform

A comprehensive ECD (Early Childhood Development) screening and intervention platform for the Andhra Pradesh Government ECD Innovation Challenge.

## 📋 Project Overview

**Bal Vikas** is a full-stack Flutter application with FastAPI backend for screening children aged 0-6 years for developmental delays and providing intervention recommendations.

### Key Features
- ✅ Mobile-based developmental screening
- ✅ WHO-based growth monitoring (Z-scores)
- ✅ Developmental Quotient (DQ) calculations
- ✅ Risk classification and referrals
- ✅ Telugu localization
- ✅ Offline capability
- ✅ Excel export matching official ECD format
- ✅ Intervention activity recommendations

## 🏗️ Architecture

### Backend (FastAPI + PostgreSQL)
```
bal-vikas-backend/
├── app/
│   ├── api/          # API endpoints
│   ├── models/       # SQLAlchemy models
│   ├── schemas/      # Pydantic schemas
│   ├── services/     # Business logic
│   └── utils/        # Utilities
├── requirements.txt
├── Dockerfile
└── docker-compose.yml
```

### Frontend (Flutter)
```
bal_vikas_app/
├── lib/
│   ├── config/       # App configuration
│   ├── models/       # Data models
│   ├── providers/    # Riverpod state management
│   ├── screens/      # UI screens
│   ├── services/     # API services
│   └── widgets/      # Reusable widgets
├── assets/
└── pubspec.yaml
```

## 🚀 Quick Start

### Backend Setup

1. **Prerequisites**
   - Docker & Docker Compose
   - Python 3.11+ (for local development)

2. **Start with Docker**
   ```bash
   cd bal-vikas-backend
   docker-compose up --build
   ```

3. **Access APIs**
   - API Base URL: `http://localhost:8000`
   - API Documentation: `http://localhost:8000/docs`

### Frontend Setup

1. **Prerequisites**
   - Flutter 3.16+
   - Android Studio / Xcode

2. **Install dependencies**
   ```bash
   cd bal_vikas_app
   flutter pub get
   ```

3. **Update API URL**
   Edit `lib/config/api_config.dart` and set your backend URL:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:8000';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

   Or build APK:
   ```bash
   flutter build apk --release
   ```

## 📊 Demo Data

The app includes demo children:
- **Arjun** (30 months) - Medium risk, language delay
- **Meera** (54 months) - Low risk, typical development

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/send-otp` - Send OTP to mobile
- `POST /api/auth/verify-otp` - Verify OTP and get token
- `GET /api/auth/profile` - Get user profile

### Children
- `GET /api/children` - List children
- `POST /api/children` - Register child
- `GET /api/children/{id}` - Get child details

### Screening
- `POST /api/screening/start` - Start screening session
- `POST /api/screening/{id}/responses` - Save responses
- `POST /api/screening/{id}/complete` - Complete and calculate
- `GET /api/screening/{id}` - Get session details

### Interventions
- `GET /api/interventions/recommend/{childId}` - Get activities
- `GET /api/interventions/activities` - List all activities

### Export
- `POST /api/export/child/{childId}/excel` - Export as Excel

## 📱 Screenshots

### Key Screens
1. **Login** - Mobile OTP authentication
2. **Dashboard** - Role-based dashboard (AWW/Parent)
3. **Children List** - View registered children
4. **Screening** - Multi-step questionnaire
5. **Results** - DQ scores and risk classification
6. **Settings** - Language preferences

## 🌐 Localization

The app supports:
- English (en)
- Telugu (te)

Switch languages in Settings.

## 📈 Scoring Methodology

### Developmental Quotient (DQ)
```
DQ = (Developmental Age / Chronological Age) × 100
```
- Delay threshold: < 85
- Mild delay: 70-84
- Significant delay: < 70

### Nutrition (WHO Standards)
- Height-for-age Z-score
- Weight-for-age Z-score
- Classification: Normal / Moderate / Severe

### Risk Classification
- **HIGH**: ≥3 delays OR high autism/behavior risk
- **MEDIUM-HIGH**: 2 delays OR medium autism + 1 delay
- **MEDIUM**: 1 delay OR medium behavior/nutrition risk
- **LOW**: No concerns

## 🤖 Intervention Bot Concept

The platform includes a conceptual "Bal Vikas Bot" that would:
- Deliver personalized intervention activities
- Provide video demonstrations
- Track progress
- Integrate with physical robots at Anganwadi centers

## 📦 Excel Export Format

Exports match the official ECD sample dataset with sheets:
1. A_Registration
2. Developmental_Assessment
3. Developmental_Risk
4. Neuro_Behavioral
5. Behaviour_Indicators
6. Environment_Caregiving
7. Nutrition
8. Baseline_Risk_Output

## 🔒 Security

- JWT token-based authentication
- OTP verification for login
- Role-based access control

## 📝 License

This project is built for the Andhra Pradesh Government ECD Innovation Challenge.

## 👥 Team

Built with ❤️ for early childhood development in India.

## 📞 Support

For issues or questions:
- Check API docs at `/docs`
- Review Flutter logs with `flutter run -v`
- Check Docker logs with `docker-compose logs`

---

**Submission Deadline:** February 22, 2025
