//
//  FlickrService.swift
//  Pixel City
//
//  Created by Jeffrey Santana on 11/30/17.
//  Copyright © 2017 Jefffrey Santana. All rights reserved.
//

import Alamofire
import AlamofireImage

class FlickrService {
    
    static let instance = FlickrService()
    
    //variables
    var imgUrls = [String]()
    var imgArray = [UIImage]()
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, completion: @escaping CompletionHandler) {
        imgUrls.removeAll()
        
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 30)).responseJSON { (response) in
            if response.result.error == nil {
                guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosDictionaryArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photosDictionaryArray {
                    let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    self.imgUrls.append(postUrl)
                }
                completion(true)
            } else {
                completion(false)
                print(response.result.error as Any)
            }
        }
    }
    
    func retrieveImages(completion: @escaping CompletionHandler) {
        imgArray.removeAll()
        
        for url in imgUrls {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                if response.result.error == nil {
                    guard let image = response.result.value else {return}
                    self.imgArray.append(image)
                    NotificationCenter.default.post(name: NOTIF_IMAGE_LOADED, object: nil)
                    
                    if self.imgArray.count == self.imgUrls.count {
                        completion(true)
                    }
                }
            })
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
}
