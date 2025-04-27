
import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case missingToken
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var currentToken: String?
    private let tokenStorage = OAuth2TokenStorage()
    
    static let profileDidChange = Notification.Name("ProfileDidChange")
    
    struct ProfileResult: Codable {
        let username: String
        let bio: String?
        let firstName: String
        let lastName: String
        
        enum CodingKeys: String, CodingKey {
            case username
            case bio
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }
    
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        
        init(from result: ProfileResult) {
            self.username = result.username
            self.name = "\(result.firstName) \(result.lastName)"
            self.loginName = "@\(result.username)"
            self.bio = result.bio
        }
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self.profile = profile
                completion(.success(profile))
                NotificationCenter.default.post(name: ProfileService.profileDidChange, object: nil)
            case .failure(let error):
                completion(.failure(error))
                print("[ProfileService.fetchProfile]: Ошибка получения профиля — \(error.localizedDescription)")
            }
            self.task = nil
            self.currentToken = nil
        }
        task?.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Ошибка: не удалось создать URL профиля")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
