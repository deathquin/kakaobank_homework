//
//  MainCell.swift
//  kakaobank_homework
//
//  Created by Deric on 2018. 5. 2..
//  Copyright © 2018년 Deric. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageBoxView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        icon.layer.cornerRadius = 10
        icon.clipsToBounds = true
        
        imageBoxView.layer.cornerRadius = 10
        imageBoxView.layer.borderColor = UIColor.lightGray.cgColor
        imageBoxView.layer.borderWidth = 0.5
        
        self.selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
