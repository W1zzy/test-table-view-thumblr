//
//  NetworkManager.swift
//  TestApplication
//
//  Created by Антон Братчик on 25.09.17.
//  Copyright © 2017 Антон Братчик. All rights reserved.
//

import UIKit

class NetworkManager {
    private let baseURL = "http://api.tumblr.com/v2/"
    private let taggedEndpoint = "tagged/?tag=%TAG%&api_key=%API_KEY%"
    private let api_key = "CcEqqSrYdQ5qTHFWssSMof4tPZ89sfx6AXYNQ4eoXHMgPJE03U"
    
    // default configuration for support of URLSessionRequestCache
    private lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    private lazy var session: URLSession = URLSession(configuration: configuration)
    private lazy var cache: NSCache<NSString, UIImage>! = NSCache()
    
    static let sharedInstance = NetworkManager()
    
    func getPostsWith(tag: String, onSuccess: @escaping ([String: AnyObject]) -> Void, onFailure: @escaping (String) -> Void) {
        cache.removeAllObjects()
        
        if let escapedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let url = "\(baseURL)\(taggedEndpoint.replacingOccurrences(of: "%TAG%", with: escapedTag).replacingOccurrences(of: "%API_KEY%", with: api_key))"
            
            var request: URLRequest = URLRequest(url: NSURL(string: url)! as URL)
            request.httpMethod = "GET"
            request.timeoutInterval = 10
            
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                if error != nil {
                    onFailure(error?.localizedDescription ?? "Something went wrong")
                } else {
                    if let result = NetworkManager.parseJSONFromData(jsonData: data) {
                        onSuccess(result)
                    } else {
                        onFailure("Wrong data received")
                    }
                }
            })
            
            task.resume()
        } else {
            onFailure("Bad input data")
        }
    }
    
    
    func getImageWith(url: URL, onSuccess: @escaping (UIImage) -> Void) {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            onSuccess(image)
        } else {
            let task = session.downloadTask(with: url, completionHandler: { [weak self] (location, response, error) in
                if let loc = location {
                    if let data = try? Data(contentsOf: loc) {
                        let img: UIImage! = UIImage(data: data)
                        self?.cache.setObject(img, forKey: url.absoluteString as NSString)
                        
                        onSuccess(img)
                    }
                }
            })
            
            task.resume()
        }
    }
    
}

/// Helpers
extension NetworkManager {
    static func parseJSONFromData(jsonData: Data?) -> [String: AnyObject]? {
        if let data = jsonData {
            do {
                let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
                return jsonDictionary
            } catch let error as NSError {
                print("Error processing json data: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
}
