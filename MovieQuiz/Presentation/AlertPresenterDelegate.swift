import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(viewControllerToPresent: UIViewController)
}
