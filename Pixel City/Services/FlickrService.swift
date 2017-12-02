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
    var photoArray = [Photo]()
    
    //(_ completionHandler: @escaping (_ typingUsers: [String: String]) -> Void) (_ Success: Bool) -> ()
    func retreivePhotos(forAnnotation annotation: DroppablePin, completion: @escaping (_ Success: Bool) -> ()) {
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: NUMBER_OF_PHOTOS_TO_VIEW)).responseJSON { (response) in
            if response.result.error == nil {
                guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosDictionaryArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photosDictionaryArray {
                    let imgUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    let title = "\(photo["title"]!)"
                    
                    Alamofire.request(imgUrl).responseImage(completionHandler: { (response) in
                        if response.result.error == nil {
                            guard let image = response.result.value else {return}
                            let foto = Photo(imgUrl: imgUrl, img: image, title: title)
                            self.photoArray.append(foto)
                            NotificationCenter.default.post(name: NOTIF_IMAGE_LOADED, object: nil)
                            //make completionHandler into a notification when done to stop spinner and reloadData
                            if self.photoArray.count == NUMBER_OF_PHOTOS_TO_VIEW {
                                NotificationCenter.default.post(name: NOTIF_DOWNLOAD_COMPLETE, object: nil)
                            }
                        }
                    })
                }
                completion(true)
            } else {
                completion(false)
                print(response.result.error as Any)
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    
    func clearArrays() {
        photoArray.removeAll()
    }
}
