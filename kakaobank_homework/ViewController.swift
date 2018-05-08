//
//  ViewController.swift
//  kakaobank_homework
//
//  Created by Deric on 2018. 5. 2..
//  Copyright © 2018년 Deric. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var mainST = [MainST]()
    
    var api = Network.shared
    
    var diskCache = DiskCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.navigationItem.title = "Content"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let urlString = "https://itunes.apple.com/kr/rss/topfreeapplications/limit=50/genre=6015/json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else {
                return
            }

            let json = JSON(data)
            let feed = json["feed"]
            
            let entryData = feed["entry"]
            
            if let entry = entryData.array {
                
                for info in entry {
                    
                    let label = info["im:name"]["label"].string
                    let summary = info["summary"]["label"].string
                    let iconUrl = info["im:image"][2]["label"].string
                    let appId = info["id"]["attributes"]["im:id"].string
                    
                    self.mainST.append(MainST(label: label, iconUrl: iconUrl, summary: summary, appId: appId))
                    
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
        }
        .resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainST.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let uvc = self.storyboard!.instantiateViewController(withIdentifier: "appdetailvc") as? AppDetailVC {
            uvc.appId = self.mainST[indexPath.row].appId
            self.navigationController?.pushViewController(uvc, animated: true);
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MainCell

        let info = mainST[indexPath.row]
        cell.name.text = info.label
        
        let imageUrl = info.iconUrl!
        let diskWriteName = imageUrl.rename()
        
        if let image = diskCache.readImage(key: diskWriteName) {
            cell.icon.image = image
        } else {
            api.get(url: info.iconUrl!, completion: { result in
                
                switch result {
                case .Success(let data):
                    DispatchQueue.main.async {
                        let iconImage = UIImage(data: data)!
                        cell.icon.image = iconImage
                        
                        let split = imageUrl.components(separatedBy: ".")
                        let type = split[split.count-1]

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
        
        return cell
        
    }
}


