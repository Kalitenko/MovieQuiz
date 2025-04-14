import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    func presentAlert(model: AlertModel) {
        
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let handler: (UIAlertAction) -> Void = { _ in
            model.completion()
        }
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: handler)
        alert.addAction(action)
        
        
        DispatchQueue.main.async { [self] in
            delegate?.presentAlert(viewControllerToPresent: alert)
        }
        
    }
}

