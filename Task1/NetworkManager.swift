//
//  NetworkManager.swift
//  Task1
//
//  Created by Malik Wahaj Ahmed on 05/11/2018.
//  Copyright © 2018 Malik Wahaj Ahmed. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    
    mutating func appendString(str:String) {
        if let data = str.data(using: .utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}

struct API {
    
    static let baseURL = "https://jsonplaceholder.typicode.com"
    static let postsURL = "/posts/"
}

struct ImageAPI {
    static let clientID = "7a9790ab3e1363b"
    static let clientSecret = "8565cf0093e16a77a9e55effe354d26f42eaaee8"
    static let baseURL = "https://api.imgur.com/3/image"
}

class NetworkManager {
    
    static let shared = NetworkManager(baseURL: URL(string:API.baseURL)!)
    
    let baseURL : URL
    
    var activityIndicator : UIActivityIndicatorView?
    
    typealias JSONDictionary = [String : Any]
    typealias JSONArray = [Any]
    
    typealias SuccessHandler = (_ json : Any) -> ()
    typealias ImageSuccessHandler = (_ image : UIImage) -> ()
    typealias ErrorHandler = (_ error : Error) -> ()
    
    lazy var defaultSession:URLSession = {
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type":"application/json; charset=UTF-8"]
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
    }()
    
    lazy var ephemeralSession:URLSession = {
        let config = URLSessionConfiguration.ephemeral
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()
    
    lazy var backgroundSession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "background")
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()
    
    lazy var customSession:URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 1000, diskCapacity: 10000, diskPath: "/")
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type":"application/json; charset=UTF-8"]
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()
    
    private init(baseURL:URL){
        self.baseURL = baseURL
    }
    
    func getRequest(urlString:String,
                    view:UIView,
                    success: @escaping (SuccessHandler),
                    failure: @escaping (ErrorHandler)) {
        
        showProgressView(in: view)
        
        let url = self.baseURL.appendingPathComponent(urlString)
        
        let urlRequest = URLRequest(url: url)
        
        let task = defaultSession.dataTask(with: urlRequest, completionHandler: { (data,response,error) -> () in
            
            self.hideProgressView()
            
            guard error == nil else {
                failure(error!)
                return
            }
            
            if let aData = data,
                let urlResponse = response as? HTTPURLResponse,
                (200..<300).contains(urlResponse.statusCode) {
                
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: aData, options: [])
                    success(responseJSON)
                }
                catch let error as NSError {
                    failure(error)
                }
            }
        })
        task.resume()
        
    }
    
    func postRequest(urlString: String,
                     params:[String : Any],
                     view:UIView,
                     success:@escaping (SuccessHandler),
                     failure:@escaping (ErrorHandler)) {
        
        showProgressView(in: view)
        
        let url = self.baseURL.appendingPathComponent(urlString)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        urlRequest.networkServiceType = .default
        urlRequest.cachePolicy = .reloadRevalidatingCacheData
        urlRequest.timeoutInterval = 100
        urlRequest.httpShouldHandleCookies = true
        urlRequest.httpShouldUsePipelining = false
        urlRequest.allowsCellularAccess = true
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let task = defaultSession.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> () in
            
            self.hideProgressView()
            
            guard error == nil else {
                failure(error!)
                return
            }
            
            if let aData = data,
            let urlResponse = response as? HTTPURLResponse,
                (200..<300).contains(urlResponse.statusCode) {
                
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: aData, options: [])
                    success(responseJSON)
                }
                catch let error as NSError {
                    failure(error)
                }
            }
            
        })
        
        task.resume()
    }
    
    
    func downloadImageFile(urlString:String,
                           view:UIView,
                           success:@escaping (ImageSuccessHandler),
                           failure:@escaping (ErrorHandler) ) {
    
        let url = URL(string: urlString)
        
        guard let unwrappedURL = url else {
            return
        }
        
        showProgressView(in: view)
        
        let task = defaultSession.downloadTask(with: unwrappedURL, completionHandler: {(localURL, response, error) in
            
            self.hideProgressView()
            
            guard error == nil else {
                failure(error!)
                return
            }
            
            if let fileURL = localURL {
                
                do {
                    let imageData = try Data(contentsOf: fileURL)
                    if let image = UIImage(data: imageData) {
                        success(image)
                    }
                    
                }
                catch let error as NSError {
                    failure(error)
                }
            }
            
        })
        
        task.resume()
    }
    
    func downloadImageInMemory(urlString:String,
                               view:UIView,
                               success: @escaping (ImageSuccessHandler),
                               failure: @escaping (ErrorHandler)) {
        
        let url = URL(string: urlString)
        
        guard let unwrapped = url else {return}
        
        showProgressView(in: view)
        
        let task = defaultSession.dataTask(with: unwrapped, completionHandler: {(data,response,error) in
            
            self.hideProgressView()
            
            guard error == nil else {
                failure(error!)
                return
            }
            
            if let aData = data,
            let urlResponse = response as? HTTPURLResponse,
                (200..<300).contains(urlResponse.statusCode) {
                
                if let image = UIImage(data: aData){
                    success(image)
                }
            }
        })
        
        task.resume()
    }
    
    func showProgressView(in view:UIView) {
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator?.frame = view.bounds
        if let progressBar = activityIndicator{
            view.addSubview(progressBar)
        }
        activityIndicator?.startAnimating()
    }
    
    func hideProgressView() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.removeFromSuperview()
        }
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func createUploadData(boundary:String,
                          params:[String:Any]?,
                          fileName:String,
                          keyName:String,
                          mimeType:String,
                          imageData:Data) -> Data {
        
        var body = Data()
        
        if let parameters = params {
            for (key,value) in parameters {
                body.appendString(str: "--\(boundary)\r\n")
                body.appendString(str: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(str: "\(value)\r\n")
            }
            
            body.appendString(str: "--\(boundary)\r\n")
            body.appendString(str: "Content-Disposition: form-data; name=\"\(keyName)\"; filename=\"\(fileName)\"\r\n")
            body.appendString(str: "Content-Type: \(mimeType)\r\n\r\n")
            body.append(imageData)
            body.appendString(str: "\r\n")
            body.appendString(str: "--\(boundary)\r\n")
            
        }
        return body
    }
    
    
    func uploadData(urlString:String,
                    parameters:[String:Any]?,
                    imageFilename:String,
                    imageKeyName:String,
                    imageMimeType:String,
                    imageData:Data,
                    completionHandler:  ((_ status:Bool,_ result:Any?) -> ())?) {
        
        if let url = URL(string: urlString) {
            let boundary = self.generateBoundaryString()
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.setValue("Client-ID \(ImageAPI.clientID)", forHTTPHeaderField: "Authorization")
            
            let body = self.createUploadData(boundary: boundary, params: parameters, fileName: imageFilename, keyName: imageKeyName, mimeType: imageMimeType, imageData: imageData)
            urlRequest.httpBody = body
            
            URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data,response,error) in
                
                guard error == nil else {
                    DispatchQueue.main.async(execute: { completionHandler?(false,error)} )
                    return
                }
                
                if let aData = data {
                    do {
                        let responseJSON = try JSONSerialization.jsonObject(with: aData, options: [])
                        DispatchQueue.main.async(execute: {completionHandler?(true,responseJSON)})
                    }
                    catch let error as NSError {
                        DispatchQueue.main.async(execute: {completionHandler?(false,error)} )
                    }
                }
                
            }).resume()
        }
        else {
            DispatchQueue.main.async(execute: {completionHandler?(false, nil)})
        }
        
    }
    
}
