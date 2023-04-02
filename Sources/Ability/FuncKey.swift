//
//  FunctionKey.swift
//  
//
//  Created by 黄磊 on 2022/10/22.
//

import Foundation

/// 方法 key 协议
public protocol FuncKeyProtocol: Hashable, CustomStringConvertible {
    associatedtype Input
    associatedtype Return
}

public protocol DefaultFuncKeyProtocol: FuncKeyProtocol {
    func defaultRun(_ input: Input) -> Return
}

extension DefaultFuncKeyProtocol where Input == Void {
    public func defaultRun() -> Return {
        defaultRun(())
    }
}

/// 方法对应 key
public struct FuncKey<Input, Return>: FuncKeyProtocol {
    let funcId: String
    
    public init(funcId: String) {
        self.funcId = funcId
    }
    
    public var description: String {
        "\(funcId)(\(String(describing: Input.self))) -> \(String(describing: Return.self))"
    }
}

public struct DefaultFuncKey<Input, Return>: DefaultFuncKeyProtocol {
    let funcKey: FuncKey<Input, Return>
    let run: (_ input: Input) -> Return
    
    public init(funcId: String, defaultRun: @escaping (_ input: Input) -> Return) {
        self.funcKey = .init(funcId: funcId)
        self.run = defaultRun
    }
    
    public func defaultRun(_ input: Input) -> Return {
        run(input)
    }
    
    public var description: String {
        "\(funcKey.funcId)(\(String(describing: Input.self))) -> \(String(describing: Return.self))"
    }
    
    public static func == (lhs: DefaultFuncKey<Input, Return>, rhs: DefaultFuncKey<Input, Return>) -> Bool {
        lhs.funcKey == rhs.funcKey
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(funcKey)
    }
}

/// 方法包装器
public struct FuncWrapper {
    let funcKey: any FuncKeyProtocol
    let block : Any
    
    public init<Func:FuncKeyProtocol>(_ funcKey: Func, _ block: @escaping (Func.Input) -> Func.Return) {
        self.funcKey = funcKey
        self.block = block
    }
    
    public init<Func:FuncKeyProtocol>(_ funcKey: Func, _ block: @escaping () -> Func.Return) where Func.Input == Void {
        self.funcKey = funcKey
        self.block = block
    }
}
