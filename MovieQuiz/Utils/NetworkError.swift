enum NetworkError: Error {
    
    case urlSessionError
    case codeError
    case pictureLoadingError
    
    func errorMessage() -> String {
        switch self {
        case .urlSessionError, .codeError:
            return "Невозможно загрузить данные"
        case .pictureLoadingError:
            return "Не удалось загрузить картинку"
            
        }
    }
}
