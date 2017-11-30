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
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, completion: @escaping CompletionHandler) {
        imgUrls.removeAll()
        
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
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
}
