//
//  network.swift
//  kakaobank_homework
//
//  Created by Deric on 2018. 5. 3..
//  Copyright © 2018년 Deric. All rights reserved.
//

import Foundation
import UIKit


enum Result<T> {
    case Success(T)
    case Error(String, Int)
}

class Network {
    
    let InvalidURLCode = 999
    let NoDataCode = 998
    
    static let shared = Network()
    
    private init() {}
    
    func get(url: String, completion:@escaping (Result<Data>) -> Void) {
        
        guard NSURL(string: url) != nil else {
            return completion(.Error("Invalid URL", InvalidURLCode))
        }
        
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
            
            guard error == nil else {
                return completion(.Error(error!.localizedDescription, self.InvalidURLCode))
            }
            
            guard let data = data else {
                return completion(.Error("No data returned", self.NoDataCode))
            }
            
            completion(.Success(data))
            
        }).resume()
        
    }
    
    
}





