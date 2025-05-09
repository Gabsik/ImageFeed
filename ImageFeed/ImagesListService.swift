
import Foundation
import UIKit


final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    static let shared = ImagesListService()
    var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var isLoading = false
    private var currentPage = 0
    private let tokenStorage: OAuth2TokenStorage
    private let session: URLSession
    private let decoder = JSONDecoder()
    private var lastLoadedPage: Int = 1
    
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
    
    func clearPhotos() {
        photos.removeAll()
    }
    
        func fetchPhotosNextPage() {
            guard !isLoading else { return }

            guard let token = tokenStorage.token else {
                print("Ошибка: отсутствует токен")
                return
            }

            isLoading = true
            currentPage += 1

            guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return }
            urlComponents.queryItems = [
                URLQueryItem(name: "page", value: "\(currentPage)"),
                URLQueryItem(name: "per_page", value: "10")
            ]
            guard let url = urlComponents.url else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    print("Ошибка загрузки фотографий: \(error.localizedDescription)")
                    return
                }
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                }
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    print("Ошибка HTTP: \(httpResponse.statusCode)")
                    return
                }

                guard let data = data else {
                    print("ERROR no data")
                    return
                }

                do {
                    let photoResults = try self.decoder.decode([PhotoResult].self, from: data)
                    let newPhotos = photoResults.map { self.convertToPhoto(from: $0) }

                    DispatchQueue.main.async {
                        self.photos.append(contentsOf: newPhotos)
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: nil,
                            userInfo: ["photos": self.photos]
                        )
                    }
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription)")
                }
            }

            task.resume()
        }
    
//    func fetchPhotosNextPage(handler: @escaping (Swift.Result<[PhotoResult], Error>) -> Void) {
//        assert(Thread.isMainThread)
//
//        guard task == nil, let request = makePhotosRequest() else {
//            print(">>> UNABLE TO CREATE REQUEST <<<")
//            handler(.failure(AuthServiceError.invalidRequest))
//            return
//        }
//
//        let session = URLSession.shared
//        let task = session.data(for: request) {[weak self] result in
//            switch result {
//            case .success(let data):
//                //print("DATA IS HERE:--->>>>", String(data: data, encoding: .utf8) ?? "NO DATA during PHOTOS REQUEST")
//                switch self?.decodePhotos(data) {
//                case .success(let response):
//                    self?.incrementLastPage()
//                    print(">>>>> SUCCESSFULLY DECODED PHOTOS RESPONSE, COUNT OF ARRAY IS: \(response.count) <<<<<")
//                    handler(.success(response))
//
//                case .failure(let error):
//                    print("func fetchPhotosNextPage error: \(String(describing: error))")
//                    handler(.failure(error))
//                case .none:
//                    print("SELF IS NIL")
//                }
//            case .failure(let error):
//                print("func fetchPhotosNextPage error: \(String(describing: error))")
//                handler(.failure(error))
//            }
//            self?.task = nil
//        }
//        self.task = task
//        task .resume()
//    }
    
    func changeLike(photoId: String, isLike: Bool, _ handler: @escaping (Swift.Result<[Photo], Error>) -> Void) {
        guard task == nil else {
            print("TASK IS ACTIVE")
            task?.cancel()
            return
        }
        if isLike == true {
            guard let request = likeOff(authToken: tokenStorage.token, photoId: photoId) else {
                print(">>> UNABLE TO MAKE LIKE REQUEST <<<")
                return
            }
            
            let session = URLSession.shared
            let task = session.data(for: request) {[weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.changePhotoInArray(photoId: photoId)
                        handler(.success(self?.photos ?? []))
                    case .failure(let error):
                        print("ERROR AFTER REQUEST")
                        handler(.failure(error))
                    }
                }
                
            }
            self.task = task
            task .resume()
        } else {
            
            guard let request = likeOn(authToken: tokenStorage.token, photoId: photoId) else {
                print(">>> UNABLE TO MAKE LIKE REQUEST <<<")
                return
            }
            
            let session = URLSession.shared
            let task = session.data(for: request) {[weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.changePhotoInArray(photoId: photoId)
                        handler(.success(self?.photos ?? []))
                    case .failure(let error):
                        print("ERROR AFTER REQUEST")
                        handler(.failure(error))
                    }
                }
            }
            self.task = task
            task .resume()
        }
    }
    
    private func changePhotoInArray(photoId: String) {
        DispatchQueue.main.async {
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                
                let photo = self.photos[index]
                
                let newPhoto: [Photo] = [Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    description: photo.description,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: !photo.isLiked
                )]
                
                self.photos.remove(at: index)
                self.photos.insert(contentsOf: newPhoto, at: index)
                print("OLD LIKE STATUS: /","ID:", photo.id, "/ PROPERTY:", photo.isLiked)
                print("NEW LIKE STATUS: /","ID:",self.photos[index].id, "/ PROPERTY:", self.photos[index].isLiked)
            }
        }
        return
    }
    
    private func incrementLastPage() {
        lastLoadedPage += 1
        return
    }
    
    private func makePhotosRequest() -> URLRequest? {
        guard let token = tokenStorage.token else { return nil }
        print("TOKEN", token as Any)
        print("Last page is:", lastLoadedPage)
        var components = URLComponents(string: Constants.defaultIBaseURLString + "/photos")
        components?.queryItems = [URLQueryItem(name: "page", value: String(lastLoadedPage))]
        
        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("REQUEST:", request.description)
        
        return request
    }
    
    private func likeOn(authToken: String?, photoId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        else { return nil }
        var request = URLRequest(url: url)
        if let authToken = authToken {
            request.httpMethod = "POST"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func likeOff(authToken: String?, photoId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        else { return nil }
        var request = URLRequest(url: url)
        if let authToken = authToken {
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func decodePhotos(_ data: Data)  -> Result<[PhotoResult], Error>  {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([PhotoResult].self, from: data)
            return .success(decodedData)
        } catch {
            print("-->UNABLE TO PARSE IMAGE FROM JSON<--")
            return .failure(error)
        }
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
