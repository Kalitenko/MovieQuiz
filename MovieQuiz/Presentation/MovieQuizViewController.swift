import UIKit

final class MovieQuizViewController: UIViewController,
                                     AlertPresenterDelegate,
                                     MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingIndicator()
        configureDependencies()
    }
    
    // MARK: - Status Bar Configuration
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        turnOffButtons()
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        turnOffButtons()
        presenter?.noButtonClicked()
    }
    
    // MARK: - AlertPresenterDelegate
    func presentAlert(viewControllerToPresent: UIViewController) {
        self.present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    // MARK: - Public Methods
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = CGFloat.zero
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        turnOnButtons()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertAction: () -> Void = { [weak self] in
            guard let self else { return }
            presenter?.restartGame()
        }
        let alertModel = AlertModel (
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: alertAction
        )
        self.alertPresenter?.presentAlert(model: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor(named: isCorrectAnswer ? "YP Green" : "YP Red")?.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertAction: () -> Void = { [weak self] in
            guard let self else { return }
            presenter?.restartGame()
        }
        
        let alertModel = AlertModel (
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: alertAction
        )
        self.alertPresenter?.presentAlert(model: alertModel)
    }
    
    // MARK: - Private Methods
    private func configureDependencies() {
        self.alertPresenter = AlertPresenter(delegate: self)
        self.presenter = MovieQuizPresenter(viewController: self)
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
