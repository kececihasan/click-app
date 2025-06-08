# 🔢 Math Speed Clicker Made by Hasan Keçeci

An educational iOS game that challenges users to solve math problems as quickly as possible! Built with SwiftUI, this app combines learning with competitive gameplay through progressive difficulty levels, scoring systems, and real-time feedback.

## ✨ Features

### 🎯 **Progressive Difficulty System**
- **Levels 1-3**: Addition problems (1-50 range)
- **Levels 4-6**: Subtraction problems (1-100 range)  
- **Levels 7-8**: Multiplication problems (2x2 to 12x15)
- **Level 9+**: Mixed operations combining all math types

### 🏆 **Advanced Scoring & Progression**
- **Smart Scoring**: Base points + streak bonus + time bonus
- **Level Progression**: Advance every 5 correct answers
- **Streak Tracking**: Consecutive correct answers with bonus points
- **Time Pressure**: 30-second rounds with penalties for wrong answers
- **Level-Up Rewards**: Extra time added when reaching new levels

### 🎨 **Dynamic User Experience**
- **Color-Coded Levels**: Different themes for each difficulty level
  - 🟢 Green: Addition (Levels 1-3)
  - 🔵 Blue: Subtraction (Levels 4-6)  
  - 🟣 Purple: Multiplication (Levels 7-8)
  - 🟠 Orange: Mixed Operations (Level 9+)
- **Real-Time Feedback**: Instant visual and haptic responses
- **Progress Indicators**: Timer bars and level progression tracking
- **Statistics**: Live accuracy percentages and performance metrics

### 📱 **Game Mechanics**
- **Multiple Choice**: 4 answer options per problem
- **Time Management**: Visual countdown with color-coded urgency
- **Haptic Feedback**: Success and error vibrations
- **Problem Generation**: Randomized questions with smart wrong-answer options
- **Performance Tracking**: Total problems, correct answers, and accuracy

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+**
- **iOS 17.0+** deployment target
- **macOS** for development

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/click-app.git
   cd click-app/TapCounter
   ```

2. **Open in Xcode:**
   ```bash
   open TapCounter.xcodeproj
   ```

3. **Build and Run:**
   - Select your target device/simulator
   - Press `Cmd + R` or click the ▶️ button
   - The app will launch with the welcome screen

### 🔧 **Build from Terminal:**
```bash
# Clean build
xcodebuild -project TapCounter.xcodeproj -scheme TapCounter clean

# Build for simulator
xcodebuild -project TapCounter.xcodeproj -scheme TapCounter -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build

# Run in simulator
xcrun simctl boot "iPhone 15"
xcrun simctl install booted path/to/TapCounter.app
xcrun simctl launch booted com.example.TapCounter
```

## 🎮 How to Play

### **Welcome Screen**
- Review the difficulty levels and their math operations
- Tap **"Start Game"** to begin your challenge

### **During Gameplay**
1. **Read the Math Problem**: Displayed prominently at the center
2. **Select the Correct Answer**: Choose from 4 multiple-choice options
3. **Beat the Clock**: Solve as many problems as possible in 30 seconds
4. **Watch Your Progress**: Monitor score, streak, and level advancement
5. **Level Up**: Every 5 correct answers advances you to the next level

### **Scoring System**
- **Base Points**: Difficulty level × 10 points
- **Streak Bonus**: Up to 50 additional points for consecutive correct answers
- **Time Bonus**: Extra points based on remaining time
- **Penalties**: -2 seconds for incorrect answers

### **Game Over**
- View your final statistics and achievements
- Choose **"Play Again"** for another round
- Return to **"Main Menu"** to review difficulty levels

## 📁 Project Structure

```
TapCounter/
├── TapCounter.xcodeproj/          # Xcode project file
├── TapCounter/                    # Source code directory
│   ├── TapCounterApp.swift       # App entry point (MathSpeedClickerApp)
│   ├── ContentView.swift         # Main game view and logic
│   ├── Assets.xcassets/          # App icons and colors
│   └── Preview Content/          # SwiftUI preview assets
├── README.md                     # Project documentation
└── LICENSE                       # MIT License
```

## 🏗️ Architecture

### **MathGameEngine**
- **ObservableObject** managing game state
- **Problem Generation**: Dynamic math problem creation
- **Timer Management**: 30-second countdown with precision
- **Scoring Logic**: Complex scoring algorithm with bonuses
- **Level Progression**: Automatic difficulty advancement

### **ContentView Components**
- **Welcome Screen**: Game introduction and level overview
- **Game Playing Screen**: Active gameplay interface
- **Game Over Screen**: Results and replay options
- **Result Feedback**: Real-time answer validation

### **Key Features Implementation**
- **SwiftUI Animations**: Smooth transitions and visual feedback
- **Color Theming**: Dynamic backgrounds based on difficulty
- **Responsive Design**: Optimized for various iPhone screen sizes
- **Accessibility**: VoiceOver support and clear visual hierarchy

## 🎯 Educational Benefits

- **Mental Math Skills**: Rapid calculation practice
- **Time Management**: Working under pressure
- **Progressive Learning**: Gradual difficulty increase
- **Performance Tracking**: Self-assessment through statistics
- **Engagement**: Gamification makes learning fun

## 🔮 Future Enhancements

- [ ] **Division Problems**: Add Level 10+ with division operations
- [ ] **Custom Difficulty**: User-selectable number ranges
- [ ] **Achievement System**: Unlock badges and rewards
- [ ] **Leaderboards**: Local and global high scores
- [ ] **Sound Effects**: Audio feedback for actions
- [ ] **Daily Challenges**: Special problem sets
- [ ] **Progress Persistence**: Save user statistics
- [ ] **Accessibility**: Enhanced VoiceOver support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with **SwiftUI** and **Combine** frameworks
- Inspired by educational gaming principles
- Designed for learners of all ages
- Thanks to the Swift community for resources and support

---

**Made with ❤️ for educational gaming and iOS development**

*Transform learning into an engaging, competitive experience!* 🚀📚 