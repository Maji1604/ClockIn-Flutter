# ClockIn - Flutter HRMS Frontend

## 🚀 Overview
A modern, production-ready Flutter frontend for ClockIn HRMS (Human Resource Management System) built with Clean Architecture and BLoC state management.

## ✨ Features
- **🏗️ Clean Architecture** - Proper separation of concerns with domain/data/presentation layers
- **🎨 Advanced Theming** - Light/Dark mode with Material Design 3
- **🔐 Authentication System** - Complete login/register flow with BLoC pattern
- **📱 Responsive Design** - Works on mobile, tablet, and desktop
- **⚡ Performance Optimized** - Lazy loading and efficient state management
- **🧪 Type Safe** - Full null safety and comprehensive error handling

## 🏛️ Architecture

### Clean Architecture Layers
```
lib/
├── core/                    # Core utilities & shared logic
│   ├── config/             # Environment configuration
│   ├── constants/          # App constants & colors
│   ├── theme/              # Theme system (light/dark)
│   ├── utils/              # Utilities (logger, etc.)
│   ├── errors/             # Custom exceptions & failures
│   ├── network/            # HTTP client setup
│   └── dependency_injection/ # DI container
├── features/               # Feature modules
│   └── auth/               # Authentication feature
│       ├── domain/         # Business entities & use cases
│       ├── data/           # Data sources & repositories
│       └── presentation/   # BLoC, pages & widgets
└── shared/                 # Shared UI components
    └── widgets/            # Reusable widget library
```

### State Management
- **BLoC Pattern** - Event-driven reactive architecture
- **Clean Separation** - Business logic separated from UI
- **Type Safety** - Strongly typed events and states
- **Error Handling** - Comprehensive error propagation

## 🎨 Theme System
- **Material Design 3** - Latest design specifications
- **Light/Dark Mode** - Automatic system detection
- **Theme Persistence** - Remembers user preference
- **Custom Colors** - HR-specific color coding
- **Accessibility** - Proper contrast ratios

## 📦 Dependencies
```yaml
# State Management
bloc: ^8.1.2
flutter_bloc: ^8.1.3
equatable: ^2.0.5

# Architecture
get_it: ^7.6.4              # Dependency Injection
dartz: ^0.10.1              # Functional Programming

# Network & Storage
dio: ^5.3.2                 # HTTP Client
shared_preferences: ^2.2.2  # Local Storage
flutter_dotenv: ^5.1.0      # Environment Variables
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/Maji1604/ClockIn.git
   cd ClockIn
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env file with your configuration
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Build for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🧪 Testing & Quality
```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Check test coverage
flutter test --coverage
```

## 🔧 Configuration

### Environment Variables (.env)
```bash
# API Configuration
API_BASE_URL=https://your-api-url.com/v1
API_KEY=your_api_key_here

# Authentication
JWT_SECRET_KEY=your_jwt_secret
JWT_EXPIRY_HOURS=24

# Feature Flags
ENABLE_BIOMETRIC_AUTH=true
ENABLE_DARK_MODE=true
```

## 📱 Features Roadmap

### ✅ Completed
- [x] Clean Architecture setup
- [x] Authentication module
- [x] Theme system (light/dark)
- [x] Environment configuration
- [x] Core infrastructure

### 🚧 In Progress
- [ ] Employee management
- [ ] Attendance tracking
- [ ] Leave management
- [ ] Dashboard & analytics

### 📋 Planned
- [ ] Payroll management
- [ ] Performance reviews
- [ ] Document management
- [ ] Notifications system
- [ ] Reports generation

## 🏢 HRMS Modules

### Employee Management
- Employee profiles and information
- Organizational hierarchy
- Department and role management
- Employee onboarding/offboarding

### Attendance & Time Tracking
- Clock-in/Clock-out functionality
- Biometric integration
- Overtime tracking
- Shift management

### Leave Management
- Leave request and approval workflow
- Leave balance tracking
- Holiday calendar
- Leave policies

### Payroll
- Salary calculations
- Payslip generation
- Tax calculations
- Benefits management

## 🤝 Contributing

1. **Fork the repository**
2. **Create feature branch:** `git checkout -b feature/new-feature`
3. **Commit changes:** `git commit -m 'Add new feature'`
4. **Push to branch:** `git push origin feature/new-feature`
5. **Submit pull request**

### Development Guidelines
- Follow Clean Architecture principles
- Write comprehensive tests
- Follow Flutter/Dart style guide
- Update documentation
- Use conventional commits

## 📚 Documentation
- [Architecture Guide](ARCHITECTURE.md)
- [Theme System](THEME_SYSTEM.md)
- [Widget Library](WIDGETS_DOCUMENTATION.md)
- [Setup Complete](SETUP_COMPLETE.md)

## 📄 License
This project is licensed under the MIT License.

## 🙏 Acknowledgments
- Flutter team for the amazing framework
- BLoC library maintainers
- Material Design team
- Open source community

---
**Built with ❤️ using Flutter & Clean Architecture**
