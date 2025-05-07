import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Private Properties
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    // MARK: - Initializers
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items
                didLoadDataFromServer()
            case .failure(let error):
                didFailToLoadData(error: error)
            }
        }
    }
    
    func requestNextQuestion() {
        didBeginAssemblingNextQuestion()
        DispatchQueue.global().async { [weak self] in
            
            guard let self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            guard let question = self.makeQuizQuestion(from: movie) else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeQuizQuestion(from movie: MostPopularMovie) -> QuizQuestion? {
        do {
            let imageData = try Data(contentsOf: movie.resizedImageURL)
            let rating = Float(movie.rating) ?? 0
            let ratingForComparison = Float.random(in: 7.5...9.0).rounded(toPlaces: 1)
            let text = "Рейтинг этого фильма больше чем \(ratingForComparison)?"
            let correctAnswer = rating > ratingForComparison
            return QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
        } catch {
            didFailToLoadData(error: NetworkError.pictureLoadingError)
            return nil
        }
    }
    
    private func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didLoadDataFromServer()
        }
    }
    
    private func didFailToLoadData(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didFailToLoadData(with: error)
        }
    }
    
    private func didBeginAssemblingNextQuestion() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didBeginAssemblingNextQuestion()
        }
    }
    
}
