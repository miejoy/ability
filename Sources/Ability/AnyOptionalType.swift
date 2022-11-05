//
//  AnyOptionalType.swift
//  
//
//  Created by 黄磊 on 2022/10/29.
//

import Foundation

/// 任意可选类型协议
/// 这个协议主要用作将关联类型为可选类型的值进行外层自动解包，避免出现两层 Optional
public protocol AnyOptionalType {
    static var wrappedType: Any.Type { get }
    static var `nil`: Any { get }
    var wrappedValue: Any? { get }
}

/// 可选类型协议
public protocol OptionalType: AnyOptionalType {
    associatedtype Wrapped
}

extension OptionalType {
    public static var wrappedType: Any.Type {
        return Wrapped.self
    }
}

extension Optional: OptionalType {
    public static var `nil`: Any {
        Self.none as Any
    }

    public var wrappedValue: Any? {
        self
    }
}
