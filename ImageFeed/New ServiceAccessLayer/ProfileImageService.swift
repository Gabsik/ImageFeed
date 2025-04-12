
import Foundation

enum ProfileImageServiceError: Error {
    case noToken
    case invalidURL
    case decodingFailed
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    struct ProfileImage: Codable {
        let small: String
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let token = tokenStorage.token else {
            completion(.failure(ProfileImageServiceError.noToken))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(ProfileImageServiceError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        task = urlSession.dataTask(with: request) { [ weak self ] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard
                    let data = data,
                    let userResult = try? JSONDecoder().decode(UserResult.self, from: data)
                else {
                    completion(.failure(ProfileImageServiceError.decodingFailed))
                    return
                }
                
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
            }
        }
        task?.resume()
    }
}
