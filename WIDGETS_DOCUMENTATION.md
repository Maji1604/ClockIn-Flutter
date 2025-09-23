# 🎨 Shared Widgets Documentation

## Clean Separation of Concerns

The shared widgets have been split into focused, single-responsibility files for better maintainability and reusability.

### 📁 Widget Organization

```
lib/shared/widgets/
├── loading_widget.dart        # Loading states and indicators
├── error_widget.dart         # Error displays and handling
├── empty_widget.dart         # Empty state presentations
├── app_buttons.dart          # Button components
├── app_text_fields.dart      # Input field components
├── app_cards.dart            # Card and information displays
├── layout_widgets.dart       # Layout helpers and utilities
├── navigation_widgets.dart   # Navigation components
└── common_widgets.dart       # Re-exports for backward compatibility
```

---

## 🔄 Loading Components (`loading_widget.dart`)

### LoadingWidget
```dart
LoadingWidget(
  size: 50.0,
  message: "Loading data...",
)
```

### SimpleLoadingWidget
```dart
SimpleLoadingWidget(
  size: 20.0,
  strokeWidth: 2.0,
)
```

### LoadingOverlay
```dart
LoadingOverlay(
  isLoading: true,
  message: "Please wait...",
  child: YourContent(),
)
```

---

## ❌ Error Components (`error_widget.dart`)

### AppErrorWidget
```dart
AppErrorWidget(
  message: "Something went wrong",
  onRetry: () => retryAction(),
)
```

### InlineErrorWidget
```dart
InlineErrorWidget(
  message: "Validation failed",
  onRetry: () => retry(),
)
```

### NetworkErrorWidget
```dart
NetworkErrorWidget(
  onRetry: () => checkConnection(),
)
```

---

## 📭 Empty State Components (`empty_widget.dart`)

### EmptyWidget
```dart
EmptyWidget(
  message: "No data available",
  icon: Icons.inbox,
  action: ElevatedButton(...),
)
```

### EmptySearchWidget
```dart
EmptySearchWidget(
  searchTerm: "flutter",
  onClear: () => clearSearch(),
)
```

### EmptyListWidget
```dart
EmptyListWidget(
  title: "No employees found",
  subtitle: "Add your first employee to get started",
  onAdd: () => addEmployee(),
)
```

### FeatureEmptyWidget
```dart
FeatureEmptyWidget(
  featureName: "Payroll Management",
  description: "Set up payroll processing for your organization",
  onGetStarted: () => setupPayroll(),
)
```

---

## 🔘 Button Components (`app_buttons.dart`)

### AppButton
```dart
AppButton(
  text: "Submit",
  onPressed: () => submit(),
  isLoading: false,
  icon: Icons.send,
)
```

### AppOutlinedButton
```dart
AppOutlinedButton(
  text: "Cancel",
  onPressed: () => cancel(),
)
```

### AppTextButton
```dart
AppTextButton(
  text: "Learn More",
  icon: Icons.info,
  onPressed: () => showInfo(),
)
```

### AppFloatingActionButton
```dart
AppFloatingActionButton(
  icon: Icons.add,
  onPressed: () => addItem(),
  tooltip: "Add new item",
)
```

---

## 📝 Input Components (`app_text_fields.dart`)

### AppTextField
```dart
AppTextField(
  controller: controller,
  labelText: "Name",
  hintText: "Enter your name",
  prefixIcon: Icon(Icons.person),
  validator: (value) => validateName(value),
)
```

### PasswordTextField
```dart
PasswordTextField(
  controller: passwordController,
  labelText: "Password",
  validator: (value) => validatePassword(value),
)
```

### EmailTextField
```dart
EmailTextField(
  controller: emailController,
  onChanged: (value) => updateEmail(value),
)
```

### SearchTextField
```dart
SearchTextField(
  controller: searchController,
  hintText: "Search employees...",
  onChanged: (query) => search(query),
)
```

---

## 🃏 Card Components (`app_cards.dart`)

### AppCard
```dart
AppCard(
  child: YourContent(),
  onTap: () => navigate(),
  padding: EdgeInsets.all(16),
)
```

### InfoCard
```dart
InfoCard(
  title: "Department",
  value: "Engineering", 
  icon: Icons.business,
  onTap: () => viewDepartment(),
)
```

### StatCard
```dart
StatCard(
  title: "Total Employees",
  value: "127",
  subtitle: "+5 this month",
  icon: Icons.people,
  color: Colors.blue,
)
```

---

## 📐 Layout Components (`layout_widgets.dart`)

### ResponsiveLayout
```dart
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### Spacing Widgets
```dart
VerticalSpacing.medium()     // 16px height
HorizontalSpacing.large()    // 24px width
AppSpacing.custom(40)        // Custom size
```

### ConditionalWrapper
```dart
ConditionalWrapper(
  condition: isEditable,
  wrapper: (child) => GestureDetector(onTap: edit, child: child),
  child: content,
)
```

### SafeAreaWrapper
```dart
SafeAreaWrapper(
  padding: EdgeInsets.all(16),
  child: YourContent(),
)
```

### KeyboardDismissWrapper
```dart
KeyboardDismissWrapper(
  child: YourScrollView(),
)
```

---

## 🧭 Navigation Components (`navigation_widgets.dart`)

### AppBarWidget
```dart
AppBarWidget(
  title: "Dashboard",
  actions: [IconButton(...)],
  centerTitle: true,
)
```

### DrawerItem
```dart
DrawerItem(
  icon: Icons.dashboard,
  title: "Dashboard",
  isSelected: true,
  onTap: () => navigate(),
)
```

### BreadcrumbNavigation
```dart
BreadcrumbNavigation(
  items: [
    BreadcrumbItem(title: "Home", onTap: () => goHome()),
    BreadcrumbItem(title: "Employees", onTap: () => goEmployees()),
    BreadcrumbItem(title: "Profile"),
  ],
)
```

---

## 🎯 Benefits of Separation

### ✅ **Single Responsibility**
- Each file focuses on one specific UI concern
- Easier to find and modify specific components
- Reduced cognitive load when working with widgets

### ✅ **Improved Maintainability**
- Changes to loading widgets don't affect error widgets
- Easier to test individual component categories
- Clear ownership and responsibility boundaries

### ✅ **Better Reusability**
- Import only what you need: `import 'shared/widgets/loading_widget.dart';`
- Smaller bundle sizes in web builds
- Cleaner dependency management

### ✅ **Enhanced Discoverability**
- Developers can quickly find the right widget type
- IDE autocomplete works better with focused imports
- Self-documenting file structure

### ✅ **Backward Compatibility**
- `common_widgets.dart` re-exports everything
- Existing code continues to work without changes
- Gradual migration path available

---

## 🚀 Usage Examples

### Before (All in one file):
```dart
import 'shared/widgets/common_widgets.dart';

// Not clear what widgets are available
// Large import for just one widget
```

### After (Focused imports):
```dart
import 'shared/widgets/loading_widget.dart';
import 'shared/widgets/app_buttons.dart';

// Clear intent and smaller imports
// Better IDE support and autocomplete
```

### Migration Strategy:
1. **Immediate**: All existing code works unchanged
2. **Gradual**: Update imports file by file as needed
3. **New Code**: Use specific widget imports from the start

This separation provides a solid foundation for scaling the UI components while maintaining clean, focused, and reusable code.