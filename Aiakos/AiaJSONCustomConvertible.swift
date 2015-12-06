//
//  AiaJSONSerializable.swift
//  Aiakos
//
//  Created by Zhu Shengqi on 12/5/15.
//  Copyright © 2015 DSoftware. All rights reserved.
//

public protocol AiaJSONCustomConvertible: AiaJSONCustomSerializable, AiaJSONCustomDeserializable {}

public protocol AiaJSONCustomSerializable {
    static func customTypeForJSONSerializationFromJSONArray(array: [AnyObject]) -> AiaModel.Type
    static func customTypeForJSONSerializationFromJSONDictionary(dictionary: [String: AnyObject]) -> AiaModel.Type
}

public protocol AiaJSONCustomDeserializable {
    static func customTypeForJSONDeserializationFromJSONArray(array: [AnyObject]) -> AiaModel.Type
    static func customTypeForJSONDeserializationFromJSONDictionary(dictionary: [String: AnyObject]) -> AiaModel.Type
}

public protocol AiaJSONCustomPropertyMapping {
    var customPropertyMapping: DictionaryLiteral<String, String> { get }
}
