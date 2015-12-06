//
//  AiaConverter.swift
//  Aiakos
//
//  Created by Zhu Shengqi on 12/6/15.
//  Copyright © 2015 DSoftware. All rights reserved.
//

import Foundation

public enum AiaJSONSerializationError: ErrorType {
    case InvalidJSONContainerStructure
    case InvalidJSONArrayElementStructure
    case InvalidJSONDictionaryValueStructure
    case FunctionNotImplementedYet
}

public class AiaConverter: AiaJSONConverter {}

public protocol AiaJSONConverter: AiaJSONSerializer, AiaJSONDeserializer {}

// MARK: - AiaJSONSerializer
public protocol AiaJSONSerializer {
    
}


// MARK: - AiaJSONDeserializer
public protocol AiaJSONDeserializer {
//    static func modelOfType(modelType: AiaModel.Type, fromJSONArray jsonArray: [AnyObject]) throws -> AiaModel
//    static func modelOfType(modelType: AiaModel.Type, fromJSONArrayData jsonData: NSData) throws -> AiaModel
    
    
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArray jsonArray: [AnyObject]) throws -> [AiaModel]
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArrayData jsonData: NSData) throws -> [AiaModel]
    
    
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionary jsonDictionary: [String: AnyObject]) throws -> [String: AiaModel]
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> [String: AiaModel]
    
    
    static func modelOfType(modelType: AiaModel.Type, fromJSONDictionary jsonDictionary: [String: AnyObject]) throws -> AiaModel
    static func modelOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> AiaModel
}

public extension AiaJSONDeserializer {
    // The following two methods is set private due to Swift's immature reflection API
    private static func modelOfType(modelType: AiaModel.Type, fromJSONArray jsonArray: [AnyObject]) throws -> AiaModel {
        let model = modelType.init()
        
        // TODO: Add this functionality when the reflection API improves
        
        return model
    }
    
    private static func modelOfType(modelType: AiaModel.Type, fromJSONArrayData jsonData: NSData) throws -> AiaModel {
        do {
            if let jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [AnyObject] {
                let model = try modelOfType(modelType, fromJSONArray: jsonArray)
                return model
            } else {
                throw AiaJSONSerializationError.InvalidJSONContainerStructure
            }
        } catch {
            throw error
        }
    }
    
    
    
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArray jsonArray: [AnyObject]) throws -> [AiaModel] {
        var models: [AiaModel] = []
        
        for jsonObject in jsonArray {
            if let jsonDictionary = jsonObject as? [String: AnyObject] {
                do {
                    let model = try modelOfType(modelType, fromJSONDictionary: jsonDictionary)
                    models.append(model)
                } catch {
                    throw AiaJSONSerializationError.InvalidJSONArrayElementStructure
                }
            }
        }
        
        return models
    }
    
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArrayData jsonData: NSData) throws -> [AiaModel] {
        do {
            if let jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [AnyObject] {
                let models = try modelArrayOfType(modelType, fromJSONArray: jsonArray)
                return models
            } else {
                throw AiaJSONSerializationError.InvalidJSONContainerStructure
            }
        } catch {
            throw error
        }
    }
    
    
    
    
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionary jsonDictionary: [String: AnyObject]) throws -> [String: AiaModel] {
        var modelDic: [String: AiaModel] = [:]
        for (key, value) in jsonDictionary {
            if let valueArray = value as? [AnyObject] {
                do {
                    let model = try modelOfType(modelType, fromJSONArray: valueArray)
                    modelDic[key] = model
                } catch {
                    throw AiaJSONSerializationError.InvalidJSONDictionaryValueStructure
                }
            }
        }
        
        return modelDic
    }
    
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> [String: AiaModel] {
        do {
            if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject] {
                let modelDic = try modelDictionaryOfType(modelType, fromJSONDictionary: jsonDictionary)
                return modelDic
            } else {
                throw AiaJSONSerializationError.InvalidJSONContainerStructure
            }
        } catch {
            throw error
        }
    }
    
    
    
    static func modelOfType(modelType: AiaModel.Type, fromJSONDictionary jsonDictionary: [String: AnyObject]) throws -> AiaModel {
        let model: AiaModel
        
        if let customDeserializable = modelType as? AiaJSONCustomDeserializable.Type {
            model = customDeserializable.customTypeForJSONDeserializationFromJSONDictionary(jsonDictionary).init()
        } else {
            model = modelType.init()
        }
        
        if let customPropertyMapping = model as? AiaJSONCustomPropertyMapping {
            
        } else {
            let mirror = Mirror(reflecting: model)
            for child in mirror.children {
                if let propertyName = child.label {
                    

                    // Single Object
                    if let _ = child.value as? String {
                        if let stringObject = jsonDictionary[propertyName] as? String {
                            model.setValue(stringObject, forKey: propertyName)
                        }
                        continue
                    }
                    
                    if let _ = child.value as? NSNumber {
                        if let numberObject = jsonDictionary[propertyName] as? NSNumber {
                            model.setValue(numberObject, forKey: propertyName)
                        }
                        continue
                    }
                    
                    if let propertyModel = child.value as? AiaModel {
                        do {
                            if let jsonArrayObject = jsonDictionary[propertyName] as? [AnyObject] {
                                let newPropertyModel = try modelOfType(propertyModel.dynamicType, fromJSONArray: jsonArrayObject)
                                model.setValue(newPropertyModel, forKey: propertyName)
                                
                            } else if let jsonDictionaryObject = jsonDictionary[propertyName] as? [String: AnyObject] {
                                let newPropertyModel = try modelOfType(propertyModel.dynamicType, fromJSONDictionary: jsonDictionaryObject)
                                model.setValue(newPropertyModel, forKey: propertyName)
                                
                            }
                        } catch {
                            #if DEBUG
                                print("Error in deserializing property: <\(propertyName)> of model: \(modelType)")
                            #endif
                        }
                        
                        continue
                    }
                    
                    
                    // Array Object
                    if let _ = child.value as? [String] {
                        if let stringArray = jsonDictionary[propertyName] as? [String] {
                            model.setValue(stringArray, forKey: propertyName)
                        }
                        continue
                    }
                    
                    if let _ = child.value as? [NSNumber] {
                        if let numberArray = jsonDictionary[propertyName] as? [NSNumber] {
                            model.setValue(numberArray, forKey: propertyName)
                        }
                        continue
                    }
                    
                    if let propertyArrayModel = child.value as? [AiaModel] {
                        do {
                            let elementModelType = propertyArrayModel.dynamicType.Generator.Element().dynamicType
                            
                            if let subJsonArray = jsonDictionary[propertyName] as? [AnyObject] {
                                let newPropertyArrayModel = try modelArrayOfType(elementModelType, fromJSONArray: subJsonArray)
                                model.setValue(newPropertyArrayModel, forKey: propertyName)
                            }
                        } catch {
                            #if DEBUG
                                print("Error in deserializing property: <\(propertyName)> of model: \(modelType)")
                            #endif
                        }
                        
                        continue
                    }
                    
                    // Dictionary Object
                    if let _ = child.value as? [String: String] {
                        if let strstrDictionary = jsonDictionary[propertyName] as? [String: String] {
                            model.setValue(strstrDictionary, forKey: propertyName)
                        }
                        continue
                    }
                    
                    if let _ = child.value as? [String: NSNumber] {
                        if let strnbrDictionary = jsonDictionary[propertyName] as? [String: NSNumber] {
                            model.setValue(strnbrDictionary, forKey: propertyName)
                        }
                        continue
                    }
                    
                    if let propertyDictionaryModel = child.value as? [String: AiaModel] {
                        do {
                            let valueModelType = propertyDictionaryModel.dynamicType.Value().dynamicType
                            
                            if let subJsonDictionary = jsonDictionary[propertyName] as? [String: AnyObject] {
                                let newPropertyDictionaryModel = try modelDictionaryOfType(valueModelType, fromJSONDictionary: subJsonDictionary)
                                model.setValue(newPropertyDictionaryModel, forKey: propertyName)
                            }
                        } catch {
                            #if DEBUG
                                print("Error in deserializing property: <\(propertyName)> of model: \(modelType)")
                            #endif
                        }
                    }
                }
            }
        }
        
        return model
    }
    
    static func modelOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> AiaModel {
        do {
            if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject] {
                let model = try modelOfType(modelType, fromJSONDictionary: jsonDictionary)
                return model
            } else {
                throw AiaJSONSerializationError.InvalidJSONContainerStructure
            }
        } catch {
            throw error
        }
    }
}



