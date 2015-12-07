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


extension AiaModel: AiaJSONSerializable, AiaJSONDeserializable {
    // MARK: - AiaJSONSerializable
    var mappedJSON: [String: AnyObject] {
        return [:]
    }
    
    // MARK: - AiaJSONDeserializable
    func setValue(value: AnyObject, forPropertyName propertyName: String) {
        guard let oldValue = self.valueForKey(propertyName) else {
            return
        }
        
        
        // Single Object
        if let _ = oldValue as? String {
            if let stringObject = value as? String {
                self.setValue(stringObject, forKey: propertyName)
            }
            return
        }
        
        if let _ = oldValue as? NSNumber {
            if let numberObject = value as? NSNumber {
                self.setValue(numberObject, forKey: propertyName)
            }
            return
        }
        
        if let propertyModel = oldValue as? AiaModel {
            do {
                // Todo: due to Swift 2.1 poor support for reflection on collectionType, collection-type model is not supported
                if let jsonDictionaryObject = value as? [String: AnyObject] {
                    let newPropertyModel = try AiaConverter.modelOfType(propertyModel.dynamicType, fromJSONDictionary: jsonDictionaryObject)
                    self.setValue(newPropertyModel, forKey: propertyName)
                }
            } catch {
                #if DEBUG
                    print("Error in deserializing property: <\(propertyName)> of model: \(modelType)")
                #endif
            }
            
            return
        }
        
        
        // Array Object
        if let _ = oldValue as? [String] {
            if let stringArray = value as? [String] {
                self.setValue(stringArray, forKey: propertyName)
            }
            
            return
        }
        
        if let _ = oldValue as? [NSNumber] {
            if let numberArray = value as? [NSNumber] {
                self.setValue(numberArray, forKey: propertyName)
            }
            
            return
        }
        
        // Dictionary Object
        if let _ = oldValue as? [String: String] {
            if let strstrDictionary = value as? [String: String] {
                self.setValue(strstrDictionary, forKey: propertyName)
            }
            
            return
        }
        
        if let _ = oldValue as? [String: NSNumber] {
            if let strnbrDictionary = value as? [String: NSNumber] {
                self.setValue(strnbrDictionary, forKey: propertyName)
            }
            
            return
        }
    }
}

protocol AiaJSONSerializable {
    var mappedJSON: [String: AnyObject] { get }
}

protocol AiaJSONDeserializable {
    func setValue(value: AnyObject, forPropertyName propertyName: String)
}
