import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    // MARK: - Initializers
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    func presentAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let handler: (UIAlertAction) -> Void = { _ in
            model.completion()
        }
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: handler)
        alert.addAction(action)
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.presentAlert(viewControllerToPresent: alert)
        }
        
    }
}

