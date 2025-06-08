import SwiftUI

struct MathProblem {
    let question: String
    let correctAnswer: Int
    let options: [Int]
    let difficulty: Int
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
    
    private var timer: Timer?
    
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
        
        if answer == currentProblem.correctAnswer {
            correctAnswers += 1
            streak += 1
            lastAnswerCorrect = true
            
            // Scoring system
            let basePoints = currentProblem.difficulty * 10
            let streakBonus = min(streak * 5, 50)
            let timeBonus = Int(timeRemaining / 3)
            
            score += basePoints + streakBonus + timeBonus
            
            // Level up every 5 correct answers
            if correctAnswers % 5 == 0 {
                level += 1
                timeRemaining = min(timeRemaining + 10, 60) // Add time bonus for leveling up
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
        } else {
            streak = 0
            lastAnswerCorrect = false
            
            // Penalty - lose 2 seconds
            timeRemaining = max(timeRemaining - 2, 0)
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        
        showResult = true
        
        // Generate next problem after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.showResult = false
            self.lastAnswerCorrect = nil
            self.generateNewProblem()
        }
    }
    
    func generateNewProblem() {
        currentProblem = MathGameEngine.generateProblem(for: level)
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
            // Dynamic background based on level
            LinearGradient(
                colors: [
                    levelColor.opacity(0.3),
                    levelColor.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: gameEngine.level)
            
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
            
            // Result feedback overlay
            if gameEngine.showResult {
                resultFeedback
            }
        }
    }
    
    var welcomeScreen: some View {
        VStack(spacing: 30) {
            Text("🔢 Math Speed Clicker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 5)
            
            Text("Test your math skills!\nSolve problems as fast as you can!")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .shadow(radius: 2)
            
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("Levels 1-3: Addition")
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Levels 4-6: Subtraction")
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.purple)
                    Text("Levels 7-8: Multiplication")
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "function")
                        .foregroundColor(.orange)
                    Text("Level 9+: Mixed Operations")
                        .foregroundColor(.white)
                }
            }
            .font(.title3)
            
            Button(action: gameEngine.startGame) {
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(30)
                    .shadow(radius: 10)
            }
            .scaleEffect(gameEngine.isGameActive ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: gameEngine.isGameActive)
        }
    }
    
    var gamePlayingScreen: some View {
        VStack(spacing: 25) {
            // Header with stats
            HStack {
                VStack(alignment: .leading) {
                    Text("Score: \(gameEngine.score)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Level \(gameEngine.level)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Streak: \(gameEngine.streak)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(difficultyText)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .foregroundColor(.white)
            .shadow(radius: 2)
            
            // Timer bar
            VStack(spacing: 8) {
                HStack {
                    Text("Time: \(Int(gameEngine.timeRemaining))s")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(gameEngine.timeRemaining > 10 ? .green : (gameEngine.timeRemaining > 5 ? .orange : .red))
                            .frame(width: geometry.size.width * (gameEngine.timeRemaining / 30.0), height: 8)
                            .cornerRadius(4)
                            .animation(.linear(duration: 0.1), value: gameEngine.timeRemaining)
                    }
                }
                .frame(height: 8)
            }
            
            // Level progress
            VStack(spacing: 8) {
                HStack {
                    Text("Progress to Level \(gameEngine.level + 1)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(gameEngine.correctAnswers % 5)/5")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(.white)
                            .frame(width: geometry.size.width * gameEngine.levelProgress, height: 4)
                            .cornerRadius(2)
                            .animation(.easeInOut(duration: 0.3), value: gameEngine.levelProgress)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            // Math problem
            VStack(spacing: 20) {
                Text(gameEngine.currentProblem.question)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)
                    .scaleEffect(gameEngine.showResult ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3), value: gameEngine.showResult)
                
                // Answer options
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(gameEngine.currentProblem.options, id: \.self) { option in
                        Button(action: {
                            gameEngine.answerSelected(option)
                        }) {
                            Text("\(option)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.white.opacity(0.5), lineWidth: 2)
                                        )
                                )
                                .shadow(radius: 5)
                        }
                        .disabled(gameEngine.showResult)
                        .scaleEffect(gameEngine.showResult ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2), value: gameEngine.showResult)
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
        VStack(spacing: 30) {
            Text("🎯 Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 5)
            
            VStack(spacing: 15) {
                Text("Final Score: \(gameEngine.score)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                Text("Level Reached: \(gameEngine.level)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("Problems Solved: \(gameEngine.correctAnswers)/\(gameEngine.totalProblems)")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text("Accuracy: \(Int(gameEngine.accuracy))%")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text("Best Streak: \(gameEngine.streak)")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.1))
            )
            
            VStack(spacing: 15) {
                Button(action: gameEngine.startGame) {
                    Text("Play Again")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                
                Button(action: gameEngine.resetGame) {
                    Text("Back to Menu")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 150, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.2))
                        )
                }
            }
        }
    }
    
    var resultFeedback: some View {
        VStack {
            if let isCorrect = gameEngine.lastAnswerCorrect {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isCorrect ? .green : .red)
                    .shadow(radius: 10)
                    .scaleEffect(1.2)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: gameEngine.showResult)
                
                Text(isCorrect ? "Correct!" : "Wrong!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
            }
        }
        .opacity(gameEngine.showResult ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: gameEngine.showResult)
    }
} 