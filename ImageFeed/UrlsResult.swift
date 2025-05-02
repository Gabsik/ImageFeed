
import Foundation


import Foundation
 
 struct UrlsResult: Codable {
     let urlLarge: String
     let urlThumb: String
     
     enum CodingKeys: String, CodingKey {
         case urlLarge = "full"
         case urlThumb = "thumb"
     }
 }
