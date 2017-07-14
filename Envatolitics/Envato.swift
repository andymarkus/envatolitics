//
//  Envato.swift
//  Envatolitics
//
//  Created by Andre Podberezniak on 31/08/15.
//  Copyright © 2015 Transparent Ideas. All rights reserved.
//

import Foundation

class Envato{
    
    class func nsdataToJSON(_ data: Data) -> AnyObject? {
        do  {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return jsonData
        } catch {
            return "Error"
        }
    }
    
    class func getData(_ show : (AnyObject)->Void ){
        let token = Authentication.oauth_token
        let url = URL(string: "https://api.envato.com/v1/market/private/user/account.json")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {
            (response, data, error) in
            
            if let receivedData = self.nsdataToJSON(data!) {
                
                if let receivedDataDictionary = receivedData as? Dictionary<String, String>{
                    if receivedDataDictionary["error_description"] != "" {
                        print(receivedDataDictionary["error_description"])
                    }
                } else {
                    show(receivedData)
                }
            }
            
        }
    }
    
    class func getSales(_ success : (AnyObject) -> Void){
        let token = Authentication.oauth_token
        let url = URL(string: "https://api.envato.com/v2/market/author/sales")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {
            (response, data, error) in
            
            if let receivedData = self.nsdataToJSON(data!) {
                
                if let receivedDataDictionary = receivedData as? Dictionary<String, String>{
                    if receivedDataDictionary["error_description"] != "" {
                        print(receivedDataDictionary["error_description"])
                    }
                } else {
                    success(receivedData)
                }
            }
            
        }
    }
    
    class func getSalesByMonth(_ success : (AnyObject) -> Void){
        let token = Authentication.oauth_token
        let url = URL(string: "https://api.envato.com/v1/market/private/user/earnings-and-sales-by-month.json")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {
            (response, data, error) in
            
            if let receivedData = self.nsdataToJSON(data!) {
                
                if let receivedDataDictionary = receivedData as? Dictionary<String, String>{
                    if receivedDataDictionary["error_description"] != "" {
                        print(receivedDataDictionary["error_description"])
                    }
                } else {
                    success(receivedData)
                }
            }
            
        }
    }
    
}
