//
//  MovieListController.swift
//  PremierSwift
//
//  Created by Richard Pickup on 04/11/2016.
//  Copyright © 2016 Deliveroo. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case errorReturned(error: Error)
    case noDataError
    case responseStatusError(status: Int)
}

enum ParseError: Error {
    case incorrectFormat
    case missingData
}


class MovieListController {
    private let networkErrorString =  NSLocalizedString("There was A Networking Error.  Please check your Connection", comment: "Network Error")
    private let parseErrorString = NSLocalizedString("There was An Error parsing the response data", comment: "Parse Error" )
    
    private let baseURL = "https://api.themoviedb.org/3/"
    private let configService = "configuration"
    private let topMoviesService = "movie/top_rated"
    private let apiKey = "e4f9e61f6ffd66639d33d3dde7e3159b"
    internal var config: Config?
    internal var movies: [Movie] = []
    
    private var urlSession: URLSession!
    init(session: URLSession) {
        self.urlSession = session
        
    }
    
    func numberOfMovies() -> Int {
        return self.movies.count
    }
    
    func movieAtindexPath(indexPath: IndexPath) -> Movie? {
        
        guard self.movies.count > indexPath.row else {
            return nil
        }
        return movies[indexPath.row]
    }
    
    
    
    func getConfigAndData(completion:@escaping (Bool) -> (), fail:@escaping (String)->()) {
        
        guard let url = self.uriForService(serviceName:configService) else {
             fail(self.networkErrorString)
            return
        }
        
        getNetworkData(url: url, completion: { (data) in
            do {
                let JSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                
                guard let config = JSON?["images"] as? [String: Any] else {
                    throw ParseError.incorrectFormat
                    
                }
                
                guard let baseUrl = config["secure_base_url"] as? String,
                    let posterSizes = config["poster_sizes"] as? [String] else {
                        throw ParseError.missingData
                        
                }
                
                self.config = Config()
                self.config?.baseURLString = baseUrl
                self.config?.posterSizes = posterSizes
                
                self.getTopMovies( completion: {
                    (success) in
                    completion(true)
                    }
                ){
                    (failString) in
                    fail(failString)
                }
            }
            catch {
                //json parse error
                fail(self.parseErrorString)
                
            }
        }) { (error) in
            //network error
            fail(self.networkErrorString)
        }
    }
    
    internal func getTopMovies(completion:@escaping (Bool) -> (), fail:@escaping (String)->()) {
        
        guard let url = self.uriForService(serviceName:topMoviesService) else {
             fail(self.networkErrorString)
            return
        }
        getNetworkData(url: url, completion: { (data) in
            
            do {
                let JSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                
                guard let resultsArray =  JSON??["results"] as? [[String: Any]] else {
                    throw ParseError.incorrectFormat
                }
                
                
                let parsedRespone:[Movie?] = resultsArray.map ({
                    (object: [String: Any]) -> Movie? in
                    
                    
                    guard let title = object["title"] as? String,
                        let description = object["overview"] as? String,
                        let resource = object["poster_path"] as? String else {
                            return nil
                    }
                    
                    var mov = Movie()
                    mov.title = title
                    mov.description = description
                    
                    let baseURL = self.config?.baseURLString
                    let imageSizes = self.config?.posterSizes
                    let smallImage = (imageSizes?[0])! as String
                    let urlString = "\(baseURL!)\(smallImage)\(resource)"
                    
                    mov.posterURLString = urlString
                    return mov
                })
                //remove optional nils
                self.movies = parsedRespone.flatMap{$0}
                completion(true)
            }
            catch {
                //json parse error
                fail(self.parseErrorString)
            }
            
            
        }) { (error) in
            //network error
            fail(self.networkErrorString)
        }
    }
    
    private func uriForService(serviceName: String) -> URL? {
        return URL(string: "\(baseURL)\(serviceName)?api_key=\(apiKey)")
    }
    
    private func getNetworkData(url: URL, completion:@escaping (Data) -> (), fail:@escaping (NetworkError)->()) {
      
        
        self.urlSession.dataTask(with: url) { (responseData, response, error) in
            
            guard let data = responseData else {
                fail(.noDataError)
                return
            }
            
            guard error == nil else {
                fail(.errorReturned(error: error!))
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            
            guard statusCode == 200 else {
                fail(.responseStatusError(status: statusCode!))
                return
            }
            
            completion(data)
            
            }.resume()
    }
}
