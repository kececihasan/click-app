import SwiftUI

struct MathProblem {
    let question: String
    let correctAnswer: Int
    let options: [Int]
    let difficulty: Int
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
        
        // Generate next problem after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + (fastAnswerBonus ? 0.5 : 0.8)) {
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
        
        // Hide achievement after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
    }
    
    var welcomeScreen: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Enhanced title with animation
                VStack(spacing: 10) {
                    Text("🔢 Math Speed Clicker")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 10)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
                    
                    Text("Made by Hasan Keçeci")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(radius: 2)
                }
                
                // Enhanced description
                VStack(spacing: 15) {
                    Text("🚀 Challenge Your Mind!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow, radius: 5)
                    
                    Text("Solve math problems as fast as you can!\nEarn combos, unlock achievements, and climb the levels!")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(radius: 2)
                        .padding(.horizontal)
                }
                
                // Enhanced level information
                VStack(spacing: 20) {
                    Text("🎯 Game Modes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 15) {
                        levelInfoRow(icon: "plus.circle.fill", color: .green, title: "Levels 1-3: Addition", subtitle: "Simple math warm-up")
                        levelInfoRow(icon: "minus.circle.fill", color: .blue, title: "Levels 4-6: Subtraction", subtitle: "Mind-bending challenges")
                        levelInfoRow(icon: "multiply.circle.fill", color: .purple, title: "Levels 7-8: Multiplication", subtitle: "Speed calculations")
                        levelInfoRow(icon: "function", color: .orange, title: "Level 9+: Mixed Operations", subtitle: "Ultimate math mastery")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Features showcase
                VStack(spacing: 15) {
                    Text("✨ Special Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        featureCard(icon: "flame.fill", title: "Combos", color: .orange)
                        featureCard(icon: "bolt.fill", title: "Speed Bonus", color: .cyan)
                        featureCard(icon: "star.fill", title: "Achievements", color: .yellow)
                    }
                }
                
                // Enhanced start button
                Button(action: gameEngine.startGame) {
                    HStack(spacing: 15) {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                        
                        Text("Start Your Journey")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 280, height: 70)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(35)
                    .shadow(color: .purple, radius: 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(.white.opacity(0.3), lineWidth: 2)
                    )
                }
                .scaleEffect(gameEngine.isGameActive ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: gameEngine.isGameActive)
                
                // Best streak display
                if gameEngine.bestStreak > 0 {
                    VStack {
                        Text("🏆 Your Best Streak")
                            .font(.headline)
                            .foregroundColor(Color.gold)
                        
                        Text("\(gameEngine.bestStreak) correct answers")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gold, lineWidth: 2)
                            )
                    )
                }
            }
            .padding()
        }
    }
    
    private func levelInfoRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
    
    private func featureCard(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .shadow(color: color, radius: 5)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
    
    var gamePlayingScreen: some View {
        VStack(spacing: 20) {
            // Enhanced header with advanced stats
            VStack(spacing: 15) {
                // Top row - Score and Level
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(gameEngine.score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        HStack {
                            Text("Level \(gameEngine.level)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.gold)
                        }
                        Text(difficultyText)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Middle row - Streak and Combo
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(gameEngine.streak)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Text("Streak")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if gameEngine.comboMultiplier > 1 {
                        VStack(alignment: .trailing, spacing: 5) {
                            HStack {
                                Text("x\(gameEngine.comboMultiplier)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.orange)
                            }
                            Text("Combo")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(radius: 10)
            
            // Enhanced timer section
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(gameEngine.timeRemaining > 10 ? .green : (gameEngine.timeRemaining > 5 ? .orange : .red))
                    
                    Text("Time: \(Int(gameEngine.timeRemaining))s")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Accuracy indicator
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.cyan)
                        Text("\(Int(gameEngine.accuracy))%")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                // Enhanced timer bar with glow effect
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.white.opacity(0.2))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: gameEngine.timeRemaining > 10 ? 
                                        [.green, .mint] : 
                                        (gameEngine.timeRemaining > 5 ? [.orange, .yellow] : [.red, .pink]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (gameEngine.timeRemaining / 30.0), height: 12)
                            .cornerRadius(6)
                            .shadow(
                                color: gameEngine.timeRemaining > 10 ? .green : 
                                      (gameEngine.timeRemaining > 5 ? .orange : .red),
                                radius: gameEngine.timeRemaining < 10 ? 8 : 4
                            )
                            .animation(.linear(duration: 0.1), value: gameEngine.timeRemaining)
                    }
                }
                .frame(height: 12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Enhanced level progress
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                    
                    Text("Progress to Level \(gameEngine.level + 1)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(gameEngine.correctAnswers % 5)/5")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.blue.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(.blue, lineWidth: 1)
                                )
                        )
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.white.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * gameEngine.levelProgress, height: 8)
                            .cornerRadius(4)
                            .shadow(color: .blue, radius: 4)
                            .animation(.easeInOut(duration: 0.3), value: gameEngine.levelProgress)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Enhanced math problem display
            VStack(spacing: 25) {
                // Problem question with enhanced styling
                VStack(spacing: 15) {
                    Text("🧮 Problem #\(gameEngine.totalProblems + 1)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(radius: 2)
                    
                    Text(gameEngine.currentProblem.question)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: levelColor, radius: 15)
                        .multilineTextAlignment(.center)
                        .scaleEffect(gameEngine.showResult ? 1.1 : 1.0)
                        .rotationEffect(.degrees(gameEngine.showResult ? (gameEngine.lastAnswerCorrect == true ? 5 : -5) : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.showResult)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(levelColor.opacity(0.5), lineWidth: 2)
                        )
                )
                .shadow(color: levelColor, radius: 10)
                
                // Enhanced answer options
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(Array(gameEngine.currentProblem.options.enumerated()), id: \.element) { index, option in
                        Button(action: {
                            gameEngine.answerSelected(option)
                        }) {
                            VStack(spacing: 8) {
                                Text("\(option)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                // Option letter (A, B, C, D)
                                Text(String(UnicodeScalar(65 + index)!))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(width: 140, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                levelColor.opacity(0.3),
                                                levelColor.opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white.opacity(0.4), lineWidth: 2)
                                    )
                            )
                            .shadow(color: levelColor, radius: gameEngine.showResult ? 0 : 8)
                            .overlay(
                                // Shimmer effect
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white.opacity(0.3), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .opacity(gameEngine.showResult ? 0 : 0.5)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: UUID())
                            )
                        }
                        .disabled(gameEngine.showResult)
                        .scaleEffect(gameEngine.showResult ? 0.9 : 1.0)
                        .rotationEffect(.degrees(gameEngine.showResult && option == gameEngine.currentProblem.correctAnswer ? 10 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameEngine.showResult)
                    }
                }
            }
            
            Spacer()
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(gameEngine.correctAnswers)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Correct")
                        .font(.caption)
                        .opacity(0.8)
                }
                
                VStack {
                    Text("\(gameEngine.totalProblems)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total")
                        .font(.caption)
                        .opacity(0.8)
                }
                
                VStack {
                    Text("\(Int(gameEngine.accuracy))%")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Accuracy")
                        .font(.caption)
                        .opacity(0.8)
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white.opacity(0.1))
            )
        }
    }
    
    var gameOverScreen: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Enhanced game over title
                VStack(spacing: 15) {
                    Text("🎯 Game Complete!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 10)
                    
                                            Text(getPerformanceMessage())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.gold)
                        .shadow(radius: 3)
                        .multilineTextAlignment(.center)
                }
                
                // Enhanced statistics panel
                VStack(spacing: 20) {
                    // Score highlight
                    VStack(spacing: 10) {
                        Text("🏆 Final Score")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(gameEngine.score)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow, radius: 10)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.yellow.opacity(0.5), lineWidth: 2)
                            )
                    )
                    .shadow(color: .yellow, radius: 5)
                    
                    // Detailed statistics
                    VStack(spacing: 15) {
                        Text("📊 Game Statistics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            statCard(icon: "trophy.fill", title: "Level Reached", value: "\(gameEngine.level)", color: Color.gold)
                            statCard(icon: "checkmark.circle.fill", title: "Correct", value: "\(gameEngine.correctAnswers)", color: .green)
                            statCard(icon: "target", title: "Accuracy", value: "\(Int(gameEngine.accuracy))%", color: .cyan)
                            statCard(icon: "flame.fill", title: "Best Streak", value: "\(gameEngine.bestStreak)", color: .orange)
                        }
                        
                        // Additional stats
                        HStack(spacing: 20) {
                            VStack {
                                Text("📝 Total Problems")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(gameEngine.totalProblems)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack {
                                Text("⚡ Max Combo")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("x\(gameEngine.comboMultiplier)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            
                            VStack {
                                Text("🎯 Difficulty")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(difficultyText)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Achievements section
                    if !gameEngine.achievements.isEmpty {
                        VStack(spacing: 15) {
                            Text("🏅 Achievements Unlocked")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.gold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                                ForEach(gameEngine.achievements, id: \.self) { achievement in
                                    Text(achievement)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.gold.opacity(0.2))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.gold, lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gold.opacity(0.3), lineWidth: 1)
                            )
                        )
                    }
                }
                
                // Enhanced action buttons
                VStack(spacing: 15) {
                    Button(action: gameEngine.startGame) {
                        HStack(spacing: 15) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title2)
                            
                            Text("Play Again")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(
                            LinearGradient(
                                colors: [.green, .blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: .blue, radius: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                    }
                    
                    Button(action: gameEngine.resetGame) {
                        HStack(spacing: 10) {
                            Image(systemName: "house.circle.fill")
                                .font(.headline)
                            
                            Text("Back to Menu")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 180, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private func statCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(color: color, radius: 3)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
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
        VStack(spacing: 15) {
            if let isCorrect = gameEngine.lastAnswerCorrect {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isCorrect ? .green : .red)
                    .shadow(color: isCorrect ? .green : .red, radius: 20)
                    .scaleEffect(gameEngine.showResult ? 1.3 : 0.5)
                    .rotationEffect(.degrees(gameEngine.showResult ? 360 : 0))
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.showResult)
                
                Text(isCorrect ? "Excellent!" : "Try Again!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .scaleEffect(gameEngine.showResult ? 1.1 : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameEngine.showResult)
                
                if isCorrect {
                    Text("+\(calculateLastScore()) points")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                        .shadow(radius: 3)
                        .scaleEffect(gameEngine.showResult ? 1.0 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameEngine.showResult)
                }
            }
        }
        .opacity(gameEngine.showResult ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: gameEngine.showResult)
    }
    
    var comboOverlay: some View {
        VStack {
            Text("🔥 COMBO x\(gameEngine.comboMultiplier)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .shadow(color: .orange, radius: 10)
                .scaleEffect(gameEngine.showCombo ? 1.2 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.showCombo)
            
            Text("Streak: \(gameEngine.streak)")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(radius: 3)
        }
        .opacity(gameEngine.showCombo ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: gameEngine.showCombo)
    }
    
    var perfectLevelOverlay: some View {
        VStack {
            Text("⭐ PERFECT LEVEL! ⭐")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .shadow(color: .yellow, radius: 15)
                .scaleEffect(gameEngine.perfectLevel ? 1.3 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: gameEngine.perfectLevel)
            
            Text("+200 Bonus Points")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(radius: 3)
        }
        .opacity(gameEngine.perfectLevel ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: gameEngine.perfectLevel)
    }
    
    var fastAnswerOverlay: some View {
        VStack {
            Text("⚡ LIGHTNING FAST! ⚡")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
                .shadow(color: .cyan, radius: 10)
                .scaleEffect(gameEngine.fastAnswerBonus ? 1.1 : 0.5)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameEngine.fastAnswerBonus)
            
            Text("+50 Speed Bonus")
                .font(.subheadline)
                .foregroundColor(.white)
                .shadow(radius: 3)
        }
        .opacity(gameEngine.fastAnswerBonus ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: gameEngine.fastAnswerBonus)
    }
    
    func achievementOverlay(_ achievement: String) -> some View {
        VStack {
                            Text("🏆 ACHIEVEMENT UNLOCKED!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gold)
                .shadow(color: .yellow, radius: 5)
            
            Text(achievement)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.yellow, lineWidth: 2)
                        )
                )
                .shadow(radius: 10)
        }
        .scaleEffect(gameEngine.showAchievement != nil ? 1.1 : 0.5)
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