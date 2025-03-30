import Foundation
import UIKit

final class OAuth2Service {
    static let shred = OAuth2Service()
    private init() {}
    private let tokenStorage = OAuth2TokenStorage()
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NSError(domain: "OAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать запрос на получение токена"])
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = tokenResponse.accessToken
                    print("Успешно получен и сохранен токен: \(tokenResponse.accessToken)")
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    print("Ошибка декодирования JSON: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка сети: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Ошибка: не удалось создать baseURL")
            return nil
        }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("Ошибка: не удалось создать URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
