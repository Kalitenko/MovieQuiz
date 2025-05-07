import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, StatisticServiceDelegate {
    
    // MARK: - Private Properties
    private var currentQuestionIndex = Int.zero
    private var correctAnswers = Int.zero
    private let numberOfQuestions: Int = 10
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService(delegate: self)
        questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        self.viewController?.hideLoadingIndicator()
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        let message = (error as? NetworkError)?.errorMessage() ?? "Не удалось загрузить данные. Попробуйте позже."
        viewController?.showNetworkError(message: message)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didBeginAssemblingNextQuestion() {
        viewController?.showLoadingIndicator()
    }
    
    // MARK: - StatisticServiceDelegate
    func didStoreData(bestGame: GameResult?) {
        guard let bestGame else { return }
        
        let accuracy = (String(format: "%.2f", statisticService?.totalAccuracy ?? Double.zero))
        let text = "Ваш результат: \(self.correctAnswers)/\(self.numberOfQuestions)\n" +
        "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)\n" +
        "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n" +
        "Средняя точность: \(accuracy)%"
        
        let result: QuizResultsViewModel = .init(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть ещё раз")
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: result)
        }
    }
    
    // MARK: - Public Methods
    func restartGame() {
        currentQuestionIndex = Int.zero
        correctAnswers = Int.zero
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(numberOfQuestions)"
        )
    }
}

// MARK: - Private Methods
private extension MovieQuizPresenter {
    private func didAnswer(isCorrectAnswer: Bool) {
        guard isCorrectAnswer else { return }
        correctAnswers += 1
    }
    
    private func didAnswer(isYes givenAnswer: Bool) {
        guard let currentQuestion else { return }
        
        self.proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == numberOfQuestions - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func proceedToNextQuestionOrResults() {
        
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: self.numberOfQuestions)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}
