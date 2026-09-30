# Quick Start Guide - NutriTrack

## 🚀 For Your Team

This guide will help you get started with the NutriTrack app quickly.

## Prerequisites Check

Before starting, ensure you have:

- [ ] Flutter SDK installed (flutter.dev)
- [ ] Android Studio installed (for Android emulator)
- [ ] VS Code with Flutter extension
- [ ] Git installed (for team collaboration)

## 5-Minute Setup

### 1. Install Dependencies

Open terminal in the Nutritrack folder and run:

```bash
flutter pub get
```

### 2. Run the App

```bash
flutter run
```

Or in VS Code:
- Press F5
- Select your emulator/device

### 3. First Run

1. You'll see the login screen
2. Tap "Skip to setup profile"
3. Fill in your details:
   - Name: Your name
   - Age: Your age
   - Gender: Select
   - Height: e.g., 175
   - Weight: e.g., 70
   - Activity Level: Moderate
   - Goal: Maintain Weight
4. Tap "Save Profile"

### 4. Add Your First Meal

1. Tap "Add Food"
2. Search for "Rice"
3. Tap on Rice
4. Enter weight: 150
5. Select "Lunch"
6. Tap "Add to Today's Meals"

### 5. Explore

- Check your home dashboard
- View history
- Explore settings

## Team Collaboration

### Setting Up Git

```bash
# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - NutriTrack MVP"

# Create GitHub repository and add remote
git remote add origin YOUR_GITHUB_REPO_URL

# Push
git push -u origin main
```

### Team Workflow

**Member 1 - UI/UX:**
- Works on: lib/screens/
- Focus: login.dart, home.dart, profile.dart

**Member 2 - Data & Logic:**
- Works on: lib/models/, lib/providers/
- Focus: food database, state management

**Member 3 - Features:**
- Works on: lib/screens/history.dart, settings.dart
- Focus: history, reports, settings

### Branch Strategy

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Work on your feature
# ... make changes ...

# Commit
git add .
git commit -m "Add your feature"

# Push branch
git push origin feature/your-feature-name

# Create pull request on GitHub
```

## Key Files to Know

### Configuration
- `pubspec.yaml` - Dependencies and app config

### Main Entry
- `lib/main.dart` - App initialization

### Models (Data Structure)
- `lib/models/user.dart` - User profile
- `lib/models/food.dart` - Food item
- `lib/models/meal_entry.dart` - Meal entry

### Providers (State Management)
- `lib/providers/user_provider.dart` - User data
- `lib/providers/meal_provider.dart` - Meal data

### Screens (UI)
- `lib/screens/login.dart` - Login
- `lib/screens/home.dart` - Dashboard
- `lib/screens/profile.dart` - Profile setup
- `lib/screens/add_food.dart` - Food search
- `lib/screens/food_details.dart` - Add food
- `lib/screens/history.dart` - History & reports
- `lib/screens/settings.dart` - Settings

### Data
- `lib/data/food.dart` - 75+ foods database

### Widgets
- `lib/widgets/calorie_card.dart` - Calorie display
- `lib/widgets/progress_bar.dart` - Progress bars

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Clean build
flutter clean

# Analyze code
flutter analyze

# Format code
flutter format .

# Build APK
flutter build apk
```

## Testing the App

### Manual Testing Checklist

- [ ] Login screen appears
- [ ] Profile can be created and saved
- [ ] Calorie targets calculate correctly
- [ ] Food search works
- [ ] Categories filter correctly
- [ ] Food can be added with weight
- [ ] Meal appears in home dashboard
- [ ] Progress bars update
- [ ] History shows daily entries
- [ ] Weekly view displays chart
- [ ] Settings clear data correctly
- [ ] Data persists after app restart

### Test Data

**Test Profile:**
- Name: Test User
- Age: 25
- Gender: Male
- Height: 175 cm
- Weight: 70 kg
- Activity: Moderate
- Goal: Maintain

**Expected Results:**
- BMR: ~1690 kcal
- TDEE: ~2620 kcal
- Daily Target: ~2620 kcal
- Protein: ~196 g
- Carbs: ~327 g
- Fat: ~58 g

## Troubleshooting

### "flutter command not found"
- Add Flutter to your system PATH
- Restart terminal

### "No devices found"
- Start Android Studio
- Create and run an emulator
- Or connect a physical phone

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

### Data not saving
- Check if app has storage permissions
- Try clearing app data and restarting

## Next Steps for Your Team

1. **Week 1**: Setup and familiarization
   - Everyone runs the app
   - Team sets up Git
   - Review code structure

2. **Week 2**: Feature assignment
   - Divide screens among team
   - Create feature branches
   - Start development

3. **Week 3**: Integration
   - Merge feature branches
   - Test complete flow
   - Fix bugs

4. **Week 4**: Polish
   - Improve UI/UX
   - Add more foods
   - Prepare presentation

## Presentation Tips

For your project presentation:

1. **Demo Flow:**
   - Show login → profile setup
   - Add foods → show dashboard
   - Show history/reports
   - Explain calculations

2. **Key Points:**
   - BMR/TDEE calculations
   - State management with Provider
   - Local data persistence
   - 75+ food database
   - Weekly reports with charts

3. **Future Scope:**
   - Firebase integration
   - ESP32/Bluetooth
   - AI food recognition

## Need Help?

- Flutter Docs: flutter.dev/docs
- Provider Package: pub.dev/packages/provider
- Team: Communicate regularly
- Test: Test on multiple devices

---

**Good luck with your project! 🎉**
