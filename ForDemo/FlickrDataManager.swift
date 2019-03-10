//
//  FlickrDataManager.swift
//  ForDemo
//
//  Created by Blacktea Liu on 2019/3/10.
//  Copyright © 2019 Jimmy Liu. All rights reserved.
//

import Foundation
import Alamofire

typealias completionHandler = (_ data: Data?, _ error: Error?) -> Void

struct FlickrSearchResult: Codable {
    let photoInfo: PhotoInfo
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case photoInfo = "photos"
        case status = "stat"
    }
}

struct PhotoInfo: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case photos = "photo"
    }
}

struct Photo : Codable, Equatable {
    let farm: Int
    let photoID: String
    let isfamily: Int
    let isfriend: Int
    let ispublic: Int
    let owner: String
    let secret: String
    let server: String
    let title: String
    
    //example  https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    var imageURL: String {
        get {
            return "https://farm" + String(farm) + ".staticflickr.com/" + server + "/" + photoID + "_" + secret + ".jpg"
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case farm
        case photoID = "id"
        case isfamily
        case isfriend
        case ispublic
        case owner
        case secret
        case server
        case title
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.photoID == rhs.photoID
    }
}

class FlickrDataManager {
    
    static let sharedInstance = FlickrDataManager()
    
    var photos: Array<Photo> = []
    var currentPage: Int = 0
    var seatchText: String = ""
    var perPage: String = ""
    
    var favorites: Array<Photo> = []
    
    
    init() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.value(forKey: "ForDemo.favorites") as? Data {
            if let favorites = try? decoder.decode(Array.self, from: data) as Array<Photo> {
                self.favorites = favorites
            }
        }
    }
    
    func parseFlickrSearchResult(data: Data) throws -> FlickrSearchResult  {
        let decoder = JSONDecoder()
        do {
            let flickrSearchResult = try decoder.decode(FlickrSearchResult.self, from: data)
            return flickrSearchResult
        }
        catch {
           throw error
        }
    }
    
    func addPhotos(photos: Array<Photo>) -> Array<Photo> {
        self.photos += photos
        return self.photos
    }
    
    func fetchData(text: String, perPage: String, page: Int = 1, completionHandler: completionHandler? = nil) -> Void {
        let encodingString = text.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=358d460ea376557af7d35b542f1659fb&text=" + encodingString! + "&per_page=" + perPage + "&page=" + String(page) + "&format=json&nojsoncallback=1"
        Alamofire.request(URLString).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let value):

                if let resultDic = value as? NSDictionary {
                    if let status = resultDic["stat"] as? String, status == "ok" {
                        if let data = response.data {
                            if let completionHandler = completionHandler {
                                completionHandler(data, nil)
                            }
                        }
                        else {
                            if let completionHandler = completionHandler {
                                completionHandler(nil, NSError.init(domain: "FlickrDataManager.fetchData.NoData", code: 100, userInfo: nil))
                            }
                        }
                    }
                    else {
                        if let completionHandler = completionHandler {
                            completionHandler(nil, NSError.init(domain: "FlickrDataManager.fetchData.FetchFail", code: 101, userInfo: nil))
                        }
                    }
                    
                }
            case .failure(let error):
                if let completionHandler = completionHandler {
                    completionHandler(nil, error)
                }
            }
        })
    }
    
    func addPhotoToFavorite(photo: Photo) -> Void {
        self.favorites.append(photo)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.favorites) {
            UserDefaults.standard.set(encoded, forKey: "ForDemo.favorites")
        }
    }
    
    func removePhotoToFavorite(photo: Photo) -> Void {
        if let index = self.favorites.index(of:photo) {
            self.favorites.remove(at: index)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.favorites) {
                UserDefaults.standard.set(encoded, forKey: "ForDemo.favorites")
            }
        }
    }
}
