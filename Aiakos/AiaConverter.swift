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


public class AiaConverter: AiaJSONConverter {
    static var jsonPropertyMappingPool: [String: [String: String]] = [:]
    
}

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
        throw AiaJSONSerializationError.FunctionNotImplementedYet
        
        //        let model = modelType.init()
        //
        //
        //        return model
    }
    
    private static func modelOfType(modelType: AiaModel.Type, fromJSONArrayData jsonData: NSData) throws -> AiaModel {
        throw AiaJSONSerializationError.FunctionNotImplementedYet
        
        //        do {
        //            if let jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [AnyObject] {
        //                let model = try modelOfType(modelType, fromJSONArray: jsonArray)
        //                return model
        //            } else {
        //                throw AiaJSONSerializationError.InvalidJSONContainerStructure
        //            }
        //        } catch {
        //            throw error
        //        }
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
        
        
        var propertyMapping: [String: String]
        
        if let cachedMapping = AiaConverter.jsonPropertyMappingPool["\(modelType)"] {
            propertyMapping = cachedMapping
        } else {
            if let customPropertyMappingObj = model as? AiaJSONCustomPropertyMapping {
                propertyMapping = customPropertyMappingObj.dynamicType.customPropertyMapping
            } else {
                propertyMapping = [:]
                
                let mirror = Mirror(reflecting: model)
                for child in mirror.children {
                    if let propertyName = child.label {
                        propertyMapping[propertyName] = propertyName
                    }
                }
            }
            
            AiaConverter.jsonPropertyMappingPool["\(modelType)"] = propertyMapping
        }
        
        for (propertyName, mappedJSONKey) in propertyMapping {
            if let value = jsonDictionary[mappedJSONKey] {
                model.setValue(value, forPropertyName: propertyName)
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



