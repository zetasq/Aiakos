//
//  AiaJSONSerializable.swift
//  Aiakos
//
//  Created by Zhu Shengqi on 12/5/15.
//  Copyright © 2015 DSoftware. All rights reserved.
//

public protocol AiaJSONCustomConvertible: AiaJSONCustomDeserializable {}

public protocol AiaJSONCustomDeserializable {
    static func customTypeForJSONDeserializationFromJSONArray(array: [AnyObject]) -> AiaModel.Type
    static func customTypeForJSONDeserializationFromJSONDictionary(dictionary: [String: AnyObject]) -> AiaModel.Type
}

public protocol AiaJSONCustomPropertyMapping {
    static var customPropertyMapping: [String: String] { get }
}
