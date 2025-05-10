

import Foundation


final class ImageFeedService {
    private let tokenStorage: OAuth2TokenStorage
    private let session:URLSession
    init(tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage(), session: URLSession = .shared) {
        self.tokenStorage = tokenStorage
        self.session = session
    }
    
    func fetchPhotos(completion: @escaping (Result<[PhotoResult], Error>) -> Void) {
        guard let token = tokenStorage.token else {
            completion(.failure(NSError(domain: "ImageFeedService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token available"])))
            return
        }
        
        let url = Constants.photosURL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ImageFeedService", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let photos = try JSONDecoder().decode([PhotoResult].self, from: data)
                completion(.success(photos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
