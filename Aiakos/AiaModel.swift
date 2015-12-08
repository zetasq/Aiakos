//
//  AiaModel.swift
//  Aiakos
//
//  Created by Zhu Shengqi on 12/5/15.
//  Copyright © 2015 DSoftware. All rights reserved.
//

import Foundation


public class AiaModel: NSObject, NSCoding {
    public required override init() {
        super.init()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let propertyMapping = AiaConverter.propertyMappingForModel(self)
        
        for (propertyName, mappedJSONKey) in propertyMapping {
            if let decodedObject = aDecoder.decodeObjectForKey(mappedJSONKey) {
                self.setValue(decodedObject, forPropertyName: propertyName)
            }
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        let propertyMapping = AiaConverter.propertyMappingForModel(self)
        for (propertyName, mappedJSONKey) in propertyMapping {
            if let propertyValue = self.valueForKey(propertyName) {
                aCoder.encodeObject(propertyValue, forKey: mappedJSONKey)
            }
        }
    }
    
    // MARK: - AiaJSONConvertible
    public class var modelContainerPropertyAnnotation: [String: AiaModelContainerPropertyType]? {
        return nil
    }
}


public enum AiaModelContainerPropertyType {
    case ArrayOfModel(AiaModel.Type) // var XXXproperty = [AiaModel]
    case DictionaryOfModel(AiaModel.Type) // var XXXproperty = [String: AiaModel]
}

extension AiaModel: AiaJSONConvertible {
    
    // MARK: - AiaJSONSerializable
    func jsonObjectForPropertyName(propertyName: String) -> AnyObject? {
        guard let propertyValue = self.valueForKey(propertyName) else {
            return nil
        }
        
        // check if custom model provides annotation for model container: [AiaModel] and [String: AiaModel]
        if let annotation = self.dynamicType.modelContainerPropertyAnnotation {
            if let containerPropertyType = annotation[propertyName] {
                do {
                    switch containerPropertyType {
                    case .ArrayOfModel(_):
                        if let modelArray = propertyValue as? [AiaModel] {
                            let jsonArray = try AiaConverter.jsonArrayFromModelArray(modelArray)
                            return jsonArray
                        }
                    case .DictionaryOfModel(_):
                        if let modelDictionary = propertyValue as? [String: AiaModel] {
                            let jsonDictionary = try AiaConverter.jsonDictionaryFromModelDictionary(modelDictionary)
                            return jsonDictionary
                        }
                    }
                } catch {
                    #if DEBUG
                        debugPrint(error)
                    #endif
                }
                
                return nil
            }
        }
        
        // Single Object
        if let jsonString = propertyValue as? String {
            return jsonString
        }
        
        if let jsonNumber = propertyValue as? NSNumber {
            return jsonNumber
        }
        
        if let propertyModel = propertyValue as? AiaModel {
            do {
                let jsonDictionary = try AiaConverter.jsonDictionaryFromModel(propertyModel)
                return jsonDictionary
            } catch {
                #if DEBUG
                    print("Error in serializing property: <\(propertyName)> of model: \(propertyModel.dynamicType)")
                #endif
            }
            
            return nil
        }
        
        
        // Array Object
        if let jsonStringArray = propertyValue as? [String] {
            return jsonStringArray
        }
        
        if let jsonNumberArray = propertyValue as? [NSNumber] {
            return jsonNumberArray
        }
        
        // Dictionary Object
        if let jsonStringDictionary = propertyValue as? [String: String] {
            return jsonStringDictionary
        }
        
        if let jsonNumberDictionary = propertyValue as? [String: NSNumber] {
            return jsonNumberDictionary
        }
        
        return nil
    }
    
    // MARK: - AiaJSONDeserializable
    func setValue(value: AnyObject, forPropertyName propertyName: String) {
        
        guard let oldValue = self.valueForKey(propertyName) else {
            return
        }
        
        // check if custom model provides annotation for model container: [AiaModel] and [String: AiaModel]
        if let annotation = self.dynamicType.modelContainerPropertyAnnotation {
            if let containerPropertyType = annotation[propertyName] {
                do {
                    switch containerPropertyType {
                    case .ArrayOfModel(let elementModelType):
                        if let jsonArrayObject = value as? [AnyObject] {
                            let newModelArray = try AiaConverter.modelArrayOfType(elementModelType, fromJSONArray: jsonArrayObject)
                            self.setValue(newModelArray, forKey: propertyName)
                        }
                    case .DictionaryOfModel(let valueModelType):
                        if let jsonDictionaryObject = value as? [String: AnyObject] {
                            let newModelDictionary = try AiaConverter.modelDictionaryOfType(valueModelType, fromJSONDictionary: jsonDictionaryObject)
                            self.setValue(newModelDictionary, forKey: propertyName)
                        }
                    }
                } catch {
                    #if DEBUG
                        debugPrint(error)
                    #endif
                }
                return
            }
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



protocol AiaJSONConvertible: AiaJSONSerializable, AiaJSONDeserializable {
    static var modelContainerPropertyAnnotation: [String: AiaModelContainerPropertyType]? { get }
}

protocol AiaJSONSerializable {
    func jsonObjectForPropertyName(propertyName: String) -> AnyObject?
}

protocol AiaJSONDeserializable {
    func setValue(value: AnyObject, forPropertyName propertyName: String)
}
