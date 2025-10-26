# App Owner Color Configuration Guide

## How to Set Hardcoded Colors for Your App

### 1. **Enable Owner Colors**
In `lib/config/app_owner_colors.dart`, set:
```dart
static const bool useOwnerColors = true;  // Enable owner colors
static const bool hideColorPicker = true; // Hide color picker from users
```

### 2. **Customize Your Colors**
Modify the color schemes in the same file:

#### **Primary Colors** (Main brand colors)
```dart
static const CustomColorScheme ownerLightScheme = CustomColorScheme(
  primary: Color(0xFF2E7D32),        // Your main brand color
  onPrimary: Color(0xFFFFFFFF),      // Text on primary color
  primaryContainer: Color(0xFFC8E6C9), // Lighter version of primary
  onPrimaryContainer: Color(0xFF1B5E20), // Text on primary container
  // ... other colors
);
```

#### **Secondary Colors** (Accent colors)
```dart
secondary: Color(0xFF1976D2),        // Your accent color
onSecondary: Color(0xFFFFFFFF),     // Text on secondary
secondaryContainer: Color(0xFFBBDEFB), // Lighter version
onSecondaryContainer: Color(0xFF0D47A1), // Text on container
```

### 3. **Color Scheme Options**

#### **Option A: Green Theme** (Default)
- Primary: Green (`#2E7D32`)
- Secondary: Blue (`#1976D2`)
- Tertiary: Purple (`#7B1FA2`)

#### **Option B: Red Theme** (Alternative)
- Primary: Red (`#D32F2F`)
- Secondary: Brown (`#5D4037`)
- Tertiary: Blue Grey (`#455A64`)

### 4. **How to Switch Themes**
You can create multiple themes and switch between them:

```dart
// In app_owner_colors.dart
static CustomColorScheme getOwnerLightScheme() {
  // Switch between themes based on conditions
  if (someCondition) {
    return alternativeLightScheme;
  }
  return ownerLightScheme;
}
```

### 5. **Dynamic Theme Switching**
For more advanced control, you can switch themes based on:
- App version
- User type (premium/free)
- Time of day
- Special events

```dart
static CustomColorScheme getOwnerLightScheme() {
  final now = DateTime.now();
  if (now.month == 12) { // December - Holiday theme
    return holidayLightScheme;
  }
  return ownerLightScheme;
}
```

### 6. **Testing Your Colors**
1. Set `useOwnerColors = true`
2. Run the app
3. Check both light and dark themes
4. Verify colors work well together
5. Test accessibility (contrast ratios)

### 7. **Color Guidelines**
- **Primary**: Your main brand color
- **Secondary**: Complementary accent color
- **Tertiary**: Additional accent color
- **Surface**: Background colors
- **Error**: Error/warning colors

### 8. **Accessibility**
Ensure good contrast ratios:
- Text on primary: at least 4.5:1 contrast ratio
- Text on surface: at least 4.5:1 contrast ratio
- Use tools like WebAIM Contrast Checker

### 9. **Disable User Color Selection**
When `useOwnerColors = true`:
- Users cannot change color mode
- Color picker is hidden (if `hideColorPicker = true`)
- Only theme mode (light/dark) can be changed

### 10. **Reverting to User Colors**
To allow users to choose colors again:
```dart
static const bool useOwnerColors = false;
static const bool hideColorPicker = false;
```

## Example: Brand Colors for Different Companies

### **Tech Company (Blue Theme)**
```dart
primary: Color(0xFF1976D2),      // Blue
secondary: Color(0xFF00BCD4),   // Cyan
tertiary: Color(0xFF9C27B0),    // Purple
```

### **Nature Company (Green Theme)**
```dart
primary: Color(0xFF4CAF50),     // Green
secondary: Color(0xFF8BC34A),   // Light Green
tertiary: Color(0xFF795548),    // Brown
```

### **Creative Agency (Purple Theme)**
```dart
primary: Color(0xFF9C27B0),     // Purple
secondary: Color(0xFFE91E63),   // Pink
tertiary: Color(0xFFFF9800),    // Orange
```

Remember to test your colors on both light and dark themes to ensure they work well in all conditions!
