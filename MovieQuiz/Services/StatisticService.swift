import Foundation

final class StatisticService {
    
    private weak var delegate: StatisticServiceDelegate?
    private let storage: UserDefaults = .standard
    
    init(delegate: StatisticServiceDelegate?) {
        self.delegate = delegate
    }
    
    private func didStoreData(_ bestGame: GameResult) {
        delegate?.didStoreData(bestGame: bestGame)
    }
    
}

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: StatisticStorageKeys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: StatisticStorageKeys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            
            let correct = storage.integer(forKey: StatisticStorageKeys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: StatisticStorageKeys.bestGameTotal.rawValue)
            let date: Date = storage.object(forKey: StatisticStorageKeys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: StatisticStorageKeys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: StatisticStorageKeys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: StatisticStorageKeys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let numberOfQuestions: Double = 10.0
            let correctAnswers: Int = storage.integer(forKey: StatisticStorageKeys.correctAnswers.rawValue)
            let doubleCorrectAnswers: Double = Double(correctAnswers)
            let doubleGamesCount: Double = Double(gamesCount)
            
            if gamesCount > 0 {
                return doubleCorrectAnswers / (numberOfQuestions * doubleGamesCount) * 100
            } else {
                return Double.zero
            }
        }
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: StatisticStorageKeys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: StatisticStorageKeys.correctAnswers.rawValue)
        }
    }
        
    private var totalAnswers: Int {
        get {
            storage.integer(forKey: StatisticStorageKeys.totalAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: StatisticStorageKeys.totalAnswers.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentGame: GameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
        correctAnswers += count
        totalAnswers += amount
        gamesCount += 1
        didStoreData(bestGame)
    }
    
    
}
