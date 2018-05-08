//
//  imageNameHelper.swift
//  kakaobank_homework
//
//  Created by Deric on 2018. 5. 7..
//  Copyright © 2018년 Deric. All rights reserved.
//

import Foundation

extension String {
    
    func rename() -> String {
        let diskWriteNameSplit = self.components(separatedBy: "/")
        
        let diskWriteName = "\(diskWriteNameSplit[diskWriteNameSplit.count-3])\(diskWriteNameSplit[diskWriteNameSplit.count-2])\(diskWriteNameSplit[diskWriteNameSplit.count-1])"
        
        return diskWriteName
    }
    
    func type() -> String {
        let split = self.components(separatedBy: ".")
        let type = split[split.count-1]

        return type
    }
    
    
}
