//
//  AppDetailVC.swift
//  kakaobank_homework
//
//  Created by Deric on 2018. 5. 2..
//  Copyright © 2018년 Deric. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var usingAge: UILabel!
    @IBOutlet weak var averageRate: UILabel!
    @IBOutlet weak var appIconImage: UIImageView!
    
    let imgArr = [UIImage(named: "test1"), UIImage(named: "test2")]
    var screenshorUrls = [String]()
    
    let itemHeight = CGFloat(470)
    var itemWidth = CGFloat(250)
    let itemSpacing = CGFloat(10)
    
    var currentPage = 0
    
    var appId: String?
    
    var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let api = Network.shared
    var diskCache = DiskCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(self.shadowView)
        self.view.bringSubview(toFront: shadowView)
        desc.adjustsFontSizeToFitWidth = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        appIconImage.layer.cornerRadius = 10
        appIconImage.clipsToBounds = true
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.scrollDirection = .horizontal
        
        collectionView!.collectionViewLayout = layout
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        
        let url = "https://itunes.apple.com/lookup?id=\(appId!)"
        
        self.api.get(url: url, completion: { result in
            
            switch result {
            case .Success(let data):
                DispatchQueue.main.async {
                    self.setup(data: data)
                }
            case .Error(let msg, let code):
                print("Error : \(code) \(msg)")
            }
            
        })
        
    }
    
    func setup(data: Data) {
        
        let json = JSON(data)
        
        if json["resultCount"].int == 0 {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "It is not data", message: "Please try again in a few minutes", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { Void in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alert, animated: true)
            }
            
            return
            
        }
        
        let results = json["results"][0]
        let screenshotUrl = results["screenshotUrls"]
        
        for url in screenshotUrl.array! {
            self.screenshorUrls.append(url.string!)
        }
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            self.shadowView.isHidden = true
            self.desc.text = results["description"].string
            self.appName.text = results["trackCensoredName"].string
            self.company.text = results["artistName"].string

            self.averageRate.text = "평점 \(results["averageUserRating"])"
            self.usingAge.text = "연령 \(results["trackContentRating"])"
            
            self.appName.sizeToFit()
            self.company.sizeToFit()
            self.usingAge.sizeToFit()
            self.averageRate.sizeToFit()
            
            self.scrollViewHeightConstraint.constant = self.contentView.frame.size.height + 64
            
            let iconImageUrl = results["artworkUrl100"].string

            let imageUrl = iconImageUrl!
            let diskWriteName = imageUrl.rename()
            
            if let image = self.diskCache.readImage(key: diskWriteName) {
                self.appIconImage.image = image
            } else {
                self.api.get(url: iconImageUrl!, completion: { result in
                    switch result {
                    case .Success(let data):
                        
                        DispatchQueue.main.async {
                            
                            let iconImage = UIImage(data: data)!
                            self.appIconImage.image = iconImage
                            
                            let type = imageUrl.type()
                            
                            if type == "png" {
                                self.diskCache.diskWrite(image: iconImage, key: diskWriteName, format: .png)
                            } else if type == "jpg" {
                                self.diskCache.diskWrite(image: iconImage, key: diskWriteName, format: .jpeg)
                            } else {
                                self.diskCache.diskWrite(image: iconImage, key: diskWriteName, format: .unknown)
                            }
                            
                        }
                        
                    case .Error(let msg, let code):
                        print("Error : \(code) \(msg)")
                    }
                })
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshorUrls.count
    }
    
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AppDetailCell
    
        let imageUrl = screenshorUrls[indexPath.row]
    
        let diskWriteName = imageUrl.rename()
    
        if let image = diskCache.readImage(key: diskWriteName) {
           cell.screenShot.image = image
        } else {
            api.get(url: imageUrl, completion: { result in
                
                switch result {
                case .Success(let data):
                    DispatchQueue.main.async {
                        cell.screenShot.image = UIImage(data: data)
                    }
                case .Error(let msg, let code):
                    print("Error : \(code) \(msg)")
                }
                
            })
        }
        return cell
    
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = Float(itemWidth + itemSpacing)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(collectionView!.contentSize.width  )
        var newPage = Float(currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? currentPage + 1 : currentPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        
        currentPage = Int(newPage)
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
        
    }


}















