import Foundation

final class StatisticService {
    
    private weak var delegate: StatisticServiceDelegate?
    
    init(delegate: StatisticServiceDelegate?) {
        self.delegate = delegate
    }
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case total
        case gamesCount
        
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
    
    private func didStoreData(_ bestGame: GameResult) {
        delegate?.didStoreData(bestGame: bestGame)
    }
    
}

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date: Date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let numberOfQuestions: Double = 10.0
            let correctAnswers: Int = storage.integer(forKey: Keys.correct.rawValue)
            let doubleCorrectAnswers: Double = Double(correctAnswers)
            let doubleGamesCount: Double = Double(gamesCount)
            
            if gamesCount > 0 {
                return doubleCorrectAnswers / (numberOfQuestions * doubleGamesCount) * 100
            } else {
                return Double.zero
            }
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentGame: GameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
        let currentCorrectValue: Int = storage.integer(forKey: Keys.correct.rawValue)
        let currentTotalValue: Int = storage.integer(forKey: Keys.total.rawValue)
        storage.set(currentCorrectValue + count, forKey: Keys.correct.rawValue)
        storage.set(currentTotalValue + amount, forKey: Keys.total.rawValue)
        gamesCount += 1
        didStoreData(bestGame)
    }
    
    
}
