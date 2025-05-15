import Foundation
import UIKit

enum Constants {
    static let accessKey = "HSpCrBKKEbC5RXExUy_1b2ATWpP609ge5CL7XQfhjxY"
    static let secretKey = "usIflqaMxWwYp9RnzR00ts292rP_NyGMBHIcmXQ8VsU"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let photosPath = "/photos"
    static let defaultIBaseURLString = "https://api.unsplash.com/"
    static let userProfilePath = "/users"
    static let baseURL = "https://unsplash.com"
    static let photosURL = defaultBaseURL.appendingPathComponent(photosPath)
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    static func userProfileURL(for username: String) -> URL {
        return defaultBaseURL.appendingPathComponent("\(userProfilePath)/\(username)")
    }
    
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL for defaultBaseURL")
        }
        return url
    }()
    
    static let authPath = "/oauth/authorize"
    static let authURL = "https://unsplash.com\(authPath)"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
}
