//
//  DiskCache.swift
//  kakao_homework
//
//  Created by Deric on 2018. 4. 12..
//  Copyright © 2018년 Deric. All rights reserved.
//

import Foundation
import UIKit

enum ImageType {
    case unknown, png, jpeg
}

class DiskCache {
    
    var diskCachePath: String
    var diskCacheName = "kakaobank_homework"
    
    let diskCachePrefix = "dev.kakaobank-homework"
    let ioQueuePrefix = "dev.kakaobank-homework-queue"
    
    let wQueue: DispatchQueue
    let fileManager: FileManager
    
    let memoryCache = NSCache<NSString, UIImage>()
    
    init() {
        
        diskCachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        diskCachePath = (diskCachePath as NSString).appendingPathComponent(diskCachePrefix + diskCacheName)
        
        wQueue = DispatchQueue(label: ioQueuePrefix + diskCacheName)
        fileManager = FileManager()
        
    }
    
    func diskWrite(image: UIImage, key: String, format: ImageType) {
        
        var data: Data? = nil
        
        if format == .png {
            data = UIImagePNGRepresentation(image)
        } else {
            data = UIImageJPEGRepresentation(image, 1)
        }
        
        if let data = data {
            memoryCache.setObject(image, forKey: key as NSString)
            diskWrite(data: data, key: key)
        }
        
    }
    
    func diskWrite(data: Data, key: String) {
        
        wQueue.async {

            if self.fileManager.fileExists(atPath: self.diskCachePath) == false {
                do {
                    try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error while createing cache folder")
                }
            }

            self.fileManager.createFile(atPath: self.cachePath(key: key), contents: data, attributes: nil)

        }
        
    }
    
    func readImage(key: String) -> UIImage? {
        
        if let cacheImage = memoryCache.object(forKey: key as NSString) {
            return cacheImage
        }
        
        if  let data = self.fileManager.contents(atPath: cachePath(key: key)) {
            return UIImage(data: data, scale: 1.0)
        }
        
        return nil
        
    }
    
    func cachePath(key: String) -> String {
        
        let fileName = key
        return (diskCachePath as NSString).appendingPathComponent(fileName)
        
    }
    
}











