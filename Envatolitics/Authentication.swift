//
//  Authentication.swift
//  Envatolitics
//
//  Created by Andre Podberezniak on 26/08/15.
//  Copyright © 2015 Transparent Ideas. All rights reserved.
//

import Foundation
import OAuthSwift

class Authentication {
    
    static let instance = Authentication()
    
    static let tokenStorage = UserDefaults.standard
    
    fileprivate init(){
        
    }
    
    static var oauth_token:String = "";
    static var refresh_token:String = "";
    static var expirationTime: TimeInterval = 0.0;
    
    static func initialize(){
        if let otoken = Authentication.tokenStorage.value(forKey: constants.storageToken) as? String {
            Authentication.oauth_token = otoken
        }
        if let rtoken = Authentication.tokenStorage.value(forKey: constants.storageRefreshToken) as? String {
            Authentication.refresh_token = rtoken
        }
    }
    
    struct constants {
        static let consumerKey = ""
        static let consumerSecret = ""
        static let authorizeUrl = "https://api.envato.com/authorization"
        static let accessTokenUrl = "https://api.envato.com/token"
        static let storageToken = "storageToken"
        static let storageRefreshToken = "storageRefreshToken"
        static let storageTokenExpirationTimeStamp = "storageTokenExpirationTimeStamp"
    }
    
    
    static func failureHandler(_ error: NSError){
        print(error)
    }
    
    static func authorize(_ success: () -> Void) {
        
        let oauthswift = OAuth2Swift(
            consumerKey:    constants.consumerKey,
            consumerSecret: constants.consumerSecret,
            authorizeUrl:   constants.authorizeUrl,
            accessTokenUrl: constants.accessTokenUrl,
            responseType:   "code"
        )
        
        oauthswift.webViewController = WebViewController()
        
        if let refresh = self.tokenStorage.value(forKey: constants.storageRefreshToken) {
            
            oauthswift.postOAuthAccessTokenByRefresh(refresh as! String, success: {
                credential, response in
                
                self.oauth_token = credential.oauth_token
                self.expirationTime = ( Date().timeIntervalSince1970 ) + 3600
                self.tokenStorage.setValue(self.oauth_token, forKey: constants.storageToken)
                self.tokenStorage.setValue(self.expirationTime, forKey: constants.storageTokenExpirationTimeStamp)
                self.tokenStorage.synchronize()
                success()
                }, failure: failureHandler)
        } else {
            oauthswift.authorizeWithCallbackURL( URL(string: "oauth-swift://oauth-callback/envato" )!,
                scope: "",
                state:"", success: {
                    credential, response in
                    
                    self.oauth_token = credential.oauth_token
                    self.refresh_token = credential.refresh_token
                    self.expirationTime = ( Date().timeIntervalSince1970 ) + 3600
                    self.tokenStorage.setValue(self.oauth_token, forKey: constants.storageToken)
                    self.tokenStorage.setValue(self.refresh_token, forKey: constants.storageRefreshToken)
                    self.tokenStorage.setValue(self.expirationTime, forKey: constants.storageTokenExpirationTimeStamp)
                    self.tokenStorage.synchronize()
                    success()
                }, failure: failureHandler)
        }
        
        
        
    }
    
    
}
