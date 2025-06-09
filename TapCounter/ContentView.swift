import SwiftUI
import StoreKit

// MARK: - Custom Button Styles and Components
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isGradient: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String, color: Color = .blue, gradient: [Color]? = nil, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = gradient?.first ?? color
        self.isGradient = gradient != nil
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isDisabled ? 0.2 : 0.3))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isDisabled ? .white.opacity(0.4) : color)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(isDisabled ? .white.opacity(0.4) : .white)
                    
                    Text(subtitle)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(isDisabled ? .white.opacity(0.3) : .white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(height: 85)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(isDisabled ? 0.05 : (isGradient ? 0.2 : 0.15)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(isDisabled ? 0.1 : 0.3), lineWidth: 1)
                    )
            )
        }
        .disabled(isDisabled)
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Simple Donation View (without In-App Purchases for now)
struct DonationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.8),
                        Color.pink.opacity(0.6),
                        Color.orange.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Text("❤️")
                                .font(.system(size: 60))
                            
                            Text("Support MATH RUSH")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Help keep the app free and support future updates!")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Coming Soon message
                        VStack(spacing: 20) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.yellow)
                            
                            Text("🚧 Coming Soon!")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Donation features are being prepared.\nStay tuned for the next update!")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                        
                        // Donation options placeholder
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            DonationCardPlaceholder(emoji: "☕️", title: "Small Tip", description: "Buy me a coffee!", price: "$0.99")
                            DonationCardPlaceholder(emoji: "🍕", title: "Medium Tip", description: "Grab a slice together!", price: "$2.99")
                            DonationCardPlaceholder(emoji: "🎮", title: "Large Tip", description: "Support development!", price: "$4.99")
                            DonationCardPlaceholder(emoji: "❤️", title: "Huge Tip", description: "You're amazing!", price: "$9.99")
                        }
                        .padding(.horizontal)
                        
                        // Thank you message
                        VStack(spacing: 15) {
                            Text("🙏 Thank You!")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Every donation helps me continue developing amazing features and keeping MATH RUSH free for everyone.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.black.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Donation Card Placeholder
struct DonationCardPlaceholder: View {
    let emoji: String
    let title: String
    let description: String
    let price: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 40))
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text(price)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 5)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(0.6) // Make it look disabled/placeholder
    }
}

struct MathProblem {
    let question: String
    let correctAnswer: Int
    let options: [Int]
    let difficulty: Int
}

struct SlidingPopup: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let icon: String
    let color: Color
    var offset: CGFloat = 0
    var opacity: Double = 1.0
}

enum PopupType: Equatable {
    case result(Bool)  // correct/incorrect
    case combo(Int)    // combo multiplier
    case perfectLevel
    case fastAnswer
    case achievement(String)
    case levelUp(Int)  // level number
}

enum MathMode: String, CaseIterable {
    case addition = "Addition"
    case subtraction = "Subtraction"
    case multiplication = "Multiplication"
    case division = "Division"
    case mixed = "Mixed"
    
    var icon: String {
        switch self {
        case .addition: return "plus"
        case .subtraction: return "minus"
        case .multiplication: return "multiply"
        case .division: return "divide"
        case .mixed: return "shuffle"
        }
    }
    
    var color: Color {
        switch self {
        case .addition: return .green
        case .subtraction: return .blue
        case .multiplication: return .purple
        case .division: return .orange
        case .mixed: return .pink
        }
    }
}

// Rank System
enum RankTier: String, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver" 
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
    case master = "Master"
    case grandmaster = "Grandmaster"
    
    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .gold: return Color.gold
        case .platinum: return Color(red: 0.9, green: 0.9, blue: 0.95)
        case .diamond: return Color.cyan
        case .master: return Color.purple
        case .grandmaster: return Color.red
        }
    }
    
    var icon: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .platinum: return "💎"
        case .diamond: return "💠"
        case .master: return "👑"
        case .grandmaster: return "🏆"
        }
    }
}

struct PlayerRank {
    let tier: RankTier
    let level: Int // 1-5 within each tier
    let points: Int
    
    var displayName: String {
        "\(tier.rawValue) \(level)"
    }
    
    var nextRankPoints: Int {
        let basePoints = RankTier.allCases.firstIndex(of: tier)! * 1000
        return basePoints + (level * 200)
    }
    
    var previousRankPoints: Int {
        let basePoints = RankTier.allCases.firstIndex(of: tier)! * 1000
        return basePoints + ((level - 1) * 200)
    }
    
    static func fromPoints(_ points: Int) -> PlayerRank {
        let tierIndex = min(points / 1000, RankTier.allCases.count - 1)
        let tier = RankTier.allCases[tierIndex]
        let remainingPoints = points - (tierIndex * 1000)
        let level = min(max(1, (remainingPoints / 200) + 1), 5)
        
        return PlayerRank(tier: tier, level: level, points: points)
    }
}

// User Profile with persistent storage
class UserProfile: ObservableObject {
    @Published var gamesPlayed: Int = 0
    @Published var bestScore: Int = 0
    @Published var bestStreak: Int = 0
    @Published var totalCorrectAnswers: Int = 0
    @Published var totalProblems: Int = 0
    @Published var unlockedAchievements: Set<String> = Set()
    @Published var rankPoints: Int = 0
    @Published var currentRank: PlayerRank = PlayerRank.fromPoints(0)
    
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
        rankPoints = userDefaults.integer(forKey: "rankPoints")
        currentRank = PlayerRank.fromPoints(rankPoints)
        
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
        userDefaults.set(rankPoints, forKey: "rankPoints")
        
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
    
    func updateRank(isCorrect: Bool, difficulty: Int) -> (rankChanged: Bool, rankUp: Bool) {
        let oldRank = currentRank
        
        if isCorrect {
            // Points for correct answer: base + difficulty bonus
            let pointsGained = 10 + (difficulty * 2)
            rankPoints += pointsGained
        } else {
            // Points lost for wrong answer: proportional to current rank
            let pointsLost = max(5, rankPoints / 100)
            rankPoints = max(0, rankPoints - pointsLost)
        }
        
        // Update current rank
        currentRank = PlayerRank.fromPoints(rankPoints)
        saveData()
        
        // Check for rank change
        let rankChanged = oldRank.tier != currentRank.tier || oldRank.level != currentRank.level
        let rankUp = rankChanged && (currentRank.points > oldRank.points)
        
        return (rankChanged, rankUp)
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

struct ConfettiPiece: View {
    @State private var animate = false
    let color: Color
    let startPosition: CGPoint
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(animate ? 720 : 0))
            .offset(
                x: animate ? CGFloat.random(in: -200...200) : 0,
                y: animate ? CGFloat.random(in: 300...800) : 0
            )
            .opacity(animate ? 0 : 1)
            .position(startPosition)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0)) {
                    animate = true
                }
            }
    }
}

struct ConfettiView: View {
    @State private var confettiPositions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            // More confetti pieces for level up celebrations
            ForEach(0..<100, id: \.self) { index in
                ConfettiPiece(
                    color: [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan, .mint].randomElement() ?? .blue,
                    startPosition: confettiPositions.indices.contains(index) ? confettiPositions[index] : CGPoint(x: 100, y: 100)
                )
            }
        }
        .onAppear {
            generateConfettiPositions()
        }
        .allowsHitTesting(false)
    }
    
    private func generateConfettiPositions() {
        confettiPositions = (0..<100).map { _ in
            CGPoint(
                x: CGFloat.random(in: 20...380),
                y: CGFloat.random(in: 50...400)
            )
        }
    }
}

class MathGameEngine: ObservableObject {
    var userProfile: UserProfile?
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
    
    // New properties for non-intrusive feedback system
    @Published var pendingPopups: [PopupType] = []
    @Published var currentPopup: PopupType? = nil
    @Published var isShowingPopups = false
    
    // Non-intrusive feedback indicators
    @Published var recentFeedback: [String] = []
    @Published var consecutiveBonuses = 0
    @Published var showBriefConfirmation = false
    
    // Sliding text popups
    @Published var slidingPopups: [SlidingPopup] = []
    
    // Rank change tracking
    @Published var rankChanged = false
    @Published var rankUp = false
    
    // Health system
    @Published var health = 2
    @Published var showContinueScreen = false
    
    // Confetti animation
    @Published var showConfetti = false
    @Published var leveledUp = false
    
    // Mode selection
    @Published var selectedMode: MathMode = .mixed
    @Published var showModeSelection = false
    
    private var timer: Timer?
    private var questionStartTime: Date?
    
    init() {
        self.currentProblem = MathGameEngine.generateProblem(for: 1, mode: .mixed)
    }
    
    static func generateProblem(for level: Int, mode: MathMode = .mixed) -> MathProblem {
        let difficulty = min(level, 10)
        
        switch mode {
        case .addition:
            return generateAdditionProblem(difficulty: difficulty)
        case .subtraction:
            return generateSubtractionProblem(difficulty: difficulty)
        case .multiplication:
            return generateMultiplicationProblem(difficulty: difficulty)
        case .division:
            return generateDivisionProblem(difficulty: difficulty)
        case .mixed:
            // Original mixed logic based on level
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
    
    static func generateDivisionProblem(difficulty: Int) -> MathProblem {
        let maxResult = difficulty <= 3 ? 10 : (difficulty <= 6 ? 15 : 20)
        let divisor = Int.random(in: 2...10)
        let result = Int.random(in: 2...maxResult)
        let dividend = divisor * result
        
        return MathProblem(
            question: "\(dividend) ÷ \(divisor) = ?",
            correctAnswer: result,
            options: generateOptions(correct: result, range: 8),
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
        
        // Clear feedback indicators
        recentFeedback.removeAll()
        consecutiveBonuses = 0
        showBriefConfirmation = false
        slidingPopups.removeAll()
        
        generateNewProblem()
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Pause timer only during result popups, not for achievement icons
            if !self.isShowingPopups && self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
            } else if self.timeRemaining <= 0 && !self.isShowingPopups {
                self.endGame()
            }
        }
    }
    
    func endGame() {
        timer?.invalidate()
        isGameActive = false
        
        // Check if player has health remaining
        if health > 0 {
            showContinueScreen = true
        } else {
            gameOver = true
        }
    }
    
    func continueGame() {
        health -= 1
        timeRemaining = 15.0 // Give 15 seconds for continue
        showContinueScreen = false
        isGameActive = true
        startTimer()
    }
    
    func declineContinue() {
        gameOver = true
        showContinueScreen = false
    }
    
    func showModeSelectionScreen() {
        showModeSelection = true
    }
    
    func startGameWithMode(_ mode: MathMode) {
        selectedMode = mode
        showModeSelection = false
        startGame()
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
                leveledUp = true
                showConfetti = true
                timeRemaining = min(timeRemaining + 15, 60) // More generous time bonus
                
                // Hide confetti after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showConfetti = false
                }
                
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
        
        // Update rank system
        if let userProfile = userProfile {
            let rankResult = userProfile.updateRank(isCorrect: answer == currentProblem.correctAnswer, difficulty: currentProblem.difficulty)
            rankChanged = rankResult.rankChanged
            rankUp = rankResult.rankUp
        }
        
        // Show result popup and add persistent achievement icons
        addSubtleFeedback(isCorrect: answer == currentProblem.correctAnswer)
        showResultPopup(isCorrect: answer == currentProblem.correctAnswer)
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
        currentProblem = MathGameEngine.generateProblem(for: level, mode: selectedMode)
        questionStartTime = Date()
    }
    
    private func addSubtleFeedback(isCorrect: Bool) {
        if isCorrect {
            var newSlidingPopups: [SlidingPopup] = []
            
            // Add persistent achievement icons (don't clear old ones)
            if fastAnswerBonus {
                recentFeedback.append("⚡")
                newSlidingPopups.append(SlidingPopup(text: "FAST ANSWER +50", icon: "⚡", color: .cyan))
            }
            
            if showCombo {
                recentFeedback.append("🔥")
                newSlidingPopups.append(SlidingPopup(text: "COMBO x\(comboMultiplier)", icon: "🔥", color: .orange))
            }
            
            if perfectLevel {
                recentFeedback.append("⭐")
                newSlidingPopups.append(SlidingPopup(text: "PERFECT LEVEL +200", icon: "⭐", color: .yellow))
            }
            
            if let achievement = showAchievement {
                recentFeedback.append("🏆")
                newSlidingPopups.append(SlidingPopup(text: achievement.uppercased(), icon: "🏆", color: Color.gold))
            }
            
            // Add rank change popup
            if rankChanged {
                if let userProfile = self.userProfile {
                    let rankText = rankUp ? "RANK UP!" : "RANK DOWN!"
                    let rankIcon = rankUp ? "📈" : "📉"
                    let rankColor = rankUp ? Color.green : Color.red
                    newSlidingPopups.append(SlidingPopup(
                        text: "\(rankText) \(userProfile.currentRank.tier.icon) \(userProfile.currentRank.displayName)",
                        icon: rankIcon,
                        color: rankColor
                    ))
                }
            }
            
            if leveledUp {
                recentFeedback.append("🎉")
                // Enhanced celebration effect for level up
                withAnimation(.easeInOut(duration: 0.5)) {
                    showBriefConfirmation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.showBriefConfirmation = false
                }
                
                // Enhanced confetti for level up
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.showConfetti = false
                }
            }
            
            // Add sliding popups with staggered delays
            for (index, popup) in newSlidingPopups.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    self.slidingPopups.append(popup)
                    self.animatePopupSlideUp(popup)
                }
            }
        }
        
        // Don't auto-clear - keep icons until game over
    }
    
    private func animatePopupSlideUp(_ popup: SlidingPopup) {
        if let index = slidingPopups.firstIndex(where: { $0.id == popup.id }) {
            // Slide up and fade out animation
            withAnimation(.easeOut(duration: 2.0)) {
                slidingPopups[index].offset = -100
                slidingPopups[index].opacity = 0
            }
            
            // Remove after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.slidingPopups.removeAll { $0.id == popup.id }
            }
        }
    }
    
    private func showResultPopup(isCorrect: Bool) {
        // Show result popup (correct/wrong)
        currentPopup = .result(isCorrect)
        isShowingPopups = true
        
        // If level up, show special level up popup after result
        if leveledUp {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.currentPopup = .levelUp(self.level)
                
                // Show level up popup for 1.5 seconds (longer for celebration)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.finishPopupSequence()
                }
            }
        } else {
            // Show result popup for 0.8 seconds, then continue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.finishPopupSequence()
            }
        }
    }
    
    private func showNextPopup() {
        // No longer used - keeping for compatibility
        finishPopupSequence()
    }
    
    private func finishPopupSequence() {
        isShowingPopups = false
        currentPopup = nil
        
        // Reset popup-related state (but keep persistent achievement icons)
        showResult = false
        lastAnswerCorrect = nil
        showCombo = false
        perfectLevel = false
        fastAnswerBonus = false
        showAchievement = nil
        leveledUp = false
        showBriefConfirmation = false
        
        // Generate next problem quickly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.generateNewProblem()
        }
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
        health = 2
        showContinueScreen = false
        showConfetti = false
        leveledUp = false
        selectedMode = .mixed
        showModeSelection = false
        
        // Clear feedback indicators
        recentFeedback.removeAll()
        consecutiveBonuses = 0
        showBriefConfirmation = false
        slidingPopups.removeAll()
        
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
    @State private var showingShareSheet = false
    @State private var showingLearnMenu = false
    @State private var showingDonationView = false
    
    var difficultyText: String {
        return gameEngine.selectedMode.rawValue
    }
    
    var levelColor: Color {
        return gameEngine.selectedMode.color
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
                
                if !gameEngine.isGameActive && !gameEngine.gameOver && !gameEngine.showContinueScreen && !gameEngine.showModeSelection {
                    // Welcome Screen
                    welcomeScreen
                } else if gameEngine.showModeSelection {
                    // Mode Selection Screen
                    modeSelectionScreen
                } else if gameEngine.showContinueScreen {
                    // Continue Screen
                    continueScreen
                } else if gameEngine.gameOver {
                    // Game Over Screen
                    gameOverScreen
                } else {
                    // Game Playing Screen
                    gamePlayingScreen
                }
            }
            .padding()
            
            // Confetti overlay
            if gameEngine.showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(
                activityItems: [createShareMessage(isGameOver: gameEngine.gameOver)]
            )
        }
        .sheet(isPresented: $showingLearnMenu) {
            LearnMenuView()
        }
        .sheet(isPresented: $showingDonationView) {
            DonationView()
        }
        .onAppear {
            // Connect userProfile to gameEngine
            gameEngine.userProfile = userProfile
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
                    // Rank display prominently
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text(userProfile.currentRank.tier.icon)
                                .font(.title)
                            Text(userProfile.currentRank.displayName)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(userProfile.currentRank.tier.color)
                        }
                        Text("CURRENT RANK")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(1)
                        
                        // Rank progress bar
                        let progress = Double(userProfile.rankPoints - userProfile.currentRank.previousRankPoints) / Double(userProfile.currentRank.nextRankPoints - userProfile.currentRank.previousRankPoints)
                        
                        VStack(spacing: 4) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(.white.opacity(0.2))
                                        .frame(height: 6)
                                        .cornerRadius(3)
                                    
                                    Rectangle()
                                        .fill(userProfile.currentRank.tier.color)
                                        .frame(width: geometry.size.width * max(0, min(1, progress)), height: 6)
                                        .cornerRadius(3)
                                }
                            }
                            .frame(height: 6)
                            
                            HStack {
                                Text("\(userProfile.rankPoints)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("\(userProfile.currentRank.nextRankPoints)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .frame(width: 200)
                    }
                    
                    HStack(spacing: 30) {
                        VStack(spacing: 5) {
                            Text("\(userProfile.bestScore)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.gold)
                            Text("BEST SCORE")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1)
                        }
                        
                        VStack(spacing: 5) {
                            Text("\(userProfile.bestStreak)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.cyan)
                            Text("BEST STREAK")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1)
                        }
                        
                        VStack(spacing: 5) {
                            Text("\(Int(userProfile.accuracy))%")
                                .font(.system(size: 20, weight: .bold))
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
            
            // Enhanced button layout with better hierarchy
            VStack(spacing: 25) {
                // Primary Start Button - Most prominent
                Button(action: {
                    // Initialize bestStreak from profile on first game
                    if userProfile.gamesPlayed == 0 {
                        gameEngine.bestStreak = userProfile.bestStreak
                    }
                    gameEngine.showModeSelectionScreen()
                }) {
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(.black.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "play.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("START GAME")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .tracking(1)
                            
                            Text("Begin your brain training")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.white, Color(white: 0.92)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                
                // Secondary action buttons in a 2x2 grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    // Learn Button
                    MenuButton(
                        icon: "brain.head.profile",
                        title: "LEARN",
                        subtitle: "Math tips & tricks",
                        color: .blue,
                        action: { showingLearnMenu = true }
                    )
                    
                    // Support Button
                    MenuButton(
                        icon: "heart.fill",
                        title: "SUPPORT",
                        subtitle: "Help development",
                        gradient: [.pink, .purple],
                        action: { showingDonationView = true }
                    )
                    
                    // Share Stats Button (conditionally shown)
                    if userProfile.gamesPlayed > 0 {
                        MenuButton(
                            icon: "square.and.arrow.up",
                            title: "SHARE",
                            subtitle: "Show your stats",
                            color: .green,
                            action: { showingShareSheet = true }
                        )
                        
                        // Achievements Button (placeholder for future feature)
                        MenuButton(
                            icon: "trophy.fill",
                            title: "STATS",
                            subtitle: "View achievements",
                            color: .orange,
                            isDisabled: true,
                            action: { /* TODO: Achievements screen */ }
                        )
                    } else {
                        // For new users, show different options
                        MenuButton(
                            icon: "questionmark.circle.fill",
                            title: "TUTORIAL",
                            subtitle: "Learn how to play",
                            color: .cyan,
                            isDisabled: true,
                            action: { /* TODO: Tutorial */ }
                        )
                        
                        MenuButton(
                            icon: "gear",
                            title: "SETTINGS",
                            subtitle: "App preferences",
                            color: .gray,
                            isDisabled: true,
                            action: { /* TODO: Settings */ }
                        )
                    }
                }
                .padding(.horizontal, 8)
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
    
    var modeSelectionScreen: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 15) {
                Text("⚡ CHOOSE MODE")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                Text("Select your math challenge")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Mode selection grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(MathMode.allCases, id: \.self) { mode in
                    Button(action: {
                        gameEngine.startGameWithMode(mode)
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(mode.color)
                            
                            Text(mode.rawValue)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 140, height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(mode.color, lineWidth: 2)
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.2), value: mode)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Back button
            Button(action: {
                gameEngine.showModeSelection = false
            }) {
                Text("BACK")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1)
            }
            
            Spacer()
        }
    }
    
    var continueScreen: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("⏰ TIME'S UP!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                Text("Continue playing?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                VStack(spacing: 10) {
                    Text("Score: \(gameEngine.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Level: \(gameEngine.level)")
                        .font(.headline)
                        .foregroundColor(levelColor)
                    
                    HStack(spacing: 5) {
                        Text("❤️ Lives left:")
                        Text("\(gameEngine.health)")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.black.opacity(0.3))
                )
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: gameEngine.continueGame) {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                        
                        Text("CONTINUE (+15s)")
                            .font(.title3)
                            .fontWeight(.black)
                            .tracking(1)
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 27)
                            .fill(.red)
                            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    )
                }
                
                Button(action: gameEngine.declineContinue) {
                    Text("END GAME")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                }
            }
            
            Spacer()
        }
    }

    
    var gamePlayingScreen: some View {
        ZStack {
            // Fixed header and timer at top
            VStack {
                // Clean header with essential info only
                HStack {
                    // Score with subtle increase animation
                    VStack(spacing: 4) {
                        Text("\(gameEngine.score)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(gameEngine.showBriefConfirmation ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameEngine.showBriefConfirmation)
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
                    
                                    // Level, rank, streak and health
                VStack(spacing: 4) {
                    Text("L\(gameEngine.level)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(levelColor)
                    
                    // Current rank display
                    HStack(spacing: 2) {
                        Text(userProfile.currentRank.tier.icon)
                            .font(.caption)
                        Text(userProfile.currentRank.displayName)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(userProfile.currentRank.tier.color)
                    }
                    
                    HStack(spacing: 2) {
                        ForEach(0..<gameEngine.health, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        ForEach(0..<(2 - gameEngine.health), id: \.self) { _ in
                            Image(systemName: "heart")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if gameEngine.streak > 0 {
                        Text("🔥\(gameEngine.streak)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
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
                
                // Achievement icons under time bar
                HStack {
                    // Achievement icons that stay until game over
                    HStack(spacing: 4) {
                        ForEach(Array(gameEngine.recentFeedback.enumerated()), id: \.offset) { index, emoji in
                            Text(emoji)
                                .font(.title2)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.1), value: gameEngine.recentFeedback)
                        }
                    }
                    .padding(.leading, 30)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            // Centered math problem - always in the middle regardless of popups
            VStack(spacing: 40) {
                // Just the equation - big and bold
                Text(gameEngine.currentProblem.question)
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                    .scaleEffect(gameEngine.showBriefConfirmation ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameEngine.showBriefConfirmation)
                
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
                        .disabled(gameEngine.isShowingPopups)
                        .scaleEffect(gameEngine.showBriefConfirmation ? 1.02 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: gameEngine.showBriefConfirmation)
                    }
                }
            }
            
            // Overlay: Sliding text popups (above center, don't affect layout)
            VStack {
                Spacer()
                    .frame(height: 200) // Push popups above center
                
                ForEach(gameEngine.slidingPopups) { popup in
                    HStack(spacing: 6) {
                        Text(popup.icon)
                            .font(.title3)
                        Text(popup.text)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(popup.color)
                            .tracking(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(popup.color.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .offset(y: popup.offset)
                    .opacity(popup.opacity)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
            .allowsHitTesting(false)
            
            // Overlay: Result popup (below center, don't affect layout)
            VStack {
                Spacer()
                    .frame(height: 50) // Push popup further down
                
                if let currentPopup = gameEngine.currentPopup {
                    popupContent(for: currentPopup)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.currentPopup)
                }
                
                Spacer()
                    .frame(height: 200) // Keep popup well below center
            }
            .allowsHitTesting(false)
            

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
                
                // Share Score Button
                Button(action: { showingShareSheet = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                        
                        Text("SHARE SCORE")
                            .font(.title3)
                            .fontWeight(.black)
                            .tracking(1)
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
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
    
    // New unified popup system
    func popupContent(for popup: PopupType) -> some View {
        Group {
            switch popup {
            case .result(let isCorrect):
                resultPopup(isCorrect: isCorrect)
            case .combo(let multiplier):
                comboPopup(multiplier: multiplier)
            case .perfectLevel:
                perfectLevelPopup()
            case .fastAnswer:
                fastAnswerPopup()
            case .achievement(let achievement):
                achievementPopup(achievement)
            case .levelUp(let level):
                levelUpPopup(level: level)
            }
        }
    }
    

    
    private func resultPopup(isCorrect: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(isCorrect ? .green : .red)
            
            Text(isCorrect ? "CORRECT!" : "WRONG!")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.white)
                .tracking(1)
            
            if isCorrect {
                Text("+\(calculateLastScore())")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isCorrect ? .green : .red, lineWidth: 2)
                )
        )
    }
    
    private func comboPopup(multiplier: Int) -> some View {
        VStack(spacing: 6) {
            Text("🔥 COMBO x\(multiplier)")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.orange)
                .tracking(1)
            
            Text("STREAK: \(gameEngine.streak)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.orange, lineWidth: 2)
                )
        )
    }
    
    private func perfectLevelPopup() -> some View {
        VStack(spacing: 6) {
            Text("⭐ PERFECT! ⭐")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.yellow)
                .tracking(1)
            
            Text("+200 BONUS")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.yellow, lineWidth: 2)
                )
        )
    }
    
    private func fastAnswerPopup() -> some View {
        VStack(spacing: 6) {
            Text("⚡ FAST! ⚡")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(.cyan)
                .tracking(1)
            
            Text("+50 SPEED")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.cyan, lineWidth: 2)
                )
        )
    }
    
    private func achievementPopup(_ achievement: String) -> some View {
        VStack(spacing: 6) {
            Text("🏆 ACHIEVEMENT!")
                .font(.subheadline)
                .fontWeight(.black)
                .foregroundColor(Color.gold)
                .tracking(1)
            
            Text(achievement)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gold, lineWidth: 2)
                )
        )
    }
    
    private func levelUpPopup(level: Int) -> some View {
        VStack(spacing: 10) {
            // Animated stars
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Text("⭐")
                        .font(.title)
                        .scaleEffect(gameEngine.showBriefConfirmation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.1), value: gameEngine.showBriefConfirmation)
                }
            }
            
            Text("LEVEL UP!")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .tracking(2)
                .scaleEffect(gameEngine.showBriefConfirmation ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: gameEngine.showBriefConfirmation)
            
            Text("LEVEL \(level)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .yellow.opacity(0.5), radius: 10)
            
            Text("+15 SECONDS")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.green)
                .tracking(1)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.8), .pink.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.yellow, lineWidth: 3)
                )
                .shadow(color: .yellow.opacity(0.3), radius: 15)
        )
    }
    
    private func calculateLastScore() -> Int {
        let basePoints = gameEngine.currentProblem.difficulty * 10
        let streakBonus = min(gameEngine.streak * 5, 100)
        let timeBonus = Int(max(0, (5.0 - gameEngine.lastAnswerTime) * 10))
        let comboBonus = (gameEngine.comboMultiplier - 1) * 25
        let fastBonus = gameEngine.fastAnswerBonus ? 50 : 0
        return basePoints + streakBonus + timeBonus + comboBonus + fastBonus
    }
    
    private func createShareMessage(isGameOver: Bool = false) -> String {
        let gameTitle = "⚡ MATH RUSH ⚡"
        let subtitle = "Quick. Simple. Addictive."
        
        if isGameOver {
            // Game over share format
            let performanceEmoji = getPerformanceEmoji()
            let levelEmoji = String(repeating: "⭐", count: min(gameEngine.level, 5))
            
            return """
            \(gameTitle)
            \(subtitle)
            
            🎯 FINAL SCORE: \(gameEngine.score)
            \(levelEmoji) LEVEL: \(gameEngine.level)
            \(userProfile.currentRank.tier.icon) RANK: \(userProfile.currentRank.displayName)
            🔥 BEST STREAK: \(gameEngine.bestStreak)
            ✅ ACCURACY: \(Int(gameEngine.accuracy))%
            📊 PROBLEMS: \(gameEngine.correctAnswers)/\(gameEngine.totalProblems)
            
            \(performanceEmoji) \(getPerformanceMessage())
            
            Can you beat my score? 🤔
            #MathRush #BrainTraining #QuickMath
            """
        } else {
            // Profile share format from main menu
            return """
            \(gameTitle)
            \(subtitle)
            
            \(userProfile.currentRank.tier.icon) RANK: \(userProfile.currentRank.displayName)
            🏆 BEST SCORE: \(userProfile.bestScore)
            🔥 BEST STREAK: \(userProfile.bestStreak)
            ✅ ACCURACY: \(Int(userProfile.accuracy))%
            🎮 GAMES PLAYED: \(userProfile.gamesPlayed)
            
            🧠 Training my math skills daily!
            Join me in this addictive brain workout! 💪
            
            #MathRush #BrainTraining #QuickMath
            """
        }
    }
    
    private func getPerformanceEmoji() -> String {
        let accuracy = gameEngine.accuracy
        if accuracy >= 90 { return "🌟" }
        else if accuracy >= 75 { return "🎉" }
        else if accuracy >= 60 { return "👍" }
        else { return "💪" }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

// Learn Menu for math tips and tricks
struct LearnMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                AdditionTipsView()
                    .tabItem {
                        Image(systemName: "plus")
                        Text("Addition")
                    }
                    .tag(0)
                
                SubtractionTipsView()
                    .tabItem {
                        Image(systemName: "minus")
                        Text("Subtraction")
                    }
                    .tag(1)
                
                MultiplicationTipsView()
                    .tabItem {
                        Image(systemName: "multiply")
                        Text("Multiplication")
                    }
                    .tag(2)
                
                DivisionTipsView()
                    .tabItem {
                        Image(systemName: "divide")
                        Text("Division")
                    }
                    .tag(3)
            }
            .navigationTitle("🧠 Math Learning Center")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AdditionTipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TipCard(
                    title: "🔥 Super Easy Addition",
                    tips: [
                        "Round to 10s: 17 + 8 → Think 20 + 8 - 3 = 25",
                        "Jump to next 10: 26 + 7 → 26 + 4 + 3 = 30 + 3 = 33",
                        "Use your fingers: For small numbers, count up on fingers"
                    ],
                    color: .green
                )
                
                TipCard(
                    title: "⚡ Lightning Fast Tricks",
                    tips: [
                        "Adding 9? Add 10, minus 1: 34 + 9 = 44 - 1 = 43",
                        "Adding 8? Add 10, minus 2: 27 + 8 = 37 - 2 = 35",
                        "Same last digit? 23 + 17 = 30 + 10 = 40"
                    ],
                    color: .orange
                )
                
                TipCard(
                    title: "🎮 Try These Now!",
                    tips: [
                        "15 + 9 = ? (Think: 15 + 10 - 1 = 24)",
                        "28 + 6 = ? (Think: 28 + 2 + 4 = 30 + 4 = 34)",
                        "37 + 25 = ? (Think: 37 + 20 + 5 = 57 + 5 = 62)"
                    ],
                    color: .blue
                )
                
                TipCard(
                    title: "🏆 Pro Tips",
                    tips: [
                        "Always start with the bigger number",
                        "Look for ways to make 10, 20, 30...",
                        "Break big numbers into tens and ones"
                    ],
                    color: .purple
                )
            }
            .padding()
        }
    }
}

struct SubtractionTipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TipCard(
                    title: "💡 Easy Subtraction",
                    tips: [
                        "Take away 10, add back: 45 - 8 → 45 - 10 + 2 = 37",
                        "Count up to subtract: 63 - 28 → How far from 28 to 63? = 35",
                        "Use number line: Jump backwards by tens, then ones"
                    ],
                    color: .red
                )
                
                TipCard(
                    title: "🚀 Super Fast Tricks",
                    tips: [
                        "Minus 9? Minus 10, plus 1: 52 - 9 = 42 + 1 = 43",
                        "Minus 8? Minus 10, plus 2: 36 - 8 = 26 + 2 = 28",
                        "Same tens? Just subtract ones: 47 - 43 = 4"
                    ],
                    color: .orange
                )
                
                TipCard(
                    title: "🎯 Practice Time!",
                    tips: [
                        "54 - 7 = ? (Think: 54 - 10 + 3 = 47)",
                        "71 - 26 = ? (Count up: 26 + 4 = 30, 30 + 41 = 71, so 45)",
                        "83 - 19 = ? (Think: 83 - 20 + 1 = 64)"
                    ],
                    color: .blue
                )
                
                TipCard(
                    title: "🎪 Magic Tricks",
                    tips: [
                        "Always round to nearest 10 first",
                        "Think: 'How do I get back to my answer?'",
                        "When stuck, count up from smaller number"
                    ],
                    color: .purple
                )
            }
            .padding()
        }
    }
}

struct MultiplicationTipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TipCard(
                    title: "✋ Finger Magic",
                    tips: [
                        "×9 with fingers: 9×6 → hold down 6th finger → 54!",
                        "×5 is super easy: 6×5 = 30, 8×5 = 40, 12×5 = 60",
                        "×2 is just doubling: 7×2 = 14, 9×2 = 18"
                    ],
                    color: .green
                )
                
                TipCard(
                    title: "🎯 Easy Patterns",
                    tips: [
                        "×10? Just add a zero: 7×10 = 70",
                        "×11? Write number twice: 6×11 = 66, 4×11 = 44",
                        "×4? Double it twice: 7×4 → 14 → 28"
                    ],
                    color: .blue
                )
                
                TipCard(
                    title: "🧠 Smart Shortcuts",
                    tips: [
                        "Use what you know: 6×8 = 6×4×2 = 24×2 = 48",
                        "Break big into small: 7×12 = 7×10 + 7×2 = 70+14 = 84",
                        "Flip it around: 3×8 = 8×3 = 24 (easier!)"
                    ],
                    color: .orange
                )
                
                TipCard(
                    title: "🎮 Try These!",
                    tips: [
                        "What's 6×7? (Think: 6×6=36, so 36+6=42)",
                        "What's 8×9? (Think: 8×10-8 = 80-8 = 72)",
                        "What's 7×5? (Easy! 35)"
                    ],
                    color: .purple
                )
                
                TipCard(
                    title: "🏆 Memory Helpers",
                    tips: [
                        "6×6 = 36 (six six, thirty-six!)",
                        "7×8 = 56 (seven ate and fifty-six)",
                        "9×9 = 81 (nine nine, eighty-one!)"
                    ],
                    color: .pink
                )
            }
            .padding()
        }
    }
}

struct DivisionTipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TipCard(
                    title: "🔄 Think Backwards!",
                    tips: [
                        "Division = backwards multiplication",
                        "42 ÷ 6 = ? Think: What × 6 = 42? Answer: 7!",
                        "Use times tables you know!"
                    ],
                    color: .cyan
                )
                
                TipCard(
                    title: "✂️ Super Easy Division",
                    tips: [
                        "÷2? Just cut in half: 18÷2 = 9",
                        "÷5? Think money! 25÷5 = 5 (like quarters)",
                        "÷10? Remove the last zero: 70÷10 = 7"
                    ],
                    color: .blue
                )
                
                TipCard(
                    title: "🎪 Magic Tricks",
                    tips: [
                        "÷4? Half it twice: 20÷4 → 10 → 5",
                        "÷8? Half it three times: 24÷8 → 12 → 6 → 3",
                        "Big number? Break it apart: 84÷4 = 80÷4 + 4÷4 = 20+1 = 21"
                    ],
                    color: .purple
                )
                
                TipCard(
                    title: "🎮 Practice Now!",
                    tips: [
                        "What's 35÷7? (Think: 7×?=35, so 7×5=35, answer is 5)",
                        "What's 48÷6? (Think: 6×8=48, so answer is 8)",
                        "What's 81÷9? (Think: 9×9=81, so answer is 9)"
                    ],
                    color: .orange
                )
                
                TipCard(
                    title: "🧠 Memory Helpers",
                    tips: [
                        "Know your times tables = know division!",
                        "Start with easy ones: ÷2, ÷5, ÷10",
                        "Practice with objects: 12 cookies ÷ 3 kids = 4 each"
                    ],
                    color: .green
                )
            }
            .padding()
        }
    }
}

struct TipCard: View {
    let title: String
    let tips: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(color)
            
            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .offset(y: 6)
                    
                    Text(tip)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.6), color.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// Share Sheet for social sharing
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        // Customize share options
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .saveToCameraRoll
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {
        // No updates needed
    }
}