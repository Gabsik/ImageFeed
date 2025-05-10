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
