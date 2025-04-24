
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
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
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
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
                
            case .failure(let error):
                completion(.failure(error))
                print("[ProfileImageService.fetchProfileImageURL]: Ошибка загрузки URL — \(error.localizedDescription)")
            }
        }
        
        task?.resume()
    }
}
