//
//  AiaConverter.swift
//  Aiakos
//
//  Created by Zhu Shengqi on 12/6/15.
//  Copyright © 2015 DSoftware. All rights reserved.
//

import Foundation

public enum AiaJSONConversionError: ErrorType {
    case InvalidJSONArrayStructure
    case InvalidJSONDictionaryStructure
    case ModelSerializationFailure
}


public class AiaConverter: AiaJSONConverter {
    static var cachedPropertyKeyMapping: [String: [String: String]] = [:]
}

public protocol AiaJSONConverter: AiaJSONSerializer, AiaJSONDeserializer {}

// MARK: - AiaJSONSerializer
public protocol AiaJSONSerializer {
    
    static func jsonArrayFromModelArray(modelArray: [AiaModel]) throws -> [AnyObject]
    static func jsonArrayDataFromModelArray(modelArray: [AiaModel]) throws -> NSData
    
    
    static func jsonDictionaryFromModelDictionary(modelDictionary: [String: AiaModel]) throws -> [String: AnyObject]
    static func jsonDictionaryDataFromModelDictionary(modelDictionary: [String: AiaModel]) throws -> NSData
    
    static func jsonDictionaryFromModel(model: AiaModel) throws -> [String: AnyObject]
    static func jsonDictionaryDataFromModel(model: AiaModel) throws -> NSData
    
}

public extension AiaJSONSerializer {
    
    static func jsonArrayFromModelArray(modelArray: [AiaModel]) throws -> [AnyObject] {
        var jsonArray: [AnyObject] = []
        
        for model in modelArray {
            let jsonDictionary = try jsonDictionaryFromModel(model)
            jsonArray.append(jsonDictionary)
        }
        
        return jsonArray
    }
    
    static func jsonArrayDataFromModelArray(modelArray: [AiaModel]) throws -> NSData {
        let jsonArray = try jsonArrayFromModelArray(modelArray)
        let jsonArrayData = try NSJSONSerialization.dataWithJSONObject(jsonArray, options: [])
        return jsonArrayData
    }
    
    
    
    static func jsonDictionaryFromModelDictionary(modelDictionary: [String: AiaModel]) throws -> [String: AnyObject] {
        var jsonDictionary: [String: AnyObject] = [:]
        
        for (key, model) in modelDictionary {
            jsonDictionary[key] = try jsonDictionaryFromModel(model)
        }
        
        return jsonDictionary
    }
    
    static func jsonDictionaryDataFromModelDictionary(modelDictionary: [String: AiaModel]) throws -> NSData {
        let jsonDictionary = try jsonDictionaryFromModelDictionary(modelDictionary)
        let jsonDictionaryData = try NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: [])
        return jsonDictionaryData
    }
    
    
    
    static func jsonDictionaryFromModel(model: AiaModel) throws -> [String: AnyObject] {
        throw AiaJSONConversionError.InvalidJSONDictionaryStructure
        
    }
    static func jsonDictionaryDataFromModel(model: AiaModel) throws -> NSData {
        let jsonDictionary = try jsonDictionaryFromModel(model)
        let jsonDictionaryData = try NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: [])
        return jsonDictionaryData
    }
}


// MARK: - AiaJSONDeserializer
public protocol AiaJSONDeserializer {
    
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArray jsonArray: [AnyObject]) throws -> [AiaModel]
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArrayData jsonData: NSData) throws -> [AiaModel]
    
    
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionary jsonDictionary: [String: AnyObject]) throws -> [String: AiaModel]
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> [String: AiaModel]
    
    
    static func modelOfType(modelType: AiaModel.Type, fromJSONDictionary jsonDictionary: [String: AnyObject]) throws -> AiaModel
    static func modelOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> AiaModel
}

public extension AiaJSONDeserializer {
    
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArray jsonArray: [AnyObject]) throws -> [AiaModel] {
        var models: [AiaModel] = []
        
        for jsonObject in jsonArray {
            if let jsonDictionary = jsonObject as? [String: AnyObject] {
                let model = try modelOfType(modelType, fromJSONDictionary: jsonDictionary)
                models.append(model)
            } else {
                throw AiaJSONConversionError.InvalidJSONDictionaryStructure
            }
        }
        
        return models
    }
    
    static func modelArrayOfType(modelType: AiaModel.Type, fromJSONArrayData jsonData: NSData) throws -> [AiaModel] {
        if let jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [AnyObject] {
            let models = try modelArrayOfType(modelType, fromJSONArray: jsonArray)
            return models
        } else {
            throw AiaJSONConversionError.InvalidJSONArrayStructure
        }
    }
    
    
    
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionary jsonDictionary: [String: AnyObject]) throws -> [String: AiaModel] {
        var modelDic: [String: AiaModel] = [:]
        
        for (key, value) in jsonDictionary {
            if let valueDictionary = value as? [String: AnyObject] {
                let model = try modelOfType(modelType, fromJSONDictionary: valueDictionary)
                modelDic[key] = model
            } else {
                throw AiaJSONConversionError.InvalidJSONDictionaryStructure
            }
        }
        
        return modelDic
    }
    
    static func modelDictionaryOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> [String: AiaModel] {
        if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject] {
            let modelDic = try modelDictionaryOfType(modelType, fromJSONDictionary: jsonDictionary)
            return modelDic
        } else {
            throw AiaJSONConversionError.InvalidJSONDictionaryStructure
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
        
        if let cachedMapping = AiaConverter.cachedPropertyKeyMapping["\(modelType)"] {
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
            
            AiaConverter.cachedPropertyKeyMapping["\(modelType)"] = propertyMapping
        }
        
        for (propertyName, mappedJSONKey) in propertyMapping {
            if let value = jsonDictionary[mappedJSONKey] {
                model.setValue(value, forPropertyName: propertyName)
            }
        }
        
        return model
    }
    
    static func modelOfType(modelType: AiaModel.Type, fromJSONDictionaryData jsonData: NSData) throws -> AiaModel {
        if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject] {
            let model = try modelOfType(modelType, fromJSONDictionary: jsonDictionary)
            return model
        } else {
            throw AiaJSONConversionError.InvalidJSONDictionaryStructure
        }
    }
}



