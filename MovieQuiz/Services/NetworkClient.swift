import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    // MARK: - Public Methods
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
    
}
