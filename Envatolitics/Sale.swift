//
//  Sale.swift
//  Envatolitics
//
//  Created by Andre Podberezniak on 15/09/15.
//  Copyright © 2015 Transparent Ideas. All rights reserved.
//

import Foundation

class EnvatoItem
{
    
    internal var id:Int = 0
    internal var name:String = ""
    internal var rating:Float = 0.0
    internal var thumbnailUrl:URL = URL()
    
}

class EnvatoSalesByMonth
{
    internal var month:    Date = Date()
    internal var sales:    String = ""
    internal var earnings: String = ""
    
    init(data: AnyObject){
        if let sale = data as? Dictionary<String, AnyObject>{
            
            let dateFormatter = DateFormatter()
           
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            dateFormatter.locale = Locale.init(localeIdentifier: "en_US_POSIX")
            if let datePurchased = (sale["month"] as? String){
                if let dd = dateFormatter.date(from: datePurchased) {
                    self.month = dd
                }
            }
            self.sales = (sale["sales"] as? String)!
            self.earnings = (sale["earnings"] as? String)!
        }
    }
    
}

class EnvatoSale
{
    
    internal var amount:String = ""
    internal var soldAt:Date = Date()
    internal var supportAmmount:String = ""
    internal var item:EnvatoItem = EnvatoItem()
    
    
    init(data:AnyObject) {
        
        if let sale = data as? Dictionary<String, AnyObject>{
            
            self.amount = (sale["amount"] as? String)!
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
            
            if let datePurchased = (sale["sold_at"] as? String){
                if let dd = dateFormatter.date(from: datePurchased) {
                    self.soldAt = dd
                }
                
            }
            
            self.supportAmmount = (sale["support_amount"] as? String)!
            
            if let item = sale["item"] as? Dictionary<String, AnyObject>{
                self.item.id = (item["id"] as? Int)!
                self.item.name = (item["name"] as? String)!
                if let rating = item["rating"] as? Dictionary<String, AnyObject>{
                    self.item.rating = (rating["rating"] as? Float)!
                }
                
                
                if let thumbURL = item["thumbnail_url"] as? String{
                    
                    self.item.thumbnailUrl = URL(fileURLWithPath: thumbURL.replacingOccurrences(of: "https", with: "http"))
                }
                
                
                
            }
            
        } else {
            print("Wrong format")
                
        }
    }
    
}
