import SwiftUI

struct MathProblem {
    let question: String
    let correctAnswer: Int
    let options: [Int]
    let difficulty: Int
}

// User Profile with persistent storage
class UserProfile: ObservableObject {
    @Published var gamesPlayed: Int = 0
    @Published var bestScore: Int = 0
    @Published var bestStreak: Int = 0
    @Published var totalCorrectAnswers: Int = 0
    @Published var totalProblems: Int = 0
    @Published var unlockedAchievements: Set<String> = Set()
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadData()
    }
    
    private func loadData() {
        gamesPlayed = userDefaults.integer(forKey: "gamesPlayed")
        bestScore = userDefaults.integer(forKey: "bestScore")
        bestStreak = userDefaults.integer(forKey: "bestStreak")
        totalCorrectAnswers = userDefaults.integer(forKey: "totalCorrectAnswers")
        totalProblems = userDefaults.integer(forKey: "totalProblems")
        
        if let achievementsData = userDefaults.data(forKey: "unlockedAchievements"),
           let achievements = try? JSONDecoder().decode(Set<String>.self, from: achievementsData) {
            unlockedAchievements = achievements
        }
    }
    
    func saveData() {
        userDefaults.set(gamesPlayed, forKey: "gamesPlayed")
        userDefaults.set(bestScore, forKey: "bestScore")
        userDefaults.set(bestStreak, forKey: "bestStreak")
        userDefaults.set(totalCorrectAnswers, forKey: "totalCorrectAnswers")
        userDefaults.set(totalProblems, forKey: "totalProblems")
        
        if let achievementsData = try? JSONEncoder().encode(unlockedAchievements) {
            userDefaults.set(achievementsData, forKey: "unlockedAchievements")
        }
    }
    
    func updateAfterGame(score: Int, streak: Int, correct: Int, total: Int, achievements: [String]) {
        gamesPlayed += 1
        bestScore = max(bestScore, score)
        bestStreak = max(bestStreak, streak)
        totalCorrectAnswers += correct
        totalProblems += total
        
        for achievement in achievements {
            unlockedAchievements.insert(achievement)
        }
        
        saveData()
    }
    
    var accuracy: Double {
        return totalProblems > 0 ? Double(totalCorrectAnswers) / Double(totalProblems) * 100 : 0
    }
}

struct ParticleView: View {
    @State private var animate = false
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .scaleEffect(animate ? 0 : 1)
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    animate = true
                }
            }
    }
}

struct FloatingParticles: View {
    let color: Color
    @State private var positions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<15, id: \.self) { _ in
                ParticleView(color: color)
                    .position(positions.randomElement() ?? CGPoint(x: 50, y: 50))
            }
        }
        .onAppear {
            generatePositions()
        }
    }
    
    private func generatePositions() {
        positions = (0..<15).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...300),
                y: CGFloat.random(in: 0...600)
            )
        }
    }
}

class MathGameEngine: ObservableObject {
    @Published var currentProblem: MathProblem
    @Published var score = 0
    @Published var level = 1
    @Published var streak = 0
    @Published var timeRemaining = 30.0
    @Published var isGameActive = false
    @Published var totalProblems = 0
    @Published var correctAnswers = 0
    @Published var gameOver = false
    @Published var showResult = false
    @Published var lastAnswerCorrect: Bool?
    @Published var comboMultiplier = 1
    @Published var showCombo = false
    @Published var perfectLevel = false
    @Published var achievements: [String] = []
    @Published var showAchievement: String? = nil
    @Published var bestStreak = 0
    @Published var fastAnswerBonus = false
    @Published var lastAnswerTime: TimeInterval = 0
    
    private var timer: Timer?
    private var questionStartTime: Date?
    
    init() {
        self.currentProblem = MathGameEngine.generateProblem(for: 1)
    }
    
    static func generateProblem(for level: Int) -> MathProblem {
        let difficulty = min(level, 10)
        
        switch difficulty {
        case 1...3:
            return generateAdditionProblem(difficulty: difficulty)
        case 4...6:
            return generateSubtractionProblem(difficulty: difficulty)
        case 7...8:
            return generateMultiplicationProblem(difficulty: difficulty)
        default:
            return generateMixedProblem(difficulty: difficulty)
        }
    }
    
    static func generateAdditionProblem(difficulty: Int) -> MathProblem {
        let maxNum = difficulty == 1 ? 10 : (difficulty == 2 ? 25 : 50)
        let a = Int.random(in: 1...maxNum)
        let b = Int.random(in: 1...maxNum)
        let correct = a + b
        
        return MathProblem(
            question: "\(a) + \(b) = ?",
            correctAnswer: correct,
            options: generateOptions(correct: correct, range: 10),
            difficulty: difficulty
        )
    }
    
    static func generateSubtractionProblem(difficulty: Int) -> MathProblem {
        let maxNum = difficulty == 4 ? 20 : (difficulty == 5 ? 50 : 100)
        let a = Int.random(in: 10...maxNum)
        let b = Int.random(in: 1...(a-1))
        let correct = a - b
        
        return MathProblem(
            question: "\(a) - \(b) = ?",
            correctAnswer: correct,
            options: generateOptions(correct: correct, range: 8),
            difficulty: difficulty
        )
    }
    
    static func generateMultiplicationProblem(difficulty: Int) -> MathProblem {
        let maxA = difficulty == 7 ? 10 : 12
        let maxB = difficulty == 7 ? 10 : 15
        let a = Int.random(in: 2...maxA)
        let b = Int.random(in: 2...maxB)
        let correct = a * b
        
        return MathProblem(
            question: "\(a) × \(b) = ?",
            correctAnswer: correct,
            options: generateOptions(correct: correct, range: 20),
            difficulty: difficulty
        )
    }
    
    static func generateMixedProblem(difficulty: Int) -> MathProblem {
        let operations = ["+", "-", "×"]
        let operation = operations.randomElement()!
        
        switch operation {
        case "+":
            return generateAdditionProblem(difficulty: 3)
        case "-":
            return generateSubtractionProblem(difficulty: 6)
        default:
            return generateMultiplicationProblem(difficulty: 8)
        }
    }
    
    static func generateOptions(correct: Int, range: Int) -> [Int] {
        var options = [correct]
        
        while options.count < 4 {
            let offset = Int.random(in: 1...range)
            let wrongAnswer = Bool.random() ? correct + offset : max(0, correct - offset)
            
            if !options.contains(wrongAnswer) && wrongAnswer != correct {
                options.append(wrongAnswer)
            }
        }
        
        return options.shuffled()
    }
    
    func startGame() {
        score = 0
        level = 1
        streak = 0
        timeRemaining = 30.0
        totalProblems = 0
        correctAnswers = 0
        gameOver = false
        showResult = false
        lastAnswerCorrect = nil
        comboMultiplier = 1
        showCombo = false
        perfectLevel = false
        fastAnswerBonus = false
        showAchievement = nil
        lastAnswerTime = 0
        isGameActive = true
        
        generateNewProblem()
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
            } else {
                self.endGame()
            }
        }
    }
    
    func endGame() {
        timer?.invalidate()
        isGameActive = false
        gameOver = true
    }
    
    func answerSelected(_ answer: Int) {
        guard isGameActive else { return }
        
        totalProblems += 1
        let answerTime = Date().timeIntervalSince(questionStartTime ?? Date())
        lastAnswerTime = answerTime
        
        if answer == currentProblem.correctAnswer {
            correctAnswers += 1
            streak += 1
            lastAnswerCorrect = true
            
            // Fast answer bonus (under 2 seconds)
            fastAnswerBonus = answerTime < 2.0
            
            // Combo system
            if streak >= 3 {
                comboMultiplier = min(streak / 3, 5)
                showCombo = true
            }
            
            // Scoring system with enhanced bonuses
            let basePoints = currentProblem.difficulty * 10
            let streakBonus = min(streak * 5, 100)
            let timeBonus = Int(max(0, (5.0 - answerTime) * 10))
            let comboBonus = (comboMultiplier - 1) * 25
            let fastBonus = fastAnswerBonus ? 50 : 0
            
            let totalPoints = (basePoints + streakBonus + timeBonus + comboBonus + fastBonus)
            score += totalPoints
            
            // Achievement system
            checkAchievements()
            
            // Update best streak
            if streak > bestStreak {
                bestStreak = streak
            }
            
            // Level up every 5 correct answers
            if correctAnswers % 5 == 0 {
                level += 1
                timeRemaining = min(timeRemaining + 15, 60) // More generous time bonus
                
                // Check if perfect level (no wrong answers in this level)
                let levelStart = ((correctAnswers - 5) / 5) * 5
                let wrongInLevel = (totalProblems - levelStart) - 5
                perfectLevel = wrongInLevel == 0
                
                if perfectLevel {
                    score += 200 // Perfect level bonus
                    addAchievement("Perfect Level!")
                }
            }
            
            // Enhanced haptic feedback
            let style: UIImpactFeedbackGenerator.FeedbackStyle = fastAnswerBonus ? .rigid : .light
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
            
        } else {
            streak = 0
            comboMultiplier = 1
            showCombo = false
            lastAnswerCorrect = false
            perfectLevel = false
            fastAnswerBonus = false
            
            // Progressive penalty based on level
            let penalty = min(Double(level), 5.0)
            timeRemaining = max(timeRemaining - penalty, 0)
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        
        showResult = true
        
        // Generate next problem after shorter delay to prevent stacking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.showResult = false
            self.lastAnswerCorrect = nil
            self.showCombo = false
            self.perfectLevel = false
            self.fastAnswerBonus = false
            self.generateNewProblem()
        }
    }
    
    private func checkAchievements() {
        if streak == 5 && !achievements.contains("Hot Streak!") {
            addAchievement("Hot Streak!")
        }
        if streak == 10 && !achievements.contains("On Fire!") {
            addAchievement("On Fire!")
        }
        if streak == 20 && !achievements.contains("Unstoppable!") {
            addAchievement("Unstoppable!")
        }
        if score >= 1000 && !achievements.contains("Math Master") {
            addAchievement("Math Master")
        }
        if score >= 2500 && !achievements.contains("Calculation King") {
            addAchievement("Calculation King")
        }
        if level >= 10 && !achievements.contains("Level Champion") {
            addAchievement("Level Champion")
        }
        if fastAnswerBonus && streak >= 3 && !achievements.contains("Speed Demon") {
            addAchievement("Speed Demon")
        }
    }
    
    private func addAchievement(_ achievement: String) {
        achievements.append(achievement)
        showAchievement = achievement
        
        // Hide achievement after 1 second to prevent stacking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAchievement = nil
        }
    }
    
    func generateNewProblem() {
        currentProblem = MathGameEngine.generateProblem(for: level)
        questionStartTime = Date()
    }
    
    func resetGame() {
        timer?.invalidate()
        score = 0
        level = 1
        streak = 0
        timeRemaining = 30.0
        totalProblems = 0
        correctAnswers = 0
        gameOver = false
        showResult = false
        lastAnswerCorrect = nil
        comboMultiplier = 1
        showCombo = false
        perfectLevel = false
        fastAnswerBonus = false
        showAchievement = nil
        lastAnswerTime = 0
        isGameActive = false
        generateNewProblem()
    }
    
    var accuracy: Double {
        return totalProblems > 0 ? Double(correctAnswers) / Double(totalProblems) * 100 : 0
    }
    
    var levelProgress: Double {
        let problemsInLevel = correctAnswers % 5
        return Double(problemsInLevel) / 5.0
    }
}

struct ContentView: View {
    @StateObject private var gameEngine = MathGameEngine()
    @StateObject private var userProfile = UserProfile()
    
    var difficultyText: String {
        switch gameEngine.level {
        case 1...3: return "Addition"
        case 4...6: return "Subtraction"
        case 7...8: return "Multiplication"
        default: return "Mixed Operations"
        }
    }
    
    var levelColor: Color {
        switch gameEngine.level {
        case 1...3: return .green
        case 4...6: return .blue
        case 7...8: return .purple
        default: return .orange
        }
    }
    
    var body: some View {
        ZStack {
            // Enhanced dynamic background with particle effects
            ZStack {
                LinearGradient(
                    colors: [
                        levelColor.opacity(0.2),
                        levelColor.opacity(0.8),
                        levelColor.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: gameEngine.level)
                
                // Animated background particles
                if gameEngine.isGameActive {
                    FloatingParticles(color: levelColor.opacity(0.3))
                        .ignoresSafeArea()
                }
            }
            
            VStack(spacing: 20) {
                
                if !gameEngine.isGameActive && !gameEngine.gameOver {
                    // Welcome Screen
                    welcomeScreen
                } else if gameEngine.gameOver {
                    // Game Over Screen
                    gameOverScreen
                } else {
                    // Game Playing Screen
                    gamePlayingScreen
                }
            }
            .padding()
            
            // Enhanced overlay system
            ZStack {
                // Result feedback overlay
                if gameEngine.showResult {
                    resultFeedback
                }
                
                // Combo multiplier overlay
                if gameEngine.showCombo {
                    comboOverlay
                }
                
                // Perfect level overlay
                if gameEngine.perfectLevel {
                    perfectLevelOverlay
                }
                
                // Fast answer bonus overlay
                if gameEngine.fastAnswerBonus {
                    fastAnswerOverlay
                }
                
                // Achievement overlay
                if let achievement = gameEngine.showAchievement {
                    achievementOverlay(achievement)
                }
            }
        }
        .onChange(of: gameEngine.gameOver) { _, isGameOver in
            if isGameOver {
                // Update user profile when game ends
                userProfile.updateAfterGame(
                    score: gameEngine.score,
                    streak: gameEngine.streak,
                    correct: gameEngine.correctAnswers,
                    total: gameEngine.totalProblems,
                    achievements: gameEngine.achievements
                )
                
                // Sync best streak back to game engine for display
                gameEngine.bestStreak = userProfile.bestStreak
            }
        }
    }
    
    var welcomeScreen: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Simple, clean title
            VStack(spacing: 15) {
                Text("⚡ MATH RUSH")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                Text("Quick. Simple. Addictive.")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Profile stats
            if userProfile.gamesPlayed > 0 {
                VStack(spacing: 15) {
                    HStack(spacing: 30) {
                        VStack(spacing: 5) {
                            Text("\(userProfile.bestScore)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.gold)
                            Text("BEST SCORE")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1)
                        }
                        
                        VStack(spacing: 5) {
                            Text("\(userProfile.bestStreak)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.cyan)
                            Text("BEST STREAK")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1)
                        }
                        
                        VStack(spacing: 5) {
                            Text("\(Int(userProfile.accuracy))%")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.green)
                            Text("ACCURACY")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1)
                        }
                    }
                    
                    Text("Games Played: \(userProfile.gamesPlayed)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.black.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
            
            // Big, simple start button
            Button(action: {
                // Initialize bestStreak from profile on first game
                if userProfile.gamesPlayed == 0 {
                    gameEngine.bestStreak = userProfile.bestStreak
                }
                gameEngine.startGame()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.title2)
                    
                    Text("START")
                        .font(.title)
                        .fontWeight(.black)
                        .tracking(2)
                }
                .foregroundColor(.black)
                .frame(width: 200, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                )
            }
            .scaleEffect(gameEngine.isGameActive ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: gameEngine.isGameActive)
            
            Spacer()
            
            // Simple credit
            Text("Made by Hasan Keçeci")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 20)
        }
    }
    

    
    var gamePlayingScreen: some View {
        VStack(spacing: 30) {
            // Clean header with essential info only
            HStack {
                // Score
                VStack(spacing: 4) {
                    Text("\(gameEngine.score)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("SCORE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
                
                Spacer()
                
                // Timer - simple and clean
                VStack(spacing: 4) {
                    Text("\(Int(gameEngine.timeRemaining))")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(gameEngine.timeRemaining > 10 ? .white : .red)
                    Text("TIME")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
                
                Spacer()
                
                // Level and streak
                VStack(spacing: 4) {
                    Text("L\(gameEngine.level)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(levelColor)
                    if gameEngine.streak > 0 {
                        Text("🔥\(gameEngine.streak)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    } else {
                        Text("LEVEL")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(1)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // Simple timer bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(gameEngine.timeRemaining > 10 ? .white : .red)
                        .frame(width: geometry.size.width * (gameEngine.timeRemaining / 30.0), height: 4)
                        .cornerRadius(2)
                        .animation(.linear(duration: 0.1), value: gameEngine.timeRemaining)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Clean math problem - this is the focus
            VStack(spacing: 40) {
                // Just the equation - big and bold
                Text(gameEngine.currentProblem.question)
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                    .scaleEffect(gameEngine.showResult ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameEngine.showResult)
                
                // Clean answer grid - 2x2
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(Array(gameEngine.currentProblem.options.enumerated()), id: \.element) { index, option in
                        Button(action: {
                            gameEngine.answerSelected(option)
                        }) {
                            Text("\(option)")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.white.opacity(0.4), lineWidth: 2)
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                        }
                        .disabled(gameEngine.showResult)
                        .scaleEffect(gameEngine.showResult ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: gameEngine.showResult)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var gameOverScreen: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Simple game over message
            VStack(spacing: 15) {
                Text("TIME'S UP!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                Text(getPerformanceMessage())
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color.gold)
            }
            
            Spacer()
            
            // Big score display
            VStack(spacing: 15) {
                Text("FINAL SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
                
                Text("\(gameEngine.score)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10)
            }
            
            // Clean stats row
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("\(gameEngine.level)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(levelColor)
                    Text("LEVEL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
                
                VStack(spacing: 8) {
                    Text("\(gameEngine.correctAnswers)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                    Text("CORRECT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
                
                VStack(spacing: 8) {
                    Text("\(Int(gameEngine.accuracy))%")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.cyan)
                    Text("ACCURACY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
            }
            
            Spacer()
            
            // Simple buttons
            VStack(spacing: 15) {
                Button(action: gameEngine.startGame) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                        
                        Text("PLAY AGAIN")
                            .font(.title3)
                            .fontWeight(.black)
                            .tracking(1)
                    }
                    .foregroundColor(.black)
                    .frame(width: 200, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    )
                }
                
                Button(action: gameEngine.resetGame) {
                    Text("MENU")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                }
            }
            
            Spacer()
        }
    }
    

    
    private func getPerformanceMessage() -> String {
        let accuracy = gameEngine.accuracy
        
        if accuracy >= 90 {
            return "🌟 Outstanding Performance!"
        } else if accuracy >= 75 {
            return "🎉 Great Job!"
        } else if accuracy >= 60 {
            return "👍 Good Effort!"
        } else {
            return "💪 Keep Practicing!"
        }
    }
    
    var resultFeedback: some View {
        VStack(spacing: 20) {
            if let isCorrect = gameEngine.lastAnswerCorrect {
                VStack(spacing: 15) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isCorrect ? .green : .red)
                        .background(
                            Circle()
                                .fill(.black)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 20)
                        )
                    
                    Text(isCorrect ? "CORRECT!" : "WRONG!")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    if isCorrect {
                        Text("+\(calculateLastScore())")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.black.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(isCorrect ? .green : .red, lineWidth: 3)
                        )
                        .shadow(radius: 30)
                )
                .scaleEffect(gameEngine.showResult ? 1.0 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.showResult)
            }
        }
        .opacity(gameEngine.showResult ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: gameEngine.showResult)
    }
    
    var comboOverlay: some View {
        VStack(spacing: 10) {
            Text("🔥 COMBO x\(gameEngine.comboMultiplier)")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(.orange)
                .tracking(2)
            
            Text("STREAK: \(gameEngine.streak)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .tracking(1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.orange, lineWidth: 3)
                )
                .shadow(radius: 30)
        )
        .scaleEffect(gameEngine.showCombo ? 1.0 : 0.5)
        .opacity(gameEngine.showCombo ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.showCombo)
    }
    
    var perfectLevelOverlay: some View {
        VStack(spacing: 10) {
            Text("⭐ PERFECT! ⭐")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(.yellow)
                .tracking(2)
            
            Text("+200 BONUS")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .tracking(1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.yellow, lineWidth: 3)
                )
                .shadow(radius: 30)
        )
        .scaleEffect(gameEngine.perfectLevel ? 1.0 : 0.5)
        .opacity(gameEngine.perfectLevel ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.perfectLevel)
    }
    
    var fastAnswerOverlay: some View {
        VStack(spacing: 10) {
            Text("⚡ FAST! ⚡")
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(.cyan)
                .tracking(2)
            
            Text("+50 SPEED")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .tracking(1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.cyan, lineWidth: 3)
                )
                .shadow(radius: 30)
        )
        .scaleEffect(gameEngine.fastAnswerBonus ? 1.0 : 0.5)
        .opacity(gameEngine.fastAnswerBonus ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.fastAnswerBonus)
    }
    
    func achievementOverlay(_ achievement: String) -> some View {
        VStack(spacing: 10) {
            Text("🏆 ACHIEVEMENT!")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(Color.gold)
                .tracking(2)
            
            Text(achievement)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .tracking(1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gold, lineWidth: 3)
                )
                .shadow(radius: 30)
        )
        .scaleEffect(gameEngine.showAchievement != nil ? 1.0 : 0.5)
        .opacity(gameEngine.showAchievement != nil ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.showAchievement)
    }
    
    private func calculateLastScore() -> Int {
        let basePoints = gameEngine.currentProblem.difficulty * 10
        let streakBonus = min(gameEngine.streak * 5, 100)
        let timeBonus = Int(max(0, (5.0 - gameEngine.lastAnswerTime) * 10))
        let comboBonus = (gameEngine.comboMultiplier - 1) * 25
        let fastBonus = gameEngine.fastAnswerBonus ? 50 : 0
        return basePoints + streakBonus + timeBonus + comboBonus + fastBonus
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
} 