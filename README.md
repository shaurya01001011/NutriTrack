# NutriTrack - Nutrition Tracking App

A complete nutrition tracking Flutter application for Semester 4 project. This app helps users track their daily food intake, monitor calories and macros, and achieve their health goals.

## Features

### ✅ Implemented Features

1. **User Profile System**
   - Personal information (name, age, gender, height, weight)
   - Activity level selection (sedentary to very active)
   - Goal setting (lose, maintain, gain weight)
   - Automatic BMR and TDEE calculation using Mifflin-St Jeor equation
   - Personalized daily calorie and macro targets

2. **Food Database**
   - 75+ Indian and common foods with nutritional information
   - Categories: Staples, Legumes, Dairy, Vegetables, Fruits, Proteins, Nuts & Seeds, Sweets
   - Search functionality with category filtering
   - Nutritional data per 100g (calories, protein, carbs, fat, fiber)

3. **Meal Tracking**
   - Add foods to breakfast, lunch, dinner, or snacks
   - Weight-based nutrition calculation
   - Real-time nutrition display
   - Automatic meal entry saving

4. **Dashboard**
   - Daily progress overview with greeting
   - Calorie tracking with progress bar
   - Macro tracking (protein, carbs, fat)
   - Today's meals organized by type
   - Visual calorie cards with remaining calories

5. **History & Reports**
   - Daily view with expandable meal details
   - Weekly view with 7-day calorie trend chart
   - Weekly summary statistics
   - Daily breakdown with totals
   - Delete individual days or all history

6. **Data Persistence**
   - Local storage using SharedPreferences
   - User profile data saved
   - Meal history preserved
   - Survives app restarts

7. **Settings**
   - Clear today's meals
   - Clear all history
   - Profile editing
   - Logout functionality
   - About and privacy policy

8. **UI/UX**
   - Modern Material Design 3
   - Green color theme
   - Gradient backgrounds
   - Card-based layouts
   - Smooth navigation
   - Responsive design

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Date/Time**: intl package

## Project Structure

```
nutritrack/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user.dart            # User profile model
│   │   ├── food.dart            # Food item model
│   │   └── meal_entry.dart      # Meal entry model
│   ├── providers/                # State management
│   │   ├── user_provider.dart   # User data provider
│   │   └── meal_provider.dart   # Meal data provider
│   ├── screens/                  # UI screens
│   │   ├── login.dart           # Login screen
│   │   ├── home.dart            # Home dashboard
│   │   ├── profile.dart         # User profile
│   │   ├── add_food.dart        # Food selection
│   │   ├── food_details.dart    # Food details & add
│   │   ├── history.dart         # History & reports
│   │   └── settings.dart        # Settings
│   ├── services/                 # Business logic
│   │   ├── nutrition_service.dart # Nutrition calculations
│   │   └── bluetooth_services.dart # Bluetooth (future)
│   ├── data/                     # Static data
│   │   └── food.dart            # Food database
│   └── widgets/                  # Reusable widgets
│       ├── calorie_card.dart    # Calorie display card
│       └── progress_bar.dart   # Progress bar widget
└── pubspec.yaml                 # Dependencies
```

## Installation

### Prerequisites

1. **Flutter SDK** (version 3.0.0 or higher)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH

2. **Android Studio** (for Android development)
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install Android SDK and emulator

3. **VS Code** (recommended IDE)
   - Install Flutter and Dart extensions

### Setup Steps

1. Clone or download this project

2. Navigate to the project directory:
   ```bash
   cd Nutritrack
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

   Or select an emulator/device in VS Code and press F5

## Usage Guide

### First Time Setup

1. **Launch the app** - You'll see the login screen
2. **Skip login** - For MVP, tap "Skip to setup profile"
3. **Fill your profile**:
   - Enter your name, age, gender
   - Enter height (cm) and weight (kg)
   - Select activity level
   - Choose your goal (lose/maintain/gain weight)
4. **Save profile** - Tap "Save Profile" to calculate your targets

### Daily Usage

1. **Add Food**:
   - Tap "Add Food" on home screen
   - Search or browse by category
   - Select a food item
   - Enter weight in grams
   - Choose meal type (breakfast/lunch/dinner/snacks)
   - Tap "Add to Today's Meals"

2. **View Progress**:
   - Check home dashboard for daily progress
   - View calories consumed vs target
   - Track protein, carbs, and fat

3. **View History**:
   - Tap "History" button
   - Switch between daily and weekly views
   - Review past meals and totals

4. **Update Profile**:
   - Go to Settings → Edit Profile
   - Update your information
   - Recalculate targets as needed

## Future Enhancements (Semester 5)

- **Firebase Integration**:
  - Cloud authentication
  - Data sync across devices
  - Cloud backup

- **IoT Integration**:
  - ESP32 Bluetooth connection
  - Automatic weight measurement
  - Real-time data from load cell

- **AI Features**:
  - Food image recognition
  - Smart meal suggestions
  - Personalized diet recommendations

- **Additional Features**:
  - Water tracking
  - Exercise logging
  - Weight trend analysis
  - Social sharing
  - Barcode scanning

## Nutritional Calculations

### BMR Calculation (Mifflin-St Jeor Equation)

**For Men:**
```
BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age + 5
```

**For Women:**
```
BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age - 161
```

### TDEE Calculation

```
TDEE = BMR × ActivityMultiplier
```

Activity multipliers:
- Sedentary: 1.2
- Light exercise: 1.375
- Moderate exercise: 1.55
- Active: 1.725
- Very active: 1.9

### Calorie Targets

- **Lose weight**: TDEE - 500 kcal
- **Maintain weight**: TDEE
- **Gain weight**: TDEE + 500 kcal

### Macro Distribution

- Protein: 30% of calories (4 kcal/g)
- Carbs: 50% of calories (4 kcal/g)
- Fat: 20% of calories (9 kcal/g)

## Data Storage

All data is stored locally on the device using SharedPreferences:
- User profile information
- Meal entries with timestamps
- Calculated nutrition targets

No data is transmitted to external servers in the current version.

## Team Collaboration

This project is designed for a 3-member team. Here's how to collaborate:

### Using Git

1. Initialize Git repository:
   ```bash
   git init
   ```

2. Create a GitHub repository and push

3. Team members can work on different features:
   - Member 1: UI/UX and Screens
   - Member 2: State Management and Data
   - Member 3: Database and Calculations

4. Use branches for features:
   ```bash
   git checkout -b feature/profile-screen
   ```

5. Merge changes regularly

### Suggested Task Division

- **Member 1**: UI screens (login, home, profile)
- **Member 2**: Food database and search
- **Member 3**: History, settings, and state management

## Troubleshooting

### Flutter commands not recognized
- Ensure Flutter SDK is installed and added to PATH
- Restart terminal after installation

### App crashes on launch
- Run `flutter clean` then `flutter pub get`
- Check if all dependencies are installed

### Emulator not showing
- Open Android Studio
- Create an AVD (Android Virtual Device)
- Start emulator before running `flutter run`

### Data not persisting
- Check if SharedPreferences is working
- Ensure app has storage permissions

## License

This project is for educational purposes for Semester 4 project.

## Credits

Built by:
- Semester 4 Project Team
- Flutter Framework
- Provider State Management

## Support

For issues or questions:
- Check Flutter documentation: [flutter.dev/docs](https://flutter.dev/docs)
- Review the code comments
- Test on different devices/emulators

---

**Version**: 1.0.0  
**Last Updated**: 2026-09-28  
**Status**: Complete MVP for Semester 4
