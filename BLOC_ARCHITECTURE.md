# BLoC Architecture Implementation

## Overview

The frontend has been refactored to implement **Clean Architecture** with **BLoC pattern** for proper separation of concerns and feature-level isolation.

## Architecture Layers

```
lib/
├── core/
│   ├── dependency_injection/
│   │   └── service_locator.dart          # Dependency injection setup
│   ├── config/
│   ├── constants/
│   ├── network/
│   ├── theme/
│   └── utils/
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── user_model.dart
    │   │   │   └── login_response_model.dart
    │   │   └── datasources/
    │   │       ├── auth_remote_data_source.dart    # API calls
    │   │       └── auth_local_data_source.dart     # Secure storage
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── auth_repository.dart             # Repository interface & impl
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── auth_bloc.dart
    │       │   ├── auth_event.dart
    │       │   └── auth_state.dart
    │       └── pages/
    │           └── unified_login_page.dart          # ⚠️ Needs refactoring
    │
    ├── employee/
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── employee_model.dart
    │   │   └── datasources/
    │   │       └── employee_remote_data_source.dart
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── employee_repository.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── employee_bloc.dart
    │       │   ├── employee_event.dart
    │       │   └── employee_state.dart
    │       └── screens/
    │           └── employee_management_screen.dart  # ⚠️ Needs refactoring
    │
    └── clockin/
        ├── data/
        │   ├── models/
        │   │   ├── attendance_model.dart
        │   │   └── activity_model.dart
        │   └── datasources/
        │       └── attendance_remote_data_source.dart
        ├── domain/
        │   └── repositories/
        │       └── attendance_repository.dart
        └── presentation/
            ├── bloc/
            │   ├── attendance_bloc.dart
            │   ├── attendance_event.dart
            │   └── attendance_state.dart
            └── screens/
                └── clockin_screen.dart              # ⚠️ Needs refactoring
```

## Dependencies Added

```yaml
dependencies:
  flutter_bloc: ^8.1.6        # State management
  equatable: ^2.0.5           # Value equality
  flutter_dotenv: ^5.2.1      # Environment variables
  flutter_secure_storage: ^9.2.2  # Token storage
  http: ^1.2.0                # HTTP client
```

## Environment Configuration

**File: `.env`**
```env
API_BASE_URL=https://clockin-backend.permasparkapp.workers.dev
```

**Loading in main.dart:**
```dart
await dotenv.load(fileName: ".env");
```

**Usage in code:**
```dart
final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
```

## Data Flow

### Authentication Flow

1. **User Input** → `unified_login_page.dart`
2. **BLoC Event** → `LoginRequested(username, password)`
3. **BLoC Handler** → `AuthBloc._onLoginRequested()`
4. **Repository** → `AuthRepository.login()`
5. **Remote Data Source** → `AuthRemoteDataSource.login()` (HTTP call)
6. **Local Data Source** → `AuthLocalDataSource.saveToken()` (Secure storage)
7. **BLoC State** → `AuthAuthenticated(user)` or `AuthError(message)`
8. **UI Update** → BlocBuilder/BlocListener reacts to state changes

### Employee Management Flow

1. **Load Employees**:
   - Event: `LoadEmployees(token)`
   - State: `EmployeeLoading` → `EmployeeLoaded(employees)` or `EmployeeError`

2. **Add Employee**:
   - Event: `AddEmployee(token, name, email, password)`
   - State: `EmployeeLoading` → `EmployeeOperationSuccess` → `EmployeeLoaded` (auto-reload)

3. **Delete Employee**:
   - Event: `DeleteEmployee(token, empId)`
   - State: `EmployeeLoading` → `EmployeeOperationSuccess` → `EmployeeLoaded` (auto-reload)

### Attendance Flow

1. **Load Today's Attendance**:
   - Event: `LoadTodayAttendance(token, empId)`
   - State: `AttendanceLoading` → `AttendanceLoaded(attendance, activities)`

2. **Clock In**:
   - Event: `ClockIn(token, empId)`
   - State: `AttendanceLoading` → `AttendanceOperationSuccess` → Auto-reload data

3. **Clock Out**:
   - Event: `ClockOut(token, empId)`
   - State: `AttendanceLoading` → `AttendanceOperationSuccess` → Auto-reload data

4. **Break Management**:
   - Events: `StartBreak(token, empId)` / `EndBreak(token, empId)`
   - States: Same pattern as clock in/out

## Dependency Injection

**File: `service_locator.dart`**

```dart
ServiceLocator.setup();  // Called once in main()

// Access BLoCs
final authBloc = ServiceLocator.authBloc;
final employeeBloc = ServiceLocator.employeeBloc;
final attendanceBloc = ServiceLocator.attendanceBloc;
```

### Setup Order:
1. External dependencies (HTTP client, secure storage)
2. Data sources (remote & local)
3. Repositories (implements interfaces)
4. BLoCs (consumes repositories)

## Next Steps: UI Refactoring

### ⚠️ Files That Need BLoC Integration

1. **unified_login_page.dart**
   - Replace direct HTTP calls with `AuthBloc`
   - Add `BlocBuilder<AuthBloc, AuthState>` for UI updates
   - Add `BlocListener` for navigation on success

2. **employee_management_screen.dart**
   - Replace direct HTTP calls with `EmployeeBloc`
   - Use `BlocBuilder<EmployeeBloc, EmployeeState>` for employee list
   - Dispatch events: `LoadEmployees`, `AddEmployee`, `DeleteEmployee`

3. **clockin_screen.dart**
   - Replace `setState` with `AttendanceBloc`
   - Use `BlocBuilder<AttendanceBloc, AttendanceState>` for attendance data
   - Dispatch events: `LoadTodayAttendance`, `ClockIn`, `ClockOut`, `StartBreak`, `EndBreak`

### Example BLoC Integration Pattern

**Before (StatefulWidget with setState):**
```dart
class OldScreen extends StatefulWidget {
  void _loadData() async {
    final response = await http.get(url);
    setState(() {
      data = response;
    });
  }
}
```

**After (BLoC Pattern):**
```dart
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.someBloc..add(LoadData()),
      child: BlocBuilder<SomeBloc, SomeState>(
        builder: (context, state) {
          if (state is SomeLoading) return CircularProgressIndicator();
          if (state is SomeLoaded) return DataWidget(state.data);
          if (state is SomeError) return ErrorWidget(state.message);
          return SizedBox();
        },
      ),
    );
  }
}
```

## Benefits of This Architecture

✅ **Separation of Concerns**
- Presentation layer only handles UI
- Business logic in BLoC
- Data access in repositories

✅ **Testability**
- Each layer can be unit tested independently
- Mock repositories for testing BLoCs
- Mock data sources for testing repositories

✅ **Maintainability**
- Changes in API don't affect UI directly
- Easy to swap implementations (e.g., different HTTP clients)
- Clear file structure

✅ **Scalability**
- Feature-level isolation
- Easy to add new features
- Minimal coupling between modules

✅ **Security**
- API URLs in environment variables
- Tokens stored in secure storage (encrypted)
- No hardcoded secrets

## API Endpoints (Configured in .env)

Base URL: `https://clockin-backend.permasparkapp.workers.dev`

### Authentication
- `POST /api/auth/login` - Login (admin or employee)

### Employees (Admin only)
- `GET /api/employees` - List all employees
- `POST /api/employees` - Add new employee
- `DELETE /api/employees/:id` - Delete employee

### Attendance (Employee)
- `GET /api/attendance/today/:empId` - Get today's attendance
- `POST /api/attendance/clock-in` - Clock in
- `POST /api/attendance/clock-out` - Clock out
- `POST /api/attendance/break-start` - Start break
- `POST /api/attendance/break-end` - End break
- `GET /api/attendance/activities/:empId` - Get activity log
- `GET /api/attendance/summary/:empId` - Get attendance summary

## Models

### UserModel (Auth)
```dart
{
  id: String,
  name: String,
  role: String ('admin' | 'employee'),
  employeeId: String? (only for employees)
}
```

### EmployeeModel
```dart
{
  id: String,
  name: String,
  email: String,
  created_at: String?
}
```

### AttendanceModel
```dart
{
  id: int,
  emp_id: String,
  clock_in: String?,
  clock_out: String?,
  total_minutes: int?,
  status: String ('clocked_in' | 'on_break' | 'clocked_out'),
  created_at: String?,
  updated_at: String?
}
```

### ActivityModel
```dart
{
  id: int,
  emp_id: String,
  action: String,
  timestamp: String?,
  details: String?
}
```

## Status

✅ **Completed:**
- Added BLoC dependencies
- Created .env file with API_BASE_URL
- Implemented all data models
- Implemented all data sources (remote & local)
- Implemented all repositories
- Implemented all BLoCs (AuthBloc, EmployeeBloc, AttendanceBloc)
- Setup dependency injection
- Updated main.dart with MultiBlocProvider

🔄 **In Progress:**
- UI refactoring to use BLoC pattern

⏳ **Pending:**
- Refactor `unified_login_page.dart` to use AuthBloc
- Refactor `employee_management_screen.dart` to use EmployeeBloc
- Refactor `clockin_screen.dart` to use AttendanceBloc
- Remove old HTTP calls from UI layer
- Add error handling UI (SnackBars, Dialogs)
- Add loading indicators during API calls
