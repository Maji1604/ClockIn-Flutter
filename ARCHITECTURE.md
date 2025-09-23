# Creoleap HRMS - BLoC Architecture

## Project Structure

This Flutter project follows Clean Architecture principles with BLoC state management pattern.

### 📁 Folder Structure

```
lib/
├── core/                          # Core utilities and shared logic
│   ├── constants/
│   │   └── app_constants.dart     # App-wide constants
│   ├── errors/
│   │   ├── exceptions.dart        # Custom exceptions
│   │   └── failures.dart          # Failure models
│   ├── network/
│   │   └── http_client.dart       # HTTP client configuration
│   ├── utils/
│   │   └── logger.dart           # Custom logger with log levels
│   ├── di/
│   │   └── injection_container.dart  # Dependency injection setup
│   └── core.dart                 # Core exports
├── features/                      # Feature-based modules
│   └── auth/                      # Authentication feature
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Data sources (remote, local)
│       │   ├── models/            # Data models
│       │   ├── repositories/      # Repository implementations
│       │   └── data.dart          # Data layer exports
│       ├── domain/                # Domain layer
│       │   ├── entities/          # Business entities
│       │   ├── repositories/      # Repository contracts
│       │   ├── usecases/          # Use cases
│       │   └── domain.dart        # Domain layer exports
│       ├── presentation/          # Presentation layer
│       │   ├── bloc/              # BLoC files
│       │   ├── pages/             # UI pages
│       │   ├── widgets/           # UI widgets
│       │   └── presentation.dart  # Presentation layer exports
│       └── auth.dart              # Feature exports
├── shared/                        # Shared widgets and utilities
│   ├── widgets/
│   │   └── common_widgets.dart    # Reusable widgets
│   └── shared.dart                # Shared exports
└── main.dart                      # App entry point
```

### 🏗️ Architecture Layers

#### Core Layer
- **Constants**: App-wide constants and configuration
- **Utils**: Logger with multiple log levels (debug, info, warning, error, critical)
- **Errors**: Custom exceptions and failure models
- **Network**: HTTP client setup with interceptors
- **DI**: Dependency injection container (ready for implementation)

#### Feature Layer (Auth Example)
Each feature follows Clean Architecture with three layers:

1. **Data Layer**
   - Remote/Local data sources
   - Data models (with JSON serialization)
   - Repository implementations

2. **Domain Layer**
   - Business entities
   - Repository contracts
   - Use cases (business logic)

3. **Presentation Layer**
   - BLoC (Events, States, Business Logic)
   - Pages (UI screens)
   - Widgets (UI components)

### 🎯 BLoC Pattern Implementation

#### Auth Feature BLoC Structure:
- **AuthEvent**: All authentication events (login, register, logout, etc.)
- **AuthState**: All authentication states (loading, success, failure, etc.)
- **AuthBloc**: Handles business logic and state transitions

#### Key Features:
- ✅ Event-driven architecture
- ✅ Separation of concerns
- ✅ Testable business logic
- ✅ Reactive UI updates
- ✅ Error handling
- ✅ Logging integration

### 🔧 Custom Logger

The logger supports multiple log levels with color-coded output:
- **DEBUG** (White): Development information
- **INFO** (Cyan): General information
- **WARNING** (Yellow): Potential issues
- **ERROR** (Red): Error conditions
- **CRITICAL** (Magenta): Critical failures

Usage:
```dart
AppLogger.info('User logged in successfully', 'AUTH');
AppLogger.error('Login failed', 'AUTH', error, stackTrace);
```

### 📦 Dependencies

Key packages used:
- `flutter_bloc`: BLoC state management
- `bloc`: Core BLoC library
- `equatable`: Value equality
- `get_it`: Dependency injection
- `dartz`: Functional programming
- `dio`: HTTP client
- `shared_preferences`: Local storage

### 🚀 Next Steps

To implement a new feature:
1. Create feature folder: `lib/features/new_feature/`
2. Implement Clean Architecture layers (domain → data → presentation)
3. Create BLoC files (events, states, bloc)
4. Add UI pages and widgets
5. Register dependencies in injection container
6. Add to main app providers

### 📝 Development Guidelines

- Each feature should be self-contained
- Use dependency injection for loose coupling
- Follow naming conventions (PascalCase for classes, snake_case for files)
- Include proper error handling and logging
- Write tests for business logic (use cases and BLoCs)
- Keep UI widgets small and focused

This structure provides a solid foundation for scaling the HRMS application with additional features while maintaining clean, testable, and maintainable code.