//
//  AiaModel.swift
//  Aiakos
//
//  Created by Zhu Shengqi on 12/5/15.
//  Copyright © 2015 DSoftware. All rights reserved.
//

import Foundation




public class AiaModel: NSObject {
    public required override init() {
        super.init()
    }
    
}


public extension AiaModel {
    
    convenience init(jsonData: NSData) throws {
        
        do {
            self.init()

//            
//            let jsonObj = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
//            
//            var propertyMapping: DictionaryLiteral<String, String>
//            if let customMappingObj = self as? AiaJSONCustomPropertyMapping {
//                propertyMapping = customMappingObj.customPropertyMapping
//            } else {
//                propertyMapping = [:]
//                
//                let mirror = Mirror(reflecting: self)
//            }
//            
//            if let jsonArray = jsonObj as? [AnyObject] {
//                
//            }
//            
//            if let jsonDictionary = jsonObj as? [String: AnyObject] {
//                
//            }
//            
//            // Actually, the following error would never be throwed, but in case NSJSONSerialization fuck up..
//            throw AiaJSONSerializationError.InvalidBaseContainerType
//        } catch {
//            throw error
        }
        
        
    }
    
}