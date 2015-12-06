//
//  AiaReflection.swift
//  Aiakos
//
//  Created by Zhu Shengqi on 12/6/15.
//  Copyright © 2015 DSoftware. All rights reserved.
//

import Foundation


// This convenience function is of poor use: when nil is returned, type information is discarded
func optionalizeAny(any: Any) -> Any? {
    let mirror = Mirror(reflecting: any)
    if let displayStyle = mirror.displayStyle where displayStyle == .Optional {
        if mirror.children.count > 0 {
            let (_, value) = mirror.children[mirror.children.startIndex]
            return value
        } else {
            return nil
        }
    } else {
        return any
    }
}