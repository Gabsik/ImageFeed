
import Foundation
import UIKit

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void)
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func clearData()
}

final class ImagesListService: ImagesListServiceProtocol {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()

    private(set) var photos: [Photo] = []
    private var isLoading = false
    private var currentPage = 0
    private let tokenStorage: OAuth2TokenStorage
    private let session: URLSession
    private let decoder = JSONDecoder()
    private var lastLoadedPage: Int = 1
    var task: URLSessionTask?

    private static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    init(tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage(), session: URLSession = .shared) {
        self.tokenStorage = tokenStorage
        self.session = session
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isLoading else {
            completion(.success(()))
            return
        }
        guard let token = tokenStorage.token else {
            completion(.failure(NSError(domain: "ImagesListService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Отсутствует токен"])))
            return
        }

        isLoading = true
        currentPage += 1

        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            completion(.failure(NSError(domain: "ImagesListService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(currentPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]

        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "ImagesListService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "ImagesListService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ сервера"])))
                }
                return
            }

            do {
                let photoResults = try self.decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { self.convertToPhoto(from: $0) }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }

        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        // Если уже идёт запрос, отменяем его
        if let activeTask = task, activeTask.state == .running {
            print(">>> TASK IS ACTIVE — CANCELING <<<")
            activeTask.cancel()
        }

        // Создание запроса
        let request = isLike
            ? likeOff(authToken: tokenStorage.token, photoId: photoId)
            : likeOn(authToken: tokenStorage.token, photoId: photoId)

        guard let request = request else {
            print(">>> UNABLE TO MAKE LIKE REQUEST <<<")
            completion(.failure(NSError(domain: "ImagesListService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать запрос"])))
            return
        }

        // Запуск задачи
        let task = session.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.changePhotoInArray(photoId: photoId)
                    completion(.success(()))
                case .failure(let error):
                    print(">>> ERROR AFTER REQUEST: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self?.task = nil // очистка после выполнения
            }
        }

        self.task = task
        task.resume()
    }

//    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard task == nil else {
//            task?.cancel()
//            completion(.failure(NSError(domain: "ImagesListService", code: 429, userInfo: [NSLocalizedDescriptionKey: "Запрос уже выполняется"])))
//            return
//        }
//
//        let request: URLRequest?
//        if isLike {
//            request = likeOff(authToken: tokenStorage.token, photoId: photoId)
//        } else {
//            request = likeOn(authToken: tokenStorage.token, photoId: photoId)
//        }
//
//        guard let request = request else {
//            completion(.failure(NSError(domain: "ImagesListService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать запрос"])))
//            return
//        }
//
//        task = session.data(for: request) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.changePhotoInArray(photoId: photoId)
//                    completion(.success(()))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//                self?.task = nil
//            }
//        }
//    }

    private func changePhotoInArray(photoId: String) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let photo = photos[index]
            let updatedPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                description: photo.description,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked
            )

            photos[index] = updatedPhoto

            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: nil,
                userInfo: ["updatedIndex": index]
            )
        }
    }

    private func likeOn(authToken: String?, photoId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func likeOff(authToken: String?, photoId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func convertToPhoto(from result: PhotoResult) -> Photo {
        let size = CGSize(width: result.width, height: result.height)
        let createdAt = result.createdAt.flatMap { ImagesListService.isoDateFormatter.date(from: $0) }
        return Photo(
            id: result.id,
            size: size,
            createdAt: createdAt,
            description: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }

    func clearData() {
        photos.removeAll()
    }
}
