import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate, StatisticServiceDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = Int.zero
    private var correctAnswers = Int.zero
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingIndicator()
        configureDependencies()
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Status Bar Configuration
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        turnOffButtons()
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        turnOffButtons()
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    // MARK: - Public Methods
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - AlertPresenterDelegate
    func presentAlert(viewControllerToPresent: UIViewController) {
        self.present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    // MARK: - StatisticServiceDelegate
    func didStoreData(bestGame: GameResult?) {
        guard let bestGame = bestGame else {
            return
        }
        
        let accuracy = (String(format: "%.2f", statisticService?.totalAccuracy ?? Double.zero))
        let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
        "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)\n" +
        "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n" +
        "Средняя точность: \(accuracy)%"
        
        let result: QuizResultsViewModel = .init(title: "Этот раунд окончен! ",
                                                 text: text,
                                                 buttonText: "Сыграть ещё раз")
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: result)
        }
        
    }
    
    // MARK: - Private Methods
    private func configureDependencies() {
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.alertPresenter = AlertPresenter(delegate: self)
        self.statisticService = StatisticService(delegate: self)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let alertAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = CGFloat.zero
            self.currentQuestionIndex = Int.zero
            self.correctAnswers = Int.zero
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertModel = AlertModel (
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: alertAction
        )
        
        self.alertPresenter?.presentAlert(model: alertModel)
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor(named: isCorrect ? "YP Green" : "YP Red")?.cgColor
        
        if isCorrect { correctAnswers += 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
        } else {
            currentQuestionIndex += 1
            self.imageView.layer.borderWidth = 0
            questionFactory?.requestNextQuestion()
        }
        turnOnButtons()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel (
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз",
            completion: {}
        )
        
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        
        self.questionFactory?.loadData()
        
        self.alertPresenter?.presentAlert(model: alertModel)
    }
    
    private func changeButtonStatus(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func turnOnButtons() {
        changeButtonStatus(isEnabled: true)
    }
    
    private func turnOffButtons() {
        changeButtonStatus(isEnabled: false)
    }
    
}
