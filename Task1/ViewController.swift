//
//  ViewController.swift
//  Task1
//
//  Created by Malik Wahaj Ahmed on 03/11/2018.
//  Copyright © 2018 Malik Wahaj Ahmed. All rights reserved.
//

import UIKit

class Manager {
    
    static let sharedManager = Manager()
    
    private init() {
        
    }
    
}


class ViewController: UIViewController,URLSessionDelegate {

    @IBOutlet weak var imageContainer: UIImageView!
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    let imageURLString = "https://images.pexels.com/photos/4198/field-sport-ball-america.jpg"
    
    let apiURL = "https://jsonplaceholder.typicode.com/posts"
    
    
    lazy var currentSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type":"application/json; charset=UTF-8"]
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    lazy var currentBackgroundSession:URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "background")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    lazy var currentEphemeralSession:URLSession = {
        let config = URLSessionConfiguration.ephemeral
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    lazy var customSession:URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 1000, diskCapacity: 10000, diskPath: "/")
        config.httpAdditionalHeaders = ["Accept":"application/json","Authorization":"Bearer 2897217109"]
        config.allowsCellularAccess = false
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    typealias JSONDictionary = [String : Any]
    typealias JSONArray = [Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        activityIndicator.frame = imageContainer.bounds
//        imageContainer.addSubview(activityIndicator)

        
    }

    func doBackgroundTask() {
        
        
    }
    
    func callGetRequest() {
        
        NetworkManager.shared.getRequest(urlString: API.postsURL, view: self.view,
                                         success: {responseJSON in
            print(responseJSON)
        }, failure: {error in
            print(error)
        })
    }
    
    func callPostRequest() {
        
        NetworkManager.shared.postRequest(urlString: API.postsURL, params: ["userID":"11","title":"Malik","body":"Ahmed"], view: self.view, success: {responseJSON in
            
            print(responseJSON)
            
        }, failure: {error in
            print(error)
        })
    }
    
    func downloadImage() {
        
        NetworkManager.shared.downloadImageInMemory(urlString: imageURLString, view: self.view,
                                                    success: {downloadedImage in
                                                        
                                                        DispatchQueue.main.async {
                                                            self.imageContainer.image = downloadedImage
                                                        }
                                                        
        }, failure: {error in
            
        })
    }
    
    func uploadImage() {
        
//        var backgroundTask = UIBackgroundTaskIdentifier.invalid
//        
//        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { () in
//            
//            UIApplication.shared.endBackgroundTask(backgroundTask)
//            backgroundTask = UIBackgroundTaskIdentifier.invalid
//            
//            
//        })
        
        let fileURL = Bundle.main.url(forResource: "football", withExtension: "jpeg")
        let fileData = try! Data(contentsOf: fileURL!)
        
        NetworkManager.shared.uploadData(urlString: ImageAPI.baseURL, parameters: ["title":"Football"], imageFilename: "football.jpeg", imageKeyName: "image", imageMimeType: "image/jpeg", imageData: fileData, completionHandler: {(status, response) in
            print(status)
            if status {
                print(response!)
            }
        })
        
    }
    
    
    func getRequest() {
        
        activityIndicator.startAnimating()
        
        let url = URL(string: apiURL)
        
        guard let unwrappedURL = url else {return}
        
        let request = URLRequest(url: unwrappedURL)
        
        currentSession.dataTask(with: request, completionHandler: { (data,response,error) -> () in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            guard error == nil else {return}
            
            if let aData = data,
                let urlResponse = response as? HTTPURLResponse,
                (200..<299).contains(urlResponse.statusCode) {
                
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: aData, options: []) as? JSONArray
                    print(responseJSON ?? "")
                    
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            
        }).resume()
        
    }
    
    func postRequest() {
        
        activityIndicator.startAnimating()
        
        let url = URL(string: apiURL)
        
        guard let unwrappedURL = url else {return}
        
        var urlRequest = URLRequest(url: unwrappedURL)
        
        urlRequest.cachePolicy = .reloadRevalidatingCacheData
        
        urlRequest.httpMethod = "POST"
        
//        urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        urlRequest.timeoutInterval = 30
        
        urlRequest.httpShouldHandleCookies = true
        
        urlRequest.httpShouldUsePipelining = false
        
        urlRequest.allowsCellularAccess = true
        
        urlRequest.networkServiceType = .default
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: ["userID":"11","title":"Malik","body":"Ahmed"], options: [])
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        currentSession.dataTask(with: urlRequest, completionHandler: {(data,urlResponse,error) -> () in
            
            guard error == nil else {return}
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let aData = data,
                    let response = urlResponse as? HTTPURLResponse,
                    (200..<299).contains(response.statusCode) {
                    
                    do {
                        
                        let responseJSON = try JSONSerialization.jsonObject(with: aData, options: []) as? JSONDictionary
                        print(responseJSON ?? "")
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                    
                }
            }
            
            
        }).resume()
        
    }
    
    func downloadTaskWithURLRequest() {
        
        activityIndicator.startAnimating()
        
        let url = URL(string: imageURLString)
        
        guard let unwrappedURL = url else {return}
        
        let request = URLRequest(url: unwrappedURL)
        
        let task = URLSession.shared.downloadTask(with: request, completionHandler: { (url,urlResponse,error) -> ()  in
            
            DispatchQueue.main.async {
                
                self.activityIndicator.stopAnimating()
                
                if let localURL = url {
                    
                    print(localURL)
                    
                    do {
                        let imageData = try Data(contentsOf: localURL)
                        
                        let image = UIImage(data: imageData)
                        
                        self.imageContainer.image = image
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        })
        
        task.resume()
        
    }
    
    
    func downloadTaskWithURL() {
    
        activityIndicator.startAnimating()
        
        let url = URL(string: imageURLString)
        
        
        guard let unwrappedURL = url else {return}
        
        let task = URLSession.shared.downloadTask(with: unwrappedURL, completionHandler: { (url, urlResponse, error) -> ()  in
            
            DispatchQueue.main.async {
            
                self.activityIndicator.stopAnimating()
            
                if let localURL = url {
                    
                    print(localURL)
                    
                    do {
                        let imageData = try Data(contentsOf: localURL)
                    
                        let image = UIImage(data: imageData)
                    
                        self.imageContainer.image = image
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        })
        
        task.resume()
    }
    
    
    func dataTaskWithURL() {
        
        activityIndicator.startAnimating()
        
        let url = URL(string: imageURLString)
        
        guard let unwrappedURL = url else {return}
        
        URLSession.shared.dataTask(with: unwrappedURL, completionHandler: { (data, response,error) -> () in
        
            guard let data = data , let image = UIImage(data: data) else {return}
            
            DispatchQueue.main.async {
                self.imageContainer.image = image
                self.activityIndicator.stopAnimating()
            }
            
        }).resume()
    }
    
    func dataTaskWithRequest() {
        
        activityIndicator.startAnimating()
        
        let url = URL(string: imageURLString)
        
        guard let unwrappedURL = url else {return}
        
        let request = URLRequest(url: unwrappedURL)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data,response,error) -> () in
            
            guard let aData = data, let image = UIImage(data: aData) else {return}
            
            DispatchQueue.main.async {
                self.imageContainer.image = image
                self.activityIndicator.stopAnimating()
            }
            
        }).resume()
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       
        if challenge.protectionSpace.authenticationMethod == (NSURLAuthenticationMethodServerTrust) {
            
            let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
            let certificate: SecCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
            let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
            
            let cerPath: String = Bundle.main.path(forResource: "example.com", ofType: "cer")!
            let localCertificateData = NSData(contentsOfFile:cerPath)!
            
            
            if (remoteCertificateData.isEqual(localCertificateData as Data) == true) {
                let credential:URLCredential = URLCredential(trust: serverTrust)
                
                challenge.sender?.use(credential, for: challenge)
                
                
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                
            } else {
                
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate
        {
            
            let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
            let PKCS12Data = NSData(contentsOfFile:path)!
            
            
            let identityAndTrust:IdentityAndTrust = self.extractIdentity(certData: PKCS12Data);
            
            let urlCredential:URLCredential = URLCredential(
                identity: identityAndTrust.identityRef,
                certificates: identityAndTrust.certArray as? [AnyObject],
                persistence: URLCredential.Persistence.forSession);
            
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, urlCredential);
            
            
        }
        else
        {
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil);
        }
    }
    
    struct IdentityAndTrust {
        
        var identityRef:SecIdentity
        var trust:SecTrust
        var certArray:AnyObject
    }
    
    func extractIdentity(certData:NSData) -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "xyz"]
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        
        var items : CFArray?
        
        securityError = SecPKCS12Import(PKCS12Data, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!;
                print("\(identityPointer)  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrust = trustPointer as! SecTrust;
                print("\(trustPointer)  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"];
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
            }
        }
        return identityAndTrust;
    }
    
    
}

