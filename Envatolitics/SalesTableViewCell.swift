//
//  SalesTableViewCell.swift
//  Envatolitics
//
//  Created by Andre Podberezniak on 14/09/15.
//  Copyright © 2015 Transparent Ideas. All rights reserved.
//

import UIKit

class SalesTableViewCell: UITableViewCell {
    
    var sale:EnvatoSale?{
        didSet{
            updateUI()
        }
    }
    
    func getDataFromUrl(_ urL:URL, completion: ((data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL, completionHandler: { (data, response, error) in
            completion(data: data)
            }) .resume()
    }
    
    func downloadImage(_ url:URL){
        print(url)
        getDataFromUrl(url) { data in
            DispatchQueue.main.async {
                if let imageData = data {
                    print(imageData.hashValue)
                    self.thumb.image = UIImage(data: imageData)
                } 
            }
        }
    }
    
   
    @IBOutlet weak var thumb: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    func updateUI(){
        self.name.text = sale!.item.name
        downloadImage(sale!.item.thumbnailUrl)
    }    
}
