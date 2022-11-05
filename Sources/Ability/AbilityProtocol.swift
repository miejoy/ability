//
//  AbilityProtocol.swift
//  
//
//  Created by 黄磊 on 2022/10/22.
//

import Foundation

/// 基础能力协议
public protocol AbilityProtocol: AnyObject {
    /// 能力名称，各能力自行设定
    static var abilityName : AbilityName { get }
    func load()
}

extension AbilityProtocol {
    /// 默认加载方法
    public func load() {
    }
}

/// 能力名
public struct AbilityName: CustomStringConvertible, Hashable {
    public let identifier: ObjectIdentifier
    let name: String
    let runCheck: (_ ability: any AbilityProtocol) -> Bool
    
    public init<T>(_ protocolType:T.Type) {
        self.identifier = ObjectIdentifier(T.Type.self)
        self.name = String(describing: T.Type.self)
        self.runCheck = { ability in
            ability is T
        }
    }
    
    public var description: String {
        name
    }
    
    public static func == (lhs: AbilityName, rhs: AbilityName) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
}
