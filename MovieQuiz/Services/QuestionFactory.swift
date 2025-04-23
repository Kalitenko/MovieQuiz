import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private weak var delegate: QuestionFactoryDelegate?
    private var questions: [QuizQuestion] = []
    
    // MARK: - Mock Data Initialization
    private let questionsData: [QuizQuestion] = QuizQuestion.mockList
    
    init() {
        questions = questionsData
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        
        if questions.isEmpty {
            questions = questionsData
        }
        
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questions[safe: index]
        questions.remove(at: index)
        delegate?.didReceiveNextQuestion(question: question)
    }
}
