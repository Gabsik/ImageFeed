
import Foundation

enum ProfileImageServiceError: Error {
    case noToken
    case invalidURL
    case decodingFailed
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    struct UserResult: Codable {
        let profileImages: [String: String]?
        
        enum CodingKeys: String, CodingKey {
            case profileImages = "profile_image"
        }
        
        static func decode(from data: Data) -> Result<String, Error> {
            let decoder = JSONDecoder()
            
            do {
                let decodedProfileImages = try decoder.decode(UserResult.self, from: data)
                
                guard let profileImages = decodedProfileImages.profileImages else { return .failure(ProfileImageServiceError.decodingFailed) }
                guard let smallProfileImage = profileImages["small"] else { return .failure(ProfileImageServiceError.decodingFailed) }
                
                return .success(smallProfileImage)
            } catch {
                print("Error decoding")
                return .failure(error)
            }
        }
    }
        
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(ProfileImageServiceError.invalidURL))
            return
        }
        
        guard let token = tokenStorage.token else {
            completion(.failure(ProfileImageServiceError.noToken))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
         let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            
            switch result {
            case .success(let decodedResponse):
                guard let profileImage = decodedResponse.profileImages else { return }
                guard let smallProfileImage = profileImage["small"] else { return }
                self?.avatarURL = smallProfileImage
                completion(.success(smallProfileImage))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": smallProfileImage])
            case .failure(let error):
                print("[ProfileImageService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        task.resume()
    }
}
                

struct UserResult: Codable {
    let profileImages: [String: String]?

    enum CodingKeys: String, CodingKey {
        case profileImages = "profile_image"
    }

    static func decode(from data: Data) -> Result<String, Error> {
        let decoder = JSONDecoder()

        do {
            let decodedProfileImages = try decoder.decode(UserResult.self, from: data)

            guard let profileImages = decodedProfileImages.profileImages else { return .failure(ProfileImageServiceError.decodingFailed) }
            guard let smallProfileImage = profileImages["small"] else { return .failure(ProfileImageServiceError.decodingFailed) }

            return .success(smallProfileImage)
        } catch {
            print("Error decoding")
            return .failure(error)
        }
    }
}
