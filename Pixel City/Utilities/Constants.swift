//
//  Constants.swift
//  Pixel City
//
//  Created by Jeffrey Santana on 11/29/17.
//  Copyright © 2017 Jefffrey Santana. All rights reserved.
//

import Foundation

//Flickr Access
let API_KEY = "&api_key=\(MY_KEY)"
let BASE_URL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"

let NUMBER_OF_PHOTOS_TO_VIEW = 40

//Reuse Identifiers
let DROPPABLE_PIN = "droppablePin"
let PHOTO_CELL = "photoCell"
let POPVC = "PopVC"

// Notification Constants
let NOTIF_IMAGE_LOADED = Notification.Name("notifImageLoaded")
let NOTIF_DOWNLOAD_COMPLETE = Notification.Name("notifDownloadComplete")

func flickrUrl(forApiKey: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url = "\(BASE_URL)\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    return url
}


